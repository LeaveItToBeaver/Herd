import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/core/utils/validators.dart';

import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  // Controllers
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Interest categories
  final List<String> availableInterests = [
    'Technology',
    'Science',
    'Art',
    'Music',
    'Sports',
    'Gaming',
    'Reading',
    'Writing',
    'Cooking',
    'Travel',
    'Photography',
    'Film',
    'Fashion',
    'Fitness',
    'Nature',
    'Politics',
    'Education',
    'Business',
    'Finance',
    'Health'
  ];

  bool _isCheckingUsername = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _collectDeviceInfo();

    // Reset legal acceptance state when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(legalAcceptanceProvider.notifier).state = {
        'terms': false,
        'privacy': false,
      };
    });
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    bioController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Collect device information in the background
  Future<void> _collectDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      Map<String, dynamic> deviceData = {};

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'platform': 'Android',
          'device': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'os_version': androidInfo.version.release,
          'timezone': DateTime.now().timeZoneOffset.toString(),
          'locale': PlatformDispatcher.instance.locale.toString(),
          'app_version': packageInfo.version,
          'build_number': packageInfo.buildNumber,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'platform': 'iOS',
          'device': iosInfo.model,
          'system_name': iosInfo.systemName,
          'system_version': iosInfo.systemVersion,
          'timezone': DateTime.now().timeZoneOffset.toString(),
          'locale': PlatformDispatcher.instance.locale.toString(),
          'app_version': packageInfo.version,
          'build_number': packageInfo.buildNumber,
        };
      }

      if (mounted) {
        ref.read(signUpFormProvider.notifier).state =
            ref.read(signUpFormProvider).copyWith(deviceInfo: deviceData);
      }
    } catch (e) {
      // Silently fail - device info is not critical
      if (kDebugMode) {
        debugPrint('Failed to collect device info: $e');
      }
    }
  }

  // Handle username changes and availability check
  void _onUsernameChanged(String value) async {
    if (value.isEmpty) return;

    setState(() => _isCheckingUsername = true);

    try {
      final isAvailable = await _isUsernameAvailable(value);

      if (mounted) {
        ref.read(signUpFormProvider.notifier).state = ref
            .read(signUpFormProvider)
            .copyWith(
              usernameError: !isAvailable ? 'Username is already taken' : null,
            );
        setState(() => _isCheckingUsername = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCheckingUsername = false);
      }
    }
  }

  // Check if username is available
  Future<bool> _isUsernameAvailable(String username) async {
    if (username.isEmpty) return false;

    try {
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      return result.docs.isEmpty;
    } catch (e) {
      debugPrint('Error checking username availability: $e');
      return false;
    }
  }

  // Navigate to previous step
  void _previousStep() {
    if (ref.read(signUpFormProvider).currentStep > 0) {
      final currentStep = ref.read(signUpFormProvider).currentStep - 1;
      ref.read(signUpFormProvider.notifier).state =
          ref.read(signUpFormProvider).copyWith(currentStep: currentStep);
      _pageController.animateToPage(
        currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Go back to login screen
      context.go('/login');
    }
  }

  // Navigate to next step
  void _nextStep() {
    final currentStep = ref.read(signUpFormProvider).currentStep;

    // Validate current step
    if (!_validateCurrentStep(currentStep)) {
      return;
    }

    final nextStep = currentStep + 1;
    ref.read(signUpFormProvider.notifier).state =
        ref.read(signUpFormProvider).copyWith(currentStep: nextStep);
    _pageController.animateToPage(
      nextStep,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    // If last step, submit the form
    if (nextStep >= 3) {
      _handleSignUp();
    }
  }

  // Validate the current step
  bool _validateCurrentStep(int step) {
    switch (step) {
      case 0:
        // Basic Information
        if (firstNameController.text.trim().isEmpty) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    firstNameError: 'First name is required',
                  );
          return false;
        }

        if (lastNameController.text.trim().isEmpty) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    lastNameError: 'Last name is required',
                  );
          return false;
        }

        if (ref.read(signUpFormProvider).dateOfBirth == null) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    dateOfBirthError: 'Date of birth is required',
                  );
          return false;
        }

        if (usernameController.text.trim().isEmpty) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    usernameError: 'Username is required',
                  );
          return false;
        }

        if (ref.read(signUpFormProvider).usernameError != null) {
          // Username has an error (likely already taken)
          return false;
        }

        final now = DateTime.now();
        final thirteenYearsAgo = DateTime(now.year - 13, now.month, now.day);
        if (ref
            .read(signUpFormProvider)
            .dateOfBirth!
            .isAfter(thirteenYearsAgo)) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    dateOfBirthError: 'You must be at least 13 years old',
                  );
          return false;
        }

        return true;

      case 1:
        // Account security
        final email = emailController.text.trim();
        final password = passwordController.text;
        final confirmPassword = confirmPasswordController.text;

        if (email.isEmpty || !Validators.isValidEmail(email)) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    emailError: 'Please enter a valid email',
                  );
          return false;
        }

        if (password.length < 8) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    passwordError: 'Password must be at least 8 characters',
                  );
          return false;
        }

        if (!Validators.isStrongPassword(password)) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    passwordError:
                        'Password should include uppercase, lowercase, numbers, and special characters',
                  );
          return false;
        }

        if (password != confirmPassword) {
          ref.read(signUpFormProvider.notifier).state =
              ref.read(signUpFormProvider).copyWith(
                    confirmPasswordError: 'Passwords do not match',
                  );
          return false;
        }

        return true;

      case 2:
        final legalAcceptance = ref.read(legalAcceptanceProvider);
        final hasAcceptedTerms = legalAcceptance['terms'] ?? false;
        final hasAcceptedPrivacy = legalAcceptance['privacy'] ?? false;

        if (!hasAcceptedTerms || !hasAcceptedPrivacy) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'You must accept both the Terms of Service and Privacy Policy to continue'),
              backgroundColor: Colors.red,
            ),
          );
          return false;
        }

        // Update the signup form state to match
        ref.read(signUpFormProvider.notifier).state =
            ref.read(signUpFormProvider).copyWith(
                  acceptedTerms: hasAcceptedTerms,
                  acceptedPrivacy: hasAcceptedPrivacy,
                );

        return true;

      default:
        return true;
    }
  }

  // Pick profile image
  Future<void> _pickProfileImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        ref.read(signUpFormProvider.notifier).state = ref
            .read(signUpFormProvider)
            .copyWith(profileImage: File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Toggle interest selection
  void _toggleInterest(String interest) {
    final selectedInterests =
        List<String>.from(ref.read(signUpFormProvider).selectedInterests);

    if (selectedInterests.contains(interest)) {
      selectedInterests.remove(interest);
    } else {
      selectedInterests.add(interest);
    }

    ref.read(signUpFormProvider.notifier).state = ref
        .read(signUpFormProvider)
        .copyWith(selectedInterests: selectedInterests);
  }

  // Handle sign up
  Future<void> _handleSignUp() async {
    // Set loading state
    ref.read(signUpFormProvider.notifier).state =
        ref.read(signUpFormProvider).copyWith(isLoading: true);

    try {
      final firstName = firstNameController.text.trim();
      final lastName = lastNameController.text.trim();
      final username = usernameController.text.trim().toLowerCase();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final bio = bioController.text.trim();
      final formState = ref.read(signUpFormProvider);

      final legalAcceptance = ref.read(legalAcceptanceProvider);
      final hasAcceptedTerms = legalAcceptance['terms'] ?? false;
      final hasAcceptedPrivacy = legalAcceptance['privacy'] ?? false;

      // Check if both terms and privacy policy are accepted
      if (!hasAcceptedTerms || !hasAcceptedPrivacy) {
        // If not accepted, go back to the legal step
        ref.read(signUpFormProvider.notifier).state = formState.copyWith(
          isLoading: false,
          currentStep: 2, // Assuming legal step is step 2
        );
        _pageController.animateToPage(
          2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'You must accept both the Terms of Service and Privacy Policy to continue'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Double-check username availability
      final isAvailable = await _isUsernameAvailable(username);
      if (!isAvailable) {
        ref.read(signUpFormProvider.notifier).state = formState.copyWith(
          usernameError: 'Username is already taken',
          isLoading: false,
        );

        // Go back to first step
        ref.read(signUpFormProvider.notifier).state = formState.copyWith(
          currentStep: 0,
          isLoading: false,
        );
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        return;
      }

      // Create user account
      final userRepository = ref.read(userRepositoryProvider);
      final auth = ref.read(authProvider.notifier);

      // Sign up user and get credentials
      final userCredential = await auth.signUp(email, password);

      // Upload profile image if selected
      String? profileImageURL;
      if (formState.profileImage != null) {
        profileImageURL = await userRepository.uploadImage(
          userId: userCredential.user!.uid,
          file: formState.profileImage!,
          type: 'profile',
        );
      }

      // Create user model with collected data
      final user = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName,
        lastName: lastName,
        username: username,
        email: email,
        bio: bio.isNotEmpty ? bio : null,
        profileImageURL: profileImageURL,
        interests: formState.selectedInterests,
        acceptedLegal: true,
        preferences: {
          'theme': 'system', // default theme preference
          'notifications': true, // default notification preference
        },
        timezone: formState.deviceInfo['timezone'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        dateOfBirth: formState.dateOfBirth,
      );

      // Create user document in Firestore
      await userRepository.createUser(userCredential.user!.uid, user);

      final notificationRepo = ref.read(notificationRepositoryProvider);
      await notificationRepo.initializeFCM();

      // Send email verification
      await userCredential.user!.sendEmailVerification();

      if (mounted) {
        // Navigate to verification screen or directly to profile
        context.go('/emailVerification',
            extra: {'email': emailController.text.trim()});
      }
    } catch (e) {
      String errorMessage = 'An error occurred';

      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email is already registered';
        ref.read(signUpFormProvider.notifier).state =
            ref.read(signUpFormProvider).copyWith(
                  emailError: errorMessage,
                  isLoading: false,
                  currentStep: 1,
                );
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (e.toString().contains('invalid-email')) {
        errorMessage = 'Invalid email format';
        ref.read(signUpFormProvider.notifier).state =
            ref.read(signUpFormProvider).copyWith(
                  emailError: errorMessage,
                  isLoading: false,
                  currentStep: 1,
                );
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
        ref.read(signUpFormProvider.notifier).state =
            ref.read(signUpFormProvider).copyWith(
                  passwordError: errorMessage,
                  isLoading: false,
                  currentStep: 1,
                );
        _pageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        // Generic error, reset loading state
        ref.read(signUpFormProvider.notifier).state =
            ref.read(signUpFormProvider).copyWith(
                  isLoading: false,
                );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // Show full terms of service
  Widget _buildLegalAgreementsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: LegalDocumentsSection(
        onValidAcceptance: () {
          // This callback is triggered when both documents are accepted
          // Move to the next step or complete signup
          _nextStep();
        },
      ),
    );
  }

  void _onDateOfBirthSelected(DateTime date) {
    ref.read(signUpFormProvider.notifier).state =
        ref.read(signUpFormProvider).copyWith(
              dateOfBirth: date,
              dateOfBirthError: null,
            );
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(signUpFormProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _previousStep,
        ),
        title: const Text('Create Account'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Step indicator
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        height: 4,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: index <= formState.currentStep
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Page content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1: Basic Information
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tell us about yourself',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'This information will be displayed on your public profile',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Profile image selection
                          Center(
                            child: GestureDetector(
                              onTap: _pickProfileImage,
                              child: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 60,
                                    backgroundColor: theme
                                        .colorScheme.surfaceContainerHighest,
                                    backgroundImage:
                                        formState.profileImage != null
                                            ? FileImage(formState.profileImage!)
                                            : null,
                                    child: formState.profileImage == null
                                        ? Icon(
                                            Icons.person,
                                            size: 60,
                                            color: theme
                                                .colorScheme.onSurfaceVariant,
                                          )
                                        : null,
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.camera_alt,
                                        size: 24,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // First name field
                          CustomTextField(
                            controller: firstNameController,
                            hintText: 'First Name',
                            errorText: formState.firstNameError,
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) {
                              if (formState.firstNameError != null) {
                                ref.read(signUpFormProvider.notifier).state =
                                    formState.copyWith(firstNameError: null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Last name field
                          CustomTextField(
                            controller: lastNameController,
                            hintText: 'Last Name',
                            errorText: formState.lastNameError,
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (_) {
                              if (formState.lastNameError != null) {
                                ref.read(signUpFormProvider.notifier).state =
                                    formState.copyWith(lastNameError: null);
                              }
                            },
                          ),

                          const SizedBox(height: 16),

                          DateSelector(
                            initialDate: formState.dateOfBirth,
                            onDateSelected: _onDateOfBirthSelected,
                            labelText: 'Date of Birth',
                            errorText: formState.dateOfBirthError,
                          ),

                          const SizedBox(height: 16),

                          // Username field
                          CustomTextField(
                            controller: usernameController,
                            hintText: 'Username',
                            errorText: formState.usernameError,
                            prefixIcon: Icons.alternate_email,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _onUsernameChanged(value);
                            },
                            suffix: _isCheckingUsername
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2),
                                  )
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Bio field
                          CustomTextField(
                            controller: bioController,
                            hintText: 'Bio (optional)',
                            errorText: formState.bioError,
                            prefixIcon: Icons.description_outlined,
                            textInputAction: TextInputAction.next,
                            maxLines: 3,
                            maxLength: 150,
                            textCapitalization: TextCapitalization.sentences,
                          ),

                          // Interests section
                          const SizedBox(height: 24),
                          Text(
                            'Select your interests',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Choose at least 3 interests to help us personalize your experience',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Interest chips
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: availableInterests.map((interest) {
                              final isSelected = formState.selectedInterests
                                  .contains(interest);
                              return FilterChip(
                                label: Text(interest),
                                selected: isSelected,
                                onSelected: (_) => _toggleInterest(interest),
                                backgroundColor:
                                    theme.colorScheme.surfaceContainerHighest,
                                selectedColor:
                                    theme.colorScheme.primaryContainer,
                                checkmarkColor: theme.colorScheme.primary,
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    // Step 2: Account Security
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secure your account',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create a secure account with your email and password',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Email field
                          CustomTextField(
                            controller: emailController,
                            hintText: 'Email',
                            errorText: formState.emailError,
                            prefixIcon: Icons.email_outlined,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (_) {
                              if (formState.emailError != null) {
                                ref.read(signUpFormProvider.notifier).state =
                                    formState.copyWith(emailError: null);
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password field
                          CustomTextField(
                            controller: passwordController,
                            hintText: 'Password',
                            errorText: formState.passwordError,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            onChanged: (_) {
                              if (formState.passwordError != null) {
                                ref.read(signUpFormProvider.notifier).state =
                                    formState.copyWith(passwordError: null);
                              }
                            },
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
                          ),

                          // Password requirements
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              'Password must be at least 8 characters and include uppercase, lowercase, numbers, and special characters',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Confirm password field
                          CustomTextField(
                            controller: confirmPasswordController,
                            hintText: 'Confirm Password',
                            errorText: formState.confirmPasswordError,
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) {
                              if (formState.confirmPasswordError != null) {
                                ref.read(signUpFormProvider.notifier).state =
                                    formState.copyWith(
                                        confirmPasswordError: null);
                              }
                            },
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Step 3: Legal Agreements
                    _buildLegalAgreementsStep(),

                    // Step 4: Account Created (Success)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 80,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Account Created!',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'We\'ve sent a verification email to your inbox. Please verify your email to complete the signup process.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: formState.currentStep < 3
                    ? Row(
                        children: [
                          if (formState.currentStep > 0)
                            OutlinedButton(
                              onPressed: _previousStep,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(100, 56),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Back'),
                            ),
                          if (formState.currentStep > 0)
                            const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: formState.isLoading ? null : _nextStep,
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
                                  : Text(
                                      formState.currentStep == 2
                                          ? 'Create Account'
                                          : 'Next',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      )
                    : FilledButton(
                        onPressed: () => context.go('/login'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Go to Login',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
