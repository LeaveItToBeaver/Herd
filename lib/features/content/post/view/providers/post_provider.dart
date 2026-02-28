import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';
import 'state/post_interaction_state.dart';

// Using keepAlive provider that reads from non-keepAlive providers is valid
// when we only need to read values once (not watch for changes).
// ignore_for_file: avoid_manual_providers_as_generated_provider_dependency
// ignore_for_file: provider_dependencies

part 'post_provider.g.dart';

// Repository provider - keepAlive since it's a stateless singleton
@Riverpod(keepAlive: true)
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
          isAlt == other.isAlt &&
          herdId == other.herdId;

  @override
  int get hashCode => Object.hash(id, isAlt, herdId);
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
// keepAlive: true ensures the provider survives async gaps during loading
@Riverpod(keepAlive: true)
class PostInteractionsWithPrivacy extends _$PostInteractionsWithPrivacy {
  late PostParams _params;

  @override
  PostInteractionState build(PostParams params) {
    _params = params;

    // Auto-initialize: schedule loading if user is logged in.
    // We check via a post-frame callback to allow the widget tree to settle,
    // then verify state.isInitialized to avoid duplicate loads.
    final currentUserAsync = ref.read(currentUserProvider);
    final userId = currentUserAsync.userId;
    if (userId != null) {
      Future.microtask(() {
        if (!ref.mounted) return;
        // Only load if not already initialized or currently loading
        if (!state.isInitialized && !state.isLoading) {
          loadInteractionStatus(userId);
        }
      });
    }

    // Return initial state (loading will update it asynchronously)
    return PostInteractionState.initial();
  }

  Future<void> initializeState(String userId) async {
    if (state.isInitialized || state.isLoading) return;
    await loadInteractionStatus(userId);
  }

  Future<void> loadInteractionStatus(String userId) async {
    // Use ref.read since repository is stable and we're in a keepAlive provider
    final repository = ref.read(postRepositoryProvider);

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
        isInitialized: true,
      );
    } catch (e) {
      debugPrint('❌ Failed to load interactions for ${_params.id}: $e');
      if (!ref.mounted) return;
      state = state.copyWith(
        isLoading: false,
        isInitialized: true,
        error: e.toString(),
      );
    }
  }

  Future<void> likePost(String userId,
      {required bool isAlt, String? feedType, String? herdId}) async {
    // Use ref.read since repository is stable and we're in a keepAlive provider
    final repository = ref.read(postRepositoryProvider);

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
    // Use ref.read since repository is stable and we're in a keepAlive provider
    final repository = ref.read(postRepositoryProvider);

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
