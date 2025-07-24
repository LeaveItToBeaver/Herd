import 'package:flutter/material.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart' hide SideBubblesOverlay;
import 'package:herdapp/features/social/floating_buttons/views/widgets/side_bubble_overlay_widget.dart'
    show SideBubblesOverlay;

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
    final bool showAnyButtons =
        showProfileBtn || showSearchBtn || showNotificationsBtn;
    const double sideBarWidth = 60.0;
    final double contentRightPadding = showSideBubbles ? sideBarWidth : 0;
    final backgroundColor = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Material(
        type: MaterialType.transparency,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              right: contentRightPadding,
              child: child,
            ),

            // Side Bubbles - positioned to extend full height within safe area
            // This overlay will handle screen-wide dragging for enhanced bubbles
            if (showSideBubbles)
              Positioned(
                right: 0,
                top: 0,
                bottom:
                    20, // Match the bottom nav's bottom position for alignment
                width: sideBarWidth,
                child: Container(
                  color: backgroundColor,
                  child: SafeArea(
                    top: true,
                    left: false,
                    right: false,
                    bottom:
                        false, // Don't apply safe area to bottom for precise alignment
                    child: SideBubblesOverlay(
                      showProfileBtn: showProfileBtn,
                      showSearchBtn: showSearchBtn,
                      showNotificationsBtn: showNotificationsBtn,
                    ),
                  ),
                ),
              ),

            if (showBottomNav)
              Positioned(
                left: 10,
                right: showSideBubbles ? (sideBarWidth + 10) : 10,
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
