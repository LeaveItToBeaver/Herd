// First, let's create a GlobalOverlayManager class to manage the overlays
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/enums/bottom_nav_item.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../navigation/view/providers/bottom_nav_bar_provider.dart';

class GlobalOverlayManager extends StatelessWidget {
  final Widget child;
  final bool showBottomNav;
  final bool showSideBubbles;

  const GlobalOverlayManager({
    Key? key,
    required this.child,
    this.showBottomNav = true,
    this.showSideBubbles = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main content with padding to account for overlays
        Padding(
          padding: EdgeInsets.only(
            right: showSideBubbles ? 70 : 0,
            bottom: showBottomNav ? 65 : 0,
          ),
          child: child,
        ),

        // Bottom Navigation Overlay
        if (showBottomNav)
          const Positioned(
            left: 0,
            right: 70, // Space for side bubbles
            bottom: 0,
            child: BottomNavOverlay(),
          ),

        // Side Bubbles Overlay
        if (showSideBubbles)
          const Positioned(
            right: 0,
            top: 0,
            bottom: 8,
            width: 70,
            child: SideBubblesOverlay(),
          ),
      ],
    );
  }
}

// Bottom Navigation Bar Overlay
class BottomNavOverlay extends ConsumerWidget {
  const BottomNavOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(bottomNavProvider);

    void onItemTapped(int index) {
      final selectedItem = BottomNavItem.values[index];
      ref.read(bottomNavProvider.notifier).state = selectedItem;

      final routeName = bottomNavRoutes[selectedItem];
      if (routeName != null) {
        context.goNamed(routeName);
      }
    }

    return Container(
      child: Card(
        color: Colors.black,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        child: BottomNavigationBar(
          enableFeedback: true,
          backgroundColor: Colors.transparent,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: const Color.fromARGB(255, 226, 62, 87),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
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

// Side Bubbles Overlay
class SideBubblesOverlay extends ConsumerWidget {
  const SideBubblesOverlay({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Generate sample data for bubbles
    // In your real app, this would come from your data source
    final List<Widget> bubbles = List.generate(50, (index) {

      final reversedIndex = 9 - index;
      // Create regular bubbles for all but the last two
      if (reversedIndex < 8) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: FloatingActionButton(
            heroTag: "bubble$index",
            backgroundColor: Colors.white,
            mini: false,
            elevation: 4,
            onPressed: () {
              // Navigate to community or open chat
            },
            child: Text(
              "${index + 1}",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
          ),
        );
      }
      // Search button (second to last)
      else if (reversedIndex == 8) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: FloatingActionButton(
            heroTag: "search",
            backgroundColor: Colors.black,
            mini: false,
            elevation: 4,
            onPressed: () {
              context.pushNamed('search');
            },
            child: const Icon(
              Icons.search,
              color: Colors.white,
            ),
          ),
        );
      }
      // Profile button (last)
      else {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          child: FloatingActionButton(
            heroTag: "profile",
            backgroundColor: Colors.black,
            mini: false,
            elevation: 4,
            onPressed: () {
              final currentUser = ref.read(authProvider);
              if (currentUser?.uid != null) {
                context.pushNamed(
                  'profile',
                  pathParameters: {'id': currentUser!.uid},
                );
              } else {
                context.go("/login");
              }
            },
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
        );
      }
    });

    return Container(
      color: Colors.transparent,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(top: 80), // Add padding at top for status bar
              reverse: true, // Build from bottom up
              children: bubbles,
            ),
          ),
        ],
      ),
    );
  }
}