/// Herd role hierarchy (lowest to highest privilege)
enum HerdRole {
  member(0),
  moderator(1),
  admin(2),
  owner(3);

  final int level;
  const HerdRole(this.level);

  /// Check if this role has at least the privilege of [other]
  bool hasAtLeast(HerdRole other) => level >= other.level;

  /// Check if this role outranks [other]
  bool outranks(HerdRole other) => level > other.level;
}

/// Granular permissions for herd actions
enum HerdPermission {
  // Content permissions
  createPost,
  editOwnPost,
  deleteOwnPost,
  editAnyPost,
  deleteAnyPost,
  pinPost,
  lockPost,

  // Comment permissions
  createComment,
  editOwnComment,
  deleteOwnComment,
  deleteAnyComment,

  // User management
  viewMembers,
  warnUser,
  muteUser,
  kickUser,
  banUser,
  unbanUser,

  // Role management
  promoteToMod,
  demoteFromMod,
  promoteToAdmin,
  demoteFromAdmin,
  transferOwnership,

  // Moderation tools
  viewReports,
  resolveReports,
  escalateReports,
  viewModerationLog,
  viewAnalytics,

  // Herd management
  editHerdInfo,
  editHerdSettings,
  deleteHerd,
}
