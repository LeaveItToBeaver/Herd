import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        ),
        body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
            : postState.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stackTrace) => Center(child: Text('Error: $error')),
          data: (_) => SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _imagePicker(context),
                const SizedBox(height: 16),
                _buildPostForm(context),
                const SizedBox(height: 16),
                ElevatedButton(
                    onPressed: () => _submitForm(context, currentUser),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)
                      )
                    ),
                    child: const Text(
                        "Post", 
                        style: TextStyle(color: Colors.white)
                    ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagePicker(BuildContext context) {
    return GestureDetector(
      onTap: () async {
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
            _showErrorDialog(context, 'Failed to pick and crop the image: $e');
          }
        }
      },
      child: Container(
        height: MediaQuery.of(context).size.height / 3,
        width: double.infinity,
        color: Colors.grey[200],
        child: _postImage != null
            ? Image.file(_postImage!, fit: BoxFit.cover)
            : const Icon(Icons.image, size: 100, color: Colors.black),
      ),
    );
  }

  Widget _buildPostForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
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

  void _submitForm(BuildContext context, UserModel currentUser) {
    if (_formKey.currentState!.validate()) {
      ref.read(postControllerProvider.notifier).createPost(
        title: _title,
        content: _content,
        imageFile: _postImage,
        userId: currentUser.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Your post is being created..."),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
