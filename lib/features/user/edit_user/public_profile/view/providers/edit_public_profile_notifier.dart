import 'dart:io';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/user/edit_user/public_profile/view/providers/state/edit_public_profile_state.dart';

import '../../../../user_profile/data/models/user_model.dart';
import '../../../../user_profile/data/repositories/user_repository.dart';

part 'edit_public_profile_notifier.g.dart';

@riverpod
class EditPublicProfile extends _$EditPublicProfile {
  @override
  EditPublicProfileState build(UserModel user) {
    return EditPublicProfileState(
      firstName: user.firstName,
      lastName: user.lastName,
      bio: user.bio ?? '',
    );
  }

  void firstNameChanged(String value) {
    state = state.copyWith(firstName: value);
  }

  void lastNameChanged(String value) {
    state = state.copyWith(lastName: value);
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
        'firstName': state.firstName,
        'lastName': state.lastName,
        'bio': state.bio, // Correct - updates the public bio
        // Other public profile fields...
      };

      if (state.coverImage != null) {
        final coverImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.coverImage!,
          type: 'cover', // Public profile cover image
        );
        if (!ref.mounted) return;
        updatedData['coverImageURL'] = coverImageUrl;
      }

      if (state.profileImage != null) {
        final profileImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.profileImage!,
          type: 'profile', // Public profile image
        );
        if (!ref.mounted) return;
        updatedData['profileImageURL'] = profileImageUrl;
      }

      await userRepository.updateUser(user.id, updatedData);
      if (!ref.mounted) return;
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } catch (error) {
      if (!ref.mounted) return;
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}
