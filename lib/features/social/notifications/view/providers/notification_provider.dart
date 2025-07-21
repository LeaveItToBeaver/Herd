import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart'; // For stream
import 'package:herdapp/features/social/notifications/data/models/notification_settings_model.dart';
import 'package:herdapp/features/social/notifications/view/notifiers/notification_notifier.dart';

// final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
//   return NotificationRepository();
// });

final notificationProvider = StateNotifierProvider.family<NotificationNotifier,
    NotificationState, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository, userId);
});

// final notificationFilterProvider = StateNotifierProvider<NotificationFilterNotifier, NotificationFilterState>((ref) {
//   return NotificationFilterNotifier();
// });

final notificationSettingsProvider = StateNotifierProvider.family<
    NotificationSettingsNotifier,
    AsyncValue<NotificationSettingsModel?>,
    String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationSettingsNotifier(repository, userId);
});

// Stream provider for real-time notifications (likely for badges or "new" indicators)
final notificationStreamProvider =
    StreamProvider.family<List<NotificationModel>, String>((ref, userId) {
  // final repository = ref.watch(notificationRepositoryProvider);
  return Stream.value(<NotificationModel>[]);
});

// Provider for unread notification count
final unreadNotificationCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final count = await repository.getUnreadCount();
  return count; // Provide a default value if null
});
