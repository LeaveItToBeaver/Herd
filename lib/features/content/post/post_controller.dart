import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'data/models/post_model.dart';
import 'view/providers/state/post_interaction_state.dart';

part 'post_controller.g.dart';

// Provider for user posts with privacy filter
@riverpod
Stream<List<PostModel>> userPostsFromController(Ref ref, String userId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getUserPosts(userId);
}

// Provider for user's public posts only
@riverpod
Future<List<PostModel>> userPublicPosts(Ref ref, String userId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return await postRepository.getFutureUserPublicPosts(userId);
}

// Provider for user's alt posts only
@riverpod
Future<List<PostModel>> userAltPosts(Ref ref, String userId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return await postRepository.getFutureUserAltProfilePosts(userId);
}

// Provider for a single post - simplified from post_provider.dart
@riverpod
Stream<PostModel?> postFromController(Ref ref, String postId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.streamPost(postId);
}

// Provider to check if post is liked by current user
@riverpod
Future<bool> isPostLikedByUserFromController(Ref ref, String postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final user = ref.read(currentUserProvider);
  final userId = user.userId;
  if (userId == null) return false;
  return postRepository.isPostLikedByUser(postId: postId, userId: userId);
}

// Provider to check if post is disliked by current user
@riverpod
Future<bool> isPostDislikedByUserFromController(Ref ref, String postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final user = ref.read(currentUserProvider);
  final userId = user.userId;
  if (userId == null) return false;
  return postRepository.isPostDislikedByUser(postId: postId, userId: userId);
}

// Provider for post interactions
@riverpod
class PostInteractions extends _$PostInteractions {
  late String _postId;

  @override
  PostInteractionState build(String postId) {
    _postId = postId;
    return PostInteractionState.initial();
  }

  Future<void> initializeState(String userId) async {
    await loadInteractionStatus(userId);
  }

  Future<void> loadInteractionStatus(String userId) async {
    final repository = ref.watch(postRepositoryProvider);

    try {
      state = state.copyWith(isLoading: true);

      final post = await repository.getPostById(_postId);

      if (!ref.mounted) return;

      final isLiked =
          await repository.isPostLikedByUser(postId: _postId, userId: userId);

      if (!ref.mounted) return;

      final isDisliked = await repository.isPostDislikedByUser(
          postId: _postId, userId: userId);

      if (!ref.mounted) return;

      state = state.copyWith(
        isLiked: isLiked,
        isDisliked: isDisliked,
        totalRawLikes: post?.likeCount ?? 0,
        totalRawDislikes: post?.dislikeCount ?? 0,
        totalLikes: (post?.likeCount ?? 0) - (post?.dislikeCount ?? 0),
        totalComments: post?.commentCount ?? 0,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
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

      String effectiveFeedType = feedType ?? (isAlt ? 'alt' : 'public');

      await repository.likePost(
          postId: _postId,
          userId: userId,
          isAlt: isAlt,
          feedType: effectiveFeedType,
          herdId: herdId);
    } catch (e) {
      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      final originalLikeCount =
          wasLiked ? state.totalRawLikes + 1 : state.totalRawLikes - 1;
      final originalDislikeCount =
          wasDisliked ? state.totalRawDislikes + 1 : state.totalRawDislikes;

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

      final newLikeCount =
          wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes;
      final newDislikeCount =
          wasDisliked ? state.totalRawDislikes - 1 : state.totalRawDislikes + 1;

      state = state.copyWith(
        isDisliked: !wasDisliked,
        isLiked: false,
        totalRawLikes: newLikeCount,
        totalRawDislikes: newDislikeCount,
        totalLikes: newLikeCount - newDislikeCount,
      );

      await repository.dislikePost(
          postId: _postId, userId: userId, isAlt: isAlt);
    } catch (e) {
      final wasLiked = state.isLiked;
      final wasDisliked = state.isDisliked;

      final originalLikeCount =
          wasLiked ? state.totalRawLikes + 1 : state.totalRawLikes;
      final originalDislikeCount =
          wasDisliked ? state.totalRawDislikes + 1 : state.totalRawDislikes - 1;

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
