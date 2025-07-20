import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpFormState {
  final String? firstNameError;
  final String? lastNameError;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final String? dateOfBirthError;
  final DateTime? dateOfBirth;
  final bool isLoading;
  final String? bioError;
  final int currentStep;
  final bool acceptedTerms;
  final bool acceptedPrivacy;
  final Map<String, dynamic> deviceInfo;
  final File? profileImage;
  final List<String> selectedInterests;

  SignUpFormState({
    this.firstNameError,
    this.lastNameError,
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.dateOfBirthError,
    this.dateOfBirth,
    this.isLoading = false,
    this.bioError,
    this.currentStep = 0,
    this.acceptedTerms = false,
    this.acceptedPrivacy = false,
    this.deviceInfo = const {},
    this.profileImage,
    this.selectedInterests = const [],
  });

  SignUpFormState copyWith({
    String? firstNameError,
    String? lastNameError,
    String? usernameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    String? dateOfBirthError,
    DateTime? dateOfBirth,
    bool? isLoading,
    String? bioError,
    int? currentStep,
    bool? acceptedTerms,
    bool? acceptedPrivacy,
    Map<String, dynamic>? deviceInfo,
    File? profileImage,
    List<String>? selectedInterests,
  }) {
    return SignUpFormState(
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      usernameError: usernameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      dateOfBirthError: dateOfBirthError,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      isLoading: isLoading ?? this.isLoading,
      bioError: bioError,
      currentStep: currentStep ?? this.currentStep,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      acceptedPrivacy: acceptedPrivacy ?? this.acceptedPrivacy,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      profileImage: profileImage ?? this.profileImage,
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

final signUpFormProvider =
    StateProvider<SignUpFormState>((ref) => SignUpFormState());
