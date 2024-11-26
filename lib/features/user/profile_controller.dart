import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/post/data/repositories/post_repository.dart';
import 'package:herdapp/features/user/view/providers/state/profile_state.dart';

import '../auth/view/providers/auth_provider.dart';
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

  Future<void> loadProfile(String userId) async {
    // Validate userId
    if (userId.isEmpty) {
      state = AsyncValue.error('User ID is empty', StackTrace.current);
      return;
    }

    state = const AsyncValue.loading();

    try {
      // Get current user for comparison
      final currentUser = ref.read(authProvider);

      // Fetch user data
      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      // Fetch posts
      final posts = await _postRepository.getUserPosts(userId).first;

      // Check following status if not viewing own profile
      final isFollowing = currentUser != null && currentUser.uid != userId
          ? await _userRepository.isFollowing(currentUser.uid, userId)
          : false;

      state = AsyncValue.data(ProfileState(
        user: user,
        posts: posts,
        isCurrentUser: currentUser?.uid == userId,
        isFollowing: isFollowing,
      ));
    } catch (e, stack) {
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

      await loadProfile(currentState.user!.id);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    try {
      await _userRepository.updateUser(currentUser.uid, data);
      await loadProfile(currentUser.uid);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
