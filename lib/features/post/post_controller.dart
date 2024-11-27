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

  Future<String> createPost({
    required String userId,
    required String title,
    required String content,
    File? imageFile,
  }) async {
    try {
      state = const AsyncValue.loading();

      final user = await _userRepository.getUserById(userId);
      if (user == null) throw Exception("User not found");

      String? imageUrl;
      final postId = _postRepository.generatePostId(); // Generate the post ID upfront

      if (imageFile != null) {
        imageUrl = await _postRepository.uploadImage(
          imageFile,
          userId: userId,
          postId: postId,
        );
      }

      final post = PostModel(
        id: postId,
        authorId: user.id,
        username: user.username,
        content: content,
        title: title,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _postRepository.createPost(post);

      state = AsyncValue.data(CreatePostState(
        user: user,
        post: post,
        isLoading: false,
      ));

      return postId; // Return the created post's ID
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow; // Propagate the error for handling in the UI
    }
  }
}

