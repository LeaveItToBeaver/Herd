import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/social/comment/view/providers/comment_providers.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class CommentInputField extends ConsumerStatefulWidget {
  final String postId;
  final bool isAltPost;

  const CommentInputField({
    super.key,
    required this.postId,
    required this.isAltPost,
  });

  @override
  ConsumerState<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends ConsumerState<CommentInputField> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  File? _mediaFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('Rebuilding CommentInputField');
    // Get user data for UI - only watch what we need
    final currentUserAsync = ref.watch(currentUserProvider.select((value) => (
          value.userId,
          value.safeProfileImageURL,
          value.safeAltProfileImageURL
        )));

    final userId = currentUserAsync.$1;
    final profileImageUrl = widget.isAltPost
        ? currentUserAsync.$3 ?? currentUserAsync.$2
        : currentUserAsync.$2;

    if (userId == null) {
      // No user logged in, show login prompt instead
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: Text('Please log in to comment'),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar
          CircleAvatar(
            radius: 20,
            backgroundImage:
                profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
            child: profileImageUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 12),

          // Comment input field
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _commentController,
                  focusNode: _commentFocusNode,
                  keyboardType: TextInputType.multiline,
                  textCapitalization: TextCapitalization.sentences,
                  enableSuggestions: true,
                  decoration: InputDecoration(
                    hintText: 'Write a comment...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  minLines: 1,
                  maxLines: 5,
                ),

                // Media attachment row
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.photo, size: 20),
                      onPressed: _isSubmitting ? null : _pickImage,
                      tooltip: 'Add image',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.gif_box, size: 20),
                      onPressed: _isSubmitting ? null : _pickGif,
                      tooltip: 'Add GIF',
                    ),
                    if (_mediaFile != null) ...[
                      const Spacer(),
                      Text(
                        'Media selected',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 12,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.clear, size: 16),
                        onPressed: () => setState(() => _mediaFile = null),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          // Submit button
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: IconButton(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isSubmitting ? null : _submitComment,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Select Image',
    );

    if (file != null) {
      setState(() => _mediaFile = file);
    }
  }

  Future<void> _pickGif() async {
    // This would ideally use a GIF picker library
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GIF picker not yet implemented')),
    );
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment or attach media')),
      );
      return;
    }

    final currentUserAsync = ref.read(currentUserProvider);
    final userId = currentUserAsync.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(commentsProvider(widget.postId).notifier).createComment(
          authorId: userId,
          content: _commentController.text.trim(),
          isAltPost: widget.isAltPost,
          authorName:
              '${currentUserAsync.firstName} ${currentUserAsync.lastName}',
          authorUsername: currentUserAsync.userName,
          authorProfileImage: widget.isAltPost
              ? currentUserAsync.safeAltProfileImageURL
              : currentUserAsync.safeProfileImageURL,
          mediaFile: _mediaFile,
          ref: ref);

      _commentController.clear();
      setState(() => _mediaFile = null);
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding comment: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
