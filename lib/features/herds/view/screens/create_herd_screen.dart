import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as path;

import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/herds/data/models/herd_model.dart';
import 'package:herdapp/features/herds/view/mixins/herd_image_handling_mixin.dart';
import 'package:herdapp/features/herds/view/mixins/herd_validation_mixin.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/herds/view/widgets/interests_selector.dart';

class CreateHerdScreen extends ConsumerStatefulWidget {
  const CreateHerdScreen({super.key});

  @override
  ConsumerState<CreateHerdScreen> createState() => _CreateHerdScreenState();
}

class _CreateHerdScreenState extends ConsumerState<CreateHerdScreen>
    with HerdValidationMixin, HerdImageHandlingMixin {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _description = '';
  bool _isPrivate = false;
  bool _isSubmitting = false;

  // Available interests for herd creation
  static const List<String> _availableInterests = [
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

  final List<String> _selectedInterests = [];

  void _toggleInterest(String interest) {
    setState(() {
      if (_selectedInterests.contains(interest)) {
        _selectedInterests.remove(interest);
      } else {
        _selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final canCreate = ref.watch(canCreateHerdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Herd'),
      ),
      body: canCreate.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Unable to create herd: $error'),
            ],
          ),
        ),
        data: (canCreateHerd) {
          if (!canCreateHerd) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'You don\'t meet the requirements to create a herd yet',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Requirements:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('• At least 100 points'),
                  const Text('• Account age of at least 30 days'),
                ],
              ),
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Cover image picker
                buildCoverImagePicker(),

                const SizedBox(height: 16),

                // Profile image picker
                buildProfileImagePicker(),

                const SizedBox(height: 24),

                // Name field
                _buildNameField(),

                const SizedBox(height: 16),

                // Description field
                _buildDescriptionField(),

                const SizedBox(height: 16),

                // Interests selector
                InterestsSelector(
                  availableInterests: _availableInterests,
                  selectedInterests: _selectedInterests,
                  onToggleInterest: _toggleInterest,
                ),

                // Privacy toggle
                _buildPrivacyToggle(),

                const SizedBox(height: 24),

                // Submit button
                _buildSubmitButton(currentUser?.uid),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build the name input field with validation
  Widget _buildNameField() {
    return TextFormField(
      maxLength: 30,
      decoration: InputDecoration(
        labelText: 'Herd Name',
        prefixIcon: const Icon(Icons.group),
        border: const OutlineInputBorder(),
        helperText:
            'Only letters, numbers, and basic punctuation allowed. No spaces or special characters.',
        helperMaxLines: 3,
        helperStyle: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
        errorText: nameValidationError,
        errorMaxLines: 3,
        errorStyle: TextStyle(
          color: Theme.of(context).colorScheme.error,
          fontSize: 12,
        ),
        suffixIcon: isCheckingName
            ? const SizedBox(
                width: 20,
                height: 20,
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            : nameValidationError == null && _name.length >= 3
                ? const Icon(Icons.check, color: Colors.green)
                : null,
      ),
      validator: validateHerdName,
      onChanged: (value) {
        _name = value;
        validateHerdNameRealTime(value);
      },
    );
  }

  /// Build the description input field
  Widget _buildDescriptionField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Description',
        prefixIcon: Icon(Icons.description),
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a description';
        }
        return null;
      },
      onChanged: (value) => _description = value,
    );
  }

  /// Build the privacy toggle
  Widget _buildPrivacyToggle() {
    return SwitchListTile(
      title: const Text('Private Herd'),
      subtitle: const Text(
        'Only approved members can join and see content',
      ),
      value: _isPrivate,
      onChanged: (value) {
        setState(() {
          _isPrivate = value;
        });
      },
    );
  }

  /// Build the submit button
  Widget _buildSubmitButton(String? userId) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : () => _submitForm(userId),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isSubmitting
          ? const CircularProgressIndicator()
          : const Text('Create Herd'),
    );
  }

  Future<void> _submitForm(String? userId) async {
    if (_formKey.currentState?.validate() != true || userId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(herdRepositoryProvider);

      // Create a new herd model
      final herd = HerdModel(
        id: '', // Will be set by the repository
        name: _name,
        description: _description,
        interests: _selectedInterests,
        creatorId: userId,
        isPrivate: _isPrivate,
      );

      // Create the herd and get its ID
      final herdId = await repository.createHerd(herd, userId);

      // Upload images if selected
      if (profileImage != null || coverImage != null) {
        final storage = FirebaseStorage.instance;

        // Upload profile image with proper extension
        if (profileImage != null) {
          // Get the file extension from the path
          final fileExtension =
              path.extension(profileImage!.path).toLowerCase();
          // Use the original file extension (or default to .jpg if none found)
          final storageExt = fileExtension.isNotEmpty ? fileExtension : '.jpg';

          final profileRef =
              storage.ref().child('herds/$herdId/profile$storageExt');
          await profileRef.putFile(profileImage!);
          final profileImageURL = await profileRef.getDownloadURL();

          await repository.updateHerd(
            herdId,
            {'profileImageURL': profileImageURL},
            userId,
          );
        }

        // Upload cover image with proper extension
        if (coverImage != null) {
          // Get the file extension from the path
          final fileExtension = path.extension(coverImage!.path).toLowerCase();
          // Use the original file extension (or default to .jpg if none found)
          final storageExt = fileExtension.isNotEmpty ? fileExtension : '.jpg';

          final coverRef =
              storage.ref().child('herds/$herdId/cover$storageExt');
          await coverRef.putFile(coverImage!);
          final coverImageURL = await coverRef.getDownloadURL();

          await repository.updateHerd(
            herdId,
            {'coverImageURL': coverImageURL},
            userId,
          );
        }
      }

      if (mounted) {
        // Show success and navigate to the new herd
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Herd created successfully')),
        );

        context.pushNamed('herd', pathParameters: {'id': herdId});
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error creating herd: $e';

        // Provide more user-friendly error messages
        final errorString = e.toString();
        if (errorString.contains('special characters') ||
            errorString.contains('punctuation')) {
          errorMessage =
              'Herd name contains invalid characters.\nPlease use only letters, numbers, and basic punctuation. No spaces or dashes allowed.';
        } else if (errorString.contains('cannot contain spaces')) {
          errorMessage =
              'Herd name cannot contain spaces.\nUse formats like "TestTest" instead of "Test Test".';
        } else if (errorString.contains('already exists')) {
          errorMessage =
              'A herd with this name already exists.\nPlease choose a different name.';
        } else if (errorString.contains('not eligible')) {
          errorMessage =
              'You don\'t meet the requirements to create a herd yet.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );

        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
