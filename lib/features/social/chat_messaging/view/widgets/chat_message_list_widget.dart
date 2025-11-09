import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat/chat_provider.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/message_input/notifiers/message_input_notifier.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/interactive_message_widget.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/encrypted_media_widget.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
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
    final visibleMessages = messageList.where((message) {
      return message.isDeleted != true;
    });
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
          itemBuilder: (context, index) {
            // Group consecutive media messages (images/videos/gifs) from same sender within 2 minutes window
            final current = sortedMessages[index];
            final isMediaType = current.type == MessageType.image ||
                current.type == MessageType.video ||
                current.type == MessageType.gif;

            if (!isMediaType) {
              return _MessageItem(
                message: current,
                previousMessage: index > 0 ? sortedMessages[index - 1] : null,
                chatId: widget.chatId,
                onReply: _handleReply,
              );
            }

            // If previous is media from same sender close in time, skip (will be part of earlier group)
            if (index > 0) {
              final prev = sortedMessages[index - 1];
              final prevIsMedia = prev.type == MessageType.image ||
                  prev.type == MessageType.video ||
                  prev.type == MessageType.gif;
              final sameSender = prev.senderId == current.senderId;
              final withinWindow = current.timestamp
                      .difference(prev.timestamp)
                      .inMinutes
                      .abs() <=
                  2;
              if (prevIsMedia && sameSender && withinWindow) {
                return const SizedBox.shrink();
              }
            }

            // Collect forward group
            final group = <MessageModel>[current];
            int j = index + 1;
            while (j < sortedMessages.length) {
              final next = sortedMessages[j];
              final nextIsMedia = next.type == MessageType.image ||
                  next.type == MessageType.video ||
                  next.type == MessageType.gif;
              if (!nextIsMedia ||
                  next.senderId != current.senderId ||
                  next.timestamp.difference(current.timestamp).inMinutes.abs() >
                      2) {
                break;
              }
              group.add(next);
              j++;
            }

            if (group.length == 1) {
              return _MessageItem(
                message: current,
                previousMessage: index > 0 ? sortedMessages[index - 1] : null,
                chatId: widget.chatId,
                onReply: _handleReply,
              );
            }

            final isCurrentUser = ref.read(currentUserProvider).when(
                  data: (u) => u?.id == current.senderId,
                  loading: () => false,
                  error: (_, __) => false,
                );

            // In-bubble carousel container
            return _MediaBubbleCarousel(
              messages: group,
              isCurrentUser: isCurrentUser,
              previousMessage: index > 0 ? sortedMessages[index - 1] : null,
              onReply: _handleReply,
              chatId: widget.chatId,
            );
          },
        ),
      ),
    );
  }
}

class _MediaBubbleCarousel extends StatefulWidget {
  final List<MessageModel> messages; // grouped
  final bool isCurrentUser;
  final MessageModel? previousMessage;
  final Function(String, String) onReply;
  final String chatId;

  const _MediaBubbleCarousel({
    required this.messages,
    required this.isCurrentUser,
    required this.previousMessage,
    required this.onReply,
    required this.chatId,
  });

  @override
  State<_MediaBubbleCarousel> createState() => _MediaBubbleCarouselState();
}

