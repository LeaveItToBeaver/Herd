import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/enums/bottom_nav_item.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../feed/providers/feed_type_provider.dart';
import '../../../navigation/view/providers/bottom_nav_bar_provider.dart';

class GlobalOverlayManager extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showSideBubbles;
  final bool showProfileBtn;
  final bool showSearchBtn;
  final FeedType? currentFeedType;

  const GlobalOverlayManager({
    super.key,
    required this.child,
    this.showBottomNav = true,
    this.showSideBubbles = true,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.currentFeedType,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we have any buttons to show
    final bool showAnyButtons = showProfileBtn || showSearchBtn;

    // Simple logic: if any side button is enabled, offset the navbar
    final double navBarRightPadding = showAnyButtons ? 70 : 0;

    // Content padding for side bubbles only
    final double contentRightPadding = showSideBubbles ? 70 : 0;

    // Key change: No bottom padding for content - let content extend under the nav bar
    // We'll stack the navigation on top of content instead

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
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
                ),
              ),

            // Bottom Navigation Bar - stacked on top of content
            if (showBottomNav)
              Positioned(
                left: 0,
                right: navBarRightPadding,
                bottom: 8, // Small margin from bottom edge
                child: BottomNavOverlay(currentFeedType: currentFeedType),
              ),

            // Floating Buttons - stacked in bottom right
            if (!showSideBubbles && showAnyButtons)
              Positioned(
                right: 8,
                bottom: 8,
                child: FloatingButtonsColumn(
                  showProfileBtn: showProfileBtn,
                  showSearchBtn: showSearchBtn,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Simplified buttons column
class FloatingButtonsColumn extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;

  const FloatingButtonsColumn({
    Key? key,
    required this.showProfileBtn,
    required this.showSearchBtn,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current feed type for determining profile route
    final currentFeed = ref.watch(currentFeedProvider);

    final bool bothButtonsVisible = showProfileBtn && showSearchBtn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile button
        if (showProfileBtn)
          Padding(
            padding: EdgeInsets.only(bottom: bothButtonsVisible ? 8.0 : 0.0),
            child: FloatingActionButton(
              heroTag: "floatingProfileBtn",
              backgroundColor: Colors.black,
              mini: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                final currentUser = ref.read(authProvider);
                if (currentUser?.uid != null) {
                  // Navigate to the appropriate profile based on current feed
                  if (currentFeed == FeedType.private) {
                    context.pushNamed(
                      'privateProfile',
                      pathParameters: {'id': currentUser!.uid},
                    );
                  } else {
                    context.pushNamed(
                      'publicProfile',
                      pathParameters: {'id': currentUser!.uid},
                    );
                  }
                } else {
                  context.go("/login");
                }
              },
            ),
          ),

        // Search button
        if (showSearchBtn)
          FloatingActionButton(
            heroTag: "floatingSearchBtn",
            backgroundColor: Colors.black,
            mini: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              context.pushNamed('search');
            },
          ),

      ],
    );
  }
}

// Enhanced Bottom Navigation Bar Overlay with subtle shadow
class BottomNavOverlay extends ConsumerWidget {
  final FeedType? currentFeedType;

  const BottomNavOverlay({
    Key? key,
    this.currentFeedType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(bottomNavProvider);
    final feedType = currentFeedType ?? ref.watch(currentFeedProvider);

    void onItemTapped(int index) {
      final selectedItem = BottomNavItem.values[index];
      ref.read(bottomNavProvider.notifier).state = selectedItem;

      // Get route based on both the selected nav item and current feed type
      String? routeName = bottomNavRoutes[selectedItem];

      // Override route for Home/Feed based on feed type
      if (selectedItem == BottomNavItem.privateFeed && feedType == FeedType.private) {
        routeName = 'privateFeed';
      } else if (selectedItem == BottomNavItem.publicFeed && feedType == FeedType.public) {
        routeName = 'publicFeed';
      }

      if (routeName != null) {
        context.goNamed(routeName);
      }
    }

    // Enhanced container with shadow for better visibility over content
    return Container(
      height: 54,
      margin: const EdgeInsets.fromLTRB(8, 0, 0, 0), // Keep horizontal margin
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(BottomNavItem.values.length, (index) {
            final item = BottomNavItem.values[index];
            final isSelected = currentItem == item;

            // Customize the color based on feed type for the home icon
            Color iconColor = isSelected
                ? const Color.fromARGB(255, 226, 62, 87)
                : Colors.grey;

            // If this is the home icon, apply a special color for private feed
            if (item == BottomNavItem.privateFeed && feedType == FeedType.private && isSelected) {
              iconColor = Colors.blue; // Use a different color for private feed
            }

            return Expanded(
              child: InkWell(
                onTap: () => onItemTapped(index),
                child: Container(
                  height: 54,
                  color: Colors.transparent,
                  child: Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          bottomNavIcons[item],
                          color: iconColor,
                          size: 24,
                        ),
                        // Add an indicator for feed type on the home icon
                        if (item == BottomNavItem.privateFeed && feedType == FeedType.private)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// Side Bubbles Overlay with material widget
class SideBubblesOverlay extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;

  const SideBubblesOverlay({
    Key? key,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current feed type for determining profile route
    final feedType = ref.watch(currentFeedProvider);

    // Generate list of bubbles
    final List<Widget> bubbles = [];

    // Add search button if enabled
    if (showSearchBtn) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: Colors.black,
          onTap: () {
            context.pushNamed('search');
          },
        ),
      );
    }

    if (showSearchBtn && showProfileBtn) {
      // Add a spacer between the two buttons
      bubbles.add(const SizedBox(height: 16));
    }

    // Add profile button if enabled
    if (showProfileBtn) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: Colors.black,
          onTap: () {
            final currentUser = ref.read(authProvider);
            if (currentUser?.uid != null) {
              // Navigate based on current feed type
              if (feedType == FeedType.private) {
                context.pushNamed(
                  'privateProfile',
                  pathParameters: {'id': currentUser!.uid},
                );
              } else {
                context.pushNamed(
                  'publicProfile',
                  pathParameters: {'id': currentUser!.uid},
                );
              }
            } else {
              context.go("/login");
            }
          },
        ),
      );
    }


    // Add feed toggle button
    bubbles.add(
      _buildBubble(
        context: context,
        child: feedType == FeedType.private
            ? const Icon(Icons.lock, color: Colors.white, size: 24)
            : const Icon(Icons.public, color: Colors.white, size: 24),
        backgroundColor: feedType == FeedType.private ? Colors.blue : Colors.black,
        onTap: () {
          // Toggle feed type
          final newFeedType = feedType == FeedType.private
              ? FeedType.public
              : FeedType.private;

          ref.read(currentFeedProvider.notifier).state = newFeedType;

          // Navigate to the appropriate feed
          if (newFeedType == FeedType.private) {
            context.goNamed('privateFeed');
          } else {
            context.goNamed('publicFeed');
          }
        },
      ),
    );

    // Add regular community bubbles
    for (int i = 0; i < 8; i++) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: Text(
            "${i + 1}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          onTap: () {
            // Navigate to community or open chat
          },
        ),
      );
    }

    return Container(
      color: Colors.transparent, // Let the app background show through
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 80, bottom: 0),
                reverse: true, // Build from bottom up
                children: bubbles,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent bubbles with Material and shadow
  Widget _buildBubble({
    required BuildContext context,
    required Widget child,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(30),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 54,
              height: 54,
              alignment: Alignment.center,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}