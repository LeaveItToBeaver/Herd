import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/message_status_indicator_widget.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

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

  void _handleReply(String messageId, String messageContent) {
    ref
        .read(messageInputProvider(widget.chatId).notifier)
        .setReplyTo(messageId);
  }

  @override
  Widget build(BuildContext context) {
    final messagesState = ref.watch(messagesProvider(widget.chatId));
    final optimisticMessages =
        ref.watch(optimisticMessagesProvider(widget.chatId));

    // More aggressive filtering to prevent any duplication
    final allMessages = <MessageModel>[];
    final seenContent = <String>{};
    final messageIds = <String>{};

    // Helper function to create content key for duplicate detection
    String contentKey(MessageModel msg) =>
        '${msg.senderId}:${msg.content}:${msg.timestamp.millisecondsSinceEpoch ~/ 1000}';

    // Add server messages first (they take priority)
    for (final message in messagesState.messages) {
      final key = contentKey(message);
      if (!messageIds.contains(message.id) && !seenContent.contains(key)) {
        allMessages.add(message);
        messageIds.add(message.id);
        seenContent.add(key);
      }
    }

    // Only add optimistic messages that don't duplicate server messages
    for (final optimisticMsg in optimisticMessages.values) {
      final key = contentKey(optimisticMsg);

      // Don't show optimistic messages that are delivered (server should handle these)
      if (optimisticMsg.status == MessageStatus.delivered) {
        continue;
      }

      // Skip if we already have this content or message ID
      if (messageIds.contains(optimisticMsg.id) || seenContent.contains(key)) {
        continue;
      }

      // Only add if it's truly unique
      allMessages.add(optimisticMsg);
      messageIds.add(optimisticMsg.id);
      seenContent.add(key);
    }

    return _buildMessagesList(allMessages, context);
  }

  Widget _buildMessagesList(
      List<MessageModel> messageList, BuildContext context) {
    if (messageList.isEmpty) {
      final currentChat = ref.read(currentChatProvider(widget.chatId));
      return EmptyChatStateWidget(
        chatName: currentChat.value?.otherUserName ?? 'this user',
        onSendFirstMessage: () {
          // Focus the input field
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
          itemBuilder: (context, index) => _MessageItem(
            message: sortedMessages[index],
            previousMessage: index > 0 ? sortedMessages[index - 1] : null,
            chatId: widget.chatId,
            onReply: _handleReply,
          ),
        ),
      ),
    );
  }
}

class _MessageItem extends ConsumerWidget {
  final MessageModel message;
  final MessageModel? previousMessage;
  final String chatId;
  final Function(String, String) onReply;

  const _MessageItem({
    required this.message,
    this.previousMessage,
    required this.chatId,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.read(currentUserProvider);
    final currentChat = ref.read(currentChatProvider(chatId));

    final isCurrentUser = currentUser.when(
      data: (user) => user?.id == message.senderId,
      loading: () => false,
      error: (_, __) => false,
    );

    // Check if we should show date separator
    bool showDateSeparator = false;
    if (previousMessage == null) {
      showDateSeparator = true;
    } else {
      final currentDate = DateTime(
        message.timestamp.year,
        message.timestamp.month,
        message.timestamp.day,
      );
      final previousDate = DateTime(
        previousMessage!.timestamp.year,
        previousMessage!.timestamp.month,
        previousMessage!.timestamp.day,
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

        // Swipeable message
        SwipeableMessage(
          message: message,
          isCurrentUser: isCurrentUser,
          onReply: () => onReply(message.id, message.content ?? ''),
          child: _MessageWithProfile(
            message: message,
            isCurrentUser: isCurrentUser,
            currentUser: currentUser,
            currentChat: currentChat,
          ),
        ),

        const SizedBox(height: 8),
      ],
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

class _MessageWithProfile extends StatelessWidget {
  final MessageModel message;
  final bool isCurrentUser;
  final AsyncValue<UserModel?> currentUser;
  final AsyncValue<ChatModel?> currentChat;

  const _MessageWithProfile({
    required this.message,
    required this.isCurrentUser,
    required this.currentUser,
    required this.currentChat,
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

  String _getDisplayName() {
    if (isCurrentUser) {
      return currentUser.when(
        data: (user) => user?.firstName ?? 'You',
        loading: () => 'You',
        error: (_, __) => 'You',
      );
    } else {
      // Use sender name from message or fallback to chat info
      if (message.senderName != null && message.senderName!.isNotEmpty) {
        return message.senderName!.split(' ').first; // Get first name only
      }
      return currentChat.when(
        data: (chat) => chat?.otherUserName?.split(' ').first ?? 'User',
        loading: () => 'User',
        error: (_, __) => 'User',
      );
    }
  }

  String? _getProfileImageUrl() {
    if (isCurrentUser) {
      return currentUser.when(
        data: (user) => user?.profileImageURL,
        loading: () => null,
        error: (_, __) => null,
      );
    } else {
      // Use sender profile image from message or fallback to chat info
      if (message.senderProfileImage != null &&
          message.senderProfileImage!.isNotEmpty) {
        return message.senderProfileImage;
      }
      return currentChat.when(
        data: (chat) => chat?.otherUserProfileImage,
        loading: () => null,
        error: (_, __) => null,
      );
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
            UserProfileImage(
              radius: 16,
              profileImageUrl: _getProfileImageUrl(),
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
                // Sender name
                Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 4),
                  child: Text(
                    _getDisplayName(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),

                // Message bubble
                Container(
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
                          ? Theme.of(context)
                              .colorScheme
                              .primary
                              .withValues(alpha: 0.5)
                          : Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.2),
                      width: 1.5,
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

                // Timestamp and status
                Padding(
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
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Avatar for current user (right side)
          if (isCurrentUser) ...[
            const SizedBox(width: 8),
            UserProfileImage(
              radius: 16,
              profileImageUrl: _getProfileImageUrl(),
            ),
          ],
        ],
      ),
    );
  }
}
