import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isCheckingUsername = false;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Check if username is available
  Future<bool> _isUsernameAvailable(String username) async {
    if (username.isEmpty) return false;

    final QuerySnapshot result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return result.docs.isEmpty;
  }

  // Handle username changes
  void _onUsernameChanged(String value) async {
    if (value.isEmpty) return;

    setState(() => _isCheckingUsername = true);

    final isAvailable = await _isUsernameAvailable(value);

    if (mounted) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        usernameError: !isAvailable ? 'Username is already taken' : null,
      );
      setState(() => _isCheckingUsername = false);
    }
  }

  // Handle sign up process
  Future<void> _handleSignUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final username = usernameController.text.trim().toLowerCase();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Reset form state
    ref.read(signUpFormProvider.notifier).state =
        SignUpFormState(isLoading: true);

    // Validate inputs
    if (firstName.isEmpty) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        firstNameError: 'First name is required',
      );
      return;
    }

    if (lastName.isEmpty) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        lastNameError: 'Last name is required',
      );
      return;
    }

    if (username.isEmpty) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        usernameError: 'Username is required',
      );
      return;
    }

    if (email.isEmpty || !_isValidEmail(email)) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        emailError: 'Please enter a valid email',
      );
      return;
    }

    if (password.length < 6) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        passwordError: 'Password must be at least 6 characters',
      );
      return;
    }

    if (password != confirmPassword) {
      ref.read(signUpFormProvider.notifier).state = SignUpFormState(
        confirmPasswordError: 'Passwords do not match',
      );
      return;
    }

    try {
      final auth = ref.read(authProvider.notifier);
      final userRepository = ref.read(userRepositoryProvider);

      // Check username availability
      final isAvailable = await userRepository.isUsernameAvailable(username);
      if (!isAvailable) {
        ref.read(signUpFormProvider.notifier).state = SignUpFormState(
          usernameError: 'Username is already taken',
        );
        return; // Add this return statement
      }

      // Sign up user and get credentials
      final userCredential = await auth.signUp(email, password);

      // Create user model with the uid from credentials
      final user = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
      );

      // Create user document in Firestore
      await userRepository.createUser(userCredential.user!.uid, user);

      if (mounted) {
        context.go('/profile');
      }
    } catch (e) {
      String errorMessage = 'An error occurred';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email is already registered';
        ref.read(signUpFormProvider.notifier).state = SignUpFormState(
          emailError: errorMessage,
        );
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format';
        ref.read(signUpFormProvider.notifier).state = SignUpFormState(
          emailError: errorMessage,
        );
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
        ref.read(signUpFormProvider.notifier).state = SignUpFormState(
          passwordError: errorMessage,
        );
      }

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
        ref.read(signUpFormProvider.notifier).state = SignUpFormState();
      }
    }
  }

  Future<void> _returnToLogin() async {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(signUpFormProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: firstNameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  errorText: formState.firstNameError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.firstNameError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.firstNameError != null
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: lastNameController,
                decoration: InputDecoration(
                  labelText: 'Last Name',
                  errorText: formState.lastNameError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.lastNameError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.lastNameError != null
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  errorText: formState.usernameError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.usernameError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.usernameError != null
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                  suffixIcon: _isCheckingUsername
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                onChanged: _onUsernameChanged,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  errorText: formState.emailError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.emailError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.emailError != null
                          ? Colors.red
                          : Colors.blue,
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
                      color: formState.passwordError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.passwordError != null
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  errorText: formState.confirmPasswordError,
                  errorStyle: const TextStyle(color: Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.confirmPasswordError != null
                          ? Colors.red
                          : Colors.grey,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: formState.confirmPasswordError != null
                          ? Colors.red
                          : Colors.blue,
                    ),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: formState.isLoading ? null : _handleSignUp,
                    child: formState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Sign Up'),
                  ),
                  ElevatedButton(
                    onPressed: _returnToLogin,
                    child: const Text('Back'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
