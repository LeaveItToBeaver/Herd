import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../data/models/banned_user_info.dart';
import 'herd_repository_provider.dart';

/// Provider for banned users in a herd
final bannedUsersProvider =
    FutureProvider.family<List<BannedUserInfo>, String>((ref, herdId) async {
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
});
