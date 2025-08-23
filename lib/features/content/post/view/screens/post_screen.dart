// lib/features/content/post/view/screens/post_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';

class PostScreen extends ConsumerStatefulWidget {
  final String postId;
  final bool isAlt;
  final String? herdId;

  const PostScreen({
    super.key,
    required this.postId,
    this.isAlt = false,
    this.herdId,
  });

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  @override
  void initState() {
    super.initState();

    // Initialize interactions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      final userId = user.userId;
      if (userId != null) {
        ref
            .read(postInteractionsWithPrivacyProvider(PostParams(
              id: widget.postId,
              isAlt: widget.isAlt,
              herdId: widget.herdId,
            )).notifier)
            .initializeState(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final postAsync = ref.watch(
      staticPostProvider(PostParams(id: widget.postId, isAlt: widget.isAlt)),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              children: [
                if (widget.isAlt)
                  const Padding(
                    padding: EdgeInsets.only(right: 8.0),
                    child: Icon(Icons.public_rounded, size: 20),
                  ),
                Expanded(
                  child: postAsync.when(
                    data: (post) => Text(
                      post?.title ?? 'Post',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      softWrap: false,
                    ),
                    loading: () => const Text('Loading...'),
                    error: (error, stack) => const Text('Error'),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: widget.isAlt ? null : () => _sharePost(context),
          ),
        ],
      ),
      body: postAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          return RefreshIndicator(
            onRefresh: () => _refreshPost(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type indicators
                  RepaintBoundary(
                    child: PostTypeIndicators(post: post),
                  ),

                  // Author header
                  RepaintBoundary(
                    child: PostAuthorHeader(
                      post: post,
                      displayMode: HeaderDisplayMode.full,
                    ),
                  ),

                  // Post content
                  RepaintBoundary(
                    child: PostContentDisplay(
                      post: post,
                      displayMode: HeaderDisplayMode.full,
                      initialExpanded: true,
                    ),
                  ),

                  // Action bar
                  RepaintBoundary(
                    child: PostActionBar(
                      post: post,
                      displayMode: HeaderDisplayMode.full,
                      onCommentTap: _scrollToComments,
                      onShareTap: post.isAlt ? null : () => _sharePost(context),
                    ),
                  ),

                  // Comments section
                  RepaintBoundary(
                    child: _CommentSection(
                      postId: widget.postId,
                      isAltPost: widget.isAlt,
                    ),
                  ),

                  // Extra bottom padding
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _scrollToComments() {
    // TODO: Implement scroll to comments
  }

  void _sharePost(BuildContext context) {
    if (widget.isAlt) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
    );
  }

  Future<void> _refreshPost() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Refreshing...'),
          duration: Duration(milliseconds: 800),
        ),
      );

      // Invalidate the static provider to force a re-fetch
      ref.invalidate(
        staticPostProvider(PostParams(id: widget.postId, isAlt: widget.isAlt)),
      );

      // Reload comments
      await ref.read(commentsProvider(widget.postId).notifier).loadComments();
      await ref.read(repliesProvider(widget.postId).notifier).loadReplies();

      // Reload interaction data
      final user = ref.read(currentUserProvider);
      final userId = user.userId;
      if (userId != null) {
        final params = PostParams(
          id: widget.postId,
          isAlt: widget.isAlt,
          herdId: widget.herdId,
        );

        ref.invalidate(postInteractionsWithPrivacyProvider(params));
        await ref
            .read(postInteractionsWithPrivacyProvider(params).notifier)
            .initializeState(userId);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error refreshing: $e')),
        );
      }
    }
  }
}

class _CommentSection extends StatelessWidget {
  final String postId;
  final bool isAltPost;

  const _CommentSection({
    required this.postId,
    required this.isAltPost,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Comments section header
        Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
            "Comments",
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),

        // Comments list widget
        CommentListWidget(
          postId: postId,
          isAltPost: isAltPost,
        ),
      ],
    );
  }
}
