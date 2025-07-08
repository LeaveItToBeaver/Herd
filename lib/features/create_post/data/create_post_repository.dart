import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
//import 'package:herdapp/features/rich_text_editing/models/user_mention_embed.dart';
import 'package:path/path.dart' as path;

import '../../../core/services/image_helper.dart';
import '../../post/data/models/post_media_model.dart';
import '../../post/data/models/post_model.dart';

class CreatePostRepostiory {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Collection references
  // CollectionReference<Map<String, dynamic>> get _posts =>
  //     _firestore.collection('posts');
  // CollectionReference<Map<String, dynamic>> get _globalAltPosts =>
  //     _firestore.collection('altPosts');
  // CollectionReference<Map<String, dynamic>> get _comments =>
  //     _firestore.collection('comments');
  // CollectionReference<Map<String, dynamic>> get _likes =>
  //     _firestore.collection('likes');
  // CollectionReference<Map<String, dynamic>> get _dislikes =>
  //     _firestore.collection('dislikes');

  Future<void> createPost(PostModel post,
      {List<File>? mediaFiles, List<String>? mentions}) async {
    try {
      // Generate post ID if needed
      String postId =
          post.id.isEmpty ? _firestore.collection('posts').doc().id : post.id;

      // Enhanced debugging
      debugPrint(
          "🔍 CREATE POST START - ID: $postId with ${mediaFiles?.length ?? 0} media files");
      debugPrint(
          "🔍 Post has ${mentions?.length ?? 0} mentions: ${mentions?.join(', ') ?? 'none'}");

      List<PostMediaModel> mediaItems = [];
      debugPrint("🔍 Initialized empty mediaItems array");

      // Upload multiple media files if provided (existing code)
      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        // ... existing media upload code ...
      }

      // Set the feedType alt/public/herd
      final feedType =
          post.isAlt ? 'alt' : (post.herdId != null ? 'herd' : 'public');

      // Create a map to update Firestore
      final Map<String, dynamic> postData = post.toMap();

      // Ensure mentions are included in postData
      postData['mentions'] = mentions ?? [];

      // Important: Make sure mediaItems is explicitly set in the map
      postData['mediaItems'] = mediaItems.map((item) => item.toMap()).toList();

      // For backward compatibility, set the first image URL as the mediaURL
      if (mediaItems.isNotEmpty) {
        postData['mediaURL'] = mediaItems.first.url;
        postData['mediaThumbnailURL'] = mediaItems.first.thumbnailUrl;
        postData['mediaType'] = mediaItems.first.mediaType;
      }

      postData['id'] = postId;
      postData['feedType'] = feedType;
      postData['isRichText'] = post.isRichText;

      // Use a batch write to ensure atomic operations
      final batch = _firestore.batch();

      // Determine where to save the post
      DocumentReference postRef;
      if (post.isAlt) {
        // Save to altPosts collection
        postRef = _firestore.collection('altPosts').doc(postId);
        batch.set(postRef, postData);
        debugPrint('Alt post created with ID: $postId');
      } else if (post.herdId != null && post.herdId!.isNotEmpty) {
        // Save to herdPosts collection
        postRef = _firestore
            .collection('herdPosts')
            .doc(post.herdId)
            .collection('posts')
            .doc(postId);
        batch.set(postRef, postData);
        debugPrint(
            'Herd post created with ID: $postId in herd: ${post.herdId}');
      } else {
        // Save to regular posts collection
        postRef = _firestore.collection('posts').doc(postId);
        batch.set(postRef, postData);
        debugPrint('Public post created with ID: $postId');
      }

      // Create mention documents if there are any mentions
      if (mentions != null && mentions.isNotEmpty) {
        // Create mentions in a subcollection under the post
        for (final mentionedUserId in mentions) {
          final mentionRef = _firestore
              .collection('mentions')
              .doc(postId)
              .collection('postMentions')
              .doc(mentionedUserId);

          batch.set(mentionRef, {
            'postId': postId,
            'authorId': post.authorId,
            'authorUsername': post.authorUsername,
            'authorName': post.authorName,
            'mentionedUserId': mentionedUserId,
            'postTitle': post.title,
            'postPreview':
                _getPostPreview(post.content), // Extract preview from content
            'isAlt': post.isAlt,
            'herdId': post.herdId,
            'herdName': post.herdName,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'feedType': feedType,
          });

          debugPrint("🔍 Created mention document for user: $mentionedUserId");
        }

        // Also create a user-centric mention for easy querying
        for (final mentionedUserId in mentions) {
          final userMentionRef = _firestore
              .collection('userMentions')
              .doc(mentionedUserId)
              .collection('mentions')
              .doc(postId);

          batch.set(userMentionRef, {
            'postId': postId,
            'authorId': post.authorId,
            'authorUsername': post.authorUsername,
            'authorName': post.authorName,
            'postTitle': post.title,
            'postPreview': _getPostPreview(post.content),
            'isAlt': post.isAlt,
            'herdId': post.herdId,
            'herdName': post.herdName,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false,
            'feedType': feedType,
          });
        }
      }

      // Commit the batch
      await batch.commit();

      debugPrint(
          "✅ Post created successfully with ${mediaItems.length} media items and ${mentions?.length ?? 0} mentions");
    } catch (e) {
      debugPrint("❌ ERROR creating post: $e");
      rethrow;
    }
  }

