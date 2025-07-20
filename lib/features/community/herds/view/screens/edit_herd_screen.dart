import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/community/herds/data/models/herd_model.dart';
import 'package:herdapp/features/community/herds/view/providers/herd_providers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class EditHerdScreen extends ConsumerStatefulWidget {
  final HerdModel herd;

  const EditHerdScreen({super.key, required this.herd});

  @override
  ConsumerState<EditHerdScreen> createState() => _EditHerdScreenState();
}

class _EditHerdScreenState extends ConsumerState<EditHerdScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _profileImage;
  File? _coverImage;
  final ImagePicker _picker = ImagePicker();

  final List<String> availableInterests = [
    'Comedy',
    'Drama',
    'Fantasy',
    'Horror',
    'Mystery',
    'Romance',
    'Thriller',
    'NSFW',
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

  late String _name;
  late String _description;
  late String _rules;
  late String _faq;
  late bool _isPrivate;
  late List<String> _selectedInterests;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize fields with herd data
    _name = widget.herd.name;
    _description = widget.herd.description;
    _rules = widget.herd.rules;
    _faq = widget.herd.faq;
    _isPrivate = widget.herd.isPrivate;

    // Initialize interests from herd
    _selectedInterests = List<String>.from(widget.herd.interests ?? []);
  }

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
    final isCreator = widget.herd.creatorId == currentUser?.uid;
    final isModerator = ref.watch(isHerdModeratorProvider(widget.herd.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Herd'),
      ),
      body: isModerator.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
            ],
          ),
        ),
        data: (canEdit) {
          if (!canEdit) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.block, size: 48, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'You do not have permission to edit this herd',
                    textAlign: TextAlign.center,
                  ),
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
                          : (widget.herd.coverImageURL != null
                              ? DecorationImage(
                                  image:
                                      NetworkImage(widget.herd.coverImageURL!),
                                  fit: BoxFit.cover,
                                )
                              : null),
                    ),
                    child: (_coverImage == null &&
                            widget.herd.coverImageURL == null)
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
                          : (widget.herd.profileImageURL != null
                              ? NetworkImage(widget.herd.profileImageURL!)
                              : null),
                      child: (_profileImage == null &&
                              widget.herd.profileImageURL == null)
                          ? const Icon(Icons.add_a_photo, size: 30)
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  initialValue: _name,
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
                  initialValue: _description,
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

                // Rules field (only for creators)
                if (isCreator)
                  TextFormField(
                    initialValue: _rules,
                    decoration: const InputDecoration(
                      labelText: 'Rules (optional)',
                      prefixIcon: Icon(Icons.rule),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    onChanged: (value) => _rules = value,
                  ),

                if (isCreator) const SizedBox(height: 16),

                // FAQ field (only for creators)
                if (isCreator)
                  TextFormField(
                    initialValue: _faq,
                    decoration: const InputDecoration(
                      labelText: 'FAQ (optional)',
                      prefixIcon: Icon(Icons.question_answer),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 5,
                    onChanged: (value) => _faq = value,
                  ),

                if (isCreator) const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Herd Interests',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Choose interests that define what your herd is about',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: 16),

                      // Interest chips
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableInterests.map((interest) {
                          final isSelected =
                              _selectedInterests.contains(interest);
                          return FilterChip(
                            label: Text(interest),
                            selected: isSelected,
                            onSelected: (_) => _toggleInterest(interest),
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            selectedColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                // Privacy toggle (only for creators)
                if (isCreator)
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
                  onPressed: _isSubmitting
                      ? null
                      : () => _submitForm(currentUser?.uid),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text('Save Changes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _selectProfileImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _profileImage = File(image.path);
      });
    }
  }

  Future<void> _selectCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _coverImage = File(image.path);
      });
    }
  }

  // Future<void> _selectProfileImage() async {
  //   final image = await ImageHelper.pickImageFromGallery(
  //     context: context,
  //     cropStyle: CropStyle.circle,
  //     title: 'Herd Profile Image',
  //   );
  //
  //   if (image != null) {
  //     setState(() {
  //       _profileImage = image;
  //     });
  //   }
  // }
  //
  // Future<void> _selectCoverImage() async {
  //   final image = await ImageHelper.pickImageFromGallery(
  //     context: context,
  //     cropStyle: CropStyle.rectangle,
  //     title: 'Herd Cover Image',
  //   );
  //
  //   if (image != null) {
  //     setState(() {
  //       _coverImage = image;
  //     });
  //   }
  // }

  Future<void> _submitForm(String? userId) async {
    if (_formKey.currentState?.validate() != true || userId == null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final repository = ref.read(herdRepositoryProvider);

      // Create a map of the fields to update
      final Map<String, dynamic> updateData = {
        'name': _name,
        'description': _description,
        'interests': _selectedInterests, // Add this line to include interests
      };

      // Only creators can update these fields
      if (widget.herd.creatorId == userId) {
        updateData['rules'] = _rules;
        updateData['faq'] = _faq;
        updateData['isPrivate'] = _isPrivate;
      }

      // Update the herd data first
      await repository.updateHerd(widget.herd.id, updateData, userId);

      // Handle image uploads if any
      if (_profileImage != null || _coverImage != null) {
        final storage = FirebaseStorage.instance;

        // Upload profile image
        if (_profileImage != null) {
          // Get the file extension from the path
          final fileExtension =
              path.extension(_profileImage!.path).toLowerCase();
          // Use the original file extension (or default to .jpg if none found)
          final storageExt = fileExtension.isNotEmpty ? fileExtension : '.jpg';

          final profileRef =
              storage.ref().child('herds/${widget.herd.id}/profile$storageExt');
          await profileRef.putFile(_profileImage!);
          final profileImageURL = await profileRef.getDownloadURL();

          await repository.updateHerd(
            widget.herd.id,
            {'profileImageURL': profileImageURL},
            userId,
          );
        }

        // Upload cover image
        if (_coverImage != null) {
          // Get the file extension from the path
          final fileExtension = path.extension(_coverImage!.path).toLowerCase();
          // Use the original file extension (or default to .jpg if none found)
          final storageExt = fileExtension.isNotEmpty ? fileExtension : '.jpg';

          final coverRef =
              storage.ref().child('herds/${widget.herd.id}/cover$storageExt');
          await coverRef.putFile(_coverImage!);
          final coverImageURL = await coverRef.getDownloadURL();

          await repository.updateHerd(
            widget.herd.id,
            {'coverImageURL': coverImageURL},
            userId,
          );
        }
      }

      if (mounted) {
        // Show success and navigate back
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Herd updated successfully')),
        );

        // Go back to the herd page
        context.pop();
        // Refresh herd view
        ref.invalidate(herdProvider(widget.herd.id));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating herd: $e')),
        );

        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}
