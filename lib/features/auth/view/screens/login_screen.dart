import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/utils/validators.dart';

import '../widgets/app_logo.dart';
import '../widgets/custom_textfield.dart';

// State class to manage form errors and loading state
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
final loginFormProvider =
    StateProvider<LoginFormState>((ref) => LoginFormState());

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Handle login process
  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset form state and set loading
    ref.read(loginFormProvider.notifier).state =
        LoginFormState(isLoading: true);

    // Validate inputs
    if (email.isEmpty) {
      ref.read(loginFormProvider.notifier).state = LoginFormState(
        emailError: 'Email is required',
      );
      return;
    }

    if (!Validators.isValidEmail(email)) {
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
      final userCredential = await auth.signIn(email, password);

      if (userCredential.user != null) {
        // Wait for Firestore data to be loaded
        await ref.read(currentUserProvider.notifier).fetchCurrentUser();

        if (mounted) {
          context.go('/profile');
        }
      } else if (mounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          emailError: 'Login failed. Please try again.',
        );
      } else {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          emailError: 'Login failed. Please try again.',
        );
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
      } else if (e
          .toString()
          .contains('account-exists-with-different-credential')) {
        errorMessage =
            'An account already exists with a different sign-in method';
      } else if (e.toString().contains('operation-not-allowed')) {
        errorMessage = 'This login method is not allowed';
      }

      ref.read(loginFormProvider.notifier).state = LoginFormState(
        emailError:
            e.toString().contains('user-not-found') ? errorMessage : null,
        passwordError:
            e.toString().contains('wrong-password') ? errorMessage : null,
      );

      if (mounted) {
        // Show error in snackbar
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

  // Handle password reset
  void _showPasswordResetDialog() {
    final resetEmailController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Reset Password'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Enter your email address and we\'ll send you a link to reset your password.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: resetEmailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  errorText: errorMessage,
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: isLoading
                    ? null
                    : () async {
                        final email = resetEmailController.text.trim();
                        if (email.isEmpty || !Validators.isValidEmail(email)) {
                          setState(() {
                            errorMessage = 'Please enter a valid email';
                          });
                          return;
                        }

                        setState(() {
                          isLoading = true;
                          errorMessage = null;
                        });

                        try {
                          await ref
                              .read(authProvider.notifier)
                              .resetPassword(email);
                          if (mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password reset link sent. Please check your email.',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                            errorMessage =
                                'Error: ${e.toString().contains('user-not-found') ? 'No account found with this email' : 'Could not send reset link'}';
                          });
                        }
                      },
                child: const Text('Send Link'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(loginFormProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // App Logo and Welcome Message
                  const AppLogo(size: 80),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue to Herd',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Email Field
                  CustomTextField(
                    controller: emailController,
                    hintText: 'Email',
                    errorText: formState.emailError,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),

                  // Password Field
                  CustomTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    errorText: formState.passwordError,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _handleLogin(),
                  ),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showPasswordResetDialog,
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button
                  FilledButton(
                    onPressed: formState.isLoading ? null : _handleLogin,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: formState.isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Sign In',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // Social Login Options
                  // You can add this functionality later if needed

                  // Divider with "OR" text
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sign Up Button
                  OutlinedButton(
                    onPressed: () => context.go('/signup'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 56),
                      side: BorderSide(color: theme.colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Create New Account',
                      style: TextStyle(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
