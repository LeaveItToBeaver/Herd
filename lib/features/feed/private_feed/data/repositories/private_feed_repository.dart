import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/data/repositories/feed_repository.dart';

/// Repository for handling private feed operations
class PrivateFeedRepository extends FeedRepository {
  PrivateFeedRepository(super.firestore);

  CollectionReference<Map<String, dynamic>> get globalPrivatePostsCollection =>
      firestore.collection('globalPrivatePosts');

  /// Get posts for the private feed - shows ALL private posts globally
  ///
  /// [userId] The current user's ID
  /// [limit] Maximum number of posts to fetch (default: 15)
  /// [lastPost] Optional last post for pagination
  /// [decayFactor] Optional factor to adjust algorithm decay rate (default: 1.0)
// In PrivateFeedRepository
  Future<List<PostModel>> getPrivateFeed({
    required String userId,  // This parameter isn't needed if showing all posts globally
    int limit = 15,
    PostModel? lastPost,
    double decayFactor = 1.0,
  }) async {
    try {
      print("DEBUG: Attempting to query globalPrivatePosts collection");

      // Query the globalPrivatePosts collection directly
      var postsQuery = globalPrivatePostsCollection
          .orderBy('createdAt', descending: true)
          .limit(limit);

      print("DEBUG: Query created: $postsQuery");

      // Add pagination if lastPost is provided
      if (lastPost != null && lastPost.createdAt != null) {
        postsQuery = postsQuery.startAfter([lastPost.createdAt]);
      }

      var postsSnapshot = await postsQuery.get();

      // Convert to PostModel objects
      List<PostModel> privatePosts = postsSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Apply hot sorting algorithm
      final sortedPosts = applySortingAlgorithm(privatePosts, decayFactor: decayFactor);

      return sortedPosts;
    } catch (e, stackTrace) {
      logError('getPrivateFeed', e, stackTrace);
      rethrow;
    }
  }

// Similarly for streamPrivateFeed
  Stream<List<PostModel>> streamPrivateFeed({
    int limit = 15,
    double decayFactor = 1.0,
  }) {
    try {
      // Stream all private posts from the main posts collection
      return globalPrivatePostsCollection
          //.where('isPrivate', isEqualTo: true)
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
      logError('streamPrivateFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Get additional posts for pagination
  ///
  /// [lastPost] The last post currently displayed
  /// [limit] Number of additional posts to fetch
  Future<List<PostModel>> getMorePrivatePosts({
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
      var postsSnapshot = await globalPrivatePostsCollection
          //.where('isPrivate', isEqualTo: true)
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
      logError('getMorePrivatePosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get highlighted private posts with high engagement
  /// This is useful for featuring posts at the top of the feed
  Future<List<PostModel>> getHighlightedPrivatePosts({
    int limit = 5,
  }) async {
    try {
      // Get recent private posts (from last 3 days) with high engagement
      final DateTime threeDaysAgo = DateTime.now().subtract(const Duration(days: 3));
      final threeDaysAgoTimestamp = Timestamp.fromDate(threeDaysAgo);

      var postsSnapshot = await globalPrivatePostsCollection
          //.where('isPrivate', isEqualTo: true)
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
      logError('getHighlightedPrivatePosts', e, stackTrace);
      rethrow;
    }
  }
}