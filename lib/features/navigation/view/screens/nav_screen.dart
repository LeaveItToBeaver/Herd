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

      // Regular navigation for routes
      final routeName = bottomNavRoutes[selectedItem];
      if (routeName != null) {
        context.goNamed(routeName);
      }
    }

    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            bottom: 8, // Position above the bottom nav bar
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Profile button
                FloatingActionButton(
                  heroTag: "profileBtn",
                  mini: true,
                  backgroundColor: Colors.black,
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    final currentUserId = ref.read(authProvider)?.uid;
                    if (currentUserId != null) {
                      context.pushNamed(
                        'profile',
                        pathParameters: {'id': currentUserId},
                      );
                    } else {
                      context.go('/login');
                    }
                  },
                ),
                const SizedBox(height: 8),
                // Search button
                FloatingActionButton(
                  heroTag: "searchBtn",
                  mini: true,
                  backgroundColor: Colors.black,
                  child: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    context.goNamed('search');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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