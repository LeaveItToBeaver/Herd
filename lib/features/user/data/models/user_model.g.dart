// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserModel _$UserModelFromJson(Map<String, dynamic> json) => _UserModel(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      friends: (json['friends'] as num?)?.toInt() ?? 0,
      userPoints: (json['userPoints'] as num?)?.toInt() ?? 0,
      friendsList: (json['friendsList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followersList: (json['followersList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      followingList: (json['followingList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      blockedUsers: (json['blockedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altUserUID: json['altUserUID'] as String?,
      bio: json['bio'] as String?,
      profileImageURL: json['profileImageURL'] as String?,
      coverImageURL: json['coverImageURL'] as String?,
      acceptedLegal: json['acceptedLegal'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      isPrivateAccount: json['isPrivateAccount'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String? ?? "",
      preferences: json['preferences'] as Map<String, dynamic>? ?? const {},
      notifications: json['notifications'] as Map<String, dynamic>? ?? const {},
      savedPosts: (json['savedPosts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      isNSFW: json['isNSFW'] as bool? ?? false,
      allowNSFW: json['allowNSFW'] as bool? ?? false,
      blurNSFW: json['blurNSFW'] as bool? ?? false,
      showHerdPostsInAltFeed: json['showHerdPostsInAltFeed'] as bool? ?? true,
      country: json['country'] as String?,
      city: json['city'] as String?,
      timezone: json['timezone'] as String?,
      totalPosts: (json['totalPosts'] as num?)?.toInt() ?? 0,
      totalComments: (json['totalComments'] as num?)?.toInt() ?? 0,
      totalLikes: (json['totalLikes'] as num?)?.toInt() ?? 0,
      lastActive: json['lastActive'] == null
          ? null
          : DateTime.parse(json['lastActive'] as String),
      altUsername: json['altUsername'] as String?,
      altBio: json['altBio'] as String?,
      altProfileImageURL: json['altProfileImageURL'] as String?,
      altCoverImageURL: json['altCoverImageURL'] as String?,
      altFollowers: (json['altFollowers'] as num?)?.toInt() ?? 0,
      altFollowing: (json['altFollowing'] as num?)?.toInt() ?? 0,
      altFriends: (json['altFriends'] as num?)?.toInt() ?? 0,
      altUserPoints: (json['altUserPoints'] as num?)?.toInt() ?? 0,
      altFriendsList: (json['altFriendsList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altFollowersList: (json['altFollowersList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altFollowingList: (json['altFollowingList'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altBlockedUsers: (json['altBlockedUsers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altTotalPosts: (json['altTotalPosts'] as num?)?.toInt() ?? 0,
      altTotalComments: (json['altTotalComments'] as num?)?.toInt() ?? 0,
      altTotalLikes: (json['altTotalLikes'] as num?)?.toInt() ?? 0,
      altSavedPosts: (json['altSavedPosts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altCreatedAt: json['altCreatedAt'] == null
          ? null
          : DateTime.parse(json['altCreatedAt'] as String),
      altUpdatedAt: json['altUpdatedAt'] == null
          ? null
          : DateTime.parse(json['altUpdatedAt'] as String),
      dateOfBirth: json['dateOfBirth'] == null
          ? null
          : DateTime.parse(json['dateOfBirth'] as String),
      altConnections: (json['altConnections'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altIsPrivateAccount: json['altIsPrivateAccount'] as bool? ?? false,
      groups: (json['groups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      moderatedGroups: (json['moderatedGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altGroups: (json['altGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altModeratedGroups: (json['altModeratedGroups'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
      altTrustScore: (json['altTrustScore'] as num?)?.toInt() ?? 0,
      reportCount: (json['reportCount'] as num?)?.toInt() ?? 0,
      altReportCount: (json['altReportCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      altIsActive: json['altIsActive'] as bool? ?? true,
      accountStatus: json['accountStatus'] as String? ?? "active",
      altAccountStatus: json['altAccountStatus'] as String? ?? "active",
      interests: (json['interests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altInterests: (json['altInterests'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      contentPreferences:
          json['contentPreferences'] as Map<String, dynamic>? ?? const {},
      altContentPreferences:
          json['altContentPreferences'] as Map<String, dynamic>? ?? const {},
      twoFactorEnabled: json['twoFactorEnabled'] as bool? ?? false,
      lastPasswordChange: json['lastPasswordChange'] == null
          ? null
          : DateTime.parse(json['lastPasswordChange'] as String),
      loginHistory: (json['loginHistory'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      isPremium: json['isPremium'] as bool? ?? false,
      premiumUntil: json['premiumUntil'] == null
          ? null
          : DateTime.parse(json['premiumUntil'] as String),
      walletBalance: (json['walletBalance'] as num?)?.toInt() ?? 0,
      pinnedPosts: (json['pinnedPosts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      altPinnedPosts: (json['altPinnedPosts'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$UserModelToJson(_UserModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'username': instance.username,
      'email': instance.email,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'followers': instance.followers,
      'following': instance.following,
      'friends': instance.friends,
      'userPoints': instance.userPoints,
      'friendsList': instance.friendsList,
      'followersList': instance.followersList,
      'followingList': instance.followingList,
      'blockedUsers': instance.blockedUsers,
      'altUserUID': instance.altUserUID,
      'bio': instance.bio,
      'profileImageURL': instance.profileImageURL,
      'coverImageURL': instance.coverImageURL,
      'acceptedLegal': instance.acceptedLegal,
      'isVerified': instance.isVerified,
      'isPrivateAccount': instance.isPrivateAccount,
      'fcmToken': instance.fcmToken,
      'preferences': instance.preferences,
      'notifications': instance.notifications,
      'savedPosts': instance.savedPosts,
      'isNSFW': instance.isNSFW,
      'allowNSFW': instance.allowNSFW,
      'blurNSFW': instance.blurNSFW,
      'showHerdPostsInAltFeed': instance.showHerdPostsInAltFeed,
      'country': instance.country,
      'city': instance.city,
      'timezone': instance.timezone,
      'totalPosts': instance.totalPosts,
      'totalComments': instance.totalComments,
      'totalLikes': instance.totalLikes,
      'lastActive': instance.lastActive?.toIso8601String(),
      'altUsername': instance.altUsername,
      'altBio': instance.altBio,
      'altProfileImageURL': instance.altProfileImageURL,
      'altCoverImageURL': instance.altCoverImageURL,
      'altFollowers': instance.altFollowers,
      'altFollowing': instance.altFollowing,
      'altFriends': instance.altFriends,
      'altUserPoints': instance.altUserPoints,
      'altFriendsList': instance.altFriendsList,
      'altFollowersList': instance.altFollowersList,
      'altFollowingList': instance.altFollowingList,
      'altBlockedUsers': instance.altBlockedUsers,
      'altTotalPosts': instance.altTotalPosts,
      'altTotalComments': instance.altTotalComments,
      'altTotalLikes': instance.altTotalLikes,
      'altSavedPosts': instance.altSavedPosts,
      'altCreatedAt': instance.altCreatedAt?.toIso8601String(),
      'altUpdatedAt': instance.altUpdatedAt?.toIso8601String(),
      'dateOfBirth': instance.dateOfBirth?.toIso8601String(),
      'altConnections': instance.altConnections,
      'altIsPrivateAccount': instance.altIsPrivateAccount,
      'groups': instance.groups,
      'moderatedGroups': instance.moderatedGroups,
      'altGroups': instance.altGroups,
      'altModeratedGroups': instance.altModeratedGroups,
      'trustScore': instance.trustScore,
      'altTrustScore': instance.altTrustScore,
      'reportCount': instance.reportCount,
      'altReportCount': instance.altReportCount,
      'isActive': instance.isActive,
      'altIsActive': instance.altIsActive,
      'accountStatus': instance.accountStatus,
      'altAccountStatus': instance.altAccountStatus,
      'interests': instance.interests,
      'altInterests': instance.altInterests,
      'contentPreferences': instance.contentPreferences,
      'altContentPreferences': instance.altContentPreferences,
      'twoFactorEnabled': instance.twoFactorEnabled,
      'lastPasswordChange': instance.lastPasswordChange?.toIso8601String(),
      'loginHistory': instance.loginHistory,
      'isPremium': instance.isPremium,
      'premiumUntil': instance.premiumUntil?.toIso8601String(),
      'walletBalance': instance.walletBalance,
      'pinnedPosts': instance.pinnedPosts,
      'altPinnedPosts': instance.altPinnedPosts,
    };
