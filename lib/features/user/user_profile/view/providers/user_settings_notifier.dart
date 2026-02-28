// user_settings_notifier.dart
import 'dart:async';

import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/user_settings_state.dart';

part 'user_settings_notifier.g.dart';

@riverpod
class UserSettings extends _$UserSettings {
  final Map<String, Timer> _debounceTimers = {};

  @override
  Future<UserSettingsState> build(String userId) async {
    // Clean up timers when provider is disposed
    ref.onDispose(() {
      for (final timer in _debounceTimers.values) {
        timer.cancel();
      }
      _debounceTimers.clear();
    });

    final repository = ref.read(userRepositoryProvider);
    final userModel = await repository.getUserById(userId);

    if (userModel != null) {
      final preferences = userModel.preferences;
      return UserSettingsState(
        allowNSFWContent: userModel.allowNSFW,
        blurNSFWContent: preferences['blurNSFWContent'] ?? true,
        showHerdsInAltFeed: userModel.showHerdPostsInAltFeed,
        isOver18: preferences['isOver18'] ?? false,
        preferences: preferences,
      );
    } else {
      throw Exception('User not found');
    }
  }

  // Update a preference with debouncing
  Future<void> updatePreference(String key, dynamic value,
      {int debounceMs = 500}) async {
    // Cancel existing timer if any
    _debounceTimers[key]?.cancel();

    // Get current state or return if not loaded
    final currentState = state.value;
    if (currentState == null) return;

    // Mark this field as updating
    final updatedFields = <String, bool>{...currentState.updatingFields};
    updatedFields[key] = true;

    // Update the local state immediately for responsive UI
    final updatedPreferences = <String, dynamic>{...currentState.preferences};
    updatedPreferences[key] = value;

    // Update specific state fields based on the key
    UserSettingsState newState;
    if (key == 'allowNSFWContent') {
      newState = currentState.copyWith(
        allowNSFWContent: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else if (key == 'blurNSFWContent') {
      newState = currentState.copyWith(
        blurNSFWContent: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else if (key == 'showHerdsInAltFeed') {
      newState = currentState.copyWith(
        showHerdsInAltFeed: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else if (key == 'isOver18') {
      newState = currentState.copyWith(
        isOver18: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else {
      // For any other preference
      newState = currentState.copyWith(
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    }

    state = AsyncData(newState);

    // Start a new debounce timer
    _debounceTimers[key] = Timer(Duration(milliseconds: debounceMs), () async {
      try {
        final repository = ref.read(userRepositoryProvider);

        // Save to repository
        await repository.updateUser(userId, {
          'preferences': {
            ...newState.preferences,
            key: value,
          },
        });

        if (!ref.mounted) return;

        // Handle special case for allowNSFW
        if (key == 'allowNSFWContent') {
          await repository.updateUser(userId, {
            'allowNSFW': value,
          });
        }

        if (!ref.mounted) return;

        // Handle special case for showHerdsInAltFeed
        if (key == 'showHerdsInAltFeed') {
          await repository.updateUser(userId, {
            'showHerdPostsInAltFeed': value,
          });
        }

        if (!ref.mounted) return;

        // Update state to mark field as not updating
        final latestState = state.value;
        if (latestState == null) return;

        final updatedFields = <String, bool>{...latestState.updatingFields};
        updatedFields[key] = false;
        state = AsyncData(latestState.copyWith(updatingFields: updatedFields));
      } catch (e) {
        if (!ref.mounted) return;
        // Handle error - mark field as not updating but set error state
        final latestState = state.value;
        if (latestState == null) return;

        final updatedFields = <String, bool>{...latestState.updatingFields};
        updatedFields[key] = false;
        state = AsyncError(e, StackTrace.current);
      }
    });
  }

  // Direct method to update allowNSFW setting
  Future<void> updateAllowNSFWContent(bool value) async {
    await updatePreference('allowNSFWContent', value);
  }

  // Direct method to update blurNSFW setting
  Future<void> updateBlurNSFWContent(bool value) async {
    await updatePreference('blurNSFWContent', value);
  }

  // Direct method to update showHerdsInAltFeed setting
  Future<void> updateShowHerdsInAltFeed(bool value) async {
    await updatePreference('showHerdsInAltFeed', value);
  }

  // Direct method to update isOver18 setting
  Future<void> updateIsOver18(bool value) async {
    await updatePreference('isOver18', value);

    // If confirming they are over 18, also enable NSFW content
    if (value) {
      await updateAllowNSFWContent(true);
    }
  }

  // Reload settings from repository
  Future<void> refreshSettings() async {
    ref.invalidateSelf();
  }
}
