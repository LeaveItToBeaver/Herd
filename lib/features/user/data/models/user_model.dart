import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart'; // For JSON serialization

@freezed
abstract class UserModel with _$UserModel {
  const UserModel._(); // Add this to allow custom methods within the class

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
    String? altUserUID,
    String? bio,
    String? profileImageURL,
    String? coverImageURL,
    @Default(false) bool acceptedLegal,
    @Default(false) bool isVerified,
    @Default(false) bool isPrivateAccount,
    @Default("") String fcmToken, // Firebase Cloud Messaging token
    @Default({}) Map<String, dynamic> preferences,
    @Default({}) Map<String, dynamic> notifications,
    @Default([]) List<String> savedPosts,
    @Default(false) bool isNSFW, // Not Safe For Work flag
    @Default(false) bool allowNSFW, // Not Safe For Work flag
    @Default(false) bool blurNSFW, // Blur NSFW content
    @Default(true) bool showHerdPostsInAltFeed, // Blur NSFW content

    // Location data
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

    // Community fields
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
    @Default("active")
    String accountStatus, // active, suspended, restricted, etc.
    @Default("active") String altAccountStatus,

    // User categories and interests
    @Default([]) List<String> interests,
    @Default([]) List<String> altInterests,

    // Content engagement preferences
    @Default({}) Map<String, dynamic> contentPreferences,
    @Default({}) Map<String, dynamic> altContentPreferences,

    // Account security
    @Default(false) bool twoFactorEnabled,
    DateTime? lastPasswordChange,
    @Default([]) List<Map<String, dynamic>> loginHistory,

    // Monetization and premium features
    @Default(false) bool isPremium,
    DateTime? premiumUntil,
    @Default(0) int walletBalance,
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      fcmToken: '',
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
      dateOfBirth: _parseDateTime(map['dateOfBirth']),
      followers: map['followers'] ?? 0,
      following: map['following'] ?? 0,
      friends: map['friends'] ?? 0,
      friendsList: _parseStringList(map['friendsList']),
      followersList: _parseStringList(map['followersList']),
      followingList: _parseStringList(map['followingList']),
      blockedUsers: _parseStringList(map['blockedUsers']),
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
      savedPosts: _parseStringList(map['savedPosts']),
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
      lastActive: _parseDateTime(map['lastActive']),
      altUsername: map['altUsername'],
      altBio: map['altBio'],
      altProfileImageURL: map['altProfileImageURL'],
      altCoverImageURL: map['altCoverImageURL'],
      altFollowers: map['altFollowers'] ?? 0,
      altFollowing: map['altFollowing'] ?? 0,
      altFriends: map['altFriends'] ?? 0,
      altUserPoints: map['altUserPoints'] ?? 0,
      altFriendsList: _parseStringList(map['altFriendsList']),
      altFollowersList: _parseStringList(map['altFollowersList']),
      altFollowingList: _parseStringList(map['altFollowingList']),
      altBlockedUsers: _parseStringList(map['altBlockedUsers']),
      altTotalPosts: map['altTotalPosts'] ?? 0,
      altTotalComments: map['altTotalComments'] ?? 0,
      altTotalLikes: map['altTotalLikes'] ?? 0,
      altSavedPosts: _parseStringList(map['altSavedPosts']),
      altCreatedAt: _parseDateTime(map['altCreatedAt']),
      altUpdatedAt: _parseDateTime(map['altUpdatedAt']),
      altConnections: _parseStringList(map['altConnections']),
      altIsPrivateAccount: map['altIsPrivateAccount'] ?? false,
      groups: _parseStringList(map['groups']),
      moderatedGroups: _parseStringList(map['moderatedGroups']),
      altGroups: _parseStringList(map['altGroups']),
      altModeratedGroups: _parseStringList(map['altModeratedGroups']),
      trustScore: map['trustScore'] ?? 0,
      altTrustScore: map['altTrustScore'] ?? 0,
      reportCount: map['reportCount'] ?? 0,
      altReportCount: map['altReportCount'] ?? 0,
      isActive: map['isActive'] ?? true,
      altIsActive: map['altIsActive'] ?? true,
      accountStatus: map['accountStatus'] ?? 'active',
      altAccountStatus: map['altAccountStatus'] ?? 'active',
      interests: _parseStringList(map['interests']),
      altInterests: _parseStringList(map['altInterests']),
      contentPreferences: map['contentPreferences'] ?? {},
      altContentPreferences: map['altContentPreferences'] ?? {},
      twoFactorEnabled: map['twoFactorEnabled'] ?? false,
      lastPasswordChange: _parseDateTime(map['lastPasswordChange']),
      loginHistory: _parseMapList(map['loginHistory']),
      isPremium: map['isPremium'] ?? false,
      premiumUntil: _parseDateTime(map['premiumUntil']),
      walletBalance: map['walletBalance'] ?? 0,
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

