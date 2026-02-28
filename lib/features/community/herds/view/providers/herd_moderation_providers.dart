import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/banned_user_info.dart';
import 'herd_repository_provider.dart';

part 'herd_moderation_providers.g.dart';

/// Provider for banned users in a herd
@riverpod
Future<List<BannedUserInfo>> bannedUsers(Ref ref, String herdId) async {
  try {
    final herdRepository = ref.read(herdRepositoryProvider);
    return await herdRepository.getBannedUsers(herdId);
  } on FirebaseException catch (e) {
    if (e.code == 'permission-denied') {
      // Log the specific permission error
      debugPrint(
          'Permission denied when fetching banned users for herd: $herdId');
      // Return empty list instead of throwing
      return <BannedUserInfo>[];
    }
    rethrow;
  } catch (e) {
    debugPrint('Error in bannedUsersProvider: $e');
    rethrow;
  }
}
