import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/providers/state/create_post_state.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_notifier.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';

import '../herds/data/repositories/herd_repository.dart';
import '../user/view/providers/current_user_provider.dart';
import 'data/models/post_media_model.dart';
import 'data/models/post_model.dart';

class CreatePostController extends StateNotifier<AsyncValue<CreatePostState>> {
  final UserRepository _userRepository;
  final PostRepository _postRepository;

  CreatePostController(this._userRepository, this._postRepository)
      : super(AsyncValue.data(CreatePostState.initial()));

  Future<String> createPost({
    required String userId,
    required String title,
    required String content,
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
      postId = _postRepository.generatePostId();

      if (mediaFiles != null && mediaFiles.isNotEmpty) {
        debugPrint("Creating post with ${mediaFiles.length} media files");
        try {
          // Upload multiple media
          mediaItems = await _postRepository.uploadMultipleMediaFiles(
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
      );

      // 5. Save post to Firestore
      await _postRepository.createPost(post);

      if (herdId.isNotEmpty) {
        final herdRepository = HerdRepository(FirebaseFirestore.instance);
        await herdRepository.addPostToHerd(herdId, post, userId);
      }

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
    print('Alt posts count: ${altPosts.length}');
    for (var post in altPosts) {
      print('Post ID: ${post.id}, isAlt: ${post.isAlt}');
    }
  }

  void reset() {
    state = AsyncValue.data(CreatePostState.initial());
  }
}

// Provider for post controller
final postControllerProvider =
    StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>(
        (ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);
  return CreatePostController(userRepository, postRepository);
});

// Provider for user posts with privacy filter
final userPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getUserPosts(userId);
});

// Provider for user's public posts only
final userPublicPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return await postRepository.getFutureUserPublicPosts(userId);
});

// Provider for user's alt posts only
final userAltPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  return await postRepository.getFutureUserAltProfilePosts(userId);
});

// Provider for a single post
final postProvider = StreamProvider.family<PostModel?, String>((ref, postId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.streamPost(postId);
});

// Provider to check if post is liked by current user
final isPostLikedByUserProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final user = ref.read(currentUserProvider);
  final userId = user.userId;
  if (userId == null) return false;
  return postRepository.isPostLikedByUser(postId: postId, userId: userId);
});

// Provider to check if post is disliked by current user
final isPostDislikedByUserProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final user = ref.read(currentUserProvider);
  final userId = user.userId;
  if (userId == null) return false;
  return postRepository.isPostDislikedByUser(postId: postId, userId: userId);
});

// Provider for post interactions
final postInteractionsProvider = StateNotifierProvider.family<
    PostInteractionsNotifier, PostInteractionState, String>(
  (ref, postId) {
    final repository = ref.watch(postRepositoryProvider);
    return PostInteractionsNotifier(
      repository: repository,
      postId: postId,
    );
  },
);
