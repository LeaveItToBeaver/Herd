import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/providers/state/create_post_state.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_notifier.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
import '../herds/data/repositories/herd_repository.dart';
import '../user/view/providers/current_user_provider.dart';
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
    File? imageFile,
    bool isAlt = false,
    String herdId = '',
  }) async {
    String? postId;
    String? imageUrl;
    String? thumbnailUrl;
    String? mediaType;

    try {
      state = const AsyncValue.loading();

      // 1. Validate user first
      final user = await _userRepository.getUserById(userId);
      if (user == null) throw Exception("User not found");

      // 2. Generate post ID
      postId = _postRepository.generatePostId();

      // 3. Try to upload media if present
      if (imageFile != null) {
        try {
          // Use the new uploadMedia method to get both image URLs
          final mediaUrls = await _postRepository.uploadMedia(
            mediaFile: imageFile,
            postId: postId,
            userId: userId,
            isAlt: isAlt,
          );

          imageUrl = mediaUrls['imageUrl'];
          thumbnailUrl = mediaUrls['thumbnailUrl'];
          mediaType = mediaUrls['mediaType'];
        } catch (e) {
          // Log error but continue with post creation
          print('Warning: Failed to upload media: $e');
          // URLs will remain null
        }
      }

      // 4. Create post model with the new fields
      final post = PostModel(
        id: postId,
        authorId: user.id,
        username: user.username ?? 'Anonymous',
        // Use appropriate profile image based on privacy setting
        profileImageURL: isAlt
            ? (user.altProfileImageURL ?? user.profileImageURL)
            : user.profileImageURL,
        content: content,
        herdId: herdId.isNotEmpty ? herdId : null, // Add this line
        title: title,
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        mediaType: mediaType,
        likeCount: 0,
        dislikeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isAlt: isAlt,
      );

      // 5. Save post to Firestore
      await _postRepository.createPost(post);

      if (herdId.isNotEmpty) {
        final herdRepository = HerdRepository(FirebaseFirestore.instance); // Or use dependency injection
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
      print('Error creating post: $e');
      print('Stack trace: $stackTrace');

      // If we have a postId, try to clean up any partially created resources
      if (postId != null) {
        try {
          await _cleanupFailedPost(postId, userId, isAlt);
        } catch (cleanupError) {
          print('Warning: Failed to cleanup failed post: $cleanupError');
        }
      }

      rethrow;
    }
  }

  Future<void> _cleanupFailedPost(String postId, String userId, bool isAlt) async {
    try {
      // Try to delete the post document if it was created
      await _postRepository.deletePost(postId);

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
        print('Warning during cleanup: $e');
      }
    } catch (e) {
      print('Warning: Cleanup of failed post encountered errors: $e');
    }
  }

  void reset() {
    state = AsyncValue.data(CreatePostState.initial());
  }
}

// Provider for post controller
final postControllerProvider = StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);
  return CreatePostController(userRepository, postRepository);
});
// Provider for user posts with privacy filter
final userPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getUserPosts(userId);
});

// Provider for user's public posts only
final userPublicPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getUserPublicPosts(userId);
});

// Provider for user's alt posts only
final userAltPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.getUserAltPosts(userId);
});

// Provider for a single post
final postProvider = StreamProvider.family<PostModel?, String>((ref, postId) {
  final postRepository = ref.watch(postRepositoryProvider);
  return postRepository.streamPost(postId);
});

// Provider to check if post is liked by current user
final isPostLikedByUserProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final userId = ref.read(currentUserProvider)?.id;
  if (userId == null) return false;
  return postRepository.isPostLikedByUser(postId: postId, userId: userId);
});

// Provider to check if post is disliked by current user
final isPostDislikedByUserProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final postRepository = ref.watch(postRepositoryProvider);
  final userId = ref.read(currentUserProvider)?.id;
  if (userId == null) return false;
  return postRepository.isPostDislikedByUser(postId: postId, userId: userId);
});

// Provider for post interactions
final postInteractionsProvider = StateNotifierProvider.family<PostInteractionsNotifier, PostInteractionState, String>(
      (ref, postId) {
    final repository = ref.watch(postRepositoryProvider);
    return PostInteractionsNotifier(
      repository: repository,
      ref: ref,
      postId: postId,
    );
  },
);