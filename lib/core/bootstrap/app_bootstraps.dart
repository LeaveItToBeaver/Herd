import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:herdapp/core/utils/router.dart';
import 'package:herdapp/features/notifications/utils/notification_service.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart';
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

  /// Initialize notifications for authenticated user
  Future<void> initializeNotifications(String userId, WidgetRef ref) async {
    try {
      if (_notificationsInitialized && _currentUserId == userId) {
        debugPrint('🔔 Notifications already initialized for user: $userId');
        return;
      }

      debugPrint('🔔 Initializing notifications for user: $userId');
      _currentUserId = userId;

      final notificationService = ref.read(notificationServiceProvider);

      // Initialize the notification service with the new API
      final success = await notificationService.initialize(
        onNotificationTap: (notification) => _handleNotificationTap(
          notification,
          ref,
        ),
        onForegroundMessage: (data) => _handleForegroundMessage(data, ref),
      );

      if (success) {
        _notificationsInitialized = true;
        debugPrint(
            '✅ Notifications initialized successfully for user: $userId');
      } else {
        debugPrint('⚠️ Notification initialization failed for user: $userId');
      }
    } catch (e) {
      debugPrint('❌ Error initializing notifications: $e');
    }
  }

  /// Handle foreground notification messages
  void _handleForegroundMessage(Map<String, dynamic> data, WidgetRef ref) {
    try {
      debugPrint('📱 Foreground notification received: ${data['title']}');

      // You can show a custom in-app notification here if needed
      // For example, show a snackbar or custom notification widget

      // The notification will also be displayed as a local notification
      // by the NotificationService automatically
    } catch (e) {
      debugPrint('❌ Error handling foreground message: $e');
    }
  }

  /// Clean up notifications (call on logout)
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
  void _handleNotificationTap(NotificationModel notification, WidgetRef ref) {
    try {
      debugPrint('👆 Handling notification tap: ${notification.type}');

      // Get router from your existing provider
      final router = ref.read(goRouterProvider);

      // Try to use the notification path first (new system)
      if (notification.path != null && notification.path!.isNotEmpty) {
        debugPrint('🧭 Navigating to path: ${notification.path}');
        router.push(notification.path!);
        return;
      }

      // Fallback to type-based navigation (legacy)
      _handleLegacyNotificationNavigation(notification, router);
    } catch (e) {
      debugPrint('❌ Error handling notification tap: $e');
      // Fallback: navigate to notifications screen
      final router = ref.read(goRouterProvider);
      router.push('/notifications');
    }
  }

  /// Legacy notification navigation (fallback)
  void _handleLegacyNotificationNavigation(
      NotificationModel notification, router) {
    switch (notification.type) {
      case NotificationType.follow:
        if (notification.senderId.isNotEmpty) {
          router.push('/profile/${notification.senderId}');
        }
        break;

      case NotificationType.newPost:
      case NotificationType.postLike:
      case NotificationType.postMilestone:
        if (notification.postId?.isNotEmpty == true) {
          router
              .push('/post/${notification.postId}?isAlt=${notification.isAlt}');
        }
        break;

      case NotificationType.comment:
        if (notification.postId?.isNotEmpty == true) {
          router.push(
              '/post/${notification.postId}?isAlt=${notification.isAlt}&showComments=true');
        }
        break;

      case NotificationType.commentReply:
        if (notification.commentId?.isNotEmpty == true &&
            notification.postId?.isNotEmpty == true) {
          router.push(
              '/post/${notification.postId}/comment/${notification.commentId}');
        }
        break;

      case NotificationType.connectionRequest:
        router.push('/connections/requests');
        break;

      case NotificationType.connectionAccepted:
        if (notification.senderId.isNotEmpty) {
          router.push('/profile/${notification.senderId}?isAlt=true');
        }
        break;

      default:
        // Default to notifications screen
        router.push('/notifications');
        break;
    }
  }

  /// Test notification functionality (for debugging)
  Future<void> testNotifications(WidgetRef ref) async {
    if (!_notificationsInitialized) {
      debugPrint('⚠️ Notifications not initialized');
      return;
    }

    try {
      debugPrint('🧪 Testing notification functionality...');

      final notificationService = ref.read(notificationServiceProvider);

      // Test if notifications are enabled
      final enabled = await notificationService.areNotificationsEnabled();
      debugPrint('📱 Notifications enabled: $enabled');

      if (!enabled) {
        // Try to request permissions
        final granted = await notificationService.requestPermissions();
        debugPrint('🔔 Permission request result: $granted');
      }

      // Show test notification
      await notificationService.showTestNotification();
      debugPrint('✅ Test notification sent');
    } catch (e) {
      debugPrint('❌ Error testing notifications: $e');
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

  /// Reset notification state (call on user logout)
  void resetNotifications() {
    _notificationsInitialized = false;
    _currentUserId = null;
    debugPrint('🔄 Notification state reset');
  }

  /// Check if notifications are initialized
  bool get areNotificationsInitialized => _notificationsInitialized;

  /// Get current user ID for notifications
  String? get currentNotificationUserId => _currentUserId;

  /// Check if app is fully initialized
  bool get isInitialized => _isInitialized;

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
