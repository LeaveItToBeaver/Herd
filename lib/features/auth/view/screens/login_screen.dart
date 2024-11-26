import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';

// State class to manage form errors
class LoginFormState {
  final String? emailError;
  final String? passwordError;
  final bool isLoading;

  LoginFormState({
    this.emailError,
    this.passwordError,
    this.isLoading = false,
  });

  LoginFormState copyWith({
    String? emailError,
    String? passwordError,
    bool? isLoading,
  }) {
    return LoginFormState(
      emailError: emailError,
      passwordError: passwordError,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Provider for form state
final loginFormProvider = StateProvider<LoginFormState>((ref) => LoginFormState());

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Handle login process
  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset form state
    ref.read(loginFormProvider.notifier).state = LoginFormState(isLoading: true);

    // Validate inputs
    if (email.isEmpty) {
      ref.read(loginFormProvider.notifier).state = LoginFormState(
        emailError: 'Email is required',
      );
      return;
    }

    if (!_isValidEmail(email)) {
      ref.read(loginFormProvider.notifier).state = LoginFormState(
        emailError: 'Please enter a valid email',
      );
      return;
    }

    if (password.isEmpty) {
      ref.read(loginFormProvider.notifier).state = LoginFormState(
        passwordError: 'Password is required',
      );
      return;
    }

    if (password.length < 6) {
      ref.read(loginFormProvider.notifier).state = LoginFormState(
        passwordError: 'Password must be at least 6 characters',
      );
      return;
    }

    try {
      final auth = ref.read(authProvider.notifier);
      await auth.signIn(email, password);

      if (mounted) {
        context.go('/profile');
      }
    } catch (e) {
      String errorMessage = 'An error occurred';

      // Handle specific error cases
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password';
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format';
      } else if (e.toString().contains('too-many-requests')) {
        errorMessage = 'Too many attempts. Please try again later';
      }

      ref.read(loginFormProvider.notifier).state = LoginFormState(
        emailError: e.toString().contains('user-not-found') ? errorMessage : null,
        passwordError: e.toString().contains('wrong-password') ? errorMessage : null,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: formState.emailError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.emailError != null ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.emailError != null ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  errorText: formState.passwordError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.passwordError != null ? Colors.red : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.passwordError != null ? Colors.red : Colors.blue,
                    ),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: formState.isLoading ? null : _handleLogin,
                  child: formState.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/signup'),
                  child: const Text('Sign Up'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}