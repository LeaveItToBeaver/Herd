import 'herd_role.dart';

/// Maps roles to their allowed permissions with inheritance support.
class PermissionMatrix {
  static const Map<HerdRole, Set<HerdPermission>> _matrix = {
    HerdRole.member: {
      HerdPermission.createPost,
      HerdPermission.editOwnPost,
      HerdPermission.deleteOwnPost,
      HerdPermission.createComment,
      HerdPermission.editOwnComment,
      HerdPermission.deleteOwnComment,
      HerdPermission.viewMembers,
    },
    HerdRole.moderator: {
      HerdPermission.deleteAnyPost,
      HerdPermission.deleteAnyComment,
      HerdPermission.pinPost,
      HerdPermission.lockPost,
      HerdPermission.warnUser,
      HerdPermission.muteUser,
      HerdPermission.kickUser,
      HerdPermission.viewReports,
      HerdPermission.resolveReports,
      HerdPermission.viewModerationLog,
    },
    HerdRole.admin: {
      HerdPermission.editAnyPost,
      HerdPermission.banUser,
      HerdPermission.unbanUser,
      HerdPermission.promoteToMod,
      HerdPermission.demoteFromMod,
      HerdPermission.escalateReports,
      HerdPermission.viewAnalytics,
      HerdPermission.editHerdInfo,
      HerdPermission.editHerdSettings,
    },
    HerdRole.owner: {},
  };

  /// Check if [role] has [permission], applying inheritance.
  static bool hasPermission(HerdRole role, HerdPermission permission) {
    final permissions = getPermissions(role);
    return permissions.contains(permission);
  }

  /// Aggregate permissions for [role], including inherited levels.
  static Set<HerdPermission> getPermissions(HerdRole role) {
    if (role == HerdRole.owner) {
      return HerdPermission.values.toSet();
    }
    final permissions = <HerdPermission>{};
    for (final r in HerdRole.values) {
      if (role.hasAtLeast(r)) {
        permissions.addAll(_matrix[r] ?? {});
      }
    }
    return permissions;
  }
}
