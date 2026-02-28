import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/social/notifications/view/providers/state/notification_state.dart';
part 'notification_provider.g.dart';

/// Class-based notifier for notifications with proper Riverpod state management.
/// Setting [state] automatically triggers UI rebuilds.
@riverpod
class Notification extends _$Notification {
  late final NotificationRepository _repository;

  @override
  NotificationState build(String userId) {
    _repository = ref.watch(notificationRepositoryProvider);
    // Kick off initial fetch; UI starts in loading state
    Future.microtask(() => refreshNotifications());
    return NotificationState.initial().copyWith(isLoading: true);
  }

  /// Refresh notifications using cloud function
  Future<void> refreshNotifications({bool markAsRead = true}) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _repository.getNotifications(
        limit: 20,
        markAsRead: markAsRead,
      );

      final notifications = result['notifications'] as List<NotificationModel>;
      final unreadCount = result['unreadCount'] as int;
      final hasMore = result['hasMore'] as bool;
      final lastNotificationId = result['lastNotificationId'] as String?;

      state = state.copyWith(
        notifications: notifications,
        isLoading: false,
        hasMore: hasMore,
        lastNotificationId: lastNotificationId,
        unreadCount: unreadCount,
        error: null,
      );
    } catch (e) {
      debugPrint('Error refreshing notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load notifications: ${e.toString()}',
      );
    }
  }

  /// Load more notifications (pagination)
  Future<void> loadMoreNotifications({bool markAsRead = false}) async {
    if (state.isLoading || !state.hasMore || state.lastNotificationId == null) {
      return;
    }

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
      debugPrint('Error loading more notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load more notifications: ${e.toString()}',
      );
    }
  }

  /// Mark specific notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      // Optimistic UI update
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
      }

      final result =
          await _repository.markAsRead(notificationIds: [notificationId]);
      state = state.copyWith(
          unreadCount: result['unreadCount'] ?? state.unreadCount);
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      refreshNotifications(markAsRead: false);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final updatedNotifications =
          state.notifications.map((n) => n.copyWith(isRead: true)).toList();
      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
      await _repository.markAsRead();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      refreshNotifications(markAsRead: false);
    }
  }

  /// Filter notifications by type
  Future<void> filterNotifications(NotificationType? type) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _repository.getNotifications(
        limit: 20,
        filterType: type,
        markAsRead: false,
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
    } catch (e) {
      debugPrint('Error filtering notifications: $e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to filter notifications: ${e.toString()}',
      );
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
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

      await _repository.deleteNotification(notificationId);
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      refreshNotifications(markAsRead: false);
    }
  }

  /// Clear error state
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Force refresh
  Future<void> forceRefresh() async {
    clearError();
    await refreshNotifications(markAsRead: true);
  }
}

/// Stream provider for real-time notifications
@riverpod
Stream<List<NotificationModel>> notificationStream(Ref ref, String userId) {
  // Return an empty stream for now
  return Stream.value(<NotificationModel>[]);
}

/// Provider for unread notification count
@riverpod
Future<int> unreadNotificationCount(Ref ref, String userId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final count = await repository.getUnreadCount();
  return count;
}
