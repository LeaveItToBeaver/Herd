import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:flutter/services.dart'; // For PlatformException BAD_DECRYPT
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';
import 'package:herdapp/features/social/chat_messaging/utils/secure_media_service.dart';

/// Extension to MessageRepository for handling encrypted media messages
class EncryptedMediaMessageHandler {
  final ChatCryptoService _cryptoService;
  final SecureMediaService _mediaService;
  final FirebaseFirestore _firestore;

  EncryptedMediaMessageHandler(
    this._cryptoService,
    this._mediaService,
    this._firestore,
  );

  /// Send an encrypted media message
  Future<MessageModel> sendEncryptedMediaMessage({
    required String chatId,
    required String senderId,
    required File mediaFile,
    required MessageType mediaType,
    required List<String> participants,
    String? caption,
    String? replyToMessageId,
    String? senderName,
    Function(double)? onUploadProgress,
  }) async {
    try {
      debugPrint('📱 Starting encrypted media message send');

      if (participants.length != 2) {
        throw Exception('Encrypted media currently only supports direct chats');
      }

      // Step 1: derive chat key (with BAD_DECRYPT recovery)
      final otherId = participants.firstWhere((p) => p != senderId);
      Uint8List? otherPubKeyBytes =
          await _cryptoService.getPeerPublicKeyBytes(_firestore, otherId);
      if (otherPubKeyBytes == null) {
        throw Exception('Cannot encrypt media: recipient missing public key');
      }

      SecretKey? chatKey;
      for (var attempt = 0; attempt < 2 && chatKey == null; attempt++) {
        try {
          chatKey = await _cryptoService.deriveDirectChatKey(
            otherPublicKeyBytes: otherPubKeyBytes!,
            chatId: chatId,
          );
        } on PlatformException catch (e) {
          final msg = e.message ?? '';
          if (msg.contains('BAD_DECRYPT')) {
            debugPrint(
                'BAD_DECRYPT during media derivation (attempt ${attempt + 1}) – regenerating identity keys');
            try {
              await _cryptoService.deleteStoredKeys();
              await _cryptoService.ensureKeyPairExists();
              await _cryptoService.ensureIdentityKeyPublished(
                  _firestore, senderId);
              // refresh peer key cache just in case
              otherPubKeyBytes = await _cryptoService.getPeerPublicKeyBytes(
                  _firestore, otherId);
            } catch (re) {
              debugPrint('Identity key regeneration failed: $re');
            }
          } else {
            rethrow;
          }
        }
      }
      if (chatKey == null) {
        throw Exception(
            'Failed to derive chat encryption key after recovery attempts');
      }

      // Step 2: generate media key
      final mediaKey = await _mediaService.generateMediaKey();

      // Step 3: upload encrypted media
      final uploadResult = await _mediaService.uploadEncryptedMedia(
        mediaFile: mediaFile,
        chatId: chatId,
        senderId: senderId,
        mediaKey: mediaKey,
        onProgress: onUploadProgress,
      );

      // Step 4: build payload
      final mediaKeyBytes = await mediaKey.extractBytes();
      final encryptedMediaPayload = {
        'type': 'encrypted_media',
        'media_type': mediaType.toString().split('.').last,
        'media_key': base64Encode(mediaKeyBytes),
        'download_url': uploadResult.downloadUrl,
        'nonce': uploadResult.encryptionNonce,
        'mac': uploadResult.encryptionMac,
        'metadata': uploadResult.originalMetadata,
        'upload_size': uploadResult.uploadSize,
        'caption': caption,
      };

      // Step 5: encrypt metadata payload
      final encryptedPayload = await _cryptoService.encryptPayload(
        key: chatKey,
        plaintext: {
          'content': caption ?? '',
          'media': encryptedMediaPayload,
        },
      );

      // Step 6: store message
      final messageRef = _firestore
          .collection('chatMessages')
          .doc(chatId)
          .collection('messages')
          .doc();

      final messageData = {
        'id': messageRef.id,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': senderName,
        'type': mediaType.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
        'isDeleted': false,
        'replyToMessageId': replyToMessageId,
        'reactions': <String, dynamic>{},
        'readReceipts': <String, dynamic>{},
        // Encrypted payload containing media info
        ...encryptedPayload,
      };

      await messageRef.set(messageData);

      // --- Step 7: Update userChats metadata ---
      final batch = _firestore.batch();
      for (final participantId in participants) {
        final userChatRef = _firestore
            .collection('userChats')
            .doc(participantId)
            .collection('chats')
            .doc(chatId);

        final updateData = <String, dynamic>{
          'lastActivity': FieldValue.serverTimestamp(),
          'lastMessage': {
            'text': caption?.isNotEmpty == true ? caption : '📎 Media',
            'senderId': senderId,
            'timestamp': FieldValue.serverTimestamp(),
            'type': mediaType.toString().split('.').last,
            'isMedia': true,
          },
        };

        if (participantId != senderId) {
          updateData['unreadCount'] = FieldValue.increment(1);
        }

        batch.update(userChatRef, updateData);
      }

      await batch.commit();

      debugPrint('Encrypted media message sent successfully');

      return MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        senderName: senderName,
        content: caption,
        type: mediaType,
        timestamp: DateTime.now(),
        mediaUrl: uploadResult.downloadUrl, // This will be the encrypted URL
        // Store metadata for UI purposes
        fileName: uploadResult.originalMetadata['originalName'],
        fileSize: uploadResult.originalMetadata['size'],
      );
    } catch (e) {
      debugPrint('Failed to send encrypted media message: $e');
      rethrow;
    }
  }

  /// Decrypt media message and return decrypted media info
  Future<DecryptedMediaInfo?> decryptMediaMessage({
    required MessageModel message,
    required String currentUserId,
    required List<String> participants,
  }) async {
    try {
      debugPrint('🔓 Decrypting media message: ${message.id}');

      if (participants.length != 2) {
        throw Exception('Encrypted media currently only supports direct chats');
      }

      // Step 1: Get the other participant's public key
      final otherId = participants.firstWhere((p) => p != currentUserId);
      final otherPubKeyBytes =
          await _cryptoService.getPeerPublicKeyBytes(_firestore, otherId);

      if (otherPubKeyBytes == null) {
        throw Exception('Cannot decrypt media: missing peer public key');
      }

      // Step 2: Derive chat decryption key
      final chatKey = await _cryptoService.deriveDirectChatKey(
        otherPublicKeyBytes: otherPubKeyBytes,
        chatId: message.chatId,
      );

      // Step 3: Get encrypted payload from Firestore (if not already in message)
      Map<String, dynamic> encryptedData;
      if (message.mediaUrl != null) {
        // We need to fetch the full message from Firestore to get encryption data
        final messageDoc = await _firestore
            .collection('chatMessages')
            .doc(message.chatId)
            .collection('messages')
            .doc(message.id)
            .get();

        if (!messageDoc.exists) {
          throw Exception('Message not found');
        }

        encryptedData = messageDoc.data()!;
      } else {
        throw Exception('No media URL in message');
      }

      // Step 4: Decrypt the message payload
      final decryptedPayload = await _cryptoService.decryptPayload(
        key: chatKey,
        encrypted: {
          'ciphertext': encryptedData['ciphertext'],
          'nonce': encryptedData['nonce'],
          'mac': encryptedData['mac'],
          'alg': encryptedData['alg'],
          'v': encryptedData['v'],
        },
      );

      final mediaInfo = decryptedPayload['media'] as Map<String, dynamic>?;
      if (mediaInfo == null) {
        throw Exception('No media info in decrypted payload');
      }

      // Step 5: Extract media decryption info
      final mediaKeyBytes = base64Decode(mediaInfo['media_key'] as String);
      final mediaKey = SecretKey(mediaKeyBytes);

      return DecryptedMediaInfo(
        mediaKey: mediaKey,
        downloadUrl: mediaInfo['download_url'] as String,
        nonce: Uint8List.fromList(List<int>.from(mediaInfo['nonce'])),
        mac: Uint8List.fromList(List<int>.from(mediaInfo['mac'])),
        metadata: mediaInfo['metadata'] as Map<String, dynamic>,
        caption: mediaInfo['caption'] as String?,
        uploadSize: mediaInfo['upload_size'] as int,
      );
    } catch (e) {
      debugPrint('Failed to decrypt media message: $e');
      return null;
    }
  }

  /// Download and decrypt media file for display
  Future<File?> downloadDecryptedMedia({
    required DecryptedMediaInfo mediaInfo,
    Function(double)? onProgress,
  }) async {
    try {
      return await _mediaService.downloadAndDecryptMedia(
        downloadUrl: mediaInfo.downloadUrl,
        mediaKey: mediaInfo.mediaKey,
        nonce: mediaInfo.nonce,
        mac: mediaInfo.mac,
        onProgress: onProgress,
      );
    } catch (e) {
      debugPrint('Failed to download decrypted media: $e');
      return null;
    }
  }

  /// Clean up temporary media files
  Future<void> cleanupTempMediaFiles() async {
    await _mediaService.cleanupTempFiles(
      olderThan: const Duration(hours: 24),
    );
  }
}

/// Decrypted media information
class DecryptedMediaInfo {
  final SecretKey mediaKey;
  final String downloadUrl;
  final Uint8List nonce;
  final Uint8List mac;
  final Map<String, dynamic> metadata;
  final String? caption;
  final int uploadSize;

  DecryptedMediaInfo({
    required this.mediaKey,
    required this.downloadUrl,
    required this.nonce,
    required this.mac,
    required this.metadata,
    this.caption,
    required this.uploadSize,
  });

  String get fileName => metadata['originalName'] as String;
  String get mimeType => metadata['mimeType'] as String;
  int get fileSize => metadata['size'] as int;
  String get fileExtension => metadata['extension'] as String;
}
