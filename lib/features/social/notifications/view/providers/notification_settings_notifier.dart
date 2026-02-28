import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_settings_model.dart';

part 'notification_settings_notifier.g.dart';

@riverpod
class NotificationSettings extends _$NotificationSettings {
  @override
  AsyncValue<NotificationSettingsModel?> build(String userID) {
    Future.microtask(() => loadSettings());
    return const AsyncValue.loading();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final settings = await ref
          .read(notificationRepositoryProvider)
          .getOrCreateSettings(userID);
      state = AsyncValue.data(settings);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> updateSettings(NotificationSettingsModel newSettings) async {
    try {
      await ref
          .read(notificationRepositoryProvider)
          .updateSettings(newSettings);
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
        newSettings = currentSettings.copyWith(commentNotifications: isEnabled);
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
