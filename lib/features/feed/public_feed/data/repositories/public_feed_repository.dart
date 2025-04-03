import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/feed/data/repositories/feed_repository.dart';

/// Repository for handling public feed operations
class PublicFeedRepository extends FeedRepository {
  PublicFeedRepository(FirebaseFirestore firestore) : super(firestore);

  /// Get posts for the public feed
  Future<List<PostModel>> getPublicFeed({
    required String userId,
    int limit = 20,
    String? lastPostId,
    double decayFactor = 1.0,
  }) async {
    try {
      List<PostModel> feedPosts = [];

      // First try to get user's feed if it exists
      var feedQuery = publicFeeds
          .doc(userId)
          .collection('userFeed')
          .orderBy('createdAt', descending: true)
          .limit(limit * 2); // Fetch more to allow for sorting

      // Add pagination if lastPostId is provided
      if (lastPostId != null) {
        // Get the last document for pagination
        DocumentSnapshot lastDocSnapshot = await posts.doc(lastPostId).get();
        if (lastDocSnapshot.exists) {
          feedQuery = feedQuery.startAfterDocument(lastDocSnapshot);
        }
      }

      var userFeedSnapshot = await feedQuery.get();

      // If user feed has posts, use those
      if (userFeedSnapshot.docs.isNotEmpty) {
        feedPosts = userFeedSnapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();
      } else {
        // Otherwise, fetch from general posts collection (only public posts)
        var postsQuery = posts
            .where('isAlt', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .limit(limit * 2); // Fetch more to allow for sorting

        // Add pagination if lastPostId is provided
        if (lastPostId != null) {
          // Get the last document for pagination
          DocumentSnapshot lastDocSnapshot = await posts.doc(lastPostId).get();
          if (lastDocSnapshot.exists) {
            postsQuery = postsQuery.startAfterDocument(lastDocSnapshot);
          }
        }

        var postsSnapshot = await postsQuery.get();

        feedPosts = postsSnapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();
      }

      // Apply hot sorting algorithm
      final sortedPosts = applySortingAlgorithm(feedPosts, decayFactor: decayFactor);

      // Return limited number of posts
      return sortedPosts.take(limit).toList();
    } catch (e, stackTrace) {
      logError('getPublicFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Stream posts for the public feed
  Stream<List<PostModel>> streamPublicFeed({
    required String userId,
    int limit = 20,
    double decayFactor = 1.0,
  }) {
    try {
      // Try to stream from user's feed collection first
      final userFeedStream = publicFeeds
          .doc(userId)
          .collection('userFeed')
          .orderBy('createdAt', descending: true)
          .limit(limit * 2) // Fetch more to allow for sorting
          .snapshots()
          .map((snapshot) {
        List<PostModel> posts = snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();

        // Apply hot algorithm sorting
        final sortedPosts = applySortingAlgorithm(posts, decayFactor: decayFactor);
        return sortedPosts.take(limit).toList();
      });

      // If the user has no feed documents, fall back to querying all public posts
      return userFeedStream.handleError((error) {
        // If there's an error with the user feed, return general public posts
        return posts
            .where('isAlt', isEqualTo: false)
            .orderBy('createdAt', descending: true)
            .limit(limit * 2)
            .snapshots()
            .map((snapshot) {
          List<PostModel> posts = snapshot.docs
              .map((doc) => PostModel.fromMap(doc.id, doc.data()))
              .toList();

          // Apply hot algorithm sorting
          final sortedPosts = applySortingAlgorithm(posts, decayFactor: decayFactor);
          return sortedPosts.take(limit).toList();
        });
      });
    } catch (e, stackTrace) {
      logError('streamPublicFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Get trending posts - posts with high engagement in a short time
  Future<List<PostModel>> getTrendingPosts({
    int limit = 10,
  }) async {
    try {
      // Get posts with high engagement in the last 24 hours
      final DateTime yesterday = DateTime.now().subtract(const Duration(hours: 24));
      final yesterdayTimestamp = Timestamp.fromDate(yesterday);

      var postsSnapshot = await posts
          .where('isAlt', isEqualTo: false)
          .where('createdAt', isGreaterThan: yesterdayTimestamp)
          .orderBy('createdAt', descending: true)
          .limit(limit * 3) // Get more posts to sort
          .get();

      List<PostModel> postsList = postsSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Use a more aggressive decay factor (0.5) to emphasize recent activity
      final trendingPosts = applySortingAlgorithm(postsList, decayFactor: 0.5);

      return trendingPosts.take(limit).toList();
    } catch (e, stackTrace) {
      logError('getTrendingPosts', e, stackTrace);
      rethrow;
    }
  }
}