import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/social/feed/public_feed/controllers/public_feed_controller.dart';
import 'package:herdapp/features/social/feed/public_feed/view/providers/state/public_feed_state.dart';
import 'package:herdapp/features/social/feed/data/models/feed_sort_type.dart';

part 'public_feed_provider.g.dart';

// Repository provider with Firebase Functions
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@Riverpod(keepAlive: true)
CacheManager publicFeedCacheManager(Ref ref) {
  return CacheManager();
}

/// Riverpod-native public feed state + actions.
/// Uses keepAlive: true to persist state across navigation.
@Riverpod(keepAlive: true)
class PublicFeedStateNotifier extends _$PublicFeedStateNotifier {
  late final PublicFeedController _controller;

  /// Default staleness threshold (1 hour)
  static const Duration _stalenessThreshold = Duration(hours: 1);

  @override
  PublicFeedState build() {
    final user = ref.watch(authProvider);
    final repository = ref.watch(feedRepositoryProvider);
    final cacheManager = ref.watch(publicFeedCacheManagerProvider);

    _controller = PublicFeedController(
      repository,
      user?.uid ?? '',
      cacheManager,
      ref,
    );
    ref.onDispose(_controller.dispose);

    return PublicFeedState.initial();
  }

  /// Check if current state has valid cached data
  bool get hasValidCache {
    if (state.posts.isEmpty) return false;
    if (state.lastFetchedAt == null) return false;

    final age = DateTime.now().difference(state.lastFetchedAt!);
    return age < _stalenessThreshold;
  }

  Future<void> loadInitialPosts({
    String? overrideUserId,
    bool forceRefresh = false,
  }) async {
    // Skip load if we have valid cached data and not forcing refresh
    if (!forceRefresh && hasValidCache) {
      debugPrint(
          'PublicFeed: Using cached data (age: ${DateTime.now().difference(state.lastFetchedAt!).inMinutes}m)');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);
    await _controller.loadInitialPosts(
        overrideUserId: overrideUserId, forceRefresh: forceRefresh);

    // Update lastFetchedAt after successful load
    state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
  }

  Future<void> loadMorePosts() async {
    // Preserve current posts; controller contains pagination values.
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
}
