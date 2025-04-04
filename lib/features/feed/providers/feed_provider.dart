import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/public_feed/data/repositories/public_feed_repository.dart';
import 'package:herdapp/features/feed/alt_feed/data/repositories/alt_feed_repository.dart';

import '../alt_feed/view/providers/state/alt_feed_state.dart';
import '../public_feed/view/providers/state/public_feed_state.dart';

// Repository providers
final publicFeedRepositoryProvider = Provider<PublicFeedRepository>((ref) {
  return PublicFeedRepository(FirebaseFirestore.instance);
});

final altFeedRepositoryProvider = Provider<AltFeedRepository>((ref) {
  return AltFeedRepository(FirebaseFirestore.instance);
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

// ===== Alt FEED PROVIDERS =====

/// Controller for alt feed with pagination using Freezed state
class AltFeedController extends StateNotifier<AltFeedState> {
  final AltFeedRepository repository;
  final int pageSize;
  bool _showHerdPosts = true;
  bool get showHerdPosts => _showHerdPosts;

  AltFeedController(this.repository, {this.pageSize = 15})
      : super(AltFeedState.initial());

  void toggleHerdPostsFilter(bool show) {
    _showHerdPosts = show;
    refreshFeed();
  }

// In AltFeedController class
  Future<void> loadInitialPosts({String? userId}) async {
    try {
      // Don't reload if already loading
      if (state.isLoading) return;

      state = state.copyWith(isLoading: true, error: null);

      final posts = await repository.getAltFeed(
        userId: userId ?? '', // Use provided userId or empty string as fallback
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
      if (state.isLoading || !state.hasMorePosts || state.posts.isEmpty) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      // Get the last post for pagination
      final lastPost = state.lastPost ?? state.posts.last;

      final morePosts = await repository.getMoreAltPosts(
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

      final posts = await repository.getAltFeed(
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

/// Provider for the alt feed controller
final altFeedControllerProvider = StateNotifierProvider<AltFeedController, AltFeedState>((ref) {
  final repository = ref.watch(altFeedRepositoryProvider);

  return AltFeedController(repository);
});

/// Provider for highlighted alt posts
final highlightedAltPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(altFeedRepositoryProvider);
  return repository.getHighlightedAltPosts();
});