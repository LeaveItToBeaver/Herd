import 'package:firebase_auth/firebase_auth.dart';
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
  bool _isMounted = true; // Track mounted state

  @override
  void initState() {
    super.initState();
    _isMounted = true;
  }

  @override
  void dispose() {
    _isMounted = false; // Set to false when disposed
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // Handle login process
  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Reset form state and set loading
    if (_isMounted) {
      ref.read(loginFormProvider.notifier).state =
          LoginFormState(isLoading: true);
    }

    // Validate inputs
    if (email.isEmpty) {
      if (_isMounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          emailError: 'Email is required',
        );
      }
      return;
    }

    if (!Validators.isValidEmail(email)) {
      if (_isMounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          emailError: 'Please enter a valid email',
        );
      }
      return;
    }

    if (password.isEmpty) {
      if (_isMounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          passwordError: 'Password is required',
        );
      }
      return;
    }

    if (password.length < 6) {
      if (_isMounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          passwordError: 'Password must be at least 6 characters',
        );
      }
      return;
    }

    try {
      // Store references to providers before any awaits
      final authNotifier = ref.read(authProvider.notifier);
      final userNotifier = ref.read(currentUserProvider.notifier);

      final userCredential = await authNotifier.signIn(email, password);

      if (userCredential.user != null) {
        // Wait for Firestore data to be loaded
        await userNotifier.fetchCurrentUser();

        if (mounted && _isMounted) {
          context.go('/profile');
        }
      } else if (mounted && _isMounted) {
        ref.read(loginFormProvider.notifier).state = LoginFormState(
          emailError: 'Login failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!_isMounted) return;

      // Debug: Print the exact code and message
      print("Firebase Auth Error Code: ${e.code}");
      print("Firebase Auth Error Message: ${e.message}");

      String errorMessage = 'An error occurred';

      // Handle specific error codes
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No account found with this email';
          break;
        case 'wrong-password':
        case 'invalid-credential': // Add this case
          errorMessage = 'Incorrect password';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later';
          break;
        case 'account-exists-with-different-credential':
          errorMessage =
              'An account already exists with a different sign-in method';
          break;
        case 'operation-not-allowed':
          errorMessage = 'This login method is not allowed';
          break;
        default:
          errorMessage = 'Authentication failed';
      }

      if (_isMounted) {
        // Set field-specific errors
        bool isEmailError =
            e.code == 'user-not-found' || e.code == 'invalid-email';
        bool isPasswordError =
            e.code == 'wrong-password' || e.code == 'invalid-credential';

        ref.read(loginFormProvider.notifier).state = LoginFormState(
          emailError: isEmailError ? errorMessage : null,
          passwordError: isPasswordError ? errorMessage : null,
        );
      }

      // Show error in snackbar
      if (mounted && _isMounted) {
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
                          // Store reference before await
                          final authNotifier = ref.read(authProvider.notifier);
                          await authNotifier.resetPassword(email);

                          if (context.mounted) {
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
                    'Welcome!',
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
                    onPressed: () => context.goNamed('signup'),
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
