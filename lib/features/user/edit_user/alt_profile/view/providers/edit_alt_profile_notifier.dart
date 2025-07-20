import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/edit_user/alt_profile/view/providers/state/edit_alt_profile_state.dart';

import '../../../../user_profile/data/models/user_model.dart';
import '../../../../user_profile/data/repositories/user_repository.dart';

class EditAltProfileNotifier extends StateNotifier<EditAltProfileState> {
  final UserRepository userRepository;
  final UserModel user;

  EditAltProfileNotifier({required this.userRepository, required this.user})
      : super(EditAltProfileState(
          username: user.username,
          bio: user.altBio ?? '',
        ));

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
        updatedData['altCoverImageURL'] = coverImageUrl;
      }

      if (state.profileImage != null) {
        final profileImageUrl = await userRepository.uploadImage(
          userId: user.id,
          file: state.profileImage!,
          type: 'alt_profile',
        );
        updatedData['altProfileImageURL'] = profileImageUrl;
      }

      await userRepository.updateAltProfile(user.id, updatedData);
      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      state =
          state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}

final editAltProfileProvider = StateNotifierProvider.family<
    EditAltProfileNotifier, EditAltProfileState, UserModel>(
  (ref, user) {
    final userRepository = ref.watch(userRepositoryProvider);
    return EditAltProfileNotifier(userRepository: userRepository, user: user);
  },
);
