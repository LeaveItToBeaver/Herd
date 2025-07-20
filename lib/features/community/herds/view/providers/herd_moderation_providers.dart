import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/banned_user_info.dart';
import 'herd_repository_provider.dart';

/// Provider for banned users in a herd
final bannedUsersProvider =
    FutureProvider.family<List<BannedUserInfo>, String>((ref, herdId) async {
  final herdRepository = ref.read(herdRepositoryProvider);
  return await herdRepository.getBannedUsers(herdId);
});
