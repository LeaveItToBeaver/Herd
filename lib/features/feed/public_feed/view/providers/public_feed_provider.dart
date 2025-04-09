import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/feed/public_feed/view/providers/state/public_feed_state.dart';

import '../../../data/repositories/feed_repository.dart';

// Repository provider with Firebase Functions
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
});

// ===== PUBLIC FEED CONTROLLERS =====

/// Controller for public feed with pagination
class PublicFeedController extends StateNotifier<PublicFeedState> {
  final FeedRepository repository;
  final String userId;
  final int pageSize;

  PublicFeedController(this.repository, this.userId, {this.pageSize = 20})
      : super(PublicFeedState.initial());

  /// Load initial public feed posts
  Future<void> loadInitialPosts() async {
    try {
      // Don't reload if already loading
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      // Try to get posts from the cloud function first
      try {
        final posts = await repository.getFeedFromFunction(
          userId: userId,
          feedType: 'public',
          limit: pageSize,
          lastHotScore: state.lastPost?.hotScore,
          lastPostId: state.lastPost?.id,
        );

        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMorePosts: posts.length >= pageSize,
          lastPost: posts.isNotEmpty ? posts.last : null,
        );
        return;
      } catch (e) {
        // If cloud function fails, fall back to direct Firestore query
        print('Falling back to direct Firestore query: $e');
      }

      final posts = await repository.getPublicFeed(
        userId: userId,
        limit: pageSize,
      );

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  /// Load more posts for pagination
  Future<void> loadMorePosts() async {
    try {
      // Don't load more if already loading or no more posts
      if (state.isLoading || !state.hasMorePosts || state.posts.isEmpty) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Get pagination info from last post
      final lastPost = state.lastPost;
      if (lastPost == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      // Try cloud function first
      try {
        final morePosts = await repository.getFeedFromFunction(
          userId: userId,
          feedType: 'public',
          limit: pageSize,
          lastHotScore: lastPost.hotScore,
          lastPostId: lastPost.id,
        );

        if (morePosts.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            hasMorePosts: false,
          );
          return;
        }

        // Merge the new posts with existing ones
        final allPosts = [...state.posts, ...morePosts];

        state = state.copyWith(
          posts: allPosts,
          isLoading: false,
          hasMorePosts: morePosts.length >= pageSize,
          lastPost: morePosts.isNotEmpty ? morePosts.last : lastPost,
        );
        return;
      } catch (e) {
        // Fall back to direct Firestore query
        print('Falling back to direct Firestore query: $e');
      }

      final morePosts = await repository.getPublicFeed(
        userId: userId,
        limit: pageSize,
        lastHotScore: lastPost.hotScore,
        lastPostId: lastPost.id,
      );

      if (morePosts.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMorePosts: false,
        );
        return;
      }

      // Merge the new posts with existing ones
      final allPosts = [...state.posts, ...morePosts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMorePosts: morePosts.length >= pageSize,
        lastPost: morePosts.isNotEmpty ? morePosts.last : lastPost,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  /// Refresh the feed (pull-to-refresh)
  Future<void> refreshFeed() async {
    try {
      state = state.copyWith(isRefreshing: true, error: null);

      // Try cloud function first
      try {
        final posts = await repository.getFeedFromFunction(
          userId: userId,
          feedType: 'public',
          limit: pageSize,
        );

        state = state.copyWith(
          posts: posts,
          isRefreshing: false,
          isLoading: false,
          hasMorePosts: posts.length >= pageSize,
          lastPost: posts.isNotEmpty ? posts.last : null,
        );
        return;
      } catch (e) {
        // Fall back to direct Firestore query
        print('Falling back to direct Firestore query: $e');
      }

      final posts = await repository.getPublicFeed(
        userId: userId,
        limit: pageSize,
      );

      state = state.copyWith(
        posts: posts,
        isRefreshing: false,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
      );
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
    }
  }

  /// Handle post like
  Future<void> likePost(String postId) async {
    try {
      await repository.interactWithPost(postId, 'like');

      // Optimistically update the UI
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          if (post.isLiked) {
            // Unlike
            return post.copyWith(
              likeCount: post.likeCount - 1,
              isLiked: false,
            );
          } else {
            // Like
            return post.copyWith(
              likeCount: post.likeCount + 1,
              isLiked: true,
              // If it was disliked before, remove dislike
              dislikeCount:
                  post.isDisliked ? post.dislikeCount - 1 : post.dislikeCount,
              isDisliked: false,
            );
          }
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      // Refresh on error to ensure UI is in sync
      refreshFeed();
    }
  }

  /// Handle post dislike
  Future<void> dislikePost(String postId) async {
    try {
      await repository.interactWithPost(postId, 'dislike');

      // Optimistically update the UI
      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          if (post.isDisliked) {
            // Undislike
            return post.copyWith(
              dislikeCount: post.dislikeCount - 1,
              isDisliked: false,
            );
          } else {
            // Dislike
            return post.copyWith(
              dislikeCount: post.dislikeCount + 1,
              isDisliked: true,
              // If it was liked before, remove like
              likeCount: post.isLiked ? post.likeCount - 1 : post.likeCount,
              isLiked: false,
            );
          }
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      // Refresh on error to ensure UI is in sync
      refreshFeed();
    }
  }
}

/// Provider for the public feed controller
final publicFeedControllerProvider =
    StateNotifierProvider<PublicFeedController, PublicFeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  final user = ref.watch(authProvider);

  return PublicFeedController(repository, user!.uid);
});
