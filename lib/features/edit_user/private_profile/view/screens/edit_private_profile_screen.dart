import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/edit_private_profile_notifier.dart';

class PrivateProfileEditScreen extends ConsumerStatefulWidget {
  final UserModel user;
  final bool isInitialSetup;

  const PrivateProfileEditScreen({
    Key? key,
    required this.user,
    this.isInitialSetup = false,
  }) : super(key: key);

  @override
  ConsumerState<PrivateProfileEditScreen> createState() => _PrivateProfileEditScreenState();
}

class _PrivateProfileEditScreenState extends ConsumerState<PrivateProfileEditScreen> {
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _bioController.text = widget.user.privateBio ?? '';
    _usernameController.text = widget.user.username;
  }

  void _saveChanges() async {
    ref.read(editPrivateProfileProvider(widget.user).notifier).bioChanged(_bioController.text);
    ref.read(editPrivateProfileProvider(widget.user).notifier).usernameChanged(_usernameController.text);
    await ref.read(editPrivateProfileProvider(widget.user).notifier).submit();

    if (ref.read(editPrivateProfileProvider(widget.user)).errorMessage == null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Private profile updated sucessfully.")),
      );

      context.pop();

      if (widget.isInitialSetup) {
        context.go('/privateFeed');
      }
    }
  }

  @override
  void dispose() {
    _bioController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      ref.read(editPrivateProfileProvider(widget.user).notifier).profileImageChanged(_profileImage);
    }
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
      });
      ref.read(editPrivateProfileProvider(widget.user).notifier).coverImageChanged(_coverImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editPrivateProfileProvider(widget.user));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isInitialSetup ? 'Set Up Private Profile' : 'Edit Private Profile'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting ? null : _saveChanges,
            child: state.isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.isInitialSetup) ...[
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Your Private Profile',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This is where you can create a separate identity for connecting with closer friends. Your private profile has its own bio, profile picture, and content that won\'t be visible on your public profile.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],

            // Cover image selector
            GestureDetector(
              onTap: _pickCoverImage,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  UserCoverImage(
                    isSelected: true,
                    coverImageUrl: widget.user.privateCoverImageURL,
                    coverFile: _coverImage,
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Profile image selector
            Center(
              child: GestureDetector(
                onTap: _pickProfileImage,
                child: Stack(
                  children: [
                    UserProfileImage(
                      radius: 50,
                      profileImageUrl: widget.user.privateProfileImageURL ?? widget.user.profileImageURL,
                      profileImage: _profileImage,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Form fields
            if (widget.isInitialSetup) ...[
              Text(
                'Username (will be the same as public profile)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _usernameController,
                enabled: false, // Username is shared between profiles
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixText: '@',
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 16),
            ],

            Text(
              'Private Bio',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 5,
              maxLength: 200,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: state.bio.isEmpty ? 'Tell us about yourself in your private profile...' : null,
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Privacy Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSwitchRow(
                      'Show Activity Status',
                      false, // Default value
                          (value) {
                        //TODO: Update setting
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchRow(
                      'Allow Connection Requests',
                      true, // Default value
                          (value) {
                        //TODO: Update setting
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildSwitchRow(
                      'Show Public Profile in Private Feed',
                      true, // Default value
                          (value) {
                        //TODO: Update setting
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            if (widget.isInitialSetup)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'What\'s Next?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'After setting up your private profile, you can create private posts, connect with friends, and join private groups. Switch between your public and private profiles using the feed selector at the bottom of the screen.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow(String label, bool initialValue, Function(bool) onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(label),
        ),
        Switch(
          value: initialValue,
          onChanged: onChanged,
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}