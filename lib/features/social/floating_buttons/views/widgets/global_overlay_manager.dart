import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/community/herds/view/widgets/herd_overlay_widget.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/overlay_providers.dart';

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
    final isHerdOverlayOpen = ref.watch(herdOverlayOpenProvider);
    final activeOverlayType = ref.watch(activeOverlayTypeProvider);
    final chatTriggeredByBubble = ref.watch(chatTriggeredByBubbleProvider);
    final herdTriggeredByBubble = ref.watch(herdTriggeredByBubbleProvider);
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

            if (activeOverlayType != null)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                right: 70,
                child: _buildOverlay(
                  overlayType: activeOverlayType,
                  bubbleId: activeOverlayType == OverlayType.chat
                      ? chatTriggeredByBubble
                      : herdTriggeredByBubble,
                  explosionReveal: explosionReveal,
                  backgroundColor: backgroundColor,
                  ref: ref,
                  onClose: () {
                    final bubbleId = activeOverlayType == OverlayType.chat
                        ? chatTriggeredByBubble
                        : herdTriggeredByBubble;

                    // Handle close for appropriate overlay type
                    if (activeOverlayType == OverlayType.chat) {
                      final callbacks =
                          ref.read(bubbleAnimationCallbackProvider);
                      final callback = callbacks[bubbleId];

                      if (callback != null) {
                        ref.read(chatClosingAnimationProvider.notifier).state =
                            bubbleId;
                      } else {
                        ref.read(chatOverlayOpenProvider.notifier).state =
                            false;
                        ref.read(chatTriggeredByBubbleProvider.notifier).state =
                            null;
                        ref.read(activeOverlayTypeProvider.notifier).state =
                            null;
                      }
                    } else if (activeOverlayType == OverlayType.herd) {
                      final callbacks =
                          ref.read(bubbleAnimationCallbackProvider);
                      final callback = callbacks[bubbleId];

                      if (callback != null) {
                        ref.read(herdClosingAnimationProvider.notifier).state =
                            bubbleId;
                      } else {
                        ref.read(herdOverlayOpenProvider.notifier).state =
                            false;
                        ref.read(herdTriggeredByBubbleProvider.notifier).state =
                            null;
                        ref.read(activeOverlayTypeProvider.notifier).state =
                            null;
                      }
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
    final revealRadius = explosionReveal.progress * 1000.0; // Max reveal radius

    return ClipPath(
      clipper: _CircularRevealClipper(
        center: explosionReveal.center,
        radius: revealRadius,
      ),
      child: child,
    );
  }
}

Widget _buildOverlay(
    {required OverlayType overlayType,
    required String? bubbleId,
    required explosionReveal,
    required Color backgroundColor,
    required VoidCallback onClose,
    required WidgetRef ref}) {
  if (bubbleId == null) return const SizedBox.shrink();

  // final overlayWidget = overlayType == OverlayType.chat
  //     ? ChatOverlayWidget(bubbleId: bubbleId, onClose: onClose)
  //     : HerdOverlayWidget(
  //         herdId: bubbleId.replaceFirst('herd_', ''), onClose: onClose);

  final overlayWidget = overlayType == OverlayType.chat
      ? ChatOverlayWidget(
          bubbleId: bubbleId,
          onClose: () {
            // Use specific animation provider for chat
            final callbacks = ref.read(bubbleAnimationCallbackProvider);
            final callback = callbacks[bubbleId];

            if (callback != null) {
              ref.read(chatClosingAnimationProvider.notifier).state = bubbleId;
            } else {
              ref.read(chatOverlayOpenProvider.notifier).state = false;
              ref.read(chatTriggeredByBubbleProvider.notifier).state = null;
              ref.read(activeOverlayTypeProvider.notifier).state = null;
            }
          },
        )
      : HerdOverlayWidget(
          herdId: bubbleId.replaceFirst('herd_', ''),
          onClose: () {
            // Use specific animation provider for herd
            final callbacks = ref.read(bubbleAnimationCallbackProvider);
            final callback = callbacks[bubbleId];

            if (callback != null) {
              ref.read(herdClosingAnimationProvider.notifier).state = bubbleId;
            } else {
              ref.read(herdOverlayOpenProvider.notifier).state = false;
              ref.read(herdTriggeredByBubbleProvider.notifier).state = null;
              ref.read(activeOverlayTypeProvider.notifier).state = null;
            }
          },
        );

  if (explosionReveal != null && explosionReveal.isActive) {
    return _ChatOverlayWithReveal(
      explosionReveal: explosionReveal,
      backgroundColor: backgroundColor,
      child: overlayWidget,
    );
  }

  return overlayWidget;
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
