import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';

import '../../../../core/services/cache_manager.dart';
import '../../data/repositories/herd_repository.dart';
import '../providers/state/herd_feed_state.dart';
import 'herd_repository_provider.dart';

/// Controller for herd feed management
class HerdFeedController extends StateNotifier<HerdFeedState> {
  final HerdRepository repository;
  final String herdId;
  final int pageSize;
  bool _disposed = false;
  final Ref ref;

  HerdFeedController(this.repository, this.herdId, this.ref,
      {this.pageSize = 20})
      : super(HerdFeedState.initial());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get _isActive => !_disposed;

  Future<void> loadInitialPosts() async {
    try {
      if (state.isLoading || _disposed) return;

      if (_isActive) state = state.copyWith(isLoading: true, error: null);

      // Use the updated repository method to get joined posts
      final posts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
      );

      if (_isActive) {
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMorePosts: posts.length >= pageSize,
          lastPost: posts.isNotEmpty ? posts.last : null,
        );
      }

      // Initialize interactions for visible posts
      final currentUser = ref.read(authProvider);
      if (currentUser?.uid != null && posts.isNotEmpty) {
        await _batchInitializePostInteractions(currentUser!.uid, posts);
      }
    } catch (e) {
      if (_isActive) {
        state = state.copyWith(
          isLoading: false,
          error: e,
        );
      }
    }
  }

  Future<void> _batchInitializePostInteractions(
      String userId, List<PostModel> posts) async {
    if (posts.isEmpty) return;

    debugPrint('🔄 Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId);
    }

    debugPrint('✅ Interactions batch initialization complete');
  }

  Future<void> loadMorePosts() async {
    try {
      if (state.isLoading || !state.hasMorePosts || state.lastPost == null) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final lastPost = state.lastPost!;

      final morePosts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
        lastHotScore: lastPost.hotScore,
        lastPostId: lastPost.id,
      );

      final currentUser = ref.read(authProvider);
      final userId = currentUser?.uid;

      // Combine with existing posts
      final allPosts = [...state.posts, ...morePosts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMorePosts: morePosts.length >= pageSize,
        lastPost: morePosts.isNotEmpty ? morePosts.last : lastPost,
      );
      if (userId != null) {
        await _batchInitializePostInteractions(userId, allPosts);
      }
    } catch (e) {
      // Keep existing posts but set loading to false
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  Future<void> refreshFeed() async {
    try {
      state = state.copyWith(isRefreshing: true, error: null);

      final posts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
      );

      final currentUser = ref.read(authProvider);
      final userId = currentUser?.uid;

      state = state.copyWith(
        posts: posts,
        isRefreshing: false,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
      );
      if (userId != null) {
        await _batchInitializePostInteractions(userId, posts);
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
    }
  }
}

/// Cache manager provider for herd feed
final herdFeedCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

/// Controller provider for herd feed
final herdFeedControllerProvider =
    StateNotifierProvider.family<HerdFeedController, HerdFeedState, String>(
  (ref, herdId) {
    final repository = ref.watch(herdRepositoryProvider);
    return HerdFeedController(repository, herdId, ref);
  },
);
