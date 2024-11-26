import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/utils/enums/bottom_nav_item.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../providers/bottom_nav_bar_provider.dart';

class BottomTabNavigator extends ConsumerWidget {
  const BottomTabNavigator({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(bottomNavProvider);

    void onItemTapped(int index) {
      final selectedItem = BottomNavItem.values[index];
      ref.read(bottomNavProvider.notifier).state = selectedItem;

      // Special handling for profile route
      if (selectedItem == BottomNavItem.profile) {
        final currentUserId = ref.read(authProvider)?.uid;
        if (currentUserId != null) {
          // Use goNamed for named routes with parameters
          context.goNamed(
            bottomNavRoutes[selectedItem]!,
            pathParameters: {'id': currentUserId},
          );
        }
      } else {
        // Regular navigation for other routes
        final routeName = bottomNavRoutes[selectedItem];
        if (routeName != null) {
          context.goNamed(routeName);
        }
      }
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: Card(
        color: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          enableFeedback: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: const Color.fromARGB(255, 226, 62, 87),
          unselectedItemColor: Colors.grey,
          items: BottomNavItem.values.map((item) {
            return BottomNavigationBarItem(
              icon: Icon(bottomNavIcons[item]),
              label: item.name,
              backgroundColor: const Color.fromARGB(255, 226, 62, 87),
            );
          }).toList(),
          currentIndex: BottomNavItem.values.indexOf(currentItem),
          onTap: onItemTapped,
        ),
      ),
    );
  }
}