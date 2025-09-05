import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/media_crypto_service.dart';
import 'package:path_provider/path_provider.dart';

/// Service for securely uploading and downloading encrypted media files
class SecureMediaService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final MediaCryptoService _cryptoService = MediaCryptoService();

  /// Upload an encrypted media file to Firebase Storage
  Future<SecureMediaUploadResult> uploadEncryptedMedia({
    required File mediaFile,
    required String chatId,
    required String senderId,
    required SecretKey mediaKey,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('📤 Starting secure media upload for chat: $chatId');

      // Step 1: Encrypt the media file
      final encryptedResult = await _cryptoService.encryptMediaFile(
        mediaFile: mediaFile,
        mediaKey: mediaKey,
      );

      // Step 2: Create storage path (use obfuscated filename)
      final storagePath =
          'encrypted_media/$chatId/${encryptedResult.obfuscatedFileName}';
      final storageRef = _storage.ref().child(storagePath);

      debugPrint('📁 Uploading to path: $storagePath');

      // Step 3: Upload encrypted data
      final uploadTask = storageRef.putData(
        encryptedResult.encryptedData,
        SettableMetadata(
          contentType:
              'application/octet-stream', // Always binary for encrypted data
          customMetadata: {
            'encrypted': 'true',
            'chat_id': chatId,
            'sender_id': senderId,
            'upload_time': DateTime.now().millisecondsSinceEpoch.toString(),
            // Don't store actual filename or any identifiable info
          },
        ),
      );

      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress?.call(progress);
        debugPrint(
            '📊 Upload progress: ${(progress * 100).toStringAsFixed(1)}%');
      });

      final taskSnapshot = await uploadTask;
      final downloadUrl = await taskSnapshot.ref.getDownloadURL();

      debugPrint('✅ Media upload completed: $downloadUrl');

      return SecureMediaUploadResult(
        downloadUrl: downloadUrl,
        storagePath: storagePath,
        encryptionNonce: encryptedResult.nonce,
        encryptionMac: encryptedResult.mac,
        originalMetadata: encryptedResult.originalMetadata,
        uploadSize: encryptedResult.encryptedData.length,
      );
    } catch (e) {
      debugPrint('❌ Secure media upload failed: $e');
      rethrow;
    }
  }

  /// Download and decrypt a media file from Firebase Storage
  Future<File> downloadAndDecryptMedia({
    required String downloadUrl,
    required SecretKey mediaKey,
    required Uint8List nonce,
    required Uint8List mac,
    String? expectedFileName,
    Function(double)? onProgress,
  }) async {
    try {
      debugPrint('📥 Starting secure media download: $downloadUrl');

      // Step 1: Download encrypted data
      final storageRef = _storage.refFromURL(downloadUrl);

      // For progress tracking, we need to use a different approach
      // since Firebase Storage doesn't provide download progress directly
      final encryptedData = await storageRef.getData();

      if (encryptedData == null) {
        throw Exception('Failed to download media data');
      }

      debugPrint('📊 Downloaded ${encryptedData.length} bytes');

      // Step 2: Decrypt the data
      final decryptedResult = await _cryptoService.decryptMediaBytes(
        encryptedData: encryptedData,
        nonce: nonce,
        mac: mac,
        mediaKey: mediaKey,
      );

      // Step 3: Create temporary file with decrypted data
      final tempDir = await getTemporaryDirectory();
      final decryptedFile = await _cryptoService.createDecryptedTempFile(
        decryptedResult: decryptedResult,
        tempDirectory: tempDir.path,
      );

      debugPrint(
          '✅ Media download and decryption completed: ${decryptedFile.path}');

      return decryptedFile;
    } catch (e) {
      debugPrint('❌ Secure media download failed: $e');
      rethrow;
    }
  }

  /// Get metadata for an encrypted media file without downloading the full file
  Future<Map<String, dynamic>?> getEncryptedMediaMetadata({
    required String downloadUrl,
  }) async {
    try {
      final storageRef = _storage.refFromURL(downloadUrl);
      final metadata = await storageRef.getMetadata();

      return metadata.customMetadata;
    } catch (e) {
      debugPrint('❌ Failed to get media metadata: $e');
      return null;
    }
  }

  /// Delete an encrypted media file from storage
  Future<void> deleteEncryptedMedia({
    required String downloadUrl,
  }) async {
    try {
      final storageRef = _storage.refFromURL(downloadUrl);
      await storageRef.delete();
      debugPrint('🗑️ Encrypted media deleted: $downloadUrl');
    } catch (e) {
      debugPrint('❌ Failed to delete encrypted media: $e');
      rethrow;
    }
  }

  /// Clean up old temporary decrypted files
  Future<void> cleanupTempFiles({Duration? olderThan}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cutoffTime =
          DateTime.now().subtract(olderThan ?? const Duration(hours: 24));

      final files = tempDir.listSync().where((entity) =>
          entity is File &&
          entity.path.contains('_') && // Our temp files have timestamp prefix
          entity.statSync().modified.isBefore(cutoffTime));

      for (final file in files) {
        try {
          await file.delete();
          debugPrint('🧹 Cleaned up temp file: ${file.path}');
        } catch (e) {
          debugPrint('⚠️ Failed to delete temp file ${file.path}: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Temp file cleanup failed: $e');
    }
  }

  /// Generate a media encryption key
  Future<SecretKey> generateMediaKey() async {
    return await _cryptoService.generateMediaKey();
  }

  /// Estimate encrypted file size (adds ~16 bytes for MAC + some metadata overhead)
  int estimateEncryptedSize(int originalSize) {
    // Rough estimate: original + metadata (~200 bytes) + MAC (16 bytes) + nonce (12 bytes)
    return originalSize + 250;
  }

  /// Check if we have enough storage quota (if needed)
  Future<bool> checkStorageQuota({required int estimatedSize}) async {
    // This is a placeholder - implement based on your storage quota system
    // You might want to track user uploads in Firestore
    try {
      // For now, just check if it's under a reasonable limit (50MB per file)
      const maxFileSize = 50 * 1024 * 1024; // 50MB
      return estimatedSize <= maxFileSize;
    } catch (e) {
      debugPrint('⚠️ Storage quota check failed: $e');
      return true; // Allow by default if check fails
    }
  }
}

/// Result of secure media upload
class SecureMediaUploadResult {
  final String downloadUrl;
  final String storagePath;
  final Uint8List encryptionNonce;
  final Uint8List encryptionMac;
  final Map<String, dynamic> originalMetadata;
  final int uploadSize;

  SecureMediaUploadResult({
    required this.downloadUrl,
    required this.storagePath,
    required this.encryptionNonce,
    required this.encryptionMac,
    required this.originalMetadata,
    required this.uploadSize,
  });

  /// Convert to JSON for storing in message
  Map<String, dynamic> toJson() => {
        'downloadUrl': downloadUrl,
        'storagePath': storagePath,
        'nonce': encryptionNonce,
        'mac': encryptionMac,
        'metadata': originalMetadata,
        'uploadSize': uploadSize,
      };

  /// Create from JSON stored in message
  factory SecureMediaUploadResult.fromJson(Map<String, dynamic> json) {
    return SecureMediaUploadResult(
      downloadUrl: json['downloadUrl'] as String,
      storagePath: json['storagePath'] as String,
      encryptionNonce: Uint8List.fromList(List<int>.from(json['nonce'])),
      encryptionMac: Uint8List.fromList(List<int>.from(json['mac'])),
      originalMetadata: json['metadata'] as Map<String, dynamic>,
      uploadSize: json['uploadSize'] as int,
    );
  }
}
