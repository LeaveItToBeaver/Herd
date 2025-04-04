import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';

import '../../../../user/view/providers/current_user_provider.dart';
import '../../../data/repositories/post_repository.dart';

class PostInteractionsNotifier extends StateNotifier<PostInteractionState> {
  final Ref _ref;
  final PostRepository _postRepository;
  final String _postId;
  final bool? _isAlt;  // Now storing the privacy status
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  PostInteractionsNotifier({
    required PostRepository repository,
    required Ref ref,
    required String postId,
    bool? isAlt,  // Add this parameter
  })  : _postRepository = repository,
        _ref = ref,
        _postId = postId,
        _isAlt = isAlt,  // Save it to the field
        super(const PostInteractionState()) {
    // Auto-initialize when created
    final userId = _ref.read(currentUserProvider)?.id;
    if (userId != null) {
      initializeState(userId);
    }

    // Listen for user changes
    _ref.listen(currentUserProvider, (previous, next) {
      if (next != null && previous?.id != next.id) {
        initializeState(next.id);
      }
    });

    // Listen for like status changes
    _ref.listen(isPostLikedByUserProvider(_postId), (previous, next) {
      if (next.value != null) {
        state = state.copyWith(isLiked: next.value!);
      }
    });

    // Listen for dislike status changes
    _ref.listen(isPostDislikedByUserProvider(_postId), (previous, next) {
      if (next.value != null) {
        state = state.copyWith(isDisliked: next.value!);
      }
    });

    // Listen for post updates
    if (_isAlt != null) {
      // If we know privacy status, use the enhanced provider
      _ref.listen(
          postProviderWithPrivacy(PostParams(id: _postId, isAlt: _isAlt!)),
              (previous, next) {
            if (next.value != null) {
              final netLikes = next.value!.likeCount - next.value!.dislikeCount;
              state = state.copyWith(
                totalLikes: netLikes,
                totalRawLikes: next.value!.likeCount,
                totalRawDislikes: next.value!.dislikeCount,
              );
            }
          }
      );
    } else {
      // Otherwise use the regular provider
      _ref.listen(
          postProvider(_postId),
              (previous, next) {
            if (next.value != null) {
              final netLikes = next.value!.likeCount - next.value!.dislikeCount;
              state = state.copyWith(
                totalLikes: netLikes,
                totalRawLikes: next.value!.likeCount,
                totalRawDislikes: next.value!.dislikeCount,
              );
            }
          }
      );
    }
  }

