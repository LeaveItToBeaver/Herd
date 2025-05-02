import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/feed/alt_feed/view/providers/state/alt_feed_states.dart';

import '../../../../../core/services/cache_manager.dart';
import '../../../../post/data/models/post_model.dart';
import '../../../../post/view/providers/post_provider.dart';
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
  final Ref ref;
  bool _showHerdPosts = true;
  bool _disposed = false;
  StreamSubscription? _postUpdateSubscription;

  bool get showHerdPosts => _showHerdPosts;

  AltFeedController(this.repository, this.userId, this.cacheManager, this.ref,
      {this.pageSize = 15})
      : super(AltFeedState.initial()) {
    // Listen for post updates from repository
    _postUpdateSubscription = repository.postUpdates.listen(_handlePostUpdates);
  }

  /// Toggle whether to show herd posts in the alt feed
  void toggleHerdPostsFilter(bool show) {
    _showHerdPosts = show;
    refreshFeed();
  }

  @override
  void dispose() {
    _disposed = true;
    _postUpdateSubscription?.cancel();
    super.dispose();
  }

  bool get _isActive => !_disposed;

  void _safeUpdateState(AltFeedState newState) {
    if (_isActive) {
      state = newState;
    }
  }

  Future<void> _batchInitializePostInteractions(List<PostModel> posts) async {
    if (posts.isEmpty || userId == null) return;

    debugPrint('🔄 Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId!);
    }

    debugPrint('✅ Interactions batch initialization complete');
  }

  void _handlePostUpdates(List<PostModel> updatedPosts) {
    if (!mounted) return;

    // Only update if we have posts and we're not loading
    if (updatedPosts.isEmpty || state.isLoading) return;

    // We need to merge updated posts with existing ones
    // by preserving posts that aren't in the update
    final existingPostIds = state.posts.map((p) => p.id).toSet();
    final updatedPostIds = updatedPosts.map((p) => p.id).toSet();

    // Keep posts that aren't in the update
    final postsToKeep =
        state.posts.where((p) => !updatedPostIds.contains(p.id)).toList();

    // Create final list with updated posts first, then unchanged posts
    final mergedPosts = [...updatedPosts, ...postsToKeep];

    // Sort by hot score to maintain correct order
    mergedPosts.sort((a, b) => (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

    // Update state with merged posts
    state = state.copyWith(
      posts: mergedPosts,
      isRefreshing: false,
      hasMorePosts: repository.hasMorePosts,
    );

    debugPrint(
        '✨ Updated feed with fresh data: ${updatedPosts.length} posts refreshed');
  }

  Future<void> loadInitialPosts(
      {String? overrideUserId, bool forceRefresh = false}) async {
    try {
      // Don't reload if already loading
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      final effectiveUserId = overrideUserId ?? userId ?? '';
      if (effectiveUserId.isEmpty) {
        _safeUpdateState(state.copyWith(
          isLoading: false,
          error: Exception('User ID is required'),
        ));
        return;
      }

      // Use hybrid loading unless we're forcing a refresh
      final posts = await repository.getFeedFromFunction(
        userId: effectiveUserId,
        feedType: 'alt',
        limit: pageSize,
        hybridLoad: !forceRefresh,
      );

      _safeUpdateState(state.copyWith(
        posts: posts,
        isLoading: false,
        isRefreshing: false,
        // Use length check rather than repository value for initial load
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        fromCache: !forceRefresh && posts.isNotEmpty,
      ));
      await _batchInitializePostInteractions(posts);
    } catch (e) {
      if (_isActive) {
        _safeUpdateState(state.copyWith(
          isLoading: false,
          error: e,
        ));
      }
    }
  }

  /// Load initial alt feed posts
  // Future<void> loadInitialPosts(
  //     {String? overrideUserId, bool forceRefresh = false}) async {
  //   try {
  //     // Don't reload if already loading
  //     if (state.isLoading) return;
  //
  //     state = state.copyWith(isLoading: true, error: null);
  //
  //     final effectiveUserId = overrideUserId ?? userId ?? '';
  //     if (effectiveUserId.isEmpty) {
  //       state = state.copyWith(
  //         isLoading: false,
  //         error: Exception('User ID is required'),
  //       );
  //       return;
  //     }
  //
  //     // Try to load from cache if not forcing refresh
  //     if (!forceRefresh) {
  //       debugPrint('🔎 Checking cache for alt feed: user=$effectiveUserId');
  //       final cachedPosts =
  //           await cacheManager.getFeed(effectiveUserId, isAlt: true);
  //
  //       if (cachedPosts.isNotEmpty) {
  //         debugPrint('✅ Retrieved ${cachedPosts.length} posts from cache');
  //         state = state.copyWith(
  //           posts: cachedPosts,
  //           isLoading: false,
  //           hasMorePosts: cachedPosts.length >= pageSize,
  //           lastPost: cachedPosts.isNotEmpty ? cachedPosts.last : null,
  //           fromCache: true,
  //         );
  //         return;
  //       }
  //       debugPrint('⚠️ No cached posts found');
  //     } else {
  //       debugPrint('🔄 Force refresh requested, skipping cache');
  //     }
  //
  //     // Try cloud function first if no cache or forcing refresh
  //     try {
  //       final posts = await repository.getFeedFromFunction(
  //         userId: effectiveUserId,
  //         feedType: 'alt',
  //         limit: pageSize,
  //       );
  //
  //       // Cache the results
  //       await cacheManager.cacheFeed(posts, effectiveUserId, isAlt: true);
  //       await cacheManager.getCacheStats();
  //
  //       state = state.copyWith(
  //         posts: posts,
  //         isLoading: false,
  //         hasMorePosts: posts.length >= pageSize,
  //         lastPost: posts.isNotEmpty ? posts.last : null,
  //         fromCache: false,
  //       );
  //       return;
  //     } catch (e) {
  //       // Fall back to direct Firestore query
  //       if (kDebugMode) {
  //         print('Falling back to direct Firestore query: $e');
  //       }
  //     }
  //
  //     // Get from user feed collection directly
  //     final posts = await repository.getAltFeed(
  //       userId: effectiveUserId,
  //       limit: pageSize,
  //       includeHerdPosts: _showHerdPosts,
  //     );
  //
  //     // Cache the results
  //     await cacheManager.cacheFeed(posts, effectiveUserId, isAlt: true);
  //
  //     state = state.copyWith(
  //       posts: posts,
  //       isLoading: false,
  //       hasMorePosts: posts.length >= pageSize,
  //       lastPost: posts.isNotEmpty ? posts.last : null,
  //       fromCache: false,
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       error: e,
  //     );
  //   }
  // }

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
      debugPrint('PAGINATION: Attempting to load more posts');
      debugPrint('PAGINATION: hasMorePosts=${repository.hasMorePosts}');
      debugPrint(
          'PAGINATION: lastHotScore=${repository.lastHotScore}, lastPostId=${repository.lastPostId}');

      if (lastPost == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      try {
        // Get next batch of posts with proper pagination parameters
        final List<PostModel> morePosts = await repository.getFeedFromFunction(
          userId: userId!,
          feedType: 'alt',
          limit: pageSize,
          lastHotScore: lastPost.hotScore,
          lastPostId: lastPost.id,
        );

        final gotFullPage = morePosts.length >= pageSize;

        // Check for empty results
        if (morePosts.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            hasMorePosts: false,
          );
          return;
        }

        // Check for duplicates - critical for preventing infinite scrolling bug
        final existingIds = state.posts.map((p) => p.id).toSet();
        final uniqueNewPosts =
            morePosts.where((p) => !existingIds.contains(p.id)).toList();

        if (uniqueNewPosts.isEmpty) {
          // If we only got duplicate posts, we've reached the end
          state = state.copyWith(
            isLoading: false,
            hasMorePosts: false,
          );
          return;
        }

        // Add the new unique posts to the existing list
        final allPosts = [...state.posts, ...uniqueNewPosts];

        // *** ADD LOGGING HERE ***
        final repoHasMore = repository.hasMorePosts; // Read it explicitly
        debugPrint(
            'AltFeedController: Updating state. Read repository.hasMorePosts = $repoHasMore');

        state = state.copyWith(
          posts: allPosts,
          isLoading: false,
          hasMorePosts: gotFullPage, // Use the local calculation
          lastPost: uniqueNewPosts.isNotEmpty ? uniqueNewPosts.last : lastPost,
        );
        await _batchInitializePostInteractions(allPosts);

        debugPrint(
            'AltFeedController: State updated. New state.hasMorePosts = ${state.hasMorePosts}'); // Log after update
      } catch (e) {
        // Fall back to direct Firestore query
        debugPrint('Falling back to direct Firestore query: $e');

        // Get from user feed collection directly
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
        await _batchInitializePostInteractions(allPosts);
      }
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
      repository, user?.uid, ref.watch(altFeedCacheManagerProvider), ref);
});
