import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/screens.dart';
import 'package:herdapp/features/auth/view/screens/email_verification_screen.dart';
import 'package:herdapp/features/customization/view/screens/ui_customization_screen.dart';
import 'package:herdapp/features/settings/notifications/view/screens/notification_settings_screen.dart';

import '../../features/auth/view/screens/reset_password_screen.dart';
import '../../features/floating_buttons/views/widgets/global_overlay_manager.dart';
import '../../features/herds/data/models/herd_model.dart';
import '../../features/herds/view/providers/herd_providers.dart';
import '../../features/herds/view/screens/create_herd_screen.dart';
import '../../features/herds/view/screens/edit_herd_screen.dart';
import '../../features/herds/view/screens/herd_screen.dart';
import '../../features/post/data/models/post_media_model.dart';
import '../../features/post/view/screens/edit_post_screen.dart';
import '../../features/post/view/screens/fullscreen_gallery_screen.dart';
import '../../features/user/data/models/user_model.dart';
import '../../features/user/view/widgets/user_list_screen.dart';

final RouteObserver<ModalRoute<void>> routeObserver =
    RouteObserver<ModalRoute<void>>();

final goRouterProvider = Provider<GoRouter>((ref) {
  final user = ref.watch(authProvider);
  final currentFeed = ref.watch(currentFeedProvider);
  // Create a key for the navigator inside ShellRoute
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    observers: [routeObserver],
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final user = ref.read(authProvider);
      final currentPath = state.uri.path;
      final isAuthRoute = [
        '/login',
        '/signup',
        '/emailVerification',
        '/resetPassword',
        '/splash',
      ].contains(currentPath);

      // 1) Not signed in → must go to login/signup
      if (user == null) {
        return isAuthRoute ? null : '/login';
      }

      // 2) Signed in but email *not* verified → force /emailVerification
      if (!user.emailVerified) {
        return (currentPath == '/emailVerification')
            ? null
            : '/emailVerification';
      }
      //    (e.g. redirect "/" → either /publicFeed or /altFeed)
      if (currentPath == '/') {
        return ref.read(currentFeedProvider) == FeedType.alt
            ? '/altFeed'
            : '/publicFeed';
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
        path: '/editHerd',
        name: 'editHerd',
        builder: (context, state) {
          final herd = state.extra as HerdModel;
          return EditHerdScreen(herd: herd);
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
              ref.read(currentHerdIdProvider.notifier).state = null;
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
                      ? postProviderWithPrivacy(
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
                showProfileBtn: true,
                showSearchBtn: true,
                showNotificationsBtn: true,
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
                      ? postProviderWithPrivacy(
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
        showNotificationsBtn: false,
        currentFeedType: feedType, // Pass feed type to highlight correct tab
        child: child,
      ),
    );
  }
}
