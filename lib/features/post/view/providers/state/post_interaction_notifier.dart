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
    return loadInteractionStatus(userId);
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

  Future<void> likePost(String userId, {required bool isAlt}) async {
    try {
      // Track the previous state to revert if needed
      final previousState = state;

      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      // Update state optimistically
      final newLikeCount =
          wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes + 1;
      final newDislikeCount =
          wasDisliked ? state.totalRawDislikes - 1 : state.totalRawDislikes;
      final netLikes = newLikeCount - newDislikeCount;

      state = state.copyWith(
        isLiked: !wasLiked,
        isDisliked: false, // Remove dislike if present
        totalRawLikes: newLikeCount,
        totalRawDislikes: newDislikeCount,
        totalLikes: netLikes,
        isLoading: true,
      );

      // Call the cloud function via repository
      await repository.likePost(postId: postId, userId: userId, isAlt: isAlt);

      // Update state based on new state (already updated optimistically)
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // If error, revert to previous state
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> dislikePost(String userId, {required bool isAlt}) async {
    try {
      final previousState = state;

      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      // Update state optimistically
      final newDislikeCount =
          wasDisliked ? state.totalRawDislikes - 1 : state.totalRawDislikes + 1;
      final newLikeCount =
          wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes;
      final netLikes = newLikeCount - newDislikeCount;

      state = state.copyWith(
        isDisliked: !wasDisliked,
        isLiked: false, // Remove like if present
        totalRawDislikes: newDislikeCount,
        totalRawLikes: newLikeCount,
        totalLikes: netLikes,
        isLoading: true,
      );

      // Call the cloud function via repository
      await repository.dislikePost(
          postId: postId, userId: userId, isAlt: isAlt);

      // Update state based on new state (already updated optimistically)
      state = state.copyWith(isLoading: false);
    } catch (e) {
      // If error, revert to previous state
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
