import 'package:flutter/material.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_type.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/draggable_bubble_widget.dart';

class MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;

  const MessageBubble({
    super.key,
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
    return Padding(
      padding: EdgeInsets.only(
        left: isCurrentUser ? 50.0 : 0.0,
        right: isCurrentUser ? 0.0 : 50.0,
      ),
      child: Row(
        mainAxisAlignment:
            isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for other users (left side)
          if (!isCurrentUser) ...[
            DraggableBubble(
              config: BubbleConfigState(
                id: 'avatar_${message.senderId}',
                type: BubbleType.custom,
                contentType: message.senderProfileImage != null
                    ? BubbleContentType.profileImage
                    : BubbleContentType.icon,
                icon: Icons.person,
                imageUrl: message.senderProfileImage,
                backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 32,
                padding: EdgeInsets.zero,
              ),
              globalKey: GlobalKey(),
              onDragStart: (_) {},
              onDragUpdate: (_) {},
              onDragEnd: () {},
              isBeingDragged: false,
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
                // Message bubble
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(isCurrentUser ? 20 : 4),
                      bottomRight: Radius.circular(isCurrentUser ? 4 : 20),
                    ),
                  ),
                  child: Text(
                    message.content ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isCurrentUser
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),

                // Timestamp
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                  child: Text(
                    _formatMessageTime(message.timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withOpacity(0.6),
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Avatar for current user (right side)
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            DraggableBubble(
              config: BubbleConfigState(
                id: 'avatar_current_user',
                type: BubbleType.custom,
                contentType: BubbleContentType
                    .icon, // TODO: Use current user's profile image
                icon: Icons.person,
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                size: 32,
                padding: EdgeInsets.zero,
              ),
              globalKey: GlobalKey(),
              onDragStart: (_) {},
              onDragUpdate: (_) {},
              onDragEnd: () {},
              isBeingDragged: false,
            ),
          ],
        ],
      ),
    );
  }
}
