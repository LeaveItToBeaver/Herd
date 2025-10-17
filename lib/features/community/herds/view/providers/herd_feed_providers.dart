import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/content/post/view/providers/post_provider.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';

import '../../../../../core/services/cache_manager.dart';
import 'state/herd_feed_state.dart';
import 'herd_repository_provider.dart';

part 'herd_feed_providers.g.dart';

/// Cache manager provider for herd feed
@riverpod
CacheManager herdFeedCacheManager(Ref ref) {
  return CacheManager();
}

/// Notifier for herd feed management
@riverpod
class HerdFeed extends _$HerdFeed {
  late String herdId;
  int get pageSize => 20;

  @override
  HerdFeedState build(String arg) {
    herdId = arg;
    return HerdFeedState.initial();
  }

  Future<void> loadInitialPosts() async {
    try {
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      final repository = ref.read(herdRepositoryProvider);
      final posts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
      );

      if (!ref.mounted) return;

      state = state.copyWith(
        posts: posts,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
      );

      // Initialize interactions for visible posts
      final currentUser = ref.read(authProvider);
      if (currentUser?.uid != null && posts.isNotEmpty) {
        await _batchInitializePostInteractions(currentUser!.uid, posts);
      }
    } catch (e) {
      if (!ref.mounted) return;
      
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  Future<void> _batchInitializePostInteractions(
      String userId, List<PostModel> posts) async {
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

  Future<void> loadMorePosts() async {
    try {
      if (state.isLoading || !state.hasMorePosts || state.lastPost == null) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final lastPost = state.lastPost!;
      final repository = ref.read(herdRepositoryProvider);

      final morePosts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
        lastHotScore: lastPost.hotScore,
        lastPostId: lastPost.id,
      );

      if (!ref.mounted) return;

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
      if (!ref.mounted) return;
      
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

      final repository = ref.read(herdRepositoryProvider);
      final posts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
      );

      if (!ref.mounted) return;

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
      if (!ref.mounted) return;
      
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
    }
  }
}