  // Helper for parsing string lists from Firestore
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return [];
  }

  // Helper for parsing list of maps from Firestore
  static List<Map<String, dynamic>> _parseMapList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value
          .map((item) => item is Map
              ? Map<String, dynamic>.from(item)
              : <String, dynamic>{})
          .toList();
    }
    return [];
  }

  // Convert to Firestore Map
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
    };
  }

  // Get full name
  String get fullName => '$firstName $lastName'.trim();

  // Check if user is premium
  bool get hasPremium =>
      isPremium &&
      (premiumUntil == null || premiumUntil!.isAfter(DateTime.now()));

  // Get user status
  bool get isActiveUser => isActive && accountStatus == 'active';

  // Get alt user status
  bool get isActiveAltUser => altIsActive && altAccountStatus == 'active';

  // Method to create alt account
  UserModel createAltAccount(String altId) {
    final result = copyWith(
      altUserUID: altId,
      altCreatedAt: DateTime.now(),
      altUpdatedAt: DateTime.now(),
    );
    return result;
  }

// Method to toggle account privacy - with type casting
  UserModel togglePrivacy({bool? forAltAccount = false}) {
    if (forAltAccount == true) {
      return copyWith(altIsPrivateAccount: !altIsPrivateAccount);
    }
    return copyWith(isPrivateAccount: !isPrivateAccount);
  }

  // Method to link public and alt accounts
  static Future<void> linkAccounts(
      String publicUserId, String altUserId) async {
    final batch = FirebaseFirestore.instance.batch();

    final publicRef =
        FirebaseFirestore.instance.collection('users').doc(publicUserId);
    final altRef =
        FirebaseFirestore.instance.collection('users').doc(altUserId);

    batch.update(publicRef, {'altUserUID': altUserId});
    batch.update(altRef, {'altUserUID': publicUserId});

    await batch.commit();
  }

  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => toMap();

  // Add a method to determine if a user can be safely deleted
  bool get canBeDeleted {
    // Check for related data that would prevent deletion
    bool hasContent = totalPosts > 0 || totalComments > 0;
    bool hasAltContent = altTotalPosts > 0 || altTotalComments > 0;
    bool isGroupModerator =
        moderatedGroups.isNotEmpty || altModeratedGroups.isNotEmpty;

    return !hasContent && !hasAltContent && !isGroupModerator;
  }

  // Determine if the user needs to complete their profile
  bool get isProfileComplete {
    if (firstName.isEmpty || lastName.isEmpty) return false;
    if (bio == null || bio!.isEmpty) return false;
    if (profileImageURL == null) return false;
    return true;
  }

  // Determine if alt profile is complete
  bool get isAltProfileComplete {
    if (altUsername == null || altUsername!.isEmpty) return false;
    if (altProfileImageURL == null) return false;
    return true;
  }

  // Calculate activity level (1-10) based on engagement
  int get activityLevel {
    final now = DateTime.now();
    final lastActiveDate = lastActive ?? updatedAt ?? createdAt;
    if (lastActiveDate == null) return 1;

    // Calculate days since last activity
    final daysSinceActive = now.difference(lastActiveDate).inDays;

    // Calculate activity score based on content and recency
    int baseScore = 0;

    // Content score (max 5 points)
    final contentScore =
        ((totalPosts + totalComments) / 10).clamp(0, 5).floor();
    baseScore += contentScore;

    // Recency score (max 5 points)
    int recencyScore = 5;
    if (daysSinceActive > 1) recencyScore = 4;
    if (daysSinceActive > 7) recencyScore = 3;
    if (daysSinceActive > 30) recencyScore = 2;
    if (daysSinceActive > 90) recencyScore = 1;
    if (daysSinceActive > 180) recencyScore = 0;

    baseScore += recencyScore;

    // Ensure range is 1-10
    return baseScore.clamp(1, 10);
  }

  // Determine user engagement type based on behavior
  String get engagementType {
    // Calculate ratios to determine user behavior
    final commentRatio = totalComments > 0
        ? totalComments / (totalPosts > 0 ? totalPosts : 1)
        : 0;
    final likeRatio =
        totalLikes > 0 ? totalLikes / (totalPosts + totalComments) : 0;

    if (totalPosts > 50 && commentRatio < 1) {
      return 'Creator'; // Posts a lot, comments less
    } else if (commentRatio > 5) {
      return 'Commenter'; // Comments much more than posts
    } else if (likeRatio > 10 && totalPosts < 10) {
      return 'Observer'; // Mostly likes, rarely posts
    } else if (followersList.length > followingList.length * 2) {
      return 'Influencer'; // Has many more followers than following
    } else {
      return 'Balanced'; // Balanced engagement
    }
  }

  // Method to get a map of incomplete profile fields for onboarding
  Map<String, String> getIncompleteFields() {
    final Map<String, String> incomplete = {};

    if (firstName.isEmpty) incomplete['firstName'] = 'First name is required';
    if (lastName.isEmpty) incomplete['lastName'] = 'Last name is required';
    if (bio == null || bio!.isEmpty) incomplete['bio'] = 'Add a short bio';
    if (profileImageURL == null) {
      incomplete['profileImage'] = 'Add a profile picture';
    }
    if (interests.isEmpty) {
      incomplete['interests'] = 'Add at least one interest';
    }

    return incomplete;
  }
}
