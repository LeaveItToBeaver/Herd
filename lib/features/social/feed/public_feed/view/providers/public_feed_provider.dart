import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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
@riverpod
class PublicFeedStateNotifier extends _$PublicFeedStateNotifier {
  late final PublicFeedController _controller;

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

  Future<void> loadInitialPosts(
      {String? overrideUserId, bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    await _controller.loadInitialPosts(
        overrideUserId: overrideUserId, forceRefresh: forceRefresh);
    state = _controller.state;
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
    state = _controller.state;
  }

  Future<void> changeSortType(FeedSortType newSortType) async {
    state = state.copyWith(
        sortType: newSortType, isLoading: true, error: null, posts: []);
    await _controller.changeSortType(newSortType);
    state = _controller.state;
  }
}
