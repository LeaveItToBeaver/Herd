import 'package:cloud_firestore/cloud_firestore.dart';

class SuspendedUserInfo {
  final String userId;
  final String username;
  final String? firstName;
  final String? lastName;
  final String? profileImageURL;
  final bool isVerified;
  final DateTime suspendedAt;
  final DateTime suspendedUntil;
  final String suspendedBy;
  final String? suspendedByUsername;
  final String? reason;
  final String? notes;
  final bool isActive;

  const SuspendedUserInfo({
    required this.userId,
    required this.username,
    this.firstName,
    this.lastName,
    this.profileImageURL,
    required this.isVerified,
    required this.suspendedAt,
    required this.suspendedUntil,
    required this.suspendedBy,
    this.suspendedByUsername,
    this.reason,
    this.notes,
    this.isActive = true,
  });

  factory SuspendedUserInfo.fromMap({
    required String userId,
    required Map<String, dynamic> userData,
    required Map<String, dynamic> suspensionData,
    String? suspendedByUsername,
  }) {
    return SuspendedUserInfo(
      userId: userId,
      username: userData['username'] ?? 'Unknown',
      firstName: userData['firstName'],
      lastName: userData['lastName'],
      profileImageURL: userData['profileImageURL'],
      isVerified: userData['isVerified'] ?? false,
      suspendedAt: _parseDateTime(suspensionData['suspendedAt']) ?? DateTime.now(),
      suspendedUntil: _parseDateTime(suspensionData['suspendedUntil']) ?? DateTime.now(),
      suspendedBy: suspensionData['suspendedBy'] ?? '',
      suspendedByUsername: suspendedByUsername,
      reason: suspensionData['reason'],
      notes: suspensionData['notes'],
      isActive: suspensionData['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'suspendedAt': Timestamp.fromDate(suspendedAt),
      'suspendedUntil': Timestamp.fromDate(suspendedUntil),
      'suspendedBy': suspendedBy,
      'reason': reason,
      'notes': notes,
      'isActive': isActive,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  bool get isCurrentlySuspended {
    final now = DateTime.now();
    return isActive && now.isBefore(suspendedUntil);
  }

  Duration get remainingSuspension {
    final now = DateTime.now();
    if (!isCurrentlySuspended) return Duration.zero;
    return suspendedUntil.difference(now);
  }

  String get remainingSuspensionText {
    if (!isCurrentlySuspended) return 'Not suspended';
    
    final remaining = remainingSuspension;
    if (remaining.inDays > 0) {
      return '${remaining.inDays} days remaining';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours} hours remaining';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes} minutes remaining';
    } else {
      return 'Less than a minute remaining';
    }
  }
}