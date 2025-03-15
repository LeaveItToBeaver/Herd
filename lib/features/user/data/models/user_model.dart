import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? followers;
  final int? following;
  final int? friends;
  final int? userPoints;
  final String? privateUserUID;
  final String? bio;
  final String? profileImageURL;
  final String? coverImageURL;

  // Add new fields for dual profiles
  final String? privateBio;
  final String? privateProfileImageURL;
  final String? privateCoverImageURL;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.createdAt,
    this.updatedAt,
    this.followers,
    this.following,
    this.friends,
    this.privateUserUID,
    this.userPoints,
    this.bio,
    this.profileImageURL,
    this.coverImageURL,
    // Add new fields to constructor
    this.privateBio,
    this.privateProfileImageURL,
    this.privateCoverImageURL,
  });

  // Update fromMap to include new fields
  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is Timestamp
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt'].toString()))
          : null,
      updatedAt: map['updatedAt'] != null
          ? (map['updatedAt'] is Timestamp
          ? (map['updatedAt'] as Timestamp).toDate()
          : DateTime.parse(map['updatedAt'].toString()))
          : null,
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      friends: map['friends'] ?? 0,
      privateUserUID: map['privateUserUID'] ?? '',
      userPoints: map['userPoints'] ?? 0,
      bio: map['bio'] ?? '',
      profileImageURL: map['profileImageURL'] ?? '',
      coverImageURL: map['coverImageURL'] ?? '',
      // Add new fields
      privateBio: map['privateBio'],
      privateProfileImageURL: map['privateProfileImageURL'],
      privateCoverImageURL: map['privateCoverImageURL'],
    );
  }

  // Update toMap to include new fields
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
      'updatedAt': updatedAt ?? FieldValue.serverTimestamp(),
      'followers': followers,
      'following': following,
      'friends': friends,
      'privateUserUID': privateUserUID,
      'userPoints': userPoints,
      'bio': bio,
      'profileImageURL': profileImageURL,
      'coverImageURL': coverImageURL,
      // Add new fields
      'privateBio': privateBio,
      'privateProfileImageURL': privateProfileImageURL,
      'privateCoverImageURL': privateCoverImageURL,
    };
  }
}