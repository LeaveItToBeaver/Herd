import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/enums/bottom_nav_item.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../navigation/view/providers/bottom_nav_bar_provider.dart';

class AppContentWrapper extends ConsumerWidget {
  final Widget child;
  final bool includeSideBubbles;
  final bool includeBottomNav;

  const AppContentWrapper({
    Key? key,
    required this.child,
    this.includeSideBubbles = true,
    this.includeBottomNav = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Row(
        children: [
          // Main content area with offset
          Expanded(
            child: child,
          ),

          // Side bubbles column - conditionally included
          if (includeSideBubbles)
            SizedBox(
              width: 70, // Width for the side bubbles column
              child: Column(
                children: [
                  // Header label for the side column (optional)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                  ),

                  // Scrollable bubbles
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemCount: 10, // Number of bubbles (will be dynamic later)
                      reverse: true,
                      itemBuilder: (context, index) {
                        final reversedIndex = 9 - index;

                        // Last bubble is the profile button (black)
                        if (reversedIndex == 8) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              heroTag: "sideProfile",
                              backgroundColor: Colors.black,
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

                        // Second to last bubble is the search button
                        if (reversedIndex == 9) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FloatingActionButton(
                              heroTag: "sideSearch",
                              backgroundColor: Colors.black,
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

                        // Regular community/user bubbles
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: FloatingActionButton(
                            heroTag: "sideBubble$index",
                            backgroundColor: Colors.white,
                            onPressed: () {
                              // Future: Navigate to community or open chat
                            },
                            child: Text(
                              "${index + 1}",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),

      // Bottom navigation - conditionally included
      bottomNavigationBar: includeBottomNav ? _buildBottomNav(context, ref) : null,
    );
  }

  Widget _buildBottomNav(BuildContext context, WidgetRef ref) {
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
      padding: EdgeInsets.only(right: 70),
      child:       Card(
        color: Colors.black,
        margin: EdgeInsets.only(bottom: 8, left: 8, right: 8),
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