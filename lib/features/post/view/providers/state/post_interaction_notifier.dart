import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';

import '../../../../user/view/providers/current_user_provider.dart';
import '../../../data/repositories/post_repository.dart';

class PostInteractionsNotifier extends StateNotifier<PostInteractionState> {
  final Ref _ref;
  final PostRepository _postRepository;
  final String _postId;
  final bool? _isPrivate;  // Now storing the privacy status

  PostInteractionsNotifier({
    required PostRepository repository,
    required Ref ref,
    required String postId,
    bool? isPrivate,  // Add this parameter
  })  : _postRepository = repository,
        _ref = ref,
        _postId = postId,
        _isPrivate = isPrivate,  // Save it to the field
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
    if (_isPrivate != null) {
      // If we know privacy status, use the enhanced provider
      _ref.listen(
          postProviderWithPrivacy(PostParams(id: _postId, isPrivate: _isPrivate!)),
              (previous, next) {
            if (next.value != null) {
              state = state.copyWith(totalLikes: next.value!.likeCount);
            }
          }
      );
    } else {
      // Otherwise use the regular provider
      _ref.listen(
          postProvider(_postId),
              (previous, next) {
            if (next.value != null) {
              state = state.copyWith(totalLikes: next.value!.likeCount);
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
      final post = await _postRepository.getPostById(_postId, isPrivate: _isPrivate);

      state = state.copyWith(
        isLoading: false,
        isLiked: isLiked,
        isDisliked: isDisliked,
        totalLikes: post?.likeCount ?? 0,
      );
    } catch(e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> likePost(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _postRepository.likePost(postId: _postId, userId: userId);

      // Invalidate providers to refresh data
      _ref.invalidate(isPostLikedByUserProvider(_postId));
      _ref.invalidate(isPostDislikedByUserProvider(_postId));

      // Invalidate the appropriate post provider
      if (_isPrivate != null) {
        _ref.invalidate(postProviderWithPrivacy(PostParams(id: _postId, isPrivate: _isPrivate!)));
      } else {
        _ref.invalidate(postProvider(_postId));
      }

      state = state.copyWith(
          isLoading: false,
          isLiked: !state.isLiked,
          isDisliked: false
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> dislikePost(String userId) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _postRepository.dislikePost(postId: _postId, userId: userId);

      // Invalidate providers to refresh data
      _ref.invalidate(isPostLikedByUserProvider(_postId));
      _ref.invalidate(isPostDislikedByUserProvider(_postId));

      // Invalidate the appropriate post provider
      if (_isPrivate != null) {
        _ref.invalidate(postProviderWithPrivacy(PostParams(id: _postId, isPrivate: _isPrivate!)));
      } else {
        _ref.invalidate(postProvider(_postId));
      }

      state = state.copyWith(
          isLoading: false,
          isDisliked: !state.isDisliked,
          isLiked: false
      );

    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}