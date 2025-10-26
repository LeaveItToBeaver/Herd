import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

final optimisticMessagesProvider = StateNotifierProvider.family<
    OptimisticMessagesNotifier,
    Map<String, MessageModel>,
    String>((ref, chatId) => OptimisticMessagesNotifier(chatId));

/// Manages optimistic messages for a specific chat
class OptimisticMessagesNotifier
    extends StateNotifier<Map<String, MessageModel>> {
  final String chatId;

  OptimisticMessagesNotifier(this.chatId) : super({});

  void addOptimisticMessage(MessageModel message) {
    final newState = Map<String, MessageModel>.from(state);
    newState[message.id] = message;
    state = newState;
    _vc('Added optimistic message: ${message.id}');
  }

  void updateMessageStatus(String messageId, MessageStatus status,
      {String? errorMessage}) {
    final message = state[messageId];
    if (message != null) {
      final updatedMessage = message.copyWith(status: status);
      final newState = Map<String, MessageModel>.from(state);
      newState[messageId] = updatedMessage;
      state = newState;
      _vc('Updated message $messageId status: ${status.displayText}');
      if (status == MessageStatus.delivered) {
        Future.delayed(const Duration(milliseconds: 800), () {
          removeOptimisticMessage(messageId);
        });
      }
    }
  }

  void removeOptimisticMessage(String messageId) {
    if (state.containsKey(messageId)) {
      final newState = Map<String, MessageModel>.from(state)..remove(messageId);
      state = newState;
      _vc('Removed optimistic message: $messageId');
    }
  }

  void clearAll() {
    state = {};
    _vc('Cleared all optimistic messages for chat: $chatId');
  }

  int get pendingCount =>
      state.values.where((msg) => msg.status.isPending).length;
  int get failedCount => state.values.where((msg) => msg.status.isError).length;
}
