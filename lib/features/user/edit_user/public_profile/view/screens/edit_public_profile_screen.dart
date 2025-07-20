import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/services/image_helper.dart';
import '../providers/edit_public_profile_notifier.dart';

class PublicProfileEditScreen extends ConsumerStatefulWidget {
  final UserModel user;

  const PublicProfileEditScreen({
    super.key,
    required this.user,
  });

  @override
  ConsumerState<PublicProfileEditScreen> createState() =>
      _PublicProfileEditScreenState();
}

class _PublicProfileEditScreenState
    extends ConsumerState<PublicProfileEditScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  late bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.user.firstName ?? '';
    _lastNameController.text = widget.user.lastName ?? '';
    _bioController.text = widget.user.bio ?? '';
  }

  void _saveChanges() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isSaving = true;
      });

      try {
        ref
            .read(editPublicProfileProvider(widget.user).notifier)
            .bioChanged(_bioController.text);
        ref
            .read(editPublicProfileProvider(widget.user).notifier)
            .firstNameChanged(_firstNameController.text);
        ref
            .read(editPublicProfileProvider(widget.user).notifier)
            .lastNameChanged(_lastNameController.text);
        await ref
            .read(editPublicProfileProvider(widget.user).notifier)
            .submit();
        if (mounted) {
          if (ref.read(editPublicProfileProvider(widget.user)).errorMessage ==
                  null &&
              context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text("Public profile updated successfully.")),
            );

            // Return true to indicate the profile was updated
            context.pop(true);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update profile')),
          );
        }
      } finally {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final image = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.circle,
      title: 'Profile Image',
    );
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
      ref
          .read(editPublicProfileProvider(widget.user).notifier)
          .profileImageChanged(_profileImage);
    }
  }

  Future<void> _pickCoverImage() async {
    final image = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Profile Cover Image',
    );
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
      });
      ref
          .read(editPublicProfileProvider(widget.user).notifier)
          .coverImageChanged(_coverImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editPublicProfileProvider(widget.user));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Public Profile'),
        actions: [
          TextButton(
            onPressed: state.isSubmitting ? null : _saveChanges,
            child: state.isSubmitting
                ? const CircularProgressIndicator()
                : const Text('Save'),
          ),
        ],
      ),
      body: state.isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.errorMessage != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      color: theme.colorScheme.error.withValues(alpha: 0.1),
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ),

                  // Cover image
                  GestureDetector(
                    onTap: _pickCoverImage,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        UserCoverImage(
                          isSelected: true,
                          coverImageUrl: widget.user.coverImageURL,
                          coverFile: _coverImage,
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile image (overlapping cover image)
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Center(
                      child: GestureDetector(
                        onTap: _pickProfileImage,
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.scaffoldBackgroundColor,
                                  width: 4,
                                ),
                              ),
                              child: UserProfileImage(
                                radius: 60,
                                profileImageUrl: widget.user.profileImageURL,
                                profileImage: _profileImage,
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: theme.scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  color: theme.colorScheme.onPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Form
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section title
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Personal Information',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),

                          // Name fields - side by side
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // First name
                              Expanded(
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'First Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your first name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              // Last name
                              Expanded(
                                child: TextFormField(
                                  controller: _lastNameController,
                                  decoration: const InputDecoration(
                                    labelText: 'Last Name',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your last name';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Bio field
                          TextFormField(
                            controller: _bioController,
                            maxLines: 5,
                            maxLength: 200,
                            decoration: const InputDecoration(
                              labelText: 'Bio',
                              hintText: 'Tell others about yourself...',
                              border: OutlineInputBorder(),
                              alignLabelWithHint: true,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Divider
                          const Divider(),

                          const SizedBox(height: 16),

                          // Section title
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              'Privacy & Visibility',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),

                          // Privacy note
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: theme.colorScheme.outline
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.public,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Public Profile',
                                      style:
                                          theme.textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'This information will be visible to everyone on your public profile. Use your public profile to build your brand and connect with a wider audience.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: state.isSubmitting
                                  ? null
                                  : () async {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        // Update form data
                                        ref.read(editPublicProfileProvider(
                                                widget.user)
                                            .notifier)
                                          ..firstNameChanged(
                                              _firstNameController.text)
                                          ..lastNameChanged(
                                              _lastNameController.text)
                                          ..bioChanged(_bioController.text);

                                        await ref
                                            .read(editPublicProfileProvider(
                                                    widget.user)
                                                .notifier)
                                            .submit();

                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                                content: Text(
                                                    "Profile updated successfully")),
                                          );

                                          // Return true to indicate the profile was updated
                                          context.pop(true);
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: theme.colorScheme.onPrimary,
                                backgroundColor: theme.colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Save Changes',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
