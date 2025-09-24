import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class ProfileController extends AsyncNotifier<ProfileState> {
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;
  late final FeedRepository _feedRepository;

  @override
  Future<ProfileState> build() async {
    _userRepository = ref.read(userRepositoryProvider);
    _postRepository = ref.read(postRepositoryProvider);
    _feedRepository = ref.read(feedRepositoryProvider);
    return ProfileState.initial();
  }

  Future<void> _batchInitializePostInteractions(
      String userId, List<PostModel> posts) async {
    if (posts.isEmpty || userId.isEmpty) return;

    debugPrint('Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId);
    }

    debugPrint('Interactions batch initialization complete');
  }

  Future<void> loadProfile(String userId, {bool? isAltView}) async {
    // Validate userId
    if (userId.isEmpty) {
      state = AsyncValue.error('User ID is empty', StackTrace.current);
      return;
    }

    // Ensure the controller is properly initialized
    if (!state.hasValue && !state.hasError) {
      // Wait for initial build to complete
      await Future.delayed(Duration.zero);
    }

    // Get current state before setting to loading, or use initial state
    final currentState = state.hasValue ? state.value! : ProfileState.initial();
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
      posts = await _feedRepository.getUserPosts(
        userId: userId,
        isAlt: useAltView,
        limit: currentState.pageSize,
      );

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
        hasMorePosts: posts.length >= currentState.pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
        currentUserId: currentUserId,
      ));
      await _batchInitializePostInteractions(currentUserId, posts);
    } catch (e, stack) {
      debugPrint("DEBUG: Profile loading error: $e");
      debugPrint("DEBUG: Stack trace: $stack");
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> loadMorePosts(String userId) async {
    debugPrint('🚀 loadMorePosts called for userId: $userId');
    debugPrint('🔍 Current state type: ${state.runtimeType}');
    debugPrint('🔍 Has value: ${state.hasValue}');
    debugPrint('🔍 Has error: ${state.hasError}');
    debugPrint('🔍 Is loading: ${state.isLoading}');

    // Check if state has a value first
    if (!state.hasValue) {
      debugPrint('Cannot load more posts - state has no value');
      if (state.hasError) {
        debugPrint('State error: ${state.error}');
      }
      return;
    }

    final currentState = state.value!;

    debugPrint('🔍 Current state details:');
    debugPrint('   posts.length: ${currentState.posts.length}');
    debugPrint('   hasMorePosts: ${currentState.hasMorePosts}');
    debugPrint('   isLoading: ${currentState.isLoading}');
    debugPrint('   lastPost: ${currentState.lastPost?.id}');
    debugPrint('   isAltView: ${currentState.isAltView}');

    if (!currentState.hasMorePosts ||
        currentState.isLoading ||
        currentState.lastPost == null) {
      debugPrint('Cannot load more posts - conditions not met');
      return;
    }

    try {
      // Set loading state
      state = AsyncValue.data(currentState.copyWith(isLoading: true));
      final currentUser = ref.read(authProvider);
      final currentUserId = currentUser?.uid ?? '';

      // Get pagination parameters
      final lastPost = currentState.lastPost!;

      debugPrint('📄 PAGINATION: Attempting to load more posts');
      debugPrint('📄 PAGINATION: hasMorePosts=${currentState.hasMorePosts}');
      debugPrint('📄 PAGINATION: lastPostId=${lastPost.id}');

      List<PostModel> morePosts = await _feedRepository.getUserPosts(
        userId: userId,
        isAlt: currentState.isAltView,
        limit: currentState.pageSize,
        lastPost: lastPost,
      );

      debugPrint('📄 PAGINATION: Loaded ${morePosts.length} more posts');

      // Check for duplicates
      final existingIds = currentState.posts.map((p) => p.id).toSet();
      final newPosts =
          morePosts.where((p) => !existingIds.contains(p.id)).toList();

      // Combine with existing posts
      final allPosts = [...currentState.posts, ...newPosts];

      debugPrint(
          '📄 PAGINATION: Total posts: ${allPosts.length} (${newPosts.length} new)');

      state = AsyncValue.data(currentState.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMorePosts: morePosts.length >= currentState.pageSize,
        lastPost: allPosts.isNotEmpty ? allPosts.last : lastPost,
      ));

      await _batchInitializePostInteractions(currentUserId, newPosts);
    } catch (e) {
      debugPrint("Error loading more posts: $e");
      // Keep the current posts but set loading to false
      if (state.hasValue) {
        final currentState = state.value!;
        state = AsyncValue.data(currentState.copyWith(isLoading: false));
      }
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
