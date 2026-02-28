import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/screens.dart';
import 'package:herdapp/features/community/herds/view/providers/herd_data_providers.dart';
import 'package:herdapp/features/content/post/data/models/post_media_model.dart';
import 'package:herdapp/features/content/post/view/screens/edit_post_screen.dart';
import 'package:herdapp/features/content/post/view/screens/fullscreen_gallery_screen.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/e2ee_chat/e2ee_chat_provider.dart';
import 'package:herdapp/features/user/auth/view/screens/email_verification_screen.dart';
import 'package:herdapp/features/ui/customization/view/screens/ui_customization_screen.dart';
import 'package:herdapp/features/community/herds/view/screens/herd_settings_screen.dart';
import 'package:herdapp/features/user/settings/notifications/view/screens/notification_settings_screen.dart';
import 'package:herdapp/features/user/settings/view/screens/data_export_screen.dart';

import '../../features/user/auth/view/screens/reset_password_screen.dart';
import '../../features/social/floating_buttons/views/widgets/global_overlay_manager.dart';
import '../../features/community/herds/data/models/herd_model.dart';
import '../../features/community/herds/view/screens/create_herd_screen.dart';
import '../../features/community/herds/view/screens/edit_herd_screen.dart';
import '../../features/community/herds/view/screens/herd_screen.dart';
import '../../features/community/moderation/view/screens/pinned_post_management_screen.dart';
import '../../features/user/user_profile/data/models/user_model.dart';
import '../../features/user/user_profile/view/widgets/user_list_screen.dart';
import '../../features/ui/navigation/utils/bottom_nav_route_observer.dart';
import '../../features/social/chat_messaging/view/screens/chat_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [
      routeObserver,
      BottomNavRouteObserver(ref), // Add the custom route observer
    ],
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final ready = ref.read(authReadyProvider);
      final currentPath = state.uri.path;
      final isAuthRoute = [
        '/login',
        '/signup',
        '/emailVerification',
        '/resetPassword',
        '/splash',
      ].contains(currentPath);

      // Wait for auth readiness before making any decision.
      if (!ready) {
        if (kDebugMode) {
          debugPrint(
              '⏳ Router redirect deferred (auth not ready). path=$currentPath');
        }
        return null; // Do nothing until first auth event
      }

      if (kDebugMode) {
        debugPrint(
            '🧭 Router evaluating redirect: path=$currentPath user=${user?.uid ?? 'null'}');
      }

      // 1) Not signed in → must go to login/signup
      if (user == null) {
        if (!isAuthRoute) {
          if (kDebugMode) debugPrint('➡️ Redirecting to /login (no user)');
          return '/login';
        }
        // Stay on auth route (login/signup/etc.)
        return null;
      }

      // 2) Signed in but email *not* verified → force /emailVerification
      if (!user.emailVerified) {
        if (currentPath != '/emailVerification') {
          if (kDebugMode) {
            debugPrint('➡️ Redirecting to /emailVerification (unverified)');
          }
          return '/emailVerification';
        }
        return null;
      }
      //    (e.g. redirect "/" → either /publicFeed or /altFeed)
      if (currentPath == '/') {
        final target = ref.read(currentFeedProvider) == FeedType.alt
            ? '/altFeed'
            : '/publicFeed';
        if (kDebugMode) debugPrint('➡️ Root redirect -> $target');
        return target;
      }

      return null; // all other routes permitted
    },
    routes: [
      GoRoute(
        path: '/',
        redirect: (_, __) =>
            '/splash', // This will then be handled by the main redirect function
      ),

      // Authentication routes
      GoRoute(
        path: '/login',
        name: 'login', // Added name for named navigation
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: LoginScreen()),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup', // Added name for named navigation
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SignUpScreen()),
      ),
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: SplashScreen()),
      ),

      GoRoute(
        path: '/emailVerification',
        pageBuilder: (context, state) {
          final email = state.extra != null
              ? (state.extra as Map<String, dynamic>)['email'] as String
              : '';
          return NoTransitionPage(
            child: EmailVerificationScreen(email: email),
          );
        },
      ),

      GoRoute(
        path: '/resetPassword',
        pageBuilder: (context, state) =>
            const NoTransitionPage(child: ResetPasswordScreen()),
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
              showNotificationsBtn: false,
              showChatToggle: false,
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
                showChatToggle: false,
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
        path: '/editHerd',
        name: 'editHerd',
        builder: (context, state) {
          final herd = state.extra as HerdModel;
          return EditHerdScreen(herd: herd);
        },
      ),

      GoRoute(
        path: '/herdSettings',
        name: 'herdSettings',
        builder: (context, state) {
          final herd = state.extra as HerdModel;
          return HerdSettingsScreen(herd: herd);
        },
      ),

      GoRoute(
        path: '/pinnedPosts/:herdId',
        name: 'pinnedPosts',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final herdId = state.pathParameters['herdId']!;
          return NoTransitionPage(
            child: PinnedPostsManagementScreen(herdId: herdId),
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

      GoRoute(
        path: '/notifications',
        name: 'notifications',
        pageBuilder: (context, state) => NoTransitionPage(
          child: Scaffold(
            body: GlobalOverlayManager(
              showBottomNav: true,
              showSideBubbles: false,
              showProfileBtn: true,
              showSearchBtn: true,
              showNotificationsBtn: false,
              showChatToggle: false,
              child: NotificationScreen(),
            ),
          ),
        ),
      ),

      GoRoute(
        path: '/notificationSettings',
        name: 'notificationSettings',
        pageBuilder: (context, state) => NoTransitionPage(
          child: NotificationSettingsScreen(),
        ),
      ),

      // Settings Route
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) {
          return SettingsScreen();
        },
      ),

      // Data Export Route (deep link from notifications)
      GoRoute(
        path: '/settings/data-export',
        name: 'dataExport',
        builder: (context, state) {
          return const DataExportScreen();
        },
      ),

      GoRoute(
        path: '/customization',
        name: 'customization',
        builder: (context, state) => const UICustomizationScreen(),
      ),

      // Comment Thread Route
      GoRoute(
        path: '/commentThread',
        name: 'commentThread',
        parentNavigatorKey: rootNavigatorKey, // Use root navigator
        pageBuilder: (context, state) {
          // Extract all parameters from state.extra
          final commentId = state.extra != null
              ? (state.extra as Map<String, dynamic>)['commentId'] as String
              : '';
          final postId = state.extra != null
              ? (state.extra as Map<String, dynamic>)['postId'] as String
              : '';
          final isAltPost = state.extra != null
              ? (state.extra as Map<String, dynamic>)['isAltPost'] as bool? ??
                  false
              : false;

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
            child: CommentThreadScreen(
              commentId: commentId,
              postId: postId,
              isAltPost: isAltPost,
            ),
          );
        },
      ),

      // Main Shell Route with Bottom Navigation Bar.
      // StatefulShellRoute.indexedStack keeps all branch widget trees alive in
      // memory simultaneously — switching tabs no longer disposes image streams
      // that are still loading.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return _TabScaffold(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/altFeed',
                name: 'altFeed',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: AltFeedScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/publicFeed',
                name: 'publicFeed',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: PublicFeedScreen()),
              ),
            ],
          ),
        ],
      ),

      // Profile: redirect-only route, outside the shell so it uses the root navigator.
      GoRoute(
        path: '/profile',
        name: 'profile',
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final userId = ref.read(authProvider)?.uid;
          if (userId == null) return '/login';
          final feedType = ref.read(currentFeedProvider);
          return feedType == FeedType.alt
              ? '/altProfile/$userId'
              : '/publicProfile/$userId';
        },
      ),

      // Routes that appear OUTSIDE the shell (will have back button)

      GoRoute(
        path: '/create',
        name: 'create',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          // Pass the current feed type to determine post privacy default
          final feedType = ref.read(currentFeedProvider);
          final isAlt = feedType == FeedType.alt;

          // Check if we have a herdId parameter from query parameters
          final herdId = state.uri.queryParameters['herdId'];

          // If coming directly to create and not from a herd screen, ensure herd ID is null
          if (herdId == null) {
            // Force reset the current herd provider
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(currentHerdIdProvider.notifier).clear();
            });
          }

          // Debug the parameter
          if (kDebugMode) {
            print('Create route received herdId: $herdId');
          }

          return NoTransitionPage(
            // Let GoRouter handle the key, or omit entirely
            child: GlobalOverlayManager(
              showBottomNav: true,
              showSideBubbles: false,
              showProfileBtn: true,
              showSearchBtn: false,
              showNotificationsBtn: false,
              showChatToggle: false,
              child: CreatePostScreen(
                isAlt: isAlt,
                herdId: herdId,
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/editPost/:id',
        name: 'editPost',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final postId = state.pathParameters['id']!;
          final isAlt = state.uri.queryParameters['isAlt'] == 'true';

          return NoTransitionPage(
            child: Consumer(
              builder: (context, ref, _) {
                // Use the appropriate provider based on whether it's an alt post
                final postAsync = ref.watch(
                  isAlt
                      ? postWithPrivacyProvider(
                          PostParams(id: postId, isAlt: true))
                      : postProvider(postId),
                );

                return postAsync.when(
                  loading: () => const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, stack) => Scaffold(
                    appBar: AppBar(title: const Text('Edit Post')),
                    body: Center(child: Text('Error: $err')),
                  ),
                  data: (post) {
                    if (post == null) {
                      return Scaffold(
                        appBar: AppBar(title: const Text('Edit Post')),
                        body: const Center(child: Text('Post not found')),
                      );
                    }
                    return EditPostScreen(post: post);
                  },
                );
              },
            ),
          );
        },
      ),

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
                showNotificationsBtn: true,
                showChatToggle: false,
                child: Stack(children: [
                  PublicProfileScreen(userId: userId),
                ]),
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
                showNotificationsBtn: true,
                showChatToggle: false,
                child: Stack(children: [
                  AltProfileScreen(userId: userId),
                ]),
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
          // Check if extra is a Map
          if (state.extra is! Map<String, dynamic>) {
            return NoTransitionPage(
              child: Scaffold(
                body: Center(child: Text('Invalid navigation parameters')),
              ),
            );
          }

          final Map<String, dynamic> extra =
              state.extra as Map<String, dynamic>;

          // Handle case where user might be AsyncValue<UserModel?>
          final userParam = extra['user'];
          final isPublic = extra['isPublic'] as bool? ?? true;
          final isInitialSetup = extra['isInitialSetup'] as bool? ?? false;

          // Check if userParam is a UserModel directly
          if (userParam is UserModel) {
            return NoTransitionPage(
              child: GlobalOverlayManager(
                showBottomNav: false,
                showSideBubbles: false,
                showProfileBtn: false,
                showSearchBtn: false,
                showNotificationsBtn: false,
                showChatToggle: false,
                child: Scaffold(
                  body: SafeArea(
                    child: isPublic
                        ? PublicProfileEditScreen(user: userParam)
                        : AltProfileEditScreen(
                            user: userParam,
                            isInitialSetup: isInitialSetup,
                          ),
                  ),
                ),
              ),
            );
          }

          // If it's an AsyncValue, handle it appropriately
          if (userParam is AsyncValue<UserModel?>) {
            return NoTransitionPage(
              child: GlobalOverlayManager(
                showBottomNav: false,
                showSideBubbles: false,
                showProfileBtn: false,
                showSearchBtn: false,
                showNotificationsBtn: false,
                child: Scaffold(
                  body: SafeArea(
                    child: userParam.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) => Center(child: Text('Error: $err')),
                      data: (user) {
                        if (user == null) {
                          return const Center(child: Text('User not found'));
                        }
                        return isPublic
                            ? PublicProfileEditScreen(user: user)
                            : AltProfileEditScreen(
                                user: user,
                                isInitialSetup: isInitialSetup,
                              );
                      },
                    ),
                  ),
                ),
              ),
            );
          }

          // Fallback for unexpected user param type
          return NoTransitionPage(
            child: Scaffold(
              body: Center(
                  child:
                      Text('Invalid user data type: ${userParam.runtimeType}')),
            ),
          );
        },
      ),

      // Post Route
      GoRoute(
        path: '/post/:id',
        name: 'post',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final postId = state.pathParameters['id']!;
          final isAlt = state.uri.queryParameters['isAlt'] == 'true';

          return NoTransitionPage(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: GlobalOverlayManager(
                showBottomNav: true,
                showSideBubbles: false,
                showProfileBtn: false,
                showSearchBtn: false,
                showNotificationsBtn: false,
                showChatToggle: false,
                child: PostScreen(
                  postId: postId,
                  isAlt: isAlt,
                ),
              ),
            ),
          );
        },
      ),

      GoRoute(
        path: '/gallery/:postId',
        name: 'gallery',
        parentNavigatorKey:
            rootNavigatorKey, // Use root navigator for fullscreen experience
        pageBuilder: (context, state) {
          final postId = state.pathParameters['postId']!;

          // Extract query parameters
          final initialIndex =
              int.tryParse(state.uri.queryParameters['index'] ?? '0') ?? 0;
          final isAlt = state.uri.queryParameters['isAlt'] == 'true';

          // We need to get the media items from the post
          // So we'll have to use a FutureBuilder or Consumer to get the post data
          return MaterialPage(
            key: state.pageKey,
            // Use MaterialPage instead of NoTransitionPage for proper transition
            child: Consumer(
              builder: (context, ref, _) {
                // Use the appropriate provider based on whether it's an alt post
                final postAsync = ref.watch(
                  isAlt
                      ? postWithPrivacyProvider(
                          PostParams(id: postId, isAlt: true))
                      : postProvider(postId),
                );

                return postAsync.when(
                  loading: () => const Scaffold(
                    backgroundColor: Colors.black,
                    body: Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                  ),
                  error: (error, stack) => Scaffold(
                    backgroundColor: Colors.black,
                    appBar: AppBar(
                      backgroundColor: Colors.black,
                      leading: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    body: Center(
                      child: Text(
                        'Error loading gallery: $error',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  data: (post) {
                    if (post == null) {
                      return Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          leading: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        body: const Center(
                          child: Text(
                            'Post not found',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    // Extract the media items from the post
                    List<PostMediaModel> mediaItems = [];

                    // Check for new media items format first
                    if (post.mediaItems.isNotEmpty) {
                      mediaItems = post.mediaItems;
                    }
                    // Fall back to legacy format
                    else if (post.mediaURL != null &&
                        post.mediaURL!.isNotEmpty) {
                      mediaItems.add(PostMediaModel(
                        id: '0',
                        url: post.mediaURL!,
                        thumbnailUrl: post.mediaThumbnailURL,
                        mediaType: post.mediaType ?? 'image',
                      ));
                    }

                    if (mediaItems.isEmpty) {
                      return Scaffold(
                        backgroundColor: Colors.black,
                        appBar: AppBar(
                          backgroundColor: Colors.black,
                          leading: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => context.pop(),
                          ),
                        ),
                        body: const Center(
                          child: Text(
                            'No media found in this post',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }

                    // Return the fullscreen gallery with the media items
                    return FullscreenGalleryScreen(
                      mediaItems: mediaItems,
                      initialIndex:
                          initialIndex < mediaItems.length ? initialIndex : 0,
                      postId: postId,
                    );
                  },
                );
              },
            ),
          );
        },
      ),

      GoRoute(
        path: '/userList',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return UserListScreen(
            userId: extra['userId'] as String,
            listType: extra['listType'] as String,
            title: extra['title'] as String,
          );
        },
      ),

      // Chat Route
      GoRoute(
        path: '/chat',
        name: 'chat',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) {
          final chatId = state.uri.queryParameters['chatId'];

          return NoTransitionPage(
            child: Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              body: GlobalOverlayManager(
                showBottomNav: false,
                showSideBubbles: false,
                showProfileBtn: false,
                showSearchBtn: false,
                showNotificationsBtn: false,
                showChatToggle: false,
                child: ChatScreen(chatId: chatId),
              ),
            ),
          );
        },
      ),
    ],
  );

  // Re-evaluate redirects when auth state changes WITHOUT recreating the router.
  // Using ref.listen instead of ref.watch prevents a new GoRouter instance from
  // being created on every auth event, which would reset the entire nav stack.
  ref.listen(authProvider, (_, __) => router.refresh());
  ref.listen(authReadyProvider, (_, __) => router.refresh());
  ref.onDispose(router.dispose);

  return router;
});

class _TabScaffold extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const _TabScaffold({required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Derive feed type from the active branch: branch 0 = alt, branch 1 = public.
    // This avoids watching currentFeedProvider here, which previously caused the
    // GoRouter to rebuild the entire navigation stack on every tab switch.
    final feedType =
        navigationShell.currentIndex == 0 ? FeedType.alt : FeedType.public;

    // Keep currentFeedProvider in sync so other routes (/create, /profile)
    // know which feed mode the user is currently in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(currentFeedProvider.notifier).state = feedType;
      }
    });

    // Initialize E2EE for authenticated users (non-blocking)
    ref.watch(e2eeStatusProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GlobalOverlayManager(
        showBottomNav: true,
        showSideBubbles: false,
        showProfileBtn: true,
        showSearchBtn: true,
        showNotificationsBtn: false,
        showChatToggle: true,
        showHerdBubbles: feedType == FeedType.alt,
        currentFeedType: feedType,
        child: navigationShell,
      ),
    );
  }
}
