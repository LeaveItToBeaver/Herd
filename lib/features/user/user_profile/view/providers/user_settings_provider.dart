//user_settings Provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/user_profile/view/providers/user_settings_notifier.dart';

import '../../../auth/view/providers/auth_provider.dart';
import '../../data/models/user_settings_state.dart';
import '../../data/repositories/user_repository.dart';

final userSettingsProvider = StateNotifierProvider.autoDispose
    .family<UserSettingsNotifier, UserSettingsState, String>(
  (ref, userId) {
    final userRepository = ref.watch(userRepositoryProvider);
    return UserSettingsNotifier(userRepository, userId);
  },
);

final currentUserSettingsProvider =
    StateNotifierProvider.autoDispose<UserSettingsNotifier, UserSettingsState>(
        (ref) {
  final currentUser = ref.watch(authProvider);
  if (currentUser == null) {
    throw Exception('No authenticated user');
  }

  final repository = ref.watch(userRepositoryProvider);
  return UserSettingsNotifier(repository, currentUser.uid);
});
