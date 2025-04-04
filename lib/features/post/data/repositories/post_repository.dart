import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;
import '../../../../core/services/image_helper.dart';
import '../../../comment/data/models/comment_model.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');
  CollectionReference<Map<String, dynamic>> get _globalAltPosts => _firestore.collection('globalAltPosts');
  CollectionReference<Map<String, dynamic>> get _comments => _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes => _firestore.collection('likes');
  CollectionReference<Map<String, dynamic>> get _dislikes => _firestore.collection('dislikes');
  CollectionReference<Map<String, dynamic>> get _feeds => _firestore.collection('feeds');
  CollectionReference<Map<String, dynamic>> get _altFeeds => _firestore.collection('altFeeds');

  /// Creating a post ///
  Future<void> createPost(PostModel post) async {
    try {
      // First determine which collection to use based on privacy setting
      final targetCollection = post.isAlt ? _globalAltPosts : _posts;

      // Create the post document in the appropriate collection
      final docRef = await targetCollection.add(post.toMap());

      // Update the id field with the auto-generated ID
      await docRef.update({'id': docRef.id});

      // Add to the post creator's own feed (this is still allowed by security rules)
      if (post.isAlt) {
        // Add to user's own alt feed
        await _altFeeds
            .doc(post.authorId)
            .collection('altFeed')
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

  Future<Map<String, String?>> uploadMedia({
    required File mediaFile,
    required String postId,
    required String userId,
    bool isAlt = false,
  }) async {
    try {
      final extension = path.extension(mediaFile.path).toLowerCase();
      String? mediaType;
      String? fullResUrl;
      String? thumbnailUrl;

      // Determine media type
      if (ImageHelper.isImage(mediaFile)) {
        mediaType = ImageHelper.isGif(mediaFile) ? 'gif' : 'image';
      } else if (ImageHelper.isVideo(mediaFile)) {
        mediaType = 'video';
      } else {
        mediaType = 'other';
      }

      // Create the storage path with the correct extension
      final String baseStoragePath = isAlt
          ? 'users/$userId/alt/posts/$postId'
          : 'users/$userId/posts/$postId';

      // Set appropriate content type based on extension
      final contentType = _getContentType(extension);

      // For videos, just upload the full version
      if (mediaType == 'video') {
        final ref = _storage.ref().child('$baseStoragePath/video$extension');

        // Set metadata with content type
        final SettableMetadata metadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'isAlt': isAlt.toString(),
            'mediaType': mediaType,
          },
        );

        // Upload with progress tracking
        final uploadTask = ref.putFile(mediaFile, metadata);

        // Add upload monitoring and error handling
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          debugPrint('Video upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
        }, onError: (e) {
          debugPrint('Video upload error: $e');
        });

        final snapshot = await uploadTask;
        fullResUrl = await snapshot.ref.getDownloadURL();

        // For videos, we use the same URL for both full and thumbnail for now
        // (In a more advanced implementation, you could generate a thumbnail image from the video)
        thumbnailUrl = fullResUrl;
      }
      // For GIFs, upload as is without compression
      else if (mediaType == 'gif') {
        final ref = _storage.ref().child('$baseStoragePath/fullres$extension');

        final SettableMetadata metadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'isAlt': isAlt.toString(),
            'mediaType': mediaType,
          },
        );

        final uploadTask = ref.putFile(mediaFile, metadata);
        final snapshot = await uploadTask;
        fullResUrl = await snapshot.ref.getDownloadURL();

        // For GIFs, we use the same URL for both
        thumbnailUrl = fullResUrl;
      }
      // For regular images, upload both versions
      else if (mediaType == 'image') {
        // 1. Upload full resolution image
        final fullResRef = _storage.ref().child('$baseStoragePath/fullres$extension');

        final fullResMetadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'isAlt': isAlt.toString(),
            'mediaType': mediaType,
            'version': 'fullres',
          },
        );

        final fullResUploadTask = fullResRef.putFile(mediaFile, fullResMetadata);
        final fullResSnapshot = await fullResUploadTask;
        fullResUrl = await fullResSnapshot.ref.getDownloadURL();

        // 2. Create and upload compressed version
        final compressedImage = await ImageHelper.compressImage(mediaFile, quality: 70);
        if (compressedImage != null) {
          final thumbnailRef = _storage.ref().child('$baseStoragePath/thumbnail$extension');

          final thumbnailMetadata = SettableMetadata(
            contentType: contentType,
            customMetadata: {
              'isAlt': isAlt.toString(),
              'mediaType': mediaType,
              'version': 'thumbnail',
            },
          );

          final thumbnailUploadTask = thumbnailRef.putFile(compressedImage, thumbnailMetadata);
          final thumbnailSnapshot = await thumbnailUploadTask;
          thumbnailUrl = await thumbnailSnapshot.ref.getDownloadURL();
        } else {
          // If compression fails, use the full-res URL for both
          thumbnailUrl = fullResUrl;
        }
      }

      return {
        'imageUrl': fullResUrl,
        'thumbnailUrl': thumbnailUrl,
        'mediaType': mediaType,
      };
    } catch (e) {
      debugPrint('Error uploading media: $e');
      throw Exception("Failed to upload media: $e");
    }
  }

  // Legacy method for compatibility, redirects to the new uploadMedia method
  Future<String?> uploadImage(File imageFile, {
    required String postId,
    required String userId,
    File? file, // Optional
    String? type, // Optional
    bool isAlt = false, // New parameter for differentiating alt/public content
  }) async {
    if (file == null) {
      return null; // No file to upload
    }

    try {
      final result = await uploadMedia(
        mediaFile: file,
        postId: postId,
        userId: userId,
        isAlt: isAlt,
      );

      return result['imageUrl']; // Return the full resolution URL for backward compatibility
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


  // Get alt user feed with pagination
  Future<List<PostModel>> getAltUserFeed({
    required String userId,
    String? lastPostId,
    int limit = 10,
  }) async {
    var query = _altFeeds
        .doc(userId)
        .collection('altFeed')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastPostDoc = await _globalAltPosts.doc(lastPostId).get();
      if (lastPostDoc.exists) {
        query = query.startAfterDocument(lastPostDoc);
      }
    }

    final postsSnap = await query.get();
    return postsSnap.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<PostModel>> getPostsWithAuthorDetails({bool altOnly = false}) async {
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
      final authorDoc = await _firestore.collection('users').doc(post.authorId).get();
      final authorData = authorDoc.data();

      if (authorData != null) {
        posts.add(PostModel(
          id: post.id,
          authorId: post.authorId,
          username: authorData['username'] ?? 'Unknown',
          profileImageURL: post.isAlt
              ? authorData['altProfileImageURL'] ?? authorData['profileImageURL']
              : authorData['profileImageURL'],
          title: post.title,
          content: post.content,
          imageUrl: post.imageUrl,
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
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList());
  }

  // Get post by ID
  Future<PostModel?> getPostById(String postId, {bool? isAlt, String? herdId, bool forceRefresh = false}) async {
    try {
      // Set the correct fetch option based on forceRefresh
      final fetchOptions = forceRefresh
          ? GetOptions(source: Source.server)
          : GetOptions(source: Source.serverAndCache);

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

      final herdPostQuery = await _firestore
      .collectionGroup('posts')
      .where(FieldPath.documentId, isEqualTo: postId)
      .limit(1)
      .get(fetchOptions);

      if (herdPostQuery.docs.isNotEmpty) {
        return PostModel.fromMap(postId, herdPostQuery.docs.first.data()); // Check for the postId directly
      }

      final publicDoc = await _posts.doc(postId).get();
      if (publicDoc.exists) {
        return PostModel.fromMap(publicDoc.id, publicDoc.data()!);
      }


      if (isAlt == true) {
        final doc = await _firestore
            .collection('globalAltPosts')
            .doc(postId)
            .get(fetchOptions);
        if (doc.exists) {
          return PostModel.fromMap(doc.id, doc.data()!);
        }
        return null;
      }

      // If we know it's public, check only in public collection
      if (isAlt == false) {
        final doc = await _firestore
            .collection('posts')
            .doc(postId)
            .get(fetchOptions);
        if (doc.exists) {
          return PostModel.fromMap(doc.id, doc.data()!);
        }
        return null;
      }

      // Then try the alt posts collection
      final altDoc = await _globalAltPosts.doc(postId).get();
      if (altDoc.exists) {
        return PostModel.fromMap(altDoc.id, altDoc.data()!);
      }


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

  /// Post Deletion ///
  Future<void> deletePost(String postId) async {
    // Fetch post to check if it's alt or public
    final postDoc = await _posts.doc(postId).get();
    final altPostDoc = await _globalAltPosts.doc(postId).get();

    // Determine which collection to delete from
    if (postDoc.exists) {
      await _posts.doc(postId).delete();
      debugPrint('Public post deleted with ID: $postId');
      debugPrint('Removal from followers\' feeds will be handled by Cloud Function');
    } else if (altPostDoc.exists) {
      await _globalAltPosts.doc(postId).delete();
      debugPrint('Alt post deleted with ID: $postId');
      debugPrint('Removal from alt connections\' feeds will be handled by Cloud Function');
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
        .where('isAlt', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
          snapshot.docs.map((doc) =>
              PostModel.fromMap(doc.id, doc.data())).toList());
  }

  // Get only user's alt posts
  Stream<List<PostModel>> getUserAltPosts(String userId) {
    return _globalAltPosts
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