import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class PostActionBar extends StatelessWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const PostActionBar({
    super.key,
    required this.post,
    this.displayMode = HeaderDisplayMode.compact,
    this.onCommentTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompact = displayMode == HeaderDisplayMode.compact;
    final isPinned = displayMode == HeaderDisplayMode.pinned;

    // Wrap entire action bar in RepaintBoundary
    return RepaintBoundary(
      child: Container(
        padding:
            EdgeInsets.symmetric(vertical: isPinned ? 0 : (isCompact ? 0 : 4)),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              width: 1,
            ),
            bottom: displayMode == HeaderDisplayMode.full
                ? BorderSide(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    width: 1,
                  )
                : BorderSide.none,
          ),
        ),
        child: displayMode == HeaderDisplayMode.full
            ? _FullScreenActionBar(
                post: post,
                onCommentTap: onCommentTap,
                onShareTap: onShareTap,
              )
            : _CompactActionBar(
                post: post,
                onCommentTap: onCommentTap,
                onShareTap: onShareTap,
              ),
      ),
    );
  }
}

class _CompactActionBar extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const _CompactActionBar({
    required this.post,
    this.onCommentTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final params = PostParams(
      id: post.id,
      isAlt: post.isAlt,
      herdId: post.herdId,
    );

    return Row(
      children: [
        // Like button
        _LikeButton(params: params, isCompact: true),

        // Dislike button
        _DislikeButton(params: params, isCompact: true),

        // Comment button
        _CommentButton(
          post: post,
          isCompact: true,
          onTap: onCommentTap,
        ),

        const Spacer(),

        // Share button
        _ShareButton(
          isAlt: post.isAlt,
          isCompact: true,
          onTap: onShareTap,
        ),
      ],
    );
  }
}

class _FullScreenActionBar extends StatelessWidget {
  final PostModel post;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const _FullScreenActionBar({
    required this.post,
    this.onCommentTap,
    this.onShareTap,
  });

  @override
  Widget build(BuildContext context) {
    final params = PostParams(
      id: post.id,
      isAlt: post.isAlt,
      herdId: post.herdId,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Share button
        _ShareButton(
          isAlt: post.isAlt,
          isCompact: false,
          onTap: onShareTap,
        ),

        // Comment button
        _CommentButton(
          post: post,
          isCompact: false,
          onTap: onCommentTap,
        ),

        // Like/Dislike buttons grouped
        _LikeDislikeGroup(params: params),
      ],
    );
  }
}

class _LikeButton extends ConsumerWidget {
  final PostParams params;
  final bool isCompact;

