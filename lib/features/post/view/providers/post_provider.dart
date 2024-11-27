import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/post_controller.dart';
import 'package:herdapp/features/post/view/providers/state/create_post_state.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../data/models/post_model.dart';
import '../../data/repositories/post_repository.dart';

// Repository provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

// User posts provider
final userPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getUserPosts(userId);
});

// Creating a new post.
final postControllerProvider = StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);
  return CreatePostController(userRepository, postRepository);
});

final postProvider = FutureProvider.family<PostModel?, String>((ref, postId) async {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getPostById(postId);
});
