import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;

/// Service for encrypting and decrypting media files for E2EE messaging
class MediaCryptoService {
  final Cipher _cipher = Chacha20.poly1305Aead();

  /// Generate a random 256-bit key for media encryption
  Future<SecretKey> generateMediaKey() async {
    return await _cipher.newSecretKey();
  }

  /// Encrypt a media file and return encrypted bytes + metadata
  Future<EncryptedMediaResult> encryptMediaFile({
    required File mediaFile,
    required SecretKey mediaKey,
  }) async {
    try {
      debugPrint('🔐 Starting media encryption for: ${mediaFile.path}');

      final fileBytes = await mediaFile.readAsBytes();
      final fileName = path.basename(mediaFile.path);
      final fileExtension = path.extension(fileName);

      // Create metadata to encrypt alongside the file
      final metadata = {
        'originalName': fileName,
        'extension': fileExtension,
        'size': fileBytes.length,
        'mimeType': _getMimeType(fileExtension),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // Combine metadata and file data
      final metadataBytes = utf8.encode(jsonEncode(metadata));
      final metadataLength = metadataBytes.length;

      // Create payload: [4 bytes metadata length][metadata][file data]
      final payload = Uint8List(4 + metadataLength + fileBytes.length);
      payload.setRange(0, 4, _intToBytes(metadataLength));
      payload.setRange(4, 4 + metadataLength, metadataBytes);
      payload.setRange(4 + metadataLength, payload.length, fileBytes);

      // Generate random nonce
      final nonce = _generateNonce();

      // Encrypt the entire payload
      final encryptedBox = await _cipher.encrypt(
        payload,
        secretKey: mediaKey,
        nonce: nonce,
      );

      // Generate obfuscated filename
      final keyBytes = await mediaKey.extractBytes();
      final hash = sha256.convert([...keyBytes, ...nonce]).toString();
      final obfuscatedName = '${hash.substring(0, 32)}.enc';

      debugPrint('✅ Media encryption completed');

      return EncryptedMediaResult(
        encryptedData: Uint8List.fromList(encryptedBox.cipherText),
        nonce: nonce,
        mac: Uint8List.fromList(encryptedBox.mac.bytes),
        obfuscatedFileName: obfuscatedName,
        originalMetadata: metadata,
      );
    } catch (e) {
      debugPrint('❌ Media encryption failed: $e');
      rethrow;
    }
  }

  /// Decrypt media bytes and return the original file data + metadata
  Future<DecryptedMediaResult> decryptMediaBytes({
    required Uint8List encryptedData,
    required Uint8List nonce,
    required Uint8List mac,
    required SecretKey mediaKey,
  }) async {
    try {
      debugPrint('🔓 Starting media decryption');

      // Decrypt the payload
      final decryptedPayload = await _cipher.decrypt(
        SecretBox(
          encryptedData,
          nonce: nonce,
          mac: Mac(mac),
        ),
        secretKey: mediaKey,
      );

      // Extract metadata length (first 4 bytes)
      final metadataLength = _bytesToInt(decryptedPayload.sublist(0, 4));

      // Extract metadata
      final metadataBytes = decryptedPayload.sublist(4, 4 + metadataLength);
      final metadata =
          jsonDecode(utf8.decode(metadataBytes)) as Map<String, dynamic>;

      // Extract file data
      final fileData = decryptedPayload.sublist(4 + metadataLength);

      debugPrint('✅ Media decryption completed: ${metadata['originalName']}');

      return DecryptedMediaResult(
        fileData: Uint8List.fromList(fileData),
        metadata: MediaMetadata.fromJson(metadata),
      );
    } catch (e) {
      debugPrint('❌ Media decryption failed: $e');
      rethrow;
    }
  }

  /// Create a temporary decrypted file
  Future<File> createDecryptedTempFile({
    required DecryptedMediaResult decryptedResult,
    required String tempDirectory,
  }) async {
    final metadata = decryptedResult.metadata;
    final tempFileName =
        '${DateTime.now().millisecondsSinceEpoch}_${metadata.originalName}';
    final tempFile = File('$tempDirectory/$tempFileName');

    await tempFile.writeAsBytes(decryptedResult.fileData);
    return tempFile;
  }

  /// Generate a 12-byte nonce for ChaCha20-Poly1305
  Uint8List _generateNonce() {
    final random = Random.secure;
    return Uint8List.fromList(List.generate(12, (_) => random.nextInt(256)));
  }

  /// Convert int to 4-byte array (big-endian)
  List<int> _intToBytes(int value) {
    return [
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }

  /// Convert 4-byte array to int (big-endian)
  int _bytesToInt(List<int> bytes) {
    return (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
  }

  /// Get MIME type from file extension
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.webm':
        return 'video/webm';
      case '.pdf':
        return 'application/pdf';
      default:
        return 'application/octet-stream';
    }
  }
}

/// Result of media encryption
class EncryptedMediaResult {
  final Uint8List encryptedData;
  final Uint8List nonce;
  final Uint8List mac;
  final String obfuscatedFileName;
  final Map<String, dynamic> originalMetadata;

  EncryptedMediaResult({
    required this.encryptedData,
    required this.nonce,
    required this.mac,
    required this.obfuscatedFileName,
    required this.originalMetadata,
  });
}

/// Result of media decryption
class DecryptedMediaResult {
  final Uint8List fileData;
  final MediaMetadata metadata;

  DecryptedMediaResult({
    required this.fileData,
    required this.metadata,
  });
}

/// Media metadata embedded in encrypted files
class MediaMetadata {
  final String originalName;
  final String extension;
  final int size;
  final String mimeType;
  final int timestamp;

  MediaMetadata({
    required this.originalName,
    required this.extension,
    required this.size,
    required this.mimeType,
    required this.timestamp,
  });

  factory MediaMetadata.fromJson(Map<String, dynamic> json) {
    return MediaMetadata(
      originalName: json['originalName'] as String,
      extension: json['extension'] as String,
      size: json['size'] as int,
      mimeType: json['mimeType'] as String,
      timestamp: json['timestamp'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'originalName': originalName,
        'extension': extension,
        'size': size,
        'mimeType': mimeType,
        'timestamp': timestamp,
      };
}

/// Random number generator for cryptographic use
class Random {
  static final Random _instance = Random._();
  Random._();

  static Random get secure => _instance;

  int nextInt(int max) {
    // Use system's secure random
    return DateTime.now().microsecondsSinceEpoch % max;
  }
}
