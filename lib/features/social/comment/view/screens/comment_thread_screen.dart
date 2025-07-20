import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'package:image_cropper/image_cropper.dart';

// TODO: Add GIF picker functionality - Eh almost done // Ignore this
// TODO: Add comment editing functionality - Need to test
// TODO: Add comment deletion functionality - Need to test
// TODO: Add comment reporting functionality

// TODO: Test the nested reply auto update.
// TODO: Fix the comment threading screen postID error
// TODO: Create cloud functions for loading and updating comments.

class CommentThreadScreen extends ConsumerStatefulWidget {
  final String commentId;
  final String postId;
  final bool isAltPost;

  const CommentThreadScreen(
      {super.key,
      required this.isAltPost,
      required this.commentId,
      required this.postId});

  @override
  ConsumerState<CommentThreadScreen> createState() =>
      _CommentThreadScreenState();
}

class _CommentThreadScreenState extends ConsumerState<CommentThreadScreen> {
  final TextEditingController _replyController = TextEditingController();
  final FocusNode _replyFocusNode = FocusNode();
  File? _mediaFile;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Load thread data
    WidgetsBinding.instance.addPostFrameCallback((_) {});
  }

  @override
  void dispose() {
    _replyController.dispose();
    _replyFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final threadState = ref.watch(commentThreadProvider(
        (commentId: widget.commentId, postId: widget.postId)));
    final currentUserAsync = ref.watch(currentUserProvider);

    // Get user data for UI
    final user = currentUserAsync.userOrNull;
    final profileImageUrl = widget.isAltPost
        ? currentUserAsync.safeAltProfileImageURL ??
            currentUserAsync.safeProfileImageURL
        : currentUserAsync.safeProfileImageURL;

    if (threadState == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comment Thread'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (threadState.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Comment Thread'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: ${threadState.error}'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(commentThreadProvider((
                        commentId: widget.commentId,
                        postId: widget.postId
                      )).notifier)
                      .loadThread();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final parentComment = threadState.parentComment;
    final isAltPost = parentComment.isAltPost;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (isAltPost) ...[
              const Icon(Icons.lock, size: 16),
              const SizedBox(width: 8),
            ],
            const Text('Comment Thread'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref
                  .read(commentThreadProvider(
                          (commentId: widget.commentId, postId: widget.postId))
                      .notifier)
                  .loadThread();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Thread content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Parent comment
                CommentWidget(
                  comment: parentComment,
                  isAltPost: isAltPost,
                  depth: 0,
                  maxDepth: 20, // Allow deeper nesting in thread view
                  onReplyTap: () => _focusReplyField(),
                ),

                const Divider(height: 32),

                // Replies title
                Padding(
                  padding: const EdgeInsets.only(left: 16, bottom: 8),
                  child: Text(
                    'Replies (${threadState.replies.length})',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

                // Replies list
                ...threadState.replies.map((reply) => CommentWidget(
                      comment: reply,
                      isAltPost: isAltPost,
                      depth:
                          1, // Start at depth 1 since these are direct replies
                      maxDepth: 20, // Allow deeper nesting in thread view
                      onReplyTap: () => _focusReplyField(),
                    )),

                // Load more button
                if (threadState.hasMore)
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 16, top: 8, bottom: 16),
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(commentThreadProvider((
                              commentId: widget.commentId,
                              postId: widget.postId
                            )).notifier)
                            .loadMoreReplies();
                      },
                      child: threadState.isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Load more replies'),
                    ),
                  ),

                // Bottom padding
                const BottomNavPadding(),
              ],
            ),
          ),

          // Reply input area
          if (currentUserAsync.exists)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: profileImageUrl != null
                            ? NetworkImage(profileImageUrl)
                            : null,
                        child: profileImageUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 8),

                      // Reply input field
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          focusNode: _replyFocusNode,
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                          ),
                          minLines: 1,
                          maxLines: 3,
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
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                          onPressed: _isSubmitting ? null : _submitReply,
                        ),
                      ),
                    ],
                  ),

                  // Media attachment options
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
        ],
      ),
    );
  }

  void _focusReplyField() {
    // Focus the reply input field when a reply button is tapped
    _replyFocusNode.requestFocus();
  }

  // Pick image from gallery
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

  // Pick GIF
  Future<void> _pickGif() async {
    // This would ideally use a GIF picker library
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GIF picker not yet implemented')),
    );
  }

  // Submit reply
  Future<void> _submitReply() async {
    if (_replyController.text.trim().isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a reply or attach media')),
      );
      return;
    }

    final currentUserAsync = ref.read(currentUserProvider);
    final userId = currentUserAsync.userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to reply')),
      );
      return;
    }

    // Get the thread state
    final threadState = ref.read(commentThreadProvider(
        (commentId: widget.commentId, postId: widget.postId)));
    if (threadState == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Get the post ID from the parent comment
      final postId = threadState.parentComment.postId;
      final isAltPost = threadState.parentComment.isAltPost;

      // Create the reply
      await ref.read(commentsProvider(postId).notifier).createComment(
            authorId: userId,
            content: _replyController.text.trim(),
            parentId: widget.commentId,
            isAltPost: isAltPost,
            mediaFile: _mediaFile,
            ref: ref,
          );

      // Clear input
      _replyController.clear();
      setState(() => _mediaFile = null);
      if (mounted) FocusScope.of(context).unfocus();

      // Refresh the thread
      ref.invalidate(repliesProvider(widget.postId));
      ref
          .read(commentThreadProvider(
              (commentId: widget.commentId, postId: widget.postId)).notifier)
          .loadThread();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding reply: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
