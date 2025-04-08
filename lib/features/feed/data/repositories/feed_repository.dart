import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

import '../../../../core/utils/hot_algorithm.dart';

/// Base repository for feed functionality
class FeedRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  /// Constructor that takes a Firestore instance
  FeedRepository(this.firestore, this.functions);

  /// Get a reference to the posts collection (source of truth)
  CollectionReference<Map<String, dynamic>> get posts =>
      firestore.collection('posts');

  /// Get a reference to the user feeds collection
  CollectionReference<Map<String, dynamic>> userFeedCollection(String userId) =>
      firestore.collection('userFeeds').doc(userId).collection('feed');

  /// Calculate the net votes for a post
  int calculateNetVotes(PostModel post) {
    return (post.likeCount ?? 0) - (post.dislikeCount ?? 0);
  }

  /// Get public feed posts (user-specific)
  Future<List<PostModel>> getPublicFeed({
    required String userId,
    int limit = 20,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      // Log before querying
      debugPrint('Fetching public feed for user: $userId with limit: $limit');

      // Query the user's feed collection filtering for public posts
      Query<Map<String, dynamic>> feedQuery = userFeedCollection(userId)
          .where('feedType', isEqualTo: 'public')
          .orderBy('hotScore', descending: true);

      // Apply pagination if lastHotScore is provided
      if (lastHotScore != null) {
        feedQuery = feedQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      feedQuery = feedQuery.limit(limit);

      // Execute query
      final snapshot = await feedQuery.get();

      // Log result count
      debugPrint('Found ${snapshot.docs.length} posts in public feed');

      // Convert to PostModel objects
      List<PostModel> posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      return posts;
    } catch (e, stackTrace) {
      logError('getPublicFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Stream public feed posts
  Stream<List<PostModel>> streamPublicFeed({
    required String userId,
    int limit = 20,
  }) {
    try {
      // Query the user's feed collection filtering for public posts
      Query<Map<String, dynamic>> feedQuery = userFeedCollection(userId)
          .where('feedType', isEqualTo: 'public')
          .orderBy('hotScore', descending: true)
          .limit(limit);

      // Return stream
      return feedQuery.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e, stackTrace) {
      logError('streamPublicFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Get global alt feed posts (visible to everyone)
  Future<List<PostModel>> getGlobalAltFeed({
    int limit = 15,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      // Base query for alt posts from the global collection
      Query<Map<String, dynamic>> feedQuery = firestore
          .collection('altPosts')
          .orderBy('hotScore', descending: true);

      // Apply pagination if lastHotScore is provided
      if (lastHotScore != null) {
        feedQuery = feedQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      feedQuery = feedQuery.limit(limit);

      // Execute query
      final snapshot = await feedQuery.get();

      // Convert to PostModel objects
      List<PostModel> posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      return posts;
    } catch (e, stackTrace) {
      logError('getGlobalAltFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Stream alt feed posts (both global alt posts and herd posts)
  Stream<List<PostModel>> streamAltFeed({
    required String userId,
    int limit = 15,
    bool includeHerdPosts = true,
  }) {
    try {
      if (includeHerdPosts) {
        // Stream both alt and herd posts from user's feed
        Query<Map<String, dynamic>> feedQuery = userFeedCollection(userId)
            .where('feedType', whereIn: ['alt', 'herd'])
            .orderBy('hotScore', descending: true)
            .limit(limit);

        return feedQuery.snapshots().map((snapshot) {
          return snapshot.docs
              .map((doc) => PostModel.fromMap(doc.id, doc.data()))
              .toList();
        });
      } else {
        // Stream only alt posts
        Query<Map<String, dynamic>> feedQuery = userFeedCollection(userId)
            .where('feedType', isEqualTo: 'alt')
            .orderBy('hotScore', descending: true)
            .limit(limit);

        return feedQuery.snapshots().map((snapshot) {
          return snapshot.docs
              .map((doc) => PostModel.fromMap(doc.id, doc.data()))
              .toList();
        });
      }
    } catch (e, stackTrace) {
      logError('streamAltFeed', e, stackTrace);
      rethrow;
    }
  }

  /// Get herd posts
  Future<List<PostModel>> getHerdPosts({
    required String userId,
    required String herdId,
    int limit = 15,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      // Query for specific herd posts
      Query<Map<String, dynamic>> feedQuery = userFeedCollection(userId)
          .where('feedType', isEqualTo: 'herd')
          .where('herdId', isEqualTo: herdId)
          .orderBy('hotScore', descending: true);

      // Apply pagination if lastHotScore is provided
      if (lastHotScore != null) {
        feedQuery = feedQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      feedQuery = feedQuery.limit(limit);

      // Execute query
      final snapshot = await feedQuery.get();

      // Convert to PostModel objects
      List<PostModel> posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      return posts;
    } catch (e, stackTrace) {
      logError('getHerdPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Stream herd posts
  Stream<List<PostModel>> streamHerdPosts({
    required String userId,
    required String herdId,
    int limit = 15,
  }) {
    try {
      // Query for specific herd posts
      Query<Map<String, dynamic>> feedQuery = userFeedCollection(userId)
          .where('feedType', isEqualTo: 'herd')
          .where('herdId', isEqualTo: herdId)
          .orderBy('hotScore', descending: true)
          .limit(limit);

      // Return stream
      return feedQuery.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e, stackTrace) {
      logError('streamHerdPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get trending posts using the cloud function
  Future<List<PostModel>> getTrendingPosts({
    bool isAlt = false,
    int limit = 10,
  }) async {
    try {
      // Using the proper Firebase Functions call pattern
      final HttpsCallableResult result = await functions
          .httpsCallable('getTrendingPosts')
          .call({
        'limit': limit,
        'postType': isAlt ? 'alt' : 'public',
      });

      // Parse the result
      final List<dynamic> postsData = result.data['posts'] ?? [];

      // Convert to PostModel objects
      List<PostModel> posts = postsData
          .map((data) => PostModel.fromMap(data['id'], Map<String, dynamic>.from(data)))
          .toList();

      return posts;
    } catch (e, stackTrace) {
      logError('getTrendingPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get posts for a specific user
  Future<List<PostModel>> getUserPosts({
    required String userId,
    bool? isAlt,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    try {
      // Base query for user's posts
      Query<Map<String, dynamic>> query = posts
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      // Filter by post type if specified
      if (isAlt != null) {
        query = query.where('isAlt', isEqualTo: isAlt);
      }

      // Apply pagination if lastDocument is provided
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      // Apply limit
      query = query.limit(limit);

      // Execute query
      final snapshot = await query.get();

      // Convert to PostModel objects
      List<PostModel> userPosts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      return userPosts;
    } catch (e, stackTrace) {
      logError('getUserPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Stream posts for a specific user
  Stream<List<PostModel>> streamUserPosts({
    required String userId,
    bool? isAlt,
    int limit = 20,
  }) {
    try {
      // Base query for user's posts
      Query<Map<String, dynamic>> query = posts
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      // Filter by post type if specified
      if (isAlt != null) {
        query = query.where('isAlt', isEqualTo: isAlt);
      }

      // Apply limit
      query = query.limit(limit);

      // Return stream
      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e, stackTrace) {
      logError('streamUserPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Create a new post
  Future<String> createPost(PostModel post) async {
    try {
      // Create the post document with auto-generated ID if none provided
      final postRef = post.id.isEmpty
          ? posts.doc()
          : posts.doc(post.id);

      // Set the feed type based on post attributes
      final feedType = post.isAlt ? 'alt' : (post.herdId != null ? 'herd' : 'public');

      // Ensure the post has an ID and feed type
      final postWithId = post.copyWith(
        id: postRef.id,
        feedType: feedType,
      );

      // Save to Firestore
      await postRef.set(postWithId.toMap());

      // Return the post ID
      return postRef.id;
    } catch (e, stackTrace) {
      logError('createPost', e, stackTrace);
      rethrow;
    }
  }

  /// Handle post interaction (like/dislike) using the correct cloud function call pattern
  Future<void> interactWithPost(String postId, String interactionType) async {
    try {
      // Call the cloud function with proper error handling
      try {
        final HttpsCallableResult result = await functions
            .httpsCallable('handlePostInteraction')
            .call({
          'postId': postId,
          'interactionType': interactionType,
        });

        // Handle result if needed
        return result.data;
      } on FirebaseFunctionsException catch (error) {
        // Handle function-specific errors
        logError('interactWithPost FirebaseFunctionsException',
            'Code: ${error.code}, Message: ${error.message}, Details: ${error.details}', null);
        rethrow;
      }
    } catch (e, stackTrace) {
      logError('interactWithPost', e, stackTrace);
      rethrow;
    }
  }

  /// Get feed from the cloud function
  Future<List<PostModel>> getFeedFromFunction({
    required String userId,
    String feedType = 'public',
    String? herdId,
    int limit = 20,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      // Build the parameters for the cloud function
      final Map<String, dynamic> params = {
        'userId': userId,
        'feedType': feedType,
        'limit': limit,
      };

      // Add optional parameters if they're provided
      if (herdId != null) params['herdId'] = herdId;

      // Only add lastHotScore for pagination
      if (lastHotScore != null) params['lastHotScore'] = lastHotScore;

      // For debugging
      debugPrint('getFeedFromFunction params: $params');

      // Call the cloud function
      final result = await functions
          .httpsCallable('getFeed')
          .call(params);

      // Parse the results
      final List<dynamic> postsData = result.data['posts'] ?? [];

      // Convert to PostModel objects
      List<PostModel> posts = postsData
          .map((data) => PostModel.fromMap(data['id'], Map<String, dynamic>.from(data)))
          .toList();

      return posts;
    } catch (e, stackTrace) {
      logError('getFeedFromFunction', e, stackTrace);
      rethrow;
    }
  }

  /// Helper method to log any feed-related errors
  void logError(String operation, Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('Feed Repository Error during $operation: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}