import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart' hide SideBubblesOverlay;
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/side_bubble_overlay_widget.dart';

class GlobalOverlayManager extends ConsumerWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showSideBubbles;
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;
  final bool showHerdBubbles;
  final FeedType? currentFeedType;

  const GlobalOverlayManager({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.showSideBubbles = true,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
    this.showHerdBubbles = false,
    this.currentFeedType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showAnyButtons =
        showProfileBtn || showSearchBtn || showNotificationsBtn;

    // Watch the drag state to determine if we should offset content
    final isDragging = ref.watch(isDraggingProvider);
    final isChatOverlayOpen = ref.watch(chatOverlayOpenProvider);
    final chatTriggeredByBubble = ref.watch(chatTriggeredByBubbleProvider);
    final explosionReveal = ref.watch(explosionRevealProvider);

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            child,

            // Side Bubbles - only shown if explicitly enabled
            if (showSideBubbles)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                child: SideBubblesOverlay(
                  showProfileBtn: showProfileBtn,
                  showSearchBtn: showSearchBtn,
                  showNotificationsBtn: showNotificationsBtn,
                  showHerdBubbles: showHerdBubbles,
                ),
              ),

            // Chat Overlay - takes up left side of screen when triggered
            if (isChatOverlayOpen && chatTriggeredByBubble != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 70, // Leave space for side bubbles
                child: explosionReveal != null && explosionReveal.isActive
                    ? _ChatOverlayWithReveal(
                        explosionReveal: explosionReveal,
                        backgroundColor: backgroundColor,
                        child: _ChatOverlayPlaceholder(
                          bubbleId: chatTriggeredByBubble,
                          onClose: () {
                            // Try animation first, fallback to direct close
                            final callbacks =
                                ref.read(bubbleAnimationCallbackProvider);
                            final callback = callbacks[chatTriggeredByBubble];

                            if (callback != null) {
                              // Trigger reverse animation
                              ref
                                  .read(chatClosingAnimationProvider.notifier)
                                  .state = chatTriggeredByBubble;
                            } else {
                              // Fallback: close directly
                              ref.read(chatOverlayOpenProvider.notifier).state =
                                  false;
                              ref
                                  .read(chatTriggeredByBubbleProvider.notifier)
                                  .state = null;
                            }
                          },
                        ),
                      )
                    : _ChatOverlayPlaceholder(
                        bubbleId: chatTriggeredByBubble,
                        onClose: () {
                          // Try animation first, fallback to direct close
                          final callbacks =
                              ref.read(bubbleAnimationCallbackProvider);
                          final callback = callbacks[chatTriggeredByBubble];

                          if (callback != null) {
                            // Trigger reverse animation
                            ref
                                .read(chatClosingAnimationProvider.notifier)
                                .state = chatTriggeredByBubble;
                          } else {
                            // Fallback: close directly
                            ref.read(chatOverlayOpenProvider.notifier).state =
                                false;
                            ref
                                .read(chatTriggeredByBubbleProvider.notifier)
                                .state = null;
                          }
                        },
                      ),
              ),

            // Bottom Navigation
            if (showBottomNav)
              Positioned(
                left: 10,
                right: 80,
                bottom: 20,
                child: SafeArea(
                  top: false,
                  child: BottomNavOverlay(currentFeedType: currentFeedType),
                ),
              ),

            // Floating Buttons - when side bubbles are disabled
            if (!showSideBubbles && showAnyButtons)
              Positioned(
                right: 8,
                bottom: 20,
                child: SafeArea(
                  top: false,
                  child: FloatingButtonsColumn(
                    showProfileBtn: showProfileBtn,
                    showSearchBtn: showSearchBtn,
                    showNotificationsBtn: showNotificationsBtn,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Placeholder chat overlay widget - will be replaced with actual chat implementation
class _ChatOverlayPlaceholder extends StatelessWidget {
  final String bubbleId;
  final VoidCallback onClose;

  const _ChatOverlayPlaceholder({
    required this.bubbleId,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Chat - $bubbleId',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Chat content placeholder
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Chat Window Placeholder',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Triggered by bubble: $bubbleId',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.color
                              ?.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onClose,
                    child: const Text('Close Chat'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget that wraps chat overlay with explosion reveal effect
class _ChatOverlayWithReveal extends StatelessWidget {
  final ({
    bool isActive,
    Offset center,
    double progress,
    String bubbleId,
  }) explosionReveal;
  final Color backgroundColor;
  final Widget child;

  const _ChatOverlayWithReveal({
    required this.explosionReveal,
    required this.backgroundColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Create a circular reveal path
    final revealRadius = explosionReveal.progress * 500.0; // Max reveal radius

    return ClipPath(
      clipper: _CircularRevealClipper(
        center: explosionReveal.center,
        radius: revealRadius,
      ),
      child: child,
    );
  }
}

// Custom clipper for circular reveal effect
class _CircularRevealClipper extends CustomClipper<Path> {
  final Offset center;
  final double radius;

  _CircularRevealClipper({
    required this.center,
    required this.radius,
  });

  @override
  Path getClip(Size size) {
    final path = Path();

    // Create a circular path at the explosion center
    path.addOval(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
    );

    return path;
  }

  @override
  bool shouldReclip(covariant _CircularRevealClipper oldClipper) {
    return oldClipper.center != center || oldClipper.radius != radius;
  }
}
