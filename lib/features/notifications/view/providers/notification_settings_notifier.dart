// lib/features/notifications/view/providers/notification_settings_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/notifications/data/models/notification_settings_model.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';

class NotificationSettingsNotifier
    extends StateNotifier<AsyncValue<NotificationSettingsModel?>> {
  final NotificationRepository _repository;
  final String _userId;

  NotificationSettingsNotifier(this._repository, this._userId)
      : super(const AsyncValue.loading()) {
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
    // Optionally, keep the current state or set to loading while updating
    // final previousState = state;
    // state = AsyncValue.loading(); // Or some other indicator if you prefer

    try {
      await _repository.updateSettings(newSettings);
      state = AsyncValue.data(
          newSettings); // Update with the successfully saved settings
    } catch (e, s) {
      // state = previousState; // Revert to previous state on error
      state = AsyncValue.error(e, s); // Or keep the new settings but show error
      // You might want to re-fetch settings here if the update partially failed
      // or if you want to be sure of the server state.
    }
  }
}
