import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'state/post_interaction_state.dart';

part 'post_provider.g.dart';

// Repository provider
@riverpod
PostRepository postRepository(Ref ref) {
  return PostRepository();
}

// User posts provider
@riverpod
Stream<List<PostModel>> userPosts(Ref ref, String userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getUserPosts(userId);
}

// Creating a new post provider
// final postControllerProvider =
//     StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>(
//         (ref) {
//   final userRepository = ref.watch(userRepositoryProvider);
//   final postRepository = ref.watch(postRepositoryProvider);
//   return CreatePostController(userRepository, postRepository);
// });

// Regular post provider - uses a plain String as parameter
@riverpod
Stream<PostModel?> post(Ref ref, String postId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.streamPost(postId);
}

// Enhanced post provider - can specify isAlt
// Use a class instead of a record for better compatibility
class PostParams {
  final String id;
  final bool isAlt;
  final String? herdId;

  PostParams({required this.id, required this.isAlt, this.herdId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isAlt == other.isAlt;

  @override
  int get hashCode => id.hashCode ^ isAlt.hashCode;
}

@riverpod
Stream<PostModel?> postWithPrivacy(Ref ref, PostParams params) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.streamPost(params.id, isAlt: params.isAlt);
}

@riverpod
Future<PostModel?> staticPost(Ref ref, PostParams params) async {
  final repository = ref.watch(postRepositoryProvider);
  // Fetch the post data a single time
  return repository.getPostById(params.id, isAlt: params.isAlt);
}

// Providers for checking like/dislike status
@riverpod
Future<bool> isPostLikedByUser(Ref ref, String postId) async {
  final currentUserAsync = ref.read(currentUserProvider);
  final userId = currentUserAsync.userId;

  if (userId == null) {
    return false;
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostLikedByUser(postId: postId, userId: userId);
}

@riverpod
Future<bool> isPostDislikedByUser(Ref ref, String postId) async {
  final currentUserAsync = ref.read(currentUserProvider);
  final userId = currentUserAsync.userId;

  if (userId == null) {
    return false;
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostDislikedByUser(postId: postId, userId: userId);
}

// Post interactions provider with privacy setting
@riverpod
class PostInteractionsWithPrivacy extends _$PostInteractionsWithPrivacy {
  late PostParams _params;

  @override
  PostInteractionState build(PostParams params) {
    _params = params;
    // Return initial state
    return PostInteractionState.initial();
  }

  Future<void> initializeState(String userId) async {
    await loadInteractionStatus(userId);
  }

  Future<void> loadInteractionStatus(String userId) async {
    final repository = ref.watch(postRepositoryProvider);

    try {
      state = state.copyWith(isLoading: true);

      final post =
          await repository.getPostById(_params.id, isAlt: _params.isAlt);

      if (!ref.mounted) return;

      final isLiked = await repository.isPostLikedByUser(
          postId: _params.id, userId: userId);

      if (!ref.mounted) return;

      final isDisliked = await repository.isPostDislikedByUser(
          postId: _params.id, userId: userId);

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

      String effectiveFeedType = feedType ?? (isAlt ? 'alt' : 'public');

      await repository.likePost(
          postId: _params.id,
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
          postId: _params.id, userId: userId, isAlt: isAlt);
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
