import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/social/feed/alt_feed/controllers/alt_feed_controller.dart';
import 'package:herdapp/features/social/feed/alt_feed/view/providers/state/alt_feed_states.dart';
import 'package:herdapp/features/social/feed/data/models/feed_sort_type.dart';

part 'alt_feed_provider.g.dart';

// Repository provider with Firebase Functions
@Riverpod(keepAlive: true)
FeedRepository altFeedRepository(Ref ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@Riverpod(keepAlive: true)
CacheManager altFeedCacheManager(Ref ref) {
  return CacheManager();
}

/// Riverpod-native alt feed state + actions.
/// Uses keepAlive: true to persist state across navigation.
@Riverpod(keepAlive: true)
class AltFeedStateNotifier extends _$AltFeedStateNotifier {
  late final AltFeedController _controller;

  /// Default staleness threshold (1 hour)
  static const Duration _stalenessThreshold = Duration(hours: 1);

  @override
  AltFeedState build() {
    final user = ref.watch(authProvider);
    final repository = ref.watch(altFeedRepositoryProvider);
    final cacheManager = ref.watch(altFeedCacheManagerProvider);

    _controller = AltFeedController(
      repository,
      user?.uid,
      cacheManager,
      ref,
    );
    ref.onDispose(_controller.dispose);

    return AltFeedState.initial();
  }

  /// Check if current state has valid cached data
  bool get hasValidCache {
    if (state.posts.isEmpty) return false;
    if (state.lastFetchedAt == null) return false;

    final age = DateTime.now().difference(state.lastFetchedAt!);
    return age < _stalenessThreshold;
  }

  bool get showHerdPosts => _controller.showHerdPosts;

  Future<void> loadInitialPosts({
    String? overrideUserId,
    bool forceRefresh = false,
  }) async {
    // Skip load if we have valid cached data and not forcing refresh
    if (!forceRefresh && hasValidCache) {
      debugPrint(
          'AltFeed: Using cached data (age: ${DateTime.now().difference(state.lastFetchedAt!).inMinutes}m)');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    await _controller.loadInitialPosts(
        overrideUserId: overrideUserId, forceRefresh: forceRefresh);

    // Update lastFetchedAt after successful load
    state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
  }

  Future<void> loadMorePosts() async {
    state = state.copyWith(isLoading: true, error: null);
    await _controller.loadMorePosts();
    state = _controller.state;
  }

  Future<void> refreshFeed() async {
    state = state.copyWith(isRefreshing: true, error: null);
    await _controller.refreshFeed();
    // Update lastFetchedAt after refresh
    state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
  }

  Future<void> changeSortType(FeedSortType newSortType) async {
    state = state.copyWith(
        sortType: newSortType, isLoading: true, error: null, posts: []);
    await _controller.changeSortType(newSortType);
    // Update lastFetchedAt after sort change
    state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
  }

  void toggleHerdPostsFilter(bool show) {
    _controller.toggleHerdPostsFilter(show);
    // Controller will refresh internally; reflect whatever it has right now.
    state = _controller.state;
  }
}
