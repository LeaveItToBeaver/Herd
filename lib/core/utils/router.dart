import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/screens.dart';
import 'package:herdapp/core/barrels/providers.dart';
import '../../features/navigation/view/providers/bottom_nav_bar_provider.dart';
import '../../features/user/data/models/user_model.dart';
import 'enums/bottom_nav_item.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isLoggedIn = user != null;
      final isGoingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup' ||
          state.matchedLocation == '/splash';

      if (kDebugMode) {
        print('Redirect debug:');
        print('- Matched location: ${state.matchedLocation}');
        print('- Is logged in: $isLoggedIn');
        print('- Is going to auth page: $isGoingToAuth');
      }

      // Allow access to auth pages when not logged in
      if (!isLoggedIn) {
        // If on auth page, allow it
        if (isGoingToAuth) {
          return null;
        }
        // If trying to access protected routes, redirect to login
        return '/login';
      }

      // If logged in and on auth page, redirect to profile
      if (isLoggedIn && isGoingToAuth) {
        return '/publicFeed';
      }

      // Allow all other navigation
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => const NoTransitionPage(child: SignUpScreen()),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return _TabScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/search',
            name: 'search',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SearchScreen(),
            ),
          ),
          GoRoute(
            path: '/privateFeed',
            name: 'privateFeed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PrivateFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/create',
            name: 'create',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreatePostScreen(),
            ),
          ),
          GoRoute(
            path: '/publicFeed',
            name: 'publicFeed',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PublicFeedScreen(),
            ),
          ),
          GoRoute(
            path: '/profile/:id',
            name: 'profile',
            pageBuilder: (context, state) {
              // Get current user ID from auth
              final currentUserId = ref.read(authProvider)?.uid;

              // Get profile ID from route params
              final profileId = state.pathParameters['id'];

              // Use profile ID from params or fallback to current user
              final userId = profileId ?? currentUserId;

              // If both are null, redirect to login or show error
              if (userId == null) {
                return const NoTransitionPage(
                  child: Scaffold(
                    body: Center(
                      child: Text('User not found'),
                    ),
                  ),
                );
              }

              return NoTransitionPage(
                child: ProfileScreen(userId: userId),
              );
            },
          ),
          GoRoute(
            path: '/editProfile',
            name: 'editProfile',
            pageBuilder: (context, state) {
              final user = state.extra as UserModel?;
              if (user == null) {
                return const NoTransitionPage(
                  child: Text('There was an error'),
                );
              }
              return NoTransitionPage(
                child: EditProfileScreen(user: user),
              );
            },
          ),
          GoRoute(
            path: '/post/:id',
            builder: (context, state) {
              final postId = state.pathParameters['id']!;
              return PostScreen(postId: postId);
            },
            pageBuilder: (context, state) {
              final postId = state.pathParameters['id']!;
              return MaterialPage(
                key: state.pageKey,
                child: PostScreen(postId: postId),
              );
            },
          ),

        ],
      ),
    ],
  );
});


class _TabScaffold extends ConsumerWidget {
  final Widget child;

  const _TabScaffold({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentItem = ref.watch(bottomNavProvider);

    void onItemTapped(int index) async {
      final selectedItem = BottomNavItem.values[index];
      ref.read(bottomNavProvider.notifier).state = selectedItem;

      if (selectedItem == BottomNavItem.profile) {
        // Get the current user ID for profile navigation
        final currentUser = ref.read(authProvider);
        if (currentUser?.uid != null) {
          context.goNamed(
            'profile',
            pathParameters: {'id': currentUser!.uid},
          );
        } else {
          // Handle the case where we don't have a user ID
          if (kDebugMode) {
            print('No user ID available for profile navigation');
          }
          // Optionally show an error message or redirect
          context.go('/login');
        }
      } else {
        // Regular navigation for other items
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