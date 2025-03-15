// edit_private_profile_state.dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_private_profile_state.freezed.dart';

@freezed
class EditPrivateProfileState with _$EditPrivateProfileState {
  const factory EditPrivateProfileState({
    @Default('') String username,
    @Default('') String bio,
    File? coverImage,
    File? profileImage,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _EditPrivateProfileState;

  factory EditPrivateProfileState.initial() => const EditPrivateProfileState();
}