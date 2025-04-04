import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/data/repositories/feed_repository.dart';

/// Repository for handling alt feed operations
class AltFeedRepository extends FeedRepository {
  AltFeedRepository(super.firestore);

  CollectionReference<Map<String, dynamic>> get globalAltPostsCollection =>
      firestore.collection('globalAltPosts');


  Future<List<PostModel>> getFollowedHerdsPosts({
    required String userId,
    int limit = 10,
    PostModel? lastPost,
  }) async {
    try {
      // Get user's followed herds
      final followedHerds = await firestore
          .collection('userHerds')
          .doc(userId)
          .collection('following')
          .get();

      if (followedHerds.docs.isEmpty) {
        return [];
      }

      final herdIds = followedHerds.docs.map((doc) => doc.id).toList();

      // Create a list to hold futures for parallel execution
      List<Future<QuerySnapshot>> queryFutures = [];

      // Split into batches (Firestore whereIn limit is 10)
      for (int i = 0; i < herdIds.length; i += 10) {
        final batchIds = herdIds.sublist(
            i, i + 10 > herdIds.length ? herdIds.length : i + 10);

        var query = firestore.collection('posts')
            .where('herdId', whereIn: batchIds)
            .where('isAlt', isEqualTo: true)
            .orderBy('hotScore', descending: true)
            .limit(limit);

        if (lastPost != null && lastPost.hotScore != null) {
          query = query.startAfter([lastPost.hotScore]);
        }

        // Add the query to our futures list instead of awaiting it
        queryFutures.add(query.get());
      }

      // Execute all queries in parallel
      final snapshots = await Future.wait(queryFutures);

      // Combine and process results
      List<PostModel> allHerdPosts = [];
      for (var snapshot in snapshots) {
        allHerdPosts.addAll(snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)));
      }

      // Sort the combined results
      allHerdPosts.sort((a, b) =>
          (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

      // Apply limit to final results
      if (allHerdPosts.length > limit) {
        allHerdPosts = allHerdPosts.sublist(0, limit);
      }

      return allHerdPosts;
    } catch (e, stackTrace) {
      logError('getFollowedHerdsPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get posts for the alt feed - shows ALL alt posts globally
  ///
  /// [userId] The current user's ID
  /// [limit] Maximum number of posts to fetch (default: 15)
  /// [lastPost] Optional last post for pagination
  /// [decayFactor] Optional factor to adjust algorithm decay rate (default: 1.0)
  // In AltFeedRepository
  Future<List<PostModel>> getAltFeed({
    required String userId,
    int limit = 15,
    PostModel? lastPost,
    bool includeHerdPosts = true,
  }) async {
    try {
      // First, get normal alt posts
      var postsQuery = globalAltPostsCollection
          .where('herdId', isNull: true)
          .orderBy('hotScore', descending: true) // Sort by hot score
          .limit(limit);

      if (lastPost != null && lastPost.hotScore != null) {
        postsQuery = postsQuery.startAfter([lastPost.hotScore]);
      }

      var postsSnapshot = await postsQuery.get();
      
      List<PostModel> altPosts = postsSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // If we want to include herd posts, fetch those too
      if (includeHerdPosts) {
        final herdPosts = await getFollowedHerdsPosts(
          userId: userId,
          limit: limit,
          lastPost: lastPost,
        );
        altPosts.addAll(herdPosts);

        // Since we're getting from two collections, we need to sort
        // after combining (normally wouldn't need this when using one collection)
        altPosts.sort((a, b) =>
            (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

        // Limit to original requested amount
        if (altPosts.length > limit) {
          altPosts = altPosts.sublist(0, limit);
        }
      }

      return altPosts;
    } catch (e, stackTrace) {
      logError('getAltFeed', e, stackTrace);
      rethrow;
    }
  }

// Similarly for streamAltFeed
  Stream<List<PostModel>> streamAltFeed({
    int limit = 15,
    double decayFactor = 1.0,
  }) {
    try {
      // Stream all alt posts from the main posts collection
      return globalAltPostsCollection
          //.where('isAlt', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        List<PostModel> altPosts = snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();

        // Apply hot algorithm sorting
        final sortedPosts = applySortingAlgorithm(altPosts, decayFactor: decayFactor);
        return sortedPosts;
      });
    } catch (e, stackTrace) {
      logError('streamAltFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Get additional posts for pagination
  ///
  /// [lastPost] The last post currently displayed
  /// [limit] Number of additional posts to fetch
  Future<List<PostModel>> getMoreAltPosts({
    required PostModel lastPost,
    int limit = 15,
    double decayFactor = 1.0,
  }) async {
    try {
      // Ensure we have a createdAt value for pagination
      if (lastPost.createdAt == null) {
        return [];
      }

      // Query for more posts after the last one
      var postsSnapshot = await globalAltPostsCollection
          //.where('isAlt', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .startAfter([lastPost.createdAt])
          .limit(limit)
          .get();

      // Convert to PostModel objects
      List<PostModel> morePosts = postsSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Apply hot sorting algorithm
      final sortedPosts = applySortingAlgorithm(morePosts, decayFactor: decayFactor);

      return sortedPosts;
    } catch (e, stackTrace) {
      logError('getMoreAltPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get highlighted alt posts with high engagement
  /// This is useful for featuring posts at the top of the feed
  Future<List<PostModel>> getHighlightedAltPosts({
    int limit = 5,
  }) async {
    try {
      // Get recent alt posts (from last 3 days) with high engagement
      final DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoTimestamp = Timestamp.fromDate(threeDaysAgo);

      var postsSnapshot = await globalAltPostsCollection
          //.where('isAlt', isEqualTo: true)
          .where('createdAt', isGreaterThan: threeDaysAgoTimestamp)
          .orderBy('createdAt', descending: true)
          .limit(limit * 3) // Get more to allow for sorting by engagement
          .get();

      List<PostModel> recentPosts = postsSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Sort by engagement (using a more aggressive decay factor to emphasize activity)
      final highlightedPosts = applySortingAlgorithm(recentPosts, decayFactor: 0.5);

      return highlightedPosts.take(limit).toList();
    } catch (e, stackTrace) {
      logError('getHighlightedAltPosts', e, stackTrace);
      rethrow;
    }
  }
}