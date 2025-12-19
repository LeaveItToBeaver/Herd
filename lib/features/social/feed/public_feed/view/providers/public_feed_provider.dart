import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/social/feed/public_feed/controllers/public_feed_controller.dart';

part 'public_feed_provider.g.dart';

// Repository provider with Firebase Functions
@riverpod
FeedRepository feedRepository(Ref ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
}

@riverpod
CacheManager publicFeedCacheManager(Ref ref) {
  return CacheManager();
}

/// Provider for the public feed controller
@Riverpod(keepAlive: true)
PublicFeedController publicFeedController(Ref ref) {
  final repository = ref.watch(feedRepositoryProvider);
  final user = ref.watch(authProvider);

  final controller = PublicFeedController(
    repository,
    user!.uid,
    ref.watch(publicFeedCacheManagerProvider),
    ref,
  );

  // Properly dispose the controller when provider disposes
  ref.onDispose(() {
    controller.dispose();
  });

  return controller;
}
