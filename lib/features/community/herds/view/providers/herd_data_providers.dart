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
