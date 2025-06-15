import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

/// Base repository for feed functionality
class FeedRepository {
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  Map<String, dynamic>? _lastFunctionResponse;
  bool _isUpdatingFromServer = false;
  final _postUpdateController = StreamController<List<PostModel>>.broadcast();

  Stream<List<PostModel>> get postUpdates => _postUpdateController.stream;

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
    return (post.likeCount) - (post.dislikeCount);
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

      // Try cloud function first
      try {
        final posts = await getFeedFromFunction(
          userId: userId,
          feedType: 'public',
          limit: limit,
          lastHotScore: lastHotScore,
          lastPostId: lastPostId,
        );

        debugPrint('Retrieved ${posts.length} posts from cloud function');
        return posts;
      } catch (e) {
        debugPrint('Cloud function failed, falling back to direct query: $e');
      }

      // Fall back to direct Firestore queries
      // STEP 1: Query the user's feed collection for ordering
      Query<Map<String, dynamic>> feedQuery = firestore
          .collection('userFeeds')
          .doc(userId)
          .collection('feed')
          .where('feedType', isEqualTo: 'public')
          .orderBy('hotScore', descending: true);

      // Apply pagination if lastHotScore is provided
      if (lastHotScore != null) {
        feedQuery = feedQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      feedQuery = feedQuery.limit(limit);

      // Execute query
      final feedSnapshot = await feedQuery.get();

      if (feedSnapshot.docs.isEmpty) {
        debugPrint('No public feed entries found');
        return [];
      }

      // Extract post IDs and hot scores
      final postIds = feedSnapshot.docs.map((doc) => doc.id).toList();
      final hotScoreMap = Map.fromEntries(feedSnapshot.docs
          .map((doc) => MapEntry(doc.id, doc.data()['hotScore'] ?? 0.0)));

      debugPrint('Found ${postIds.length} feed entries, querying source posts');

      // STEP 2: Query source of truth for complete post data
      // Due to Firestore limitations, query in chunks of 10
      final List<PostModel> result = [];

      for (int i = 0; i < postIds.length; i += 10) {
        final chunk = postIds.sublist(
            i, i + 10 > postIds.length ? postIds.length : i + 10);

        // Query the posts collection for complete data
        final postsQuery = firestore
            .collection('posts')
            .where(FieldPath.documentId, whereIn: chunk);

        final postsSnapshot = await postsQuery.get();

        // Create post models with correct hot scores
        for (final doc in postsSnapshot.docs) {
          final data = doc.data();
          // Use hot score from userFeed for correct ordering
          data['hotScore'] = hotScoreMap[doc.id];
          result.add(PostModel.fromMap(doc.id, data));
        }
      }

      // Sort by hot score to maintain original order
      result.sort((a, b) => (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

      debugPrint('Successfully retrieved ${result.length} complete posts');
      return result;
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
      Query<Map<String, dynamic>> feedQuery = firestore
          .collection('userFeeds')
          .doc(userId)
          .collection('feed')
          .where('feedType', isEqualTo: 'public')
          .orderBy('hotScore', descending: true);

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

  /// Get alt feed posts with proper hot score ordering
  Future<List<PostModel>> getAltFeed({
    required String userId,
    int limit = 15,
    double? lastHotScore,
    String? lastPostId,
    bool includeHerdPosts = true,
  }) async {
    try {
      // STEP 1: Query the user's feed collection for ordering
      Query<Map<String, dynamic>> feedQuery;

      if (includeHerdPosts) {
        feedQuery = userFeedCollection(userId).where('feedType',
            whereIn: ['alt', 'herd']).orderBy('hotScore', descending: true);
      } else {
        feedQuery = userFeedCollection(userId)
            .where('feedType', isEqualTo: 'alt')
            .orderBy('hotScore', descending: true);
      }

      // Apply pagination if provided
      if (lastHotScore != null) {
        feedQuery = feedQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      feedQuery = feedQuery.limit(limit);

      // Execute query
      final feedSnapshot = await feedQuery.get();

      if (feedSnapshot.docs.isEmpty) {
        return [];
      }

      // Group entries by feed type to query appropriate collections
      final feedEntries = feedSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'feedType': data['feedType'],
          'herdId': data['herdId'],
          'hotScore': data['hotScore'] ?? 0.0,
        };
      }).toList();

      // Sort to preserve the ordering by hot score
      final results = <PostModel>[];

      // Process entries in batches due to Firestore's 'in' query limitation (max 10)
      // Split entries by feed type
      final altIds = <String>[];
      final herdPostMap = <String, List<String>>{}; // herdId -> [postIds]

      for (final entry in feedEntries) {
        if (entry['feedType'] == 'alt') {
          altIds.add(entry['id'] as String);
        } else if (entry['feedType'] == 'herd' && entry['herdId'] != null) {
          final herdId = entry['herdId'] as String;
          if (!herdPostMap.containsKey(herdId)) {
            herdPostMap[herdId] = [];
          }
          herdPostMap[herdId]!.add(entry['id'] as String);
        }
      }

      // Fetch alt posts in batches of 10
      for (int i = 0; i < altIds.length; i += 10) {
        final end = (i + 10 < altIds.length) ? i + 10 : altIds.length;
        final batch = altIds.sublist(i, end);

        if (batch.isEmpty) continue;

        final query = firestore
            .collection('altPosts')
            .where(FieldPath.documentId, whereIn: batch);

        final snapshot = await query.get();

        for (final doc in snapshot.docs) {
          final index = feedEntries.indexWhere((e) => e['id'] == doc.id);
          if (index >= 0) {
            final data = doc.data();
            // Use hot score from user feed for ordering
            data['hotScore'] = feedEntries[index]['hotScore'];
            results.add(PostModel.fromMap(doc.id, data));
          }
        }
      }

      // Fetch herd posts per herd in batches
      for (final entry in herdPostMap.entries) {
        final herdId = entry.key;
        final postIds = entry.value;

        for (int i = 0; i < postIds.length; i += 10) {
          final end = (i + 10 < postIds.length) ? i + 10 : postIds.length;
          final batch = postIds.sublist(i, end);

          if (batch.isEmpty) continue;

          final query = firestore
              .collection('herdPosts')
              .doc(herdId)
              .collection('posts')
              .where(FieldPath.documentId, whereIn: batch);

          final snapshot = await query.get();

          for (final doc in snapshot.docs) {
            final index = feedEntries.indexWhere((e) => e['id'] == doc.id);
            if (index >= 0) {
              final data = doc.data();
              // Use hot score from user feed for ordering
              data['hotScore'] = feedEntries[index]['hotScore'];
              results.add(PostModel.fromMap(doc.id, data));
            }
          }
        }
      }

      // Sort results by hot score to maintain original order
      results.sort((a, b) => (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

      return results;
    } catch (e, stackTrace) {
      logError('getAltFeed', e, stackTrace);
      rethrow;
    }
  }

  Stream<List<PostModel>> streamAltFeed({
    required String userId,
    int limit = 15,
    bool includeHerdPosts = true,
  }) {
    try {
      Query<Map<String, dynamic>> feedQuery;

      if (includeHerdPosts) {
        feedQuery = userFeedCollection(userId)
            .where('feedType', whereIn: ['alt', 'herd'])
            .orderBy('hotScore', descending: true)
            .limit(limit);
      } else {
        feedQuery = userFeedCollection(userId)
            .where('feedType', isEqualTo: 'alt')
            .orderBy('hotScore', descending: true)
            .limit(limit);
      }

      return feedQuery.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();
      });
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

      // Apply pagination if provided
      if (lastHotScore != null && lastPostId != null) {
        feedQuery = feedQuery.startAfter([lastHotScore, lastPostId]);
      } else if (lastHotScore != null) {
        feedQuery = feedQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      feedQuery = feedQuery.limit(limit);

      // Execute query
      final feedSnapshot = await feedQuery.get();

      if (feedSnapshot.docs.isEmpty) {
        return [];
      }

      // Convert to PostModel objects
      List<PostModel> posts = feedSnapshot.docs
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
      final HttpsCallableResult result =
          await functions.httpsCallable('getTrendingPosts').call({
        'limit': limit,
        'postType': isAlt ? 'alt' : 'public',
      });

      // Parse the result
      final List<dynamic> postsData = result.data['posts'] ?? [];

      // Convert to PostModel objects
      List<PostModel> posts = postsData
          .map((data) =>
              PostModel.fromMap(data['id'], Map<String, dynamic>.from(data)))
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
    PostModel? lastPost, // Add this parameter
  }) async {
    try {
      // Determine which collection to query
      String collectionName = (isAlt == true) ? 'altPosts' : 'posts';

      // Base query for user's posts
      Query<Map<String, dynamic>> query = firestore
          .collection(collectionName)
          .where('authorId', isEqualTo: userId)
          .orderBy('createdAt', descending: true);

      // Apply pagination - use lastPost if provided, otherwise lastDocument
      if (lastPost != null) {
        // Convert PostModel to DocumentSnapshot by fetching the document
        final lastDoc =
            await firestore.collection(collectionName).doc(lastPost.id).get();

        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      } else if (lastDocument != null) {
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
      final postRef = post.id.isEmpty ? posts.doc() : posts.doc(post.id);

      // Set the feed type based on post attributes
      final feedType =
          post.isAlt ? 'alt' : (post.herdId != null ? 'herd' : 'public');

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
        final HttpsCallableResult result =
            await functions.httpsCallable('handlePostInteraction').call({
          'postId': postId,
          'interactionType': interactionType,
        });

        // Handle result if needed
        return result.data;
      } on FirebaseFunctionsException catch (error) {
        // Handle function-specific errors
        logError(
            'interactWithPost FirebaseFunctionsException',
            'Code: ${error.code}, Message: ${error.message}, Details: ${error.details}',
            null);
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
    required String feedType,
    int limit = 15,
    double? lastHotScore,
    String? lastPostId,
    bool hybridLoad = true,
  }) async {
    try {
      _isUpdatingFromServer = true;

      // Build parameters
      final Map<String, dynamic> params = {
        'userId': userId,
        'feedType': feedType,
        'limit': limit,
      };

      if (lastHotScore != null) {
        params['lastHotScore'] = lastHotScore;
        debugPrint('Added lastHotScore to params: $lastHotScore');
      }
      if (lastPostId != null) {
        params['lastPostId'] = lastPostId;
        debugPrint('Added lastPostId to params: $lastPostId');
      }

      // Skip cache for pagination requests
      if (lastHotScore != null || lastPostId != null) {
        hybridLoad = false; // Don't use cache for pagination
      }

      List<PostModel> cachedPosts = [];

      if (hybridLoad) {
        if (feedType == 'alt') {
          cachedPosts = await CacheManager().getFeed(userId, isAlt: true);
          if (cachedPosts.isNotEmpty) {
            debugPrint(
                '🔄 Returning ${cachedPosts.length} cached posts immediately');

            _fetchFromServerAndNotify(params, userId, feedType == 'alt');

            return cachedPosts;
          }
        } else if (feedType == 'public') {
          cachedPosts = await CacheManager().getFeed(userId, isAlt: false);
          if (cachedPosts.isNotEmpty) {
            debugPrint(
                '🔄 Returning ${cachedPosts.length} cached posts immediately');

            _fetchFromServerAndNotify(params, userId, feedType == 'alt');

            return cachedPosts;
          }
        } else if (feedType == 'herd') {
          cachedPosts =
              await CacheManager().getFeed(userId, isAlt: feedType == 'herd');
          if (cachedPosts.isNotEmpty) {
            debugPrint(
                '🔄 Returning ${cachedPosts.length} cached posts immediately');

            _fetchFromServerAndNotify(params, userId, feedType == 'herd');

            return cachedPosts;
          }
        }
      }

      // Call the cloud function
      final result = await functions.httpsCallable('getFeed').call(params);
      _lastFunctionResponse = result.data;
      // *** ADD LOGGING HERE ***
      debugPrint(
          'FeedRepository.getFeedFromFunction: Received response data: $_lastFunctionResponse');

      // Parse the posts from the response
      final List<dynamic> postsData = result.data['posts'] ?? [];

      // Convert to PostModel objects
      final List<PostModel> posts = postsData
          .map((data) =>
              PostModel.fromMap(data['id'], Map<String, dynamic>.from(data)))
          .toList();

      if (posts.isNotEmpty) {
        await CacheManager().cacheFeed(posts, userId, isAlt: feedType == 'alt');
      }

      _isUpdatingFromServer = false;

      return posts;
    } catch (e, stackTrace) {
      logError('getFeedFromFunction', e, stackTrace);
      rethrow;
    }
  }

  Future<void> _fetchFromServerAndNotify(
      Map<String, dynamic> params, String userId, bool isAlt) async {
    try {
      final result = await functions.httpsCallable('getFeed').call(params);
      // ADD THIS LINE to update pagination state after background fetch
      _lastFunctionResponse = result.data;

      // Parse posts and notify listeners
      final List<dynamic> postsData = result.data['posts'] ?? [];
      final List<PostModel> freshPosts = postsData
          .map((data) =>
              PostModel.fromMap(data['id'], Map<String, dynamic>.from(data)))
          .toList();

      if (freshPosts.isNotEmpty) {
        // Update cache with fresh data
        await CacheManager().cacheFeed(freshPosts, userId, isAlt: isAlt);

        // Notify listeners about the updated posts
        _postUpdateController.add(freshPosts);
      }

      _isUpdatingFromServer = false;
    } catch (e) {
      _isUpdatingFromServer = false;
      debugPrint('Background fetch error: $e');
    }
  }

  double? get lastHotScore {
    final value = _lastFunctionResponse?['lastHotScore'];
    if (value == null) return null;
    return (value is int) ? value.toDouble() : value as double;
  }

  String? get lastPostId => _lastFunctionResponse?['lastPostId'];
  bool get hasMorePosts {
    final value = _lastFunctionResponse?['hasMorePosts'] ?? false;
    debugPrint(
        'FeedRepository.hasMorePosts getter: _lastFunctionResponse = $_lastFunctionResponse, returning = $value');
    return value;
  }

  //bool get hasMorePosts => true;
  bool get isUpdatingFromServer => _isUpdatingFromServer;

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
