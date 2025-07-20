import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/utils/enums/bottom_nav_item.dart';
import '../view/providers/bottom_nav_bar_provider.dart';

/// Route observer that automatically updates bottom navigation state
/// based on the current route. This creates a two-way relationship
/// where the current screen informs the bottom nav which tab should be active.
class BottomNavRouteObserver extends RouteObserver<ModalRoute<void>> {
  final Ref ref;

  BottomNavRouteObserver(this.ref);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _updateBottomNavFromRoute(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute != null) {
      _updateBottomNavFromRoute(previousRoute);
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _updateBottomNavFromRoute(newRoute);
    }
  }

  /// Updates the bottom navigation state based on the current route
  void _updateBottomNavFromRoute(Route route) {
    final routeName = route.settings.name;
    if (routeName != null) {
      final bottomNavItem = _getBottomNavItemFromRoute(routeName);
      if (bottomNavItem != null) {
        // Only update if the bottom nav item is different from current state
        final currentItem = ref.read(bottomNavProvider);
        if (currentItem != bottomNavItem) {
          ref.read(bottomNavProvider.notifier).state = bottomNavItem;
        }
      }
    }
  }

  /// Maps route names to bottom navigation items
  /// Only the three main screens that have bottom nav tabs are mapped
  BottomNavItem? _getBottomNavItemFromRoute(String routeName) {
    switch (routeName) {
      case 'altFeed':
        return BottomNavItem.altFeed;
      case 'publicFeed':
        return BottomNavItem.publicFeed;
      case 'create':
        return BottomNavItem.create;
      default:
        // Return null for routes that don't correspond to bottom nav items
        // This prevents the bottom nav from changing when navigating to
        // other screens like settings, profile, etc.
        return null;
    }
  }
}
