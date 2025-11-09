import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/content/post/view/providers/post_provider.dart';
import 'package:herdapp/features/social/feed/data/models/feed_sort_type.dart';
import 'package:herdapp/features/social/feed/data/repositories/feed_repository.dart';
import 'package:herdapp/features/social/feed/public_feed/view/providers/state/public_feed_state.dart';

/// Controller for public feed with pagination
class PublicFeedController extends StateNotifier<PublicFeedState> {
  final FeedRepository repository;
  final CacheManager cacheManager;
  final String userId;
  final int pageSize;
  final Ref ref; // Add this
  bool _disposed = false;
  StreamSubscription? _postUpdateSubscription;

  PublicFeedController(
      this.repository, this.userId, this.cacheManager, this.ref,
      {this.pageSize = 20})
      : super(PublicFeedState.initial());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Check if controller is still active
  bool get _isActive => !_disposed;

  void _safeUpdateState(PublicFeedState newState) {
    if (_isActive) {
      state = newState;
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

// In both AltFeedController and PublicFeedController:
  Future<void> _batchInitializePostInteractions(List<PostModel> posts) async {
    if (posts.isEmpty) return;

    debugPrint('Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId);
    }

    debugPrint('Interactions batch initialization complete');
  }

  /// Load initial public feed posts
  Future<void> loadInitialPosts(
      {String? overrideUserId, bool forceRefresh = false}) async {
    try {
      // Don't reload if already loading
      if (state.isLoading || _disposed) return;

      _safeUpdateState(state.copyWith(isLoading: true, error: null));

      final effectiveUserId = overrideUserId ?? userId;
      if (effectiveUserId.isEmpty) {
        _safeUpdateState(state.copyWith(
          isLoading: false,
          error: Exception('User ID is required'),
        ));
        return;
      }

      List<PostModel> posts = [];
      try {
        // Get posts from repository
        posts = await repository.getPublicFeed(
          userId: effectiveUserId,
          limit: pageSize,
        );

        debugPrint('Fetched ${posts.length} posts from Firestore.');

        // Cache the results (don't await this to avoid delays)
        unawaited(cacheManager.cacheFeed(posts, effectiveUserId, isAlt: false));
        unawaited(cacheManager.getCacheStats());
      } catch (e) {
        // Fall back to direct Firestore query
        if (kDebugMode) {
          debugPrint('Falling back to direct Firestore query: $e');
        }

        // Get from user feed collection directly
        posts = await repository.getPublicFeed(
          userId: effectiveUserId,
          limit: pageSize,
        );

        // Cache the results (don't await this)
        unawaited(cacheManager.cacheFeed(posts, effectiveUserId, isAlt: false));
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
          lastHotScore: _getLastSortValue(),
          lastPostId: lastPost.id,
          sortType: state.sortType.value, // Use current sort type
        );

        if (morePosts.isEmpty) {
          state = state.copyWith(
            isLoading: false,
            hasMorePosts: false,
          );
          return;
        }

        // Merge the new posts with existing ones, filtering duplicates
        final existingIds = state.posts.map((p) => p.id).toSet();
        final newPosts =
            morePosts.where((p) => !existingIds.contains(p.id)).toList();
        final allPosts = [...state.posts, ...newPosts];

        _safeUpdateState(state.copyWith(
          posts: allPosts,
          isLoading: false,
          hasMorePosts: newPosts.length >= pageSize, // Use newPosts length
          lastPost: newPosts.isNotEmpty ? newPosts.last : lastPost,
        ));
        await _batchInitializePostInteractions(allPosts);

        return;
      } catch (e) {
        // Fall back to direct Firestore query
        debugPrint('Falling back to direct Firestore query: $e');
      }

      final morePosts = await repository.getPublicFeed(
        userId: userId,
        limit: pageSize,
        lastHotScore: _getLastSortValue(),
        lastPostId: lastPost.id,
        sortType: state.sortType.value,
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

      _safeUpdateState(state.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMorePosts: morePosts.length >= pageSize,
        lastPost: morePosts.isNotEmpty ? morePosts.last : lastPost,
      ));
      await _batchInitializePostInteractions(allPosts);
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
      if (_disposed) return;

      _safeUpdateState(state.copyWith(isRefreshing: true, error: null));

      // Try cloud function first
      try {
        final posts = await repository.getFeedFromFunction(
          userId: userId,
          feedType: 'public',
          limit: pageSize,
          sortType: state.sortType.value, // Use current sort type
        );

        if (!_isActive) return; // Check if still active

        _safeUpdateState(state.copyWith(
          posts: posts,
          isRefreshing: false,
          isLoading: false,
          hasMorePosts: posts.length >= pageSize,
          lastPost: posts.isNotEmpty ? posts.last : null,
        ));
        await _batchInitializePostInteractions(posts);
        return;
      } catch (e) {
        // Fall back to direct Firestore query
        debugPrint('Falling back to direct Firestore query: $e');
      }

      if (!_isActive) return; // Check again

      final posts = await repository.getPublicFeed(
        userId: userId,
        limit: pageSize,
      );

      if (!_isActive) return; // Check again after await

      _safeUpdateState(state.copyWith(
        posts: posts,
        isRefreshing: false,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
      ));
    } catch (e) {
      if (_isActive) {
        _safeUpdateState(state.copyWith(
          isRefreshing: false,
          isLoading: false,
          error: e,
        ));
      }
    }
  }

  /// Change sort type and reload feed
  Future<void> changeSortType(FeedSortType newSortType) async {
    if (state.sortType == newSortType) return; // No change needed

    try {
      if (_disposed) return;

      _safeUpdateState(state.copyWith(
        sortType: newSortType,
        isLoading: true,
        error: null,
        posts: [], // Clear existing posts
        hasMorePosts: true,
        lastPost: null,
        lastCreatedAt: null,
      ));

      // Load feed with new sort type
      final posts = await repository.getFeedFromFunction(
        userId: userId,
        feedType: 'public',
        limit: pageSize,
        sortType: newSortType.value,
        hybridLoad: false, // Don't use cache when changing sort type
      );

      if (!_isActive) return;

      _safeUpdateState(state.copyWith(
        posts: posts,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        lastCreatedAt: posts.isNotEmpty ? posts.last.createdAt : null,
      ));

      // Initialize interactions for loaded posts
      await _batchInitializePostInteractions(posts);
    } catch (e) {
      if (!_isActive) return;
      _safeUpdateState(state.copyWith(
        isLoading: false,
        error: e,
      ));
      debugPrint('Error changing sort type: $e');
    }
  }

  /// Handle post like
  Future<void> likePost(String postId) async {
    try {
      if (_disposed) return;

      await repository.interactWithPost(postId, 'like');

      if (!_isActive) return; // Check if still active after await

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

      _safeUpdateState(state.copyWith(posts: updatedPosts));
    } catch (e) {
      // Refresh on error to ensure UI is in sync
      if (_isActive) {
        refreshFeed();
      }
    }
  }

  /// Handle post dislike
  Future<void> dislikePost(String postId) async {
    try {
      if (_disposed) return;

      await repository.interactWithPost(postId, 'dislike');

      if (!_isActive) return; // Check if still active after await

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

      _safeUpdateState(state.copyWith(posts: updatedPosts));
    } catch (e) {
      // Refresh on error to ensure UI is in sync
      if (_isActive) {
        refreshFeed();
      }
    }
  }
}
