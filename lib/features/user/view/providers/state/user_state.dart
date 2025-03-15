import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_state.freezed.dart';

@freezed
class UserState with _$UserState {
  const factory UserState({
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

    // Add fields for private profile
    String? privateBio,
    String? privateProfileImageURL,
    String? privateCoverImageURL,
    @Default(0) int? privateFollowers,
    @Default(0) int? privateFollowing,
    @Default(0) int? privateFriends,
    @Default(0) int? privateUserPoints,
    DateTime? privateCreatedAt,
    DateTime? privateUpdatedAt,
    List<String>? privateConnections,
    List<String>? groups,
  }) = _UserState;

  // Static factory method for Firestore
  static UserState fromFirestore(String id, Map<String, dynamic> map) {
    return UserState(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      friends: map['friends'] ?? 0,
      privateUserUID: map['privateUserUID'],
      userPoints: map['userPoints'] ?? 0,
      bio: map['bio'],
      profileImageURL: map['profileImageURL'],
      coverImageURL: map['coverImageURL'],
      privateBio: map['privateBio'],
      privateProfileImageURL: map['privateProfileImageURL'],
      privateCoverImageURL: map['privateCoverImageURL'],
      privateFollowers: map['privateFollowers'] ?? 0,
      privateFollowing: map['privateFollowing'] ?? 0,
      privateFriends: map['privateFriends'] ?? 0,
      privateUserPoints: map['privateUserPoints'] ?? 0,
      privateCreatedAt: (map['privateCreatedAt'] as Timestamp?)?.toDate(),
      privateUpdatedAt: (map['privateUpdatedAt'] as Timestamp?)?.toDate(),
      privateConnections: List<String>.from(map['privateConnections'] ?? []),
      groups: List<String>.from(map['groups'] ?? []),
    );
  }
}

// Extension method for Firestore conversion
extension UserStateExtension on UserState {
  Map<String, dynamic> toFirestore() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
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
      'privateFollowers': privateFollowers,
      'privateFollowing': privateFollowing,
      'privateFriends': privateFriends,
      'privateUserPoints': privateUserPoints,
      'privateCreatedAt': privateCreatedAt ?? FieldValue.serverTimestamp(),
      'privateUpdatedAt': privateUpdatedAt ?? FieldValue.serverTimestamp(),
      'privateConnections': privateConnections,
      'groups': groups,
    };
  }
}