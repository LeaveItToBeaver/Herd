// edit_alt_profile_state.dart
import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_alt_profile_state.freezed.dart';

@freezed
class EditAltProfileState with _$EditAltProfileState {
  const factory EditAltProfileState({
    @Default('') String username,
    @Default('') String bio,
    File? coverImage,
    File? profileImage,
    @Default(false) bool isSubmitting,
    String? errorMessage,
  }) = _EditAltProfileState;

  factory EditAltProfileState.initial() => const EditAltProfileState();
}