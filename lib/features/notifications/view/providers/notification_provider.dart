import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart'; // For stream
import 'package:herdapp/features/notifications/data/models/notification_settings_model.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';
// import 'package:herdapp/features/notifications/utils/notification_service.dart'; // Keep if you still use it
import 'package:herdapp/features/notifications/view/providers/state/notification_filter_state.dart';
import 'package:herdapp/features/notifications/view/providers/state/notification_state.dart';

// Import your actual Notifier classes
import 'notification_notifier.dart';
import 'notification_settings_notifier.dart';
// import 'notification_filter_notifier.dart'; // Assuming you created this

// Provider for the repository (you already have this, ensure it's correct)
// final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
//   return NotificationRepository();
// });

final notificationProvider = StateNotifierProvider.family<NotificationNotifier,
    NotificationState, String>((ref, userId) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationNotifier(repository, userId);
});

// final notificationFilterProvider = StateNotifierProvider<NotificationFilterNotifier, NotificationFilterState>((ref) {
//   return NotificationFilterNotifier(); // Assuming you created this class
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
  final repository = ref.watch(notificationRepositoryProvider);
  return repository.streamNotifications(userId);
});

// Provider for unread notification count
final unreadNotificationCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final repository = ref.watch(notificationRepositoryProvider);
  final count = await repository.getUnreadCount(userId);
  return count ?? 0; // Provide a default value if null
});

// If you still have a NotificationService separate from the repository:
// final notificationServiceProvider = Provider<NotificationService>((ref) {
//   final repository = ref.watch(notificationRepositoryProvider);
//   return NotificationService(repository: repository);
// });
