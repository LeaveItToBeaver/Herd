import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/chat_header_widget.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/chat_message_list_widget.dart';
import 'package:herdapp/features/social/chat_messaging/view/widgets/chat_input_widget.dart';

class ChatOverlayWidget extends ConsumerStatefulWidget {
  final String bubbleId;
  final VoidCallback onClose;

  const ChatOverlayWidget({
    super.key,
    required this.bubbleId,
    required this.onClose,
  });

  @override
  ConsumerState<ChatOverlayWidget> createState() => _ChatOverlayWidgetState();
}

class _ChatOverlayWidgetState extends ConsumerState<ChatOverlayWidget> {
  bool _isKeyboardVisible = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Track keyboard visibility
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final newKeyboardVisible = bottomInset > 0;
    
    if (newKeyboardVisible != _isKeyboardVisible) {
      setState(() {
        _isKeyboardVisible = newKeyboardVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChat = ref.watch(currentChatProvider(widget.bubbleId));
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomNavHeight = 94.0; // Bottom nav height + padding

    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Swipe down to close
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          widget.onClose();
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          top: statusBarHeight, // Account for status bar
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(2, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            // Swipe indicator
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 8, bottom: 4),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            ChatHeaderWidget(
              bubbleId: widget.bubbleId,
              onClose: widget.onClose,
            ),

            // Messages List
            Expanded(
              child: currentChat.when(
                data: (chat) => chat != null
                    ? ChatMessageListWidget(chatId: chat.id)
                    : const Center(
                        child: Text('Chat not found'),
                      ),
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
                        'Failed to load chat',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Input Area with keyboard awareness
            currentChat.when(
              data: (chat) => chat != null
                  ? AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.only(
                        bottom: keyboardHeight > 0 
                            ? keyboardHeight 
                            : bottomNavHeight, // Keep above bottom nav when keyboard is hidden
                      ),
                      child: ChatInputWidget(
                        chatId: chat.id,
                      ),
                    )
                  : const SizedBox.shrink(),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
