import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // For DocumentSnapshot
import '../providers/state/notification_state.dart';

const int _notificationsPerPage = 20;

class NotificationNotifier extends StateNotifier<NotificationState> {
  final NotificationRepository _repository;
  final String _userId;

  NotificationNotifier(this._repository, this._userId)
      : super(NotificationState.initial()) {
    refreshNotifications();
  }

  Future<void> refreshNotifications() async {
    state = NotificationState.initial()
        .copyWith(isLoading: true); // Reset and start loading
    try {
      final fetchedNotifications = await _repository.getNotifications(
        userId: _userId,
        limit: _notificationsPerPage,
      );
      final unread = await _repository.getUnreadCount(_userId);

      state = state.copyWith(
        notifications: fetchedNotifications,
        isLoading: false,
        hasMore: fetchedNotifications.length == _notificationsPerPage,
        lastDocument: fetchedNotifications.isNotEmpty
            ? await _repository.getNotificationDocument(
                fetchedNotifications.last.id) // Fetch the actual snapshot
            : null,
        unreadCount: unread ?? 0,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMoreNotifications() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);
    try {
      final moreNotifications = await _repository.getNotifications(
        userId: _userId,
        limit: _notificationsPerPage,
        startAfter: state.lastDocument,
      );

      final currentNotifications =
          List<NotificationModel>.from(state.notifications);
      currentNotifications.addAll(moreNotifications);

      state = state.copyWith(
        notifications: currentNotifications,
        isLoading: false,
        hasMore: moreNotifications.length == _notificationsPerPage,
        lastDocument: moreNotifications.isNotEmpty
            ? await _repository.getNotificationDocument(
                moreNotifications.last.id) // Fetch the actual snapshot
            : state.lastDocument,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      // Optimistically update UI first (optional, but improves perceived performance)
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
          unreadCount: (state.unreadCount - 1)
              .clamp(0, state.unreadCount), // Ensure non-negative
        );
      }

      await _repository.markAsRead(notificationId); // Make the actual call

      // Fetch the latest unread count to ensure accuracy (if optimistic update wasn't perfect or other changes happened)
      final unread = await _repository.getUnreadCount(_userId);
      state = state.copyWith(unreadCount: unread ?? 0);
    } catch (e) {
      print("Error marking notification as read: $e");
      // Potentially re-fetch or show error to user
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistic UI update
    final updatedNotifications =
        state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updatedNotifications, unreadCount: 0);

    try {
      await _repository.markAllAsRead(_userId);
      // The unread count should already be 0 from the optimistic update.
      // final unread = await _repository.getUnreadCount(_userId);
      // state = state.copyWith(unreadCount: unread ?? 0);
    } catch (e) {
      print("Error marking all notifications as read: $e");
      // Potentially revert optimistic update or show error
      refreshNotifications(); // Re-fetch to correct state on error
    }
  }

  // If we need to react to real-time updates from notificationStreamProvider,
  // you can listen to it and update this notifier's state.
  // However, this might be complex to merge with pagination.
  // Often, the stream is used for the badge count and a "new notifications" banner,
  // and the list itself is manually refreshed or paginated.
}
