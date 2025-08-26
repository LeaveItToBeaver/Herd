import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

import 'chat_provider_test.mocks.dart';

@GenerateMocks([MessageRepository])
void main() {
  group('OptimisticMessagesNotifier', () {
    late OptimisticMessagesNotifier notifier;
    const chatId = 'test_chat_id';

    setUp(() {
      notifier = OptimisticMessagesNotifier(chatId);
    });

    test('should add optimistic message', () {
      final message = _createTestMessage();

      notifier.addOptimisticMessage(message);

      expect(notifier.state, containsPair(message.id, message));
    });

    test('should update message status', () {
      final message = _createTestMessage();
      notifier.addOptimisticMessage(message);

      notifier.updateMessageStatus(message.id, MessageStatus.delivered);

      final updatedMessage = notifier.state[message.id]!;
      expect(updatedMessage.status, MessageStatus.delivered);
    });

    test('should remove optimistic message', () {
      final message = _createTestMessage();
      notifier.addOptimisticMessage(message);

      notifier.removeOptimisticMessage(message.id);

      expect(notifier.state, isEmpty);
    });

    test('should clear all optimistic messages', () {
      final message1 = _createTestMessage(id: 'msg1');
      final message2 = _createTestMessage(id: 'msg2');
      
      notifier.addOptimisticMessage(message1);
      notifier.addOptimisticMessage(message2);

      notifier.clearAll();

      expect(notifier.state, isEmpty);
    });

    test('should count pending messages', () {
      final pendingMessage = _createTestMessage(id: 'pending', status: MessageStatus.sending);
      final deliveredMessage = _createTestMessage(id: 'delivered', status: MessageStatus.delivered);
      
      notifier.addOptimisticMessage(pendingMessage);
      notifier.addOptimisticMessage(deliveredMessage);

      expect(notifier.pendingCount, 1);
    });

    test('should count failed messages', () {
      final failedMessage = _createTestMessage(id: 'failed', status: MessageStatus.failed);
      final successMessage = _createTestMessage(id: 'success', status: MessageStatus.delivered);
      
      notifier.addOptimisticMessage(failedMessage);
      notifier.addOptimisticMessage(successMessage);

      expect(notifier.failedCount, 1);
    });

    test('should remove delivered message after delay', () async {
      final message = _createTestMessage();
      notifier.addOptimisticMessage(message);

      notifier.updateMessageStatus(message.id, MessageStatus.delivered);

      // Wait for the delayed removal (800ms + buffer)
      await Future.delayed(const Duration(milliseconds: 900));

      expect(notifier.state, isEmpty);
    });
  });

  group('MessageInputNotifier', () {
    late ProviderContainer container;
    late MockMessageRepository mockRepo;
    const chatId = 'test_chat_id';

    setUp(() {
      mockRepo = MockMessageRepository();
      container = ProviderContainer(
        overrides: [
          messageRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should update text input', () {
      final notifier = container.read(messageInputProvider(chatId).notifier);
      const testText = 'Hello, world!';

      notifier.updateText(testText);

      final state = container.read(messageInputProvider(chatId));
      expect(state.text, testText);
    });

    test('should set typing state', () {
      final notifier = container.read(messageInputProvider(chatId).notifier);

      notifier.setTyping(true);

      final state = container.read(messageInputProvider(chatId));
      expect(state.isTyping, true);
    });

    test('should set reply message ID', () {
      final notifier = container.read(messageInputProvider(chatId).notifier);
      const replyId = 'reply_message_id';

      notifier.setReplyTo(replyId);

      final state = container.read(messageInputProvider(chatId));
      expect(state.replyToMessageId, replyId);
    });

    test('should clear error', () {
      final notifier = container.read(messageInputProvider(chatId).notifier);
      
      // Simulate error state
      notifier.state = notifier.state.copyWith(error: 'Test error');

      notifier.clearError();

      final state = container.read(messageInputProvider(chatId));
      expect(state.error, isNull);
    });
  });

  group('MessagesNotifier', () {
    late ProviderContainer container;
    late MockMessageRepository mockRepo;
    const chatId = 'test_chat_id';

    setUp(() {
      mockRepo = MockMessageRepository();
      container = ProviderContainer(
        overrides: [
          messageRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should sort messages by timestamp', () {
      final notifier = MessagesNotifier(container.read, chatId);
      final oldMessage = _createTestMessage(
        id: 'old',
        timestamp: DateTime(2023, 1, 1),
      );
      final newMessage = _createTestMessage(
        id: 'new', 
        timestamp: DateTime(2023, 1, 2),
      );

      final sorted = notifier._sortMessages([newMessage, oldMessage]);

      expect(sorted.first.id, 'old');
      expect(sorted.last.id, 'new');
    });
  });
}

MessageModel _createTestMessage({
  String id = 'test_message_id',
  String chatId = 'test_chat_id',
  String senderId = 'test_sender_id',
  String content = 'Test message content',
  MessageStatus status = MessageStatus.sending,
  DateTime? timestamp,
}) {
  return MessageModel(
    id: id,
    chatId: chatId,
    senderId: senderId,
    senderName: 'Test User',
    content: content,
    type: MessageType.text,
    status: status,
    timestamp: timestamp ?? DateTime.now(),
    reactions: const {},
    readReceipts: const {},
  );
}

class MessageInputState {
  final String text;
  final bool isTyping;
  final bool isSending;
  final String? replyToMessageId;
  final String? error;

  const MessageInputState({
    this.text = '',
    this.isTyping = false,
    this.isSending = false,
    this.replyToMessageId,
    this.error,
  });

  MessageInputState copyWith({
    String? text,
    bool? isTyping,
    bool? isSending,
    String? replyToMessageId,
    String? error,
  }) {
    return MessageInputState(
      text: text ?? this.text,
      isTyping: isTyping ?? this.isTyping,
      isSending: isSending ?? this.isSending,
      replyToMessageId: replyToMessageId ?? this.replyToMessageId,
      error: error,
    );
  }
}