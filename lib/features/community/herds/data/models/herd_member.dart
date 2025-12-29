import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/community/moderation/data/models/herd_role.dart';
import 'package:herdapp/features/community/moderation/data/models/permission_matrix.dart';

class HerdMember {
  final String userId;
  final String herdId;
  final DateTime joinedAt;
  final HerdRole role;
  final String? promotedBy;
  final DateTime? roleChangedAt;
  final Map<String, bool> restrictions;

  const HerdMember({
    required this.userId,
    required this.herdId,
    required this.joinedAt,
    this.role = HerdRole.member,
    this.promotedBy,
    this.roleChangedAt,
    this.restrictions = const {},
  });

  factory HerdMember.fromMap(
    String userId,
    Map<String, dynamic> map, {
    String? herdId,
  }) {
    final role = parseHerdRole(map); // TODO: remove isModerator fallback after migration

    return HerdMember(
      userId: userId,
      herdId: herdId ?? map['herdId'] as String? ?? '',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: role,
      promotedBy: map['promotedBy'] as String?,
      roleChangedAt: (map['roleChangedAt'] as Timestamp?)?.toDate(),
      restrictions: Map<String, bool>.from(map['restrictions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'herdId': herdId,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'role': role.name,
      'promotedBy': promotedBy,
      'roleChangedAt': roleChangedAt != null ? Timestamp.fromDate(roleChangedAt!) : null,
      'restrictions': restrictions,
    };
  }

  /// Check if this member has a specific permission.
  bool hasPermission(HerdPermission permission) {
    return PermissionMatrix.hasPermission(role, permission);
  }

  /// Check if this member can perform an action on another member.
  bool canActOn(HerdMember target) {
    return role.outranks(target.role);
  }
}