class _MediaBubbleCarouselState extends State<_MediaBubbleCarousel> {
  late final PageController _controller;
  int _current = 0;
  final Set<String> _prefetched = {};
  bool _fullscreenOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    // Prefetch first + next
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefetchAround(0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser = widget.isCurrentUser;
    final bubbleColor = isCurrentUser
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    // Determine date separator
    bool showDateSeparator = false;
    if (widget.previousMessage == null) {
      showDateSeparator = true;
    } else {
      final currentDate = DateTime(
        widget.messages.first.timestamp.year,
        widget.messages.first.timestamp.month,
        widget.messages.first.timestamp.day,
      );
      final previousDate = DateTime(
        widget.previousMessage!.timestamp.year,
        widget.previousMessage!.timestamp.month,
        widget.previousMessage!.timestamp.day,
      );
      showDateSeparator = !currentDate.isAtSameMomentAs(previousDate);
    }

    return Column(
      children: [
        if (showDateSeparator) ...[
          const SizedBox(height: 16),
          _DateSeparator(date: widget.messages.first.timestamp),
          const SizedBox(height: 16),
        ],
        Container(
          padding: EdgeInsets.only(
            left: isCurrentUser ? 50.0 : 0.0,
            right: isCurrentUser ? 0.0 : 50.0,
          ),
          margin: const EdgeInsets.only(bottom: 8),
          child: Row(
            mainAxisAlignment:
                isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: bubbleColor,
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
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: PageView.builder(
                            controller: _controller,
                            itemCount: widget.messages.length,
                            onPageChanged: (v) {
                              setState(() => _current = v);
                              _prefetchAround(v);
                            },
                            itemBuilder: (context, index) {
                              final m = widget.messages[index];
                              return GestureDetector(
                                onTap: () => _openFullscreen(index),
                                child: EncryptedMediaWidget(message: m),
                              );
                            },
                          ),
                        ),
                      ),
                      if (widget.messages.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children:
                                List.generate(widget.messages.length, (idx) {
                              final active = idx == _current;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 3),
                                width: active ? 10 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: (isCurrentUser
                                          ? Theme.of(context)
                                              .colorScheme
                                              .onPrimary
                                          : Theme.of(context)
                                              .colorScheme
                                              .primary)
                                      .withValues(alpha: active ? 0.9 : 0.4),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      _groupCaption(isCurrentUser, context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _groupCaption(bool isCurrentUser, BuildContext context) {
    final caption = widget.messages
        .firstWhere(
          (m) => (m.content ?? '').isNotEmpty,
          orElse: () => widget.messages.first,
        )
        .content;
    if (caption == null || caption.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        caption,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isCurrentUser
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }

  void _prefetchAround(int index) {
    _prefetch(index + 1);
    _prefetch(index - 1);
  }

  void _prefetch(int index) async {
    if (index < 0 || index >= widget.messages.length) return;
    final msg = widget.messages[index];
    if (_prefetched.contains(msg.id)) return;
    _prefetched.add(msg.id);
    // Use a provider scope lookup via context
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final auth = container.read(authProvider);
      if (auth == null) return;
      final repo = container.read(messageRepositoryProvider);
      await repo.getDecryptedMedia(message: msg, currentUserId: auth.uid);
    } catch (_) {
      // swallow
    }
  }

  void _openFullscreen(int startIndex) async {
    if (_fullscreenOpen) return;
    _fullscreenOpen = true;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => _FullscreenMediaGallery(
          messages: widget.messages,
          startIndex: startIndex,
        ),
      ),
    );
    _fullscreenOpen = false;
  }
}

class _FullscreenMediaGallery extends ConsumerStatefulWidget {
  final List<MessageModel> messages;
  final int startIndex;
  const _FullscreenMediaGallery(
      {required this.messages, required this.startIndex});
  @override
  ConsumerState<_FullscreenMediaGallery> createState() =>
      _FullscreenMediaGalleryState();
}

class _FullscreenMediaGalleryState
    extends ConsumerState<_FullscreenMediaGallery> {
  late PageController _pageController;
  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.messages.length,
              itemBuilder: (context, index) {
                final m = widget.messages[index];
                return _FullscreenMediaItem(message: m);
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FullscreenMediaItem extends ConsumerStatefulWidget {
  final MessageModel message;
  const _FullscreenMediaItem({required this.message});

  @override
  ConsumerState<_FullscreenMediaItem> createState() =>
      _FullscreenMediaItemState();
}

class _FullscreenMediaItemState extends ConsumerState<_FullscreenMediaItem> {
  File? _file;
  double _progress = 0.0;
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final msg = widget.message;
    try {
      // Optimistic local file path
      if (msg.mediaUrl != null && File(msg.mediaUrl!).existsSync()) {
        _file = File(msg.mediaUrl!);
        setState(() {
          _loading = false;
        });
        return;
      }
      // Check cached decrypted media
      final cache = ref.read(messageCacheServiceProvider);
      await cache.initialize();
      final cached = await cache.getCachedMediaFile(msg.id);
      if (cached != null && await cached.exists()) {
        _file = cached;
        setState(() {
          _loading = false;
        });
        return;
      }
      // Decrypt & download full media
      final auth = ref.read(authProvider);
      if (auth == null) {
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }
      final repo = ref.read(messageRepositoryProvider);
      final file = await repo.getDecryptedMedia(
        message: msg,
        currentUserId: auth.uid,
        onProgress: (p) {
          if (!mounted) return;
          setState(() {
            _progress = p;
          });
        },
      );
      if (file != null) {
        _file = file;
      } else {
        _error = true;
      }
    } catch (_) {
      _error = true;
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                  value: _progress > 0 && _progress < 1 ? _progress : null,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Text('Loading media', style: TextStyle(color: Colors.white70)),
          ],
        ),
      );
    }
    if (_error || _file == null) {
      return Center(
        child: Icon(Icons.error_outline, color: Colors.redAccent, size: 42),
      );
    }

    Widget media;
    if (widget.message.type == MessageType.video) {
      // Reuse existing encrypted widget (it handles video player logic) but we already have decrypted file; could implement custom player.
      media = EncryptedMediaWidget(message: widget.message);
    } else {
      media = Image.file(_file!, fit: BoxFit.contain);
    }
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: InteractiveViewer(
        panEnabled: true,
        minScale: 0.5,
        maxScale: 5,
        child: Center(child: media),
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

  String _getDisplayName(MessageModel message, bool isCurrentUser,
      AsyncValue<UserModel?> currentUser, AsyncValue<ChatModel?> currentChat) {
    if (isCurrentUser) {
      return currentUser.when(
        data: (user) => user?.firstName ?? 'You',
        loading: () => 'You',
        error: (_, __) => 'You',
      );
    } else {
      // For alt profiles, NEVER show usernames - only use first name from senderName
      // senderName should contain "firstName lastName" format, not username
      if (message.senderName != null && message.senderName!.isNotEmpty) {
        final nameParts = message.senderName!.trim().split(' ');
        // Only return the first part and ensure it's not a username (doesn't start with @)
        final firstName = nameParts.first.trim();
        if (firstName.isNotEmpty && !firstName.startsWith('@')) {
          return firstName;
        }
      }

      // Fallback to generic "User" - never expose username information
      return 'User';
    }
  }

  String? _getProfileImageUrl(MessageModel message, bool isCurrentUser,
      AsyncValue<UserModel?> currentUser, AsyncValue<ChatModel?> currentChat) {
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

        // Enhanced interactive message with swipe support
        SwipeableMessage(
          message: message,
          isCurrentUser: isCurrentUser,
          onReply: () => onReply(message.id, message.content ?? ''),
          onReplyCallback: onReply,
          child: InteractiveMessageWidget(
            message: message,
            isCurrentUser: isCurrentUser,
            displayName: _getDisplayName(
                message, isCurrentUser, currentUser, currentChat),
            profileImageUrl: _getProfileImageUrl(
                message, isCurrentUser, currentUser, currentChat),
            onReply: (messageId, content) => onReply(messageId, content),
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
