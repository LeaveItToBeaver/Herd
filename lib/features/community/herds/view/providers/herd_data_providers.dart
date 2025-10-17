import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';

import '../../data/models/herd_member_info.dart';
import '../../data/models/herd_model.dart';
import 'herd_repository_provider.dart';

part 'herd_data_providers.g.dart';

/// Provider for user's followed herds
@riverpod
Stream<List<HerdModel>> userHerds(Ref ref) {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return herdRepository.streamUserHerds(user.uid);
}

/// Provider for a specific herd
@riverpod
Future<HerdModel?> herd(Ref ref, String herdId) async {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerd(herdId);
}

/// Provider for a specific user's followed herds
@riverpod
Future<List<HerdModel>> profileUserHerds(Ref ref, String userId) async {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getUserHerds(userId);
}

/// Count of herds a specific user is in
@riverpod
Future<int> userHerdCount(Ref ref, String userId) async {
  final herds = await ref.watch(profileUserHerdsProvider(userId).future);
  return herds.length;
}

/// Stream provider for a specific herd's posts
@riverpod
Stream<List<PostModel>> herdPosts(Ref ref, String herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.streamHerdPosts(herdId: herdId);
}

/// Provider for herd members with detailed info
@riverpod
Future<List<HerdMemberInfo>> herdMembersWithInfo(Ref ref, String herdId) async {
  final herdRepository = ref.read(herdRepositoryProvider);
  return await herdRepository.getHerdMembersWithInfo(herdId);
}

/// Provider for herd members - returns just the user IDs (legacy version)
@riverpod
Future<List<String>> herdMembers(Ref ref, String herdId) async {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerdMembers(herdId);
}

/// Provider for trending herds
@riverpod
Future<List<HerdModel>> trendingHerds(Ref ref) async {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getTrendingHerds();
}

/// Provider to track the current herd ID when viewing a herd screen
@riverpod
class CurrentHerdId extends _$CurrentHerdId {
  @override
  String? build() => null;

  void set(String? herdId) => state = herdId;
  void clear() => state = null;
}

/// Provider for pinned posts in a herd
@riverpod
Future<List<PostModel>> herdPinnedPosts(Ref ref, String herdId) async {
  final herd = await ref.watch(herdProvider(herdId).future);
  if (herd == null || herd.pinnedPosts.isEmpty) return [];

  final List<PostModel> pinnedPosts = [];
  final firestore = FirebaseFirestore.instance;

  for (final postId in herd.pinnedPosts) {
    try {
      // Try to fetch from herd posts first (most likely location for herd pinned posts)
      final herdPostDoc = await firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId)
          .get();

      if (herdPostDoc.exists) {
        final post = PostModel.fromMap(herdPostDoc.id, herdPostDoc.data()!);
        pinnedPosts.add(post);
        continue;
      }

      // If not found in herd posts, try regular posts collection
      final publicPostDoc =
          await firestore.collection('posts').doc(postId).get();

      if (publicPostDoc.exists) {
        final post = PostModel.fromMap(publicPostDoc.id, publicPostDoc.data()!);
        pinnedPosts.add(post);
        continue;
      }

      // Finally, try alt posts collection
      final altPostDoc =
          await firestore.collection('altPosts').doc(postId).get();

      if (altPostDoc.exists) {
        final post = PostModel.fromMap(altPostDoc.id, altPostDoc.data()!);
        pinnedPosts.add(post);
        continue;
      }

      debugPrint('Pinned post $postId not found in any collection');
    } catch (e) {
      debugPrint('Error loading pinned post $postId: $e');
    }
  }

  return pinnedPosts;
}
