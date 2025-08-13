import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';

class GlobalOverlayManager extends ConsumerWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showChatToggle;
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
    this.showChatToggle = true,
    this.showSideBubbles = true,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
    this.showHerdBubbles = false,
    this.currentFeedType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChatEnabled = ref.watch(chatBubblesEnabledProvider);

    final bool showAnyButtons = showProfileBtn ||
        showSearchBtn ||
        showNotificationsBtn ||
        showChatToggle; // Chat toggle should be shown regardless of enabled state

    // Watch the drag state to determine if we should offset content
    final isDragging = ref.watch(isDraggingProvider);
    final isChatOverlayOpen = ref.watch(chatOverlayOpenProvider);
    final chatTriggeredByBubble = ref.watch(chatTriggeredByBubbleProvider);
    final explosionReveal = ref.watch(explosionRevealProvider);

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;
    double navBarPositionRight = 10;

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
                child: Builder(
                  builder: (context) {
                    // Create completely keyboard-independent MediaQuery
                    final originalMediaQuery = MediaQuery.of(context);
                    final keyboardFreeMediaQuery = originalMediaQuery.copyWith(
                      viewInsets: EdgeInsets.zero,
                      size: Size(
                          originalMediaQuery.size.width,
                          originalMediaQuery.size.height +
                              originalMediaQuery.viewInsets.bottom),
                    );

                    return MediaQuery(
                      data: keyboardFreeMediaQuery,
                      child: SideBubblesOverlay(
                        showProfileBtn: showProfileBtn,
                        showSearchBtn: showSearchBtn,
                        showNotificationsBtn: showNotificationsBtn,
                        showHerdBubbles: showHerdBubbles,
                      ),
                    );
                  },
                ),
              ),

            // Bottom Navigation - positioned before chat overlay so chat appears on top
            if (showBottomNav)
              Positioned(
                left: 10,
                right: showAnyButtons ? 70 : 10,
                bottom: 20,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true, // Ignore keyboard padding
                  child: SafeArea(
                    top: false,
                    child: BottomNavOverlay(currentFeedType: currentFeedType),
                  ),
                ),
              ),

            // Chat Overlay - positioned after bottom nav to be on top of it
            if (isChatOverlayOpen && chatTriggeredByBubble != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0, // Full height, will render on top of bottom nav
                right: 70, // Leave space for side bubbles
                child: explosionReveal != null && explosionReveal.isActive
                    ? _ChatOverlayWithReveal(
                        explosionReveal: explosionReveal,
                        backgroundColor: backgroundColor,
                        child: ChatOverlayWidget(
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
                    : ChatOverlayWidget(
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

            // Floating Buttons - when side bubbles are disabled
            if (!showSideBubbles && showAnyButtons)
              Positioned(
                right: 8,
                bottom: 20,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true, // Ignore keyboard padding
                  child: SafeArea(
                    top: false,
                    child: FloatingButtonsColumn(
                      showProfileBtn: showProfileBtn,
                      showSearchBtn: showSearchBtn,
                      showNotificationsBtn: showNotificationsBtn,
                      showChatToggle:
                          showChatToggle, // Pass the parameter directly
                    ),
                  ),
                ),
              ),
          ],
        ),
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
