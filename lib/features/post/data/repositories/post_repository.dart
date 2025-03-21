import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import '../../../user/data/repositories/user_repository.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');
  CollectionReference<Map<String, dynamic>> get _globalPrivatePosts => _firestore.collection('globalPrivatePosts');
  CollectionReference<Map<String, dynamic>> get _comments => _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes => _firestore.collection('likes');
  CollectionReference<Map<String, dynamic>> get _dislikes => _firestore.collection('dislikes');
  CollectionReference<Map<String, dynamic>> get _feeds => _firestore.collection('feeds');
  CollectionReference<Map<String, dynamic>> get _privateFeeds => _firestore.collection('privateFeeds');

  /// Creating a post ///
  Future<void> createPost(PostModel post) async {
    try {
      // First determine which collection to use based on privacy setting
      final targetCollection = post.isPrivate ? _globalPrivatePosts : _posts;

      // Create the post document in the appropriate collection
      final docRef = await targetCollection.add(post.toMap());

      // Update the id field with the auto-generated ID
      await docRef.update({'id': docRef.id});

      // Add to the post creator's own feed (this is still allowed by security rules)
      if (post.isPrivate) {
        // Add to user's own private feed
        await _privateFeeds
            .doc(post.authorId)
            .collection('privateFeed')
            .doc(docRef.id)
            .set({
          ...post.toMap(),
          'id': docRef.id,
        });
      } else {
        // Add to user's own public feed
        await _feeds
            .doc(post.authorId)
            .collection('userFeed')
            .doc(docRef.id)
            .set({
          ...post.toMap(),
          'id': docRef.id,
        });
      }

      // The Cloud Function will handle distribution to other users' feeds
      debugPrint('Post created with ID: ${docRef.id}');
      debugPrint('Distribution to followers will be handled by Cloud Function');
    } catch (e) {
      debugPrint('Error creating post: $e');
      throw e; // Rethrow to allow proper error handling upstream
    }
  }

  Future<String?> uploadImage(File imageFile, {
    required String postId,
    required String userId,
    File? file, // Optional
    String? type, // Optional
    bool isPrivate = false, // New parameter for differentiating private/public content
  }) async {
    if (file == null || type == null) {
      return null; // No file to upload
    }

    try {
      // Get the file extension to preserve it
      final extension = path.extension(file.path).toLowerCase();

      // Create the storage path with the correct extension
      final String storagePath = isPrivate
          ? 'users/$userId/private/posts/$postId/$type$extension'
          : 'users/$userId/posts/$postId/$type$extension';

      final ref = _storage.ref().child(storagePath);

      // Set appropriate content type based on extension
      final SettableMetadata metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {'isPrivate': isPrivate.toString()},
      );

      // Upload with metadata
      final uploadTask = ref.putFile(file, metadata);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload media: $e");
    }
  }


  // Helper method to determine content type based on file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.mkv':
        return 'video/x-matroska';
      case '.webm':
        return 'video/webm';
      default:
        return 'application/octet-stream'; // Default binary content type
    }
  }

  String generatePostId() => _firestore.collection('posts').doc().id;

  /// Get Posts for Feeds ///
  // Get public user feed with pagination
  Future<List<PostModel>> getUserFeed({
    required String userId,
    String? lastPostId,
    int limit = 10,
  }) async {
    var query = _feeds
        .doc(userId)
        .collection('userFeed')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastPostDoc = await _posts.doc(lastPostId).get();
      if (lastPostDoc.exists) {
        query = query.startAfterDocument(lastPostDoc);
      }
    }

    final postsSnap = await query.get();
    return postsSnap.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList();
  }


  // Get private user feed with pagination
  Future<List<PostModel>> getPrivateUserFeed({
    required String userId,
    String? lastPostId,
    int limit = 10,
  }) async {
    var query = _privateFeeds
        .doc(userId)
        .collection('privateFeed')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastPostDoc = await _globalPrivatePosts.doc(lastPostId).get();
      if (lastPostDoc.exists) {
        query = query.startAfterDocument(lastPostDoc);
      }
    }

    final postsSnap = await query.get();
    return postsSnap.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<PostModel>> getPostsWithAuthorDetails({bool privateOnly = false}) async {
    var query = _posts.orderBy('createdAt', descending: true);

    if (privateOnly) {
      query = query.where('isPrivate', isEqualTo: true);
    } else {
      query = query.where('isPrivate', isEqualTo: false);
    }

    final postsSnap = await query.get();
    final posts = <PostModel>[];

    for (final doc in postsSnap.docs) {
      final post = PostModel.fromMap(doc.id, doc.data());

      // Fetch author details
      final authorDoc = await _firestore.collection('users').doc(post.authorId).get();
      final authorData = authorDoc.data();

      if (authorData != null) {
        posts.add(PostModel(
          id: post.id,
          authorId: post.authorId,
          username: authorData['username'] ?? 'Unknown',
          profileImageURL: post.isPrivate
              ? authorData['privateProfileImageURL'] ?? authorData['profileImageURL']
              : authorData['profileImageURL'],
          title: post.title,
          content: post.content,
          imageUrl: post.imageUrl,
          isPrivate: post.isPrivate,
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
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList());
  }

  // Get post by ID
  Future<PostModel?> getPostById(String postId) async {
    final doc = await _posts.doc(postId).get();
    return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
  }

  // Stream specific post
  Stream<PostModel?> streamPost(String postId) {
    return _posts.doc(postId).snapshots().map((doc) {
      return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
    });
  }

  /// Post Deletion ///
  Future<void> deletePost(String postId) async {
    // Fetch post to check if it's private or public
    final postDoc = await _posts.doc(postId).get();
    final privatePostDoc = await _globalPrivatePosts.doc(postId).get();

    // Determine which collection to delete from
    if (postDoc.exists) {
      await _posts.doc(postId).delete();
      debugPrint('Public post deleted with ID: $postId');
      debugPrint('Removal from followers\' feeds will be handled by Cloud Function');
    } else if (privatePostDoc.exists) {
      await _globalPrivatePosts.doc(postId).delete();
      debugPrint('Private post deleted with ID: $postId');
      debugPrint('Removal from private connections\' feeds will be handled by Cloud Function');
    } else {
      throw Exception("Post not found");
    }

    // Delete associated documents (comments, likes, dislikes)
    await _deleteSubCollection(_comments.doc(postId).collection('postComments'));
    await _deleteSubCollection(_likes.doc(postId).collection('postLikes'));
    await _deleteSubCollection(_dislikes.doc(postId).collection('postDislikes'));

    // Remove from the author's feed (the Cloud Function will handle distribution)
    // You'd need the authorId from the post data here
  }

  // Utility: Delete all documents in a subcollection
  Future<void> _deleteSubCollection(CollectionReference<Map<String, dynamic>> collection) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Get all user posts
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .where('herdId', isNull: true) // Exclude herd posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
          snapshot.docs.map((doc) =>
              PostModel.fromMap(doc.id, doc.data())).toList());
  }

  // Get only user's public posts
  Stream<List<PostModel>> getUserPublicPosts(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .where('herdId', isNull: true) // Exclude herd posts
        .where('isPrivate', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
          snapshot.docs.map((doc) =>
              PostModel.fromMap(doc.id, doc.data())).toList());
  }

  // Get only user's private posts
  Stream<List<PostModel>> getUserPrivatePosts(String userId) {
    return _globalPrivatePosts
        .where('authorId', isEqualTo: userId)
        .where('herdId', isNull: true) // Exclude herd posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
          snapshot.docs.map((doc) =>
              PostModel.fromMap(doc.id, doc.data())).toList());
  }

  /// Liking and Disliking Posts ///

  Future<void> likePost({required String postId, required String userId}) async {
    final postLikeRef = _likes.doc(postId).collection('postLikes').doc(userId);
    final postDislikeRef = _dislikes.doc(postId).collection('postDislikes').doc(userId);
    final postRef = _posts.doc(postId);

    try {
      // First transaction: Handle the like/unlike operation
      final transactionResult = await _firestore.runTransaction((transaction) async {
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
          transaction.update(postRef, {'dislikeCount': FieldValue.increment(-1)});
        }

        // Handle likes
        if (hasLiked) {
          // Unlike the post
          transaction.delete(postLikeRef);
          transaction.update(postRef, {'likeCount': FieldValue.increment(-1)});
          return {'postAuthorId': postAuthorId, 'isNewLike': false};
        } else {
          // Like the post
          transaction.set(postLikeRef, {'createdAt': FieldValue.serverTimestamp()});
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
      print("Error in likePost operation: $e");
      rethrow;
    }
  }

  // Dislike Post
  Future<void> dislikePost({required String postId, required String userId}) async {
    final postLikeRef = _likes.doc(postId).collection('postLikes').doc(userId);
    final postDislikeRef = _dislikes.doc(postId).collection('postDislikes').doc(userId);
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
        transaction.set(postDislikeRef, {'createdAt': FieldValue.serverTimestamp()});
        transaction.update(postRef, {'dislikeCount': FieldValue.increment(1)});
      }
    });
  }

  // Check if post is liked by user
  Future<bool> isPostLikedByUser({required String postId, required String userId}) async {
    final postLikeRef = _likes.doc(postId).collection('postLikes').doc(userId);
    final snapshot = await postLikeRef.get();
    return snapshot.exists;
  }

  // Check if post is disliked by user
  Future<bool> isPostDislikedByUser({required String postId, required String userId}) async {
    final postDislikeRef = _dislikes.doc(postId).collection('postDislikes').doc(userId);
    final snapshot = await postDislikeRef.get();
    return snapshot.exists;
  }
}