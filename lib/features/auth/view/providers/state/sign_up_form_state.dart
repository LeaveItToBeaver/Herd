import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignUpFormState {
  final String? firstNameError;
  final String? lastNameError;
  final String? usernameError;
  final String? emailError;
  final String? passwordError;
  final String? confirmPasswordError;
  final bool isLoading;

  SignUpFormState({
    this.firstNameError,
    this.lastNameError,
    this.usernameError,
    this.emailError,
    this.passwordError,
    this.confirmPasswordError,
    this.isLoading = false,
  });

  SignUpFormState copyWith({
    String? firstNameError,
    String? lastNameError,
    String? usernameError,
    String? emailError,
    String? passwordError,
    String? confirmPasswordError,
    bool? isLoading,
  }) {
    return SignUpFormState(
      firstNameError: firstNameError,
      lastNameError: lastNameError,
      usernameError: usernameError,
      emailError: emailError,
      passwordError: passwordError,
      confirmPasswordError: confirmPasswordError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

final signUpFormProvider = StateProvider<SignUpFormState>((ref) => SignUpFormState());