  Future<void> initializeState(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final isLiked = await _postRepository.isPostLikedByUser(
          postId: _postId,
          userId: userId
      );
      final isDisliked = await _postRepository.isPostDislikedByUser(
          postId: _postId,
          userId: userId
      );

      // Pass privacy status to the repository
      final post = await _postRepository.getPostById(_postId, isAlt: _isAlt);

      if (post != null) {
        final netLikes = post.likeCount - post.dislikeCount;
        state = state.copyWith(
          isLoading: false,
          isLiked: isLiked,
          isDisliked: isDisliked,
          totalLikes: netLikes,
          totalRawLikes: post.likeCount,
          totalRawDislikes: post.dislikeCount,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isLiked: isLiked,
          isDisliked: isDisliked,
          totalLikes: 0,
          totalRawLikes: 0,
          totalRawDislikes: 0,
        );
      }
    } catch(e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> likePost(String userId) async {
    try {
      // Capture original state to revert in case of error
      final originalState = state;

      // Optimistically update UI state
      int rawLikeChange = state.isLiked ? -1 : 1;
      int rawDislikeChange = state.isDisliked ? -1 : 0;

      state = state.copyWith(
        isLoading: true,
        error: null,
        isLiked: !state.isLiked,
        isDisliked: false, // Remove dislike if present
        totalRawLikes: state.totalRawLikes + rawLikeChange,
        totalRawDislikes: state.totalRawDislikes + rawDislikeChange,
        totalLikes: (state.totalRawLikes + rawLikeChange) - (state.totalRawDislikes + rawDislikeChange),
      );

      try {
        final post = await _postRepository.getPostById(_postId, isAlt: _isAlt);
        final herdId = post?.herdId;

        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken();

        // Call cloud function
        final callable = _functions.httpsCallable('handlePostLike');
        final result = await callable.call<Map<String, dynamic>>({
          'postId': _postId,
          'isAlt': _isAlt ?? false,
          'idToken': idToken,
          'herdId': herdId,
        });

        final data = result.data;

        // Update state with server-confirmed values
        if (data != null && data['successful'] == true) {
          state = state.copyWith(
            isLoading: false,
            isLiked: data['isLiked'] ?? !originalState.isLiked,
            isDisliked: data['isDisliked'] ?? false,
            totalRawLikes: data['likeCount'] ?? state.totalRawLikes,
            totalRawDislikes: data['dislikeCount'] ?? state.totalRawDislikes,
          );

          // Calculate net likes
          state = state.copyWith(
            totalLikes: state.totalRawLikes - state.totalRawDislikes,
          );

          // Invalidate relevant providers to refresh UI
          _invalidateProviders();
          return;
        } else {
          // Revert to original state on error
          state = originalState.copyWith(isLoading: false);
          throw Exception("Unexpected response from server");
        }
      } catch (e) {
        // On error, use local repository as fallback
        debugPrint('Cloud function error, falling back to repository: $e');
        await _postRepository.likePost(postId: _postId, userId: userId);
        _invalidateProviders();

        // Update state using local calculation
        state = state.copyWith(
          isLoading: false,
          isLiked: !originalState.isLiked,
          isDisliked: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> dislikePost(String userId) async {
    try {
      // Capture original state to revert in case of error
      final originalState = state;

      // Optimistically update UI state
      int rawDislikeChange = state.isDisliked ? -1 : 1;
      int rawLikeChange = state.isLiked ? -1 : 0;

      state = state.copyWith(
        isLoading: true,
        error: null,
        isDisliked: !state.isDisliked,
        isLiked: false, // Remove like if present
        totalRawDislikes: state.totalRawDislikes + rawDislikeChange,
        totalRawLikes: state.totalRawLikes + rawLikeChange,
        totalLikes: (state.totalRawLikes + rawLikeChange) - (state.totalRawDislikes + rawDislikeChange),
      );

      try {
        final post = await _postRepository.getPostById(_postId, isAlt: _isAlt);
        final herdId = post?.herdId;

        final user = FirebaseAuth.instance.currentUser;
        final idToken = await user?.getIdToken();


        // Call cloud function
        final callable = _functions.httpsCallable('handlePostDislike');
        final result = await callable.call<Map<String, dynamic>>({
          'postId': _postId,
          'isAlt':  _isAlt ?? false,
          'idToken': idToken,
          'herdId': herdId,
        });

        final data = result.data;

        // Update state with server-confirmed values
        if (data != null && data['successful'] == true) {
          state = state.copyWith(
            isLoading: false,
            isDisliked: data['isDisliked'] ?? !originalState.isDisliked,
            isLiked: data['isLiked'] ?? false,
            totalRawLikes: data['likeCount'] ?? state.totalRawLikes,
            totalRawDislikes: data['dislikeCount'] ?? state.totalRawDislikes,
          );

          // Calculate net likes
          state = state.copyWith(
            totalLikes: state.totalRawLikes - state.totalRawDislikes,
          );

          // Invalidate relevant providers to refresh UI
          _invalidateProviders();
          return;
        } else {
          // Revert to original state on error
          state = originalState.copyWith(isLoading: false);
          throw Exception("Unexpected response from server");
        }
      } catch (e) {
        // On error, use local repository as fallback
        debugPrint('Cloud function error, falling back to repository: $e');
        await _postRepository.dislikePost(postId: _postId, userId: userId);
        _invalidateProviders();

        // Update state using local calculation
        state = state.copyWith(
          isLoading: false,
          isLiked: false,
          isDisliked: !originalState.isDisliked,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Helper method to invalidate all relevant providers
  void _invalidateProviders() {
    _ref.invalidate(isPostLikedByUserProvider(_postId));
    _ref.invalidate(isPostDislikedByUserProvider(_postId));

    // Invalidate the appropriate post provider
    if (_isAlt != null) {
      _ref.invalidate(postProviderWithPrivacy(PostParams(id: _postId, isAlt: _isAlt!)));
    } else {
      _ref.invalidate(postProvider(_postId));
    }
  }
}