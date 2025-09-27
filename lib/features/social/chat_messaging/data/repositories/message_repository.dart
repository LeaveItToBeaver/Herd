import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:cryptography/cryptography.dart'; // For SecretKey caching
import 'package:herdapp/features/social/chat_messaging/data/handlers/encrypted_media_handler.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';
import 'package:herdapp/features/user_management/data/repositories/user_block_repository.dart';

// Verbose logging toggle for message repository (non-error info). Set true for diagnostics.
const bool _verboseMessages = false;
void _v(String msg) {
  if (_verboseMessages && kDebugMode) debugPrint(msg);
}

/// Handles all message CRUD, encryption, and search logic.
class MessageRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _users;
  final ChatCryptoService _crypto;
  final ChatRepository _chats;
  final UserBlockRepository _userBlockRepository;
  static const int _fetchLimit = 50;
  int get pageSize => _fetchLimit;

  // Cache to prevent excessive calls
  final Map<String, List<String>> _participantsCache = {};
  final Map<String, String?> _userKeysCache = {};
  final Map<String, bool> _encryptionCapabilityCache = {};
  // Simple in-memory cache for derived direct chat symmetric keys to avoid
  // re-running X25519 + HKDF every message decrypt. Keyed by chatId:peerId (peerId = other user).
  final Map<String, SecretKey> _directChatKeyCache = {};

  final EncryptedMediaMessageHandler _mediaHandler;

  MessageRepository(this._firestore, this._users, this._crypto, this._chats,
      this._mediaHandler, this._userBlockRepository);

  // Helper method to check if two users can interact (not blocking each other)
  Future<bool> _canUsersInteract(String userId1, String userId2) async {
    try {
      // Check if userId1 blocks userId2
      final user1BlocksUser2 = await _userBlockRepository.isUserBlocked(
        currentUserId: userId1,
        targetUserId: userId2,
      );

      // Check if userId2 blocks userId1
      final user2BlocksUser1 = await _userBlockRepository.isUserBlocked(
        currentUserId: userId2,
        targetUserId: userId1,
      );

      // Users can interact if neither blocks the other
      return !user1BlocksUser2 && !user2BlocksUser1;
    } catch (e) {
      debugPrint('Error checking if users can interact: $e');
      // SECURITY: Default to blocking interaction if there's an error (fail closed)
      return false;
    }
  }

  // Cached methods to prevent excessive calls
  Future<List<String>> _getCachedParticipants(
      String chatId, String userId) async {
    final key = '${chatId}_$userId';
    if (_participantsCache.containsKey(key)) {
      return _participantsCache[key]!;
    }

    try {
      // For direct chats, derive participants from chatId format (more reliable)
      if (chatId.contains('_')) {
        final parts = chatId.split('_');
        if (parts.length == 2) {
          final participants = [parts[0], parts[1]];
          _participantsCache[key] = participants;
          _v('Derived participants from chatId: $participants');
          // Clear cache after 5 minutes to prevent stale data
          Future.delayed(
              const Duration(minutes: 5), () => _participantsCache.remove(key));
          return participants;
        }
      }

      // Fallback: get from user's own chat document (only for group chats)
      final participants = await _chats.getChatParticipants(chatId, userId);
      _participantsCache[key] = participants;
      // Clear cache after 5 minutes to prevent stale data
      Future.delayed(
          const Duration(minutes: 5), () => _participantsCache.remove(key));
      return participants;
    } catch (e) {
      debugPrint('Failed to get cached participants: $e');

      // Emergency fallback: derive from chatId for direct chats
      if (chatId.contains('_')) {
        final parts = chatId.split('_');
        if (parts.length == 2) {
          _v('Using emergency fallback for chatId: $chatId');
          return [parts[0], parts[1]];
        }
      }

      return [userId]; // Return at least the current user
    }
  }

  Future<String?> _getCachedUserKey(String userId) async {
    _v('🔑 Getting cached key for user: $userId');
    if (_userKeysCache.containsKey(userId)) {
      final cached = _userKeysCache[userId];
      _v('Using cached key for $userId: ${cached != null ? 'found' : 'null'}');
      return cached;
    }

    try {
      _v('🔍 Fetching key from Firestore for user: $userId');
      final snap = await _firestore.collection('userKeys').doc(userId).get();
      if (snap.exists && snap.data() != null) {
        final publicKey = snap.data()!['publicKey'] as String?;
        _v('Key retrieved for $userId: ${publicKey != null ? 'found' : 'null'}');
        _userKeysCache[userId] = publicKey;
        Future.delayed(
            const Duration(minutes: 10), () => _userKeysCache.remove(userId));
        return publicKey;
      } else {
        debugPrint('No key document found for user: $userId');
        _userKeysCache[userId] = null;
        return null;
      }
    } catch (e) {
      debugPrint('Failed to get cached user key for $userId: $e');
      _userKeysCache[userId] = null;
      return null;
    }
  }

  Future<bool> _getCachedEncryptionCapability(List<String> participants) async {
    final key = participants.join('_');
    _v('🔍 Checking encryption capability for participants: $participants');

    if (_encryptionCapabilityCache.containsKey(key)) {
      final cached = _encryptionCapabilityCache[key]!;
      _v('Using cached encryption capability: $cached');
      return cached;
    }

    try {
      for (final userId in participants) {
        _v('🔑 Checking key for user: $userId');
        final userKey = await _getCachedUserKey(userId);
        if (userKey == null) {
          _v('No key found for user: $userId');
          _encryptionCapabilityCache[key] = false;
          Future.delayed(const Duration(minutes: 2),
              () => _encryptionCapabilityCache.remove(key));
          return false;
        } else {
          _v('Key found for user: $userId');
        }
      }
      _v('All participants have keys - encryption enabled');
      _encryptionCapabilityCache[key] = true;
      Future.delayed(const Duration(minutes: 5),
          () => _encryptionCapabilityCache.remove(key));
      return true;
    } catch (e) {
      debugPrint('Failed to check cached encryption capability: $e');
      _encryptionCapabilityCache[key] = false;
      return false;
    }
  }

  // Collections
  CollectionReference<Map<String, dynamic>> get _legacyMessages =>
      _firestore.collection('messages'); // legacy flat
  CollectionReference<Map<String, dynamic>> _chatMessages(String chatId) =>
      _firestore.collection('chatMessages').doc(chatId).collection('messages');
  // Note: Legacy chats collection removed - using single collection architecture
  CollectionReference<Map<String, dynamic>> _userChats(String uid) =>
      _firestore.collection('userChats').doc(uid).collection('chats');

  // ---------- Encrypted (Direct) ----------
  Future<MessageModel> sendEncryptedDirect({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    Map<String, dynamic>? media,
    String? senderName,
  }) async {
    final sender = await _users.getUserById(senderId);
    if (sender == null) throw Exception('Sender not found');

    // Use cached participants to prevent excessive calls
    final participants = await _getCachedParticipants(chatId, senderId);
    if (participants.length != 2) {
      throw Exception(
          'Direct chat must have exactly 2 participants, got ${participants.length}');
    }

    // Ensure chat exists
    final chatExists = await _chats.chatExists(chatId, senderId);
    if (!chatExists) throw Exception('Chat not found');

    final otherId =
        participants.firstWhere((p) => p != senderId, orElse: () => senderId);

    // Check if users can interact (not blocking each other)
    final canInteract = await _canUsersInteract(senderId, otherId);
    if (!canInteract) {
      throw Exception(
          'Cannot send encrypted message: user interaction blocked');
    }
    final otherPub = await _getCachedUserKey(otherId);
    if (otherPub == null) throw Exception('Missing other user public key');

    final secret = await _crypto.deriveDirectChatKey(
      otherPublicKeyBytes: base64Decode(otherPub),
      chatId: chatId,
    );

    final messageRef = _chatMessages(chatId).doc();
    final now = DateTime.now();

    final plaintext = <String, dynamic>{
      'content': content,
    };
    if (replyToMessageId != null) {
      final replySnap = await _chatMessages(chatId).doc(replyToMessageId).get();
      if (replySnap.exists) {
        plaintext['replyMeta'] = {'id': replyToMessageId};
      }
    }

    final encrypted =
        await _crypto.encryptPayload(key: secret, plaintext: plaintext);

    final batch = _firestore.batch();
    batch.set(messageRef, {
      'id': messageRef.id,
      'chatId': chatId,
      'senderId': senderId,
      'senderName':
          senderName ?? '${sender.firstName} ${sender.lastName}'.trim(),
      'senderProfileImage': sender.profileImageURL,
      'type': type.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'isDeleted': false,
      'isPinned': false,
      'isStarred': false,
      'isForwarded': false,
      'isSelfDestructing': false,
      'reactions': <String, dynamic>{},
      'readReceipts': <String, dynamic>{},
      'replyToMessageId': replyToMessageId,
      'media': media,
      ...encrypted, // Add encryption metadata (ciphertext, nonce, mac, alg, v)
    });
    // Update userChats for all participants (single collection architecture)
    for (final uid in participants) {
      final ref = _userChats(uid).doc(chatId);
      final update = <String, dynamic>{
        'lastActivity': FieldValue.serverTimestamp(),
        'encryptedLastMessage': encrypted,
      };
      if (uid != senderId) update['unreadCount'] = FieldValue.increment(1);
      batch.update(ref, update);
    }
    await batch.commit();

    return MessageModel(
      id: messageRef.id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName ?? '${sender.firstName} ${sender.lastName}'.trim(),
      senderProfileImage: sender.profileImageURL,
      content: content,
      type: type,
      timestamp: now,
      reactions: const {},
      readReceipts: const {},
    );
  }

  /// Send encrypted media message
  Future<MessageModel> sendEncryptedMedia({
    required String chatId,
    required String senderId,
    required File mediaFile,
    required MessageType mediaType,
    String? caption,
    String? replyToMessageId,
    String? senderName,
    Function(double)? onProgress,
  }) async {
    final participants = await _getCachedParticipants(chatId, senderId);

    // For direct chats, check if users can interact (not blocking each other)
    if (participants.length == 2) {
      final otherUserId = participants.firstWhere((id) => id != senderId);
      final canInteract = await _canUsersInteract(senderId, otherUserId);
      if (!canInteract) {
        throw Exception('Cannot send media: user interaction blocked');
      }
    }

    return await _mediaHandler.sendEncryptedMediaMessage(
      chatId: chatId,
      senderId: senderId,
      mediaFile: mediaFile,
      mediaType: mediaType,
      participants: participants,
      caption: caption,
      replyToMessageId: replyToMessageId,
      senderName: senderName,
      onUploadProgress: onProgress,
    );
  }

  /// Decrypt and download media
  Future<File?> getDecryptedMedia({
    required MessageModel message,
    required String currentUserId,
    Function(double)? onProgress,
  }) async {
    final participants =
        await _getCachedParticipants(message.chatId, currentUserId);

    final mediaInfo = await _mediaHandler.decryptMediaMessage(
      message: message,
      currentUserId: currentUserId,
      participants: participants,
    );

    if (mediaInfo != null) {
      return await _mediaHandler.downloadDecryptedMedia(
        mediaInfo: mediaInfo,
        onProgress: onProgress,
      );
    }

    return null;
  }

  // ---------- Unified (Public) API moved from ChatRepository ----------
  // These methods retain their original names/signatures for backwards compatibility.

  /// Stream of messages for a chat (unified hierarchical structure).
  /// Filters out messages from blocked users for security
  Stream<List<MessageModel>> getChatMessages(
    String chatId, {
    int limit = _fetchLimit,
    DocumentSnapshot? lastDocument,
    String? currentUserId,
  }) async* {
    // All messages now use hierarchical structure chatMessages/{chatId}/messages
    // The difference is whether they're encrypted or plaintext within that structure
    await for (final messages
        in _unifiedMessagesStream(chatId, limit: limit, last: lastDocument)) {
      // Filter out messages from blocked users if currentUserId is provided
      if (currentUserId != null) {
        final filteredMessages = <MessageModel>[];
        for (final message in messages) {
          // Skip messages from users who are blocked by current user
          // or who have blocked the current user
          if (message.senderId != currentUserId) {
            final canInteract =
                await _canUsersInteract(currentUserId, message.senderId);
            if (!canInteract) {
              continue; // Skip this message - user is blocked
            }
          }
          filteredMessages.add(message);
        }
        yield filteredMessages;
      } else {
        yield messages; // No filtering if no current user
      }
    }
  }

  /// Unified stream that handles both encrypted and plaintext messages from hierarchical structure
  Stream<List<MessageModel>> _unifiedMessagesStream(
    String chatId, {
    int limit = _fetchLimit,
    DocumentSnapshot? last,
  }) {
    Query<Map<String, dynamic>> q = _chatMessages(chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (last != null) q = q.startAfterDocument(last);

    return q.snapshots().asyncMap((snap) async {
      final List<MessageModel> messages = [];
      _v('📥 Processing ${snap.docs.length} message documents from Firestore');
      for (final doc in snap.docs) {
        try {
          final data = doc.data();
          _v('📄 Message ${doc.id}: keys=${data.keys.toList()}');

          // Check if message is encrypted (has ciphertext field)
          if (data.containsKey('ciphertext')) {
            _v('🔐 Processing encrypted message: ${doc.id}');
            // Encrypted message - try to decrypt it
            final decrypted = await _decodeEncrypted(chatId, doc.id, data);
            messages.add(decrypted);
          } else {
            _v('📝 Processing plaintext message: ${doc.id}');
            // Plaintext message - convert directly
            messages.add(_fromHierarchicalDoc(doc));
          }
        } catch (e) {
          debugPrint('Failed to process message ${doc.id}: $e');
          // Skip messages that can't be processed
          continue;
        }
      }
      _v('Processed ${messages.length} messages successfully');

      return messages;
    });
  }

  /// Convert hierarchical plaintext document to MessageModel
  MessageModel _fromHierarchicalDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    _v('🔍 Parsing message ${doc.id} with data: ${data.keys.toList()}');
    _v('📝 Content field: "${data['content']}" (type: ${data['content'].runtimeType})');
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] as String? ?? '', // Handle null chatId
      senderId: data['senderId'] as String? ?? '', // Handle null senderId
      senderName: data['senderName'] as String?,
      senderProfileImage: data['senderProfileImage'] as String?,
      content: data['content'] as String? ?? '', // Handle null content
      type: _parseMessageType(data['type'] as String?),
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      editedAt: (data['editedAt'] as Timestamp?)?.toDate(),
      mediaUrl: data['mediaUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      fileName: data['fileName'] as String?,
      fileSize: data['fileSize'] as int?,
      replyToMessageId: data['replyToMessageId'] as String?,
      forwardedFromUserId: data['forwardedFromUserId'] as String?,
      forwardedFromChatId: data['forwardedFromChatId'] as String?,
      readReceipts: (data['readReceipts'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, (v as Timestamp).toDate())),
      reactions: Map<String, String>.from(data['reactions'] ?? {}),
      isEdited: data['isEdited'] as bool? ?? false,
      isDeleted: data['isDeleted'] as bool? ?? false,
      isPinned: data['isPinned'] as bool? ?? false,
      isStarred: data['isStarred'] as bool? ?? false,
      isForwarded: data['isForwarded'] as bool? ?? false,
      isSelfDestructing: data['isSelfDestructing'] as bool? ?? false,
      selfDestructTime: (data['selfDestructTime'] as Timestamp?)?.toDate(),
      quotedMessageId: data['quotedMessageId'] as String?,
      quotedMessageContent: data['quotedMessageContent'] as String?,
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      locationName: data['locationName'] as String?,
      contactName: data['contactName'] as String?,
      contactPhone: data['contactPhone'] as String?,
      contactEmail: data['contactEmail'] as String?,
    );
  }

  /// Parse message type from string
  MessageType _parseMessageType(String? raw) {
    if (raw == null) return MessageType.text;
    return MessageType.values.firstWhere(
      (type) => type.toString().split('.').last == raw,
      orElse: () => MessageType.text,
    );
  }

  /// One-shot page fetch (older messages) for infinite scroll pagination.
  /// Returns messages in descending order (newest first) to match Firestore query style.
  Future<List<MessageModel>> fetchMessagePage({
    required String chatId,
    DocumentSnapshot? lastDocument,
    int limit = _fetchLimit,
  }) async {
    // Use unified hierarchical structure for all messages
    Query<Map<String, dynamic>> q = _chatMessages(chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (lastDocument != null) q = q.startAfterDocument(lastDocument);

    final snap = await q.get();
    final List<MessageModel> messages = [];

    for (final doc in snap.docs) {
      try {
        final data = doc.data();

        // Check if message is encrypted (has ciphertext field)
        if (data.containsKey('ciphertext')) {
          // Encrypted message - try to decrypt it
          final decrypted = await _decodeEncrypted(chatId, doc.id, data);
          messages.add(decrypted);
        } else {
          // Plaintext message - convert directly
          messages.add(_fromHierarchicalDoc(doc));
        }
      } catch (e) {
        // Skip messages that can't be processed
        continue;
      }
    }

    return messages;
  }

  /// Stream a single message by ID from hierarchical collection.
  Stream<MessageModel?> getMessageById(String chatId, String messageId) {
    return _chatMessages(chatId)
        .doc(messageId)
        .snapshots()
        .asyncMap((snap) async {
      if (!snap.exists) return null;

      try {
        final data = snap.data()!;

        // Check if message is encrypted (has ciphertext field)
        if (data.containsKey('ciphertext')) {
          // Encrypted message - try to decrypt it
          return await _decodeEncrypted(chatId, messageId, data);
        } else {
          // Plaintext message - convert directly
          return _fromHierarchicalDoc(
              snap as QueryDocumentSnapshot<Map<String, dynamic>>);
        }
      } catch (e) {
        return null;
      }
    });
  }

  /// Backwards-compatible sendMessage that auto-selects encryption for direct chats.
  /// Uses fallback strategy: plaintext until both users have keys, then encrypted.
  /// Updated for single collection architecture.
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    Map<String, dynamic>? mediaData,
    String? senderName,
  }) async {
    // Get cached participants to prevent excessive calls
    final participants = await _getCachedParticipants(chatId, senderId);

    if (participants.isEmpty) {
      throw Exception('Chat not found or no participants');
    }

    // Check if chat exists
    final chatExists = await _chats.chatExists(chatId, senderId);
    if (!chatExists) {
      throw Exception('Chat not found');
    }

    final isDirect = participants.length == 2;

    // For direct chats, check if users can interact (not blocking each other)
    if (isDirect) {
      final otherUserId = participants.firstWhere((id) => id != senderId);
      final canInteract = await _canUsersInteract(senderId, otherUserId);
      if (!canInteract) {
        throw Exception('Cannot send message: user interaction blocked');
      }
    }
    _v('📱 Chat type: ${isDirect ? 'Direct' : 'Group'}, participants: $participants');

    if (isDirect) {
      // Check if both users have identity keys for E2EE (cached)
      _v('🔐 Checking E2EE capability for direct chat...');
      final hasEncryption = await _getCachedEncryptionCapability(participants);
      _v('🔐 E2EE capability result: $hasEncryption');
      if (hasEncryption) {
        try {
          _v('Using encrypted messaging path');
          return await sendEncryptedDirect(
            chatId: chatId,
            senderId: senderId,
            content: content,
            type: type,
            replyToMessageId: replyToMessageId,
            media: mediaData,
            senderName: senderName,
          );
        } catch (e) {
          debugPrint(
              'Encrypted send failed ($e) – falling back to plaintext once');
        }
      } else {
        debugPrint('Falling back to plaintext messaging - missing keys');
      }
    }

    // Use plaintext for group chats or when encryption not available
    return sendPlaintext(
      chatId: chatId,
      senderId: senderId,
      content: content,
      type: type,
    );
  }

  /// Mark messages as read (legacy + userChats metadata). Encrypted read receipts TBD.
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    // Reset unread count
    await _userChats(userId).doc(chatId).update({
      'unreadCount': 0,
      'lastReadTimestamp': FieldValue.serverTimestamp(),
    });

    // For legacy flat messages, emulate prior behavior updating read receipts (best-effort).
    // Get participant count from cached data
    final participants = await _getCachedParticipants(chatId, userId);
    final participantCount = participants.length;

    if (participantCount < 50) {
      final unread = await _legacyMessages
          .where('chatId', isEqualTo: chatId)
          .where('senderId', isNotEqualTo: userId)
          .where('readReceipts.$userId', isNull: true)
          .limit(100)
          .get();
      if (unread.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final d in unread.docs) {
          batch.update(d.reference, {
            'readReceipts.$userId': FieldValue.serverTimestamp(),
          });
        }
        await batch.commit();
      }
    }
  }

  /// Backwards-compatible reaction toggle for legacy messages.
  Future<void> toggleMessageReaction({
    required String messageId,
    required String userId,
    required String emoji,
  }) async =>
      toggleReaction(messageId: messageId, userId: userId, emoji: emoji);

  /// Backwards-compatible edit for legacy messages.
  Future<void> editMessage({
    required String messageId,
    required String newContent,
    required String userId,
  }) async =>
      editPlaintext(
          messageId: messageId, userId: userId, newContent: newContent);

  Future<void> softDeleteMessage(
      String chatId, String messageId, String currentUserId) async {
    try {
      final messageRef = _firestore
          .collection('chatMessages')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      // First verify the message exists and user owns it
      final messageDoc = await messageRef.get();
      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final messageData = messageDoc.data()!;
      if (messageData['senderId'] != currentUserId) {
        throw Exception('You can only delete your own messages');
      }

      // Perform soft delete
      await messageRef.update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': currentUserId,
      });

      debugPrint('Message soft deleted successfully');
    } catch (e) {
      debugPrint('Error soft deleting message: $e');
      rethrow;
    }
  }

  /// Delete a message with user validation.
  Future<bool> deleteMessageWithValidation({
    required String chatId,
    required String messageId,
    required String userId,
  }) async {
    try {
      final messageRef = _firestore
          .collection('chatMessages')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);

      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        debugPrint('Message not found');
        return false;
      }

      final messageData = messageDoc.data()!;
      final senderId = messageData['senderId'] as String?;

      if (senderId != userId) {
        debugPrint('User $userId cannot delete message from $senderId');
        return false;
      }

      await messageRef.update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });

      debugPrint('Message deleted successfully by $userId');
      return true;
    } catch (e) {
      debugPrint('Error deleting message: $e');
      return false;
    }
  }

  /// Backwards-compatible search (legacy only for now).
  Future<List<MessageModel>> searchMessages({
    required String chatId,
    required String query,
    int limit = 20,
  }) =>
      searchPlaintext(chatId: chatId, query: query, limit: limit);

  Stream<List<MessageModel>> encryptedMessagesStream(
    String chatId, {
    int limit = _fetchLimit,
    DocumentSnapshot? last,
  }) {
    Query<Map<String, dynamic>> q = _chatMessages(chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (last != null) q = q.startAfterDocument(last);
    return q.snapshots().asyncMap((snap) async {
      return Future.wait(
          snap.docs.map((d) => _decodeEncrypted(chatId, d.id, d.data())));
    });
  }

  Future<MessageModel?> getEncryptedMessage(String chatId, String id) async {
    final doc = await _chatMessages(chatId).doc(id).get();
    if (!doc.exists) return null;
    return _decodeEncrypted(chatId, doc.id, doc.data()!);
  }

  Future<MessageModel> _decodeEncrypted(
      String chatId, String id, Map<String, dynamic> data) async {
    final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();

    // If no ciphertext, this shouldn't have been called - return plaintext message
    if (data['ciphertext'] == null) {
      debugPrint('_decodeEncrypted called for plaintext message: $id');
      final legacyTypeStr = data['type'] as String?;
      final legacyType = legacyTypeStr == null
          ? MessageType.text
          : MessageType.values.firstWhere(
              (e) => e.toString().split('.').last == legacyTypeStr,
              orElse: () => MessageType.text,
            );
      return MessageModel(
        id: id,
        chatId: chatId,
        senderId: data['senderId'] as String? ?? '',
        senderName: data['senderName'] as String?,
        senderProfileImage: data['senderProfileImage'] as String?,
        content: data['content'] as String?,
        type: legacyType,
        timestamp: ts,
        reactions: const {},
        readReceipts: const {},
      );
    }

    // Check if chat exists and is direct using cached participants
    final participants =
        await _getCachedParticipants(chatId, data['senderId'] as String? ?? '');
    if (participants.isEmpty) return _empty(chatId, id, data, ts);

    // Only decrypt direct chats (2 participants)
    if (participants.length != 2) return _empty(chatId, id, data, ts);

    // Optimization: Determine the single peer (other participant) and try once.
    // Only fallback to sender key if MAC/auth failure occurs. This removes the
    // always-two-attempts pattern from before.
    final senderId = data['senderId'] as String?;
    final otherId = participants.firstWhere(
      (p) => p != senderId,
      orElse: () => senderId ?? participants.first,
    );

    Map<String, dynamic>? decrypted;
    String? usedPeer;

    Future<SecretKey?> _getOrDeriveKey(String peerId) async {
      final cacheKey = '$chatId:$peerId';
      final cached = _directChatKeyCache[cacheKey];
      if (cached != null) return cached;
      final pub = await _getCachedUserKey(peerId);
      if (pub == null) return null;
      final key = await _crypto.deriveDirectChatKey(
        otherPublicKeyBytes: base64Decode(pub),
        chatId: chatId,
      );
      _directChatKeyCache[cacheKey] = key;
      // Lightweight TTL eviction
      Future.delayed(const Duration(minutes: 10), () {
        _directChatKeyCache.remove(cacheKey);
      });
      return key;
    }

    Future<Map<String, dynamic>?> _attempt(String peerId) async {
      try {
        debugPrint('🔐 Attempting decrypt for message $id using peer $peerId');
        final key = await _getOrDeriveKey(peerId);
        if (key == null) {
          debugPrint('No public key for peer $peerId');
          return null;
        }
        final d = await _crypto.decryptPayload(key: key, encrypted: data);
        if (d['content'] != null) {
          debugPrint('Decryption succeeded for message $id with peer $peerId');
          return d;
        }
        debugPrint('Decryption produced no content for $id with $peerId');
        return null;
      } catch (e) {
        debugPrint('Decryption failed for message $id with peer $peerId: $e');
        return null;
      }
    }

    // First attempt with other participant (normal case on receiver side).
    decrypted = await _attempt(otherId);
    usedPeer = otherId;

    // Fallback: if failed and senderId differs, try senderId once.
    if (decrypted == null && senderId != null && senderId != otherId) {
      decrypted = await _attempt(senderId);
      if (decrypted != null) usedPeer = senderId;
    }

    if (decrypted == null) {
      debugPrint(
          '🚫 Decryption failed for $id (attempted ${senderId == otherId ? 1 : 2} peer(s))');
      return _empty(chatId, id, data, ts, placeholder: '[Encrypted message]');
    }

    if (kDebugMode) {
      debugPrint('🔓 Decrypted message $id using peer $usedPeer');
    }

    // Get type from plaintext metadata (not encrypted)
    final typeStr = data['type'] as String?;
    final msgType = typeStr == null
        ? MessageType.text
        : MessageType.values.firstWhere(
            (e) => e.toString().split('.').last == typeStr,
            orElse: () => MessageType.text,
          );
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
      // Prefer plaintext metadata; fallback to decrypted (older messages encrypted full payload)
      senderName: (data['senderName'] as String?) ??
          (decrypted['senderName'] as String?),
      senderProfileImage: (data['senderProfileImage'] as String?) ??
          (decrypted['senderProfileImage'] as String?),
      // If this is an encrypted media payload, decrypted['media'] will exist.
      // We still set `content` to the (possibly empty) caption so text bubbles aren't shown when caption empty.
      content: (decrypted['media'] != null)
          ? (decrypted['media']['caption'] as String?)
          : decrypted['content'] as String?,
      type: msgType,
      timestamp: ts,
      // Populate media related fields (these are needed by UI to know it's a media message BEFORE on-demand decryption).
      // We intentionally expose the encrypted download_url so the on-demand decrypt flow can fetch it.
      mediaUrl: decrypted['media'] != null
          ? decrypted['media']['download_url'] as String?
          : (data['mediaUrl'] as String?),
      fileName: decrypted['media'] != null
          ? (decrypted['media']['metadata']?['originalName'] as String?)
          : data['fileName'] as String?,
      fileSize: decrypted['media'] != null
          ? (decrypted['media']['metadata']?['size'] as int?)
          : data['fileSize'] as int?,
      reactions: const {},
      readReceipts: const {},
    );
  }

  MessageModel _empty(
      String chatId, String id, Map<String, dynamic> data, DateTime ts,
      {String? placeholder}) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
      content: placeholder,
      timestamp: ts,
      reactions: const {},
      readReceipts: const {},
    );
  }

  // ---------- Legacy Plaintext Support ----------
  Stream<List<MessageModel>> legacyMessagesStream(String chatId,
      {int limit = _fetchLimit, DocumentSnapshot? last}) {
    Query<Map<String, dynamic>> q = _legacyMessages
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (last != null) q = q.startAfterDocument(last);
    return q
        .snapshots()
        .map((snap) => snap.docs.map((d) => _fromLegacyDoc(d)).toList());
  }

  MessageModel _fromLegacyDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    return MessageModel.fromJson({
      'id': doc.id,
      ...data,
      'timestamp':
          (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      'editedAt': (data['editedAt'] as Timestamp?)?.toDate().toIso8601String(),
      'selfDestructTime':
          (data['selfDestructTime'] as Timestamp?)?.toDate().toIso8601String(),
      'reactions': (data['reactions'] as Map<String, dynamic>? ?? {})
          .map((k, v) => MapEntry(k, v.toString())),
      'readReceipts': (data['readReceipts'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => v is Timestamp
              ? MapEntry(k, v.toDate().toIso8601String())
              : MapEntry(k, v.toString())),
    });
  }

  Future<MessageModel> sendPlaintext({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
  }) async {
    final sender = await _users.getUserById(senderId);
    if (sender == null) throw Exception('Sender not found');

    // Use hierarchical structure instead of flat messages
    final messageRef = _chatMessages(chatId).doc();
    final now = DateTime.now();

    final data = {
      'id': messageRef.id,
      'chatId': chatId, // FIXED: Add chatId field for _fromHierarchicalDoc
      'senderId': senderId,
      'senderName': '${sender.firstName} ${sender.lastName}'.trim(),
      'senderProfileImage': sender.profileImageURL,
      'content': content,
      'type': type.toString().split('.').last,
      'timestamp': FieldValue.serverTimestamp(),
      'isEdited': false,
      'isDeleted': false,
      'isPinned': false,
      'isStarred': false,
      'isForwarded': false,
      'isSelfDestructing': false,
      'reactions': <String, dynamic>{},
      'readReceipts': <String, dynamic>{},
    };

    // Get cached participants to prevent excessive calls
    final participants = await _getCachedParticipants(chatId, senderId);
    if (participants.isEmpty) {
      throw Exception('Chat not found or no participants');
    }

    final batch = _firestore.batch();
    batch.set(messageRef, data);

    // Update userChats for all participants (single collection architecture)
    for (final pid in participants) {
      final uc = _userChats(pid).doc(chatId);
      final upd = <String, dynamic>{
        'lastActivity': FieldValue.serverTimestamp(),
        'lastMessage': {
          'text': content,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
          'type': type.toString().split('.').last,
        },
      };
      if (pid != senderId) upd['unreadCount'] = FieldValue.increment(1);
      batch.update(uc, upd);
    }
    await batch.commit();

    return MessageModel(
      id: messageRef.id,
      chatId: chatId,
      senderId: senderId,
      senderName: '${sender.firstName} ${sender.lastName}'.trim(),
      senderProfileImage: sender.profileImageURL,
      content: content,
      type: type,
      timestamp: now,
    );
  }

  Future<void> toggleReaction(
      {required String messageId,
      required String userId,
      required String emoji}) async {
    final ref = _legacyMessages.doc(messageId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('Message not found');
    final data = snap.data()!;
    final reactions = Map<String, dynamic>.from(data['reactions'] ?? {});
    if (reactions[userId] == emoji) {
      reactions.remove(userId);
    } else {
      reactions[userId] = emoji;
    }
    await ref.update({'reactions': reactions});
  }

  Future<void> editPlaintext(
      {required String messageId,
      required String userId,
      required String newContent}) async {
    final ref = _legacyMessages.doc(messageId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('Message not found');
    if (snap.data()!['senderId'] != userId) {
      throw Exception('Only sender can edit');
    }
    await ref.update({
      'content': newContent,
      'isEdited': true,
      'editedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deletePlaintext(
      {required String messageId, required String userId}) async {
    final ref = _legacyMessages.doc(messageId);
    final snap = await ref.get();
    if (!snap.exists) throw Exception('Message not found');
    if (snap.data()!['senderId'] != userId) {
      throw Exception('Only sender can delete');
    }
    await ref.update({'isDeleted': true, 'content': null});
  }

  Future<void> markRead(String chatId, String userId) async {
    await _userChats(userId).doc(chatId).update({
      'unreadCount': 0,
      'lastReadTimestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<MessageModel>> searchPlaintext(
      {required String chatId, required String query, int limit = 20}) async {
    final snap = await _legacyMessages
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(1000)
        .get();
    final lower = query.toLowerCase();
    final results = <MessageModel>[];
    for (final d in snap.docs) {
      final content = d.data()['content']?.toString().toLowerCase() ?? '';
      if (content.contains(lower)) {
        results.add(_fromLegacyDoc(d));
        if (results.length >= limit) break;
      }
    }
    return results;
  }

  /// Get total message count for a chat (for delta sync)
  Future<int> getMessageCount(String chatId) async {
    try {
      final snapshot = await _chatMessages(chatId).count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Failed to get message count: $e');
      return 0;
    }
  }

  /// Fetch all messages for a chat (fallback when cache is inconsistent)
  /// Filters out messages from blocked users for security
  Future<List<MessageModel>> fetchAllMessages(String chatId,
      {String? currentUserId}) async {
    try {
      final snapshot = await _chatMessages(chatId)
          .orderBy('timestamp', descending: false)
          .get();

      final messages = <MessageModel>[];
      int encryptedCount = 0;
      int plaintextCount = 0;
      int decryptSuccess = 0;
      int decryptFailed = 0;
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          debugPrint(
              '📄 [fetchAll] Message ${doc.id} keys=${data.keys.toList()}');
          if (data.containsKey('ciphertext')) {
            // Decrypt encrypted message
            encryptedCount++;
            final decrypted = await _decodeEncrypted(chatId, doc.id, data);
            if (decrypted.content != null && decrypted.content!.isNotEmpty) {
              decryptSuccess++;
            } else {
              decryptFailed++;
            }
            messages.add(decrypted);
          } else {
            plaintextCount++;
            messages.add(_fromHierarchicalDoc(doc));
          }
        } catch (e) {
          debugPrint('Failed to parse message ${doc.id}: $e');
        }
      }
      debugPrint(
          '📊 fetchAllMessages summary for chat $chatId: total=${messages.length}, encrypted=$encryptedCount (ok=$decryptSuccess, failedOrEmpty=$decryptFailed), plaintext=$plaintextCount');

      // Filter out messages from blocked users if currentUserId is provided
      if (currentUserId != null) {
        final filteredMessages = <MessageModel>[];
        for (final message in messages) {
          // Skip messages from users who are blocked by current user
          // or who have blocked the current user
          if (message.senderId != currentUserId) {
            final canInteract =
                await _canUsersInteract(currentUserId, message.senderId);
            if (!canInteract) {
              continue; // Skip this message - user is blocked
            }
          }
          filteredMessages.add(message);
        }
        debugPrint(
            '🔒 Filtered ${messages.length - filteredMessages.length} messages from blocked users (fetchAll)');
        return filteredMessages;
      }

      return messages;
    } catch (e) {
      debugPrint('Failed to fetch all messages: $e');
      return [];
    }
  }

  /// Fetch latest messages after a certain timestamp (for delta sync)
  /// Filters out messages from blocked users for security
  Future<List<MessageModel>> fetchLatestMessages(
    String chatId, {
    required int limit,
    DateTime? afterTimestamp,
    String? currentUserId,
  }) async {
    try {
      Query<Map<String, dynamic>> query =
          _chatMessages(chatId).orderBy('timestamp', descending: false);

      if (afterTimestamp != null) {
        query = query.where('timestamp',
            isGreaterThan: Timestamp.fromDate(afterTimestamp));
      }

      final snapshot = await query.limit(limit).get();

      final messages = <MessageModel>[];
      int encryptedCount = 0;
      int plaintextCount = 0;
      int decryptSuccess = 0;
      int decryptFailed = 0;
      // Separate encrypted vs plaintext first for potential batch decrypt.
      final encryptedDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        debugPrint(
            '📄 [fetchLatest] Message ${doc.id} keys=${data.keys.toList()}');
        if (data.containsKey('ciphertext')) {
          encryptedDocs.add(doc);
        } else {
          try {
            plaintextCount++;
            messages.add(_fromHierarchicalDoc(doc));
          } catch (e) {
            debugPrint('Failed to parse plaintext message ${doc.id}: $e');
          }
        }
      }

      // Attempt batch decrypt for direct chat encrypted messages.
      if (encryptedDocs.isNotEmpty) {
        debugPrint(
            '🧵 Batch decrypting ${encryptedDocs.length} messages off main thread');
        // Determine participants (use first senderId available).
        final firstSender =
            encryptedDocs.first.data()['senderId'] as String? ?? '';
        List<String> participants = [];
        try {
          participants = await _getCachedParticipants(chatId, firstSender);
        } catch (_) {}

        // Only batch decrypt for direct chats (2 participants).
        if (participants.length == 2) {
          final senderId = firstSender;
          final otherId = participants.firstWhere(
            (p) => p != senderId,
            orElse: () => senderId,
          );
          // Derive (or reuse cached) key once for chosen peer.
          final otherPub = await _getCachedUserKey(otherId);
          SecretKey? secret;
          if (otherPub != null) {
            final cacheKey = '$chatId:$otherId';
            secret = _directChatKeyCache[cacheKey];
            if (secret == null) {
              secret = await _crypto.deriveDirectChatKey(
                otherPublicKeyBytes: base64Decode(otherPub),
                chatId: chatId,
              );
              _directChatKeyCache[cacheKey] = secret;
              Future.delayed(const Duration(minutes: 10),
                  () => _directChatKeyCache.remove(cacheKey));
            }
          }

          if (secret != null) {
            final keyBytes = await secret.extractBytes();
            // Launch compute jobs.
            final futures = <Future<Map<String, dynamic>?>>[];
            for (final doc in encryptedDocs) {
              futures.add(compute(_decryptPayloadIsolate, {
                'key': keyBytes,
                'ciphertext': doc.data()['ciphertext'],
                'nonce': doc.data()['nonce'],
                'mac': doc.data()['mac'],
              }));
            }
            final results = await Future.wait(futures);
            for (var i = 0; i < encryptedDocs.length; i++) {
              final doc = encryptedDocs[i];
              final data = doc.data();
              encryptedCount++;
              final res = results[i];
              if (res != null && res['content'] != null) {
                decryptSuccess++;
                // Build MessageModel (type is outside encryption)
                final typeStr = data['type'] as String?;
                final msgType = typeStr == null
                    ? MessageType.text
                    : MessageType.values.firstWhere(
                        (e) => e.toString().split('.').last == typeStr,
                        orElse: () => MessageType.text,
                      );
                messages.add(MessageModel(
                  id: doc.id,
                  chatId: chatId,
                  senderId: data['senderId'] as String? ?? '',
                  senderName: data['senderName'] as String?,
                  senderProfileImage: data['senderProfileImage'] as String?,
                  content: res['content'] as String?,
                  type: msgType,
                  timestamp: (data['timestamp'] as Timestamp?)?.toDate() ??
                      DateTime.now(),
                  reactions: const {},
                  readReceipts: const {},
                ));
              } else {
                // Fallback to existing per-message decrypt (may try alternate peer or yield placeholder)
                try {
                  final fallback = await _decodeEncrypted(chatId, doc.id, data);
                  if (fallback.content != null &&
                      fallback.content!.isNotEmpty) {
                    decryptSuccess++;
                  } else {
                    decryptFailed++;
                  }
                  messages.add(fallback);
                } catch (e) {
                  decryptFailed++;
                  debugPrint('Fallback decrypt failed for ${doc.id}: $e');
                  messages.add(_empty(
                      chatId,
                      doc.id,
                      data,
                      (data['timestamp'] as Timestamp?)?.toDate() ??
                          DateTime.now(),
                      placeholder: '[Encrypted message]'));
                }
              }
            }
          } else {
            // No key -> fallback sequential decrypt (will log issues)
            for (final doc in encryptedDocs) {
              try {
                encryptedCount++;
                final decrypted =
                    await _decodeEncrypted(chatId, doc.id, doc.data());
                if (decrypted.content != null &&
                    decrypted.content!.isNotEmpty) {
                  decryptSuccess++;
                } else {
                  decryptFailed++;
                }
                messages.add(decrypted);
              } catch (e) {
                decryptFailed++;
                debugPrint('Failed to decrypt (no key path) ${doc.id}: $e');
              }
            }
          }
        } else {
          // Not a direct chat -> fallback sequential decrypt
          for (final doc in encryptedDocs) {
            try {
              encryptedCount++;
              final decrypted =
                  await _decodeEncrypted(chatId, doc.id, doc.data());
              if (decrypted.content != null && decrypted.content!.isNotEmpty) {
                decryptSuccess++;
              } else {
                decryptFailed++;
              }
              messages.add(decrypted);
            } catch (e) {
              decryptFailed++;
              debugPrint('Failed to decrypt group/unknown ${doc.id}: $e');
            }
          }
        }
      }
      debugPrint(
          '📊 fetchLatestMessages summary for chat $chatId: total=${messages.length}, encrypted=$encryptedCount (ok=$decryptSuccess, failedOrEmpty=$decryptFailed), plaintext=$plaintextCount, after=${afterTimestamp?.toIso8601String()}');

      // Filter out messages from blocked users if currentUserId is provided
      if (currentUserId != null) {
        final filteredMessages = <MessageModel>[];
        for (final message in messages) {
          // Skip messages from users who are blocked by current user
          // or who have blocked the current user
          if (message.senderId != currentUserId) {
            final canInteract =
                await _canUsersInteract(currentUserId, message.senderId);
            if (!canInteract) {
              continue; // Skip this message - user is blocked
            }
          }
          filteredMessages.add(message);
        }
        debugPrint(
            '🔒 Filtered ${messages.length - filteredMessages.length} messages from blocked users');
        return filteredMessages;
      }

      return messages;
    } catch (e) {
      debugPrint('Failed to fetch latest messages: $e');
      return [];
    }
  }
}

/// Top-level isolate entry for decrypting a single payload with ChaCha20-Poly1305.
/// Expects map: { 'key': List< int >, 'ciphertext': String(base64), 'nonce': String(base64), 'mac': String(base64) }
Future<Map<String, dynamic>?> _decryptPayloadIsolate(
    Map<String, dynamic> args) async {
  try {
    final keyBytes = (args['key'] as List).cast<int>();
    final cipherTextB64 = args['ciphertext'] as String?;
    final nonceB64 = args['nonce'] as String?;
    final macB64 = args['mac'] as String?;
    if (cipherTextB64 == null || nonceB64 == null || macB64 == null) {
      return null;
    }
    final cipher = Chacha20.poly1305Aead();
    final secretKey = SecretKey(keyBytes);
    final clear = await cipher.decrypt(
      SecretBox(
        base64Decode(cipherTextB64),
        nonce: base64Decode(nonceB64),
        mac: Mac(base64Decode(macB64)),
      ),
      secretKey: secretKey,
    );
    final decoded = jsonDecode(utf8.decode(clear)) as Map<String, dynamic>;
    return decoded;
  } catch (_) {
    return null; // caller decides fallback
  }
}
