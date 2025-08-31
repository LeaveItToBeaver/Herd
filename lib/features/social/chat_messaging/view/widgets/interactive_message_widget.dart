import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/message_interaction_provider.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/message_context_menu_widget.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/message_status_indicator_widget.dart';

/// Enhanced message widget that handles tap and long press interactions
class InteractiveMessageWidget extends ConsumerWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final String displayName;
  final String? profileImageUrl;
  final Function(String, String) onReply;

  const InteractiveMessageWidget({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.displayName,
    required this.profileImageUrl,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionState =
        ref.watch(messageInteractionProvider(message.chatId));
    final interactionNotifier =
        ref.read(messageInteractionProvider(message.chatId).notifier);

    // Status is hidden by default, shown when message ID is in the set
    final isStatusVisible =
        interactionState.hiddenStatusMessages.contains(message.id);

    // If message is deleted, show a deleted message placeholder
    if (message.isDeleted) {
      return _DeletedMessageWidget(
        isCurrentUser: isCurrentUser,
        timestamp: message.timestamp,
        deletedAt: message.deletedAt,
      );
    }

    return GestureDetector(
      onTap: () {
        // Toggle status visibility on tap
        interactionNotifier.toggleStatusVisibility(message.id);
      },
      onLongPress: () {
        // Get the tap position for context menu
        final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);

          showMessageContextMenu(
            context: context,
            message: message,
            isCurrentUser: isCurrentUser,
            position: Offset(
              position.dx + renderBox.size.width / 2,
              position.dy,
            ),
            onReply: onReply,
          );
        }
      },
      child: Container(
        padding: EdgeInsets.only(
          left: isCurrentUser ? 50.0 : 0.0,
          right: isCurrentUser ? 0.0 : 50.0,
        ),
        child: Row(
          mainAxisAlignment:
              isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Avatar for other users (left side) - Always visible
            if (!isCurrentUser) ...[
              _ProfileAvatar(
                profileImageUrl: profileImageUrl,
                isVisible: true, // Always visible
              ),
              const SizedBox(width: 8),
            ],

            // Message content
            Flexible(
              child: Column(
                crossAxisAlignment: isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  // Sender name - shown when status is visible
                  if (isStatusVisible)
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                      child: Text(
                        displayName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.7),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),

                  // Message bubble with enhanced styling
                  _MessageBubble(
                    message: message,
                    isCurrentUser: isCurrentUser,
                    isStatusHidden: !isStatusVisible,
                  ),

                  // Timestamp and status - shown when tapped
                  if (isStatusVisible)
                    _MessageStatusRow(
                      message: message,
                      isCurrentUser: isCurrentUser,
                    ),
                ],
              ),
            ),

            // Avatar for current user (right side) - Always visible
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              _ProfileAvatar(
                profileImageUrl: profileImageUrl,
                isVisible: true, // Always visible
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? profileImageUrl;
  final bool isVisible;

  const _ProfileAvatar({
    required this.profileImageUrl,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isVisible ? 1.0 : 0.0,
      child: CircleAvatar(
        radius: 16,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        backgroundImage:
            profileImageUrl != null ? NetworkImage(profileImageUrl!) : null,
        child: profileImageUrl == null
            ? Icon(
                Icons.person,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final bool isStatusHidden;

  const _MessageBubble({
    required this.message,
    required this.isCurrentUser,
    required this.isStatusHidden,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
          bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
        ),
        border: Border.all(
          color: isCurrentUser
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
              : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: isStatusHidden
              ? 2.0
              : 1.5, // Slightly thicker border when selected
        ),
        boxShadow: isStatusHidden
            ? [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reply indicator if this is a reply
          if (message.replyToMessageId != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (isCurrentUser
                        ? Theme.of(context).colorScheme.onPrimary
                        : Theme.of(context).colorScheme.primary)
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.reply,
                    size: 14,
                    color: isCurrentUser
                        ? Theme.of(context)
                            .colorScheme
                            .onPrimary
                            .withValues(alpha: 0.7)
                        : Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant
                            .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Replying to message',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isCurrentUser
                              ? Theme.of(context)
                                  .colorScheme
                                  .onPrimary
                                  .withValues(alpha: 0.7)
                              : Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant
                                  .withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                  ),
                ],
              ),
            ),

          // Message content
          Text(
            message.content ?? '',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isCurrentUser
                      ? Theme.of(context).colorScheme.onPrimary
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),

          // Reactions if any
          if (message.reactions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Wrap(
                spacing: 4,
                children: message.reactions.entries.map((entry) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: (isCurrentUser
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.primary)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(fontSize: 12),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _MessageStatusRow extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;

  const _MessageStatusRow({
    required this.message,
    required this.isCurrentUser,
  });

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${timestamp.day}/${timestamp.month}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: 1.0,
      child: Padding(
        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _formatMessageTime(message.timestamp),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
            ),

            // Status indicator for current user messages
            if (isCurrentUser) ...[
              const SizedBox(width: 4),
              MessageStatusIndicator(status: message.status),
            ],

            // Edited indicator
            if (message.isEdited) ...[
              const SizedBox(width: 4),
              Text(
                '(edited)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.5),
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DeletedMessageWidget extends StatelessWidget {
  final bool isCurrentUser;
  final DateTime timestamp;
  final DateTime? deletedAt;

  const _DeletedMessageWidget({
    required this.isCurrentUser,
    required this.timestamp,
    this.deletedAt,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: isCurrentUser ? 50.0 : 0.0,
        right: isCurrentUser ? 0.0 : 50.0,
      ),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                  bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                ),
                border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.delete_outline,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Message was deleted',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
