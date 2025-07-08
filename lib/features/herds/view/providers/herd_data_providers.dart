import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

import '../../data/models/herd_member_info.dart';
import '../../data/models/herd_model.dart';
import 'herd_repository_provider.dart';

/// Provider for user's followed herds
final userHerdsProvider = StreamProvider<List<HerdModel>>((ref) {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return herdRepository.streamUserHerds(user.uid);
});

/// Provider for a specific herd
final herdProvider = FutureProvider.family<HerdModel?, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerd(herdId);
});

/// Provider for a specific user's followed herds
final profileUserHerdsProvider =
    FutureProvider.family<List<HerdModel>, String>((ref, userId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getUserHerds(userId);
});

/// Count of herds a specific user is in
final userHerdCountProvider =
    FutureProvider.family<int, String>((ref, userId) async {
  final herds = await ref.watch(profileUserHerdsProvider(userId).future);
  return herds.length;
});

/// Stream provider for a specific herd's posts
final herdPostsProvider =
    StreamProvider.family<List<PostModel>, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.streamHerdPosts(herdId: herdId);
});

/// Provider for herd members with detailed info
final herdMembersWithInfoProvider =
    FutureProvider.family<List<HerdMemberInfo>, String>((ref, herdId) async {
  final herdRepository = ref.read(herdRepositoryProvider);
  return await herdRepository.getHerdMembersWithInfo(herdId);
});

/// Provider for herd members - returns just the user IDs (legacy version)
final herdMembersProvider =
    FutureProvider.family<List<String>, String>((ref, herdId) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getHerdMembers(herdId);
});

/// Provider for trending herds
final trendingHerdsProvider = FutureProvider<List<HerdModel>>((ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return herdRepository.getTrendingHerds();
});

/// Provider to track the current herd ID when viewing a herd screen
final currentHerdIdProvider = StateProvider<String?>((ref) => null);
