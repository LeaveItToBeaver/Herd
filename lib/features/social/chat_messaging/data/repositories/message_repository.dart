import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';

/// Handles all message CRUD, encryption, and search logic.
class MessageRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _users;
  final ChatCryptoService _crypto;
  final ChatRepository _chats;
  static const int _fetchLimit = 50;
  int get pageSize => _fetchLimit;

  // Cache to prevent excessive calls
  final Map<String, List<String>> _participantsCache = {};
  final Map<String, String?> _userKeysCache = {};
  final Map<String, bool> _encryptionCapabilityCache = {};

  MessageRepository(this._firestore, this._users, this._crypto, this._chats);

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
          debugPrint('✅ Derived participants from chatId: $participants');
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
      debugPrint('❌ Failed to get cached participants: $e');

      // Emergency fallback: derive from chatId for direct chats
      if (chatId.contains('_')) {
        final parts = chatId.split('_');
        if (parts.length == 2) {
          debugPrint('🔄 Using emergency fallback for chatId: $chatId');
          return [parts[0], parts[1]];
        }
      }

      return [userId]; // Return at least the current user
    }
  }

  Future<String?> _getCachedUserKey(String userId) async {
    if (_userKeysCache.containsKey(userId)) {
      return _userKeysCache[userId];
    }

    try {
      final keyDoc = await _firestore.collection('userKeys').doc(userId).get();
      final key = keyDoc.data()?['identityPub'] as String?;
      _userKeysCache[userId] = key;
      // Clear cache after 10 minutes
      Future.delayed(
          const Duration(minutes: 10), () => _userKeysCache.remove(userId));
      return key;
    } catch (e) {
      debugPrint('❌ Failed to get cached user key: $e');
      _userKeysCache[userId] = null;
      return null;
    }
  }

  Future<bool> _getCachedEncryptionCapability(List<String> participants) async {
    final key = participants.join('_');
    if (_encryptionCapabilityCache.containsKey(key)) {
      return _encryptionCapabilityCache[key]!;
    }

    try {
      for (final userId in participants) {
        final userKey = await _getCachedUserKey(userId);
        if (userKey == null) {
          _encryptionCapabilityCache[key] = false;
          Future.delayed(const Duration(minutes: 2),
              () => _encryptionCapabilityCache.remove(key));
          return false;
        }
      }
      _encryptionCapabilityCache[key] = true;
      Future.delayed(const Duration(minutes: 5),
          () => _encryptionCapabilityCache.remove(key));
      return true;
    } catch (e) {
      debugPrint('❌ Failed to check cached encryption capability: $e');
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
      'senderName':
          senderName ?? '${sender.firstName} ${sender.lastName}'.trim(),
      'senderProfileImage': sender.profileImageURL,
      'type': type.toString().split('.').last,
      'replyToMessageId': replyToMessageId,
      'media': media,
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
      'senderId': senderId,
      'timestamp': FieldValue.serverTimestamp(), // normalized field name
      ...encrypted,
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
      senderName: plaintext['senderName'],
      senderProfileImage: plaintext['senderProfileImage'],
      content: content,
      type: type,
      timestamp: now,
      reactions: const {},
      readReceipts: const {},
    );
  }

  // ---------- Unified (Public) API moved from ChatRepository ----------
  // These methods retain their original names/signatures for backwards compatibility.

  /// Stream of messages for a chat (unified hierarchical structure).
  Stream<List<MessageModel>> getChatMessages(
    String chatId, {
    int limit = _fetchLimit,
    DocumentSnapshot? lastDocument,
  }) async* {
    // All messages now use hierarchical structure chatMessages/{chatId}/messages
    // The difference is whether they're encrypted or plaintext within that structure
    yield* _unifiedMessagesStream(chatId, limit: limit, last: lastDocument);
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
    });
  }

  /// Convert hierarchical plaintext document to MessageModel
  MessageModel _fromHierarchicalDoc(
      QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
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

    if (isDirect) {
      // Check if both users have identity keys for E2EE (cached)
      final hasEncryption = await _getCachedEncryptionCapability(participants);
      if (hasEncryption) {
        // Both users have keys - use encrypted path
        return sendEncryptedDirect(
          chatId: chatId,
          senderId: senderId,
          content: content,
          type: type,
          replyToMessageId: replyToMessageId,
          media: mediaData,
          senderName: senderName,
        );
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

  /// Backwards-compatible delete for legacy messages.
  Future<void> softDeleteMessage(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chatMessages')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('✅ Message soft deleted successfully');
    } catch (e) {
      debugPrint('❌ Error soft deleting message: $e');
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
        debugPrint('❌ Message not found');
        return false;
      }

      final messageData = messageDoc.data()!;
      final senderId = messageData['senderId'] as String?;

      if (senderId != userId) {
        debugPrint('❌ User $userId cannot delete message from $senderId');
        return false;
      }

      await messageRef.update({
        'isDeleted': true,
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });

      debugPrint('✅ Message deleted successfully by $userId');
      return true;
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
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
      debugPrint('⚠️ _decodeEncrypted called for plaintext message: $id');
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

    Map<String, dynamic>? decrypted;
    for (final pid in participants) {
      try {
        final pub = await _getCachedUserKey(pid);
        if (pub == null) continue;
        final key = await _crypto.deriveDirectChatKey(
          otherPublicKeyBytes: base64Decode(pub),
          chatId: chatId,
        );
        final d = await _crypto.decryptPayload(key: key, encrypted: data);
        if (d['content'] != null || d['senderName'] != null) {
          decrypted = d;
          break;
        }
      } catch (_) {
        // continue
      }
    }
    if (decrypted == null) return _empty(chatId, id, data, ts);
    final typeStr = decrypted['type'] as String?;
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
      senderName: decrypted['senderName'] as String?,
      senderProfileImage: decrypted['senderProfileImage'] as String?,
      content: decrypted['content'] as String?,
      type: msgType,
      timestamp: ts,
      reactions: const {},
      readReceipts: const {},
    );
  }

  MessageModel _empty(
      String chatId, String id, Map<String, dynamic> data, DateTime ts) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: data['senderId'] as String? ?? '',
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
      debugPrint('❌ Failed to get message count: $e');
      return 0;
    }
  }

  /// Fetch all messages for a chat (fallback when cache is inconsistent)
  Future<List<MessageModel>> fetchAllMessages(String chatId) async {
    try {
      final snapshot = await _chatMessages(chatId)
          .orderBy('timestamp', descending: false)
          .get();

      final messages = <MessageModel>[];
      for (final doc in snapshot.docs) {
        try {
          messages.add(_fromHierarchicalDoc(doc));
        } catch (e) {
          debugPrint('❌ Failed to parse message ${doc.id}: $e');
        }
      }
      return messages;
    } catch (e) {
      debugPrint('❌ Failed to fetch all messages: $e');
      return [];
    }
  }

  /// Fetch latest messages after a certain timestamp (for delta sync)
  Future<List<MessageModel>> fetchLatestMessages(
    String chatId, {
    required int limit,
    DateTime? afterTimestamp,
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
      for (final doc in snapshot.docs) {
        try {
          messages.add(_fromHierarchicalDoc(doc));
        } catch (e) {
          debugPrint('❌ Failed to parse message ${doc.id}: $e');
        }
      }
      return messages;
    } catch (e) {
      debugPrint('❌ Failed to fetch latest messages: $e');
      return [];
    }
  }
}
