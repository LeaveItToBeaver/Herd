import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/data/repositories/feed_repository.dart';

/// Repository for handling private feed operations
class AltFeedRepository extends FeedRepository {
  AltFeedRepository(super.firestore);

  CollectionReference<Map<String, dynamic>> get globalAltPostsCollection =>
      firestore.collection('globalAltPosts');


  Future<List<PostModel>> getFollowedHerdsPosts({
    required String userId,
    int limit = 10,
    PostModel? lastPost,
    double decayFactor = 1.0,
  }) async {
    try {
      // Get list of herds the user follows
      final followedHerds = await firestore
          .collection('userHerds')
          .doc(userId)
          .collection('following')
          .get();

      if (followedHerds.docs.isEmpty) {
        return [];
      }

      final herdIds = followedHerds.docs.map((doc) => doc.id).toList();

      // Query posts from these herds
      var query = firestore.collection('posts')
          .where('herdId', whereIn: herdIds)
          .where('isAlt', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Add pagination if lastPost is provided
      if (lastPost != null && lastPost.createdAt != null) {
        query = query.startAfter([lastPost.createdAt]);
      }

      final snapshot = await query.get();

      List<PostModel> herdPosts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Apply hot sorting algorithm
      final sortedPosts = applySortingAlgorithm(herdPosts, decayFactor: decayFactor);

      return sortedPosts;
    } catch (e, stackTrace) {
      logError('getFollowedHerdsPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get posts for the private feed - shows ALL private posts globally
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
    double decayFactor = 1.0,
    bool includeHerdPosts = true, // New parameter
  }) async {
    try {
      // First, get normal alt posts
      var postsQuery = globalAltPostsCollection
          .where('herdId', isNull: true) // Only include non-herd posts here
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Add pagination if lastPost is provided
      if (lastPost != null && lastPost.createdAt != null) {
        postsQuery = postsQuery.startAfter([lastPost.createdAt]);
      }

      var postsSnapshot = await postsQuery.get();

      List<PostModel> privatePosts = postsSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // If we want to include herd posts, fetch those too
      if (includeHerdPosts) {
        final herdPosts = await getFollowedHerdsPosts(
          userId: userId,
          limit: limit,
          lastPost: lastPost,
          decayFactor: decayFactor,
        );

        // Combine both types of posts
        privatePosts.addAll(herdPosts);
      }

      // Apply hot sorting algorithm to the combined list
      final sortedPosts = applySortingAlgorithm(privatePosts, decayFactor: decayFactor);

      return sortedPosts;
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
      // Stream all private posts from the main posts collection
      return globalAltPostsCollection
          //.where('isAlt', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        List<PostModel> privatePosts = snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();

        // Apply hot algorithm sorting
        final sortedPosts = applySortingAlgorithm(privatePosts, decayFactor: decayFactor);
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

  /// Get highlighted private posts with high engagement
  /// This is useful for featuring posts at the top of the feed
  Future<List<PostModel>> getHighlightedAltPosts({
    int limit = 5,
  }) async {
    try {
      // Get recent private posts (from last 3 days) with high engagement
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