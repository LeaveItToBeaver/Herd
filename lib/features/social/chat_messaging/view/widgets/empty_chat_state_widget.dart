import 'package:flutter/material.dart';

class EmptyChatStateWidget extends StatelessWidget {
  final String chatName;
  final VoidCallback? onSendFirstMessage;

  const EmptyChatStateWidget({
    super.key,
    required this.chatName,
    this.onSendFirstMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with $chatName',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.5),
                  ),
              textAlign: TextAlign.center,
            ),
            if (onSendFirstMessage != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onSendFirstMessage,
                icon: const Icon(Icons.send),
                label: const Text('Send first message'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