// Helper method to extract a preview from rich text content
  String _getPostPreview(String richTextContent, {int maxLength = 100}) {
    try {
      // Try to parse the rich text and extract plain text
      final decoded = jsonDecode(richTextContent);
      if (decoded is List) {
        final buffer = StringBuffer();
        for (final op in decoded) {
          if (op['insert'] is String) {
            buffer.write(op['insert']);
          }
        }
        final plainText = buffer.toString().trim();
        if (plainText.length > maxLength) {
          return '${plainText.substring(0, maxLength)}...';
        }
        return plainText;
      }
    } catch (e) {
      debugPrint('Error extracting post preview: $e');
    }
    return richTextContent.length > maxLength
        ? '${richTextContent.substring(0, maxLength)}...'
        : richTextContent;
  }

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
        // final extension = path.extension(file.path).toLowerCase();
        String mediaType;

        if (ImageHelper.isImage(file)) {
          mediaType = ImageHelper.isGif(file) ? 'gif' : 'image';
        } else if (ImageHelper.isVideo(file)) {
          mediaType = 'video';
        } else {
          mediaType = 'other';
        }

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

  Future<List<PostMediaModel>> uploadProcessedMediaFiles({
    required List<Map<String, dynamic>> processedMedia,
    required String postId,
    required String userId,
    required bool isAlt,
  }) async {
    List<PostMediaModel> mediaItems = [];

    for (var mediaData in processedMedia) {
      File file = mediaData['file'];
      String mediaType = mediaData['mediaType'];
      int index = mediaData['index'] ?? 0;
      String? thumbnailUrl;

      // Generate path based on privacy
      final String basePath = isAlt
          ? 'users/$userId/alt/posts/$postId'
          : 'users/$userId/posts/$postId';

      // Upload the main media file
      final String fileName = '$index-${path.basename(file.path)}';
      final String mediaPath = '$basePath/$fileName';

      final mainRef = _storage.ref().child(mediaPath);

      // Set appropriate content type
      final extension = path.extension(file.path).toLowerCase();
      final contentType = _getContentType(extension);

      final SettableMetadata metadata = SettableMetadata(
        contentType: contentType,
        customMetadata: {
          'isAlt': isAlt.toString(),
          'mediaType': mediaType,
        },
      );

      final uploadTask = mainRef.putFile(file, metadata);
      final snapshot = await uploadTask;
      final String mainUrl = await snapshot.ref.getDownloadURL();

      // For videos, upload the thumbnail too
      if (mediaType == 'video' && mediaData['thumbnailFile'] != null) {
        final File thumbnailFile = mediaData['thumbnailFile'];
        final String thumbName = '$index-thumbnail.jpg';
        final String thumbPath = '$basePath/$thumbName';

        final thumbRef = _storage.ref().child(thumbPath);
        final thumbMetadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'isAlt': isAlt.toString(),
            'mediaType': 'thumbnail',
            'for': mediaType,
          },
        );

        final thumbUploadTask = thumbRef.putFile(thumbnailFile, thumbMetadata);
        final thumbSnapshot = await thumbUploadTask;
        thumbnailUrl = await thumbSnapshot.ref.getDownloadURL();
      }

      // Add to media items
      mediaItems.add(PostMediaModel(
        id: index.toString(),
        url: mainUrl,
        thumbnailUrl: thumbnailUrl,
        mediaType: mediaType,
      ));
    }

    return mediaItems;
  }
}
