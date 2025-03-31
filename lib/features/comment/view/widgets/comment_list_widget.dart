import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/comment/view/providers/comment_providers.dart';
import 'package:herdapp/features/comment/view/widgets/comment_widget.dart';
import 'package:herdapp/features/navigation/view/widgets/BottomNavPadding.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/user/view/providers/current_user_provider.dart';

class CommentListWidget extends ConsumerStatefulWidget {
  final String postId;
  final bool isPrivatePost;

  const CommentListWidget({
    Key? key,
    required this.postId,
    this.isPrivatePost = false,
  }) : super(key: key);

  @override
  ConsumerState<CommentListWidget> createState() => _CommentListWidgetState();
}

class _CommentListWidgetState extends ConsumerState<CommentListWidget> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  File? _mediaFile;
  bool _isSubmitting = false;
  StreamSubscription? _commentRefreshListener;

  @override
  void initState() {
    super.initState();

    // Initialize comments
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentsProvider(widget.postId).notifier).loadComments();
    });

    // Set up comment refresh listener
    _commentRefreshListener = Stream.periodic(const Duration(seconds: 10)).listen((_) {
      if (mounted) {
        ref.read(commentsProvider(widget.postId).notifier).loadComments();
      }
    });
  }

  @override
  void dispose() {
    _commentRefreshListener?.cancel();
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

// Modification to CommentListWidget build method:
  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsProvider(widget.postId));
    final sortBy = ref.watch(commentSortProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sort controls
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Row(
            children: [
              const Text('Sort comments by: '),
              DropdownButton<String>(
                value: sortBy,
                onChanged: (value) {
                  if (value != null) {
                    ref.read(commentSortProvider.notifier).state = value;
                    ref.read(commentsProvider(widget.postId).notifier).changeSortBy(value);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'hot', child: Text('Hot')),
                  DropdownMenuItem(value: 'newest', child: Text('Newest')),
                  DropdownMenuItem(value: 'mostLiked', child: Text('Most Liked')),
                ],
              ),
              const Spacer(),
              if (commentsState.comments.isNotEmpty)
                TextButton(
                  onPressed: () {
                    ref.read(expandedCommentsProvider.notifier).collapseAll();
                  },
                  child: const Text('Collapse all'),
                ),
            ],
          ),
        ),

        // Comment entry field
        if (currentUser != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User avatar
                CircleAvatar(
                  radius: 20,
                  backgroundImage: currentUser.profileImageURL != null
                      ? NetworkImage(widget.isPrivatePost
                      ? (currentUser.privateProfileImageURL ?? currentUser.profileImageURL!)
                      : currentUser.profileImageURL!)
                      : null,
                  child: currentUser.profileImageURL == null
                      ? const Icon(Icons.person)
                      : null,
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
          ),

        // Comments list - now as a Column, not a scrollable widget
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: commentsState.isLoading && commentsState.comments.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : commentsState.comments.isEmpty
              ? const Center(child: Text('No comments yet. Be the first to comment!'))
              : Column(
            children: [
              // Map comments to widgets directly
              ...commentsState.comments.map((comment) => CommentWidget(
                comment: comment,
                isPrivatePost: widget.isPrivatePost,
                onReplyTap: () => _showReplyDialog(context, comment.id),
              )),

              // Load more button
              if (commentsState.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (commentsState.hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        ref.read(commentsProvider(widget.postId).notifier)
                            .loadMoreComments();
                      },
                      child: const Text('Load More Comments'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
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
    // For now, we'll use the image picker as a placeholder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('GIF picker not yet implemented')),
    );
  }

  // Submit comment
  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty && _mediaFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a comment or attach media')),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to comment')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(commentsProvider(widget.postId).notifier).createComment(
        authorId: currentUser.id,
        content: _commentController.text.trim(),
        isPrivatePost: widget.isPrivatePost,
        mediaFile: _mediaFile,
        ref: ref
      );

      _commentController.clear();
      setState(() => _mediaFile = null);
      FocusScope.of(context).unfocus();

      // Force refresh after submission
      await ref.read(commentsProvider(widget.postId).notifier).loadComments();
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

  // Show reply dialog
  void _showReplyDialog(BuildContext context, String parentId) {
    showDialog(
      context: context,
      builder: (context) => ReplyDialog(
        postId: widget.postId,
        parentId: parentId,
        isPrivatePost: widget.isPrivatePost,
      ),
    );
  }
}