import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/utils/enums/bottom_nav_item.dart';

import '../../../../community/herds/view/providers/herd_providers.dart';

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
    final customization = ref.watch(uICustomizationProvider).value;
    final isHerdMember = currentHerdId != null
        ? ref.watch(isHerdMemberProvider(currentHerdId)).value ?? false
        : false;

    // Get custom theme colors or fall back to defaults
    final appTheme = customization?.appTheme;
    final navBackgroundColor = appTheme?.getSurfaceColor() ?? Colors.black;
    final primaryColor =
        appTheme?.getPrimaryColor() ?? Theme.of(context).colorScheme.primary;
    final secondaryColor = appTheme?.getSecondaryColor() ??
        Theme.of(context).colorScheme.secondary;
    final onSurfaceColor = appTheme?.getTextColor() ?? Colors.grey;

    // Apply glassmorphism if enabled
    final enableGlassmorphism = appTheme?.enableGlassmorphism ?? false;
    final enableShadows = appTheme?.enableShadows ?? true;
    final shadowIntensity = appTheme?.shadowIntensity ?? 1.0;

    void onItemTapped(int index) {
      final navService = ref.read(navigationServiceProvider);

      if (!navService.canNavigate) return;

      final selectedItem = BottomNavItem.values[index];
      ref.read(bottomNavProvider.notifier).state = selectedItem;

      HapticFeedback.heavyImpact();

      // Handle create action with context awareness for herds
      if (selectedItem == BottomNavItem.create) {
        if (currentHerdId != null && isHerdMember) {
          context
              .pushNamed('create', queryParameters: {'herdId': currentHerdId});
          return;
        } else {
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

      // Navigation logic
      String? routeName = bottomNavRoutes[selectedItem];

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

    // Restore original floating pill design with custom theme
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: enableGlassmorphism
            ? navBackgroundColor.withValues(alpha: 0.8)
            : navBackgroundColor,
        borderRadius: BorderRadius.circular(30),
        border: enableGlassmorphism
            ? Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 1,
              )
            : null,
        boxShadow: enableShadows
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3 * shadowIntensity),
                  blurRadius: 12 * shadowIntensity,
                  offset: Offset(0, 4 * shadowIntensity),
                ),
                if (enableGlassmorphism)
                  BoxShadow(
                    color: navBackgroundColor.withValues(alpha: 0.1),
                    blurRadius: 16,
                    offset: const Offset(0, -2),
                  ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: enableGlassmorphism
            ? BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children:
                        List.generate(BottomNavItem.values.length, (index) {
                      final item = BottomNavItem.values[index];
                      final isSelected = currentItem == item;

                      // Customize the color based on selection and context
                      Color iconColor = isSelected
                          ? primaryColor
                          : onSurfaceColor.withValues(alpha: 0.6);

                      // Special color for alt feed when selected
                      if (item == BottomNavItem.altFeed &&
                          feedType == FeedType.alt &&
                          isSelected) {
                        iconColor = secondaryColor;
                      }

                      // Special color for create button in herd context
                      if (item == BottomNavItem.create &&
                          currentHerdId != null &&
                          isHerdMember &&
                          isSelected) {
                        iconColor = appTheme?.getSuccessColor() ?? Colors.green;
                      }

                      return Expanded(
                        child: InkWell(
                          onTap: () => onItemTapped(index),
                          child: Container(
                            height: 54,
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  bottomNavIcons[item],
                                  color: iconColor,
                                  size: 24,
                                ),

                                // Feed type indicator for alt feed
                                if (item == BottomNavItem.altFeed &&
                                    feedType == FeedType.alt)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: secondaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),

                                // Herd context indicator for create button
                                if (item == BottomNavItem.create &&
                                    currentHerdId != null &&
                                    isHerdMember)
                                  Positioned(
                                    right: -6,
                                    top: -6,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: appTheme?.getSuccessColor() ??
                                            Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              )
            : Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(30),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(BottomNavItem.values.length, (index) {
                    final item = BottomNavItem.values[index];
                    final isSelected = currentItem == item;

                    // Customize the color based on selection and context
                    Color iconColor = isSelected
                        ? primaryColor
                        : onSurfaceColor.withValues(alpha: 0.6);

                    // Special color for alt feed when selected
                    if (item == BottomNavItem.altFeed &&
                        feedType == FeedType.alt &&
                        isSelected) {
                      iconColor = secondaryColor;
                    }

                    // Special color for create button in herd context
                    if (item == BottomNavItem.create &&
                        currentHerdId != null &&
                        isHerdMember &&
                        isSelected) {
                      iconColor = appTheme?.getSuccessColor() ?? Colors.green;
                    }

                    return Expanded(
                      child: InkWell(
                        onTap: () => onItemTapped(index),
                        child: Container(
                          height: 54,
                          alignment: Alignment.center,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                bottomNavIcons[item],
                                color: iconColor,
                                size: 24,
                              ),

                              // Feed type indicator for alt feed
                              if (item == BottomNavItem.altFeed &&
                                  feedType == FeedType.alt)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: secondaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),

                              // Herd context indicator for create button
                              if (item == BottomNavItem.create &&
                                  currentHerdId != null &&
                                  isHerdMember)
                                Positioned(
                                  right: -6,
                                  top: -6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: appTheme?.getSuccessColor() ??
                                          Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
      ),
    );
  }
}
