import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/services/cache_manager.dart';

import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _posts =>
      _firestore.collection('posts');
  CollectionReference<Map<String, dynamic>> get _globalAltPosts =>
      _firestore.collection('altPosts');
  // CollectionReference<Map<String, dynamic>> get _comments =>
  //     _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes =>
      _firestore.collection('likes');
  CollectionReference<Map<String, dynamic>> get _dislikes =>
      _firestore.collection('dislikes');

  /// Get Posts for Feeds ///
  // Get public user feed with pagination
  Future<List<PostModel>> getPostsWithAuthorDetails(
      {bool altOnly = false}) async {
    var query = _posts.orderBy('createdAt', descending: true);

    if (altOnly) {
      query = query.where('isAlt', isEqualTo: true);
    } else {
      query = query.where('isAlt', isEqualTo: false);
    }

    final postsSnap = await query.get();
    final posts = <PostModel>[];

    for (final doc in postsSnap.docs) {
      final post = PostModel.fromMap(doc.id, doc.data());

      // Fetch author details
      final authorDoc =
          await _firestore.collection('users').doc(post.authorId).get();
      final authorData = authorDoc.data();

      if (authorData != null) {
        posts.add(PostModel(
          id: post.id,
          authorId: post.authorId,
          authorUsername: authorData['username'] ?? 'Unknown',
          authorProfileImageURL: post.isAlt
              ? authorData['altProfileImageURL'] ??
                  authorData['profileImageURL']
              : authorData['profileImageURL'],
          title: post.title,
          content: post.content,
          mediaURL: post.mediaURL,
          isAlt: post.isAlt,
          likeCount: post.likeCount,
          dislikeCount: post.dislikeCount,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        ));
      }
    }

    return posts;
  }

  //Get posts within a herd
  Stream<List<PostModel>> getHerdPosts(String herdId) {
    return _posts
        .where('herdId', isEqualTo: herdId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Get post by ID
  Future<PostModel?> getPostById(String postId,
      {bool? isAlt, String? herdId, bool forceRefresh = false}) async {
    try {
      if (!forceRefresh) {
        final cacheManager = CacheManager();
        final cachedPost =
            await cacheManager.getPost(postId, isAlt: isAlt ?? false);
        if (cachedPost != null) {
          return cachedPost;
        }
      }
      // Set the correct fetch option based on forceRefresh
      final fetchOptions = forceRefresh
          ? GetOptions(source: Source.server)
          : GetOptions(source: Source.serverAndCache);

      // If we know it's a herd post and have the herdId, check there first
      if (herdId != null && herdId.isNotEmpty) {
        final doc = await _firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .doc(postId)
            .get(fetchOptions);

        if (doc.exists) {
          return PostModel.fromMap(doc.id, doc.data()!);
        }
      }

      // If we know it's an alt post, check the alt posts collection
      if (isAlt == true) {
        final doc = await _firestore
            .collection('altPosts')
            .doc(postId)
            .get(fetchOptions);

        if (doc.exists) {
          return PostModel.fromMap(doc.id, doc.data()!);
        }
      }

      // If we know it's a public post, check the public posts collection
      if (isAlt == false) {
        final doc =
            await _firestore.collection('posts').doc(postId).get(fetchOptions);

        if (doc.exists) {
          return PostModel.fromMap(doc.id, doc.data()!);
        }
      }

      // If we don't know the post type or haven't found it yet, check all collections
      // Check herd posts first (less common)
      if (herdId != null && herdId.isNotEmpty) {
        final herdDoc = await _firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .doc(postId)
            .get(fetchOptions);

        if (herdDoc.exists) {
          return PostModel.fromMap(herdDoc.id, herdDoc.data()!);
        }
      }

      // Check alt posts collection
      if (isAlt == true) {
        final altDoc = await _firestore
            .collection('altPosts')
            .doc(postId)
            .get(fetchOptions);

        if (altDoc.exists) {
          return PostModel.fromMap(altDoc.id, altDoc.data()!);
        }
      }
      // If we know it's a public post, check the public posts collection
      if (isAlt == false) {
        final doc =
            await _firestore.collection('posts').doc(postId).get(fetchOptions);

        if (doc.exists) {
          return PostModel.fromMap(doc.id, doc.data()!);
        }
      }

      // Check public posts first (most common)
      final publicDoc =
          await _firestore.collection('posts').doc(postId).get(fetchOptions);

      if (publicDoc.exists) {
        return PostModel.fromMap(publicDoc.id, publicDoc.data()!);
      }

      // Check alt posts collection
      final altDoc =
          await _firestore.collection('altPosts').doc(postId).get(fetchOptions);

      if (altDoc.exists) {
        return PostModel.fromMap(altDoc.id, altDoc.data()!);
      }

      // As a last resort, check for herd posts using a collection group query
      final herdPostQuery = await _firestore
          .collectionGroup('posts')
          .where('id', isEqualTo: postId)
          .limit(1)
          .get(fetchOptions);

      if (herdPostQuery.docs.isNotEmpty) {
        return PostModel.fromMap(postId, herdPostQuery.docs.first.data());
      }

      // Post not found in any collection
      return null;
    } catch (e) {
      debugPrint('Error fetching post $postId: $e');
      rethrow;
    }
  }

  // Stream specific post
  Stream<PostModel?> streamPost(String postId, {bool? isAlt}) {
    try {
      // If we know it's alt, stream only from alt collection
      if (isAlt == true) {
        return _globalAltPosts.doc(postId).snapshots().map((doc) {
          return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
        });
      }

      // If we know it's public, stream only from public collection
      if (isAlt == false) {
        return _posts.doc(postId).snapshots().map((doc) {
          return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
        });
      }

      // If we don't know for sure, create a custom merged stream
      // using a StreamController
      final controller = StreamController<PostModel?>();

      // Subscribe to public posts stream
      late StreamSubscription publicSub;
      late StreamSubscription altSub;
      bool hasData = false;

      publicSub = _posts.doc(postId).snapshots().map((doc) {
        return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
      }).listen((post) {
        if (post != null) {
          hasData = true;
          controller.add(post);
        } else if (!hasData) {
          // Only add null if we haven't found data in either stream
          controller.add(null);
        }
      });

      // Subscribe to alt posts stream
      altSub = _globalAltPosts.doc(postId).snapshots().map((doc) {
        return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
      }).listen((post) {
        if (post != null) {
          hasData = true;
          controller.add(post);
        } else if (!hasData) {
          // Only add null if we haven't found data in either stream
          controller.add(null);
        }
      });

      // Clean up subscriptions when the stream is closed
      controller.onCancel = () {
        publicSub.cancel();
        altSub.cancel();
      };

      return controller.stream;
    } catch (e) {
      debugPrint('Error streaming post $postId: $e');
      rethrow;
    }
  }

  Future<void> updatePost({
    required String postId,
    required String userId,
    String? title,
    String? content,
    bool? isAlt,
    String? herdId,
    bool? isNSFW,
  }) async {
    try {
      // Determine which collection to update based on post type
      DocumentReference postRef;

      if (isAlt == true) {
        postRef = _firestore.collection('altPosts').doc(postId);
      } else if (herdId != null && herdId.isNotEmpty) {
        postRef = _firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .doc(postId);
      } else {
        postRef = _firestore.collection('posts').doc(postId);
      }

      // Get post data before update
      final postDoc = await postRef.get();
      if (!postDoc.exists) {
        throw Exception("Post not found");
      }

      final postData = postDoc.data() as Map<String, dynamic>;

      // Security check: Only allow the author to edit their own post
      if (postData['authorId'] != userId) {
        throw Exception("You don't have permission to edit this post");
      }

      // Create a map of fields to update
      final Map<String, dynamic> updates = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (title != null) updates['title'] = title;
      if (content != null) updates['content'] = content;
      if (isNSFW != null) updates['isNSFW'] = isNSFW;

      // Update the post
      await postRef.update(updates);

      debugPrint('Post $postId successfully updated');
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }

  /// Post Deletion ///
  Future<void> deletePost(String postId, String userId,
      {bool isAlt = false, String? herdId}) async {
    try {
      DocumentReference? postRef;

      // Determine which collection to delete from based on post type
      if (isAlt) {
        postRef = _firestore.collection('altPosts').doc(postId);
      } else if (herdId != null && herdId.isNotEmpty) {
        postRef = _firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .doc(postId);
      } else {
        postRef = _firestore.collection('posts').doc(postId);
      }

      // Get post data before deletion for cleanup
      final postDoc = await postRef.get();
      if (!postDoc.exists) {
        throw Exception("Post not found");
      }

      final postData = postDoc.data() as Map<String, dynamic>;

      // Security check: Only allow the author to delete their own post
      if (postData['authorId'] != userId) {
        throw Exception("You don't have permission to delete this post");
      }

      // Delete associated media files from storage
      await _deletePostMedia(postId, userId, isAlt);

      await _deleteUserOwnInteractions(postId, userId);

      // Delete the post document itself
      await postRef.delete();

      debugPrint('Post $postId successfully deleted');
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> _deletePostMedia(
      String postId, String userId, bool isAlt) async {
    try {
      // Base path for post media
      final basePath = isAlt
          ? 'users/$userId/alt/posts/$postId'
          : 'users/$userId/posts/$postId';

      final storageRef = _storage.ref().child(basePath);

      try {
        // List all items in this directory
        final result = await storageRef.listAll();

        // Delete each item
        for (var item in result.items) {
          debugPrint('Deleting storage item: ${item.fullPath}');
          await item.delete();
        }

        // Delete items in subdirectories
        for (var prefix in result.prefixes) {
          final subResult = await prefix.listAll();
          for (var item in subResult.items) {
            debugPrint('Deleting storage item: ${item.fullPath}');
            await item.delete();
          }
        }
      } catch (e) {
        debugPrint('Note: No media found at $basePath: $e');
      }

      // Also check for potential media with ID pattern postId-*
      // We need to check parent directories and filter
      try {
        final userMediaRef = _storage.ref().child('users/$userId/posts');
        final userMediaResult = await userMediaRef.listAll();

        // Find and delete any items or directories matching the pattern
        for (var prefix in userMediaResult.prefixes) {
          if (prefix.name.startsWith('$postId-')) {
            debugPrint('Found matching directory: ${prefix.fullPath}');

            // List all files in this directory
            final subResult = await prefix.listAll();

            // Delete each file
            for (var item in subResult.items) {
              debugPrint('Deleting storage item: ${item.fullPath}');
              await item.delete();
            }
          }
        }

        // Also check direct files
        for (var item in userMediaResult.items) {
          if (item.name.contains('$postId-')) {
            debugPrint('Deleting storage item: ${item.fullPath}');
            await item.delete();
          }
        }
      } catch (e) {
        // Ignore errors if the parent folder doesn't exist
        debugPrint('Note: Error checking for media with pattern $postId-*: $e');
      }
    } catch (e) {
      // Log but don't fail if media deletion has issues
      debugPrint('Warning: Error deleting post media: $e');
    }
  }

  Future<void> _deleteUserOwnInteractions(String postId, String userId) async {
    try {
      final likeRef = _firestore
          .collection("likes")
          .doc(postId)
          .collection("userInteractions")
          .doc(userId);

      final likeDoc = await likeRef.get();
      if (likeDoc.exists) {
        await likeRef.delete();
      }

      final dislikeRef = _firestore
          .collection("dislikes")
          .doc(postId)
          .collection("userInteractions")
          .doc(userId);
      final dislikeDoc = await dislikeRef.get();
      if (dislikeDoc.exists) {
        await dislikeRef.delete();
      }

      // Note: Comments by other users should remain until cleaned up by Cloud Functions
      // Only delete the user's own comments if needed
      // final commentsQuery = await _firestore
      //     .collection('comments')
      //     .doc(postId)
      //     .collection('postComments')
      //     .where('authorId', isEqualTo: userId)
      //     .get();

      // for (final doc in commentsQuery.docs) {
      //   await doc.reference.delete();
      // }
    } catch (e) {
      debugPrint('Error deleting user interactions: $e');
    }
  }

  // Get all user posts
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .where('herdId', isNull: true) // Exclude herd posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get only user's public posts
  Stream<List<PostModel>> getUserPublicPosts(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .where('herdId', isNull: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  Stream<List<PostModel>> getUserAltProfilePosts(
    String userId, {
    int limit = 20,
    double? lastHotScore,
    String? lastPostId,
  }) {
    debugPrint('⚠️ Getting alt posts from userFeeds/$userId/feed');
    return FirebaseFirestore.instance
        .collection('userFeeds')
        .doc(userId)
        .collection('feed')
        .where('authorId', isEqualTo: userId)
        .where('feedType', isEqualTo: 'alt')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();
      return posts;
    });
  }

  /// Get public posts for a user's profile
  Future<List<PostModel>> getFutureUserPublicPosts(
    String userId, {
    int limit = 20,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      // Query directly from posts collection (not userFeeds)
      Query<Map<String, dynamic>> postsQuery = _firestore
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .where('isAlt', isEqualTo: false)
          .orderBy('hotScore', descending: true);

      // Apply pagination if provided
      if (lastHotScore != null) {
        postsQuery = postsQuery.startAfter([lastHotScore]);
      }

      // Apply limit
      postsQuery = postsQuery.limit(limit);

      // Execute query
      final snapshot = await postsQuery.get();

      return snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting user public posts: $e');
      rethrow;
    }
  }

  /// Get alt posts for a user's profile (includes posts from both altPosts and herdPosts)
  Future<List<PostModel>> getFutureUserAltProfilePosts(
    String userId, {
    int limit = 20,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      // First, query alt posts
      Query<Map<String, dynamic>> altPostsQuery = _firestore
          .collection('altPosts')
          .where('authorId', isEqualTo: userId)
          .orderBy('hotScore', descending: true);

      // Apply limit (we'll fetch more to merge with herd posts)
      altPostsQuery = altPostsQuery.limit(limit);

      // Execute query
      final altSnapshot = await altPostsQuery.get();
      final altPosts = altSnapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Second, query the user's herd posts
      // We need to find herds the user is a member of first
      final userHerdsQuery = _firestore
          .collection('herdMembers')
          .where('members', arrayContains: userId);

      final herdsSnapshot = await userHerdsQuery.get();

      // Fetch posts from each herd
      List<PostModel> herdPosts = [];
      for (final herdDoc in herdsSnapshot.docs) {
        final herdId = herdDoc.id;

        final herdPostsQuery = _firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .where('authorId', isEqualTo: userId)
            .orderBy('hotScore', descending: true)
            .limit(limit);

        final herdPostsSnapshot = await herdPostsQuery.get();

        herdPosts.addAll(herdPostsSnapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList());
      }

      // Combine and sort posts
      final allPosts = [...altPosts, ...herdPosts];
      allPosts.sort((a, b) => (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

      // Apply final limit after combining
      return allPosts.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting user alt posts: $e');
      rethrow;
    }
  }

  /// Liking and Disliking Posts ///
  Future<void> likePost({
    required String postId,
    required String userId,
    required bool isAlt,
    String? feedType,
    String? herdId,
  }) async {
    try {
      // Determine the effective feed type if not provided
      final effectiveFeedType = feedType ?? (isAlt ? 'alt' : 'public');

      // Add herdId to the parameters when it's a herd post
      final params = {
        'postId': postId,
        'interactionType': 'like',
        'feedType': effectiveFeedType,
      };

      // Only add herdId if it's provided and it's a herd post
      if (effectiveFeedType == 'herd' && herdId != null) {
        params['herdId'] = herdId;
      }

      // Call the Cloud Function with the parameters
      await _functions.httpsCallable('handlePostInteraction').call(params);
    } catch (e) {
      debugPrint('Error liking post with cloud function: $e');
      debugPrint('Falling back to direct like method...');

      try {
        // Fallback to direct method if cloud function fails
        await _directLikePost(postId: postId, userId: userId);
      } catch (fallbackError) {
        debugPrint('Error with direct like fallback: $fallbackError');
        rethrow;
      }
    }
  }

  Future<void> dislikePost({
    required String postId,
    required String userId,
    required bool isAlt,
    String? feedType,
    String? herdId,
  }) async {
    try {
      // Determine the effective feed type if not provided
      final effectiveFeedType = feedType ?? (isAlt ? 'alt' : 'public');

      // Add herdId to the parameters when it's a herd post
      final params = {
        'postId': postId,
        'interactionType': 'dislike',
        'feedType': effectiveFeedType,
      };

      // Only add herdId if it's provided and it's a herd post
      if (effectiveFeedType == 'herd' && herdId != null) {
        params['herdId'] = herdId;
      }

      // Call the Cloud Function with the parameters
      await _functions.httpsCallable('handlePostInteraction').call(params);
    } catch (e) {
      debugPrint('Error disliking post with cloud function: $e');
      debugPrint('Falling back to direct dislike method...');

      try {
        // Fallback to direct method if cloud function fails
        await _directDislikePost(postId: postId, userId: userId);
      } catch (fallbackError) {
        debugPrint('Error with direct dislike fallback: $fallbackError');
        rethrow;
      }
    }
  }

  Future<String> createHerdPost({
    required PostModel post,
    required String herdId,
    required String userId,
  }) async {
    try {
      // Set the correct post attributes
      final postWithHerdId = post.copyWith(
          herdId: herdId,
          isAlt:
              true, // All herd posts are considered alt posts in the new structure
          feedType: 'herd');

      // For consistency, create the same document ID for both locations
      final postRef = _firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc();

      final postId = postRef.id;

      // The actual post creation is handled by the Firebase functions
      // which implement our new structure, so we just need to create
      // the initial document

      await postRef.set({
        ...postWithHerdId.toMap(),
        'id': postId,
      });

      return postId;
    } catch (e) {
      debugPrint('Error creating herd post: $e');
      rethrow;
    }
  }

  Future<void> _directLikePost(
      {required String postId, required String userId}) async {
    final postLikeRef = _likes.doc(postId).collection('postLikes').doc(userId);
    final postDislikeRef =
        _dislikes.doc(postId).collection('postDislikes').doc(userId);
    final postRef = _posts.doc(postId);

    try {
      // First transaction: Handle the like/unlike operation
      final transactionResult =
          await _firestore.runTransaction((transaction) async {
        // Pre-fetch data
        final postSnapshot = await transaction.get(postRef);
        final postLikeSnapshot = await transaction.get(postLikeRef);
        final postDislikeSnapshot = await transaction.get(postDislikeRef);

        if (!postSnapshot.exists) {
          throw Exception("Post not found");
        }

        final hasDisliked = postDislikeSnapshot.exists;
        final hasLiked = postLikeSnapshot.exists;
        final postAuthorId = postSnapshot.data()!['authorId'];

        // Handle dislikes
        if (hasDisliked) {
          transaction.delete(postDislikeRef);
          transaction
              .update(postRef, {'dislikeCount': FieldValue.increment(-1)});
        }

        // Handle likes
        if (hasLiked) {
          // Unlike the post
          transaction.delete(postLikeRef);
          transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
          return {'postAuthorId': postAuthorId, 'isNewLike': false};
        } else {
          // Like the post
          transaction
              .set(postLikeRef, {'createdAt': FieldValue.serverTimestamp()});
          transaction.update(postRef, {'likeCount': FieldValue.increment(1)});
          return {'postAuthorId': postAuthorId, 'isNewLike': true};
        }
      });

      // Check if we need to increment user points (only if it's a new like)
      if (transactionResult['isNewLike'] == true) {
        final postAuthorId = transactionResult['postAuthorId'];
        // Update points in a separate operation
        await UserRepository(_firestore).incrementUserPoints(postAuthorId, 1);
      }
    } catch (e) {
      debugPrint("Error in likePost operation: $e");
      rethrow;
    }
  }

  // Dislike Post
  Future<void> _directDislikePost(
      {required String postId, required String userId}) async {
    final postLikeRef = _likes.doc(postId).collection('postLikes').doc(userId);
    final postDislikeRef =
        _dislikes.doc(postId).collection('postDislikes').doc(userId);
    final postRef = _posts.doc(postId);

    await _firestore.runTransaction((transaction) async {
      // *** PRE-FETCH ALL DATA AT THE BEGINNING ***
      final postSnapshot = await transaction.get(postRef);
      final postLikeSnapshot = await transaction.get(postLikeRef);
      final postDislikeSnapshot = await transaction.get(postDislikeRef);

      if (!postSnapshot.exists) {
        throw Exception("Post not found");
      }

      final hasLiked = postLikeSnapshot.exists;
      final hasDisliked = postDislikeSnapshot.exists;

      // *** NOW PERFORM LOGIC AND WRITES BASED ON PRE-FETCHED DATA ***

      if (hasLiked) {
        transaction.delete(postLikeRef);
        transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
      }

      if (hasDisliked) {
        // Undislike the post
        transaction.delete(postDislikeRef);
        transaction.update(postRef, {'dislikeCount': FieldValue.increment(-1)});
      } else {
        // Dislike the post
        transaction
            .set(postDislikeRef, {'createdAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {'dislikeCount': FieldValue.increment(1)});
      }
    });
  }

  // Check if post is liked by user
  Future<bool> isPostLikedByUser(
      {required String postId, required String userId}) async {
    final postLikeRef =
        _likes.doc(postId).collection('userInteractions').doc(userId);
    final snapshot = await postLikeRef.get();
    return snapshot.exists;
  }

  // Check if post is disliked by user
  Future<bool> isPostDislikedByUser(
      {required String postId, required String userId}) async {
    final postDislikeRef =
        _dislikes.doc(postId).collection('userInteractions').doc(userId);
    final snapshot = await postDislikeRef.get();
    return snapshot.exists;
  }

  /// DEBUG METHODS - DO NOT USE IN PRODUCTION
  /// These methods are for debugging purposes only and should not be used in production code.
  Future<Map<String, dynamic>> recalculateAllUserPostCountsBatch({
    int batchSize = 10,
    String? startAfterUserId,
  }) async {
    try {
      final callable =
          _functions.httpsCallable('recalculateUserPostCountsBatch');
      final result = await callable.call({
        'batchSize': batchSize,
        'startAfterUserId': startAfterUserId,
      });
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('Error recalculating post counts batch: $e');
      rethrow;
    }
  }

  /// Process all users in batches automatically
  Future<Map<String, dynamic>> recalculateAllUsersInBatches() async {
    int totalProcessed = 0;
    String? lastUserId;
    bool hasMore = true;

    while (hasMore) {
      try {
        final result = await recalculateAllUserPostCountsBatch(
          batchSize: 10,
          startAfterUserId: lastUserId,
        );

        if (result['success'] == true) {
          totalProcessed += result['processedCount'] as int;
          lastUserId = result['lastUserId'] as String?;
          hasMore = result['hasMore'] as bool;

          debugPrint(
              'Processed batch: ${result['processedCount']} users, total: $totalProcessed');

          // Small delay between batches to avoid overwhelming Firestore
          if (hasMore) {
            await Future.delayed(const Duration(seconds: 1));
          }
        } else {
          throw Exception(result['error']);
        }
      } catch (e) {
        debugPrint('Error processing batch: $e');
        break;
      }
    }

    return {
      'success': true,
      'totalProcessed': totalProcessed,
      'message': 'Processed $totalProcessed users in batches'
    };
  }

  Future<Map<String, dynamic>> recalculateUserPostCounts(String userId) async {
    try {
      final callable = _functions.httpsCallable('recalculateUserPostCounts');
      final result = await callable.call({'userId': userId});
      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      debugPrint('Error recalculating user post counts: $e');
      rethrow;
    }
  }
}
