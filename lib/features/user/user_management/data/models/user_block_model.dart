import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_block_model.freezed.dart';

@freezed
abstract class UserBlockModel with _$UserBlockModel {
  const UserBlockModel._();

  const factory UserBlockModel({
    required String userId, // The blocked user's ID
    required DateTime createdAt,
    required bool isAlt, // Whether this user is considered an alt account
    String? username, // The blocked user's username
    String? firstName, // The blocked user's first name
    String? lastName, // The blocked user's last name
    @Default(false) bool reported, // Whether this user was also reported
    String? notes, // Optional notes about why they were blocked
  }) = _UserBlockModel;

  factory UserBlockModel.fromMap(Map<String, dynamic> map) {
    return UserBlockModel(
      userId: map['userId'] ?? '',
      createdAt: _parseDateTime(map['createdAt']) ?? DateTime.now(),
      isAlt: map['isAlt'] ?? false,
      username: map['username'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      reported: map['reported'] ?? false,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isAlt': isAlt,
      'username': username,
      'firstName': firstName,
      'lastName': lastName,
      'reported': reported,
      'notes': notes,
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

  // Helper method to get display name - NEVER show username for anonymity
  String get displayName {
    // For alt profiles, NEVER show username - only use first name or generic "User"
    if (firstName != null && firstName!.isNotEmpty) {
      return firstName!; // Only show first name for anonymity
    }

    // Never show username or full names for alt profiles
    return 'User'; // Generic fallback to protect anonymity
  }
}
