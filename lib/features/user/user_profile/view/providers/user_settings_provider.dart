//user_settings Provider.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/view/providers/auth_provider.dart';
import '../../data/models/user_settings_state.dart';
import 'user_settings_notifier.dart';

part 'user_settings_provider.g.dart';

// Current user settings provider - wraps the family provider for convenience
@riverpod
class CurrentUserSettings extends _$CurrentUserSettings {
  @override
  Future<UserSettingsState> build() async {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      throw Exception('No authenticated user');
    }

    // Watch the actual user settings for the current user
    return await ref.watch(userSettingsProvider(currentUser.uid).future);
  }

  // Delegate methods to the actual notifier
  Future<void> updateAllowNSFWContent(bool value) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    await ref
        .read(userSettingsProvider(currentUser.uid).notifier)
        .updateAllowNSFWContent(value);
  }

  Future<void> updateBlurNSFWContent(bool value) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    await ref
        .read(userSettingsProvider(currentUser.uid).notifier)
        .updateBlurNSFWContent(value);
  }

  Future<void> updateShowHerdsInAltFeed(bool value) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    await ref
        .read(userSettingsProvider(currentUser.uid).notifier)
        .updateShowHerdsInAltFeed(value);
  }

  Future<void> updateIsOver18(bool value) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    await ref
        .read(userSettingsProvider(currentUser.uid).notifier)
        .updateIsOver18(value);
  }

  Future<void> updatePreference(String key, dynamic value,
      {int debounceMs = 500}) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    await ref
        .read(userSettingsProvider(currentUser.uid).notifier)
        .updatePreference(key, value, debounceMs: debounceMs);
  }

  Future<void> refreshSettings() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    await ref
        .read(userSettingsProvider(currentUser.uid).notifier)
        .refreshSettings();
  }
}
