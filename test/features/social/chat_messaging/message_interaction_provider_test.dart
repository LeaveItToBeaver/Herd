import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';

class MockMessageRepository extends Mock implements MessageRepository {
  @override
  Future<void> softDeleteMessage(
          String chatId, String messageId, String currentUserId) =>
      super.noSuchMethod(
        Invocation.method(
            #softDeleteMessage, [chatId, messageId, currentUserId]),
        returnValue: Future<void>.value(),
      );
}

void main() {
  group('MessageInteractionNotifier', () {
    late MessageInteractionNotifier notifier;
    late MockMessageRepository mockRepository;

    setUp(() {
      mockRepository = MockMessageRepository();
      notifier = MessageInteractionNotifier('test_chat_id', mockRepository);
    });

    test('deleteMessage calls repository softDeleteMessage', () async {
      // Arrange
      const messageId = 'test_message_id';
      const currentUserId = 'test_user_id';

      when(mockRepository.softDeleteMessage(
              'test_chat_id', messageId, currentUserId))
          .thenAnswer((_) async {});

      // Act
      final result = await notifier.deleteMessage(messageId, currentUserId);

      // Assert
      expect(result, 'Message deleted successfully');
      verify(mockRepository.softDeleteMessage(
              'test_chat_id', messageId, currentUserId))
          .called(1);
    });

    test('deleteMessage handles errors', () async {
      // Arrange
      const messageId = 'test_message_id';
      const currentUserId = 'test_user_id';

      when(mockRepository.softDeleteMessage(
              'test_chat_id', messageId, currentUserId))
          .thenThrow(Exception('Permission denied'));

      // Act
      final result = await notifier.deleteMessage(messageId, currentUserId);

      // Assert
      expect(result, 'Failed to delete message: Permission denied');
    });

    test('toggleStatusVisibility updates state correctly', () {
      // Arrange
      const messageId = 'test_message_id';

      // Act - toggle on
      notifier.toggleStatusVisibility(messageId);

      // Assert
      expect(notifier.state.hiddenStatusMessages.contains(messageId), true);

      // Act - toggle off
      notifier.toggleStatusVisibility(messageId);

      // Assert
      expect(notifier.state.hiddenStatusMessages.contains(messageId), false);
    });
  });
}
