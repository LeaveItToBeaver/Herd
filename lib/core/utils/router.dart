import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/screens.dart';
import 'package:herdapp/core/barrels/providers.dart';
import '../../features/floating_buttons/views/widgets/global_overlay_manager.dart';
import '../../features/herds/view/screens/create_herd_screen.dart';
import '../../features/herds/view/screens/herd_screen.dart';
import '../../features/user/data/models/user_model.dart';

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
        return currentFeed == FeedType.alt ? '/altFeed' : '/publicFeed';
      }

      // Allow all other navigation
      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) => '/splash',
      ),

      // Authentication routes //
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

      GoRoute(
        path: '/search',
        name: 'search',
        pageBuilder: (context, state) => NoTransitionPage(
          child: Scaffold(
            body: GlobalOverlayManager(
              showBottomNav: true,
              showSideBubbles: false,
              showProfileBtn: true,
              showSearchBtn: false,
              child: SearchScreen(),
            ),
          ),
        ),
      ),

      GoRoute(
        path: '/herd/:id',
        name: 'herd',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final herdId = state.pathParameters['id']!;

          return NoTransitionPage(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: GlobalOverlayManager(
                showBottomNav: true,
                showSideBubbles: false,
                showProfileBtn: true,
                showSearchBtn: true,
                child: HerdScreen(herdId: herdId),
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/createHerd',
        name: 'createHerd',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          return const NoTransitionPage(
            child: CreateHerdScreen(),
          );
        },
      ),

      GoRoute(
        path: '/connection-requests',
        name: 'connectionRequests',
        parentNavigatorKey: rootNavigatorKey, // Use root navigator
        pageBuilder: (context, state) {
          return NoTransitionPage(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: const ConnectionRequestsScreen(),
            ),
          );
        },
      ),

      // Comment Thread Route
      GoRoute(
        path: '/commentThread',
        name: 'commentThread',
        parentNavigatorKey: rootNavigatorKey, // Use root navigator
        pageBuilder: (context, state) {
          final commentId = state.extra != null
              ? (state.extra as Map<String, dynamic>)['commentId'] as String
              : '';
          final postId = state.extra != null
              ? (state.extra as Map<String, dynamic>)['postId'] as String
              : '';

          if (commentId.isEmpty) {
            return const NoTransitionPage(
              child: Scaffold(
                body: Center(
                  child: Text('Comment ID is required'),
                ),
              ),
            );
          }

          return NoTransitionPage(
            child: CommentThreadScreen(commentId: commentId, postId: postId),
          );
        },
      ),

      // Main Shell Route with Bottom Navigation Bar
      ShellRoute(
        navigatorKey: shellNavigatorKey,
        builder: (context, state, child) {
          return _TabScaffold(child: child);
        },

        routes: [
          GoRoute(
            path: '/altFeed',
            name: 'altFeed',
            parentNavigatorKey: shellNavigatorKey,
            pageBuilder: (context, state) {
              // Set current feed to alt when viewing alt feed
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ref.read(currentFeedProvider.notifier).state = FeedType.alt;
              });
              return const NoTransitionPage(
                child: AltFeedScreen(),
              );
            },
          ),

          GoRoute(
            path: '/create',
            name: 'create',
            parentNavigatorKey: shellNavigatorKey,
            pageBuilder: (context, state) {
              // Pass the current feed type to determine post privacy default
              final feedType = ref.read(currentFeedProvider);
              final isAlt = feedType == FeedType.alt;

              // Check if we have a herdId parameter (for creating posts in herds)
              final herdId = state.uri.queryParameters['herdId'];

              // Create a unique key for the page based on the parameters
              // This prevents duplicate key issues in the navigator
              final uniqueKey = ValueKey('create-${herdId ?? 'personal'}-${isAlt ? 'alt' : 'public'}');

              return NoTransitionPage(
                key: uniqueKey,
                child: GlobalOverlayManager(
                  showBottomNav: true,
                  showSideBubbles: false,
                  showProfileBtn: true,
                  showSearchBtn: false,
                  child: Stack(
                    children: [
                      // Pass herdId if provided, otherwise normal create post
                      CreatePostScreen(
                        isAlt: isAlt,
                        herdId: herdId,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          GoRoute(
            path: '/publicFeed',
            name: 'publicFeed',
            parentNavigatorKey: shellNavigatorKey,
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
            parentNavigatorKey: shellNavigatorKey,
            redirect: (context, state) {
              final userId = ref.read(authProvider)?.uid;
              if (userId == null) return '/login';

              // Determine which profile to show based on current feed
              final feedType = ref.read(currentFeedProvider);
              if (feedType == FeedType.alt) {
                return '/altProfile/$userId';
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

      // Alt profile route
      GoRoute(
        path: '/altProfile/:id',
        name: 'altProfile',
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

          // Set feed type to alt when viewing alt profile
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(currentFeedProvider.notifier).state = FeedType.alt;
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
                      AltProfileScreen(userId: userId),
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
                      : AltProfileEditScreen(
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
          // Get isAlt parameter if it exists
          final isAlt = state.uri.queryParameters['isAlt'] == 'true';

          return MaterialPage(
            key: state.pageKey,
            child: PostScreen(
              postId: postId,
              isAlt: isAlt,
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