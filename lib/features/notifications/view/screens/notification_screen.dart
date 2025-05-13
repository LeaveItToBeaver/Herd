import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
    // Load notifications when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshNotifications();
    });
  }

  void _refreshNotifications() {
    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      ref
          .read(notificationProvider(currentUser.uid).notifier)
          .refreshNotifications();
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

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view notifications'),
        ),
      );
    }

    final notificationsState = ref.watch(notificationProvider(currentUser.uid));
    final unreadCount = notificationsState.unreadCount;

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
          _refreshNotifications();
        },
        child: _buildNotificationList(notificationsState),
      ),
    );
  }

  Widget _buildNotificationList(NotificationState state) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.notifications.isEmpty) {
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
                .loadMoreNotifications();
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
              _handleNotificationTap(notification);
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

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read
    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      ref
          .read(notificationProvider(currentUser.uid).notifier)
          .markAsRead(notification.id);
    }

    // Navigate based on notification type
    switch (notification.type) {
      case NotificationType.follow:
        // Navigate to profile
        if (notification.senderId.isNotEmpty) {
          context.pushNamed(
            'publicProfile',
            pathParameters: {'id': notification.senderId},
          );
        }
        break;

      case NotificationType.newPost:
      case NotificationType.postLike:
      case NotificationType.postMilestone:
        // Navigate to post
        if (notification.postId != null && notification.postId!.isNotEmpty) {
          context.pushNamed(
            'post',
            pathParameters: {'id': notification.postId!},
            queryParameters: {'isAlt': notification.isAlt.toString()},
          );
        }
        break;

      case NotificationType.comment:
        // Navigate to post with comments expanded
        if (notification.postId != null && notification.postId!.isNotEmpty) {
          context.pushNamed(
            'post',
            pathParameters: {'id': notification.postId!},
            queryParameters: {
              'isAlt': notification.isAlt.toString(),
              'showComments': 'true',
            },
          );
        }
        break;

      case NotificationType.commentReply:
        // Navigate to comment thread
        if (notification.commentId != null && notification.postId != null) {
          context.push('/commentThread', extra: {
            'commentId': notification.commentId,
            'postId': notification.postId,
            'isAltPost': notification.isAlt,
          });
        }
        break;

      case NotificationType.connectionRequest:
        // Navigate to connection requests screen
        context.pushNamed('connectionRequests');
        break;

      case NotificationType.connectionAccepted:
        // Navigate to alt profile of user who accepted
        if (notification.senderId.isNotEmpty) {
          context.pushNamed(
            'altProfile',
            pathParameters: {'id': notification.senderId},
          );
        }
        break;
    }
  }
}
