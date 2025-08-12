import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';

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

      final notifier = ref.read(messageInputProvider(widget.chatId).notifier);
      notifier.updateText(_textController.text);
    });

    // Listen to focus changes for typing indicator
    _focusNode.addListener(() {
      final notifier = ref.read(messageInputProvider(widget.chatId).notifier);
      notifier
          .setTyping(_focusNode.hasFocus && _textController.text.isNotEmpty);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    if (_textController.text.trim().isEmpty) return;

    final notifier = ref.read(messageInputProvider(widget.chatId).notifier);
    await notifier.sendMessage();

    // Clear the text field if message was sent successfully
    final newState = ref.read(messageInputProvider(widget.chatId));
    if (newState.text.isEmpty) {
      _textController.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final inputState = ref.watch(messageInputProvider(widget.chatId));
    final replyMessage = inputState.replyToMessageId != null
        ? ref.watch(messageProvider(inputState.replyToMessageId!))
        : null;

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reply preview
            if (inputState.replyToMessageId != null)
              replyMessage!.when(
                data: (message) => message != null
                    ? _ReplyPreview(
                        message: message,
                        onDismiss: () {
                          ref
                              .read(
                                  messageInputProvider(widget.chatId).notifier)
                              .setReplyTo(null);
                        },
                      )
                    : const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                loading: () => const CircularProgressIndicator(),
              ),

            // Error message
            if (inputState.error != null)
              _ErrorBanner(
                error: inputState.error!,
                onDismiss: () {
                  ref
                      .read(messageInputProvider(widget.chatId).notifier)
                      .clearError();
                },
              ),

            // Input area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
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
                              // TODO: Implement attachment picker
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
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                hintText: inputState.replyToMessageId != null
                                    ? 'Reply...'
                                    : 'Message...',
                                hintStyle: TextStyle(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant
                                      .withValues(alpha: 0.6),
                                ),
                              ),
                              style: Theme.of(context).textTheme.bodyMedium,
                              textCapitalization: TextCapitalization.sentences,
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
                                // TODO: Implement emoji picker
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Emoji picker coming soon!'),
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

                  // Send/Voice button
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _hasText && !inputState.isSending
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.hardEdge,
                      child: InkWell(
                        onTap: _hasText && !inputState.isSending
                            ? _sendMessage
                            : () {
                                // TODO: Voice recording
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content:
                                        Text('Voice messages coming soon!'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                        child: Center(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 150),
                            child: inputState.isSending
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.onPrimary,
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
                  ),
                ],
              ),
            ),
          ],
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

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    required this.error,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
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
            child: Text(
              error,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
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
