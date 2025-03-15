import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/screens.dart';
import 'package:herdapp/core/barrels/providers.dart';
import '../../features/edit_user/private_profile/view/screens/edit_private_profile_screen.dart';
import '../../features/edit_user/public_profile/view/screens/edit_public_profile_screen.dart';
import '../../features/feed/providers/feed_type_provider.dart';
import '../../features/floating_buttons/views/widgets/global_overlay_manager.dart';
import '../../features/user/data/models/user_model.dart';
import '../../features/user/view/screens/private_profile_screen.dart';
import '../../features/user/view/screens/public_profile_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);
  final currentFeed = ref.watch(currentFeedProvider);

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
        print('- Current feed type: $currentFeed');
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

      if (isLoggedIn && isGoingToAuth) {
        return currentFeed == FeedType.private ? '/privateFeed' : '/publicFeed';
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
            pageBuilder: (context, state) {
              // Set current feed to private when viewing private feed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(currentFeedProvider.notifier).state = FeedType.private;
              });
              return const NoTransitionPage(
                child: PrivateFeedScreen(),
              );
            },
          ),
          GoRoute(
            path: '/create',
            name: 'create',
            pageBuilder: (context, state) {
              // Pass the current feed type to determine post privacy default
              final feedType = ref.read(currentFeedProvider);
              final isPrivate = feedType == FeedType.private;

              return NoTransitionPage(
                child: GlobalOverlayManager(
                  showBottomNav: true,
                  showSideBubbles: false,
                  showProfileBtn: true,
                  showSearchBtn: false,
                  child: Scaffold(
                    body: SafeArea(
                      child: CreatePostScreen(isPrivate: isPrivate),
                    ),
                  ),
                ),
              );
            },
          ),
          GoRoute(
            path: '/publicFeed',
            name: 'publicFeed',
            pageBuilder: (context, state) {
              // Set current feed to public when viewing public feed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(currentFeedProvider.notifier).state = FeedType.public;
              });
              return const NoTransitionPage(
                child: PublicFeedScreen(),
              );
            },
          ),
          // Context-aware profile navigation that redirects based on current feed type
          GoRoute(
            path: '/profile',
            name: 'profile',
            redirect: (context, state) {
              final userId = ref.read(authProvider)?.uid;
              if (userId == null) return '/login';

              // Determine which profile to show based on current feed
              final feedType = ref.read(currentFeedProvider);
              if (feedType == FeedType.private) {
                return '/privateProfile/$userId';
              } else {
                return '/publicProfile/$userId';
              }
            },
          ),
        ],
      ),

      // Routes that appear OUTSIDE the shell (will have back button)
      // Public Profile Route
      GoRoute(
        path: '/publicProfile/:id',
        name: 'publicProfile',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final currentUserId = ref.read(authProvider)?.uid;
          final profileId = state.pathParameters['id'];
          final userId = profileId ?? currentUserId;

          if (userId == null) {
            return const NoTransitionPage(
              child: Scaffold(
                body: Center(
                  child: Text('User not found'),
                ),
              ),
            );
          }

          // Set feed type to public when viewing public profile
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentFeedProvider.notifier).state = FeedType.public;
          });

          return NoTransitionPage(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: GlobalOverlayManager(
                showBottomNav: true,
                showSideBubbles: false,
                showProfileBtn: false,
                showSearchBtn: true,
                child: Stack(
                    children: [
                      PublicProfileScreen(userId: userId),
                    ]
                ),
              ),
            ),
          );
        },
      ),

      // Private profile route
      GoRoute(
        path: '/privateProfile/:id',
        name: 'privateProfile',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final currentUserId = ref.read(authProvider)?.uid;
          final profileId = state.pathParameters['id'];
          final userId = profileId ?? currentUserId;

          if (userId == null) {
            return const NoTransitionPage(
              child: Scaffold(
                body: Center(
                  child: Text('User not found'),
                ),
              ),
            );
          }

          // Set feed type to private when viewing private profile
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentFeedProvider.notifier).state = FeedType.private;
          });

          return NoTransitionPage(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: GlobalOverlayManager(
                showBottomNav: true,
                showSideBubbles: false,
                showProfileBtn: false,
                showSearchBtn: true,
                child: Stack(
                    children: [
                      PrivateProfileScreen(userId: userId),
                    ]
                ),
              ),
            ),
          );
        },
      ),

      // Edit Profile Routes
      GoRoute(
        path: '/editProfile',
        name: 'editProfile',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final Map<String, dynamic> extra = state.extra as Map<String, dynamic>;
          final user = extra['user'] as UserModel;
          final isPublic = extra['isPublic'] as bool;
          final isInitialSetup = extra['isInitialSetup'] as bool? ?? false;

          return NoTransitionPage(
            child: GlobalOverlayManager(
              showBottomNav: false, // Hide bottom nav for edit screens
              showSideBubbles: false,
              showProfileBtn: false,
              showSearchBtn: false,
              child: Scaffold(
                body: SafeArea(
                  child: isPublic
                      ? PublicProfileEditScreen(user: user)
                      : PrivateProfileEditScreen(
                    user: user,
                    isInitialSetup: isInitialSetup,
                  ),
                ),
              ),
            ),
          );
        },
      ),

      // Post Route
      GoRoute(
        path: '/post/:id',
        name: 'post',
        parentNavigatorKey: rootNavigatorKey, // Use root navigator
        pageBuilder: (context, state) {
          final postId = state.pathParameters['id']!;
          // Get isPrivate parameter if it exists
          final isPrivate = state.uri.queryParameters['isPrivate'] == 'true';

          return MaterialPage(
            key: state.pageKey,
            child: PostScreen(
              postId: postId,
              isPrivate: isPrivate,
            ),
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
    // Get current feed type to highlight the active tab
    final feedType = ref.watch(currentFeedProvider);

    return Scaffold(
      body: GlobalOverlayManager(
        showBottomNav: true,
        showSideBubbles: false,
        showProfileBtn: true,
        showSearchBtn: true,
        currentFeedType: feedType, // Pass feed type to highlight correct tab
        child: child,
      ),
    );
  }
}