import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/interactive_message_widget.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';

void main() {
  group('InteractiveMessageWidget', () {
    testWidgets('shows deleted message placeholder for deleted messages',
        (WidgetTester tester) async {
      // Arrange
      final deletedMessage = MessageModel(
        id: 'test_id',
        chatId: 'test_chat',
        senderId: 'test_sender',
        content: 'This was deleted',
        type: MessageType.text,
        status: MessageStatus.delivered,
        timestamp: DateTime.now(),
        isDeleted: true,
        deletedAt: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractiveMessageWidget(
                message: deletedMessage,
                isCurrentUser: false,
                displayName: 'Test User',
                profileImageUrl: null,
                onReply: (messageId, content) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Message was deleted'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);

      // The original message content should not be visible
      expect(find.text('This was deleted'), findsNothing);
    });

    testWidgets('shows normal message for non-deleted messages',
        (WidgetTester tester) async {
      // Arrange
      final normalMessage = MessageModel(
        id: 'test_id',
        chatId: 'test_chat',
        senderId: 'test_sender',
        content: 'This is a normal message',
        type: MessageType.text,
        status: MessageStatus.delivered,
        timestamp: DateTime.now(),
        isDeleted: false,
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: InteractiveMessageWidget(
                message: normalMessage,
                isCurrentUser: false,
                displayName: 'Test User',
                profileImageUrl: null,
                onReply: (messageId, content) {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('This is a normal message'), findsOneWidget);
      expect(find.text('Message was deleted'), findsNothing);
      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });
  });
}
