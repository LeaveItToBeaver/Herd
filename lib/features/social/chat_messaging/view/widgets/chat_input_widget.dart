import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat/notifiers/messages_notifier.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/message/message_provider.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/message_input/notifiers/message_input_notifier.dart';
import 'package:image_picker/image_picker.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/user/user_management/view/providers/user_block_providers.dart';

class ChatInputWidget extends ConsumerStatefulWidget {
  final String chatId;

  const ChatInputWidget({
    super.key,
    required this.chatId,
  });

  @override
  ConsumerState<ChatInputWidget> createState() => _ChatInputWidgetState();
}

class _ChatInputWidgetState extends ConsumerState<ChatInputWidget> {
  late final TextEditingController _textController;
  late final TextEditingController _captionController;
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;
  // Pending attachments selected by user (images/videos) before sending
  final List<_PendingAttachment> _attachments = [];
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _captionController = TextEditingController();

    // Listen to text changes
    _textController.addListener(() {
      final hasText = _textController.text.trim().isNotEmpty;
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }

      // Debounce provider updates to prevent excessive rebuilds during typing
      _debounceUpdateProvider();
    });

    // Listen to focus changes for typing indicator
    _focusNode.addListener(() {
      if (mounted) {
        final notifier = ref.read(messageInputProvider(widget.chatId).notifier);
        notifier
            .setTyping(_focusNode.hasFocus && _textController.text.isNotEmpty);
      }
    });
  }

  Timer? _debounceTimer;

  void _debounceUpdateProvider() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (mounted) {
        final notifier = ref.read(messageInputProvider(widget.chatId).notifier);
        notifier.updateText(_textController.text);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _textController.dispose();
    _captionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String? _getOtherUserId() {
    final currentUserId = ref.read(authProvider)?.uid;
    if (currentUserId == null || !widget.chatId.contains('_')) {
      return null;
    }

    final parts = widget.chatId.split('_');
    if (parts.length == 2) {
      return parts[0] == currentUserId ? parts[1] : parts[0];
    }

    return null;
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty && _attachments.isEmpty) return;

    final notifier = ref.read(messageInputProvider(widget.chatId).notifier);

    // Send text (if any)
    if (_textController.text.trim().isNotEmpty) {
      await notifier.sendMessage();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final currentState = ref.read(messageInputProvider(widget.chatId));
        if (currentState.text != _textController.text) {
          _textController.text = currentState.text;
        }
        if (mounted) {
          setState(() {
            _hasText = false;
          });
        }
      });
    }

    // Then send all attachments in this batch
    final batch = List<_PendingAttachment>.from(_attachments);
    _attachments.clear();
    if (mounted) setState(() {});
    for (final pending in batch) {
      await _sendMediaMessage(pending.file, pending.type);
    }
  }

  Future<void> _showAttachmentSheet() async {
    if (_picking) return;
    if (!mounted) return;
    setState(() => _picking = true);
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Images'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final images = await picker.pickMultiImage();
                  if (!mounted) return;
                  if (images.isNotEmpty) {
                    setState(() {
                      _attachments.addAll(images.map((x) => _PendingAttachment(
                          file: File(x.path), type: MessageType.image)));
                      _hasText = _textController.text.trim().isNotEmpty;
                    });
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Video'),
                onTap: () async {
                  Navigator.pop(context);
                  final picker = ImagePicker();
                  final video =
                      await picker.pickVideo(source: ImageSource.gallery);
                  if (video != null && mounted) {
                    setState(() {
                      _attachments.add(_PendingAttachment(
                          file: File(video.path), type: MessageType.video));
                    });
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (mounted) setState(() => _picking = false);
  }

  Widget _buildBlockedInputMessage(String message, {bool showIcon = true}) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                if (showIcon) ...[
                  Icon(
                    Icons.block,
                    color: Theme.of(context).colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledInput() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Container(
                  constraints: const BoxConstraints(minHeight: 44),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const TextField(
                    enabled: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      hintText: 'Message...',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.3),
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final otherUserId = _getOtherUserId();

    // If not a direct chat, show normal input
    if (otherUserId == null) {
      return _buildNormalInput();
    }

    // For direct chats, check blocking status using bi-directional provider
    final canInteractAsync = ref.watch(canUsersInteractProvider(otherUserId));

    return canInteractAsync.when(
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => _buildNormalInput(),
      data: (canInteract) {
        if (!canInteract) {
          // Users are blocked - determine which message to show
          final currentUserId = ref.watch(authProvider)?.uid;
          if (currentUserId == null) {
            return const SizedBox.shrink();
          }

          // Check if current user blocked the other user to show appropriate message
          final currentUserBlockedOtherAsync =
              ref.watch(isUserBlockedProvider(otherUserId));

          return currentUserBlockedOtherAsync.when(
            loading: () => _buildDisabledInput(),
            error: (_, __) => _buildDisabledInput(),
            data: (currentUserBlockedOther) {
              if (currentUserBlockedOther) {
                // Current user blocked the other user - show explicit message
                return _buildBlockedInputMessage(
                  'You have blocked this user. You cannot send them any messages.',
                );
              } else {
                // Other user blocked current user - show disabled input without explanation
                return _buildDisabledInput();
              }
            },
          );
        }

        // Users can interact - show normal input
        return _buildNormalInput();
      },
    );
  }

  Widget _buildNormalInput() {
    // Wrap entire input widget in RepaintBoundary
    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          border: Border(
            top: BorderSide(
              color:
                  Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Reply preview - only rebuilds when reply state changes
              Consumer(
                builder: (context, ref, child) {
                  final replyToMessageId = ref.watch(
                    messageInputProvider(widget.chatId).select(
                      (state) => state.replyToMessageId,
                    ),
                  );

                  if (replyToMessageId == null) {
                    return const SizedBox.shrink();
                  }

                  return ref.watch(messageProvider(replyToMessageId)).when(
                        data: (message) => message != null
                            ? RepaintBoundary(
                                child: _ReplyPreview(
                                  message: message,
                                  onDismiss: () {
                                    ref
                                        .read(
                                            messageInputProvider(widget.chatId)
                                                .notifier)
                                        .setReplyTo(null);
                                  },
                                ),
                              )
                            : const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                        loading: () => const CircularProgressIndicator(),
                      );
                },
              ),

              // Error message - only rebuilds when error state changes
              Consumer(
                builder: (context, ref, child) {
                  final error = ref.watch(
                    messageInputProvider(widget.chatId).select(
                      (state) => state.error,
                    ),
                  );

                  if (error == null) {
                    return const SizedBox.shrink();
                  }

                  return RepaintBoundary(
                    child: _ErrorBanner(
                      error: error,
                      chatId: widget.chatId,
                      onDismiss: () {
                        ref
                            .read(messageInputProvider(widget.chatId).notifier)
                            .clearError();
                      },
                    ),
                  );
                },
              ),

              // Input area - isolated from state changes
              RepaintBoundary(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Text input field
                      Expanded(
                        child: Container(
                          constraints: const BoxConstraints(
                            minHeight: 44,
                            maxHeight: 120,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Unified attachment picker (+) button
                              IconButton(
                                icon: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant,
                                      size: 22,
                                    ),
                                    if (_attachments.isNotEmpty)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4, vertical: 1),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            _attachments.length.toString(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                onPressed:
                                    _picking ? null : _showAttachmentSheet,
                                tooltip: 'Add attachments',
                                padding: const EdgeInsets.all(10),
                                constraints: const BoxConstraints(),
                              ),

                              // Text field
                              Expanded(
                                child: TextField(
                                  controller: _textController,
                                  focusNode: _focusNode,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    hintText: 'Message...',
                                    hintStyle: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurfaceVariant
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  onSubmitted: (_) => _sendMessage(),
                                ),
                              ),

                              // Removed individual media buttons (consolidated under +)

                              // Emoji button (only when no text)
                              if (!_hasText)
                                IconButton(
                                  icon: Icon(
                                    Icons.mood,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content:
                                            Text('Emoji picker coming soon!'),
                                        duration: Duration(seconds: 1),
                                      ),
                                    );
                                  },
                                  tooltip: 'Emojis',
                                  padding: const EdgeInsets.all(10),
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // Send button (active if text or attachments)
                      Consumer(
                        builder: (context, ref, child) {
                          final isSending = ref.watch(
                            messageInputProvider(widget.chatId).select(
                              (state) => state.isSending,
                            ),
                          );

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (_hasText || _attachments.isNotEmpty) &&
                                      !isSending
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                onTap: (_hasText || _attachments.isNotEmpty) &&
                                        !isSending
                                    ? _sendMessage
                                    : null,
                                child: Center(
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 150),
                                    child: isSending
                                        ? SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            (_hasText ||
                                                    _attachments.isNotEmpty)
                                                ? Icons.send
                                                : Icons.mic,
                                            color: (_hasText ||
                                                    _attachments.isNotEmpty)
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                            size: 22,
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              // Attachment preview strip
              if (_attachments.isNotEmpty)
                SizedBox(
                  height: 92,
                  child: ListView.separated(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final att = _attachments[index];
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: 80,
                              height: 80,
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              child: att.type == MessageType.image
                                  ? Image.file(att.file, fit: BoxFit.cover)
                                  : Center(
                                      child: Icon(Icons.videocam,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: -6,
                            top: -6,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _attachments.removeAt(index);
                                });
                              },
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.close,
                                    size: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemCount: _attachments.length,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMediaMessage(File mediaFile, MessageType mediaType) async {
    final inputNotifier =
        ref.read(messageInputProvider(widget.chatId).notifier);

    try {
      setState(() => _isUploading = true);

      final messagesRepo = ref.read(messageRepositoryProvider);
      final messagesNotifier =
          ref.read(messagesProvider(widget.chatId).notifier);
      final authUser = ref.read(authProvider);
      final currentUser = ref.read(currentUserProvider);

      if (authUser == null) throw Exception('Not authenticated');
      final user = currentUser.when(
        data: (u) => u,
        loading: () => null,
        error: (_, __) => null,
      );
      if (user == null) throw Exception('User not loaded');

      // 1. Create optimistic message
      final tempId =
          'temp_media_${DateTime.now().microsecondsSinceEpoch}_${mediaFile.path.hashCode}';
      final optimistic = MessageModel(
        id: tempId,
        chatId: widget.chatId,
        senderId: authUser.uid,
        senderName: '${user.firstName} ${user.lastName}'.trim(),
        senderProfileImage: user.profileImageURL,
        content: _captionController.text.trim().isEmpty
            ? null
            : _captionController.text.trim(),
        type: mediaType,
        status: MessageStatus.sending,
        timestamp: DateTime.now(),
        // Temporarily use mediaUrl to pass local path so UI can display immediately
        mediaUrl: mediaFile.path,
      );

      messagesNotifier.addOptimisticMessage(optimistic);

      // 2. Clear caption once for first media in batch
      _captionController.clear();

      // 3. Perform encryption/upload in background (not awaited for UI speed)
      () async {
        try {
          final sentMessage = await messagesRepo.sendEncryptedMedia(
            chatId: widget.chatId,
            senderId: authUser.uid,
            mediaFile: mediaFile,
            mediaType: mediaType,
            caption: optimistic.content,
            senderName: optimistic.senderName,
            onProgress: (progress) {
              if (!mounted) return;
              setState(() => _uploadProgress = progress);
            },
          );

          // Replace optimistic with server message (will have remote mediaUrl encrypted metadata)
          messagesNotifier.replaceOptimisticMessage(tempId, sentMessage);
          debugPrint('Media sent & replaced: ${sentMessage.id}');
        } catch (e) {
          debugPrint('Failed to send media: $e');
          messagesNotifier.updateMessageStatus(tempId, MessageStatus.failed);
        } finally {
          if (mounted) {
            setState(() {
              _isUploading = false;
              _uploadProgress = 0.0;
            });
          }
        }
      }();
    } catch (e) {
      debugPrint('Media send setup failed: $e');
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0.0;
        });
      }
    }
  }
}

class _ReplyPreview extends StatelessWidget {
  final MessageModel message;
  final VoidCallback onDismiss;

  const _ReplyPreview({
    required this.message,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 36,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.senderName ?? 'Unknown',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  message.content ?? '',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends ConsumerWidget {
  final String error;
  final VoidCallback onDismiss;
  final String chatId;

  const _ErrorBanner({
    required this.error,
    required this.onDismiss,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRetryableError = error.contains('Failed to send message');

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  error,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                ),
                if (isRetryableError) ...[
                  const SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      ref
                          .read(messageInputProvider(chatId).notifier)
                          .clearError();
                      ref
                          .read(messageInputProvider(chatId).notifier)
                          .sendMessage();
                    },
                    child: Text(
                      'Tap to retry',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
            onPressed: onDismiss,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}

// Internal model for pending attachments
class _PendingAttachment {
  final File file;
  final MessageType type;
  _PendingAttachment({required this.file, required this.type});
}
