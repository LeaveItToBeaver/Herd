import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as path;

import '../../../../core/services/image_helper.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../models/post_media_model.dart';
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
  CollectionReference<Map<String, dynamic>> get _comments =>
      _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes =>
      _firestore.collection('likes');
  CollectionReference<Map<String, dynamic>> get _dislikes =>
      _firestore.collection('dislikes');
  CollectionReference<Map<String, dynamic>> get _feeds =>
      _firestore.collection('feeds');
  CollectionReference<Map<String, dynamic>> get _altFeeds =>
      _firestore.collection('altFeeds');

// At the beginning of createPost
  Future<void> createPost(PostModel post, {List<File>? mediaFiles}) async {
    try {
      // Generate post ID if needed
      String postId =
          post.id.isEmpty ? _firestore.collection('posts').doc().id : post.id;

      // Enhanced debugging
      debugPrint(
          "🔍 CREATE POST START - ID: $postId with ${mediaFiles?.length ?? 0} media files");

      List<PostMediaModel> mediaItems = [];
      debugPrint("🔍 Initialized empty mediaItems array");

      // Upload multiple media files if provided
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        debugPrint("🔍 Beginning upload of ${mediaFiles.length} media files");

        // For each media file, upload it and get the URL
        for (int i = 0; i < mediaFiles.length; i++) {
          final File file = mediaFiles[i];
          final String mediaId = '$i';
          final String individualPostId = '$postId-$mediaId';

          debugPrint("🔍 Processing file $i: ${file.path}");

          try {
            // Use existing uploadMedia method
            final result = await uploadMedia(
              mediaFile: file,
              postId: individualPostId,
              userId: post.authorId,
              isAlt: post.isAlt,
            );

            debugPrint("🔍 Upload result for file $i: $result");

            // Only add if we got a URL back
            if (result['imageUrl'] != null && result['imageUrl']!.isNotEmpty) {
              // Create the media model and add to our list
              final mediaItem = PostMediaModel(
                id: mediaId,
                url: result['imageUrl']!,
                thumbnailUrl: result['thumbnailUrl'],
                mediaType: result['mediaType'] ?? 'image',
              );

              mediaItems.add(mediaItem);
              debugPrint("🔍 Added to mediaItems: ${mediaItem.toMap()}");
              debugPrint("🔍 mediaItems length now: ${mediaItems.length}");
            }
          } catch (e) {
            debugPrint("❌ Error uploading media file $i: $e");
          }
        }

        debugPrint(
            "🔍 All uploads complete. Final mediaItems count: ${mediaItems.length}");
        if (mediaItems.isNotEmpty) {
          debugPrint("🔍 Sample first item: ${mediaItems.first.toMap()}");
        }
      }

      // Set the feedType alt/public/herd
      final feedType =
          post.isAlt ? 'alt' : (post.herdId != null ? 'herd' : 'public');

      // Create a map to update Firestore
      final Map<String, dynamic> postData = post.toMap();
      debugPrint(
          "🔍 Initial postData without mediaItems: ${postData.keys.toList()}");

      // Important: Make sure mediaItems is explicitly set in the map
      postData['mediaItems'] = mediaItems.map((item) => item.toMap()).toList();
      debugPrint(
          "🔍 CRITICAL CHECK: postData['mediaItems'] length: ${(postData['mediaItems'] as List).length}");
      debugPrint(
          "🔍 CRITICAL CHECK: postData['mediaItems'] content: ${postData['mediaItems']}");

      // For backward compatibility, set the first image URL as the mediaURL
      if (mediaItems.isNotEmpty) {
        postData['mediaURL'] = mediaItems.first.url;
        postData['mediaThumbnailURL'] = mediaItems.first.thumbnailUrl;
        postData['mediaType'] = mediaItems.first.mediaType;
        debugPrint("🔍 Set legacy mediaURL fields: ${postData['mediaURL']}");
      } else {
        debugPrint("⚠️ mediaItems is empty, no legacy mediaURL fields set");
      }

      postData['id'] = postId;
      postData['feedType'] = feedType;

      // Debug final state before save
      debugPrint(
          "🔍 FINAL CHECK before save: postData has ${(postData['mediaItems'] as List).length} mediaItems");

      // Create a post with the feed type and ID
      final postWithTypeAndId = post.copyWith(
        id: postId,
        feedType: feedType,
      );

      // Determine where to save the post
      if (post.isAlt) {
        // Save to altPosts collection
        await _firestore
            .collection('altPosts')
            .doc(postId)
            .set(postWithTypeAndId.toMap());
        debugPrint('Alt post created with ID: ${postId}');
      } else if (post.herdId != null && post.herdId!.isNotEmpty) {
        // Save to herdPosts collection
        await _firestore
            .collection('herdPosts')
            .doc(post.herdId)
            .collection('posts')
            .doc(postId)
            .set(postWithTypeAndId.toMap());
        debugPrint(
            'Herd post created with ID: ${postId} in herd: ${post.herdId}');
      } else {
        // Save to regular posts collection
        await _firestore
            .collection('posts')
            .doc(postId)
            .set(postWithTypeAndId.toMap());
        debugPrint('Public post created with ID: ${postId}');
      }
      debugPrint(
          "✅ Post created successfully with ${mediaItems.length} media items");
    } catch (e) {
      debugPrint("❌ ERROR creating post: $e");
      throw e;
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
          debugPrint(
              'Video upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%');
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
        final fullResRef =
            _storage.ref().child('$baseStoragePath/fullres$extension');

        final fullResMetadata = SettableMetadata(
          contentType: contentType,
          customMetadata: {
            'isAlt': isAlt.toString(),
            'mediaType': mediaType,
            'version': 'fullres',
          },
        );

        final fullResUploadTask =
            fullResRef.putFile(mediaFile, fullResMetadata);
        final fullResSnapshot = await fullResUploadTask;
        fullResUrl = await fullResSnapshot.ref.getDownloadURL();

        // 2. Create and upload compressed version
        final compressedImage =
            await ImageHelper.compressImage(mediaFile, quality: 70);
        if (compressedImage != null) {
          final thumbnailRef =
              _storage.ref().child('$baseStoragePath/thumbnail$extension');

          final thumbnailMetadata = SettableMetadata(
            contentType: contentType,
            customMetadata: {
              'isAlt': isAlt.toString(),
              'mediaType': mediaType,
              'version': 'thumbnail',
            },
          );

          final thumbnailUploadTask =
              thumbnailRef.putFile(compressedImage, thumbnailMetadata);
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
  Future<String?> uploadImage(
    File imageFile, {
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

      return result[
          'imageUrl']; // Return the full resolution URL for backward compatibility
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
    return postsSnap.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
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
    return postsSnap.docs
        .map((doc) => PostModel.fromMap(doc.id, doc.data()))
        .toList();
  }

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

  // In PostRepository class, add this method:
  Future<List<PostMediaModel>> uploadMultipleMediaFiles({
    required List<File> mediaFiles,
    required String postId,
    required String userId,
    bool isAlt = false,
  }) async {
    final List<PostMediaModel> uploadedMedia = [];

    // Process each file sequentially
    for (int i = 0; i < mediaFiles.length; i++) {
      try {
        final File file = mediaFiles[i];
        final String mediaId = '$i';
        final String individualPostId = '$postId-$mediaId';

        // Determine media type
        final extension = path.extension(file.path).toLowerCase();
        String mediaType;

        if (ImageHelper.isImage(file)) {
          mediaType = ImageHelper.isGif(file) ? 'gif' : 'image';
        } else if (ImageHelper.isVideo(file)) {
          mediaType = 'video';
        } else {
          mediaType = 'other';
        }

        // Use your existing uploadMedia method
        final result = await uploadMedia(
          mediaFile: file,
          postId: individualPostId,
          userId: userId,
          isAlt: isAlt,
        );

        // Create a PostMediaModel from the upload result
        if (result['imageUrl'] != null) {
          uploadedMedia.add(PostMediaModel(
            id: mediaId,
            url: result['imageUrl']!,
            thumbnailUrl: result['thumbnailUrl'],
            mediaType: result['mediaType'] ?? mediaType,
          ));
        }
      } catch (e) {
        debugPrint('Error uploading media file ${i + 1}: $e');
        // Continue with other files even if one fails
      }
    }

    return uploadedMedia;
  }

  /// Get post by ID
  Future<PostModel?> getPostById(String postId,
      {bool? isAlt, String? herdId, bool forceRefresh = false}) async {
    try {
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

  /// Post Deletion ///
  Future<void> deletePost(String postId) async {
    // Fetch post to check if it's alt or public
    final postDoc = await _posts.doc(postId).get();
    final altPostDoc = await _globalAltPosts.doc(postId).get();

    // Determine which collection to delete from
    if (postDoc.exists) {
      await _posts.doc(postId).delete();
      debugPrint('Public post deleted with ID: $postId');
      debugPrint(
          'Removal from followers\' feeds will be handled by Cloud Function');
    } else if (altPostDoc.exists) {
      await _globalAltPosts.doc(postId).delete();
      debugPrint('Alt post deleted with ID: $postId');
      debugPrint(
          'Removal from alt connections\' feeds will be handled by Cloud Function');
    } else {
      throw Exception("Post not found");
    }

    // Delete associated documents (comments, likes, dislikes)
    await _deleteSubCollection(
        _comments.doc(postId).collection('postComments'));
    await _deleteSubCollection(_likes.doc(postId).collection('postLikes'));
    await _deleteSubCollection(
        _dislikes.doc(postId).collection('postDislikes'));

    // Remove from the author's feed (the Cloud Function will handle distribution)
    // You'd need the authorId from the post data here
  }

  // Utility: Delete all documents in a subcollection
  Future<void> _deleteSubCollection(
      CollectionReference<Map<String, dynamic>> collection) async {
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

  // Add this method to your PostRepository class
  Stream<List<PostModel>> getUserAltProfilePosts(String userId) {
    return FirebaseFirestore.instance
        .collection('userFeeds')
        .doc(userId)
        .collection('feed')
        .where('authorId', isEqualTo: userId) // Posts by this user
        .where('feedType', isEqualTo: 'alt') // Only alt posts
        .orderBy('hotScore', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get only user's alt posts=
  Future<List<PostModel>> getFutureUserAltProfilePosts(
    String userId, {
    int limit = 20,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      debugPrint('Fetching alt profile posts for user: $userId');

      // Query the userFeeds/{userId}/feed collection for alt posts by this author
      Query<Map<String, dynamic>> query = FirebaseFirestore.instance
          .collection('userFeeds')
          .doc(userId)
          .collection('feed')
          .where('authorId', isEqualTo: userId) // Posts by this user
          .where('feedType', isEqualTo: 'alt') // Only alt posts
          .orderBy('hotScore', descending: true);

      // Apply pagination if needed
      if (lastHotScore != null && lastPostId != null) {
        query = query.startAfter([lastHotScore, lastPostId]);
      }

      // Apply limit
      query = query.limit(limit);

      // Execute query
      final snapshot = await query.get();

      // Debug logging
      debugPrint('Found ${snapshot.docs.length} alt posts for user profile');

      // Convert to PostModel objects
      List<PostModel> posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      return posts;
    } catch (e, stackTrace) {
      debugPrint('Error getting alt profile posts: $e');
      debugPrint(stackTrace.toString());
      return []; // Return empty list on error
    }
  }

  /// Liking and Disliking Posts ///
  Future<void> likePost(
      {required String postId,
      required String userId,
      required bool isAlt}) async {
    try {
      // Call the Cloud Function to handle like/unlike
      if (isAlt) {
        // For alt posts, use the alt-specific Cloud Function
        await _functions.httpsCallable('handlePostInteraction').call({
          'postId': postId,
          'interactionType': 'like',
          'feedType': 'alt',
        });
      } else {
        // For public posts, use the regular Cloud Function
        await _functions.httpsCallable('handlePostInteraction').call({
          'postId': postId,
          'interactionType': 'like',
          'feedType': 'public',
        });
      }

      // Process result if needed
      debugPrint('Like operation completed via Cloud Function');
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Error in Cloud Function: ${error.message}');
      // Fall back to direct implementation if needed
      await _directLikePost(postId: postId, userId: userId);
    } catch (e) {
      debugPrint('Error liking post: $e');
      throw e;
    }
  }

  Future<void> dislikePost(
      {required String postId,
      required String userId,
      required bool isAlt}) async {
    try {
      if (isAlt) {
        // For alt posts, use the alt-specific Cloud Function
        await _functions.httpsCallable('handlePostInteraction').call({
          'postId': postId,
          'interactionType': 'dislike',
          'feedType': 'alt',
        });
      } else {
        // For public posts, use the regular Cloud Function
        await _functions.httpsCallable('handlePostInteraction').call({
          'postId': postId,
          'interactionType': 'dislike',
          'feedType': 'public',
        });
      }
      // Process result if needed
      debugPrint('Like operation completed via Cloud Function');
    } on FirebaseFunctionsException catch (error) {
      debugPrint('Error in Cloud Function: ${error.message}');
      // Fall back to direct implementation if needed
      await _directDislikePost(postId: postId, userId: userId);
    } catch (e) {
      debugPrint('Error liking post: $e');
      throw e;
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
      print("Error in likePost operation: $e");
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
}
