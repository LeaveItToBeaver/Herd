import 'dart:async' show StreamSubscription, unawaited;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/social/feed/data/models/feed_sort_type.dart';
import 'package:herdapp/features/social/feed/public_feed/controllers/public_feed_controller.dart';

// Repository provider with Firebase Functions
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
});

final publicFeedCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

/// Provider for the public feed controller
final publicFeedControllerProvider =
    StateNotifierProvider<PublicFeedController, PublicFeedState>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  final user = ref.watch(authProvider);

  return PublicFeedController(
      repository, user!.uid, ref.watch(publicFeedCacheManagerProvider), ref);
});
