import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/screens.dart';
import 'package:herdapp/core/barrels/providers.dart';
import '../../features/floating_buttons/views/widgets/global_overlay_manager.dart';
import '../../features/user/data/models/user_model.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);

  // Create a key for the navigator inside ShellRoute
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
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
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SignUpScreen()),
      ),

      // Main Shell Route with Bottom Navigation Bar
      ShellRoute(
        navigatorKey: shellNavigatorKey,
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
        ],
      ),

      // Routes that appear OUTSIDE the shell (will have back button)
      GoRoute(
        path: '/profile/:id',
        name: 'profile',
        parentNavigatorKey: rootNavigatorKey,
        // This is key for proper back navigation
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
            child: GlobalOverlayManager(
              showBottomNav: true,
              showSideBubbles: true,
              child: Scaffold(
                body: SafeArea(
                  child: ProfileScreen(userId: userId),
                ),
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/editProfile',
        name: 'editProfile',
        parentNavigatorKey: rootNavigatorKey, // Use root navigator
        pageBuilder: (context, state) {
          final user = state.extra as UserModel?;
          if (user == null) {
            return const NoTransitionPage(
              child: Scaffold(
                body: Center(
                  child: Text('There was an error'),
                ),
              ),
            );
          }
          return NoTransitionPage(
            child: EditProfileScreen(user: user),
          );
        },
      ),

      GoRoute(
        path: '/post/:id',
        name: 'post',
        parentNavigatorKey: rootNavigatorKey, // Use root navigator
        pageBuilder: (context, state) {
          final postId = state.pathParameters['id']!;
          return MaterialPage(
            key: state.pageKey,
            child: PostScreen(postId: postId),
          );
        },
      ),
    ],
  );
});



class _TabScaffold extends ConsumerWidget {
  final Widget child;

  const _TabScaffold({required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: GlobalOverlayManager(
        showBottomNav: true,
        showSideBubbles: true,
        child: child,
      ),
    );
  }
}