import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'dart:io';

import '../../../../user/data/repositories/user_repository.dart';

class EditProfileState {
  final String username;
  final String bio;
  final File? coverImage;
  final File? profileImage;
  final bool isSubmitting;
  final String? errorMessage;

  EditProfileState({
    this.username = '',
    this.bio = '',
    this.coverImage,
    this.profileImage,
    this.isSubmitting = false,
    this.errorMessage,
  });

  EditProfileState copyWith({
    String? username,
    String? bio,
    File? coverImage,
    File? profileImage,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return EditProfileState(
      username: username ?? this.username,
      bio: bio ?? this.bio,
      coverImage: coverImage ?? this.coverImage,
      profileImage: profileImage ?? this.profileImage,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

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

      // Handle image uploads
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

      // Update user in Firestore
      await userRepository.updateUser(user.id, updatedData);

      state = state.copyWith(isSubmitting: false);
    } catch (error) {
      state = state.copyWith(isSubmitting: false, errorMessage: error.toString());
    }
  }
}
