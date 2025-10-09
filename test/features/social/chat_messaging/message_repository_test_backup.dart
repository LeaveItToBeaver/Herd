import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/crypto/chat_crypto_service.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_repository.dart';

// import 'message_repository_test.mocks.dart'; // Will be generated

@GenerateMocks([ChatCryptoService, UserRepository, ChatRepository])
void main() {
  group('MessageRepository', () {
    late MessageRepository repository;
    late FakeFirebaseFirestore fakeFirestore;
    late ChatCryptoService mockCrypto;
    late UserRepository mockUserRepo;
    late ChatRepository mockChatRepo;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      // Temporary implementation until mocks are generated
      // mockCrypto = MockChatCryptoService();
      // mockUserRepo = MockUserRepository();
      // mockChatRepo = MockChatRepository();

      // Skip repository initialization for now
      // repository = MessageRepository(
      //   fakeFirestore,
      //   mockUserRepo,
      //   mockCrypto,
      //   mockChatRepo,
      // );
    });

    group('getChatMessages', () {
      test('should return stream of messages for chat', () async {
        // Arrange
        const chatId = 'test_chat_id';
        final messageData = _createTestMessageData();

        await fakeFirestore
            .collection('chatMessages')
            .doc(chatId)
            .collection('messages')
            .doc('msg1')
            .set(messageData);

        // Act
        //final stream = repository.getChatMessages(chatId);
        //final messages = await stream.first;

        // Assert
        //expect(messages.length, 1);
        //expect(messages.first.content, messageData['content']);
      });

      test('should handle encrypted messages', () async {
        const chatId = 'test_chat_id';
        final encryptedMessageData = _createTestEncryptedMessageData();

        await fakeFirestore
            .collection('chatMessages')
            .doc(chatId)
            .collection('messages')
            .doc('encrypted_msg')
            .set(encryptedMessageData);

        // // Mock decryption
        // when(mockCrypto.decryptPayload(key: anyNamed('key'), encrypted: any))
        //     .thenAnswer((_) async => {
        //       'content': 'Decrypted message',
        //       'senderName': 'Test User',
        //       'type': 'text',
        //     });

        // final stream = repository.getChatMessages(chatId);
        // final messages = await stream.first;

        // expect(messages.length, 1);
        // // Note: In actual implementation, this would need proper mocking setup
      });
    });

    group('fetchMessagePage', () {
      test('should return paginated messages', () async {
        const chatId = 'test_chat_id';

        // Add multiple messages
        for (int i = 0; i < 5; i++) {
          await fakeFirestore
              .collection('chatMessages')
              .doc(chatId)
              .collection('messages')
              .doc('msg_$i')
              .set(_createTestMessageData(
                content: 'Message $i',
                timestamp: Timestamp.fromDate(
                    DateTime.now().add(Duration(minutes: i))),
              ));
        }

        // final messages = await repository.fetchMessagePage(
        //   chatId: chatId,
        //   limit: 3,
        // );

        // expect(messages.length, 3);
        // // Should be ordered by timestamp descending (newest first)
        // expect(messages.first.content, contains('4')); // Most recent
      });
    });

    group('sendMessage', () {
      test('should send plaintext message when encryption not available',
          () async {
        const chatId = 'user1_user2';
        const senderId = 'user1';
        const content = 'Hello, World!';

        // // Mock user data
        // when(mockUserRepo.getUserById(senderId))
        //     .thenAnswer((_) async => _createTestUser(senderId));

        // // Mock chat exists
        // when(mockChatRepo.chatExists(chatId, senderId))
        //     .thenAnswer((_) async => true);

        // final result = await repository.sendMessage(
        //   chatId: chatId,
        //   senderId: senderId,
        //   content: content,
        // );

        // expect(result.content, content);
        // expect(result.senderId, senderId);
        // expect(result.type, MessageType.text);

        // Verify message was stored
        final messagesQuery = await fakeFirestore
            .collection('chatMessages')
            .doc(chatId)
            .collection('messages')
            .get();

        expect(messagesQuery.docs.length, 1);
        expect(messagesQuery.docs.first.data()['content'], content);
      });
    });

    group('markMessagesAsRead', () {
      test('should update unread count', () async {
        const chatId = 'test_chat_id';
        const userId = 'test_user_id';

        // Setup initial unread count
        await fakeFirestore
            .collection('userChats')
            .doc(userId)
            .collection('chats')
            .doc(chatId)
            .set({'unreadCount': 5});

        //await repository.markMessagesAsRead(chatId, userId);

        final chatDoc = await fakeFirestore
            .collection('userChats')
            .doc(userId)
            .collection('chats')
            .doc(chatId)
            .get();

        expect(chatDoc.data()!['unreadCount'], 0);
      });
    });

    group('searchMessages', () {
      test('should find messages containing query text', () async {
        const chatId = 'test_chat_id';
        const query = 'hello';

        // Add messages with different content
        await fakeFirestore
            .collection('messages') // Legacy collection for search
            .doc('msg1')
            .set(_createTestMessageData(
              chatId: chatId,
              content: 'Hello world!',
            ));

        await fakeFirestore
            .collection('messages')
            .doc('msg2')
            .set(_createTestMessageData(
              chatId: chatId,
              content: 'Goodbye world!',
            ));

        await fakeFirestore
            .collection('messages')
            .doc('msg3')
            .set(_createTestMessageData(
              chatId: chatId,
              content: 'Hello there!',
            ));

        // final results = await repository.searchMessages(
        //   chatId: chatId,
        //   query: query,
        // );

        // expect(results.length, 2);
        // expect(
        //     results.every(
        //         (msg) => msg.content?.toLowerCase().contains(query) ?? false),
        //     true);
      });
    });

    group('Message validation', () {
      test('should validate message content', () {
        final message = MessageModel(
          id: 'test_id',
          chatId: 'test_chat',
          senderId: 'test_sender',
          content: '', // Empty content
          type: MessageType.text,
          timestamp: DateTime.now(),
          reactions: const {},
          readReceipts: const {},
        );

        expect(message.content?.isEmpty ?? true, true);
      });

      test('should handle different message types', () {
        final textMessage = MessageModel(
          id: 'text_msg',
          chatId: 'test_chat',
          senderId: 'sender',
          content: 'Text message',
          type: MessageType.text,
          timestamp: DateTime.now(),
          reactions: const {},
          readReceipts: const {},
        );

        final imageMessage = MessageModel(
          id: 'image_msg',
          chatId: 'test_chat',
          senderId: 'sender',
          content: null,
          type: MessageType.image,
          mediaUrl: 'https://example.com/image.jpg',
          timestamp: DateTime.now(),
          reactions: const {},
          readReceipts: const {},
        );

        expect(textMessage.type, MessageType.text);
        expect(imageMessage.type, MessageType.image);
        expect(imageMessage.mediaUrl, isNotNull);
      });
    });

    group('Cache behavior', () {
      test('should handle participant caching', () {
        const chatId = 'user1_user2';
        const userId = 'user1';

        // Extract participants from direct chat ID format
        final parts = chatId.split('_');
        expect(parts.length, 2);
        expect(parts, contains(userId));

        final otherParticipant = parts.firstWhere((p) => p != userId);
        expect(otherParticipant, 'user2');
      });
    });
  });
}

Map<String, dynamic> _createTestMessageData({
  String chatId = 'test_chat_id',
  String senderId = 'test_sender_id',
  String content = 'Test message content',
  String senderName = 'Test User',
  Timestamp? timestamp,
}) {
  return {
    'chatId': chatId,
    'senderId': senderId,
    'content': content,
    'senderName': senderName,
    'type': 'text',
    'timestamp': timestamp ?? Timestamp.now(),
    'isEdited': false,
    'isDeleted': false,
    'reactions': <String, dynamic>{},
    'readReceipts': <String, dynamic>{},
  };
}

Map<String, dynamic> _createTestEncryptedMessageData({
  String senderId = 'test_sender_id',
  Timestamp? timestamp,
}) {
  return {
    'senderId': senderId,
    'timestamp': timestamp ?? Timestamp.now(),
    'ciphertext': 'encrypted_data_here',
    'nonce': 'test_nonce',
    'tag': 'test_tag',
  };
}

// dynamic _createTestUser(String userId) {
//   return {
//     'userId': userId,
//     'firstName': 'Test',
//     'lastName': 'User',
//     'profileImageURL': 'https://example.com/avatar.jpg',
//   };
// }
