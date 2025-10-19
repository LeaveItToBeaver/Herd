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
  UserSettingsState build(String userId) {
    // Load settings when created
    _loadSettings(userId);
    return UserSettingsState(isLoading: true);
  }

  Future<void> _loadSettings(String userId) async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final repository = ref.read(userRepositoryProvider);
      final userModel = await repository.getUserById(userId);

      if (!ref.mounted) return;

      if (userModel != null) {
        final preferences = userModel.preferences;

        state = state.copyWith(
          allowNSFWContent: userModel.allowNSFW,
          blurNSFWContent: preferences['blurNSFWContent'] ?? true,
          showHerdsInAltFeed: userModel.showHerdPostsInAltFeed,
          isOver18: preferences['isOver18'] ?? false,
          preferences: preferences,
          isLoading: false,
        );
      } else {
        state =
            state.copyWith(isLoading: false, errorMessage: 'User not found');
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(
          isLoading: false, errorMessage: 'Error loading settings: $e');
    }
  }

  // Update a preference with debouncing
  Future<void> updatePreference(String key, dynamic value,
      {int debounceMs = 500}) async {
    // Cancel existing timer if any
    _debounceTimers[key]?.cancel();

    // Mark this field as updating
    final updatedFields = {...state.updatingFields};
    updatedFields[key] = true;

    // Update the local state immediately for responsive UI
    final updatedPreferences = {...state.preferences};
    updatedPreferences[key] = value;

    // Update specific state fields based on the key
    if (key == 'allowNSFWContent') {
      state = state.copyWith(
        allowNSFWContent: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else if (key == 'blurNSFWContent') {
      state = state.copyWith(
        blurNSFWContent: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else if (key == 'showHerdsInAltFeed') {
      state = state.copyWith(
        showHerdsInAltFeed: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else if (key == 'isOver18') {
      state = state.copyWith(
        isOver18: value as bool,
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    } else {
      // For any other preference
      state = state.copyWith(
        preferences: updatedPreferences,
        updatingFields: updatedFields,
      );
    }

    // Start a new debounce timer
    _debounceTimers[key] = Timer(Duration(milliseconds: debounceMs), () async {
      try {
        final repository = ref.read(userRepositoryProvider);

        // Save to repository
        await repository.updateUser(userId, {
          'preferences': {
            ...state.preferences,
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
        final updatedFields = {...state.updatingFields};
        updatedFields[key] = false;
        state = state.copyWith(updatingFields: updatedFields);
      } catch (e) {
        if (!ref.mounted) return;
        // Handle error - update state to show error
        final updatedFields = {...state.updatingFields};
        updatedFields[key] = false;
        state = state.copyWith(
          errorMessage: 'Error saving preference: $e',
          updatingFields: updatedFields,
        );
      }
    });
  }

  // Direct method to update allowNSFW setting
  Future<void> updateAllowNSFWContent(bool value) async {
    updatePreference('allowNSFWContent', value);
  }

  // Direct method to update blurNSFW setting
  Future<void> updateBlurNSFWContent(bool value) async {
    updatePreference('blurNSFWContent', value);
  }

  // Direct method to update showHerdsInAltFeed setting
  Future<void> updateShowHerdsInAltFeed(bool value) async {
    updatePreference('showHerdsInAltFeed', value);
  }

  // Direct method to update isOver18 setting
  Future<void> updateIsOver18(bool value) async {
    updatePreference('isOver18', value);

    // If confirming they are over 18, also enable NSFW content
    if (value) {
      updateAllowNSFWContent(true);
    }
  }

  // Reset all errors
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  // Reload settings from repository
  Future<void> refreshSettings() async {
    await _loadSettings(userId);
  }
}
