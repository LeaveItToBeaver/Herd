import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:herdapp/features/community/herds/data/repositories/herd_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_media_model.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

part 'create_post_controller.g.dart';

@riverpod
class CreatePostController extends _$CreatePostController {
  @override
  AsyncValue<CreatePostState> build() {
    return AsyncValue.data(CreatePostState.initial());
  }

  Future<String> createPost({
    required String userId,
    required String title,
    required String content,
    List<Map<String, dynamic>>? processedMedia,
    List<File>? mediaFiles,
    bool isAlt = false,
    bool isNSFW = false,
    String herdId = '',
    String herdName = '',
    String herdProfileImageURL = '',
    List<String>? mentions, // Add mentions parameter
    List<String>? tags,
  }) async {
    String? postId;
    List<PostMediaModel> mediaItems = [];

    try {
      state = const AsyncValue.loading();

      final userRepository = ref.read(userRepositoryProvider);
      final createPostRepository = ref.read(createPostRepositoryProvider);
      final postRepository = ref.read(postRepositoryProvider);

      final user = await userRepository.getUserById(userId);

      if (!ref.mounted) return '';

      if (user == null) throw Exception("User not found");

      postId = createPostRepository.generatePostId();

      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        debugPrint("Creating post with ${mediaFiles.length} media files");
        try {
          // Upload multiple media
          mediaItems = await createPostRepository.uploadMultipleMediaFiles(
            mediaFiles: mediaFiles,
            postId: postId,
            userId: userId,
            isAlt: isAlt,
          );

          if (!ref.mounted) return postId;

          debugPrint("Uploaded ${mediaItems.length} media items");
          for (var item in mediaItems) {
            debugPrint(
                "Media item: id=${item.id}, url=${item.url}, type=${item.mediaType}");
          }
        } catch (e) {
          debugPrint('Warning: Failed to upload media: $e');
        }
      }

      // Get the first media item for backward compatibility
      String? imageUrl;
      String? thumbnailUrl;
      String? mediaType;

      if (mediaItems.isNotEmpty) {
        imageUrl = mediaItems[0].url;
        thumbnailUrl = mediaItems[0].thumbnailUrl;
        mediaType = mediaItems[0].mediaType;
      }

      final post = PostModel(
        id: postId,
        authorId: user.id,
        authorUsername: user.username,
        authorName: (user.firstName + user.lastName),
        authorProfileImageURL: isAlt
            ? (user.altProfileImageURL ?? user.profileImageURL)
            : user.profileImageURL,
        content: content,
        herdId: herdId.isNotEmpty ? herdId : null,
        herdName: herdId.isNotEmpty ? herdName : null,
        herdProfileImageURL: herdId.isNotEmpty ? herdProfileImageURL : null,
        title: title,
        mediaItems: mediaItems,
        mediaURL: imageUrl,
        mediaThumbnailURL: thumbnailUrl,
        mediaType: mediaType,
        likeCount: 0,
        dislikeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isAlt: isAlt,
        isNSFW: isNSFW,
        isRichText: true,
        tags: tags ?? [],
        mentions: mentions ?? [],
      );
      await createPostRepository.createPost(
        post,
        mentions: mentions,
      );

      if (!ref.mounted) return postId;

      if (herdId.isNotEmpty) {
        final herdRepository = HerdRepository(FirebaseFirestore.instance);
        await herdRepository.addPostToHerd(herdId, post, userId);

        if (!ref.mounted) return postId;

        await _waitForAltPostCreation(postId);
      }

      if (!ref.mounted) return postId;

      await postRepository.likePost(
        postId: postId,
        userId: userId,
        isAlt: isAlt,
        feedType: herdId.isNotEmpty ? 'herd' : (isAlt ? 'alt' : 'public'),
        herdId: herdId.isNotEmpty ? herdId : null,
      );

      if (!ref.mounted) return postId;

      state = AsyncValue.data(CreatePostState(
        user: user,
        post: post,
        isLoading: false,
      ));

      return postId;
    } catch (e, stackTrace) {
      if (!ref.mounted) return postId ?? '';

      state = AsyncValue.error(e, stackTrace);

      // Log error for debugging
      debugPrint('Error creating post: $e');
      debugPrint('Stack trace: $stackTrace');

      // If we have a postId, try to clean up any partially created resources
      if (postId != null) {
        try {
          await _cleanupFailedPost(postId, userId, isAlt);
        } catch (cleanupError) {
          debugPrint('Warning: Failed to cleanup failed post: $cleanupError');
        }
      }

      rethrow;
    }
  }

  Future<void> _waitForAltPostCreation(String postId) async {
    const maxAttempts = 20; // Maximum 10 seconds (20 * 500ms)
    const retryInterval = Duration(milliseconds: 500);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        final altPostDoc = await FirebaseFirestore.instance
            .collection('altPosts')
            .doc(postId)
            .get();

        if (altPostDoc.exists) {
          debugPrint('altPosts document created after ${attempt * 500}ms');
          return;
        }

        if (attempt < maxAttempts - 1) {
          await Future.delayed(retryInterval);
        }
      } catch (e) {
        debugPrint('Error checking altPosts document: $e');
        if (attempt < maxAttempts - 1) {
          await Future.delayed(retryInterval);
        }
      }
    }

    throw Exception('Timeout waiting for altPosts document to be created');
  }

  Future<void> _cleanupFailedPost(
      String postId, String userId, bool isAlt) async {
    try {
      final postRepository = ref.read(postRepositoryProvider);

      // Try to delete the post document if it was created
      await postRepository.deletePost(postId, userId, isAlt: isAlt);

      // Try to delete any uploaded images
      final String basePath = isAlt
          ? 'users/$userId/alt/posts/$postId'
          : 'users/$userId/posts/$postId';

      // List all files in the post directory
      final storageRef = FirebaseStorage.instance.ref().child(basePath);
      try {
        final listResult = await storageRef.listAll();

        // Delete all files in this directory
        for (var item in listResult.items) {
          await item.delete();
        }

        // Also attempt to delete any subdirectories
        for (var prefix in listResult.prefixes) {
          final subListResult = await prefix.listAll();
          for (var item in subListResult.items) {
            await item.delete();
          }
        }
      } catch (e) {
        // Ignore errors if files don't exist
        debugPrint('Warning during cleanup: $e');
      }
    } catch (e) {
      debugPrint('Warning: Cleanup of failed post encountered errors: $e');
    }
  }

  Future<void> deletePost(String postId, String userId,
      {bool isAlt = false, String? herdId}) async {
    try {
      final postRepository = ref.read(postRepositoryProvider);
      await postRepository.deletePost(postId, userId,
          isAlt: isAlt, herdId: herdId);
    } catch (e) {
      debugPrint('Error in delete post controller: $e');
      rethrow;
    }
  }

  Future<void> updatePost({
    required String postId,
    required String userId,
    String? title,
    String? content,
    bool? isAlt,
    bool? isNSFW,
    String? herdId,
  }) async {
    try {
      final postRepository = ref.read(postRepositoryProvider);
      await postRepository.updatePost(
        postId: postId,
        userId: userId,
        title: title,
        content: content,
        isAlt: isAlt,
        isNSFW: isNSFW,
        herdId: herdId,
      );
    } catch (e) {
      debugPrint('Error in update post controller: $e');
      rethrow;
    }
  }

  void debugAltPosts(String userId) async {
    final postRepository = ref.read(postRepositoryProvider);
    final altPosts = await postRepository.getFutureUserPublicPosts(userId);
    debugPrint('Alt posts count: ${altPosts.length}');
    for (var post in altPosts) {
      debugPrint('Post ID: ${post.id}, isAlt: ${post.isAlt}');
    }
  }

  void reset() {
    state = AsyncValue.data(CreatePostState.initial());
  }
}
