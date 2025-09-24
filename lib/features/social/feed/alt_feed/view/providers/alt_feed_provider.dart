import 'dart:async' show StreamSubscription, unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/social/feed/data/models/feed_sort_type.dart';

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

  Future<void> changeSortType(FeedSortType newSortType) async {
    if (state.sortType == newSortType) return; // No change needed

    try {
      if (userId == null || _disposed) return;

      state = state.copyWith(
        sortType: newSortType,
        isLoading: true,
        error: null,
        posts: [], // Clear existing posts
        hasMorePosts: true,
        lastPost: null,
        lastCreatedAt: null,
      );

      // Load feed with new sort type
      final posts = await repository.getFeedFromFunction(
        userId: userId!,
        feedType: 'alt',
        limit: pageSize,
        sortType: newSortType.value,
        hybridLoad: false, // Don't use cache when changing sort type
      );

      if (_disposed) return;

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        lastCreatedAt: posts.isNotEmpty ? posts.last.createdAt : null,
      );

      // Initialize interactions for loaded posts
      await _batchInitializePostInteractions(posts);
    } catch (e) {
      if (_disposed) return;
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
      debugPrint('Error changing sort type in alt feed: $e');
    }
  }

  Future<void> _batchInitializePostInteractions(List<PostModel> posts) async {
    if (posts.isEmpty || userId == null) return;

    debugPrint('Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId!);
    }

    debugPrint('Interactions batch initialization complete');
  }

  void _handlePostUpdates(List<PostModel> updatedPosts) {
    if (!mounted) return;

    // Only update if we have posts and we're not loading
    if (updatedPosts.isEmpty || state.isLoading) return;

    // We need to merge updated posts with existing ones
    // by preserving posts that aren't in the update
    //final existingPostIds = state.posts.map((p) => p.id).toSet();
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
      if (state.isLoading || _disposed) return;

      _safeUpdateState(state.copyWith(isLoading: true, error: null));

      final effectiveUserId = overrideUserId ?? userId ?? '';
      if (effectiveUserId.isEmpty) {
        _safeUpdateState(state.copyWith(
          isLoading: false,
          error: Exception('User ID is required'),
        ));
        return;
      }

      List<PostModel> posts = [];
      try {
        // Try cloud function first
        posts = await repository.getFeedFromFunction(
          userId: effectiveUserId,
          feedType: 'alt',
          limit: pageSize,
          sortType: state.sortType.value,
          hybridLoad: !forceRefresh &&
              state.sortType == FeedSortType.hot, // Only use cache for hot
        );

        debugPrint('Fetched ${posts.length} alt posts from cloud function.');

        // Cache the results (don't await this to avoid delays)
        unawaited(cacheManager.cacheFeed(posts, effectiveUserId, isAlt: true));
      } catch (e) {
        // Fall back to direct Firestore query
        debugPrint('Falling back to direct Firestore query: $e');

        // Get from user feed collection directly
        posts = await repository.getAltFeed(
          userId: effectiveUserId,
          limit: pageSize,
          includeHerdPosts: _showHerdPosts,
        );

        // Cache the results (don't await this)
        unawaited(cacheManager.cacheFeed(posts, effectiveUserId, isAlt: true));
      }

      // Final state update with safety check
      _safeUpdateState(state.copyWith(
        posts: posts,
        isLoading: false,
        isRefreshing: false,
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
        // Build pagination parameters based on sort type
        final Map<String, dynamic> extraParams = {};

        switch (state.sortType) {
          case FeedSortType.latest:
            extraParams['lastCreatedAt'] =
                lastPost.createdAt?.millisecondsSinceEpoch;
            extraParams['lastPostId'] = lastPost.id;
            break;
          case FeedSortType.trending:
          case FeedSortType.hot:
            extraParams['lastHotScore'] = lastPost.hotScore;
            extraParams['lastPostId'] = lastPost.id;
            break;
          case FeedSortType.top:
            // For top, we can use the last post's hot score
            extraParams['lastHotScore'] = lastPost.hotScore;
            extraParams['lastPostId'] = lastPost.id;
            break;
        }

        // Get next batch of posts with proper pagination parameters
        final List<PostModel> morePosts = await repository.getFeedFromFunction(
          userId: userId!,
          feedType: 'alt',
          limit: pageSize,
          sortType: state.sortType.value,
          lastHotScore: _getLastSortValue(),
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

        state = state.copyWith(
          posts: allPosts,
          isLoading: false,
          hasMorePosts: gotFullPage,
          lastPost: uniqueNewPosts.isNotEmpty ? uniqueNewPosts.last : lastPost,
          lastCreatedAt:
              state.sortType == FeedSortType.latest && uniqueNewPosts.isNotEmpty
                  ? uniqueNewPosts.last.createdAt
                  : state.lastCreatedAt,
        );
        await _batchInitializePostInteractions(allPosts);

        debugPrint(
            'AltFeedController: State updated. New state.hasMorePosts = ${state.hasMorePosts}');
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

  /// Get the last sort value based on current sort type
  double? _getLastSortValue() {
    if (state.posts.isEmpty) return null;

    final lastPost = state.posts.last;
    switch (state.sortType) {
      case FeedSortType.latest:
        return lastPost.createdAt?.millisecondsSinceEpoch.toDouble();
      case FeedSortType.top:
        return lastPost.likeCount.toDouble();
      case FeedSortType.trending:
        // For trending, use createdAt since that's the first orderBy field
        return lastPost.createdAt?.millisecondsSinceEpoch.toDouble();
      case FeedSortType.hot:
      default:
        return lastPost.hotScore;
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
