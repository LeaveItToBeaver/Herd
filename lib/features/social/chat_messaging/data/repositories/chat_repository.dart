import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ChatRepository(FirebaseFirestore.instance, userRepo);
});

class ChatRepository {
  final FirebaseFirestore _firestore;
  final UserRepository _userRepository;

  // Batch size for operations
  static const int _batchSize = 500;
  static const int _messageFetchLimit = 50;

  ChatRepository(this._firestore, this._userRepository);

  // Collection references
  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');
  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('messages');

  CollectionReference<Map<String, dynamic>> _userChats(String? userId) =>
      _firestore.collection('userChats').doc(userId).collection('chats');

  CollectionReference<Map<String, dynamic>> _chatMembers(String chatId) =>
      _firestore.collection('chatMembers').doc(chatId).collection('members');

  /// Create or get direct chat between two users
  Future<ChatModel> getOrCreateDirectChat({
    required String currentUserId,
    required String otherUserId,
  }) async {
    try {
      // Generate consistent chat ID for direct chats
      final chatId = _generateDirectChatId(currentUserId, otherUserId);

      // Check if chat already exists
      final chatDoc = await _chats.doc(chatId).get();

      if (chatDoc.exists) {
        // Get the user's specific chat data
        final userChatDoc = await _userChats(currentUserId).doc(chatId).get();
        if (userChatDoc.exists) {
          return ChatModel.fromJson({
            'id': chatId,
            ...userChatDoc.data()!,
          });
        }
      }

      // Create new chat
      final otherUser = await _userRepository.getUserById(otherUserId);
      if (otherUser == null) {
        throw Exception('Other user not found');
      }

      final batch = _firestore.batch();
      final now = DateTime.now();

      // Create main chat document
      batch.set(_chats.doc(chatId), {
        'id': chatId,
        'type': 'direct',
        'participants': [currentUserId, otherUserId],
        'participantCount': 2,
        'lastActivity': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create user chat document for current user
      batch.set(_userChats(currentUserId).doc(chatId), {
        'chatId': chatId,
        'type': 'direct',
        'otherParticipantId': otherUserId,
        'otherParticipantName':
            '${otherUser.firstName} ${otherUser.lastName}'.trim(),
        'otherParticipantPhoto': otherUser.profileImageURL,
        'unreadCount': 0,
        'isPinned': false,
        'isMuted': false,
        'isArchived': false,
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // Create user chat document for other user
      final currentUser = await _userRepository.getUserById(currentUserId);
      batch.set(_userChats(otherUserId).doc(chatId), {
        'chatId': chatId,
        'type': 'direct',
        'otherParticipantId': currentUserId,
        'otherParticipantName':
            '${currentUser?.firstName} ${currentUser?.lastName}'.trim(),
        'otherParticipantPhoto': currentUser?.profileImageURL,
        'unreadCount': 0,
        'isPinned': false,
        'isMuted': false,
        'isArchived': false,
        'lastActivity': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Return the created chat
      return ChatModel(
        id: chatId,
        otherUserId: otherUserId,
        otherUserName: '${otherUser.firstName} ${otherUser.lastName}'.trim(),
        otherUserUsername: otherUser.username,
        otherUserProfileImage: otherUser.profileImageURL,
        lastMessageTimestamp: now,
        unreadCount: 0,
        isGroupChat: false,
      );
    } catch (e) {
      throw Exception('Failed to create chat: $e');
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
            id: data['chatId'],
            otherUserId: data['otherParticipantId'],
            otherUserName: data['otherParticipantName'],
            otherUserProfileImage: data['otherParticipantPhoto'],
            lastMessage: data['lastMessage']?['text'],
            lastMessageTimestamp:
                (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
            unreadCount: data['unreadCount'] ?? 0,
            isGroupChat: false,
            isMuted: data['isMuted'] ?? false,
            isArchived: data['isArchived'] ?? false,
            isPinned: data['isPinned'] ?? false,
          );
        } else {
          // Group chat
          return ChatModel(
            id: data['chatId'],
            otherUserName: data['groupName'],
            otherUserProfileImage: data['groupPhoto'],
            lastMessage: data['lastMessage']?['text'],
            lastMessageTimestamp:
                (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
            unreadCount: data['unreadCount'] ?? 0,
            isGroupChat: true,
            isMuted: data['isMuted'] ?? false,
            isArchived: data['isArchived'] ?? false,
            isPinned: data['isPinned'] ?? false,
            groupId: data['chatId'],
          );
        }
      }).toList();
    });
  }

  Stream<MessageModel?> getMessageById(String messageId) {
    return _messages.doc(messageId).snapshots().map((snapshot) {
      if (!snapshot.exists) {
        return null;
      }

      final data = snapshot.data()!;
      return MessageModel.fromJson({
        'id': snapshot.id,
        ...data,
        'timestamp':
            (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
      });
    });
  }

  /// Get messages for a chat with pagination
  Stream<List<MessageModel>> getChatMessages(
    String chatId, {
    int limit = _messageFetchLimit,
    DocumentSnapshot? lastDocument,
  }) {
    Query<Map<String, dynamic>> query = _messages
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return MessageModel.fromJson({
          'id': doc.id,
          ...data,
          'timestamp':
              (data['timestamp'] as Timestamp?)?.toDate().toIso8601String(),
        });
      }).toList();
    });
  }

