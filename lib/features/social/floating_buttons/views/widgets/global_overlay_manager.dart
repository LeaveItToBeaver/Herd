import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart' hide SideBubblesOverlay;
import 'package:herdapp/features/social/floating_buttons/views/widgets/side_bubble_overlay_widget.dart';

class GlobalOverlayManager extends ConsumerWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showSideBubbles;
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;
  final FeedType? currentFeedType;

  const GlobalOverlayManager({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.showSideBubbles = true,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
    this.currentFeedType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool showAnyButtons =
        showProfileBtn || showSearchBtn || showNotificationsBtn;

    // Watch the drag state to determine if we should offset content
    final isDragging = ref.watch(isDraggingProvider);

    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main content - no padding needed when side bubbles are screen-specific
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
                ),
              ),

            // Bottom Navigation
            if (showBottomNav)
              Positioned(
                left: 10,
                right: 75,
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
