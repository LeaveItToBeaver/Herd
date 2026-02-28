import 'package:herdapp/features/community/moderation/data/models/herd_role.dart';

class HerdMemberInfo {
  final String userId;
  final String username;
  final String? altUsername;
  final String? profileImageURL;
  final String? altProfileImageURL;
  final bool isVerified;
  final DateTime? joinedAt;
  final bool isModerator;
  final HerdRole role;
  final int userPoints;
  final int altUserPoints;
  final bool isActive;
  final String? bio;
  final String? altBio;

  const HerdMemberInfo({
    required this.userId,
    required this.username,
    this.altUsername,
    this.profileImageURL,
    this.altProfileImageURL,
    required this.isVerified,
    this.joinedAt,
    required this.isModerator,
    this.role = HerdRole.member,
    required this.userPoints,
    required this.altUserPoints,
    required this.isActive,
    this.bio,
    this.altBio,
  });

  // Helper getter to get the preferred username (alt if available, otherwise regular)
  String get displayUsername =>
      altUsername?.isNotEmpty == true ? altUsername! : username;

  // Helper getter to get the preferred profile image (alt if available, otherwise regular)
  String? get displayProfileImage => altProfileImageURL ?? profileImageURL;

  // Helper getter to get the preferred bio (alt if available, otherwise regular)
  String? get displayBio => altBio?.isNotEmpty == true ? altBio : bio;

  // Helper getter to get the preferred user points (alt if available, otherwise regular)
  int get displayUserPoints => altUserPoints > 0 ? altUserPoints : userPoints;

  bool get hasModeratorPrivileges => role.hasAtLeast(HerdRole.moderator);
}
