import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:herdapp/core/services/local_cache_service.dart';
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
    final repository = ref.read(postRepositoryProvider);

    try {
      // Check local cache first — skips 3 Firestore reads per post on
      // repeated sessions (app restart, web refresh, tab switch).
      final cached = LocalCacheService().getInteraction(_params.id);
      if (cached != null) {
        state = state.copyWith(
          isLiked: cached['isLiked'] as bool? ?? false,
          isDisliked: cached['isDisliked'] as bool? ?? false,
          totalRawLikes: cached['likeCount'] as int? ?? 0,
          totalRawDislikes: cached['dislikeCount'] as int? ?? 0,
          totalLikes: (cached['likeCount'] as int? ?? 0) -
              (cached['dislikeCount'] as int? ?? 0),
          totalComments: cached['commentCount'] as int? ?? 0,
          isLoading: false,
          isInitialized: true,
        );
        return;
      }

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

      final likeCount = post?.likeCount ?? 0;
      final dislikeCount = post?.dislikeCount ?? 0;
      final commentCount = post?.commentCount ?? 0;

      // Persist to local cache so the next session skips these reads.
      await LocalCacheService().saveInteraction(_params.id, {
        'isLiked': isLiked,
        'isDisliked': isDisliked,
        'likeCount': likeCount,
        'dislikeCount': dislikeCount,
        'commentCount': commentCount,
      });

      state = state.copyWith(
        isLiked: isLiked,
        isDisliked: isDisliked,
        totalRawLikes: likeCount,
        totalRawDislikes: dislikeCount,
        totalLikes: likeCount - dislikeCount,
        totalComments: commentCount,
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
    final repository = ref.read(postRepositoryProvider);

    final wasLiked = state.isLiked;
    final wasDisliked = state.isDisliked;

    final newLikeCount =
        wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes + 1;
    final newDislikeCount =
        wasDisliked ? state.totalRawDislikes - 1 : state.totalRawDislikes;

    // Optimistic update
    state = state.copyWith(
      isLiked: !wasLiked,
      isDisliked: false,
      totalRawLikes: newLikeCount,
      totalRawDislikes: newDislikeCount,
      totalLikes: newLikeCount - newDislikeCount,
    );

    // Write-through to local cache so the next session reflects this action.
    unawaited(LocalCacheService().saveInteraction(_params.id, {
      'isLiked': !wasLiked,
      'isDisliked': false,
      'likeCount': newLikeCount,
      'dislikeCount': newDislikeCount,
      'commentCount': state.totalComments,
    }));

    try {
      final effectiveFeedType = feedType ?? (isAlt ? 'alt' : 'public');
      await repository.likePost(
          postId: _params.id,
          userId: userId,
          isAlt: isAlt,
          feedType: effectiveFeedType,
          herdId: herdId);
    } catch (e) {
      // Revert optimistic update on failure
      final revertLikeCount =
          wasLiked ? state.totalRawLikes + 1 : state.totalRawLikes - 1;
      final revertDislikeCount =
          wasDisliked ? state.totalRawDislikes + 1 : state.totalRawDislikes;
      state = state.copyWith(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        totalRawLikes: revertLikeCount,
        totalRawDislikes: revertDislikeCount,
        totalLikes: revertLikeCount - revertDislikeCount,
        error: e.toString(),
      );
      // Revert cache too
      unawaited(LocalCacheService().saveInteraction(_params.id, {
        'isLiked': wasLiked,
        'isDisliked': wasDisliked,
        'likeCount': revertLikeCount,
        'dislikeCount': revertDislikeCount,
        'commentCount': state.totalComments,
      }));
    }
  }

  Future<void> dislikePost(String userId,
      {required bool isAlt, required String feedType, String? herdId}) async {
    final repository = ref.read(postRepositoryProvider);

    final wasLiked = state.isLiked;
    final wasDisliked = state.isDisliked;

    final newLikeCount =
        wasLiked ? state.totalRawLikes - 1 : state.totalRawLikes;
    final newDislikeCount =
        wasDisliked ? state.totalRawDislikes - 1 : state.totalRawDislikes + 1;

    // Optimistic update
    state = state.copyWith(
      isDisliked: !wasDisliked,
      isLiked: false,
      totalRawLikes: newLikeCount,
      totalRawDislikes: newDislikeCount,
      totalLikes: newLikeCount - newDislikeCount,
    );

    // Write-through to local cache
    unawaited(LocalCacheService().saveInteraction(_params.id, {
      'isLiked': false,
      'isDisliked': !wasDisliked,
      'likeCount': newLikeCount,
      'dislikeCount': newDislikeCount,
      'commentCount': state.totalComments,
    }));

    try {
      await repository.dislikePost(
          postId: _params.id, userId: userId, isAlt: isAlt);
    } catch (e) {
      // Revert optimistic update on failure
      final revertLikeCount =
          wasLiked ? state.totalRawLikes + 1 : state.totalRawLikes;
      final revertDislikeCount =
          wasDisliked ? state.totalRawDislikes + 1 : state.totalRawDislikes - 1;
      state = state.copyWith(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        totalRawLikes: revertLikeCount,
        totalRawDislikes: revertDislikeCount,
        totalLikes: revertLikeCount - revertDislikeCount,
        error: e.toString(),
      );
      // Revert cache too
      unawaited(LocalCacheService().saveInteraction(_params.id, {
        'isLiked': wasLiked,
        'isDisliked': wasDisliked,
        'likeCount': revertLikeCount,
        'dislikeCount': revertDislikeCount,
        'commentCount': state.totalComments,
      }));
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
