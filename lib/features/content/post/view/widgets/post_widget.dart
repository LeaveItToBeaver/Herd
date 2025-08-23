// lib/features/content/post/view/widgets/post_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';

class PostWidget extends ConsumerStatefulWidget {
  final PostModel post;
  final bool isCompact;

  const PostWidget({
    super.key,
    required this.post,
    this.isCompact = false,
  });

  @override
  ConsumerState<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends ConsumerState<PostWidget>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Initialize interactions once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _initializeInteractions();
      }
    });
  }

  void _initializeInteractions() {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    if (userId != null) {
      ref
          .read(postInteractionsWithPrivacyProvider(PostParams(
            id: widget.post.id,
            isAlt: widget.post.isAlt,
            herdId: widget.post.herdId,
          )).notifier)
          .initializeState(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);

    // Use StaticPostWrapper to completely prevent rebuilds from external changes
    return StaticPostWrapper(
      postId: widget.post.id,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: () => _navigateToPost(context),
          child: Container(
            margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(25),
              border: widget.post.isAlt
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 2,
                    )
                  : Border.all(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                      width: 2,
                    ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Type indicators
                  RepaintBoundary(
                    child: PostTypeIndicators(post: widget.post),
                  ),

                  // Post content wrapped in padding
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        RepaintBoundary(
                          child: PostAuthorHeader(
                            post: widget.post,
                            displayMode: widget.isCompact
                                ? HeaderDisplayMode.compact
                                : HeaderDisplayMode.compact,
                          ),
                        ),

                        // Content
                        RepaintBoundary(
                          child: PostContentDisplay(
                            post: widget.post,
                            displayMode: HeaderDisplayMode.compact,
                            initialExpanded: false,
                          ),
                        ),

                        // Action bar
                        RepaintBoundary(
                          child: PostActionBar(
                            post: widget.post,
                            displayMode: HeaderDisplayMode.compact,
                            onCommentTap: () => _navigateToPost(context),
                            onShareTap: widget.post.isAlt
                                ? null
                                : () => _sharePost(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPost(BuildContext context) {
    context.pushNamed(
      'post',
      pathParameters: {'id': widget.post.id},
      queryParameters: {'isAlt': widget.post.isAlt.toString()},
    );
  }

  void _sharePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
    );
  }
}
