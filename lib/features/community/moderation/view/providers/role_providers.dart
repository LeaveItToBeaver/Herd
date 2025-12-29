import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../herds/data/models/herd_member.dart';
import '../../../herds/view/providers/herd_repository_provider.dart';
import '../../data/models/herd_role.dart';
import '../../data/models/permission_matrix.dart';
import '../../data/repositories/role_repository.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

final roleRepositoryProvider = Provider<RoleRepository>((ref) {
  return RoleRepository(
    FirebaseFirestore.instance,
    ref.read(herdRepositoryProvider),
  );
});

/// Get the current user's membership in a herd
final currentUserHerdMembershipProvider =
    FutureProvider.family<HerdMember?, String>((ref, herdId) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;

  final repository = ref.watch(herdRepositoryProvider);
  final doc = await repository.herdMembers(herdId).doc(user.uid).get();

  if (!doc.exists) return null;
  final data = doc.data();
  if (data == null) return null;
  return HerdMember.fromMap(doc.id, data, herdId: herdId);
});

/// Get the current user's role in a herd
final currentUserRoleProvider =
    FutureProvider.family<HerdRole?, String>((ref, herdId) async {
  final membership = await ref.watch(currentUserHerdMembershipProvider(herdId).future);
  return membership?.role;
});

/// Check if current user has a specific permission in a herd
class PermissionRequest {
  final String herdId;
  final HerdPermission permission;

  const PermissionRequest({required this.herdId, required this.permission});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PermissionRequest &&
          runtimeType == other.runtimeType &&
          herdId == other.herdId &&
          permission == other.permission;

  @override
  int get hashCode => herdId.hashCode ^ permission.hashCode;
}

final hasPermissionProvider =
    FutureProvider.family<bool, PermissionRequest>((ref, request) async {
  final role = await ref.watch(currentUserRoleProvider(request.herdId).future);
  if (role == null) return false;
  return PermissionMatrix.hasPermission(role, request.permission);
});

/// Stream the current user's role (for real-time updates)
final currentUserRoleStreamProvider =
    StreamProvider.family<HerdRole?, String>((ref, herdId) {
  final user = ref.watch(authProvider);
  if (user == null) return Stream.value(null);

  final repository = ref.watch(herdRepositoryProvider);
  return repository.herdMembers(herdId).doc(user.uid).snapshots().map((doc) {
    if (!doc.exists) return null;
    final roleStr = doc.data()?['role'] as String?;
    return HerdRole.values.firstWhere(
      (r) => r.name == roleStr,
      orElse: () => HerdRole.member,
    );
  });
});
