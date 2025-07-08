import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/herds/data/models/herd_member_info.dart';
import 'package:herdapp/features/herds/data/models/banned_user_info.dart';
import 'package:herdapp/features/herds/view/providers/state/herd_feed_state.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';

import '../../../../core/services/cache_manager.dart';
import '../../data/models/herd_model.dart';
import '../../data/repositories/herd_repository.dart';

// Basic repository provider
final herdRepositoryProvider = Provider<HerdRepository>((ref) {
  return HerdRepository(FirebaseFirestore.instance);
});

// Provider for user's followed herds
final userHerdsProvider = StreamProvider<List<HerdModel>>((ref) {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return herdRepository.streamUserHerds(user.uid);
});

// Provider for a specific herd
final herdProvider = FutureProvider.family<HerdModel?, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerd(herdId);
});

// Provider for a specific user's followed herds
final profileUserHerdsProvider =
    FutureProvider.family<List<HerdModel>, String>((ref, userId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getUserHerds(userId);
});

// Count of herds a specific user is in
final userHerdCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final herds = await ref.watch(profileUserHerdsProvider(userId).future);
  return herds.length;
});

// Stream provider for a specific herd's posts
final herdPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.streamHerdPosts(herdId: herdId);
});

// Provider for herd members
final herdMembersWithInfoProvider =
    FutureProvider.family<List<HerdMemberInfo>, String>((ref, herdId) async {
  final herdRepository = ref.read(herdRepositoryProvider);
  return await herdRepository.getHerdMembersWithInfo(herdId);
});

// Provider for herd members - this returns just the user IDs older version
final herdMembersProvider =
    FutureProvider.family<List<String>, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerdMembers(herdId);
});

// Provider for trending herds
final trendingHerdsProvider = FutureProvider<List<HerdModel>>((ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getTrendingHerds();
});

// Provider to check if the current user is a member of a specific herd
final isHerdMemberProvider =
    FutureProvider.family<bool, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  return herdRepository.isHerdMember(herdId, user.uid);
});

// Provider to check if the current user is a moderator of a specific herd
final isHerdModeratorProvider =
    FutureProvider.family<bool, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  return herdRepository.isHerdModerator(herdId, user.uid);
});

// Provider to check if user is eligible to create herds
final canCreateHerdProvider = FutureProvider.autoDispose((ref) async {
  debugPrint("⚡ canCreateHerdProvider executing");
  final user = ref.watch(authProvider);
  debugPrint("⚡ User ID: ${user?.uid}");
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  // Check if user is exempt by querying the exemptUserIds collection
  try {
    debugPrint("⚡ Checking exemption for ${user.uid}");
    final exemptDoc = await herdRepository.exemptUserIds().doc(user.uid).get();
    debugPrint("⚡ Exempt doc exists: ${exemptDoc.exists}");
    if (exemptDoc.exists) {
      return true; // User is exempt from eligibility checks
    }
  } catch (e) {
    debugPrint("⚡ Error checking exempt status: $e");
    // Continue with regular eligibility check even if the exempt check fails
  }

  // If not exempt, check regular eligibility criteria
  return herdRepository.checkUserEligibility(user.uid);
});

// Add new provider to track the current herd ID when viewing a herd screen
final currentHerdIdProvider = StateProvider<String?>((ref) => null);

// 2. Create a controller for herd feed
class HerdFeedController extends StateNotifier<HerdFeedState> {
  final HerdRepository repository;
  final String herdId;
  final int pageSize;
  bool _disposed = false;
  final Ref ref;

  HerdFeedController(this.repository, this.herdId, this.ref,
      {this.pageSize = 20})
      : super(HerdFeedState.initial());

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  bool get _isActive => !_disposed;

  Future<void> loadInitialPosts() async {
    try {
      if (state.isLoading || _disposed) return;

      if (_isActive) state = state.copyWith(isLoading: true, error: null);

      // Use the updated repository method to get joined posts
      final posts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
      );

      if (_isActive) {
        state = state.copyWith(
          posts: posts,
          isLoading: false,
          hasMorePosts: posts.length >= pageSize,
          lastPost: posts.isNotEmpty ? posts.last : null,
        );
      }

      // Initialize interactions for visible posts
      final currentUser = ref.read(authProvider);
      if (currentUser?.uid != null && posts.isNotEmpty) {
        await _batchInitializePostInteractions(currentUser!.uid, posts);
      }
    } catch (e) {
      if (_isActive) {
        state = state.copyWith(
          isLoading: false,
          error: e,
        );
      }
    }
  }

  Future<void> _batchInitializePostInteractions(
      String userId, List<PostModel> posts) async {
    if (posts.isEmpty) return;

    debugPrint('🔄 Batch initializing interactions for ${posts.length} posts');

    for (final post in posts) {
      // Initialize each post's interaction state proactively
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: post.id, isAlt: post.isAlt))
              .notifier)
          .initializeState(userId);
    }

    debugPrint('✅ Interactions batch initialization complete');
  }

  Future<void> loadMorePosts() async {
    try {
      if (state.isLoading || !state.hasMorePosts || state.lastPost == null) {
        return;
      }

      state = state.copyWith(isLoading: true, error: null);

      final lastPost = state.lastPost!;

      final morePosts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
        lastHotScore: lastPost.hotScore,
        lastPostId: lastPost.id,
      );

      final currentUser = ref.read(authProvider);
      final userId = currentUser?.uid;

      // Combine with existing posts
      final allPosts = [...state.posts, ...morePosts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        hasMorePosts: morePosts.length >= pageSize,
        lastPost: morePosts.isNotEmpty ? morePosts.last : lastPost,
      );
      if (userId != null) {
        await _batchInitializePostInteractions(userId, allPosts);
      }
    } catch (e) {
      // Keep existing posts but set loading to false
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  Future<void> refreshFeed() async {
    try {
      state = state.copyWith(isRefreshing: true, error: null);

      final posts = await repository.getHerdPosts(
        herdId: herdId,
        limit: pageSize,
      );

      final currentUser = ref.read(authProvider);
      final userId = currentUser?.uid;

      state = state.copyWith(
        posts: posts,
        isRefreshing: false,
        isLoading: false,
        hasMorePosts: posts.length >= pageSize,
        lastPost: posts.isNotEmpty ? posts.last : null,
      );
      if (userId != null) {
        await _batchInitializePostInteractions(userId, posts);
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshing: false,
        isLoading: false,
        error: e,
      );
    }
  }
}

final herdFeedCacheManagerProvider = Provider<CacheManager>((ref) {
  return CacheManager();
});

final herdFeedControllerProvider =
    StateNotifierProvider.family<HerdFeedController, HerdFeedState, String>(
  (ref, herdId) {
    final repository = ref.watch(herdRepositoryProvider);
    return HerdFeedController(repository, herdId, ref);
  },
);

// Provider for banned users
final bannedUsersProvider =
    FutureProvider.family<List<BannedUserInfo>, String>((ref, herdId) async {
  final herdRepository = ref.read(herdRepositoryProvider);
  return await herdRepository.getBannedUsers(herdId);
});
