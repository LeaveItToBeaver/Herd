import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/public_feed/view/providers/state/public_feed_state.dart';
import 'package:herdapp/features/feed/alt_feed/view/providers/state/alt_feed_states.dart';

import '../data/repositories/feed_repository.dart';

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
              dislikeCount: post.isDisliked ? post.dislikeCount - 1 : post.dislikeCount,
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
final publicFeedControllerProvider = StateNotifierProvider<PublicFeedController, PublicFeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  final user = ref.watch(authProvider);

  if (user == null) {
    // Return a dummy controller if user is not logged in
    return PublicFeedController(repository, '');
  }

  return PublicFeedController(repository, user.uid);
});

// ===== ALT FEED CONTROLLERS =====

/// Controller for alt feed with pagination
class AltFeedController extends StateNotifier<AltFeedState> {
  final FeedRepository repository;
  final String? userId;
  final int pageSize;
  bool _showHerdPosts = true;

  bool get showHerdPosts => _showHerdPosts;

  AltFeedController(this.repository, this.userId, {this.pageSize = 15})
      : super(AltFeedState.initial());

  /// Toggle whether to show herd posts in the alt feed
  void toggleHerdPostsFilter(bool show) {
    _showHerdPosts = show;
    refreshFeed();
  }

  /// Load initial alt feed posts
  Future<void> loadInitialPosts({String? overrideUserId}) async {
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

      // Try cloud function first
      try {
        final posts = await repository.getFeedFromFunction(
          userId: effectiveUserId,
          feedType: 'alt',
          limit: pageSize,
        );

        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMorePosts: posts.length >= pageSize,
          lastPost: posts.isNotEmpty ? posts.last : null,
        );
        return;
      } catch (e) {
        // Fall back to direct Firestore query
        print('Falling back to direct Firestore query: $e');
      }

      final posts = await repository.getAltFeed(
        userId: effectiveUserId,
        limit: pageSize,
        includeHerdPosts: _showHerdPosts,
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
      if (state.isLoading || !state.hasMorePosts || state.posts.isEmpty || userId == null) {
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

      final morePosts = await repository.getAltFeed(
        userId: userId!,
        limit: pageSize,
        lastHotScore: lastPost.hotScore,
        lastPostId: lastPost.id,
        includeHerdPosts: _showHerdPosts,
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
      if (userId == null) return;

      state = state.copyWith(isRefreshing: true, error: null);

      // Try cloud function first
      try {
        final posts = await repository.getFeedFromFunction(
          userId: userId!,
          feedType: 'alt',
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

      final posts = await repository.getAltFeed(
        userId: userId!,
        limit: pageSize,
        includeHerdPosts: _showHerdPosts,
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
              dislikeCount: post.isDisliked ? post.dislikeCount - 1 : post.dislikeCount,
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
final altFeedControllerProvider = StateNotifierProvider<AltFeedController, AltFeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  final user = ref.watch(authProvider);

  return AltFeedController(repository, user?.uid);
});

// ===== TRENDING POSTS PROVIDERS =====

/// Provider for trending public posts
final trendingPublicPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getTrendingPosts(isAlt: false);
});

/// Provider for highlighted alt posts
final highlightedAltPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getTrendingPosts(isAlt: true, limit: 5);
});