  /// Send a message with optimistic UI updates
  Future<MessageModel> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    String? replyToMessageId,
    Map<String, dynamic>? mediaData,
    String? senderName,
  }) async {
    try {
      // Get sender info
      final sender = await _userRepository.getUserById(senderId);
      if (sender == null) throw Exception('Sender not found');

      // Create message document
      final messageRef = _messages.doc();
      final timestamp = DateTime.now();

      final messageData = {
        'id': messageRef.id,
        'chatId': chatId,
        'senderId': senderId,
        'senderName': '${sender.firstName} ${sender.lastName}'.trim(),
        'senderProfileImage': sender.profileImageURL,
        'content': content,
        'type': type.toString().split('.').last,
        'timestamp': FieldValue.serverTimestamp(),
        'isEdited': false,
        'isDeleted': false,
        'reactions': {},
      };

      if (replyToMessageId != null) {
        // Get reply message data
        final replyDoc = await _messages.doc(replyToMessageId).get();
        if (replyDoc.exists) {
          final replyData = replyDoc.data()!;
          messageData['replyTo'] = {
            'messageId': replyToMessageId,
            'text': replyData['content'],
            'senderId': replyData['senderId'],
            'senderName': replyData['senderName'],
          };
        }
      }

      if (mediaData != null) {
        messageData.addAll(mediaData);
      }

      // Use batch to update multiple documents atomically
      final batch = _firestore.batch();

      // Add message
      batch.set(messageRef, messageData);

      // Update chat's last message
      batch.update(_chats.doc(chatId), {
        'lastMessage': {
          'text': content,
          'senderId': senderId,
          'timestamp': FieldValue.serverTimestamp(),
          'type': type.toString().split('.').last,
        },
        'lastActivity': FieldValue.serverTimestamp(),
      });

      // Get chat participants to update their userChats
      final chatDoc = await _chats.doc(chatId).get();
      final participants =
          List<String>.from(chatDoc.data()?['participants'] ?? []);

      // Update each participant's userChat document
      for (final participantId in participants) {
        final userChatRef = _userChats(participantId).doc(chatId);

        final updateData = {
          'lastMessage': {
            'text': content,
            'senderId': senderId,
            'senderName': '${sender.firstName} ${sender.lastName}'.trim(),
            'timestamp': FieldValue.serverTimestamp(),
            'type': type.toString().split('.').last,
          },
          'lastActivity': FieldValue.serverTimestamp(),
        };

        // Increment unread count for other participants
        if (participantId != senderId) {
          updateData['unreadCount'] = FieldValue.increment(1);
        }

        batch.update(userChatRef, updateData);
      }

      await batch.commit();

      // Return the message model for optimistic UI
      return MessageModel(
        id: messageRef.id,
        chatId: chatId,
        senderId: senderId,
        senderName: '${sender.firstName} ${sender.lastName}'.trim(),
        senderProfileImage: sender.profileImageURL,
        content: content,
        type: type,
        timestamp: timestamp,
        replyToMessageId: replyToMessageId,
      );
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    try {
      // Reset unread count in user's chat
      await _userChats(userId).doc(chatId).update({
        'unreadCount': 0,
        'lastReadTimestamp': FieldValue.serverTimestamp(),
      });

      // For small groups (<50 members), update read receipts
      final chatDoc = await _chats.doc(chatId).get();
      final participantCount = chatDoc.data()?['participantCount'] ?? 2;

      if (participantCount < 50) {
        // Get unread messages and update read receipts
        final unreadMessages = await _messages
            .where('chatId', isEqualTo: chatId)
            .where('senderId', isNotEqualTo: userId)
            .where('readBy.$userId', isNull: true)
            .limit(100) // Process in batches
            .get();

        if (unreadMessages.docs.isNotEmpty) {
          final batch = _firestore.batch();

          for (final doc in unreadMessages.docs) {
            batch.update(doc.reference, {
              'readBy.$userId': FieldValue.serverTimestamp(),
            });
          }

          await batch.commit();
        }
      }
    } catch (e) {
      throw Exception('Failed to mark messages as read: $e');
    }
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

  /// Search messages within a chat
  Future<List<MessageModel>> searchMessages({
    required String chatId,
    required String query,
    int limit = 20,
  }) async {
    try {
      // For now, we'll do client-side filtering
      // In production, consider using Algolia or ElasticSearch
      final allMessages = await _messages
          .where('chatId', isEqualTo: chatId)
          .orderBy('timestamp', descending: true)
          .limit(1000) // Reasonable limit for client-side search
          .get();

      final searchResults = allMessages.docs
          .where((doc) {
            final content =
                doc.data()['content']?.toString().toLowerCase() ?? '';
            return content.contains(query.toLowerCase());
          })
          .take(limit)
          .map((doc) => MessageModel.fromJson({
                'id': doc.id,
                ...doc.data(),
                'timestamp': (doc.data()['timestamp'] as Timestamp?)
                    ?.toDate()
                    .toIso8601String(),
              }))
          .toList();

      return searchResults;
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Helper to generate consistent chat ID for direct chats
  String _generateDirectChatId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
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
          otherUserId: data['otherParticipantId'],
          otherUserName: data['otherParticipantName'],
          otherUserProfileImage: data['otherParticipantPhoto'],
          lastMessage: data['lastMessage']?['text'],
          lastMessageTimestamp:
              (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
          unreadCount: data['unreadCount'] ?? 0,
          isGroupChat: false,
          isMuted: data['isMuted'] ?? false,
          isArchived: data['isArchived'] ?? false,
          isPinned: data['isPinned'] ?? false,
        );
      } else {
        // Group chat
        return ChatModel(
          id: chatId,
          otherUserName: data['groupName'],
          otherUserProfileImage: data['groupPhoto'],
          lastMessage: data['lastMessage']?['text'],
          lastMessageTimestamp:
              (data['lastMessage']?['timestamp'] as Timestamp?)?.toDate(),
          unreadCount: data['unreadCount'] ?? 0,
          isGroupChat: true,
          isMuted: data['isMuted'] ?? false,
          isArchived: data['isArchived'] ?? false,
          isPinned: data['isPinned'] ?? false,
          groupId: chatId,
        );
      }
    } catch (e) {
      throw Exception('Failed to get chat by bubble ID: $e');
    }
  }
}
