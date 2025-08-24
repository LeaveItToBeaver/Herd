import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';

class ChatRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  // Batch size for operations
  static const int _batchSize = 500;

  ChatRepository(this._firestore, this._userRepository);

  // Note: Legacy chats collection removed - using single collection architecture

  CollectionReference<Map<String, dynamic>> _userChats(String? userId) =>
      _firestore.collection('userChats').doc(userId).collection('chats');

  CollectionReference<Map<String, dynamic>> _chatMembers(String chatId) =>
      _firestore.collection('chatMembers').doc(chatId).collection('members');

  /// Create or get direct chat between two users - Single collection architecture
  Future<ChatModel?> getOrCreateDirectChat({
    required String currentUserId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserUsername,
    String? otherUserProfileImage,
    String? otherUserAltProfileImage,
    bool isAlt = false,
    String? currentUserName,
    String? currentUserProfileImage,
    String? currentUserAltProfileImage,
  }) async {
    try {
      // Create a consistent chat ID based on user IDs (alphabetically sorted)
      final List<String> userIds = [currentUserId, otherUserId]..sort();
      final chatId = '${userIds[0]}_${userIds[1]}';

      debugPrint(
          '🔍 Creating/getting chat: $chatId between $currentUserId and $otherUserId');

      // Check if chat exists in current user's userChats collection
      final currentUserChatDoc =
          await _userChats(currentUserId).doc(chatId).get();

      if (currentUserChatDoc.exists) {
        debugPrint('✅ Chat exists, updating info if provided');

        // Chat exists - optionally update other user's info in current user's document
        final updates = <String, dynamic>{};

        if (otherUserName != null) {
          updates['otherParticipantName'] = otherUserName;
        }
        if (otherUserUsername != null) {
          updates['otherParticipantUsername'] = otherUserUsername;
        }
        if (otherUserProfileImage != null) {
          updates['otherParticipantPhoto'] = otherUserProfileImage;
        }
        if (otherUserAltProfileImage != null) {
          updates['otherParticipantAltPhoto'] = otherUserAltProfileImage;
        }

        if (updates.isNotEmpty) {
          updates['lastActivity'] = FieldValue.serverTimestamp();
          await currentUserChatDoc.reference.update(updates);
          debugPrint('📝 Updated current user chat info');
        }

        // Also update the other user's document if we have current user info
        if (currentUserName != null ||
            currentUserProfileImage != null ||
            currentUserAltProfileImage != null) {
          final otherUserUpdates = <String, dynamic>{};

          if (currentUserName != null) {
            otherUserUpdates['otherParticipantName'] = currentUserName;
          }
          if (currentUserProfileImage != null) {
            otherUserUpdates['otherParticipantPhoto'] = currentUserProfileImage;
          }
          if (currentUserAltProfileImage != null) {
            otherUserUpdates['otherParticipantAltPhoto'] =
                currentUserAltProfileImage;
          }

          if (otherUserUpdates.isNotEmpty) {
            otherUserUpdates['lastActivity'] = FieldValue.serverTimestamp();
            await _userChats(otherUserId).doc(chatId).update(otherUserUpdates);
            debugPrint('📝 Updated other user chat info');
          }
        }

        return getChatByBubbleId(chatId, currentUserId);
      }

      debugPrint('🆕 Creating new chat documents');

      // Create new chat using batch operation
      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      // Create user-specific chat document for current user
      batch.set(_userChats(currentUserId).doc(chatId), {
        'chatId': chatId,
        'type': 'direct',
        'otherParticipantId': otherUserId,
        'otherParticipantName': otherUserName,
        'otherParticipantUsername': otherUserUsername,
        'otherParticipantPhoto': otherUserProfileImage,
        'otherParticipantAltPhoto': otherUserAltProfileImage,
        'lastMessage': null,
        'lastMessageTimestamp': null,
        'unreadCount': 0,
        'isPinned': false,
        'isMuted': false,
        'isArchived': false,
        'isAlt': isAlt,
        'createdAt': now,
        'lastActivity': now,
      });

      // Create user-specific chat document for other user
      batch.set(_userChats(otherUserId).doc(chatId), {
        'chatId': chatId,
        'type': 'direct',
        'otherParticipantId': currentUserId,
        'otherParticipantName': currentUserName,
        'otherParticipantUsername':
            null, // We might not have current user's username
        'otherParticipantPhoto': currentUserProfileImage,
        'otherParticipantAltPhoto': currentUserAltProfileImage,
        'lastMessage': null,
        'lastMessageTimestamp': null,
        'unreadCount': 0,
        'isPinned': false,
        'isMuted': false,
        'isArchived': false,
        'isAlt': isAlt,
        'createdAt': now,
        'lastActivity': now,
      });

      await batch.commit();
      debugPrint('✅ Chat documents created successfully');

      return getChatByBubbleId(chatId, currentUserId);
    } catch (e) {
      debugPrint('❌ Error creating/getting direct chat: $e');
      return null;
    }
  }

  /// Get participants for a chat from user's perspective - Single collection architecture
  Future<List<String>> getChatParticipants(String chatId, String userId) async {
    try {
      debugPrint(
          '🔍 Getting participants for chat: $chatId from user: $userId');

      // For direct chats, we can derive participants from chatId directly
      if (chatId.contains('_')) {
        final parts = chatId.split('_');
        if (parts.length == 2) {
          final participants = [parts[0], parts[1]];
          debugPrint(
              '✅ Derived participants from chatId directly: $participants');
          return participants;
        }
      }

      // Fallback: get from user's own chat document (for group chats or when chatId doesn't follow pattern)
      final userChatDoc = await _userChats(userId).doc(chatId).get();

      if (!userChatDoc.exists) {
        debugPrint('❌ User chat document not found: $chatId for user: $userId');
        // Emergency fallback: try to derive from chatId
        if (chatId.contains('_')) {
          final parts = chatId.split('_');
          if (parts.length == 2) {
            debugPrint('🔄 Emergency fallback to chatId derivation');
            return [parts[0], parts[1]];
          }
        }
        return [userId]; // Return at least the current user
      }

      final data = userChatDoc.data()!;
      final chatType = data['type'] as String?;

      if (chatType == 'direct') {
        // Direct chat: participants are [userId, otherParticipantId]
        final otherParticipantId = data['otherParticipantId'] as String?;
        if (otherParticipantId == null) {
          debugPrint('❌ No otherParticipantId found in direct chat: $chatId');
          return [userId]; // Return at least the current user
        }

        final participants = [userId, otherParticipantId];
        debugPrint('✅ Direct chat participants: $participants');
        return participants;
      } else if (chatType == 'group') {
        // Group chat: participants are stored in the participants array
        final participants = List<String>.from(data['participants'] ?? []);
        debugPrint('✅ Group chat participants: $participants');
        return participants;
      } else {
        debugPrint('❌ Unknown chat type: $chatType for chat: $chatId');
        return [userId]; // Return at least the current user
      }
    } catch (e) {
      debugPrint('❌ Error getting chat participants: $e');

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

  /// Check if a chat exists from user's perspective
  Future<bool> chatExists(String chatId, String userId) async {
    try {
      final doc = await _userChats(userId).doc(chatId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('❌ Error checking if chat exists: $e');
      return false;
    }
  }

  /// Get user's chat list with pagination - Now much simpler with user-specific collections!
  Stream<List<ChatModel>> getUserChats(String userId, {int limit = 20}) {
    debugPrint('🔍 Getting chats for user: $userId');

    return _userChats(userId)
        .orderBy('isPinned', descending: true)
        .orderBy('lastActivity', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      debugPrint(
          '📱 Found ${snapshot.docs.length} chat documents for user: $userId');

      final chatModels = snapshot.docs.map((doc) {
        final data = doc.data();
        final chatId = doc.id; // Use document ID as chat ID

        debugPrint('📄 Processing chat document: $chatId');
        debugPrint('   - Other participant: ${data['otherParticipantId']}');
        debugPrint('   - Chat type: ${data['type']}');

        // Convert userChat data to ChatModel using consistent structure
        return ChatModel(
          id: chatId,
          otherUserId: data['otherParticipantId'] as String?,
          otherUserName: data['otherParticipantName'] as String?,
          otherUserUsername: data['otherParticipantUsername'] as String?,
          otherUserProfileImage: data['otherParticipantPhoto'] as String?,
          otherUserAltProfileImage: data['otherParticipantAltPhoto'] as String?,
          lastMessage: data['lastMessage']?['text'] as String?,
          lastMessageTimestamp:
              (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
          unreadCount: data['unreadCount'] as int? ?? 0,
          isGroupChat: data['type'] == 'group',
          isMuted: data['isMuted'] as bool? ?? false,
          isArchived: data['isArchived'] as bool? ?? false,
          isPinned: data['isPinned'] as bool? ?? false,
          isAlt: data['isAlt'] as bool? ?? false,
          groupId: data['type'] == 'group' ? chatId : null,
        );
      }).toList();

      debugPrint('✅ Returning ${chatModels.length} chat models');

      // Check for duplicate chat IDs at the source
      final chatIds = chatModels.map((c) => c.id).toList();
      final uniqueIds = chatIds.toSet();
      if (chatIds.length != uniqueIds.length) {
        debugPrint('⚠️ WARNING: Repository returning duplicate chat IDs!');
        debugPrint('All IDs: $chatIds');
        debugPrint('Unique IDs: $uniqueIds');
      }

      return chatModels;
    });
  }

  /// Create a group chat
  Future<ChatModel> createGroupChat({
    required String creatorId,
    required String groupName,
    required List<String> memberIds,
    String? description,
    String? photoUrl,
  }) async {
    try {
      // Generate unique group chat ID
      final chatId = _firestore.collection('groups').doc().id;

      // Include creator in members
      final allMembers = {...memberIds, creatorId}.toList();

      final batch = _firestore.batch();
      final now = FieldValue.serverTimestamp();

      // Create userChats document for each participant (single collection architecture)
      for (final memberId in allMembers) {
        final memberNames = <String, String>{};
        final memberPhotos = <String, String>{};

        // TODO: In a real implementation, you'd fetch member names and photos
        // For now, we'll create minimal group chat documents
        for (final otherId in allMembers) {
          if (otherId != memberId) {
            memberNames[otherId] = 'Member $otherId'; // Placeholder
            memberPhotos[otherId] = ''; // Placeholder
          }
        }

        batch.set(_userChats(memberId).doc(chatId), {
          'chatId': chatId,
          'type': 'group',
          'groupName': groupName,
          'groupPhoto': photoUrl,
          'description': description,
          'participants': allMembers,
          'participantNames': memberNames,
          'participantPhotos': memberPhotos,
          'admins': [creatorId],
          'isAdmin': memberId == creatorId,
          'lastMessage': null,
          'lastMessageTimestamp': null,
          'unreadCount': 0,
          'isPinned': false,
          'isMuted': false,
          'isArchived': false,
          'createdAt': now,
          'lastActivity': now,
          'settings': {
            'isPublic': false,
            'allowInvites': true,
            'maxMembers': 256,
          },
        });
      }

      // Create chat member documents
      for (final memberId in allMembers) {
        batch.set(_chatMembers(chatId).doc(memberId), {
          'userId': memberId,
          'role': memberId == creatorId ? 'admin' : 'member',
          'joinedAt': FieldValue.serverTimestamp(),
          'addedBy': creatorId,
          'permissions': {
            'canPost': true,
            'canInvite': memberId == creatorId,
            'canRemoveMembers': memberId == creatorId,
            'canEditInfo': memberId == creatorId,
          },
        });

        // Create userChat document for each member
        batch.set(_userChats(memberId).doc(chatId), {
          'chatId': chatId,
          'type': 'group',
          'groupName': groupName,
          'groupPhoto': photoUrl,
          'unreadCount': 0,
          'isPinned': false,
          'isMuted': false,
          'isArchived': false,
          'lastActivity': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      return ChatModel(
        id: chatId,
        otherUserName: groupName,
        otherUserProfileImage: photoUrl,
        lastMessageTimestamp: DateTime.now(),
        unreadCount: 0,
        isGroupChat: true,
        groupId: chatId,
      );
    } catch (e) {
      throw Exception('Failed to create group chat: $e');
    }
  }

  Future<ChatModel?> getChatByBubbleId(
      String bubbleId, String? currentUserId) async {
    try {
      if (currentUserId == null) {
        debugPrint('❌ Cannot get chat: currentUserId is null');
        return null;
      }

      // Extract chat ID from bubble ID (handle both formats)
      String chatId = bubbleId;
      if (bubbleId.startsWith('chat_')) {
        chatId = bubbleId.replaceFirst('chat_', '');
      }

      debugPrint('🔍 Looking for user chat: $chatId for user: $currentUserId');

      // Get user-specific chat document (new architecture)
      final userChatDoc = await _userChats(currentUserId).doc(chatId).get();

      if (!userChatDoc.exists) {
        debugPrint('❌ User chat document not found: $chatId');
        return null;
      }

      final data = userChatDoc.data()!;

      // Convert userChat data to ChatModel using the new structure
      final chatModel = ChatModel(
        id: chatId,
        otherUserId: data['otherParticipantId'] as String?,
        otherUserName: data['otherParticipantName'] as String?,
        otherUserUsername: data['otherParticipantUsername'] as String?,
        otherUserProfileImage: data['otherParticipantPhoto'] as String?,
        otherUserAltProfileImage: data['otherParticipantAltPhoto'] as String?,
        lastMessage: data['lastMessage']?['text'] as String?,
        lastMessageTimestamp:
            (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
        unreadCount: data['unreadCount'] as int? ?? 0,
        isGroupChat: data['type'] == 'group',
        isMuted: data['isMuted'] as bool? ?? false,
        isArchived: data['isArchived'] as bool? ?? false,
        isPinned: data['isPinned'] as bool? ?? false,
        isAlt: data['isAlt'] as bool? ?? false,
        groupId: data['type'] == 'group' ? chatId : null,
      );

      debugPrint('✅ User chat found and parsed successfully: ${chatModel.id}');
      return chatModel;
    } catch (e) {
      debugPrint('❌ Error in getChatByBubbleId: $e');
      throw Exception('Failed to get chat by bubble ID: $e');
    }
  }
}
