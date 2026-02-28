import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../../core/utils/enums/bottom_nav_item.dart';

part 'bottom_nav_bar_provider.g.dart';

// Provider to manage the current BottomNavItem
@riverpod
class BottomNav extends _$BottomNav {
  @override
  BottomNavItem build() {
    return BottomNavItem.publicFeed; // Default to the feed tab
  }

  void setCurrentTab(BottomNavItem item) {
    state = item;
  }
}
