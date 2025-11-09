import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/social/notifications/view/notifiers/notification_notifier.dart';

part 'notification_provider.g.dart';

/// Provider for the notification notifier with userId parameter
@riverpod
NotificationNotifier notification(Ref ref, String userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository, userId);
}

/// Provider for notification settings with userId parameter
@riverpod
NotificationSettingsNotifier notificationSettings(Ref ref, String userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationSettingsNotifier(repository, userId);
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
