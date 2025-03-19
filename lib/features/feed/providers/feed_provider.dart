import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/public_feed/data/repositories/public_feed_repository.dart';
import 'package:herdapp/features/feed/private_feed/data/repositories/private_feed_repository.dart';

import '../private_feed/view/providers/state/private_feed_state.dart';
import '../public_feed/view/providers/state/public_feed_state.dart';

// Repository providers
final publicFeedRepositoryProvider = Provider<PublicFeedRepository>((ref) {
  return PublicFeedRepository(FirebaseFirestore.instance);
});

final privateFeedRepositoryProvider = Provider<PrivateFeedRepository>((ref) {
  return PrivateFeedRepository(FirebaseFirestore.instance);
});

// Decay factor provider - allows customizing the algorithm weight
final feedAlgorithmDecayFactorProvider = StateProvider<double>((ref) {
  return 1.0; // Default decay factor
});

// ===== PUBLIC FEED PROVIDERS =====

/// Stream provider for public feed posts
final publicFeedProvider = StreamProvider<List<PostModel>>((ref) {
  final user = ref.watch(authProvider);
  final feedRepository = ref.watch(publicFeedRepositoryProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return feedRepository.streamPublicFeed(userId: user.uid);
});

/// Provider for trending public posts
final trendingPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final feedRepository = ref.watch(publicFeedRepositoryProvider);
  return feedRepository.getTrendingPosts();
});

/// Controller for public feed with pagination using Freezed state
class PublicFeedController extends StateNotifier<PublicFeedState> {
  final PublicFeedRepository repository;
  final String userId;
  final int pageSize;

  PublicFeedController(this.repository, this.userId, {this.pageSize = 20})
      : super(PublicFeedState.initial());

  /// Initialize the feed with first batch of posts
  Future<void> loadInitialPosts() async {
    try {
      // Don't reload if already loading
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      final posts = await repository.getPublicFeed(
        userId: userId,
        limit: pageSize,
      );

      print("DEBUG: getPublicFeed returned ${posts.length} posts");


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

      // Get the last post for pagination
      final lastPostId = state.posts.last.id;

      final morePosts = await repository.getPublicFeed(
        userId: userId,
        lastPostId: lastPostId,
        limit: pageSize,
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
        lastPost: morePosts.isNotEmpty ? morePosts.last : state.lastPost,
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
}

/// Provider for the public feed controller
final publicFeedControllerProvider = StateNotifierProvider<PublicFeedController, PublicFeedState>((ref) {
  final repository = ref.watch(publicFeedRepositoryProvider);
  final user = ref.watch(authProvider);

  if (user == null) {
    // Return a dummy controller if user is not logged in
    return PublicFeedController(repository, '');
  }

  return PublicFeedController(repository, user.uid);
});

// ===== PRIVATE FEED PROVIDERS =====

/// Controller for private feed with pagination using Freezed state
class PrivateFeedController extends StateNotifier<PrivateFeedState> {
  final PrivateFeedRepository repository;
  final int pageSize;

  PrivateFeedController(this.repository, {this.pageSize = 15})
      : super(PrivateFeedState.initial());

  /// Initialize the feed with first batch of posts
  Future<void> loadInitialPosts() async {
    try {
      // Don't reload if already loading
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      print("DEBUG: loadInitialPosts called");
      final posts = await repository.getPrivateFeed(
        userId: '',
        limit: pageSize,
      );
      print("DEBUG: getPrivateFeed returned ${posts.length} posts");

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

      // Get the last post for pagination
      final lastPost = state.lastPost ?? state.posts.last;

      final morePosts = await repository.getMorePrivatePosts(
        lastPost: lastPost,
        limit: pageSize,
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
        lastPost: morePosts.isNotEmpty ? morePosts.last : state.lastPost,
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

      final posts = await repository.getPrivateFeed(
        userId: '',  // No need for userId in global feed
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
}

/// Provider for the private feed controller
final privateFeedControllerProvider = StateNotifierProvider<PrivateFeedController, PrivateFeedState>((ref) {
  final repository = ref.watch(privateFeedRepositoryProvider);
  return PrivateFeedController(repository);
});

/// Provider for highlighted private posts
final highlightedPrivatePostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(privateFeedRepositoryProvider);
  return repository.getHighlightedPrivatePosts();
});