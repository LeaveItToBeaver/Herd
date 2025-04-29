import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_notifier.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';

import '../user/view/providers/current_user_provider.dart';
import 'data/models/post_model.dart';

// Provider for post controller
// final postControllerProvider =
//     StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>(
//         (ref) {
//   final userRepository = ref.watch(userRepositoryProvider);
//   final postRepository = ref.watch(postRepositoryProvider);
//   return CreatePostController(userRepository, postRepository);
// });

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
