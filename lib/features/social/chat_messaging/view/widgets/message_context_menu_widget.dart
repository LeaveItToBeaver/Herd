import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/message_interaction_provider.dart';

class MessageContextMenu extends ConsumerWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final VoidCallback onDismiss;
  final Function(String, String) onReply;

  const MessageContextMenu({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.onDismiss,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionNotifier =
        ref.read(messageInteractionProvider(message.chatId).notifier);

    final actions = MessageActionConfig.getAvailableActions(
      message: message,
      isCurrentUser: isCurrentUser,
      canDeleteOthersMessages: false,
    );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: ['👍', '❤️', '😂', '😮', '😢', '😡']
                  .map((emoji) => _QuickReactionButton(
                        emoji: emoji,
                        onTap: () async {
                          onDismiss();
                          final currentUser = ref.read(authProvider);
                          if (currentUser != null) {
                            final result =
                                await interactionNotifier.reactToMessage(
                              messageId: message.id,
                              userId: currentUser.uid,
                              emoji: emoji,
                            );
                            if (result != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result)),
                              );
                            }
                          }
                        },
                      ))
                  .toList(),
            ),
          ),
          Divider(
            height: 1,
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          ...actions.map((action) => _ActionButton(
                config: action,
                onTap: () async {
                  onDismiss();
                  await _handleAction(
                      context, ref, action, interactionNotifier);
                },
              )),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    WidgetRef ref,
    MessageActionConfig action,
    MessageInteractionNotifier interactionNotifier,
  ) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You must be logged in to perform this action')),
        );
      }
      return;
    }

    String? result;

    switch (action.action) {
      case MessageAction.copy:
        if (message.content != null) {
          result =
              await interactionNotifier.copyMessageContent(message.content!);
        } else {
          result = 'No content to copy';
        }
        break;

      case MessageAction.delete:
        if (context.mounted) {
          final confirmed = await _showDeleteConfirmation(context);
          if (confirmed) {
            // Close the context menu first
            onDismiss();

            // Perform deletion without passing ref
            try {
              await interactionNotifier.deleteMessage(
                  message.id, currentUser.uid);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Message deleted successfully')),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete message: $e'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              }
            }
            return; // Don't set result since we handle the snackbar above
          }
        }
        break;

      case MessageAction.reply:
        onReply(message.id, message.content ?? '');
        break;

      case MessageAction.react:
        break;

      case MessageAction.forward:
        result = 'Forward feature coming soon';
        break;

      case MessageAction.pin:
        result = 'Pin feature coming soon';
        break;

      case MessageAction.star:
        result = 'Star feature coming soon';
        break;
    }

    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result),
          backgroundColor: result.contains('Failed') || result.contains('Error')
              ? Theme.of(context).colorScheme.error
              : null,
        ),
      );
    }
  }

  Future<bool> _showDeleteConfirmation(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Message'),
            content: const Text(
                'Are you sure you want to delete this message? This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _QuickReactionButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onTap;

  const _QuickReactionButton({
    required this.emoji,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final MessageActionConfig config;
  final VoidCallback onTap;

  const _ActionButton({
    required this.config,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Text(
              config.icon,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 12),
            Text(
              config.label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: config.isDestructive
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

void showMessageContextMenu({
  required BuildContext context,
  required MessageModel message,
  required bool isCurrentUser,
  required Offset position,
  required Function(String, String) onReply,
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;
  bool isRemoved = false;

  void safeRemove() {
    if (!isRemoved) {
      isRemoved = true;
      overlayEntry.remove();
    }
  }

  overlayEntry = OverlayEntry(
    builder: (context) {
      final screenSize = MediaQuery.of(context).size;
      final menuWidth = 300.0;
      final menuHeight = 200.0;

      double left = position.dx - (menuWidth / 2);
      double top = position.dy - menuHeight - 20;

      if (left < 20) left = 20;
      if (left + menuWidth > screenSize.width - 20) {
        left = screenSize.width - menuWidth - 20;
      }
      if (top < 50) top = position.dy + 20;

      return Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: safeRemove,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),
            Positioned(
              left: left,
              top: top,
              width: menuWidth,
              child: MessageContextMenu(
                message: message,
                isCurrentUser: isCurrentUser,
                onDismiss: safeRemove,
                onReply: onReply,
              ),
            ),
          ],
        ),
      );
    },
  );

  overlay.insert(overlayEntry);
}
