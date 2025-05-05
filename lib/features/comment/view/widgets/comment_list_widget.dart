import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/image_helper.dart';
import 'package:herdapp/features/comment/view/providers/comment_providers.dart';
import 'package:herdapp/features/comment/view/widgets/comment_input_field.dart';
import 'package:herdapp/features/comment/view/widgets/comment_widget.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:herdapp/features/user/view/providers/current_user_provider.dart';
import 'package:image_cropper/image_cropper.dart';

class CommentListWidget extends ConsumerWidget {
  final String postId;
  final bool isAltPost;

  const CommentListWidget({
    super.key,
    required this.postId,
    this.isAltPost = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    debugPrint('Rebuilding CommentListWidget');
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSortControls(),
        CommentInputField(
          postId: postId,
          isAltPost: isAltPost,
        ),
        _buildCommentList(),
      ],
    );
  }

  Widget _buildSortControls() {
    return Consumer(builder: (context, ref, child) {
      final sortBy = ref.watch(commentSortProvider);
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        child: Row(
          children: [
            const Text('Sort comments by: '),
            DropdownButton<String>(
              value: sortBy,
              onChanged: (value) {
                if (value != null) {
                  ref.read(commentSortProvider.notifier).state = value;
                  ref
                      .read(commentsProvider(postId).notifier)
                      .changeSortBy(value);
                }
              },
              items: const [
                DropdownMenuItem(value: 'hot', child: Text('Hot')),
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'mostLiked', child: Text('Most Liked')),
              ],
            ),
            const Spacer(),
            _buildCollapseAllButton(),
          ],
        ),
      );
    });
  }

  Widget _buildCollapseAllButton() {
    return Consumer(builder: (context, ref, child) {
      final hasComments = ref.watch(commentsProvider(postId)
          .select((value) => value.comments.isNotEmpty));

      if (!hasComments) return const SizedBox.shrink();

      return TextButton(
        onPressed: () {
          ref.read(expandedCommentsProvider.notifier).collapseAll();
        },
        child: const Text('Collapse all'),
      );
    });
  }

  Widget _buildCommentList() {
    return Consumer(
      builder: (context, ref, child) {
        // Select only the properties we need
        final commentsState = ref.watch(commentsProvider(postId).select(
            (state) =>
                (state.comments, state.isLoading, state.hasMore, state.error)));

        final comments = commentsState.$1;
        final isLoading = commentsState.$2;
        final hasMore = commentsState.$3;
        final error = commentsState.$4;

        // Loading state
        if (isLoading && comments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Error state
        if (error != null && comments.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Error: $error'),
                ElevatedButton(
                  onPressed: () => ref
                      .read(commentsProvider(postId).notifier)
                      .loadComments(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        // Empty state
        if (comments.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No comments yet. Be the first to comment!'),
            ),
          );
        }

        // Comments list
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              // Map comments to widgets
              ...comments.map((comment) => CommentWidget(
                    comment: comment,
                    isAltPost: isAltPost,
                    onReplyTap: () =>
                        _showReplyDialog(context, ref, comment.id),
                  )),

              // Load more button
              if (isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (hasMore)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        ref
                            .read(commentsProvider(postId).notifier)
                            .loadMoreComments();
                      },
                      child: const Text('Load More Comments'),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showReplyDialog(BuildContext context, WidgetRef ref, String parentId) {
    showDialog(
      context: context,
      builder: (context) => ReplyDialog(
        postId: postId,
        parentId: parentId,
        isAltPost: isAltPost,
      ),
    );
  }
}
