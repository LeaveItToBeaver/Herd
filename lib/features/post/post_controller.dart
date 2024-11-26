import 'dart:io';

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

  Future<void> createPost({
    required String userId,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      // Fetch user data
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception("User not found");
      }

      // Upload image if provided
      String? imageUrl;
      if (imageFile != null) {
        final postId = _postRepository.generatePostId();
        imageUrl = await _postRepository.uploadImage(
          imageFile,
          userId: userId,
          postId: postId,
        );
      }

      // Create the post model
      final post = PostModel(
        id: _postRepository.generatePostId(),
        authorId: user.id,
        username: user.username,
        content: content,
        title: title,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      // Save the post
      await _postRepository.createPost(post);

      // Update the state
      state = AsyncValue.data(
        CreatePostState(
          user: user,
          post: post,
          herdId: null, // Add herdId if applicable
          isImage: imageFile != null,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }
}

