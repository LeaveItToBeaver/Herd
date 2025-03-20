import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
import 'package:herdapp/features/user/view/providers/state/profile_state.dart';


import '../auth/view/providers/auth_provider.dart';
import '../feed/providers/feed_type_provider.dart';
import '../post/data/models/post_model.dart';
import '../post/view/providers/post_provider.dart';

class ProfileController extends AutoDisposeAsyncNotifier<ProfileState> {
  late final UserRepository _userRepository;
  late final PostRepository _postRepository;

  @override
  Future<ProfileState> build() async {
    _userRepository = ref.read(userRepositoryProvider);
    _postRepository = ref.read(postRepositoryProvider);
    return ProfileState.initial();
  }

  Future<void> loadProfile(String userId, {bool? isPrivateView}) async {
    // Validate userId
    if (userId.isEmpty) {
      state = AsyncValue.error('User ID is empty', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Get current user for comparison
      final currentUser = ref.read(authProvider);

      // Determine if we're viewing the private or public profile
      final currentFeed = ref.read(currentFeedProvider);
      final usePrivateView = isPrivateView ?? (currentFeed == FeedType.private);

      // Fetch user data
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Check if private profile exists
      final hasPrivateProfile = user.privateBio != null ||
          user.privateProfileImageURL != null ||
          user.privateCoverImageURL != null;

      // Fetch posts based on view type
      List<PostModel> posts;
      if (usePrivateView) {
        posts = await _postRepository.getUserPrivatePosts(userId).first;
      } else {
        posts = await _postRepository.getUserPublicPosts(userId).first;
      }

      // Check following status if not viewing own profile
      final isFollowing = currentUser != null && currentUser.uid != userId
          ? await _userRepository.isFollowing(currentUser.uid, userId)
          : false;

      // Get connection count for ANY user, not just the current user
      int connectionCount = 0;
      if (usePrivateView) {
        try {
          // This works for any user, not just the current one
          final snapshot = await FirebaseFirestore.instance
              .collection('privateConnections')
              .doc(userId)
              .collection('userConnections')
              .count()
              .get();
          connectionCount = snapshot.count ?? 0;

          print("DEBUG: Found $connectionCount private connections for user $userId");
        } catch (e) {
          print("DEBUG: Error getting private connections count: $e");
        }
      }

      // Since we now have freezed UserModel, we can use copyWith
      final updatedUser = user.copyWith(
        friends: connectionCount, // Use the actual connection count
      );

      state = AsyncValue.data(ProfileState(
        user: updatedUser,
        posts: posts,
        isCurrentUser: currentUser?.uid == userId,
        isFollowing: isFollowing,
        isPrivateView: usePrivateView,
        hasPrivateProfile: hasPrivateProfile,
      ));
    } catch (e, stack) {
      print("DEBUG: Profile loading error: $e");
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> toggleFollow(bool currentlyFollowing) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    final currentState = state.value;
    if (currentState == null || currentState.user == null) return;

    try {
      if (currentlyFollowing) {
        await _userRepository.unfollowUser(currentUser.uid, currentState.user!.id);
      } else {
        await _userRepository.followUser(currentUser.uid, currentState.user!.id);
      }

      // Reload profile with same view type
      await loadProfile(
          currentState.user!.id,
          isPrivateView: currentState.isPrivateView
      );
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> createPrivateProfile(Map<String, dynamic> data) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    try {
      await _userRepository.updateUser(currentUser.uid, data);
      await loadProfile(currentUser.uid, isPrivateView: true);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data, bool isPublicProfile) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    try {
      await _userRepository.updateUser(currentUser.uid, data);
      await loadProfile(currentUser.uid, isPrivateView: !isPublicProfile);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

final profileControllerProvider = AutoDisposeAsyncNotifierProvider<ProfileController, ProfileState>(
      () => ProfileController(),
);