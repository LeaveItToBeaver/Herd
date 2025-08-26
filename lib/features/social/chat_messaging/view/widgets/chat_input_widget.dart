import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';

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
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

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
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final notifier = ref.read(messageInputProvider(widget.chatId).notifier);
    await notifier.sendMessage();

    // Force sync controller with provider state after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentState = ref.read(messageInputProvider(widget.chatId));
      if (currentState.text != _textController.text) {
        _textController.text = currentState.text;
        setState(() {
          _hasText = currentState.text.trim().isNotEmpty;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                              // Attachment button
                              IconButton(
                                icon: Icon(
                                  Icons.add,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  size: 22,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Attachments coming soon!'),
                                      duration: Duration(seconds: 1),
                                    ),
                                  );
                                },
                                tooltip: 'Add attachment',
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

                      // Send/Voice button - isolated from provider state
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
                              color: _hasText && !isSending
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              shape: const CircleBorder(),
                              clipBehavior: Clip.hardEdge,
                              child: InkWell(
                                onTap: _hasText && !isSending
                                    ? _sendMessage
                                    : () {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Voice messages coming soon!'),
                                            duration: Duration(seconds: 1),
                                          ),
                                        );
                                      },
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
                                            _hasText ? Icons.send : Icons.mic,
                                            color: _hasText
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
            ],
          ),
        ),
      ),
    );
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
