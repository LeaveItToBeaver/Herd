import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/notifications/view/providers/notification_provider.dart';

import '../../../../core/utils/enums/bottom_nav_item.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../feed/providers/feed_type_provider.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../navigation/view/providers/bottom_nav_bar_provider.dart';

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

// Simplified buttons column
class FloatingButtonsColumn extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;

  const FloatingButtonsColumn({
    super.key,
    required this.showProfileBtn,
    required this.showSearchBtn,
    required this.showNotificationsBtn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current feed type for determining profile route
    final currentFeed = ref.watch(currentFeedProvider);
    final notifications =
        ref.watch(notificationStreamProvider(ref.read(authProvider)!.uid));

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
              child: Icon(Icons.person,
                  color: currentFeed == FeedType.alt
                      ? Colors.purpleAccent
                      : Colors.white),
              onPressed: () {
                final navService = ref.read(navigationServiceProvider);
                if (!navService.canNavigate) return;

                HapticFeedback.mediumImpact();
                final currentUser = ref.read(authProvider);
                if (currentUser?.uid != null) {
                  // Navigate to the appropriate profile based on current feed
                  if (currentFeed == FeedType.alt) {
                    context.pushNamed(
                      'altProfile',
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

        // Notifications button
        if (showNotificationsBtn)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton(
              heroTag: "floatingNotificationsBtn",
              backgroundColor: Colors.black,
              mini: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: notifications.hasValue
                  ? Icon(Icons.notifications, color: Colors.purpleAccent)
                  : Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.pushNamed('notifications');
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
              HapticFeedback.mediumImpact();
              context.pushNamed('search');
            },
          ),
      ],
    );
  }
}

final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});

class NavigationService {
  DateTime _lastNavigationTime = DateTime.fromMillisecondsSinceEpoch(0);

  bool get canNavigate {
    final now = DateTime.now();
    if (now.difference(_lastNavigationTime).inMilliseconds > 300) {
      _lastNavigationTime = now;
      return true;
    }
    return false;
  }
}

// Enhanced Bottom Navigation Bar Overlay with subtle shadow
class BottomNavOverlay extends ConsumerWidget {
  final FeedType? currentFeedType;

  const BottomNavOverlay({
    super.key,
    this.currentFeedType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(bottomNavProvider);
    final feedType = currentFeedType ?? ref.watch(currentFeedProvider);
    final currentHerdId = ref.watch(currentHerdIdProvider);
    final isHerdMember = currentHerdId != null
        ? ref.watch(isHerdMemberProvider(currentHerdId)).value ?? false
        : false;

    void onItemTapped(int index) {
      final navService = ref.read(navigationServiceProvider);

      if (!navService.canNavigate) return;

      final selectedItem = BottomNavItem.values[index];
      ref.read(bottomNavProvider.notifier).state = selectedItem;

      HapticFeedback.heavyImpact();

      // Handle create action with context awareness for herds
      if (selectedItem == BottomNavItem.create) {
        // If we're on a herd screen and the user is a member, create a post in that herd
        if (currentHerdId != null && isHerdMember) {
          // Use context.pushNamed with the right parameters
          context.pushNamed(
            'create',
            queryParameters: {'herdId': currentHerdId},
          );
          return;
        } else {
          // Regular create post - explicitly reset any herd context
          ref.read(currentHerdIdProvider.notifier).state = null;
          context.pushNamed('create');
          return;
        }
      }

      // Reset current herd ID when navigating to feeds
      if (selectedItem == BottomNavItem.altFeed ||
          selectedItem == BottomNavItem.publicFeed) {
        ref.read(currentHerdIdProvider.notifier).state = null;
      }

      // For other navigation items, use normal goNamed
      String? routeName = bottomNavRoutes[selectedItem];

      // Override route for Home/Feed based on feed type
      if (selectedItem == BottomNavItem.altFeed && feedType == FeedType.alt) {
        routeName = 'altFeed';
      } else if (selectedItem == BottomNavItem.publicFeed &&
          feedType == FeedType.public) {
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

            // If this is the home icon, apply a special color for alt feed
            if (item == BottomNavItem.altFeed &&
                feedType == FeedType.alt &&
                isSelected) {
              iconColor =
                  Colors.purpleAccent; // Use a different color for alt feed
            }

            // Customize the 'create' icon if we're in a herd context
            if (item == BottomNavItem.create &&
                currentHerdId != null &&
                isHerdMember) {
              iconColor = isSelected ? Colors.green : Colors.grey;
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
                        if (item == BottomNavItem.altFeed &&
                            feedType == FeedType.alt)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.purpleAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        // Add an indicator for herd context on the create button
                        if (item == BottomNavItem.create &&
                            currentHerdId != null &&
                            isHerdMember)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.green,
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
  final bool showNotificationsBtn;

  const SideBubblesOverlay({
    super.key,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
  });

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

    if (showNotificationsBtn) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: Colors.black,
          onTap: () {
            context.pushNamed('notifications');
          },
        ),
      );
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
              if (feedType == FeedType.alt) {
                context.pushNamed(
                  'altProfile',
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

    if (showSearchBtn && showProfileBtn ||
        showNotificationsBtn && showProfileBtn ||
        showSearchBtn && showNotificationsBtn) {
      // Add a spacer between the two buttons
      bubbles.add(const SizedBox(height: 16));
    }

    // Add feed toggle button
    bubbles.add(
      _buildBubble(
        context: context,
        child: feedType == FeedType.alt
            ? const Icon(Icons.public, color: Colors.white, size: 24)
            : const Icon(Icons.groups_outlined, color: Colors.white, size: 24),
        backgroundColor:
            feedType == FeedType.alt ? Colors.purpleAccent : Colors.black,
        onTap: () {
          // Toggle feed type
          final newFeedType =
              feedType == FeedType.alt ? FeedType.public : FeedType.alt;

          ref.read(currentFeedProvider.notifier).state = newFeedType;

          // Navigate to the appropriate feed
          if (newFeedType == FeedType.alt) {
            context.goNamed('altFeed');
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
