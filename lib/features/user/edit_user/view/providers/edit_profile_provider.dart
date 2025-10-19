import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/user/edit_user/view/providers/state/edit_profile_state.dart';

import '../../../user_profile/data/models/user_model.dart';
import '../../../user_profile/data/repositories/user_repository.dart';

part 'edit_profile_provider.g.dart';

@riverpod
class EditProfile extends _$EditProfile {
  @override
  EditProfileState build(UserModel user) {
    return EditProfileState(username: user.username, bio: user.bio ?? '');
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
        'username': state.username,
        'bio': state.bio,
      };
      if (state.coverImage != null) {
        final coverImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.coverImage!,
          type: 'cover',
        );
        if (!ref.mounted) return;
        updatedData['coverImageURL'] = coverImageUrl;
      }

      if (state.profileImage != null) {
        final profileImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.profileImage!,
          type: 'profile',
        );
        if (!ref.mounted) return;
        updatedData['profileImageURL'] = profileImageUrl;
      }

      await userRepository.updateUser(user.id, updatedData);
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      if (!ref.mounted) return;
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}
