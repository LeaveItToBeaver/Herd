import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import '../state/message_interaction_state.dart';

part 'message_interaction_notifier.g.dart';

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

@riverpod
class MessageInteraction extends _$MessageInteraction {
  @override
  MessageInteractionState build(String chatId) {
    return const MessageInteractionState();
  }

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
      final messageRepository = ref.read(messageRepositoryProvider);
      // Use soft delete instead of hard delete
      // chatId is provided by the generated base class as a getter
      await messageRepository.softDeleteMessage(
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
      final messageRepository = ref.read(messageRepositoryProvider);
      await messageRepository.toggleMessageReaction(
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
