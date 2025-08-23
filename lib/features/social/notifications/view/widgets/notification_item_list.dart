import 'package:flutter/material.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cached_network_image/cached_network_image.dart';

class NotificationListItem extends StatelessWidget {
  final NotificationModel notification;
  final Function(NotificationModel) onTap;
  final Function(String) onMarkAsRead;

  const NotificationListItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => onTap(notification),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: notification.isRead
              ? null
              : theme.colorScheme.primary.withValues(alpha: 0.08),
          border: Border(
            bottom: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBody(theme),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.timestamp),
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              IconButton(
                icon: const Icon(Icons.done, size: 18),
                onPressed: () => onMarkAsRead(notification.id),
                tooltip: 'Mark as read',
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final profileUrl = notification.isAlt
        ? notification.senderAltProfileImage
        : notification.senderProfileImage;

    IconData iconData;
    Color iconColor;

    switch (notification.type) {
      case NotificationType.follow:
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case NotificationType.newPost:
        iconData = Icons.post_add;
        iconColor = Colors.green;
        break;
      case NotificationType.postLike:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case NotificationType.comment:
      case NotificationType.commentReply:
        iconData = Icons.comment;
        iconColor = Colors.purple;
        break;
      case NotificationType.connectionRequest:
        iconData = Icons.group_add;
        iconColor = Colors.orange;
        break;
      case NotificationType.connectionAccepted:
        iconData = Icons.group;
        iconColor = Colors.teal;
        break;
      case NotificationType.postMilestone:
        iconData = Icons.emoji_events;
        iconColor = Colors.amber;
        break;
      case NotificationType.chatMessage:
        iconData = Icons.message;
        iconColor = Colors.purple;
    }

    if (profileUrl != null && profileUrl.isNotEmpty) {
      return Stack(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: CachedNetworkImageProvider(profileUrl),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
              child: Icon(
                iconData,
                size: 10,
                color: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return CircleAvatar(
        radius: 20,
        backgroundColor: iconColor.withValues(alpha: 0.2),
        child: Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
      );
    }
  }

  Widget _buildBody(ThemeData theme) {
    final senderName = notification.senderName ?? 'Someone';

    TextSpan notificationText;

    switch (notification.type) {
      case NotificationType.follow:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' started following you',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.newPost:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' added a new post',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.postLike:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' liked your post',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.comment:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' commented on your post',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.commentReply:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' replied to your comment',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.connectionRequest:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' sent you a connection request',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.connectionAccepted:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' accepted your connection request',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;

      case NotificationType.postMilestone:
        final count = notification.count ?? 0;
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: 'Your post reached ',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: '$count likes',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;
      case NotificationType.chatMessage:
        notificationText = TextSpan(
          children: [
            TextSpan(
              text: senderName,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
            TextSpan(
              text: ' sent you a message',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary),
            ),
          ],
        );
        break;
    }

    return RichText(
      text: notificationText,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
