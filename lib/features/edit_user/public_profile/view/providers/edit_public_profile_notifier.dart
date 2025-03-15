import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/edit_user/public_profile/view/providers/state/edit_public_profile_state.dart';

import '../../../../user/data/models/user_model.dart';
import '../../../../user/data/repositories/user_repository.dart';

class EditPublicProfileNotifier extends StateNotifier<EditPublicProfileState> {
  final UserRepository userRepository;
  final UserModel user;

  EditPublicProfileNotifier({required this.userRepository, required this.user})
      : super(EditPublicProfileState(
    firstName: user.firstName ?? '',
    lastName: user.lastName ?? '',
    bio: user.bio ?? '',
  ));

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

  Future<void> submit() async {
    if (state.isSubmitting) return;

    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final Map<String, dynamic> updatedData = {
        'firstName': state.firstName,
        'lastName': state.lastName,
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
      state = state.copyWith(isSubmitting: false, isSuccess: true);
    } catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}

final editPublicProfileProvider =
StateNotifierProvider.family<EditPublicProfileNotifier, EditPublicProfileState, UserModel>(
      (ref, user) {
    final userRepository = ref.watch(userRepositoryProvider);
    return EditPublicProfileNotifier(userRepository: userRepository, user: user);
  },
);