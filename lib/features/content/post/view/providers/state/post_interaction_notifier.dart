import 'package:flutter/cupertino.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'post_interaction_state.dart';

part 'post_interaction_notifier.g.dart';

@riverpod
class PostInteractionsNotifier extends _$PostInteractionsNotifier {
  late String _postId;

  @override
  PostInteractionState build(String postId) {
    _postId = postId;
    return PostInteractionState.initial();
  }

  Future<void> initializeState(String userId) async {
    debugPrint(
        'Initializing interaction state for post: $_postId, user: $userId');
    final result = await loadInteractionStatus(userId);
    debugPrint(
        'Interaction loaded for post: $_postId, isLiked: ${state.isLiked}');
    return result;
  }

  Future<void> loadInteractionStatus(String userId) async {
    final repository = ref.watch(postRepositoryProvider);

    try {
      state = state.copyWith(isLoading: true);

      final post = await repository.getPostById(_postId);

      final isLiked =
          await repository.isPostLikedByUser(postId: _postId, userId: userId);

      final isDisliked = await repository.isPostDislikedByUser(
          postId: _postId, userId: userId);

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
    final repository = ref.watch(postRepositoryProvider);

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
          postId: _postId,
          userId: userId,
          isAlt: isAlt,
          feedType: effectiveFeedType,
          herdId: herdId);

      if (!ref.mounted) return;
    } catch (e) {
      if (!ref.mounted) return;

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
    final repository = ref.watch(postRepositoryProvider);

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
          postId: _postId, userId: userId, isAlt: isAlt);

      if (!ref.mounted) return;
    } catch (e) {
      if (!ref.mounted) return;

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
