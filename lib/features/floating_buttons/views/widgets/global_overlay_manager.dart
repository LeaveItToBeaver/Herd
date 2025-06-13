import 'package:flutter/material.dart';
import 'package:herdapp/features/floating_buttons/views/widgets/bottom_nav_overlay_widget.dart';
import 'package:herdapp/features/floating_buttons/views/widgets/floating_buttons_column_widget.dart';
import 'package:herdapp/features/floating_buttons/views/widgets/side_bubble_overlay_widget.dart';
import '../../../feed/providers/feed_type_provider.dart';

class GlobalOverlayManager extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Determine if we have any buttons to show
    final bool showAnyButtons =
        showProfileBtn || showSearchBtn || showNotificationsBtn;

    // Simple logic: if any side button is enabled, offset the navbar
    final double navBarRightPadding = showAnyButtons ? 70 : 0;

    // Content padding for side bubbles only
    final double contentRightPadding = showSideBubbles ? 70 : 0;

    // Key change: No bottom padding for content - let content extend under the nav bar
    // We'll stack the navigation on top of content instead

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Main content takes full height but respects side bubble width
            Positioned.fill(
              right: contentRightPadding,
              child: child,
            ),

            // Side Bubbles - only when enabled
            if (showSideBubbles)
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 70,
                child: SideBubblesOverlay(
                  showProfileBtn: showProfileBtn,
                  showSearchBtn: showSearchBtn,
                  showNotificationsBtn: showNotificationsBtn,
                ),
              ),

            // Bottom Navigation Bar - stacked on top of content
            if (showBottomNav)
              Positioned(
                left: 0,
                right: navBarRightPadding,
                bottom: 20, // Small margin from bottom edge
                child: BottomNavOverlay(currentFeedType: currentFeedType),
              ),

            // Floating Buttons - stacked in bottom right
            if (!showSideBubbles && showAnyButtons)
              Positioned(
                right: 8,
                bottom: 20,
                child: FloatingButtonsColumn(
                  showProfileBtn: showProfileBtn,
                  showSearchBtn: showSearchBtn,
                  showNotificationsBtn: showNotificationsBtn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
