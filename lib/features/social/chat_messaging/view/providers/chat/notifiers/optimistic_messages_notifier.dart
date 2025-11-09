import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';

part 'optimistic_messages_notifier.g.dart';

// Verbose logging toggle for optimistic messages (non-error informational logs)
const bool _verboseOptimisticMessages = false;
void _vc(String msg) {
  if (_verboseOptimisticMessages && kDebugMode) debugPrint(msg);
}

/// Manages optimistic messages for a specific chat
@riverpod
class OptimisticMessages extends _$OptimisticMessages {
  late String _chatId;

  @override
  Map<String, MessageModel> build(String chatId) {
    _chatId = chatId;
    return {};
  }

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
