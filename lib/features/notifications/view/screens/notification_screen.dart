import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/utils/router.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/notifications/view/providers/notification_provider.dart';
import 'package:herdapp/features/notifications/view/providers/state/notification_state.dart';
import 'package:herdapp/features/notifications/view/widgets/notification_item_list.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen> {
  bool _isMarkingAllAsRead = false;

  @override
  void initState() {
    super.initState();
    // Load notifications when screen is opened (with auto-read)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  void _refreshNotifications() {
    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      ref
          .read(notificationProvider(currentUser.uid).notifier)
          .refreshNotifications(markAsRead: true); // Auto-mark as read
    }
  }

  Future<void> _markAllAsRead() async {
    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      setState(() {
        _isMarkingAllAsRead = true;
      });

      try {
        await ref
            .read(notificationProvider(currentUser.uid).notifier)
            .markAllAsRead();
      } finally {
        if (mounted) {
          setState(() {
            _isMarkingAllAsRead = false;
          });
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: _refreshNotifications,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_circle, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('Please sign in to view notifications'),
            ],
          ),
        ),
      );
    }

    final notificationsState = ref.watch(notificationProvider(currentUser.uid));
    final unreadCount = notificationsState.unreadCount;

    // Show error if present
    if (notificationsState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showErrorSnackBar(notificationsState.error!);
        ref.read(notificationProvider(currentUser.uid).notifier).clearError();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications ${unreadCount > 0 ? "($unreadCount)" : ""}'),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: _isMarkingAllAsRead
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.done_all),
              onPressed: _isMarkingAllAsRead ? null : _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(notificationProvider(currentUser.uid).notifier)
                  .forceRefresh();
            },
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/notificationSettings');
            },
            tooltip: 'Notification settings',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(notificationProvider(currentUser.uid).notifier)
              .forceRefresh();
        },
        child: _buildNotificationList(notificationsState),
      ),
    );
  }

  Widget _buildNotificationList(NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading notifications...'),
          ],
        ),
      );
    }

    if (state.notifications.isEmpty && state.error == null) {
      return ListView(
        // Need to wrap in ListView for RefreshIndicator to work
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No notifications yet',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 8),
                Text(
                  'When you get notifications, they\'ll appear here',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (state.error != null && state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 80),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to load notifications',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _refreshNotifications,
                  child: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (scrollInfo.metrics.pixels >
                scrollInfo.metrics.maxScrollExtent - 200 &&
            !state.isLoading &&
            state.hasMore) {
          final currentUser = ref.read(authProvider);
          if (currentUser != null) {
            ref
                .read(notificationProvider(currentUser.uid).notifier)
                .loadMoreNotifications(
                    markAsRead: false); // Don't auto-mark pagination as read
          }
        }
        return false;
      },
      child: ListView.builder(
        itemCount: state.notifications.length +
            (state.isLoading && state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          final notification = state.notifications[index];
          return NotificationListItem(
            notification: notification,
            onTap: (notification) {
              _handleNotificationTap(notification, ref);
            },
            onMarkAsRead: (notificationId) {
              final currentUser = ref.read(authProvider);
              if (currentUser != null) {
                ref
                    .read(notificationProvider(currentUser.uid).notifier)
                    .markAsRead(notificationId);
              }
            },
          );
        },
      ),
    );
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

        // Special handling for commentThread which needs extra data
        if (notification.path!.contains('/commentThread')) {
          router.push('/commentThread', extra: {
            'commentId': notification.commentId ?? '',
            'postId': notification.postId ?? '',
            'isAltPost': notification.isAlt,
          });
          return;
        }

        // Regular path navigation
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
          // Default to public profile for follow notifications
          router.push('/publicProfile/${notification.senderId}');
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
          router.push('/commentThread', extra: {
            'commentId': notification.commentId,
            'postId': notification.postId,
            'isAltPost': notification.isAlt,
          });
        }
        break;

      case NotificationType.connectionRequest:
        router.push('/connection-requests');
        break;

      case NotificationType.connectionAccepted:
        if (notification.senderId.isNotEmpty) {
          router.push('/altProfile/${notification.senderId}');
        }
        break;

      default:
        // Default to notifications screen
        router.push('/notifications');
        break;
    }
  }
}
