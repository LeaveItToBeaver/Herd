import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:herdapp/core/utils/router.dart';
import 'package:herdapp/features/notifications/utils/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bootstrap class for initializing app dependencies
class AppBootstrap {
  static final AppBootstrap _instance = AppBootstrap._internal();
  factory AppBootstrap() => _instance;

  AppBootstrap._internal();

  bool _isInitialized = false;
  bool _isInitializing = false;

  bool _notificationsInitialized = false;
  String? _currentUserId;

  // Future to track initialization status
  Future<void>? _initializationFuture;

  Future<void> initializeNotifications(String userId, WidgetRef ref) async {
    try {
      if (_notificationsInitialized && _currentUserId == userId) {
        debugPrint('Notifications already initialized for user: $userId');
        return;
      }

      debugPrint('Initializing notifications for user: $userId');

      final notificationService = ref.read(notificationServiceProvider);

      await notificationService.initialize(
        userId: userId,
        onNotificationTap: (notification) => _handleNotificationTap(
          notification,
          ref,
        ),
      );
    } catch (e) {
      debugPrint('⚠️ Error initializing notifications: $e');
    }
  }

  Future<void> cleanupNotifications(WidgetRef ref) async {
    try {
      if (_notificationsInitialized) {
        debugPrint('🧹 Cleaning up notifications');

        final notificationService = ref.read(notificationServiceProvider);
        await notificationService.clearAllNotifications();

        _notificationsInitialized = false;
        _currentUserId = null;

        debugPrint('✅ Notifications cleaned up');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up notifications: $e');
    }
  }

  /// Handle notification tap navigation
  void _handleNotificationTap(notification, WidgetRef ref) {
    try {
      debugPrint('👆 Handling notification tap: ${notification.type}');

      // Get router from your existing provider
      final router = ref.read(goRouterProvider);

      // Navigate based on notification type
      switch (notification.type.toString()) {
        case 'NotificationType.follow':
          if (notification.senderId?.isNotEmpty == true) {
            router.push('/profile/${notification.senderId}');
          }
          break;

        case 'NotificationType.newPost':
        case 'NotificationType.postLike':
        case 'NotificationType.postMilestone':
          if (notification.postId?.isNotEmpty == true) {
            router.push(
                '/post/${notification.postId}?isAlt=${notification.isAlt}');
          }
          break;

        case 'NotificationType.comment':
          if (notification.postId?.isNotEmpty == true) {
            router.push(
                '/post/${notification.postId}?isAlt=${notification.isAlt}&showComments=true');
          }
          break;

        case 'NotificationType.commentReply':
          if (notification.commentId?.isNotEmpty == true &&
              notification.postId?.isNotEmpty == true) {
            router.push(
                '/post/${notification.postId}/comment/${notification.commentId}');
          }
          break;

        case 'NotificationType.connectionRequest':
          router.push('/connections/requests');
          break;

        case 'NotificationType.connectionAccepted':
          if (notification.senderId?.isNotEmpty == true) {
            router.push('/profile/${notification.senderId}?isAlt=true');
          }
          break;

        default:
          // Default to notifications screen
          router.push('/notifications');
          break;
      }
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
    }
  }

  /// Initialize all app services and dependencies
  Future<void> initialize() async {
    // Return existing future if already initializing
    if (_isInitializing && _initializationFuture != null) {
      return _initializationFuture!;
    }

    // Skip if already initialized
    if (_isInitialized) return;

    // Set initializing flag and create future
    _isInitializing = true;
    _initializationFuture = _doInitialize();
    return _initializationFuture;
  }

  /// Actual initialization implementation
  Future<void> _doInitialize() async {
    try {
      debugPrint('🚀 Starting app initialization...');

      // Initialize shared preferences
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ Shared preferences initialized');

      // Initialize media cache with better error handling
      try {
        await MediaCacheService().initialize();
        debugPrint('✅ Media cache service initialized');
      } catch (e) {
        debugPrint('⚠️ Media cache initialization error: $e');
        // Continue despite error
      }

      // Initialize cache manager with better error handling
      try {
        final cacheManager = CacheManager();
        await cacheManager.initialize();
        debugPrint('✅ Cache manager initialized');

        // Log cache statistics
        if (kDebugMode) {
          try {
            final cacheStats = await cacheManager.getCacheStats();
            debugPrint('📊 Cache statistics:');
            debugPrint('- Total size: ${cacheStats['totalSizeFormatted']}');
            debugPrint('- Image count: ${cacheStats['imageCount']}');
            debugPrint('- Video count: ${cacheStats['videoCount']}');
            debugPrint('- Thumbnail count: ${cacheStats['thumbnailCount']}');
            debugPrint('- Post count: ${cacheStats['postCount'] ?? 0}');
            debugPrint('- Feed count: ${cacheStats['feedCount'] ?? 0}');
          } catch (e) {
            debugPrint('⚠️ Failed to get cache stats: $e');
          }
        }
      } catch (e) {
        debugPrint('⚠️ Cache manager initialization error: $e');
        // Continue despite error
      }

      _isInitialized = true;
      debugPrint('✅ App initialization complete');
    } catch (e, stackTrace) {
      debugPrint('❌ Error during app initialization: $e');
      debugPrint(stackTrace.toString());
      // Continue without fatal error
    } finally {
      _isInitializing = false;
    }
  }

  /// Force reinitialization (useful after logout or settings change)
  Future<void> reinitialize() async {
    _isInitialized = false;
    _isInitializing = false;
    _initializationFuture = null;

    _notificationsInitialized = false;
    _currentUserId = null;
    return initialize();
  }

  /// Check if notifications are initialized
  bool get areNotificationsInitialized => _notificationsInitialized;

  /// Get current user ID for notifications
  String? get currentNotificationUserId => _currentUserId;

  /// Create a provider for the bootstrap service
  static final appBootstrapProvider = Provider<AppBootstrap>((ref) {
    return AppBootstrap();
  });
}

/// Extension on WidgetRef to easily access bootstrap
extension BootstrapExtension on WidgetRef {
  AppBootstrap get bootstrap => read(AppBootstrap.appBootstrapProvider);
}

/// A widget that ensures the app is bootstrapped
class BootstrapWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const BootstrapWrapper({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<BootstrapWrapper> createState() => _BootstrapWrapperState();
}

class _BootstrapWrapperState extends ConsumerState<BootstrapWrapper> {
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    // Get the initialization future once to avoid rebuilds causing multiple initializations
    _initFuture = ref.read(AppBootstrap.appBootstrapProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        // Show splash screen while initializing
        if (snapshot.connectionState == ConnectionState.waiting) {
          return MaterialApp(
            home: Scaffold(
              backgroundColor: Theme.of(context).primaryColor,
              body: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FlutterLogo(size: 100),
                    SizedBox(height: 32),
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Initializing app...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        // Handle initialization errors
        if (snapshot.hasError) {
          debugPrint('⚠️ Initialization error: ${snapshot.error}');
          // Continue anyway, but log the error
        }

        // Continue with the app regardless of initialization state
        return widget.child;
      },
    );
  }
}
