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

  // Collection references
  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> _userChats(String? userId) =>
      _firestore.collection('userChats').doc(userId).collection('chats');

  CollectionReference<Map<String, dynamic>> _chatMembers(String chatId) =>
      _firestore.collection('chatMembers').doc(chatId).collection('members');

  /// Create or get direct chat between two users
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

      // Check if chat exists
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (chatDoc.exists) {
        // Update user info if provided
        final updates = <String, dynamic>{};

        // Update info for current user's view
        if (otherUserName != null) {
          updates['otherUserName_$currentUserId'] = otherUserName;
        }
        if (otherUserUsername != null) {
          updates['otherUserUsername_$currentUserId'] = otherUserUsername;
        }
        if (otherUserProfileImage != null) {
          updates['otherUserProfileImage_$currentUserId'] =
              otherUserProfileImage;
        }
        if (otherUserAltProfileImage != null) {
          updates['otherUserAltProfileImage_$currentUserId'] =
              otherUserAltProfileImage;
        }

        // Update info for other user's view
        if (currentUserName != null) {
          updates['otherUserName_$otherUserId'] = currentUserName;
        }
        if (currentUserProfileImage != null) {
          updates['otherUserProfileImage_$otherUserId'] =
              currentUserProfileImage;
        }
        if (currentUserAltProfileImage != null) {
          updates['otherUserAltProfileImage_$otherUserId'] =
              currentUserAltProfileImage;
        }

        if (updates.isNotEmpty) {
          updates['updatedAt'] = FieldValue.serverTimestamp();
          await chatDoc.reference.update(updates);
        }

        return _chatFromFirestore(chatDoc, currentUserId);
      }

      // Create new chat
      final chatData = {
        'participants': [currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'lastMessageTimestamp': null,
        'isAlt': isAlt,
        'isGroupChat': false,
        'isPinned': false,
        'isMuted': false,
        'isArchived': false,

        // Store user info for current user's view
        'otherUserId_$currentUserId': otherUserId,
        'otherUserName_$currentUserId': otherUserName,
        'otherUserUsername_$currentUserId': otherUserUsername,
        'otherUserProfileImage_$currentUserId': otherUserProfileImage,
        'otherUserAltProfileImage_$currentUserId': otherUserAltProfileImage,
        'unreadCount_$currentUserId': 0,

        // Store user info for other user's view
        'otherUserId_$otherUserId': currentUserId,
        'otherUserName_$otherUserId': currentUserName,
        'otherUserProfileImage_$otherUserId': currentUserProfileImage,
        'otherUserAltProfileImage_$otherUserId': currentUserAltProfileImage,
        'unreadCount_$otherUserId': 0,
      };

      await _firestore.collection('chats').doc(chatId).set(chatData);
      final newDoc = await _firestore.collection('chats').doc(chatId).get();

      return _chatFromFirestore(newDoc, currentUserId);
    } catch (e) {
      print('Error creating/getting direct chat: $e');
      return null;
    }
  }

  ChatModel? _chatFromFirestore(DocumentSnapshot doc, String currentUserId) {
    if (!doc.exists) return null;

    try {
      final data = doc.data() as Map<String, dynamic>;

      // Extract values safely with null checks
      final otherUserId = data['otherUserId_$currentUserId'];
      final otherUserName = data['otherUserName_$currentUserId'];
      final otherUserUsername = data['otherUserUsername_$currentUserId'];
      final otherUserProfileImage =
          data['otherUserProfileImage_$currentUserId'];
      final otherUserAltProfileImage =
          data['otherUserAltProfileImage_$currentUserId'];

      // Debug logging
      debugPrint('DEBUG: Chat data keys: ${data.keys.toList()}');
      debugPrint(
          'DEBUG: otherUserId value: $otherUserId (type: ${otherUserId.runtimeType})');
      debugPrint(
          'DEBUG: otherUserName value: $otherUserName (type: ${otherUserName.runtimeType})');

      // Ensure we're dealing with the correct types
      return ChatModel(
        id: doc.id,
        otherUserId: otherUserId is String ? otherUserId : null,
        otherUserName: otherUserName is String ? otherUserName : null,
        otherUserUsername:
            otherUserUsername is String ? otherUserUsername : null,
        otherUserProfileImage:
            otherUserProfileImage is String ? otherUserProfileImage : null,
        otherUserAltProfileImage: otherUserAltProfileImage is String
            ? otherUserAltProfileImage
            : null,
        otherUserIsAlt: (data['otherUserIsAlt_$currentUserId'] is bool)
            ? data['otherUserIsAlt_$currentUserId']
            : false,
        isAlt: (data['isAlt'] is bool) ? data['isAlt'] : false,
        lastMessage:
            (data['lastMessage'] is String) ? data['lastMessage'] : null,
        lastMessageTimestamp: (data['lastMessageTimestamp'] is Timestamp)
            ? (data['lastMessageTimestamp'] as Timestamp).toDate()
            : null,
        unreadCount: (data['unreadCount_$currentUserId'] is int)
            ? data['unreadCount_$currentUserId']
            : 0,
        isGroupChat:
            (data['isGroupChat'] is bool) ? data['isGroupChat'] : false,
        isMuted: (data['isMuted_$currentUserId'] is bool)
            ? data['isMuted_$currentUserId']
            : false,
        isArchived: (data['isArchived_$currentUserId'] is bool)
            ? data['isArchived_$currentUserId']
            : false,
        isPinned: (data['isPinned_$currentUserId'] is bool)
            ? data['isPinned_$currentUserId']
            : false,
        groupId: (data['groupId'] is String) ? data['groupId'] : null,
      );
    } catch (e, stackTrace) {
      debugPrint('Error in _chatFromFirestore: $e');
      debugPrint('StackTrace: $stackTrace');
      return null;
    }
  }

  /// Get user's chat list with pagination
  Stream<List<ChatModel>> getUserChats(String userId, {int limit = 20}) {
    return _userChats(userId)
        .orderBy('isPinned', descending: true)
        .orderBy('lastActivity', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        // Convert userChat data to ChatModel
        if (data['type'] == 'direct') {
          return ChatModel(
            id: data['chatId'] as String? ?? '',
            otherUserId: data['otherParticipantId'] as String?,
            otherUserName: data['otherParticipantName'] as String?,
            otherUserProfileImage: data['otherParticipantPhoto'] as String?,
            lastMessage: data['lastMessage']?['text'] as String?,
            lastMessageTimestamp:
                (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
            unreadCount: data['unreadCount'] as int? ?? 0,
            isGroupChat: false,
            isMuted: data['isMuted'] as bool? ?? false,
            isArchived: data['isArchived'] as bool? ?? false,
            isPinned: data['isPinned'] as bool? ?? false,
          );
        } else {
          // Group chat
          return ChatModel(
            id: data['chatId'] as String? ?? '',
            otherUserName: data['groupName'] as String?,
            otherUserProfileImage: data['groupPhoto'] as String?,
            lastMessage: data['lastMessage']?['text'] as String?,
            lastMessageTimestamp:
                (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
            unreadCount: data['unreadCount'] as int? ?? 0,
            isGroupChat: true,
            isMuted: data['isMuted'] as bool? ?? false,
            isArchived: data['isArchived'] as bool? ?? false,
            isPinned: data['isPinned'] as bool? ?? false,
            groupId: data['chatId'] as String?,
          );
        }
      }).toList();
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
      final chatRef = _chats.doc();
      final chatId = chatRef.id;
      final now = DateTime.now();

      // Include creator in members
      final allMembers = {...memberIds, creatorId}.toList();

      final batch = _firestore.batch();

      // Create main chat document
      batch.set(chatRef, {
        'id': chatId,
        'type': 'group',
        'name': groupName,
        'description': description,
        'photoUrl': photoUrl,
        'participants': allMembers,
        'participantCount': allMembers.length,
        'admins': [creatorId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'settings': {
          'isPublic': false,
          'allowInvites': true,
          'maxMembers': 256,
        },
      });

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
        lastMessageTimestamp: now,
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
      // Extract chat ID from bubble ID
      final chatId = bubbleId.replaceFirst('chat_', '');

      // Get user's chat data
      final userChatDoc = await _userChats(currentUserId).doc(chatId).get();

      if (!userChatDoc.exists) {
        return null;
      }

      final data = userChatDoc.data()!;

      if (data['type'] == 'direct') {
        return ChatModel(
          id: chatId,
          otherUserId: data['otherParticipantId'] as String?,
          otherUserName: data['otherParticipantName'] as String?,
          otherUserProfileImage: data['otherParticipantPhoto'] as String?,
          lastMessage: data['lastMessage']?['text'] as String?,
          lastMessageTimestamp:
              (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
          unreadCount: data['unreadCount'] as int? ?? 0,
          isGroupChat: false,
          isMuted: data['isMuted'] as bool? ?? false,
          isArchived: data['isArchived'] as bool? ?? false,
          isPinned: data['isPinned'] as bool? ?? false,
        );
      } else {
        // Group chat
        return ChatModel(
          id: chatId,
          otherUserName: data['groupName'] as String?,
          otherUserProfileImage: data['groupPhoto'] as String?,
          lastMessage: data['lastMessage']?['text'] as String?,
          lastMessageTimestamp:
              (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
          unreadCount: data['unreadCount'] as int? ?? 0,
          isGroupChat: true,
          isMuted: data['isMuted'] as bool? ?? false,
          isArchived: data['isArchived'] as bool? ?? false,
          isPinned: data['isPinned'] as bool? ?? false,
          groupId: chatId,
        );
      }
    } catch (e) {
      throw Exception('Failed to get chat by bubble ID: $e');
    }
  }
}
