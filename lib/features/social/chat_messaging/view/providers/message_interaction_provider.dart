import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/message_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';

enum MessageAction {
  copy,
  delete,
  reply,
  react,
  forward,
  pin,
  star,
}

class MessageActionConfig {
  final MessageAction action;
  final String label;
  final String icon;
  final bool isDestructive;

  const MessageActionConfig({
    required this.action,
    required this.label,
    required this.icon,
    this.isDestructive = false,
  });

  static const List<MessageActionConfig> defaultActions = [
    MessageActionConfig(
      action: MessageAction.reply,
      label: 'Reply',
      icon: '↩️',
    ),
    MessageActionConfig(
      action: MessageAction.copy,
      label: 'Copy',
      icon: '📋',
    ),
    MessageActionConfig(
      action: MessageAction.react,
      label: 'React',
      icon: '😀',
    ),
    MessageActionConfig(
      action: MessageAction.forward,
      label: 'Forward',
      icon: '➡️',
    ),
    MessageActionConfig(
      action: MessageAction.star,
      label: 'Star',
      icon: '⭐',
    ),
    MessageActionConfig(
      action: MessageAction.pin,
      label: 'Pin',
      icon: '📌',
    ),
    MessageActionConfig(
      action: MessageAction.delete,
      label: 'Delete',
      icon: '🗑️',
      isDestructive: true,
    ),
  ];

  static List<MessageActionConfig> getAvailableActions({
    required MessageModel message,
    required bool isCurrentUser,
    required bool canDeleteOthersMessages,
  }) {
    return defaultActions.where((action) {
      switch (action.action) {
        case MessageAction.delete:
          return isCurrentUser || canDeleteOthersMessages;
        case MessageAction.pin:
          return canDeleteOthersMessages;
        default:
          return true;
      }
    }).toList();
  }
}

class MessageInteractionState {
  final Set<String> hiddenStatusMessages;
  final String? selectedMessageId;

  const MessageInteractionState({
    this.hiddenStatusMessages = const {},
    this.selectedMessageId,
  });

  MessageInteractionState copyWith({
    Set<String>? hiddenStatusMessages,
    String? selectedMessageId,
  }) {
    return MessageInteractionState(
      hiddenStatusMessages: hiddenStatusMessages ?? this.hiddenStatusMessages,
      selectedMessageId: selectedMessageId ?? this.selectedMessageId,
    );
  }
}

class MessageInteractionNotifier
    extends StateNotifier<MessageInteractionState> {
  final String chatId;
  final MessageRepository _messageRepository;

  MessageInteractionNotifier(this.chatId, this._messageRepository)
      : super(const MessageInteractionState());

  void toggleStatusVisibility(String messageId) {
    final hiddenMessages = Set<String>.from(state.hiddenStatusMessages);

    if (hiddenMessages.contains(messageId)) {
      hiddenMessages.remove(messageId);
    } else {
      hiddenMessages.add(messageId);
    }

    state = state.copyWith(hiddenStatusMessages: hiddenMessages);
  }

  bool isStatusHidden(String messageId) {
    return !state.hiddenStatusMessages.contains(messageId);
  }

  Future<String?> copyMessageContent(String content) async {
    try {
      await Clipboard.setData(ClipboardData(text: content));
      return 'Message copied to clipboard';
    } catch (e) {
      return 'Failed to copy message';
    }
  }

  Future<String> deleteMessage(String messageId, String currentUserId) async {
    try {
      // Use soft delete instead of hard delete
      await _messageRepository.softDeleteMessage(
          chatId, messageId, currentUserId);

      return 'Message deleted successfully';
    } catch (e) {
      final errorMessage = e.toString().replaceFirst('Exception: ', '');
      return 'Failed to delete message: $errorMessage';
    }
  }

  Future<String?> reactToMessage({
    required String messageId,
    required String userId,
    required String emoji,
  }) async {
    try {
      await _messageRepository.toggleMessageReaction(
        messageId: messageId,
        userId: userId,
        emoji: emoji,
      );
      return null;
    } catch (e) {
      return 'Failed to add reaction';
    }
  }

  void clearHiddenStates() {
    state = state.copyWith(hiddenStatusMessages: {});
  }

  void replyToMessage(String messageId) {
    state = state.copyWith(selectedMessageId: messageId);
  }

  void clearSelection() {
    state = state.copyWith(selectedMessageId: null);
  }
}

final messageInteractionProvider = StateNotifierProvider.family<
    MessageInteractionNotifier, MessageInteractionState, String>(
  (ref, chatId) {
    final messageRepository = ref.watch(messageRepositoryProvider);
    return MessageInteractionNotifier(chatId, messageRepository);
  },
);