  const _LikeButton({
    required this.params,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to only rebuild when specific values change
    final likeState = ref.watch(
      postInteractionsWithPrivacyProvider(params).select(
        (state) => (state.isLiked, state.totalLikes, state.isLoading),
      ),
    );

    final isLiked = likeState.$1;
    final totalLikes = likeState.$2;
    final isLoading = likeState.$3;

    if (isCompact) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 0, 0),
        child: TextButton.icon(
          onPressed: isLoading ? null : () => _handleLike(context, ref),
          icon: Icon(
            isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
            size: 18,
            color: isLiked ? Colors.green : null,
          ),
          label: Text(
            isLoading ? '...' : _formatCount(totalLikes),
            style: TextStyle(
              color: isLiked ? Colors.green : null,
              fontWeight: FontWeight.w500,
            ),
          ),
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
        color: isLiked ? Colors.green : null,
        size: 22,
      ),
      onPressed: isLoading ? null : () => _handleLike(context, ref),
    );
  }

  void _handleLike(BuildContext context, WidgetRef ref) {
    LikeDislikeHelper.handleLikePost(
      context: context,
      ref: ref,
      postId: params.id,
      isAlt: params.isAlt,
      herdId: params.herdId,
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

class _DislikeButton extends ConsumerWidget {
  final PostParams params;
  final bool isCompact;

  const _DislikeButton({
    required this.params,
    required this.isCompact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select to only rebuild when specific values change
    final dislikeState = ref.watch(
      postInteractionsWithPrivacyProvider(params).select(
        (state) => (state.isDisliked, state.isLoading),
      ),
    );

    final isDisliked = dislikeState.$1;
    final isLoading = dislikeState.$2;

    if (isCompact) {
      return TextButton.icon(
        onPressed: isLoading ? null : () => _handleDislike(context, ref),
        icon: Icon(
          isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
          size: 18,
          color: isDisliked ? Colors.red : null,
        ),
        label: const Text(''), // No count for dislikes
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    return IconButton(
      icon: Icon(
        isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
        color: isDisliked ? Colors.red : null,
        size: 22,
      ),
      onPressed: isLoading ? null : () => _handleDislike(context, ref),
    );
  }

  void _handleDislike(BuildContext context, WidgetRef ref) {
    LikeDislikeHelper.handleDislikePost(
      context: context,
      ref: ref,
      postId: params.id,
      isAlt: params.isAlt,
      herdId: params.herdId,
    );
  }
}

class _CommentButton extends ConsumerWidget {
  final PostModel post;
  final bool isCompact;
  final VoidCallback? onTap;

  const _CommentButton({
    required this.post,
    required this.isCompact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read comment count from the keepAlive interactions provider instead of
    // opening a per-post Firestore stream, which would create N stream
    // subscriptions every time the feed is rebuilt.
    final commentCount = ref.watch(
      postInteractionsWithPrivacyProvider(
        PostParams(id: post.id, isAlt: post.isAlt, herdId: post.herdId),
      ).select(
        (state) => state.isInitialized ? state.totalComments : post.commentCount,
      ),
    );

    if (isCompact) {
      return TextButton.icon(
        onPressed: onTap ?? () => _navigateToPost(context),
        icon: const Icon(Icons.chat_bubble_outline, size: 18),
        label: Text(
          commentCount.toString(),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        style: TextButton.styleFrom(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      );
    }

    return TextButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.comment_rounded, size: 24),
      label: Text(
        commentCount.toString(),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _navigateToPost(BuildContext context) {
    context.pushNamed(
      'post',
      pathParameters: {'id': post.id},
      queryParameters: {'isAlt': post.isAlt.toString()},
    );
  }
}

class _ShareButton extends StatelessWidget {
  final bool isAlt;
  final bool isCompact;
  final VoidCallback? onTap;

  const _ShareButton({
    required this.isAlt,
    required this.isCompact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isCompact) {
      return Padding(
        padding: EdgeInsets.fromLTRB(0, 0, 2, 0),
        child: IconButton(
          icon: Icon(
            Icons.share_outlined,
            size: 20,
            color: isAlt ? theme.disabledColor : null,
          ),
          onPressed: isAlt ? null : (onTap ?? () => _handleShare(context)),
          tooltip: isAlt ? 'Cannot share alt posts' : 'Share',
        ),
      );
    }

    return TextButton.icon(
      onPressed: isAlt ? null : (onTap ?? () => _handleShare(context)),
      icon: Icon(
        Icons.share_rounded,
        size: 24,
        color: isAlt ? theme.disabledColor : null,
      ),
      label: Text(
        'Share',
        style: TextStyle(
          color: isAlt ? theme.disabledColor : null,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  void _handleShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
    );
  }
}

class _LikeDislikeGroup extends ConsumerWidget {
  final PostParams params;

  const _LikeDislikeGroup({required this.params});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Use select for minimal rebuilds
    final interactionState = ref.watch(
      postInteractionsWithPrivacyProvider(params).select(
        (state) => (
          state.isLiked,
          state.isDisliked,
          state.totalLikes,
          state.isLoading,
        ),
      ),
    );

    final isLiked = interactionState.$1;
    final isDisliked = interactionState.$2;
    final totalLikes = interactionState.$3;
    final isLoading = interactionState.$4;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: isLiked
                  ? Colors.green
                  : theme.buttonTheme.colorScheme?.primary,
              size: 22,
            ),
            onPressed: isLoading
                ? null
                : () => LikeDislikeHelper.handleLikePost(
                      context: context,
                      ref: ref,
                      postId: params.id,
                      isAlt: params.isAlt,
                      herdId: params.herdId,
                    ),
          ),
        ),
        SizedBox(
          width: 46,
          child: Center(
            child: Text(
              _formatCount(totalLikes),
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SizedBox(
          width: 48,
          height: 48,
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: Icon(
              isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: isDisliked
                  ? Colors.red
                  : theme.buttonTheme.colorScheme?.primary,
              size: 22,
            ),
            onPressed: isLoading
                ? null
                : () => LikeDislikeHelper.handleDislikePost(
                      context: context,
                      ref: ref,
                      postId: params.id,
                      isAlt: params.isAlt,
                      herdId: params.herdId,
                    ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}
