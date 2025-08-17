import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';

class ChatHeaderWidget extends ConsumerWidget {
  final String bubbleId;
  final VoidCallback onClose;

  const ChatHeaderWidget({
    super.key,
    required this.bubbleId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentChat = ref.watch(currentChatProvider(bubbleId));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          topLeft: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor:
                Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.2),
            backgroundImage: currentChat.maybeWhen(
              data: (chat) => chat?.otherUserProfileImage != null
                  ? NetworkImage(chat!.otherUserProfileImage!)
                  : null,
              orElse: () => null,
            ),
            child: currentChat.maybeWhen(
              data: (chat) => chat?.otherUserProfileImage == null
                  ? Icon(
                      chat?.isGroupChat == true ? Icons.group : Icons.person,
                      color: Theme.of(context).colorScheme.onPrimary,
                    )
                  : null,
              orElse: () => Icon(
                Icons.person,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Chat info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name
                currentChat.when(
                  data: (chat) => Text(
                    chat?.otherUserName ?? 'Chat',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Error',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),

                const SizedBox(height: 2),

                // Username or status
                currentChat.when(
                  data: (chat) => Text(
                    chat?.otherUserUsername ?? '@unknown',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.8),
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  loading: () => Container(
                    height: 12,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  error: (_, __) => Text(
                    'Offline',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.8),
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Action buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Video call button
              IconButton(
                icon: Icon(
                  Icons.videocam,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  // TODO: Implement video call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Video call coming soon!')),
                  );
                },
                tooltip: 'Video call',
              ),

              // Voice call button
              IconButton(
                icon: Icon(
                  Icons.call,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: () {
                  // TODO: Implement voice call
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Voice call coming soon!')),
                  );
                },
                tooltip: 'Voice call',
              ),

              // More options
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onSelected: (value) {
                  switch (value) {
                    case 'mute':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Mute/Unmute coming soon!')),
                      );
                      break;
                    case 'search':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Search in chat coming soon!')),
                      );
                      break;
                    case 'clear':
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Clear chat coming soon!')),
                      );
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'mute',
                    child: ListTile(
                      leading: Icon(Icons.volume_off),
                      title: Text('Mute'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'search',
                    child: ListTile(
                      leading: Icon(Icons.search),
                      title: Text('Search'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'clear',
                    child: ListTile(
                      leading: Icon(Icons.clear_all),
                      title: Text('Clear Chat'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),

              // Close button
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
                onPressed: onClose,
                tooltip: 'Close chat',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
