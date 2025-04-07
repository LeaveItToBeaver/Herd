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

      final isLiked = await repository.isPostLikedByUser(
          postId: postId,
          userId: userId
      );

      final isDisliked = await repository.isPostDislikedByUser(
          postId: postId,
          userId: userId
      );

      state = state.copyWith(
        isLiked: isLiked,
        isDisliked: isDisliked,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
  Future<void> likePost(String userId) async {
    try {
      // Track the previous state to revert if needed
      final previousState = state;

      // Update state optimistically
      state = state.copyWith(
        isLiked: !state.isLiked,
        isDisliked: false, // Remove dislike if present
        isLoading: true,
      );

      // Call the cloud function via repository
      await repository.likePost(postId: postId, userId: userId);

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

  Future<void> dislikePost(String userId) async {
    try {
      // Track the previous state
      final previousState = state;

      // Update state optimistically
      state = state.copyWith(
        isDisliked: !state.isDisliked,
        isLiked: false, // Remove like if present
        isLoading: true,
      );

      // Call the cloud function via repository
      await repository.dislikePost(postId: postId, userId: userId);

      // Update state
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