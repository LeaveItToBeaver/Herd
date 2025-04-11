// lib/features/herds/view/screens/create_herd_screen.dart
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/herds/data/models/herd_model.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class CreateHerdScreen extends ConsumerStatefulWidget {
  const CreateHerdScreen({super.key});

  @override
  ConsumerState<CreateHerdScreen> createState() => _CreateHerdScreenState();
}

class _CreateHerdScreenState extends ConsumerState<CreateHerdScreen> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _description = '';
  bool _isPrivate = false;
  File? _profileImage;
  File? _coverImage;
  bool _isSubmitting = false;

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
                GestureDetector(
                  onTap: _selectCoverImage,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      image: _coverImage != null
                          ? DecorationImage(
                        image: FileImage(_coverImage!),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _coverImage == null
                        ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40),
                          SizedBox(height: 8),
                          Text('Add Cover Image'),
                        ],
                      ),
                    )
                        : null,
                  ),
                ),

                const SizedBox(height: 16),

                // Profile image picker
                Center(
                  child: GestureDetector(
                    onTap: _selectProfileImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Herd Name',
                    prefixIcon: Icon(Icons.group),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    if (value.length < 3) {
                      return 'Name must be at least 3 characters';
                    }
                    return null;
                  },
                  onChanged: (value) => _name = value,
                ),

                const SizedBox(height: 16),

                // Description field
                TextFormField(
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
                ),

                const SizedBox(height: 16),

                // Privacy toggle
                SwitchListTile(
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
                ),

                const SizedBox(height: 24),

                // Submit button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : () => _submitForm(currentUser?.uid),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Create Herd'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    final image = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.circle,
      title: 'Herd Profile Image',
    );

    if (image != null) {
      setState(() {
        _profileImage = image;
      });
    }
  }

  Future<void> _selectCoverImage() async {
    final image = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Herd Cover Image',
    );

    if (image != null) {
      setState(() {
        _coverImage = image;
      });
    }
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
        creatorId: userId,
        isPrivate: _isPrivate,
      );

      // Create the herd and get its ID
      final herdId = await repository.createHerd(herd, userId);

      // Upload images if selected
      if (_profileImage != null || _coverImage != null) {
        final storage = FirebaseStorage.instance;

        // Upload profile image
        if (_profileImage != null) {
          final profileRef = storage.ref().child('herds/$herdId/profile.jpg');
          await profileRef.putFile(_profileImage!);
          final profileImageURL = await profileRef.getDownloadURL();

          await repository.updateHerd(
            herdId,
            {'profileImageURL': profileImageURL},
            userId,
          );
        }

        // Upload cover image
        if (_coverImage != null) {
          final coverRef = storage.ref().child('herds/$herdId/cover.jpg');
          await coverRef.putFile(_coverImage!);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating herd: $e')),
        );

        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}