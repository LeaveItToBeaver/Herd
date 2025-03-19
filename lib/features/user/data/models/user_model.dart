import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._(); // Add this to allow custom methods within the class

  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int? followers,
    @Default(0) int? following,
    @Default(0) int? friends,
    @Default(0) int? userPoints,
    String? privateUserUID,
    String? bio,
    String? profileImageURL,
    String? coverImageURL,

    // Private profile fields
    String? privateBio,
    String? privateProfileImageURL,
    String? privateCoverImageURL,
  }) = _UserModel;

  // Factory constructor to create a UserModel from Firebase User
  factory UserModel.fromFirebaseUser(
      String uid,
      String? email,
      String? displayName, {
        String? bio,
        String? profileImageURL,
        String? coverImageURL,
      }) {
    return UserModel(
      id: uid,
      firstName: '',
      lastName: '',
      username: displayName ?? '',
      email: email ?? '',
      bio: bio,
      profileImageURL: profileImageURL,
      coverImageURL: coverImageURL,
    );
  }

  // Factory constructor to convert from Firestore snapshot
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      friends: map['friends'] ?? 0,
      privateUserUID: map['privateUserUID'],
      userPoints: map['userPoints'] ?? 0,
      bio: map['bio'] ?? '',
      profileImageURL: map['profileImageURL'],
      coverImageURL: map['coverImageURL'],
      privateBio: map['privateBio'],
      privateProfileImageURL: map['privateProfileImageURL'],
      privateCoverImageURL: map['privateCoverImageURL'],
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
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'followers': followers,
      'following': following,
      'friends': friends,
      'privateUserUID': privateUserUID,
      'userPoints': userPoints,
      'bio': bio,
      'profileImageURL': profileImageURL,
      'coverImageURL': coverImageURL,
      'privateBio': privateBio,
      'privateProfileImageURL': privateProfileImageURL,
      'privateCoverImageURL': privateCoverImageURL,
    };
  }
}