import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'edit_profile_state.freezed.dart';

@freezed
abstract class EditProfileState with _$EditProfileState {
  const factory EditProfileState({
    @Default('') String username,
    @Default('') String bio,
    File? coverImage,
    File? profileImage,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _EditProfileState;

  factory EditProfileState.initial() => const EditProfileState();
}