import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/user/edit_user/alt_profile/view/providers/state/edit_alt_profile_state.dart';

import '../../../../user_profile/data/models/user_model.dart';
import '../../../../user_profile/data/repositories/user_repository.dart';

part 'edit_alt_profile_notifier.g.dart';

@riverpod
class EditAltProfile extends _$EditAltProfile {
  @override
  EditAltProfileState build(UserModel user) {
    return EditAltProfileState(
      username: user.username,
      bio: user.altBio ?? '',
    );
  }

  void usernameChanged(String value) {
    state = state.copyWith(username: value);
  }

  void bioChanged(String value) {
    state = state.copyWith(bio: value);
  }

  void coverImageChanged(File? file) {
    state = state.copyWith(coverImage: file);
  }

  void profileImageChanged(File? file) {
    state = state.copyWith(profileImage: file);
  }

  Future<void> submit(UserModel user) async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final userRepository = ref.read(userRepositoryProvider);
      final Map<String, dynamic> updatedData = {
        // Username is shared between profiles, so this stays the same
        'username': state.username,
        // Use altBio instead of bio for the alt profile
        'altBio': state.bio,
      };

      if (state.coverImage != null) {
        final coverImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.coverImage!,
          type: 'alt_cover',
        );
        if (!ref.mounted) return;
        updatedData['altCoverImageURL'] = coverImageUrl;
      }

      if (state.profileImage != null) {
        final profileImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.profileImage!,
          type: 'alt_profile',
        );
        if (!ref.mounted) return;
        updatedData['altProfileImageURL'] = profileImageUrl;
      }

      await userRepository.updateAltProfile(user.id, updatedData);
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      if (!ref.mounted) return;
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}
