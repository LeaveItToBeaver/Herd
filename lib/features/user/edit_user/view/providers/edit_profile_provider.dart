import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/edit_user/view/providers/state/edit_profile_state.dart';

import '../../../user_profile/data/models/user_model.dart';
import '../../../user_profile/data/repositories/user_repository.dart';

class EditProfileNotifier extends StateNotifier<EditProfileState> {
  final UserRepository userRepository;
  final UserModel user;

  EditProfileNotifier({required this.userRepository, required this.user})
      : super(EditProfileState(username: user.username, bio: user.bio ?? ''));

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

  Future<void> submit() async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
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
        updatedData['coverImageURL'] = coverImageUrl;
      }

      if (state.profileImage != null) {
        final profileImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.profileImage!,
          type: 'profile',
        );
        updatedData['profileImageURL'] = profileImageUrl;
      }

      await userRepository.updateUser(user.id, updatedData);
      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}

final editProfileProvider = StateNotifierProvider.family<EditProfileNotifier,
    EditProfileState, UserModel>(
  (ref, user) {
    final userRepository = ref.watch(userRepositoryProvider);
    return EditProfileNotifier(userRepository: userRepository, user: user);
  },
);
