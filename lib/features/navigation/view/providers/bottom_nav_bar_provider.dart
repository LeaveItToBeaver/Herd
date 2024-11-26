import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/utils/enums/bottom_nav_item.dart';

// Provider to manage the current BottomNavItem
final bottomNavProvider = StateProvider<BottomNavItem>((ref) {
  return BottomNavItem.publicFeed; // Default to the feed tab
});
