import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/social/feed/alt_feed/controllers/alt_feed_controller.dart';

part 'alt_feed_provider.g.dart';

// Repository provider with Firebase Functions
@riverpod
FeedRepository altFeedRepository(Ref ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@riverpod
CacheManager altFeedCacheManager(Ref ref) {
  return CacheManager();
}

/// Provider for the alt feed controller
@riverpod
AltFeedController altFeedController(Ref ref) {
  final repository = ref.watch(altFeedRepositoryProvider);
  final user = ref.watch(authProvider);

  return AltFeedController(
    repository,
    user?.uid,
    ref.watch(altFeedCacheManagerProvider),
    ref,
  );
}
