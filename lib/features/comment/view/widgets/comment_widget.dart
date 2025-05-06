import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/comment/data/models/comment_model.dart';
import 'package:herdapp/features/comment/view/providers/comment_providers.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../../core/services/image_helper.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../providers/reply_providers.dart';

class CommentWidget extends ConsumerStatefulWidget {
  final CommentModel comment;
  final bool isAltPost;
  final int depth;
  final int maxDepth;
  final Function()? onReplyTap;

  const CommentWidget({
    super.key,
    required this.comment,
    this.isAltPost = false,
    this.depth = 0,
    this.maxDepth = 3,
    this.onReplyTap,
  });

  @override
  ConsumerState<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends ConsumerState<CommentWidget> {
  bool _hasInitializedInteraction = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeCommentInteraction();
  }

  void _initializeCommentInteraction() {
    if (!_hasInitializedInteraction) {
      Future.microtask(() {
        if (mounted) {
          ref
              .read(commentInteractionProvider((
                commentId: widget.comment.id,
                postId: widget.comment.postId
              )).notifier)
              .initializeState();
          _hasInitializedInteraction = true;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use RepaintBoundary to isolate painting
    return RepaintBoundary(
      child: Card(
        margin: EdgeInsets.only(
          left: widget.depth * 16.0,
          right: 8.0,
          top: 8.0,
          bottom: 4.0,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: widget.isAltPost
                ? Colors.blue.withAlpha(51)
                : Colors.grey.withAlpha(51),
            width: 1,
          ),
        ),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            ListTile(
              contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              leading: GestureDetector(
                onTap: () =>
                    _navigateToUserProfile(context, widget.comment.authorId),
                child: CircleAvatar(
                  radius: 18,
                  backgroundImage: widget.comment.authorProfileImage != null
                      ? CachedNetworkImageProvider(
                          widget.comment.authorProfileImage!)
                      : null,
                  child: widget.comment.authorProfileImage == null
                      ? const Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
              ),
              title: Row(
                children: [
                  GestureDetector(
                    onTap: () => _navigateToUserProfile(
                        context, widget.comment.authorId),
                    child: widget.comment.isAltPost
                        ? Text(
                            widget.comment.authorUsername ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          )
                        : Text(
                            // For public posts, construct name from first/last name or fall back to authorName
                            (widget.comment.authorFirstName != null &&
                                    widget.comment.authorLastName != null)
                                ? "${widget.comment.authorFirstName} ${widget.comment.authorLastName}"
                                : widget.comment.authorName ?? 'Anonymous',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.blue,
                            ),
                          ),
                  ),
                  if (widget.isAltPost) ...[
                    const SizedBox(width: 4),
                    Icon(Icons.lock, size: 12, color: Colors.blue.shade300)
                  ],
                ],
              ),
              subtitle: Text(
                timeago.format(widget.comment.timestamp),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'report') {
                    _showReportDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Text('Report comment'),
                  ),
                ],
              ),
            ),

            // Comment content
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text content
                  Text(
                    widget.comment.content,
                    style: const TextStyle(fontSize: 14),
                  ),

                  // Media content if available
                  if (widget.comment.mediaUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: widget.comment.mediaUrl!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child:
                              const Center(child: CircularProgressIndicator()),
                        ),
                        errorWidget: (context, url, error) => Container(
                          height: 150,
                          color: Colors.grey[200],
                          child: const Icon(Icons.error),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),

                  // Use separate consumers for interactions
                  Row(
                    children: [
                      // Like button in its own consumer
                      _buildLikeButton(),

                      const SizedBox(width: 16),

                      // Dislike button in its own consumer
                      _buildDislikeButton(),

                      const SizedBox(width: 16),

                      // Reply button
                      InkWell(
                        onTap: widget.onReplyTap,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            children: [
                              Icon(Icons.reply, size: 16, color: Colors.grey),
                              SizedBox(width: 4),
                              Text(
                                'Reply',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Expanded/collapse replies in its own consumer
                      if (widget.comment.replyCount > 0) _buildRepliesToggle(),
                    ],
                  ),
                ],
              ),
            ),

            // Show replies if expanded and not at max depth
            _buildRepliesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeButton() {
    return Consumer(
      builder: (context, ref, child) {
        // Only watch the like state
        final likeState = ref.watch(commentInteractionProvider(
                (commentId: widget.comment.id, postId: widget.comment.postId))
            .select(
                (state) => (state.isLiked, state.likeCount, state.isLoading)));

        final isLiked = likeState.$1;
        final likeCount = likeState.$2;
        final isLoading = likeState.$3;

        return InkWell(
          onTap: isLoading ? null : () => _handleLike(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  size: 16,
                  color: isLiked ? Colors.blue : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likeCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: isLiked ? Colors.blue : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDislikeButton() {
    return Consumer(
      builder: (context, ref, child) {
        // Only watch the dislike state
        final dislikeState = ref.watch(commentInteractionProvider(
                (commentId: widget.comment.id, postId: widget.comment.postId))
            .select((state) =>
                (state.isDisliked, state.dislikeCount, state.isLoading)));

        final isDisliked = dislikeState.$1;
        final dislikeCount = dislikeState.$2;
        final isLoading = dislikeState.$3;

        return InkWell(
          onTap: isLoading ? null : () => _handleDislike(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Icon(
                  isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  size: 16,
                  color: isDisliked ? Colors.red : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '$dislikeCount',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDisliked ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRepliesToggle() {
    return Consumer(
      builder: (context, ref, child) {
        // Only watch expanded state for this comment
        final isExpanded = ref.watch(expandedCommentsProvider.select(
            (state) => state.expandedCommentIds.contains(widget.comment.id)));

        return Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              InkWell(
                onTap: () {
                  ref
                      .read(expandedCommentsProvider.notifier)
                      .toggleExpanded(widget.comment.id);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    children: [
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isExpanded
                            ? 'Hide replies'
                            : '${widget.comment.replyCount} replies',
                        style:
                            const TextStyle(fontSize: 12, color: Colors.indigo),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRepliesSection() {
    return Consumer(builder: (context, ref, child) {
      // Only watch expanded state for this comment
      final isExpanded = ref.watch(expandedCommentsProvider.select(
          (state) => state.expandedCommentIds.contains(widget.comment.id)));

      if (!isExpanded ||
          widget.comment.replyCount <= 0 ||
          widget.depth >= widget.maxDepth) {
        return widget.comment.replyCount > 0 && widget.depth >= widget.maxDepth
            ? _buildViewThreadButton()
            : const SizedBox.shrink();
      }

      // If expanded, show thread
      return _buildReplies();
    });
  }

  // Build replies list
  Widget _buildReplies() {
    return Consumer(
      builder: (context, ref, child) {
        final threadStateAsync = ref.watch(commentThreadProvider(
            (commentId: widget.comment.id, postId: widget.comment.postId)));

        if (threadStateAsync == null) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        // Check for loading or error states
        if (threadStateAsync.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(8.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (threadStateAsync.error != null) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text('Error: ${threadStateAsync.error}')),
          );
        }

        // Show replies
        final replies = threadStateAsync.replies;
        return Column(
          children: [
            ...replies.map((reply) => CommentWidget(
                  comment: reply,
                  isAltPost: widget.isAltPost,
                  depth: widget.depth + 1,
                  maxDepth: widget.maxDepth,
                  onReplyTap: () => _showReplyDialog(context, reply.id),
                )),
            if (threadStateAsync.hasMore)
              Padding(
                padding: EdgeInsets.only(
                  left: (widget.depth + 1) * 16.0,
                  right: 8.0,
                  top: 4.0,
                  bottom: 8.0,
                ),
                child: TextButton(
                  onPressed: () {
                    ref
                        .read(commentThreadProvider((
                          commentId: widget.comment.id,
                          postId: widget.comment.postId
                        )).notifier)
                        .loadMoreReplies();
                  },
                  child: const Text('Load more replies'),
                ),
              ),
          ],
        );
      },
    );
  }

  // Build "View thread" button for deep comment chains
  Widget _buildViewThreadButton() {
    return Padding(
      padding: EdgeInsets.only(
        left: widget.depth * 16.0,
        right: 8.0,
        bottom: 8.0,
      ),
      child: TextButton.icon(
        onPressed: () {
          // Navigate to full thread view
          context.push('/commentThread', extra: {
            'commentId': widget.comment.id,
            'postId': widget.comment.postId,
            'isAltPost': widget.comment.isAltPost,
          });
        },
        icon: const Icon(Icons.forum, size: 16),
        label: const Text(
          'View thread',
          style: TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  // Like function with optimistic update
  void _handleLike() {
    final userId = ref.read(currentUserProvider).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like comments')),
      );
      return;
    }

    ref
        .read(commentInteractionProvider(
                (commentId: widget.comment.id, postId: widget.comment.postId))
            .notifier)
        .toggleLike();
  }

  // Dislike function with optimistic update
  void _handleDislike() {
    final userId = ref.read(currentUserProvider).userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to dislike comments')),
      );
      return;
    }

    // This executes immediately for optimistic update, just like before
    ref
        .read(commentInteractionProvider(
                (commentId: widget.comment.id, postId: widget.comment.postId))
            .notifier)
        .toggleDislike();
  }

  // Show reply dialog
  void _showReplyDialog(BuildContext context, String parentId) {
    // This will be implemented in the next step
    showDialog(
      context: context,
      builder: (context) => ReplyDialog(
        postId: widget.comment.postId,
        parentId: parentId,
        isAltPost: widget.isAltPost,
      ),
    );
  }

  // Navigate to user profile
  void _navigateToUserProfile(BuildContext context, String userId) {
    if (widget.isAltPost) {
      context.pushNamed(
        'altProfile',
        pathParameters: {'id': userId},
      );
    } else {
      context.pushNamed(
        'publicProfile',
        pathParameters: {'id': userId},
      );
    }
  }

  // Show report dialog
  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Comment'),
        content: const Text('Would you like to report this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Handle report functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Comment reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}

// Reply Dialog Widget
class ReplyDialog extends ConsumerStatefulWidget {
  final String postId;
  final String parentId;
  final bool isAltPost;

  const ReplyDialog({
    super.key,
    required this.postId,
    required this.parentId,
    required this.isAltPost,
  });

  @override
  ConsumerState<ReplyDialog> createState() => _ReplyDialogState();
}

class _ReplyDialogState extends ConsumerState<ReplyDialog> {
  final TextEditingController _contentController = TextEditingController();
  File? _mediaFile;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reply to Comment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.photo),
                onPressed: _pickImage,
              ),
              if (_mediaFile != null) ...[
                Expanded(
                  child: Text(
                    'Image selected',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => setState(() => _mediaFile = null),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isSubmitting ? null : _submitReply,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Reply'),
        ),
      ],
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

  Future<void> _submitReply() async {
    if (_contentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something')),
      );
      return;
    }

    final userAsync = ref.read(currentUserProvider);
    final user = userAsync.userOrNull; // Using our extension method to unwrap

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to reply')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await ref.read(commentsProvider(widget.postId).notifier).createComment(
            authorId: user.id,
            content: _contentController.text.trim(),
            parentId: widget.parentId,
            isAltPost: widget.isAltPost,
            mediaFile: _mediaFile,
            ref: ref,
          );

      // Rest of the function remains the same
      ref.invalidate(repliesProvider(widget.postId));
      ref.invalidate(commentThreadProvider(
          (commentId: widget.parentId, postId: widget.postId)));

      // Increment update counter to force refresh of listeners
      ref.read(commentUpdateProvider.notifier).state++;

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reply added successfully')),
        );
      }
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
