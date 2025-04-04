import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

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

// Stream provider for a specific herd's posts
final herdPostsProvider = StreamProvider.family<List<PostModel>, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.streamHerdPosts(herdId: herdId);
});

// Provider for herd members
final herdMembersProvider = FutureProvider.family<List<String>, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerdMembers(herdId);
});

// Provider for trending herds
final trendingHerdsProvider = FutureProvider<List<HerdModel>>((ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getTrendingHerds();
});

// Provider to check if the current user is a member of a specific herd
final isHerdMemberProvider = FutureProvider.family<bool, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  return herdRepository.isHerdMember(herdId, user.uid);
});

// Provider to check if the current user is a moderator of a specific herd
final isHerdModeratorProvider = FutureProvider.family<bool, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  return herdRepository.isHerdModerator(herdId, user.uid);
});

// Provider to check if user is eligible to create herds
final canCreateHerdProvider = FutureProvider((ref) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  // Check if user is exempt
  if (HerdRepository.exemptUserIds.contains(user.uid)) {
    return true;
  }

  return herdRepository.checkUserEligibility(user.uid);
});