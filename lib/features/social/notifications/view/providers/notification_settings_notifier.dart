import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_settings_model.dart';
import 'package:herdapp/features/social/notifications/data/repositories/notification_repository.dart';

class NotificationSettingsNotifier {
  final NotificationRepository _repository;
  final String _userId;
  AsyncValue<NotificationSettingsModel?> _state = const AsyncValue.loading();

  AsyncValue<NotificationSettingsModel?> get state => _state;
  set state(AsyncValue<NotificationSettingsModel?> newState) => _state = newState;

  NotificationSettingsNotifier(this._repository, this._userId) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await _repository.getOrCreateSettings(_userId);
      state = AsyncValue.data(settings);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    try {
      await _repository.updateSettings(newSettings);
      state = AsyncValue.data(newSettings);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> togglePushNotifications(bool isEnabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings =
        currentSettings.copyWith(pushNotificationsEnabled: isEnabled);
    await updateSettings(newSettings);
  }

  Future<void> toggleTypeNotification(
      NotificationType type, bool isEnabled) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    NotificationSettingsModel newSettings;
    switch (type) {
      case NotificationType.follow:
        newSettings = currentSettings.copyWith(followNotifications: isEnabled);
        break;
      case NotificationType.newPost:
        newSettings = currentSettings.copyWith(postNotifications: isEnabled);
        break;
      case NotificationType.postLike:
        newSettings = currentSettings.copyWith(likeNotifications: isEnabled);
        break;
      case NotificationType.comment:
        newSettings =
            currentSettings.copyWith(commentNotifications: isEnabled);
        break;
      case NotificationType.commentReply:
        newSettings = currentSettings.copyWith(replyNotifications: isEnabled);
        break;
      case NotificationType.connectionRequest:
      case NotificationType.connectionAccepted:
        newSettings =
            currentSettings.copyWith(connectionNotifications: isEnabled);
        break;
      case NotificationType.postMilestone:
        newSettings =
            currentSettings.copyWith(milestoneNotifications: isEnabled);
        break;
      default:
        return;
    }
    await updateSettings(newSettings);
  }

  Future<void> setMuteUntil(DateTime? muteUntilDate) async {
    final currentSettings = state.value;
    if (currentSettings == null) return;

    final newSettings = currentSettings.copyWith(mutedUntil: muteUntilDate);
    await updateSettings(newSettings);
  }
}
