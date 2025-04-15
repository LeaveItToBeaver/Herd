import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/feed/alt_feed/view/providers/state/alt_feed_states.dart';

import '../../../../../core/services/cache_manager.dart';
import '../../../data/repositories/feed_repository.dart';

// Repository provider with Firebase Functions
final altFeedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
});

final altFeedCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

// ===== ALT FEED CONTROLLERS =====

/// Controller for alt feed with pagination
class AltFeedController extends StateNotifier<AltFeedState> {
  final FeedRepository repository;
  final CacheManager cacheManager;
  final String? userId;
  final int pageSize;
  bool _showHerdPosts = true;

  bool get showHerdPosts => _showHerdPosts;

  AltFeedController(this.repository, this.userId, this.cacheManager,
      {this.pageSize = 15})
      : super(AltFeedState.initial());

  /// Toggle whether to show herd posts in the alt feed
  void toggleHerdPostsFilter(bool show) {
    _showHerdPosts = show;
    refreshFeed();
  }

  /// Load initial alt feed posts
  Future<void> loadInitialPosts(
      {String? overrideUserId, bool forceRefresh = false}) async {
    try {
      // Don't reload if already loading
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      final effectiveUserId = overrideUserId ?? userId ?? '';
      if (effectiveUserId.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: Exception('User ID is required'),
        );
        return;
      }

      // Try to load from cache if not forcing refresh
      if (!forceRefresh) {
        final cachedPosts =
            await cacheManager.getFeed(effectiveUserId, isAlt: true);

        if (cachedPosts.isNotEmpty) {
          state = state.copyWith(
            posts: cachedPosts,
            isLoading: false,
            hasMorePosts: cachedPosts.length >= pageSize,
            lastPost: cachedPosts.isNotEmpty ? cachedPosts.last : null,
            fromCache: true, // New field to indicate cache source
          );
          return;
        }
      }

      // Try cloud function first if no cache or forcing refresh
      try {
        final posts = await repository.getFeedFromFunction(
          userId: effectiveUserId,
          feedType: 'alt',
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
        return;
      } catch (e) {
        // Fall back to direct Firestore query
        print('Falling back to direct Firestore query: $e');
      }

      // Use the global alt feed as fallback
      final posts = await repository.getGlobalAltFeed(limit: pageSize);

      // Cache the global feed results
      await cacheManager.cacheFeed(posts, 'global', isAlt: true);

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        fromCache: false,
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
      if (state.isLoading ||
          !state.hasMorePosts ||
          state.posts.isEmpty ||
          userId == null) {
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
          userId: userId!,
          feedType: 'alt',
          limit: pageSize,
          lastHotScore: lastPost.hotScore,
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

      // Use the global alt feed for pagination
      final morePosts = await repository.getGlobalAltFeed(
        limit: pageSize,
        lastHotScore: lastPost.hotScore,
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

  Future<void> refreshFeed() async {
    try {
      if (userId == null) return;

      state = state.copyWith(isRefreshing: true, error: null);

      // Force refresh always loads fresh data from server
      await loadInitialPosts(forceRefresh: true);
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
    }
  }

  /// Refresh the feed (pull-to-refresh)
  // Future<void> refreshFeed() async {
  //   try {
  //     if (userId == null) return;
  //
  //     state = state.copyWith(isRefreshing: true, error: null);
  //
  //     // Try cloud function first
  //     try {
  //       final posts = await repository.getFeedFromFunction(
  //         userId: userId!,
  //         feedType: 'alt',
  //         limit: pageSize,
  //       );
  //
  //       state = state.copyWith(
  //         posts: posts,
  //         isRefreshing: false,
  //         isLoading: false,
  //         hasMorePosts: posts.length >= pageSize,
  //         lastPost: posts.isNotEmpty ? posts.last : null,
  //       );
  //       return;
  //     } catch (e) {
  //       // Fall back to direct Firestore query
  //       print('Falling back to direct Firestore query: $e');
  //     }
  //
  //     // Use the global alt feed for refresh
  //     final posts = await repository.getGlobalAltFeed(
  //       limit: pageSize,
  //     );
  //
  //     state = state.copyWith(
  //       posts: posts,
  //       isRefreshing: false,
  //       isLoading: false,
  //       hasMorePosts: posts.length >= pageSize,
  //       lastPost: posts.isNotEmpty ? posts.last : null,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isRefreshing: false,
  //       isLoading: false,
  //       error: e,
  //     );
  //   }
  // }

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

/// Provider for the alt feed controller
final altFeedControllerProvider =
    StateNotifierProvider<AltFeedController, AltFeedState>((ref) {
  final repository = ref.watch(altFeedRepositoryProvider);
  final user = ref.watch(authProvider);

  return AltFeedController(
    repository,
    user?.uid,
    ref.watch(altFeedCacheManagerProvider),
  );
});
