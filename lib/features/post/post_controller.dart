import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/providers/state/create_post_state.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
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
  }) async {
    String? postId;
    String? imageUrl;

    try {
      state = const AsyncValue.loading();

      // 1. Validate user first
      final user = await _userRepository.getUserById(userId);
      if (user == null) throw Exception("User not found");

      // 2. Generate post ID
      postId = _postRepository.generatePostId();

      // 3. Try to upload image if present
      if (imageFile != null) {
        try {
          imageUrl = await _postRepository.uploadImage(
            imageFile,
            postId: postId,
            userId: userId,
            file: imageFile,
            type: 'post',
          );
        } catch (e) {
          // Log error but continue with post creation
          print('Warning: Failed to upload image: $e');
          // imageUrl will remain null
        }
      }

      // 4. Create post model
      final post = PostModel(
        id: postId,
        authorId: user.id,
        username: user.username ?? 'Anonymous',
        profileImageURL: user.profileImageURL,
        content: content,
        title: title,
        imageUrl: imageUrl, // This might be null if upload failed
        likeCount: 0,
        dislikeCount: 0,
        commentCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 5. Save post to Firestore
      await _postRepository.createPost(post);

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
          await _cleanupFailedPost(postId, userId);
        } catch (cleanupError) {
          print('Warning: Failed to cleanup failed post: $cleanupError');
        }
      }

      rethrow;
    }
  }

  Future<void> _cleanupFailedPost(String postId, String userId) async {
    try {
      // Try to delete the post document if it was created
      await _postRepository.deletePost(postId);

      // Try to delete any uploaded images
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('users/$userId/posts/$postId');
      try {
        await storageRef.delete();
      } catch (e) {
        // Ignore errors if the image doesn't exist
      }
    } catch (e) {
      print('Warning: Cleanup of failed post encountered errors: $e');
    }
  }

  void reset() {
    state = AsyncValue.data(CreatePostState.initial());
  }
}