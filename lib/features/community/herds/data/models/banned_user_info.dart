import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for banned user information
class BannedUserInfo {
  final String userId;
  final String username;
  final String? bio;
  final String? profileImageURL;
  final bool isVerified;
  final DateTime? bannedAt;
  final String? bannedBy;
  final String? bannedByUsername;

  const BannedUserInfo({
    required this.userId,
    required this.username,
    this.bio,
    this.profileImageURL,
    required this.isVerified,
    this.bannedAt,
    this.bannedBy,
    this.bannedByUsername,
  });

  // Helper for parsing DateTime values from Firestore
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  factory BannedUserInfo.fromMap({
    required String userId,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> banData,
    String? bannedByUsername,
  }) {
    return BannedUserInfo(
      userId: userId,
      username: userData['username'] ?? 'Unknown',
      bio: userData['bio'],
      profileImageURL: userData['profileImageURL'],
      isVerified: userData['isVerified'] ?? false,
      bannedAt: _parseDateTime(banData['bannedAt']),
      bannedBy: banData['bannedBy'],
      bannedByUsername: bannedByUsername,
    );
  }
}
