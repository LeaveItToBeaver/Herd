import 'dart:io';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'sign_up_form_state.freezed.dart';
part 'sign_up_form_state.g.dart';

@freezed
abstract class SignUpFormState with _$SignUpFormState {
  const factory SignUpFormState({
    String? firstNameError,
    String? lastNameError,
    String? usernameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? dateOfBirthError,
    DateTime? dateOfBirth,
    @Default(false) bool isLoading,
    String? bioError,
    @Default(0) int currentStep,
    @Default(false) bool acceptedTerms,
    @Default(false) bool acceptedPrivacy,
    @Default({}) Map<String, dynamic> deviceInfo,
    File? profileImage,
    @Default([]) List<String> selectedInterests,
  }) = _SignUpFormState;

  factory SignUpFormState.initial() => const SignUpFormState();
}

@riverpod
class SignUpForm extends _$SignUpForm {
  @override
  SignUpFormState build() => SignUpFormState.initial();

  void updateFirstNameError(String? error) {
    state = state.copyWith(firstNameError: error);
  }

  void updateLastNameError(String? error) {
    state = state.copyWith(lastNameError: error);
  }

  void updateUsernameError(String? error) {
    state = state.copyWith(usernameError: error);
  }

  void updateEmailError(String? error) {
    state = state.copyWith(emailError: error);
  }

  void updatePasswordError(String? error) {
    state = state.copyWith(passwordError: error);
  }

  void updateConfirmPasswordError(String? error) {
    state = state.copyWith(confirmPasswordError: error);
  }

  void updateDateOfBirthError(String? error) {
    state = state.copyWith(dateOfBirthError: error);
  }

  void updateDateOfBirth(DateTime? date) {
    state = state.copyWith(dateOfBirth: date);
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void updateBioError(String? error) {
    state = state.copyWith(bioError: error);
  }

  void setCurrentStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setAcceptedTerms(bool accepted) {
    state = state.copyWith(acceptedTerms: accepted);
  }

  void setAcceptedPrivacy(bool accepted) {
    state = state.copyWith(acceptedPrivacy: accepted);
  }

  void updateDeviceInfo(Map<String, dynamic> info) {
    state = state.copyWith(deviceInfo: info);
  }

  void setProfileImage(File? image) {
    state = state.copyWith(profileImage: image);
  }

  void updateSelectedInterests(List<String> interests) {
    state = state.copyWith(selectedInterests: interests);
  }

  void toggleInterest(String interest) {
    final currentInterests = List<String>.from(state.selectedInterests);
    if (currentInterests.contains(interest)) {
      currentInterests.remove(interest);
    } else {
      currentInterests.add(interest);
    }
    state = state.copyWith(selectedInterests: currentInterests);
  }

  void updateState(SignUpFormState newState) {
    state = newState;
  }

  void reset() {
    state = SignUpFormState.initial();
  }
}
