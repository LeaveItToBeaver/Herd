import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/community/herds/view/widgets/herd_overlay_widget.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/overlay_providers.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/animated_reveal_overlay.dart';

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

                    debugPrint(
                        "🎆 GlobalOverlayManager onClose called for $bubbleId");

                    // Immediately start closing animation by setting explosion reveal to closing state
                    final currentReveal = ref.read(explosionRevealProvider);
                    if (currentReveal != null && currentReveal.isActive) {
                      // Update to closing state immediately for instant response
                      ref.read(explosionRevealProvider.notifier).state = (
                        isActive: true,
                        center: currentReveal.center,
                        progress: currentReveal.progress,
                        bubbleId: currentReveal.bubbleId,
                        isClosing: true, // Switch to closing mode instantly
                      );
                    } else {
                      // No reveal animation, trigger direct close
                      if (activeOverlayType == OverlayType.chat) {
                        ref.read(chatClosingAnimationProvider.notifier).state =
                            bubbleId;
                      } else if (activeOverlayType == OverlayType.herd) {
                        ref.read(herdClosingAnimationProvider.notifier).state =
                            bubbleId;
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

Widget _buildOverlay(
    {required OverlayType overlayType,
    required String? bubbleId,
    required explosionReveal,
    required Color backgroundColor,
    required VoidCallback onClose,
    required WidgetRef ref}) {
  if (bubbleId == null) return const SizedBox.shrink();

  final overlayWidget = overlayType == OverlayType.chat
      ? ChatOverlayWidget(
          bubbleId: bubbleId,
          onClose: onClose, // Pass the callback directly
        )
      : HerdOverlayWidget(
          herdId: bubbleId.replaceFirst('herd_', ''),
          onClose: onClose, // Pass the callback directly
        );

  // ALWAYS use AnimatedRevealOverlay for consistent animation handling
  // Check if we have explosion reveal data OR if this is a triggered overlay
  if (explosionReveal != null && explosionReveal.isActive) {
    final isClosing = explosionReveal.isClosing;
    debugPrint(
        "🎆 Creating AnimatedRevealOverlay for $bubbleId at center: ${explosionReveal.center}, isClosing: $isClosing");

    return AnimatedRevealOverlay(
      explosionCenter: explosionReveal.center,
      backgroundColor: backgroundColor,
      isVisible: !isClosing, // true for opening, false for closing
      isReversed: isClosing,
      duration: const Duration(milliseconds: 800), // Consistent 800ms duration
      onAnimationComplete: () {
        debugPrint(
            "🎆 Reveal animation completed for $bubbleId, isClosing: $isClosing");
        if (isClosing) {
          // Animation finished, now trigger snap back
          final callbacks = ref.read(bubbleAnimationCallbackProvider);
          final snapBackCallback = callbacks['${bubbleId}_snapback'];
          if (snapBackCallback != null) {
            snapBackCallback();
          }
        }
      },
      child: overlayWidget,
    );
  }

  debugPrint("🎆 Using overlay without reveal animation for $bubbleId");
  return overlayWidget;
}
