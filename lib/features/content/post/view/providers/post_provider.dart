import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

import 'package:herdapp/features/user/user_profile/utils/async_user_value_extension.dart';

// Repository provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

// User posts provider
final userPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getUserPosts(userId);
});

// Creating a new post provider
// final postControllerProvider =
//     StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>(
//         (ref) {
//   final userRepository = ref.watch(userRepositoryProvider);
//   final postRepository = ref.watch(postRepositoryProvider);
//   return CreatePostController(userRepository, postRepository);
// });

// Regular post provider - uses a plain String as parameter
final postProvider = StreamProvider.family<PostModel?, String>((ref, postId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.streamPost(postId);
});

// Enhanced post provider - can specify isAlt
// Use a class instead of a record for better compatibility
class PostParams {
  final String id;
  final bool isAlt;
  final String? herdId;

  PostParams({required this.id, required this.isAlt, this.herdId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostParams &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          isAlt == other.isAlt;

  @override
  int get hashCode => id.hashCode ^ isAlt.hashCode;
}

final postProviderWithPrivacy =
    StreamProvider.family<PostModel?, PostParams>((ref, params) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.streamPost(params.id, isAlt: params.isAlt);
});

final staticPostProvider =
    FutureProvider.family<PostModel?, PostParams>((ref, params) async {
  final repository = ref.watch(postRepositoryProvider);
  // Fetch the post data a single time
  return repository.getPostById(params.id, isAlt: params.isAlt);
});

// Providers for checking like/dislike status
final isPostLikedByUserProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final currentUserAsync = ref.read(currentUserProvider);
  final userId = currentUserAsync.userId;

  if (userId == null) {
    return false;
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostLikedByUser(postId: postId, userId: userId);
});

final isPostDislikedByUserProvider =
    FutureProvider.family<bool, String>((ref, postId) async {
  final currentUserAsync = ref.read(currentUserProvider);
  final userId = currentUserAsync.userId;

  if (userId == null) {
    return false;
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostDislikedByUser(postId: postId, userId: userId);
});

// Post interactions provider (original)
// final postInteractionsProvider = StateNotifierProvider.family<PostInteractionsNotifier, PostInteractionState, String>((ref, postId) {
//   final repository = ref.watch(postRepositoryProvider);
//   return PostInteractionsNotifier(
//     repository: repository,
//     postId: postId,
//   );
// });

// Post interactions provider with privacy setting
final postInteractionsWithPrivacyProvider = StateNotifierProvider.family<
    PostInteractionsNotifier, PostInteractionState, PostParams>((ref, params) {
  final repository = ref.watch(postRepositoryProvider);
  // Pass the full params if notifier needs herdId, otherwise just id/isAlt
  return PostInteractionsNotifier(
    repository: repository,
    postId: params.id,
    // Consider if the notifier needs isAlt directly or gets it from the post object later
  );
});
