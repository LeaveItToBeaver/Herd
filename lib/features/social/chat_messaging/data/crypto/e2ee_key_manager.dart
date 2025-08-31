import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';

/// Service for managing E2EE user keys initialization and synchronization
class E2EEKeyManager {
  static const String _keyInitializedKey = 'e2ee_key_initialized_v1';
  static const String _lastSyncTimestampKey = 'e2ee_last_sync_timestamp';

  final FlutterSecureStorage _secureStorage;
  final ChatCryptoService _cryptoService;
  final FirebaseFirestore _firestore;

  E2EEKeyManager(this._secureStorage, this._cryptoService, this._firestore);

  /// Initialize E2EE keys for a user during app startup
  Future<void> initializeUserKeys(String userId) async {
    try {
      debugPrint('🔐 Starting E2EE key initialization for user: $userId');

      // Step 1: Generate or load existing key from device
      final userKey = await _generateOrLoadUserKey();

      // Step 2: Check and sync with Firestore
      await _checkAndSyncWithFirestore(userId, userKey);

      // Mark as initialized
      await _secureStorage.write(key: _keyInitializedKey, value: 'true');
      await _secureStorage.write(
          key: _lastSyncTimestampKey,
          value: DateTime.now().millisecondsSinceEpoch.toString());

      debugPrint('✅ E2EE key initialization completed for user: $userId');
    } catch (e) {
      debugPrint('❌ E2EE key initialization failed for user $userId: $e');
      rethrow;
    }
  }

  /// Check if keys have been initialized
  Future<bool> isKeyInitialized() async {
    final initialized = await _secureStorage.read(key: _keyInitializedKey);
    return initialized == 'true';
  }

  /// Force re-initialization of keys (for manual reset)
  Future<void> resetAndReinitializeKeys(String userId) async {
    try {
      debugPrint('🔄 Resetting E2EE keys for user: $userId');

      // Clear local storage
      await _secureStorage.delete(key: _keyInitializedKey);
      await _secureStorage.delete(key: _lastSyncTimestampKey);

      // Delete existing identity keys
      await _cryptoService.deleteStoredKeys();

      // Reinitialize
      await initializeUserKeys(userId);

      debugPrint('✅ E2EE keys reset and reinitialized for user: $userId');
    } catch (e) {
      debugPrint('❌ E2EE key reset failed for user $userId: $e');
      rethrow;
    }
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus(String userId) async {
    try {
      final isInitialized = await isKeyInitialized();
      final lastSyncStr = await _secureStorage.read(key: _lastSyncTimestampKey);
      final lastSync = lastSyncStr != null
          ? DateTime.fromMillisecondsSinceEpoch(int.parse(lastSyncStr))
          : null;

      final hasLocalKey = await _cryptoService.hasStoredKeys();
      final hasRemoteKey = await _hasRemoteKey(userId);

      return {
        'isInitialized': isInitialized,
        'lastSync': lastSync?.toIso8601String(),
        'hasLocalKey': hasLocalKey,
        'hasRemoteKey': hasRemoteKey,
        'status': _determineStatus(isInitialized, hasLocalKey, hasRemoteKey),
      };
    } catch (e) {
      return {
        'error': e.toString(),
        'status': 'error',
      };
    }
  }

  /// Generate new user key or load existing one from device storage
  Future<String> _generateOrLoadUserKey() async {
    // Try to load existing key from device
    final existingKey = await _cryptoService.exportPublicIdentityKeyBase64();

    if (existingKey.isNotEmpty) {
      debugPrint('📱 Found existing user key on device');
      return existingKey;
    } else {
      debugPrint('🆕 Generating new user key');
      // This will create a new key pair and store it securely
      await _cryptoService.ensureKeyPairExists();
      return await _cryptoService.exportPublicIdentityKeyBase64();
    }
  }

  /// Check user key in Firestore and sync if needed
  Future<void> _checkAndSyncWithFirestore(
      String userId, String localKey) async {
    try {
      final userKeyDoc =
          await _firestore.collection('userKeys').doc(userId).get();

      if (userKeyDoc.exists) {
        final remoteKey = userKeyDoc.data()?['publicKey'] as String?;

        if (remoteKey != null && remoteKey == localKey) {
          debugPrint('✅ Local and remote keys match - no sync needed');
          return;
        } else {
          debugPrint('🔄 Keys don\'t match - updating remote key');
          await _updateRemoteKey(userId, localKey);
        }
      } else {
        debugPrint('🆕 No remote key found - creating new one');
        await _updateRemoteKey(userId, localKey);
      }
    } catch (e) {
      debugPrint('❌ Failed to sync with Firestore: $e');
      rethrow;
    }
  }

  /// Update the user's key in Firestore
  Future<void> _updateRemoteKey(String userId, String publicKey) async {
    await _firestore.collection('userKeys').doc(userId).set({
      'publicKey': publicKey,
      'userId': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastSyncedAt': FieldValue.serverTimestamp(),
      'version': 1,
    }, SetOptions(merge: true));

    debugPrint('✅ Remote key updated for user: $userId');
  }

  /// Check if user has a remote key in Firestore
  Future<bool> _hasRemoteKey(String userId) async {
    try {
      final doc = await _firestore.collection('userKeys').doc(userId).get();
      return doc.exists && doc.data()?['publicKey'] != null;
    } catch (e) {
      return false;
    }
  }

  /// Determine overall status based on key states
  String _determineStatus(
      bool isInitialized, bool hasLocalKey, bool hasRemoteKey) {
    if (!isInitialized) return 'not_initialized';
    if (!hasLocalKey) return 'missing_local_key';
    if (!hasRemoteKey) return 'missing_remote_key';
    return 'synchronized';
  }
}
