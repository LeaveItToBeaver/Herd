// user_settings_notifier.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_repository.dart';

import '../../data/models/user_settings_state.dart';

class UserSettingsNotifier extends StateNotifier<UserSettingsState> {
  final UserRepository _repository;
  final String _userId;
  final Map<String, Timer> _debounceTimers = {};

  UserSettingsNotifier(this._repository, this._userId)
      : super(UserSettingsState(isLoading: true)) {
    // Load settings when created
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      state = state.copyWith(isLoading: true, errorMessage: null);

      final userModel = await _repository.getUserById(_userId);

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
        // Save to repository
        await _repository.updateUser(_userId, {
          'preferences': {
            ...state.preferences,
            key: value,
          },
        });

        // Handle special case for allowNSFW
        if (key == 'allowNSFWContent') {
          await _repository.updateUser(_userId, {
            'allowNSFW': value,
          });
        }

        // Handle special case for showHerdsInAltFeed
        if (key == 'showHerdsInAltFeed') {
          await _repository.updateUser(_userId, {
            'showHerdPostsInAltFeed': value,
          });
        }

        // Update state to mark field as not updating
        final updatedFields = {...state.updatingFields};
        updatedFields[key] = false;
        state = state.copyWith(updatingFields: updatedFields);
      } catch (e) {
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
    await _loadSettings();
  }

  @override
  void dispose() {
    // Cancel all timers
    for (final timer in _debounceTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }
}
