import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/user/view/providers/state/profile_state.dart';

import '../auth/view/providers/auth_provider.dart';
import '../feed/providers/feed_type_provider.dart';
import '../post/data/models/post_model.dart';
import '../post/view/providers/post_provider.dart';

class ProfileController extends AutoDisposeAsyncNotifier<ProfileState> {
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;
  final int pageSize = 20;

  @override
  Future<ProfileState> build() async {
    _userRepository = ref.read(userRepositoryProvider);
    _postRepository = ref.read(postRepositoryProvider);
    return ProfileState.initial();
  }

  Future<void> _batchInitializePostInteractions(
      String userId, List<PostModel> posts) async {
    if (posts.isEmpty || userId == null) return;

    debugPrint('🔄 Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId!);
    }

    debugPrint('✅ Interactions batch initialization complete');
  }

  Future<void> loadProfile(String userId, {bool? isAltView}) async {
    // Validate userId
    if (userId.isEmpty) {
      state = AsyncValue.error('User ID is empty', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Get current user for comparison
      final currentUser = ref.read(authProvider);
      final currentUserId = currentUser?.uid ?? '';

      // Determine if we're viewing the alt or public profile
      final currentFeed = ref.read(currentFeedProvider);
      final useAltView = isAltView ?? (currentFeed == FeedType.alt);

      // Fetch user data
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if alt profile exists
      final hasAltProfile = user.altBio != null ||
          user.altProfileImageURL != null ||
          user.altCoverImageURL != null;

      // Fetch posts based on view type
      List<PostModel> posts;
      if (useAltView) {
        posts = await _postRepository.getFutureUserAltProfilePosts(
          userId,
          limit: pageSize,
        );
      } else {
        posts = await _postRepository.getFutureUserPublicPosts(
          userId,
          limit: pageSize,
        );
      }

      // Check following status if not viewing own profile
      final isFollowing = currentUser != null && currentUser.uid != userId
          ? await _userRepository.isFollowing(currentUser.uid, userId)
          : false;

      // Get connection count for ANY user, not just the current user
      int connectionCount = 0;
      if (useAltView) {
        try {
          connectionCount = await _userRepository.getAltConnectionCount(userId);
          debugPrint(
              "DEBUG: Found $connectionCount alt connections for user $userId");
        } catch (e) {
          debugPrint("DEBUG: Error getting alt connections count: $e");
        }
      }

      // Since we now have freezed UserModel, we can use copyWith
      final updatedUser = user.copyWith(
        friends: connectionCount,
      );

      state = AsyncValue.data(ProfileState(
        user: updatedUser,
        posts: posts,
        isCurrentUser: currentUser?.uid == userId,
        isFollowing: isFollowing,
        isAltView: useAltView,
        hasAltProfile: hasAltProfile,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        currentUserId: currentUserId,
      ));
      await _batchInitializePostInteractions(currentUserId, posts);
    } catch (e, stack) {
      debugPrint("DEBUG: Profile loading error: $e");
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMorePosts(String userId) async {
    final currentState = state.value;
    if (currentState == null ||
        !currentState.hasMorePosts ||
        currentState.isLoading ||
        currentState.lastPost == null) {
      return;
    }

    try {
      // Set loading state
      state = AsyncValue.data(currentState.copyWith(isLoading: true));
      final currentUser = ref.read(authProvider);
      final currentUserId = currentUser?.uid ?? '';

      // Get pagination parameters
      final lastPost = currentState.lastPost!;

      List<PostModel> morePosts;
      if (currentState.isAltView) {
        // For alt profile
        morePosts = await _postRepository.getFutureUserAltProfilePosts(
          userId,
          limit: pageSize,
          lastHotScore: lastPost.hotScore,
          lastPostId: lastPost.id,
        );
      } else {
        // For public profile
        morePosts = await _postRepository.getFutureUserPublicPosts(
          userId,
          limit: pageSize,
          lastHotScore: lastPost.hotScore,
          lastPostId: lastPost.id,
        );
      }

      // Combine with existing posts
      final allPosts = [...currentState.posts, ...morePosts];

      state = AsyncValue.data(currentState.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMorePosts: morePosts.length >= pageSize,
        lastPost: morePosts.isNotEmpty ? morePosts.last : lastPost,
      ));
      await _batchInitializePostInteractions(currentUserId, allPosts);
    } catch (e) {
      debugPrint("DEBUG: Error loading more posts: $e");
      // Keep the current posts but set loading to false
      state = AsyncValue.data(currentState.copyWith(isLoading: false));
    }
  }

  Future<void> toggleFollow(bool currentlyFollowing) async {
    final currentState = state;
    if (!currentState.hasValue) return;

    final profile = currentState.value!;
    if (profile.user == null) return;

    final currentUserId = profile.currentUserId;
    if (currentUserId.isEmpty) {
      debugPrint("DEBUG: Current user ID is empty, cannot toggle follow.");
      return;
    }

    final targetUserId = profile.user!.id;

    // Optimistically update UI state
    state = AsyncValue.data(profile.copyWith(
      isFollowing: !currentlyFollowing,
      user: profile.user!.copyWith(
        followers: currentlyFollowing
            ? profile.user!.followers - 1
            : profile.user!.followers + 1,
      ),
    ));

    try {
      // Perform API call in background
      if (currentlyFollowing) {
        await _userRepository.unfollowUser(currentUserId, targetUserId);
      } else {
        await _userRepository.followUser(currentUserId, targetUserId);
      }

      // No need to update state again since we already did it optimistically
    } catch (e) {
      debugPrint("DEBUG: Follow/unfollow error: $e");
      // If API call fails, revert back to previous state
      state = currentState;
      // You might want to show an error message here
    }
  }

  Future<void> createAltProfile(Map<String, dynamic> data) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    try {
      await _userRepository.updateUser(currentUser.uid, data);
      await loadProfile(currentUser.uid, isAltView: true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(
      Map<String, dynamic> data, bool isPublicProfile) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    try {
      await _userRepository.updateUser(currentUser.uid, data);
      await loadProfile(currentUser.uid, isAltView: !isPublicProfile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final profileControllerProvider =
    AutoDisposeAsyncNotifierProvider<ProfileController, ProfileState>(
  () => ProfileController(),
);
