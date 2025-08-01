import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(FirebaseFirestore.instance);
});

class ChatRepository {
  final FirebaseFirestore _firestore;

  ChatRepository(this._firestore);

  // Collection references
  CollectionReference<Map<String, dynamic>> get _chats =>
      _firestore.collection('chats');

  CollectionReference<Map<String, dynamic>> get _messages =>
      _firestore.collection('messages');

  // Get or create a chat between two users
  Future<ChatModel> getOrCreateChat({
    required String currentUserId,
    required String otherUserId,
    String? otherUserName,
    String? otherUserUsername,
    String? otherUserProfileImage,
    String? otherUserAltProfileImage,
    bool otherUserIsAlt = false,
  }) async {
    // Generate consistent chat ID for 1-on-1 chats
    final chatId = _generateChatId(currentUserId, otherUserId);

    final chatDoc = await _chats.doc(chatId).get();

    if (chatDoc.exists) {
      return ChatModel.fromJson({
        'id': chatDoc.id,
        ...chatDoc.data()!,
      });
    }

    // Create new chat
    final newChat = ChatModel(
      id: chatId,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserUsername: otherUserUsername,
      otherUserProfileImage: otherUserProfileImage,
      otherUserAltProfileImage: otherUserAltProfileImage,
      otherUserIsAlt: otherUserIsAlt,
    );

    await _chats.doc(chatId).set(newChat.toJson());

    return newChat;
  }

  // Get chat by bubble ID (for demo purposes, we'll map bubble IDs to mock chats)
  Future<ChatModel?> getChatByBubbleId(String bubbleId) async {
    // For MVP, create mock chats based on bubble ID
    if (bubbleId.startsWith('chat_')) {
      final chatIndex = int.tryParse(bubbleId.replaceFirst('chat_', '')) ?? 0;
      return ChatModel(
        id: bubbleId,
        otherUserId: 'user_$chatIndex',
        otherUserName: 'User ${chatIndex + 1}',
        otherUserUsername: '@user${chatIndex + 1}',
        otherUserProfileImage: null,
        lastMessage: 'Hey there! 👋',
        lastMessageTimestamp:
            DateTime.now().subtract(Duration(hours: chatIndex)),
        unreadCount: chatIndex % 3,
      );
    } else if (bubbleId.startsWith('herd_')) {
      final herdIndex = int.tryParse(bubbleId.replaceFirst('herd_', '')) ?? 0;
      return ChatModel(
        id: bubbleId,
        otherUserId: 'herd_$herdIndex',
        otherUserName: 'Herd ${herdIndex + 1}',
        otherUserUsername: '@herd${herdIndex + 1}',
        otherUserProfileImage: null,
        lastMessage: 'Welcome to the herd! 🐄',
        lastMessageTimestamp:
            DateTime.now().subtract(Duration(days: herdIndex)),
        unreadCount: herdIndex % 2,
        isGroupChat: true,
      );
    }

    return null;
  }

  // Get messages for a chat
  Stream<List<MessageModel>> getMessages(String chatId) {
    return _messages
        .where('chatId', isEqualTo: chatId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MessageModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    });
  }

  // Send a message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
    String? senderName,
    String? senderProfileImage,
  }) async {
    final message = MessageModel(
      id: '', // Will be set by Firestore
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: content,
      timestamp: DateTime.now(),
    );

    // Add message to messages collection
    final docRef = await _messages.add(message.toJson());

    // Update chat's last message
    await _chats.doc(chatId).update({
      'lastMessage': content,
      'lastMessageTimestamp': FieldValue.serverTimestamp(),
    });
  }

  // Get mock messages for demo
  Stream<List<MessageModel>> getMockMessages(String chatId) async* {
    // Generate mock messages for demo
    final mockMessages = <MessageModel>[];

    final now = DateTime.now();

    if (chatId.startsWith('chat_')) {
      final chatIndex = int.tryParse(chatId.replaceFirst('chat_', '')) ?? 0;
      final otherUserId = 'user_$chatIndex';
      final currentUserId = 'current_user';

      mockMessages.addAll([
        MessageModel(
          id: '1',
          chatId: chatId,
          senderId: otherUserId,
          senderName: 'User ${chatIndex + 1}',
          content: 'Hey there! How are you doing? 👋',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
        MessageModel(
          id: '2',
          chatId: chatId,
          senderId: currentUserId,
          senderName: 'You',
          content: 'Hi! I\'m doing great, thanks for asking!',
          timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        ),
        MessageModel(
          id: '3',
          chatId: chatId,
          senderId: otherUserId,
          senderName: 'User ${chatIndex + 1}',
          content: 'That\'s awesome to hear! What have you been up to lately?',
          timestamp: now.subtract(const Duration(hours: 1)),
        ),
        MessageModel(
          id: '4',
          chatId: chatId,
          senderId: currentUserId,
          senderName: 'You',
          content:
              'Just working on some Flutter projects. Really enjoying the new features!',
          timestamp: now.subtract(const Duration(minutes: 30)),
        ),
        MessageModel(
          id: '5',
          chatId: chatId,
          senderId: otherUserId,
          senderName: 'User ${chatIndex + 1}',
          content:
              'Flutter is amazing! The hot reload feature is such a game changer 🚀',
          timestamp: now.subtract(const Duration(minutes: 15)),
        ),
      ]);
    } else if (chatId.startsWith('herd_')) {
      final herdIndex = int.tryParse(chatId.replaceFirst('herd_', '')) ?? 0;
      final currentUserId = 'current_user';

      mockMessages.addAll([
        MessageModel(
          id: '1',
          chatId: chatId,
          senderId: 'herd_member_1',
          senderName: 'Member 1',
          content: 'Welcome to Herd ${herdIndex + 1}! 🐄',
          timestamp: now.subtract(const Duration(days: 1)),
        ),
        MessageModel(
          id: '2',
          chatId: chatId,
          senderId: 'herd_member_2',
          senderName: 'Member 2',
          content: 'Great to have you here!',
          timestamp: now.subtract(const Duration(hours: 12)),
        ),
        MessageModel(
          id: '3',
          chatId: chatId,
          senderId: currentUserId,
          senderName: 'You',
          content: 'Thanks for the warm welcome!',
          timestamp: now.subtract(const Duration(hours: 6)),
        ),
        MessageModel(
          id: '4',
          chatId: chatId,
          senderId: 'herd_member_3',
          senderName: 'Member 3',
          content: 'Feel free to ask if you have any questions!',
          timestamp: now.subtract(const Duration(hours: 2)),
        ),
      ]);
    }

    yield mockMessages.reversed.toList(); // Reverse to show latest first
  }

  // Generate consistent chat ID for 1-on-1 chats
  String _generateChatId(String userId1, String userId2) {
    final users = [userId1, userId2]..sort();
    return '${users[0]}_${users[1]}';
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String chatId, String userId) async {
    final batch = _firestore.batch();

    final unreadMessages = await _messages
        .where('chatId', isEqualTo: chatId)
        .where('senderId', isNotEqualTo: userId)
        .where('readReceipts.$userId', isNull: true)
        .get();

    for (final doc in unreadMessages.docs) {
      batch.update(doc.reference, {
        'readReceipts.$userId': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();

    // Update chat unread count
    await _chats.doc(chatId).update({
      'unreadCount': 0,
    });
  }
}
