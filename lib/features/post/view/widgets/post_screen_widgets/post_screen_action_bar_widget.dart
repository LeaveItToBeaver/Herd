import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/helpers/like_dislike_helper.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';

class PostActionBar extends ConsumerWidget {
  final String postId;
  final bool isAlt;
  final String? herdId;
  final VoidCallback? onCommentTap;
  final VoidCallback? onShareTap;

  const PostActionBar({
    Key? key,
    required this.postId,
    required this.isAlt,
    this.herdId,
    this.onCommentTap,
    this.onShareTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Create params just once for efficiency
    final params = PostParams(id: postId, isAlt: isAlt, herdId: herdId);

    return RepaintBoundary(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
            bottom: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ShareButton(
              isAlt: isAlt,
              onShareTap: onShareTap,
            ),
            _CommentButton(
              postId: postId,
              isAlt: isAlt,
              onCommentTap: onCommentTap,
            ),
            _LikeDislikeButtons(params: params),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final bool isAlt;
  final VoidCallback? onShareTap;

  const _ShareButton({
    Key? key,
    required this.isAlt,
    this.onShareTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(
        Icons.share_rounded,
        size: 24,
        color: isAlt ? Colors.grey.shade400 : Colors.grey.shade700,
      ),
      label: Text(
        'Share',
        style: TextStyle(
          color: isAlt ? Colors.grey.shade400 : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: isAlt
          ? null
          : onShareTap ??
              () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sharing post...')),
                );
              },
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _CommentButton extends ConsumerWidget {
  final String postId;
  final bool isAlt;
  final VoidCallback? onCommentTap;

  const _CommentButton({
    Key? key,
    required this.postId,
    required this.isAlt,
    this.onCommentTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only watch the comment count for better performance
    final commentCount = ref.watch(postInteractionsWithPrivacyProvider(
            PostParams(id: postId, isAlt: isAlt))
        .select((state) => state.totalComments));

    return TextButton.icon(
      icon: Icon(
        Icons.comment_rounded,
        size: 24,
        color: Colors.grey.shade700,
      ),
      label: Text(
        commentCount.toString(),
        style: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: onCommentTap ??
          () {
            debugPrint("Comment button tapped");
          },
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _LikeDislikeButtons extends ConsumerWidget {
  final PostParams params;

  const _LikeDislikeButtons({
    Key? key,
    required this.params,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use select for minimal rebuilds
    final interactionState = ref.watch(
        postInteractionsWithPrivacyProvider(params).select((state) => (
              state.isLiked,
              state.isDisliked,
              state.totalLikes,
              state.isLoading
            )));

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
              color: isLiked ? Colors.green : Colors.grey.shade700,
              size: 24,
            ),
            onPressed: isLoading ? null : () => _handleLikePost(context, ref),
          ),
        ),
        SizedBox(
          width: 30,
          child: Center(
            child: Text(
              totalLikes.toString(),
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
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
              color: isDisliked ? Colors.red : Colors.grey.shade700,
              size: 24,
            ),
            onPressed:
                isLoading ? null : () => _handleDislikePost(context, ref),
          ),
        ),
      ],
    );
  }

  void _handleLikePost(BuildContext context, WidgetRef ref) {
    LikeDislikeHelper.handleLikePost(
      context: context,
      ref: ref,
      postId: params.id,
      isAlt: params.isAlt,
      herdId: params.herdId,
    );
  }

  void _handleDislikePost(BuildContext context, WidgetRef ref) {
    LikeDislikeHelper.handleDislikePost(
      context: context,
      ref: ref,
      postId: params.id,
      isAlt: params.isAlt,
      herdId: params.herdId,
    );
  }
}
