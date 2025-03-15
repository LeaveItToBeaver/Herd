import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import '../../../user/view/providers/current_user_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  final bool isPrivate;

  const CreatePostScreen({
    super.key,
    this.isPrivate = false, // Default to public posts
  });

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _content = '';
  File? _postImage;
  bool _isSubmitting = false;
  late bool _isPrivate;

  @override
  void initState() {
    super.initState();
    // Initialize with the provided value
    _isPrivate = widget.isPrivate;
  }

  @override
  Widget build(BuildContext context) {
    final postState = ref.watch(postControllerProvider);
    final currentUser = ref.watch(currentUserProvider);
    final currentFeed = ref.watch(currentFeedProvider);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(_isPrivate ? "Create Private Post" : "Create Public Post"),
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
    // Get theme for consistent styling
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Privacy toggle card at the top
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: _isPrivate ? Colors.blue : Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Post Privacy',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isPrivate,
                        activeColor: Colors.blue,
                        onChanged: (value) {
                          setState(() {
                            _isPrivate = value;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        _isPrivate ? Icons.lock : Icons.public,
                        color: _isPrivate ? Colors.blue : Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isPrivate ? 'Private Post' : 'Public Post',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _isPrivate ? Colors.blue : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isPrivate
                        ? 'Only visible to your private connections.'
                        : 'Visible to everyone in your public feed.',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          _imagePicker(context),

          const SizedBox(height: 16),

          _buildPostForm(context),

          const SizedBox(height: 24),

          // Submit button at the bottom
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: Icon(
                _isPrivate ? Icons.lock : Icons.send,
                color: Colors.white,
              ),
              label: Text(
                _isPrivate ? 'Post Privately' : 'Post Publicly',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPrivate ? Colors.blue : Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: _isSubmitting
                  ? null
                  : () {
                if (currentUser != null) {
                  _submitForm(context, currentUser);
                }
              },
            ),
          ),
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
          border: Border.all(
            color: _isPrivate ? Colors.blue.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: _postImage != null
            ? ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(_postImage!, fit: BoxFit.cover),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 64,
              color: _isPrivate ? Colors.blue.withOpacity(0.7) : Colors.black54,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to add an image',
              style: TextStyle(
                color: _isPrivate ? Colors.blue.withOpacity(0.7) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostForm(BuildContext context) {
    final borderColor = _isPrivate ? Colors.blue.withOpacity(0.3) : Colors.grey.shade300;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            enabled: !_isSubmitting,
            decoration: InputDecoration(
              labelText: 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _isPrivate ? Colors.blue : Colors.black,
                  width: 2,
                ),
              ),
              prefixIcon: Icon(
                Icons.title,
                color: _isPrivate ? Colors.blue : null,
              ),
            ),
            onChanged: (value) => _title = value,
            validator: (value) =>
            value == null || value.isEmpty ? 'Title cannot be empty.' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            enabled: !_isSubmitting,
            maxLines: 7,
            decoration: InputDecoration(
              labelText: 'Content',
              alignLabelWithHint: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: _isPrivate ? Colors.blue : Colors.black,
                  width: 2,
                ),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: Icon(
                  Icons.article,
                  color: _isPrivate ? Colors.blue : null,
                ),
              ),
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
        isPrivate: _isPrivate, // Pass privacy setting to controller
      );

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isPrivate
                ? 'Private post created successfully!'
                : 'Post created successfully!'),
            backgroundColor: _isPrivate ? Colors.blue : Colors.green,
          ),
        );

        // Navigate to the post
        context.go('/post/$postId?isPrivate=${_isPrivate}');
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