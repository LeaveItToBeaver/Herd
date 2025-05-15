import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/create_post/data/create_post_repository.dart';
import 'package:herdapp/features/create_post/view/providers/create_post_provider.dart';

import '../herds/data/repositories/herd_repository.dart';
import '../post/data/models/post_media_model.dart';
import '../post/data/models/post_model.dart';

class CreatePostController extends StateNotifier<AsyncValue<CreatePostState>> {
  final UserRepository _userRepository;
  final CreatePostRepostiory _createPostRepository;
  final PostRepository _postRepository;

  CreatePostController(
      this._userRepository, this._postRepository, this._createPostRepository)
      : super(AsyncValue.data(CreatePostState.initial()));

  Future<String> createPost({
    required String userId,
    required String title,
    required String content,
    List<Map<String, dynamic>>? processedMedia,
    List<File>? mediaFiles,
    bool isAlt = false,
    bool isNSFW = false, // Added NSFW parameter
    String herdId = '',
    String herdName = '',
    String herdProfileImageURL = '',
  }) async {
    String? postId;
    List<PostMediaModel> mediaItems = [];

    try {
      state = const AsyncValue.loading();

      // 1. Validate user first
      final user = await _userRepository.getUserById(userId);
      if (user == null) throw Exception("User not found");

      // 2. Generate post ID
      postId = _createPostRepository.generatePostId();

      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        debugPrint("Creating post with ${mediaFiles.length} media files");
        try {
          // Upload multiple media
          mediaItems = await _createPostRepository.uploadMultipleMediaFiles(
            mediaFiles: mediaFiles,
            postId: postId,
            userId: userId,
            isAlt: isAlt,
          );

          debugPrint("Uploaded ${mediaItems.length} media items");
          for (var item in mediaItems) {
            debugPrint(
                "Media item: id=${item.id}, url=${item.url}, type=${item.mediaType}");
          }
        } catch (e) {
          // Log error but continue with post creation
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

      // 4. Create post model with all fields
      final post = PostModel(
        id: postId,
        authorId: user.id,
        authorUsername: user.username ?? 'Anonymous',
        authorName: (user.firstName + user.lastName) ?? 'Anonymous',
        authorProfileImageURL: isAlt
            ? (user.altProfileImageURL ?? user.profileImageURL)
            : user.profileImageURL,
        content: content,
        herdId: herdId.isNotEmpty ? herdId : null,
        herdName: herdId.isNotEmpty ? herdName : null,
        herdProfileImageURL: herdId.isNotEmpty ? herdProfileImageURL : null,
        title: title,
        // Include both mediaItems and legacy fields for compatibility
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
        isNSFW: isNSFW, // Set the NSFW flag
        isRichText: true,
        tags: [],
      );

      // 5. Save post to Firestore
      await _createPostRepository.createPost(post);

      if (herdId.isNotEmpty) {
        final herdRepository = HerdRepository(FirebaseFirestore.instance);
        await herdRepository.addPostToHerd(herdId, post, userId);
      }

      // Automatically like the post
      await _postRepository.likePost(
          postId: postId, userId: userId, isAlt: isAlt);

      // 6. Update state with success
      state = AsyncValue.data(CreatePostState(
        user: user,
        post: post,
        isLoading: false,
      ));

      return postId;
    } catch (e, stackTrace) {
      // Update state with error
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

  Future<void> _cleanupFailedPost(
      String postId, String userId, bool isAlt) async {
    try {
      // Try to delete the post document if it was created
      await _postRepository.deletePost(postId, userId, isAlt: isAlt);

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
      await _postRepository.deletePost(postId, userId,
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
      await _postRepository.updatePost(
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
    final altPosts = await _postRepository.getFutureUserPublicPosts(userId);
    debugPrint('Alt posts count: ${altPosts.length}');
    for (var post in altPosts) {
      debugPrint('Post ID: ${post.id}, isAlt: ${post.isAlt}');
    }
  }

  void reset() {
    state = AsyncValue.data(CreatePostState.initial());
  }
}

final postControllerProvider =
    StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>(
        (ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);
  final createPostRepository = ref.watch(createPostRepositoryProvider);

  return CreatePostController(
      userRepository, postRepository, createPostRepository);
});
