import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

import '../data/repositories/feed_repository.dart';

// Repository provider with Firebase Functions
final feedRepositoryProvider = Provider<FeedRepository>((ref) {
  return FeedRepository(
    FirebaseFirestore.instance,
    FirebaseFunctions.instance,
  );
});

// ===== TRENDING POSTS PROVIDERS =====

/// Provider for trending public posts
final trendingPublicPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getTrendingPosts(isAlt: false);
});

/// Provider for highlighted alt posts
final highlightedAltPostsProvider = FutureProvider<List<PostModel>>((ref) {
  final repository = ref.watch(feedRepositoryProvider);
  return repository.getTrendingPosts(isAlt: true, limit: 5);
});
