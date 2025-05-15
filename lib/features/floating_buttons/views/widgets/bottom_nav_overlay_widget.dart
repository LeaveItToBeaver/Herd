import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/floating_buttons/views/providers/navigation_service_provider.dart';

import '../../../../core/utils/enums/bottom_nav_item.dart';
import '../../../feed/providers/feed_type_provider.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../navigation/view/providers/bottom_nav_bar_provider.dart';

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
