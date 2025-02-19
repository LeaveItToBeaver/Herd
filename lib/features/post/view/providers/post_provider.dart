import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/post_controller.dart';
import 'package:herdapp/features/post/view/providers/state/create_post_state.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_notifier.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../../user/view/providers/current_user_provider.dart';
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

final postProvider = StreamProvider.family<PostModel?, String>((ref, postId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.streamPost(postId);
});

//Liking and disliking posts
final isPostLikedByUserProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id;

  if (userId == null) {
    return false; // Or handle it as needed, e.g., throw an error or return false
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostLikedByUser(postId: postId, userId: userId);
});

// Provider to check if a post is disliked by the current user
final isPostDislikedByUserProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id;

  if (userId == null) {
    return false; // Or handle it as needed
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostDislikedByUser(postId: postId, userId: userId);
});

final postInteractionsProvider = StateNotifierProvider.family<PostInteractionsNotifier, PostInteractionState,String>((ref, postId) {
  final repository = ref.watch(postRepositoryProvider);
  return PostInteractionsNotifier(
      repository: repository,
      ref: ref,
      postId: postId
  );
});