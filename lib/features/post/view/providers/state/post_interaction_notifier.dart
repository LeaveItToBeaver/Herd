import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';

class PostInteractionsNotifier extends StateNotifier<PostInteractionState> {
  final PostRepository repository;
  final String postId;

  PostInteractionsNotifier({
    required this.repository,
    required this.postId,
  }) : super(PostInteractionState.initial());
  Future<void> initializeState(String userId) async {
    debugPrint(
        '🔄 Initializing interaction state for post: $postId, user: $userId');
    final result = await loadInteractionStatus(userId);
    debugPrint(
        '✅ Interaction loaded for post: $postId, isLiked: ${state.isLiked}');
    return result;
  }

  Future<void> loadInteractionStatus(String userId) async {
    try {
      state = state.copyWith(isLoading: true);

      final post = await repository.getPostById(postId);

      final isLiked =
          await repository.isPostLikedByUser(postId: postId, userId: userId);

      final isDisliked =
          await repository.isPostDislikedByUser(postId: postId, userId: userId);

      state = state.copyWith(
        isLiked: isLiked,
        isDisliked: isDisliked,
        totalRawLikes: post?.likeCount ?? 0,
        totalRawDislikes: post?.dislikeCount ?? 0,
        totalLikes:
            (post?.likeCount ?? 0) - (post?.dislikeCount ?? 0), // Net likes
        totalComments: post?.commentCount ?? 0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> likePost(String userId,
      {required bool isAlt, String? feedType, String? herdId}) async {
    try {
      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      // Update state optimistically
      final newLikeCount =
          wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes + 1;
      final newDislikeCount =
          wasDisliked ? state.totalRawDislikes - 1 : state.totalRawDislikes;

      state = state.copyWith(
        isLiked: !wasLiked,
        isDisliked: false,
        totalRawLikes: newLikeCount,
        totalRawDislikes: newDislikeCount,
        totalLikes: newLikeCount - newDislikeCount,
      );

      // Use the feedType to determine which collection to update
      String effectiveFeedType = feedType ?? (isAlt ? 'alt' : 'public');

      // Call repository with the feed type information
      await repository.likePost(
          postId: postId,
          userId: userId,
          isAlt: isAlt,
          feedType: effectiveFeedType,
          herdId: herdId);
    } catch (e) {
      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      // Calculate original counts
      final originalLikeCount =
          wasLiked ? state.totalRawLikes + 1 : state.totalRawLikes - 1;
      final originalDislikeCount = wasDisliked
          ? state.totalRawDislikes + 1 // Was disliked before
          : state.totalRawDislikes; // Wasn't disliked before
      state = state.copyWith(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        totalRawLikes: originalLikeCount,
        totalRawDislikes: originalDislikeCount,
        totalLikes: originalLikeCount - originalDislikeCount,
        error: e.toString(),
      );
    }
  }

  Future<void> dislikePost(String userId,
      {required bool isAlt, required String feedType, String? herdId}) async {
    try {
      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      // Calculate new counts
      final newLikeCount =
          wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes;
      final newDislikeCount = wasDisliked
          ? state.totalRawDislikes - 1 // Removing dislike
          : state.totalRawDislikes + 1; // Adding dislike

      // Update state once with all changes (optimistic update)
      state = state.copyWith(
        isDisliked: !wasDisliked,
        isLiked: false, // Remove like if present
        totalRawLikes: newLikeCount,
        totalRawDislikes: newDislikeCount,
        totalLikes: newLikeCount - newDislikeCount, // Update net likes
      );

      // Call the API without updating state for loading
      await repository.dislikePost(
          postId: postId, userId: userId, isAlt: isAlt);
    } catch (e) {
      // If error, revert to previous state
      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      // Calculate original counts
      final originalLikeCount =
          wasLiked ? state.totalRawLikes + 1 : state.totalRawLikes;
      final originalDislikeCount = wasDisliked
          ? state.totalRawDislikes + 1 // Was disliked before
          : state.totalRawDislikes - 1; // Wasn't disliked before

      state = state.copyWith(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        totalRawLikes: originalLikeCount,
        totalRawDislikes: originalDislikeCount,
        totalLikes: originalLikeCount - originalDislikeCount,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
