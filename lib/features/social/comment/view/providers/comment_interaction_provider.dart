import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/social/comment/data/repositories/comment_repository.dart';
import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';

final commentInteractionProvider = StateNotifierProvider.family<
    CommentInteractionNotifier,
    CommentInteractionState,
    ({String commentId, String postId})>((ref, params) {
  final repository = ref.watch(commentRepositoryProvider);
  final currentUser = ref.read(currentUserProvider);

  // Use the extension method to safely extract the ID
  final userId = currentUser.userId ?? '';

  return CommentInteractionNotifier(
      repository, params.commentId, userId, params.postId);
});

class CommentInteractionNotifier
    extends StateNotifier<CommentInteractionState> {
  final CommentRepository _repository;
  final String _commentId;
  final String _userId;
  final String _postId;

  CommentInteractionNotifier(
      this._repository, this._commentId, this._userId, this._postId)
      : super(const CommentInteractionState()) {
    _loadInteractionState();
  }

  // Initialize state when the provider is created
  void initializeState() {
    _loadInteractionState();
  }

  Future<void> _loadInteractionState() async {
    try {
      final isLiked = await _repository.isCommentLikedByUser(
          commentId: _commentId, userId: _userId);

      final isDisliked = await _repository.isCommentDislikedByUser(
          commentId: _commentId, userId: _userId);

      // Get the comment to get current like/dislike counts
      final commentDoc = await FirebaseFirestore.instance
          .collection('comments')
          .doc(_postId)
          .collection('postComments')
          .doc(_commentId)
          .get();

      if (commentDoc.exists) {
        final data = commentDoc.data()!;
        state = CommentInteractionState(
          isLiked: isLiked,
          isDisliked: isDisliked,
          likeCount: data['likeCount'] ?? 0,
          dislikeCount: data['dislikeCount'] ?? 0,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading interaction state: $e');
      }
    }
  }

  Future<void> toggleLike() async {
    if (state.isLoading) return;

    // Optimistic update
    final wasLiked = state.isLiked;
    final wasDisliked = state.isDisliked;

    // Calculate new counts
    final newLikeCount = wasLiked ? state.likeCount - 1 : state.likeCount + 1;

    final newDislikeCount =
        wasDisliked && !wasLiked ? state.dislikeCount - 1 : state.dislikeCount;

    // Update state optimistically
    state = CommentInteractionState(
      isLiked: !wasLiked,
      isDisliked: false, // Remove dislike if present
      likeCount: newLikeCount,
      dislikeCount: newDislikeCount,
      isLoading: true,
    );

    try {
      // Perform the action
      await _repository.toggleLikeComment(
        commentId: _commentId,
        userId: _userId,
        postId: _postId,
      );

      // Mark loading complete
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling like: $e');
      }

      // Revert on error
      state = CommentInteractionState(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        likeCount: state.likeCount + (wasLiked ? 1 : -1),
        dislikeCount: wasDisliked && !wasLiked
            ? state.dislikeCount + 1
            : state.dislikeCount,
        isLoading: false,
      );
    }
  }

  Future<void> toggleDislike() async {
    if (state.isLoading) return;

    // Optimistic update
    final wasLiked = state.isLiked;
    final wasDisliked = state.isDisliked;

    // Calculate new counts
    final newDislikeCount =
        wasDisliked ? state.dislikeCount - 1 : state.dislikeCount + 1;

    final newLikeCount =
        wasLiked && !wasDisliked ? state.likeCount - 1 : state.likeCount;

    // Update state optimistically
    state = CommentInteractionState(
      isDisliked: !wasDisliked,
      isLiked: false, // Remove like if present
      dislikeCount: newDislikeCount,
      likeCount: newLikeCount,
      isLoading: true,
    );

    try {
      // Perform the action
      await _repository.toggleDislikeComment(
        commentId: _commentId,
        userId: _userId,
        postId: _postId,
      );

      // Mark loading complete
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling dislike: $e');
      }

      // Revert on error
      state = CommentInteractionState(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        likeCount:
            wasLiked && !wasDisliked ? state.likeCount + 1 : state.likeCount,
        dislikeCount: state.dislikeCount + (wasDisliked ? 1 : -1),
        isLoading: false,
      );
    }
  }
}
