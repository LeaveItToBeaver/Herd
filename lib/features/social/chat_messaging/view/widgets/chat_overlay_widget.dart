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
    // Create a completely isolated widget tree that doesn't depend on external MediaQuery changes
    return RepaintBoundary(
      child: Builder(
        builder: (isolatedContext) {
          // Pre-calculate all needed values to minimize provider watches during rebuilds
          final statusBarHeight = MediaQuery.of(context).padding.top;
          final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

          return MediaQuery(
            // Provide stable MediaQuery data that ignores keyboard changes
            data: MediaQuery.of(context).copyWith(
              viewInsets: EdgeInsets.zero, // Always zero to prevent rebuilds
              size: Size(
                MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height +
                    keyboardHeight, // Stable size
              ),
            ),
            child: _ChatOverlayContent(
              bubbleId: widget.bubbleId,
              onClose: widget.onClose,
              statusBarHeight: statusBarHeight,
              keyboardHeight: keyboardHeight,
            ),
          );
        },
      ),
    );
  }
}

class _ChatOverlayContent extends ConsumerStatefulWidget {
  final String bubbleId;
  final VoidCallback onClose;
  final double statusBarHeight;
  final double keyboardHeight;

  const _ChatOverlayContent({
    required this.bubbleId,
    required this.onClose,
    required this.statusBarHeight,
    required this.keyboardHeight,
  });

  @override
  ConsumerState<_ChatOverlayContent> createState() =>
      _ChatOverlayContentState();
}

class _ChatOverlayContentState extends ConsumerState<_ChatOverlayContent> {
  // Cache the chat provider to avoid repeated lookups
  late final _currentChatProvider = currentChatProvider(widget.bubbleId);

  @override
  Widget build(BuildContext context) {
    // Watch providers only once and cache results
    final currentChat = ref.watch(_currentChatProvider);

    // Pre-calculate theme values to avoid repeated theme lookups
    final theme = Theme.of(context);
    final surfaceColor = theme.colorScheme.surface;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    return GestureDetector(
      onVerticalDragEnd: (details) {
        // Swipe down to close
        if (details.primaryVelocity != null && details.primaryVelocity! > 300) {
          widget.onClose();
        }
      },
      child: Container(
        margin: EdgeInsets.only(
          top: widget.statusBarHeight, // Account for status bar
        ),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: surfaceColor,
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
                color: onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            ChatHeaderWidget(
              bubbleId: widget.bubbleId,
              onClose: widget.onClose,
            ),

            // Messages List - wrapped in its own RepaintBoundary
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
                          color: theme.colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load chat',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error.toString(),
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Input Area with manual keyboard handling for better performance
            currentChat.when(
              data: (chat) => chat != null
                  ? RepaintBoundary(
                      child: Container(
                        padding: EdgeInsets.only(
                          bottom: widget.keyboardHeight,
                        ),
                        child: ChatInputWidget(
                          chatId: chat.id,
                        ),
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
