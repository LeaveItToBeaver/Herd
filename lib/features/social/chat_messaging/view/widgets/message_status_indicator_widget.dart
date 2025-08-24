import 'package:flutter/material.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';

class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;

  const MessageStatusIndicator({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ));
      case MessageStatus.delivered:
        return Icon(Icons.done,
            size: 12,
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8));
      case MessageStatus.failed:
        return Icon(Icons.error_outline,
            size: 12,
            color: Theme.of(context).colorScheme.error);
      case MessageStatus.read:
        return Icon(Icons.done_all,
            size: 12,
            color: Theme.of(context).colorScheme.primary);
      case MessageStatus.draft:
        return Icon(Icons.note,
            size: 12,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6));
    }
  }
}
