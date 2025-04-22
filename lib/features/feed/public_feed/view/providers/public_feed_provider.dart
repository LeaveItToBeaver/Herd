import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/feed/public_feed/view/providers/state/public_feed_state.dart';

import '../../../../../core/services/cache_manager.dart';
import '../../../data/repositories/feed_repository.dart';

// Repository provider with Firebase Functions
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
});

final publicFeedCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

// ===== PUBLIC FEED CONTROLLERS =====

/// Controller for public feed with pagination
class PublicFeedController extends StateNotifier<PublicFeedState> {
  final FeedRepository repository;
  final CacheManager cacheManager;
  final String userId;
  final int pageSize;
  bool _disposed = false;

  PublicFeedController(this.repository, this.userId, this.cacheManager,
      {this.pageSize = 20})
      : super(PublicFeedState.initial());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Check if controller is still active
  bool get _isActive => !_disposed;

  /// Load initial public feed posts
  Future<void> loadInitialPosts(
      {String? overrideUserId, bool forceRefresh = false}) async {
    try {
      // Don't reload if already loading
      if (state.isLoading || _disposed) return;

      if (_isActive) state = state.copyWith(isLoading: true, error: null);

      final effectiveUserId = overrideUserId ?? userId ?? '';
      if (effectiveUserId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: Exception('User ID is required'),
        );
        return;
      }

      if (!forceRefresh) {
        debugPrint('🔎 Checking cache for alt feed: user=$effectiveUserId');
        final cachedPosts =
            await cacheManager.getFeed(effectiveUserId, isAlt: true);

        if (cachedPosts.isNotEmpty) {
          debugPrint('✅ Retrieved ${cachedPosts.length} posts from cache');
          state = state.copyWith(
            posts: cachedPosts,
            isLoading: false,
            hasMorePosts: cachedPosts.length >= pageSize,
            lastPost: cachedPosts.isNotEmpty ? cachedPosts.last : null,
            fromCache: true,
          );
          return;
        }
        debugPrint('⚠️ No cached posts found');
      } else {
        debugPrint('🔄 Force refresh requested, skipping cache');
      }

      try {
        // Get posts from repository
        final posts = await repository.getPublicFeed(
          userId: effectiveUserId,
          limit: pageSize,
        );

        // Cache the results
        await cacheManager.cacheFeed(posts, effectiveUserId, isAlt: true);
        await cacheManager.getCacheStats();

        if (_isActive) {
          state = state.copyWith(
            posts: posts,
            isLoading: false,
            hasMorePosts: posts.length >= pageSize,
            lastPost: posts.isNotEmpty ? posts.last : null,
            fromCache: false,
          );
        }
      } catch (e) {
        // Fall back to direct Firestore query
        if (kDebugMode) {
          print('Falling back to direct Firestore query: $e');
        }
      }

      // Get from user feed collection directly
      final posts = await repository.getPublicFeed(
        userId: effectiveUserId,
        limit: pageSize,
      );

      // Cache the results
      await cacheManager.cacheFeed(posts, effectiveUserId, isAlt: true);

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        fromCache: false,
      );
    } catch (e) {
      if (_isActive) {
        state = state.copyWith(
          isLoading: false,
          error: e,
        );
      }
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

  return PublicFeedController(
      repository, user!.uid, ref.watch(publicFeedCacheManagerProvider));
});
