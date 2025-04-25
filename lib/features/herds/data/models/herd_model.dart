import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'herd_model.freezed.dart';

@freezed
abstract class HerdModel with _$HerdModel {
  const HerdModel._(); // Add this to allow custom methods within the class

  const factory HerdModel({
    required String id,
    required String name,
    required String description,
    @Default([]) List<String> interests,
    @Default('') String rules,
    @Default('') String faq,
    DateTime? createdAt,
    required String creatorId,
    String? profileImageURL,
    String? coverImageURL,
    @Default([]) List<String> moderatorIds,
    @Default(0) int memberCount,
    @Default(0) int postCount,
    @Default({}) Map<String, dynamic> customization,
    @Default(false) bool isPrivate,
  }) = _HerdModel;

  // Factory constructor to convert from Firestore snapshot
  factory HerdModel.fromMap(String id, Map<String, dynamic> map) {
    return HerdModel(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      interests: List<String>.from(map['interests'] ?? []),
      rules: map['rules'] ?? '',
      faq: map['faq'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      creatorId: map['creatorId'] ?? '',
      profileImageURL: map['profileImageURL'],
      coverImageURL: map['coverImageURL'],
      moderatorIds: List<String>.from(map['moderatorIds'] ?? []),
      memberCount: map['memberCount'] ?? 0,
      postCount: map['postCount'] ?? 0,
      customization: Map<String, dynamic>.from(map['customization'] ?? {}),
      isPrivate: map['isPrivate'] ?? false,
    );
  }

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

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'interests': interests,
      'rules': rules,
      'faq': faq,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'creatorId': creatorId,
      'profileImageURL': profileImageURL,
      'coverImageURL': coverImageURL,
      'moderatorIds': moderatorIds,
      'memberCount': memberCount,
      'postCount': postCount,
      'customization': customization,
      'isPrivate': isPrivate,
    };
  }

  // Check if a user is a moderator
  bool isModerator(String userId) {
    return creatorId == userId || moderatorIds.contains(userId);
  }

  // Check if a user is the creator
  bool isCreator(String userId) {
    return creatorId == userId;
  }
}
