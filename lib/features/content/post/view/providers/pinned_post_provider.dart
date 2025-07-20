import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

// Provider for user's pinned posts (public profile)
final userPinnedPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);

  try {
    // Get pinned post IDs
    final pinnedPostIds =
        await userRepository.getPinnedPosts(userId, isAlt: false);
    if (pinnedPostIds.isEmpty) return [];

    // Fetch each pinned post
    List<PostModel> pinnedPosts = [];
    for (final postId in pinnedPostIds) {
      try {
        final post = await postRepository.getPostById(postId, isAlt: false);
        if (post != null) {
          pinnedPosts.add(post);
        }
      } catch (e) {
        // Continue with other posts if one fails
        continue;
      }
    }

    // Sort by pinned date (most recently pinned first)
    pinnedPosts.sort((a, b) {
      if (a.pinnedAt == null && b.pinnedAt == null) return 0;
      if (a.pinnedAt == null) return 1;
      if (b.pinnedAt == null) return -1;
      return b.pinnedAt!.compareTo(a.pinnedAt!);
    });

    return pinnedPosts;
  } catch (e) {
    throw Exception('Failed to load pinned posts: $e');
  }
});

// Provider for user's alt pinned posts
final userAltPinnedPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, userId) async {
  final userRepository = ref.watch(userRepositoryProvider);
  final postRepository = ref.watch(postRepositoryProvider);

  try {
    // Get pinned post IDs
    final pinnedPostIds =
        await userRepository.getPinnedPosts(userId, isAlt: true);
    if (pinnedPostIds.isEmpty) return [];

    // Fetch each pinned post
    List<PostModel> pinnedPosts = [];
    for (final postId in pinnedPostIds) {
      try {
        final post = await postRepository.getPostById(postId, isAlt: true);
        if (post != null) {
          pinnedPosts.add(post);
        }
      } catch (e) {
        // Continue with other posts if one fails
        continue;
      }
    }

    // Sort by pinned date (most recently pinned first)
    pinnedPosts.sort((a, b) {
      if (a.pinnedAt == null && b.pinnedAt == null) return 0;
      if (a.pinnedAt == null) return 1;
      if (b.pinnedAt == null) return -1;
      return b.pinnedAt!.compareTo(a.pinnedAt!);
    });

    return pinnedPosts;
  } catch (e) {
    throw Exception('Failed to load alt pinned posts: $e');
  }
});

// Provider for herd's pinned posts
final herdPinnedPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, herdId) async {
  final herdRepository = ref.watch(herdRepositoryProvider);

  try {
    return await herdRepository.fetchHerdPinnedPosts(herdId);
  } catch (e) {
    throw Exception('Failed to load herd pinned posts: $e');
  }
});

// Provider to check if a post is pinned to user profile
final isPostPinnedToProfileProvider =
    FutureProvider.family<bool, ({String userId, String postId, bool isAlt})>(
        (ref, params) async {
  final userRepository = ref.watch(userRepositoryProvider);

  try {
    return await userRepository.isPostPinnedToProfile(
      params.userId,
      params.postId,
      isAlt: params.isAlt,
    );
  } catch (e) {
    return false;
  }
});

// Provider to check if a post is pinned to herd
final isPostPinnedToHerdProvider =
    FutureProvider.family<bool, ({String herdId, String postId})>(
        (ref, params) async {
  final herdRepository = ref.watch(herdRepositoryProvider);

  try {
    return await herdRepository.isPostPinnedToHerd(
        params.herdId, params.postId);
  } catch (e) {
    return false;
  }
});

// Controller for managing pin/unpin actions
class PinnedPostsController {
  final Ref ref;

  PinnedPostsController(this.ref);

  // Pin post to user profile
  Future<void> pinToProfile(String userId, String postId,
      {bool isAlt = false}) async {
    final userRepository = ref.read(userRepositoryProvider);

    try {
      await userRepository.pinPostToProfile(userId, postId, isAlt: isAlt);

      // Invalidate relevant providers to refresh UI
      if (isAlt) {
        ref.invalidate(userAltPinnedPostsProvider(userId));
      } else {
        ref.invalidate(userPinnedPostsProvider(userId));
      }

      ref.invalidate(isPostPinnedToProfileProvider(
          (userId: userId, postId: postId, isAlt: isAlt)));
    } catch (e) {
      rethrow;
    }
  }

  // Unpin post from user profile
  Future<void> unpinFromProfile(String userId, String postId,
      {bool isAlt = false}) async {
    final userRepository = ref.read(userRepositoryProvider);

    try {
      await userRepository.unpinPostFromProfile(userId, postId, isAlt: isAlt);

      // Invalidate relevant providers to refresh UI
      if (isAlt) {
        ref.invalidate(userAltPinnedPostsProvider(userId));
      } else {
        ref.invalidate(userPinnedPostsProvider(userId));
      }

      ref.invalidate(isPostPinnedToProfileProvider(
          (userId: userId, postId: postId, isAlt: isAlt)));
    } catch (e) {
      rethrow;
    }
  }

  // Pin post to herd
  Future<void> pinToHerd(String herdId, String postId, String userId) async {
    final herdRepository = ref.read(herdRepositoryProvider);

    try {
      await herdRepository.pinPostToHerd(herdId, postId, userId);

      // Invalidate relevant providers to refresh UI
      ref.invalidate(herdPinnedPostsProvider(herdId));
      ref.invalidate(
          isPostPinnedToHerdProvider((herdId: herdId, postId: postId)));
    } catch (e) {
      rethrow;
    }
  }

  // Unpin post from herd
  Future<void> unpinFromHerd(
      String herdId, String postId, String userId) async {
    final herdRepository = ref.read(herdRepositoryProvider);

    try {
      await herdRepository.unpinPostFromHerd(herdId, postId, userId);

      // Invalidate relevant providers to refresh UI
      ref.invalidate(herdPinnedPostsProvider(herdId));
      ref.invalidate(
          isPostPinnedToHerdProvider((herdId: herdId, postId: postId)));
    } catch (e) {
      rethrow;
    }
  }
}

// Provider for the controller
final pinnedPostsControllerProvider = Provider<PinnedPostsController>((ref) {
  return PinnedPostsController(ref);
});
