import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import 'package:herdapp/features/post/view/providers/state/post_state.dart';

import '../../../data/repositories/post_repository.dart';

class PostInteractionsNotifier extends StateNotifier<PostInteractionState> {
  final Ref _ref;
  final PostRepository _postRepository;
  final String _postId;

  PostInteractionsNotifier({
    required PostRepository repository,
    required Ref ref,
    required String postId,
  })  : _postRepository = repository,
        _ref = ref,
        _postId = postId,
        super(const PostInteractionState());

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

      final post = await _postRepository.getPostById(_postId);

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

      _ref.invalidate(isPostLikedByUserProvider(_postId));
      _ref.invalidate(isPostDislikedByUserProvider(_postId));
      _ref.invalidate(postProvider(_postId));

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

      _ref.invalidate(isPostLikedByUserProvider(_postId));
      _ref.invalidate(isPostDislikedByUserProvider(_postId));
      _ref.invalidate(postProvider(_postId));

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