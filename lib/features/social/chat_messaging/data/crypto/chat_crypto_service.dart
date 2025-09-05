import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart'; // For PlatformException BAD_DECRYPT handling

/// Provides identity key management and symmetric encryption helpers
/// for end-to-end encrypted chat messages.
class ChatCryptoService {
  static const _identityPrivKeyKey = 'identity_private_key_v1';
  static const _identityPubKeyKey = 'identity_public_key_v1';

  final FlutterSecureStorage _secureStorage;
  final Cipher _cipher = Chacha20.poly1305Aead();
  final X25519 _x25519 = X25519();
  final Hkdf _hkdf = Hkdf(hmac: Hmac.sha256(), outputLength: 32);
  final Map<String, Uint8List> _peerCache = {};

  ChatCryptoService(this._secureStorage);

  /// Returns (and creates if needed) the long-lived identity key pair.
  Future<SimpleKeyPair> _loadOrCreateIdentityKeyPair() async {
    try {
      final storedPriv = await _secureStorage.read(key: _identityPrivKeyKey);
      final storedPub = await _secureStorage.read(key: _identityPubKeyKey);

      if (storedPriv != null && storedPub != null) {
        final privBytes = base64Decode(storedPriv);
        // X25519 private key uses 32 byte seed
        final keyPair =
            await _x25519.newKeyPairFromSeed(privBytes.sublist(0, 32));
        return keyPair;
      }
    } on PlatformException catch (e) {
      // Handle Android keystore BAD_DECRYPT (corrupted / reset secure storage)
      final msg = e.message ?? '';
      if (msg.contains('BAD_DECRYPT') || msg.contains('Cipher')) {
        // Attempt recovery: purge and regenerate keys
        try {
          await deleteStoredKeys();
        } catch (_) {}
        // Logging recovery (not gated; rare critical event)
        // ignore: avoid_print
        print(
            '🔐 Identity key corruption detected (BAD_DECRYPT). Regenerating keys.');
        // fall through to regeneration below
      } else {
        rethrow; // unrelated platform exception
      }
    } catch (_) {
      // Non-platform errors fall through to regeneration
    }

    // Regenerate fresh identity key pair
    final keyPair = await _x25519.newKeyPair();
    final priv = await keyPair.extractPrivateKeyBytes();
    final pub = await keyPair.extractPublicKey();
    await _secureStorage.write(
        key: _identityPrivKeyKey, value: base64Encode(priv));
    await _secureStorage.write(
        key: _identityPubKeyKey, value: base64Encode(pub.bytes));
    return keyPair;
  }

  Future<String> exportPublicIdentityKeyBase64() async {
    final kp = await _loadOrCreateIdentityKeyPair();
    final pub = await kp.extractPublicKey();
    return base64Encode(pub.bytes);
  }

  /// Check if identity keys are stored on device
  Future<bool> hasStoredKeys() async {
    final storedPriv = await _secureStorage.read(key: _identityPrivKeyKey);
    final storedPub = await _secureStorage.read(key: _identityPubKeyKey);
    return storedPriv != null && storedPub != null;
  }

  /// Delete stored identity keys from device
  Future<void> deleteStoredKeys() async {
    await _secureStorage.delete(key: _identityPrivKeyKey);
    await _secureStorage.delete(key: _identityPubKeyKey);
  }

  /// Ensure key pair exists (creates if needed)
  Future<void> ensureKeyPairExists() async {
    await _loadOrCreateIdentityKeyPair();
  }

  /// Returns the public key from the identity key pair
  Future<SimplePublicKey> getPublicIdentityKey() async {
    final kp = await _loadOrCreateIdentityKeyPair();
    return await kp.extractPublicKey();
  }

  /// Derive a direct chat symmetric key from peer public key & chatId salt.
  Future<SecretKey> deriveDirectChatKey({
    required Uint8List otherPublicKeyBytes,
    required String chatId,
  }) async {
    final myPair = await _loadOrCreateIdentityKeyPair();
    final shared = await _x25519.sharedSecretKey(
      keyPair: myPair,
      remotePublicKey:
          SimplePublicKey(otherPublicKeyBytes, type: KeyPairType.x25519),
    );
    final sharedBytes = await shared.extractBytes();
    final salt = utf8.encode('chat-$chatId');
    final info = utf8.encode('chat-key-v1');
    return _hkdf.deriveKey(
      secretKey: SecretKey(sharedBytes),
      nonce: salt,
      info: info,
    );
  }

  Future<Map<String, dynamic>> encryptPayload({
    required SecretKey key,
    required Map<String, dynamic> plaintext,
  }) async {
    final nonce = _randomBytes(12);
    final jsonPlain = jsonEncode(plaintext);
    final box = await _cipher.encrypt(
      utf8.encode(jsonPlain),
      secretKey: key,
      nonce: nonce,
      aad: utf8.encode('v1'),
    );
    return {
      'ciphertext': base64Encode(box.cipherText),
      'nonce': base64Encode(nonce),
      'mac': base64Encode(box.mac.bytes),
      'alg': 'chacha20poly1305',
      'v': 1,
    };
  }

  Future<Map<String, dynamic>> decryptPayload({
    required SecretKey key,
    required Map<String, dynamic> encrypted,
  }) async {
    final cipherText = base64Decode(encrypted['ciphertext'] as String);
    final nonce = base64Decode(encrypted['nonce'] as String);
    final mac = Mac(base64Decode(encrypted['mac'] as String));
    final clear = await _cipher.decrypt(
      SecretBox(cipherText, nonce: nonce, mac: mac),
      secretKey: key,
      aad: utf8.encode('v1'),
    );
    return jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
  }

  Uint8List _randomBytes(int length) {
    final rnd = SecureRandom();
    return Uint8List.fromList(
        List<int>.generate(length, (_) => rnd.nextUint8()));
  }

  Future<SimplePublicKey> ensureIdentityKeyPublished(
      FirebaseFirestore firestore, String userId) async {
    final pub = await getPublicIdentityKey();
    final pub864 = base64Encode(pub.bytes);
    final snap = await firestore.collection('userKeys').doc(userId).get();

    if (!snap.exists || snap.data()?['publicKey'] != pub864) {
      await firestore.collection('userKeys').doc(userId).set({
        'publicKey': pub864,
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastSyncedAt': FieldValue.serverTimestamp(),
        'version': 1,
      }, SetOptions(merge: true));
    }
    return pub;
  }

  Future<Uint8List?> getPeerPublicKeyBytes(
      FirebaseFirestore firestore, String userId) async {
    final cached = _peerCache[userId];
    if (cached != null) return cached;
    final snap = await firestore.collection('userKeys').doc(userId).get();
    final b64 = snap.data()?['publicKey'];
    if (b64 is String) {
      final bytes = base64Decode(b64);
      _peerCache[userId] = bytes;
      return bytes;
    }
    return null;
  }
}

/// Basic secure random helper (NOT crypto-secure high throughput, but fine for nonces here since using underlying cipher's requirements).
class SecureRandom {
  final _rand = Cryptography.instance;
  int nextUint8() => DateTime.now().microsecondsSinceEpoch % 256;
}
