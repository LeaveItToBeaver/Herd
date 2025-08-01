import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/draggable_bubble_widget.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_type.dart';

class ChatMessageListWidget extends ConsumerStatefulWidget {
  final String chatId;

  const ChatMessageListWidget({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatMessageListWidget> createState() =>
      _ChatMessageListWidgetState();
}

class _ChatMessageListWidgetState extends ConsumerState<ChatMessageListWidget> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

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
    final messagesAsync = ref.watch(messagesProvider(widget.chatId));

    return messagesAsync.when(
      data: (messages) {
        if (messages.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No messages yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Start the conversation!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        // Scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.builder(
            controller: _scrollController,
            reverse: false, // Since messages are already sorted newest first
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final message = messages[index];
              final isCurrentUser = message.senderId == 'current_user';

              // Check if we should show date separator
              bool showDateSeparator = false;
              if (index == 0) {
                showDateSeparator = true;
              } else {
                final previousMessage = messages[index - 1];
                final currentDate = DateTime(
                  message.timestamp.year,
                  message.timestamp.month,
                  message.timestamp.day,
                );
                final previousDate = DateTime(
                  previousMessage.timestamp.year,
                  previousMessage.timestamp.month,
                  previousMessage.timestamp.day,
                );
                showDateSeparator = !currentDate.isAtSameMomentAs(previousDate);
              }

              return Column(
                children: [
                  // Date separator
                  if (showDateSeparator) ...[
                    const SizedBox(height: 16),
                    _DateSeparator(date: message.timestamp),
                    const SizedBox(height: 16),
                  ],

                  // Message bubble using draggable bubble component
                  Padding(
                    padding: EdgeInsets.only(
                      left: isCurrentUser ? 50.0 : 0.0,
                      right: isCurrentUser ? 0.0 : 50.0,
                    ),
                    child: Row(
                      mainAxisAlignment: isCurrentUser
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onSurface,
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: isCurrentUser
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              // Sender name (only for other users)
                              if (!isCurrentUser && message.senderName != null)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Text(
                                    message.senderName!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),

                              // Message bubble
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context)
                                          .colorScheme
                                          .surfaceContainerHighest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(16),
                                    topRight: const Radius.circular(16),
                                    bottomLeft:
                                        Radius.circular(isCurrentUser ? 16 : 4),
                                    bottomRight:
                                        Radius.circular(isCurrentUser ? 4 : 16),
                                  ),
                                ),
                                child: Text(
                                  message.content ?? '',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isCurrentUser
                                            ? Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurface,
                                      ),
                                ),
                              ),

                              // Timestamp
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  _formatMessageTime(message.timestamp),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurfaceVariant,
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
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor:
                                  Theme.of(context).colorScheme.onPrimary,
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
                  ),

                  const SizedBox(height: 8),
                ],
              );
            },
          ),
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load messages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.invalidate(messagesProvider(widget.chatId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final DateTime date;

  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate.isAtSameMomentAs(today)) {
      dateText = 'Today';
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      dateText = 'Yesterday';
    } else {
      dateText = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        dateText,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }
}
