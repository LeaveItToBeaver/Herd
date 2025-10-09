import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';

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
  // Remove the keyboard tracking that causes rebuilds
  // bool _isKeyboardVisible = false;

  // Don't use didChangeDependencies to track keyboard
  // This was causing unnecessary rebuilds

  @override
  void initState() {
    super.initState();

    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      ref.read(initializeE2eeProvider(currentUser.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentChat = ref.watch(currentChatProvider(widget.bubbleId));
    final statusBarHeight = MediaQuery.of(context).padding.top;

    // Get the draggable painter color from customization
    final customization = ref.watch(uiCustomizationProvider).value;
    final appTheme = customization?.appTheme;
    final painterColor =
        appTheme?.getSurfaceColor() ?? Theme.of(context).colorScheme.surface;

    // Wrap the entire overlay in RepaintBoundary to isolate repaints
    return RepaintBoundary(
      child: GestureDetector(
        onVerticalDragEnd: (details) {
          // Swipe down to close
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            widget.onClose();
          }
        },
        child: Container(
          margin: EdgeInsets.only(
            top: statusBarHeight,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(
              color: painterColor,
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              // Swipe indicator
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 8, bottom: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header - wrapped in RepaintBoundary
              RepaintBoundary(
                child: ChatHeaderWidget(
                  bubbleId: widget.bubbleId,
                  onClose: widget.onClose,
                ),
              ),

              // Messages List - wrapped in RepaintBoundary
              Expanded(
                child: RepaintBoundary(
                  child: currentChat.when(
                    data: (chat) => chat != null
                        ? ChatMessageListWidget(
                            chatId: chat.id,
                            bubbleId: widget.bubbleId,
                          )
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
              ),

              // Input Area - isolated keyboard handling
              currentChat.when(
                data: (chat) => chat != null
                    ? _KeyboardAwareInputWrapper(
                        chatId: chat.id,
                      )
                    : const SizedBox.shrink(),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate widget to handle keyboard without affecting other widgets
class _KeyboardAwareInputWrapper extends StatelessWidget {
  final String chatId;

  const _KeyboardAwareInputWrapper({
    required this.chatId,
  });

  @override
  Widget build(BuildContext context) {
    // Handle keyboard locally without triggering parent rebuilds
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: RepaintBoundary(
        child: ChatInputWidget(
          chatId: chatId,
        ),
      ),
    );
  }
}
