import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

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
