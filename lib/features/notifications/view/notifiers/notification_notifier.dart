import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';
import '../providers/state/notification_state.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final String _userId;

  NotificationNotifier(this._repository, this._userId)
      : super(NotificationState.initial()) {
    debugPrint('🔔 NotificationNotifier initialized for user: $_userId');
    refreshNotifications();
  }

  /// Test cloud function connectivity
  Future<void> testConnection() async {
    try {
      final testResult = await _repository.testCloudFunctionConnectivity();
      debugPrint('🧪 Cloud function test result: $testResult');
    } catch (e) {
      debugPrint('❌ Cloud function test failed: $e');
    }
  }

  /// Refresh notifications using cloud function
  Future<void> refreshNotifications({bool markAsRead = true}) async {
    debugPrint('🔄 Refreshing notifications (markAsRead: $markAsRead)');

    state = NotificationState.initial().copyWith(isLoading: true);

    try {
      // Test connection first in debug mode
      if (kDebugMode) {
        await testConnection();
      }

      final result = await _repository.getNotifications(
        limit: 20,
        markAsRead: markAsRead,
      );

      final notifications = result['notifications'] as List<NotificationModel>;
      final unreadCount = result['unreadCount'] as int;
      final hasMore = result['hasMore'] as bool;
      final lastNotificationId = result['lastNotificationId'] as String?;

      debugPrint(
          '✅ Fetched ${notifications.length} notifications, unread: $unreadCount');

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: hasMore,
        lastNotificationId: lastNotificationId,
        unreadCount: unreadCount,
        error: null,
      );
    } catch (e) {
      debugPrint('❌ Error refreshing notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications: ${e.toString()}',
      );
    }
  }

  /// Load more notifications using cloud function
  Future<void> loadMoreNotifications({bool markAsRead = false}) async {
    if (state.isLoading || !state.hasMore || state.lastNotificationId == null) {
      debugPrint(
          '⏭️ Skipping load more: isLoading=${state.isLoading}, hasMore=${state.hasMore}');
      return;
    }

    debugPrint('📄 Loading more notifications...');
    state = state.copyWith(isLoading: true);

    try {
      final result = await _repository.getNotifications(
        limit: 20,
        lastNotificationId: state.lastNotificationId,
        markAsRead: markAsRead,
      );

      final moreNotifications =
          result['notifications'] as List<NotificationModel>;
      final hasMore = result['hasMore'] as bool;
      final lastNotificationId = result['lastNotificationId'] as String?;

      debugPrint('✅ Loaded ${moreNotifications.length} more notifications');

      final currentNotifications =
          List<NotificationModel>.from(state.notifications);
      currentNotifications.addAll(moreNotifications);

      state = state.copyWith(
        notifications: currentNotifications,
        isLoading: false,
        hasMore: hasMore,
        lastNotificationId: lastNotificationId,
        error: null,
      );
    } catch (e) {
      debugPrint('❌ Error loading more notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more notifications: ${e.toString()}',
      );
    }
  }

  /// Mark specific notification as read using cloud function
  Future<void> markAsRead(String notificationId) async {
    try {
      debugPrint('✅ Marking notification as read: $notificationId');

      // Optimistically update UI first
      final notificationIndex =
          state.notifications.indexWhere((n) => n.id == notificationId);

      if (notificationIndex != -1 &&
          !state.notifications[notificationIndex].isRead) {
        final updatedNotifications =
            List<NotificationModel>.from(state.notifications);
        updatedNotifications[notificationIndex] =
            updatedNotifications[notificationIndex].copyWith(isRead: true);

        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: (state.unreadCount - 1).clamp(0, state.unreadCount),
        );

        debugPrint('🔄 Optimistically updated UI');
      }

      // Make the cloud function call
      final result =
          await _repository.markAsRead(notificationIds: [notificationId]);

      // Update with server response
      state = state.copyWith(
          unreadCount: result['unreadCount'] ?? state.unreadCount);

      debugPrint('✅ Notification marked as read successfully');
    } catch (e) {
      debugPrint('❌ Error marking notification as read: $e');
      // Refresh to get correct state on error
      refreshNotifications(markAsRead: false);
    }
  }

  /// Mark all notifications as read using cloud function
  Future<void> markAllAsRead() async {
    try {
      debugPrint('✅ Marking all notifications as read...');

      // Optimistic UI update
      final updatedNotifications =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );

      // Make the cloud function call
      await _repository.markAsRead(); // No specific IDs = mark all as read

      debugPrint('✅ All notifications marked as read successfully');
    } catch (e) {
      debugPrint('❌ Error marking all notifications as read: $e');
      // Refresh to get correct state on error
      refreshNotifications(markAsRead: false);
    }
  }

  /// Filter notifications by type using cloud function
  Future<void> filterNotifications(NotificationType? type) async {
    debugPrint('🔍 Filtering notifications by type: $type');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getNotifications(
        limit: 20,
        filterType: type,
        markAsRead: false, // Don't auto-mark filtered results as read
      );

      final notifications = result['notifications'] as List<NotificationModel>;
      final hasMore = result['hasMore'] as bool;
      final lastNotificationId = result['lastNotificationId'] as String?;

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: hasMore,
        lastNotificationId: lastNotificationId,
        error: null,
      );

      debugPrint('✅ Filtered notifications loaded: ${notifications.length}');
    } catch (e) {
      debugPrint('❌ Error filtering notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to filter notifications: ${e.toString()}',
      );
    }
  }

  /// Get only unread notifications using cloud function
  Future<void> getUnreadNotifications() async {
    debugPrint('📧 Getting unread notifications...');

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getNotifications(
        limit: 20,
        onlyUnread: true,
        markAsRead: false, // Don't auto-mark when just viewing unread
      );

      final notifications = result['notifications'] as List<NotificationModel>;
      final hasMore = result['hasMore'] as bool;
      final lastNotificationId = result['lastNotificationId'] as String?;

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: hasMore,
        lastNotificationId: lastNotificationId,
        error: null,
      );

      debugPrint('✅ Unread notifications loaded: ${notifications.length}');
    } catch (e) {
      debugPrint('❌ Error getting unread notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to get unread notifications: ${e.toString()}',
      );
    }
  }

  /// Refresh unread count using cloud function
  Future<void> refreshUnreadCount() async {
    try {
      debugPrint('🔢 Refreshing unread count...');

      final unreadCount = await _repository.getUnreadCount();

      state = state.copyWith(unreadCount: unreadCount);
      debugPrint('✅ Unread count updated: $unreadCount');
    } catch (e) {
      debugPrint('❌ Error refreshing unread count: $e');
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      debugPrint('🗑️ Deleting notification: $notificationId');

      // Optimistically remove from UI
      final updatedNotifications =
          state.notifications.where((n) => n.id != notificationId).toList();
      final wasUnread = state.notifications
              .firstWhere((n) => n.id == notificationId)
              .isRead ==
          false;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: wasUnread
            ? (state.unreadCount - 1).clamp(0, state.unreadCount)
            : state.unreadCount,
      );

      // Make the cloud function call
      await _repository.deleteNotification(notificationId);

      debugPrint('✅ Notification deleted successfully');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      // Refresh to get correct state on error
      refreshNotifications(markAsRead: false);
    }
  }

  /// Clear error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Force refresh with error handling
  Future<void> forceRefresh() async {
    debugPrint('🔄 Force refreshing notifications...');
    clearError();
    await refreshNotifications(markAsRead: true);
  }

  /// Reset state (useful for logout)
  void reset() {
    debugPrint('🔄 Resetting notification state');
    state = NotificationState.initial();
  }
}
