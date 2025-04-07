import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/providers/state/create_post_state.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_notifier.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import '../../../comment/data/repositories/comment_repository.dart';
import '../../../comment/view/providers/comment_providers.dart';
import '../../../comment/view/providers/state/comment_state.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../user/data/repositories/user_repository.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../../data/repositories/post_repository.dart';
import '../../post_controller.dart';

// Repository provider
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepository();
});

// User posts provider
final userPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.getUserPosts(userId);
});

// Creating a new post provider
final postControllerProvider = StateNotifierProvider<CreatePostController, AsyncValue<CreatePostState>>((ref) {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);
  return CreatePostController(userRepository, postRepository);
});

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

  PostParams({required this.id, required this.isAlt});

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
final postProviderWithPrivacy = StreamProvider.family<PostModel?, PostParams>((ref, params) {
  final repository = ref.watch(postRepositoryProvider);
  return repository.streamPost(params.id, isAlt: params.isAlt);
});

// Providers for checking like/dislike status
final isPostLikedByUserProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id;

  if (userId == null) {
    return false;
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostLikedByUser(postId: postId, userId: userId);
});

final isPostDislikedByUserProvider = FutureProvider.family<bool, String>((ref, postId) async {
  final user = ref.watch(currentUserProvider);
  final userId = user?.id;

  if (userId == null) {
    return false;
  }

  final repository = ref.watch(postRepositoryProvider);
  return repository.isPostDislikedByUser(postId: postId, userId: userId);
});

// Post interactions provider (original)
final postInteractionsProvider = StateNotifierProvider.family<PostInteractionsNotifier, PostInteractionState, String>((ref, postId) {
  final repository = ref.watch(postRepositoryProvider);
  return PostInteractionsNotifier(
    repository: repository,
    postId: postId,
  );
});

final commentsProvider = StateNotifierProvider.family<CommentsNotifier, CommentState, String>((ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  final sortBy = ref.watch(commentSortProvider);
  return CommentsNotifier(repository, postId, sortBy);
});

// Post interactions provider with privacy setting
final postInteractionsWithPrivacyProvider = StateNotifierProvider.family<
    PostInteractionsNotifier, PostInteractionState, PostParams>((ref, params) {
  final repository = ref.watch(postRepositoryProvider);
  return PostInteractionsNotifier(
    repository: repository,
    postId: params.id,
  );
});

final userPostsWithHerdsProvider = StreamProvider.family<List<PostModel>, String>((ref, userId) async* {
  final postRepository = ref.watch(postRepositoryProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  // Get regular user posts
  Stream<List<PostModel>> regularPosts = postRepository.getUserPosts(userId);

  // Stream combined results
  await for (final posts in regularPosts) {
    // Get user's herds
    final userHerds = await herdRepository.getUserHerds(userId);
    List<PostModel> allPosts = List.from(posts);

    // For each herd, get posts by this user
    for (final herd in userHerds) {
      final herdPosts = await herdRepository.getHerdPosts(
          herdId: herd.id,
          limit: 50
      );

      // Filter for posts by this user
      final userHerdPosts = herdPosts.where((post) => post.authorId == userId).toList();
      allPosts.addAll(userHerdPosts);
    }

    // Sort all posts by date
    allPosts.sort((a, b) => (b.createdAt ?? DateTime.now())
        .compareTo(a.createdAt ?? DateTime.now()));

    yield allPosts;
  }
});