import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

import 'herd_repository_provider.dart';

/// Provider to check if the current user is a member of a specific herd
final isHerdMemberProvider =
    FutureProvider.family<bool, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  return herdRepository.isHerdMember(herdId, user.uid);
});

/// Provider to check if the current user is a moderator of a specific herd
final isHerdModeratorProvider =
    FutureProvider.family<bool, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  final herdRepository = ref.watch(herdRepositoryProvider);

  if (user == null) return false;

  return herdRepository.isHerdModerator(herdId, user.uid);
});

/// Provider to check if user is eligible to create herds
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
