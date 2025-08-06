import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/empty_chat_state_widget.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/message_bubble_widget.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/swipable_message_widget.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';

class ChatMessageListWidget extends ConsumerStatefulWidget {
  final String chatId;
  final String bubbleId;
  final VoidCallback? onCloseRequested;

  const ChatMessageListWidget({
    super.key,
    required this.chatId,
    required this.bubbleId,
    this.onCloseRequested,
  });

  @override
  ConsumerState<ChatMessageListWidget> createState() =>
      _ChatMessageListWidgetState();
}

class _ChatMessageListWidgetState extends ConsumerState<ChatMessageListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _isAtBottom = true;
  double _dragOffset = 0.0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.hasClients) {
      final isAtBottom = _scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50;
      if (isAtBottom != _isAtBottom) {
        setState(() {
          _isAtBottom = isAtBottom;
        });
      }
    }
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

  String formatMessageTime(DateTime timestamp) {
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

  void _handleReply(String messageId, String messageContent) {
    ref
        .read(messageInputProvider(widget.chatId).notifier)
        .setReplyTo(messageId);
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(messagesProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider);
    final currentChat = ref.watch(currentChatProvider(widget.chatId));

    return messages.when(
      data: (messageList) {
        if (messageList.isEmpty) {
          return EmptyChatStateWidget(
            chatName: currentChat.value?.otherUserName ?? 'this user',
            onSendFirstMessage: () {
              // Focus the input field
              // You might want to pass a callback to focus the input
            },
          );
        }

        // Sort messages by timestamp (oldest first for correct display order)
        final sortedMessages = [...messageList]
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Scroll to bottom when new messages arrive
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_isAtBottom) {
            _scrollToBottom();
          }
        });

        return NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // Handle overscroll for swipe-to-close
            if (_isAtBottom && notification is OverscrollNotification) {
              if (notification.overscroll > 0) {
                setState(() {
                  _isDragging = true;
                  _dragOffset += notification.overscroll;
                });

                if (_dragOffset > 100 && widget.onCloseRequested != null) {
                  widget.onCloseRequested!();
                }
              }
            } else if (notification is ScrollEndNotification) {
              setState(() {
                _isDragging = false;
                _dragOffset = 0.0;
              });
            }
            return false;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            transform: Matrix4.translationValues(
                0, _isDragging ? _dragOffset * 0.3 : 0, 0),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: sortedMessages.length,
              itemBuilder: (context, index) {
                final message = sortedMessages[index];
                final isCurrentUser = message.senderId == 'current_user';

                // Check if we should show date separator
                bool showDateSeparator = false;
                if (index == 0) {
                  showDateSeparator = true;
                } else {
                  final previousMessage = sortedMessages[index - 1];
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
                  showDateSeparator =
                      !currentDate.isAtSameMomentAs(previousDate);
                }

                return Column(
                  children: [
                    // Date separator
                    if (showDateSeparator) ...[
                      const SizedBox(height: 16),
                      _DateSeparator(date: message.timestamp),
                      const SizedBox(height: 16),
                    ],

                    // Swipeable message
                    SwipeableMessage(
                      message: message,
                      isCurrentUser: isCurrentUser,
                      onReply: () =>
                          _handleReply(message.id, message.content ?? ''),
                      child: MessageBubble(
                        message: message,
                        isCurrentUser: isCurrentUser,
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                );
              },
            ),
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
                ref.invalidate(messageProvider(widget.chatId));
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
