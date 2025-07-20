// edit_public_profile_state.dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'edit_public_profile_state.freezed.dart';

@freezed
abstract class EditPublicProfileState with _$EditPublicProfileState {
  const factory EditPublicProfileState({
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String bio,
    File? coverImage,
    File? profileImage,
    @Default(false) bool isSubmitting,
    @Default(true) bool isPublic,
    @Default(false) bool isSuccess,
    String? errorMessage,
  }) = _EditPublicProfileState;

  factory EditPublicProfileState.initial() => const EditPublicProfileState();
}