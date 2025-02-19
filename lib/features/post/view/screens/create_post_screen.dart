import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import '../../../user/view/providers/current_user_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  File? _postImage;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postControllerProvider);
    final currentUser = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text("Create a Post"),
          actions: [
            // Add submit button in app bar
            if (!_isSubmitting)
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (currentUser != null) {
                    _submitForm(context, currentUser);
                  }
                },
              ),
            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
        body: currentUser == null
            ? const Center(child: CircularProgressIndicator())
            : postState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => _buildForm(context, currentUser),
          data: (_) => _buildForm(context, currentUser),
        ),
      ),
    );
  }

  Widget _buildForm(BuildContext context, UserModel currentUser) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _imagePicker(context),
          const SizedBox(height: 16),
          _buildPostForm(context),
        ],
      ),
    );
  }

  Widget _imagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (_isSubmitting) return; // Prevent changing image while submitting

        try {
          final pickedFile = await ImageHelper.pickImageFromGallery(
            context: context,
            cropStyle: CropStyle.rectangle,
            title: 'Select Post Image',
          );
          setState(() {
            _postImage = pickedFile;
          });
        } catch (e) {
          if (context.mounted) {
            _showErrorSnackBar(context, 'Failed to pick image. Please try again.');
          }
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: _postImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_postImage!, fit: BoxFit.cover),
        )
            : const Icon(Icons.image, size: 100, color: Colors.black54),
      ),
    );
  }

  Widget _buildPostForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            enabled: !_isSubmitting,
            decoration: const InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.title),
            ),
            onChanged: (value) => _title = value,
            validator: (value) =>
            value == null || value.isEmpty ? 'Title cannot be empty.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: !_isSubmitting,
            maxLines: null,
            decoration: const InputDecoration(
              labelText: 'Content',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.article),
            ),
            onChanged: (value) => _content = value,
          ),
        ],
      ),
    );
  }

  Future<void> _submitForm(BuildContext context, UserModel currentUser) async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final postId = await ref.read(postControllerProvider.notifier).createPost(
        title: _title,
        content: _content,
        imageFile: _postImage,
        userId: currentUser.id,
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post created successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to the post
        context.go('/post/$postId');
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(
          context,
          'There was an issue creating the post. Try again.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}