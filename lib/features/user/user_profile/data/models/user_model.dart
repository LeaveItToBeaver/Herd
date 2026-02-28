import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/user/user_profile/data/models/firestore_parse_helpers.dart';

// Re-export extensions so existing importers of user_model.dart
// automatically get all the helper getters/methods.
export 'package:herdapp/features/user/user_profile/data/extensions/user_profile_extensions.dart';
export 'package:herdapp/features/user/user_profile/data/extensions/alt_profile_extensions.dart';
export 'package:herdapp/features/user/user_profile/data/extensions/account_status_extensions.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

/// The core user model that maps 1:1 with the `users/{userId}` Firestore
/// document.
///
/// All fields live here because they share a single document. Business-logic
/// helpers are split into focused extensions:
///
/// - [UserProfileExtensions] – profile completeness, activity, engagement
/// - [AltProfileExtensions] – alt profile helpers, privacy toggles
/// - [AccountStatusExtensions] – deletion lifecycle, premium status
@freezed
abstract class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required String id,
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int followers,
    @Default(0) int following,
    @Default(0) int friends,
    @Default(0) int userPoints,
    @Default([]) List<String> friendsList,
    @Default([]) List<String> followersList,
    @Default([]) List<String> followingList,
    @Default([]) List<String> blockedUsers,
    @Default({}) Map<String, dynamic> herdAndRole,
    String? role,
    String? altUserUID,
    String? bio,
    String? profileImageURL,
    String? coverImageURL,
    @Default(false) bool acceptedLegal,
    @Default(false) bool isVerified,
    @Default(false) bool isPrivateAccount,
    @Default("") String fcmToken,
    @Default({}) Map<String, dynamic> preferences,
    @Default({}) Map<String, dynamic> notifications,
    @Default([]) List<String> savedPosts,
    @Default(false) bool isNSFW,
    @Default(false) bool allowNSFW,
    @Default(false) bool blurNSFW,
    @Default(true) bool showHerdPostsInAltFeed,

    // Location
    String? country,
    String? city,
    String? timezone,

    // Activity metrics
    @Default(0) int totalPosts,
    @Default(0) int totalComments,
    @Default(0) int totalLikes,
    DateTime? lastActive,

    // Alt profile fields
    String? altUsername,
    String? altBio,
    String? altProfileImageURL,
    String? altCoverImageURL,
    @Default(0) int altFollowers,
    @Default(0) int altFollowing,
    @Default(0) int altFriends,
    @Default(0) int altUserPoints,
    @Default([]) List<String> altFriendsList,
    @Default([]) List<String> altFollowersList,
    @Default([]) List<String> altFollowingList,
    @Default([]) List<String> altBlockedUsers,
    @Default(0) int altTotalPosts,
    @Default(0) int altTotalComments,
    @Default(0) int altTotalLikes,
    @Default([]) List<String> altSavedPosts,
    DateTime? altCreatedAt,
    DateTime? altUpdatedAt,
    DateTime? dateOfBirth,
    @Default([]) List<String> altConnections,
    @Default(false) bool altIsPrivateAccount,

    // Community
    @Default([]) List<String> groups,
    @Default([]) List<String> moderatedGroups,
    @Default([]) List<String> altGroups,
    @Default([]) List<String> altModeratedGroups,

    // Reputation and trust
    @Default(0) int trustScore,
    @Default(0) int altTrustScore,
    @Default(0) int reportCount,
    @Default(0) int altReportCount,

    // Account status
    @Default(true) bool isActive,
    @Default(true) bool altIsActive,
    @Default("active") String accountStatus,
    @Default("active") String altAccountStatus,

    // Interests
    @Default([]) List<String> interests,
    @Default([]) List<String> altInterests,

    // Content engagement preferences
    @Default({}) Map<String, dynamic> contentPreferences,
    @Default({}) Map<String, dynamic> altContentPreferences,

    // Account security
    @Default(false) bool twoFactorEnabled,
    DateTime? lastPasswordChange,
    @Default([]) List<Map<String, dynamic>> loginHistory,

    // Monetization / premium
    @Default(false) bool isPremium,
    DateTime? premiumUntil,
    @Default(0) int walletBalance,

    // Pinned posts (max 5 each)
    @Default([]) List<String> pinnedPosts,
    @Default([]) List<String> altPinnedPosts,

    // Account deletion
    DateTime? markedForDeleteAt,
  }) = _UserModel;

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fcmToken: '',
    );
  }

  factory UserModel.fromMap(String id, Map<String, dynamic> map) {
    return UserModel(
      id: id,
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      createdAt: FirestoreParseHelpers.parseDateTime(map['createdAt']),
      updatedAt: FirestoreParseHelpers.parseDateTime(map['updatedAt']),
      dateOfBirth: FirestoreParseHelpers.parseDateTime(map['dateOfBirth']),
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      friends: map['friends'] ?? 0,
      friendsList: FirestoreParseHelpers.parseStringList(map['friendsList']),
      followersList: FirestoreParseHelpers.parseStringList(map['followersList']),
      followingList: FirestoreParseHelpers.parseStringList(map['followingList']),
      blockedUsers: FirestoreParseHelpers.parseStringList(map['blockedUsers']),
      herdAndRole: map['herdAndRole'] ?? {},
      role: map['role'] ?? '',
      altUserUID: map['altUserUID'],
      userPoints: map['userPoints'] ?? 0,
      bio: map['bio'] ?? '',
      profileImageURL: map['profileImageURL'],
      coverImageURL: map['coverImageURL'],
      acceptedLegal: map['acceptedLegal'] ?? false,
      isVerified: map['isVerified'] ?? false,
      isPrivateAccount: map['isPrivateAccount'] ?? false,
      fcmToken: map['fcmToken'] ?? '',
      preferences: map['preferences'] ?? {},
      notifications: map['notifications'] ?? {},
      savedPosts: FirestoreParseHelpers.parseStringList(map['savedPosts']),
      isNSFW: map['isNSFW'] ?? false,
      allowNSFW: map['allowNSFW'] ?? false,
      blurNSFW: map['blurNSFW'] ?? false,
      showHerdPostsInAltFeed: map['showHerdPostsInAltFeed'] ?? true,
      country: map['country'],
      city: map['city'],
      timezone: map['timezone'],
      totalPosts: map['totalPosts'] ?? 0,
      totalComments: map['totalComments'] ?? 0,
      totalLikes: map['totalLikes'] ?? 0,
      lastActive: FirestoreParseHelpers.parseDateTime(map['lastActive']),
      altUsername: map['altUsername'],
      altBio: map['altBio'],
      altProfileImageURL: map['altProfileImageURL'],
      altCoverImageURL: map['altCoverImageURL'],
      altFollowers: map['altFollowers'] ?? 0,
      altFollowing: map['altFollowing'] ?? 0,
      altFriends: map['altFriends'] ?? 0,
      altUserPoints: map['altUserPoints'] ?? 0,
      altFriendsList:
          FirestoreParseHelpers.parseStringList(map['altFriendsList']),
      altFollowersList:
          FirestoreParseHelpers.parseStringList(map['altFollowersList']),
      altFollowingList:
          FirestoreParseHelpers.parseStringList(map['altFollowingList']),
      altBlockedUsers:
          FirestoreParseHelpers.parseStringList(map['altBlockedUsers']),
      altTotalPosts: map['altTotalPosts'] ?? 0,
      altTotalComments: map['altTotalComments'] ?? 0,
      altTotalLikes: map['altTotalLikes'] ?? 0,
      altSavedPosts:
          FirestoreParseHelpers.parseStringList(map['altSavedPosts']),
      altCreatedAt: FirestoreParseHelpers.parseDateTime(map['altCreatedAt']),
      altUpdatedAt: FirestoreParseHelpers.parseDateTime(map['altUpdatedAt']),
      altConnections:
          FirestoreParseHelpers.parseStringList(map['altConnections']),
      altIsPrivateAccount: map['altIsPrivateAccount'] ?? false,
      groups: FirestoreParseHelpers.parseStringList(map['groups']),
      moderatedGroups:
          FirestoreParseHelpers.parseStringList(map['moderatedGroups']),
      altGroups: FirestoreParseHelpers.parseStringList(map['altGroups']),
      altModeratedGroups:
          FirestoreParseHelpers.parseStringList(map['altModeratedGroups']),
      trustScore: map['trustScore'] ?? 0,
      altTrustScore: map['altTrustScore'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
      altReportCount: map['altReportCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      altIsActive: map['altIsActive'] ?? true,
      accountStatus: map['accountStatus'] ?? 'active',
      altAccountStatus: map['altAccountStatus'] ?? 'active',
      interests: FirestoreParseHelpers.parseStringList(map['interests']),
      altInterests: FirestoreParseHelpers.parseStringList(map['altInterests']),
      contentPreferences: map['contentPreferences'] ?? {},
      altContentPreferences: map['altContentPreferences'] ?? {},
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      lastPasswordChange:
          FirestoreParseHelpers.parseDateTime(map['lastPasswordChange']),
      loginHistory: FirestoreParseHelpers.parseMapList(map['loginHistory']),
      isPremium: map['isPremium'] ?? false,
      premiumUntil: FirestoreParseHelpers.parseDateTime(map['premiumUntil']),
      walletBalance: map['walletBalance'] ?? 0,
      pinnedPosts: FirestoreParseHelpers.parseStringList(map['pinnedPosts']),
      altPinnedPosts:
          FirestoreParseHelpers.parseStringList(map['altPinnedPosts']),
      markedForDeleteAt:
          FirestoreParseHelpers.parseDateTime(map['markedForDeleteAt']),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'username': username,
      'email': email,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'dateOfBirth':
          dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'followers': followers,
      'following': following,
      'friends': friends,
      'friendsList': friendsList,
      'followersList': followersList,
      'followingList': followingList,
      'blockedUsers': blockedUsers,
      'herdAndRole': herdAndRole,
      'role': role,
      'altUserUID': altUserUID,
      'userPoints': userPoints,
      'bio': bio,
      'profileImageURL': profileImageURL,
      'coverImageURL': coverImageURL,
      'acceptedLegal': acceptedLegal,
      'isVerified': isVerified,
      'isPrivateAccount': isPrivateAccount,
      'fcmToken': fcmToken,
      'preferences': preferences,
      'notifications': notifications,
      'savedPosts': savedPosts,
      'isNSFW': isNSFW,
      'allowNSFW': allowNSFW,
      'blurNSFW': blurNSFW,
      'showHerdPostsInAltFeed': showHerdPostsInAltFeed,
      'country': country,
      'city': city,
      'timezone': timezone,
      'totalPosts': totalPosts,
      'totalComments': totalComments,
      'totalLikes': totalLikes,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'altUsername': altUsername,
      'altBio': altBio,
      'altProfileImageURL': altProfileImageURL,
      'altCoverImageURL': altCoverImageURL,
      'altFollowers': altFollowers,
      'altFollowing': altFollowing,
      'altFriends': altFriends,
      'altUserPoints': altUserPoints,
      'altFriendsList': altFriendsList,
      'altFollowersList': altFollowersList,
      'altFollowingList': altFollowingList,
      'altBlockedUsers': altBlockedUsers,
      'altTotalPosts': altTotalPosts,
      'altTotalComments': altTotalComments,
      'altTotalLikes': altTotalLikes,
      'altSavedPosts': altSavedPosts,
      'altCreatedAt':
          altCreatedAt != null ? Timestamp.fromDate(altCreatedAt!) : null,
      'altUpdatedAt': altUpdatedAt != null
          ? Timestamp.fromDate(altUpdatedAt!)
          : FieldValue.serverTimestamp(),
      'altConnections': altConnections,
      'altIsPrivateAccount': altIsPrivateAccount,
      'groups': groups,
      'moderatedGroups': moderatedGroups,
      'altGroups': altGroups,
      'altModeratedGroups': altModeratedGroups,
      'trustScore': trustScore,
      'altTrustScore': altTrustScore,
      'reportCount': reportCount,
      'altReportCount': altReportCount,
      'isActive': isActive,
      'altIsActive': altIsActive,
      'accountStatus': accountStatus,
      'altAccountStatus': altAccountStatus,
      'interests': interests,
      'altInterests': altInterests,
      'contentPreferences': contentPreferences,
      'altContentPreferences': altContentPreferences,
      'twoFactorEnabled': twoFactorEnabled,
      'lastPasswordChange': lastPasswordChange != null
          ? Timestamp.fromDate(lastPasswordChange!)
          : null,
      'loginHistory': loginHistory,
      'isPremium': isPremium,
      'premiumUntil':
          premiumUntil != null ? Timestamp.fromDate(premiumUntil!) : null,
      'walletBalance': walletBalance,
      'pinnedPosts': pinnedPosts,
      'altPinnedPosts': altPinnedPosts,
      'markedForDeleteAt': markedForDeleteAt != null
          ? Timestamp.fromDate(markedForDeleteAt!)
          : null,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => toMap();
}
