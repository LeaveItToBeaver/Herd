// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserModel implements DiagnosticableTreeMixin {
  String get id;
  String get firstName;
  String get lastName;
  String get username;
  String get email;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  int get followers;
  int get following;
  int get friends;
  int get userPoints;
  List<String> get friendsList;
  List<String> get followersList;
  List<String> get followingList;
  List<String> get blockedUsers;
  Map<String, dynamic> get herdAndRole;
  String? get role;
  String? get altUserUID;
  String? get bio;
  String? get profileImageURL;
  String? get coverImageURL;
  bool get acceptedLegal;
  bool get isVerified;
  bool get isPrivateAccount;
  String get fcmToken;
  Map<String, dynamic> get preferences;
  Map<String, dynamic> get notifications;
  List<String> get savedPosts;
  bool get isNSFW;
  bool get allowNSFW;
  bool get blurNSFW;
  bool get showHerdPostsInAltFeed; // Location
  String? get country;
  String? get city;
  String? get timezone; // Activity metrics
  int get totalPosts;
  int get totalComments;
  int get totalLikes;
  DateTime? get lastActive; // Alt profile fields
  String? get altUsername;
  String? get altBio;
  String? get altProfileImageURL;
  String? get altCoverImageURL;
  int get altFollowers;
  int get altFollowing;
  int get altFriends;
  int get altUserPoints;
  List<String> get altFriendsList;
  List<String> get altFollowersList;
  List<String> get altFollowingList;
  List<String> get altBlockedUsers;
  int get altTotalPosts;
  int get altTotalComments;
  int get altTotalLikes;
  List<String> get altSavedPosts;
  DateTime? get altCreatedAt;
  DateTime? get altUpdatedAt;
  DateTime? get dateOfBirth;
  List<String> get altConnections;
  bool get altIsPrivateAccount; // Community
  List<String> get groups;
  List<String> get moderatedGroups;
  List<String> get altGroups;
  List<String> get altModeratedGroups; // Reputation and trust
  int get trustScore;
  int get altTrustScore;
  int get reportCount;
  int get altReportCount; // Account status
  bool get isActive;
  bool get altIsActive;
  String get accountStatus;
  String get altAccountStatus; // Interests
  List<String> get interests;
  List<String> get altInterests; // Content engagement preferences
  Map<String, dynamic> get contentPreferences;
  Map<String, dynamic> get altContentPreferences; // Account security
  bool get twoFactorEnabled;
  DateTime? get lastPasswordChange;
  List<Map<String, dynamic>> get loginHistory; // Monetization / premium
  bool get isPremium;
  DateTime? get premiumUntil;
  int get walletBalance; // Pinned posts (max 5 each)
  List<String> get pinnedPosts;
  List<String> get altPinnedPosts; // Account deletion
  DateTime? get markedForDeleteAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'UserModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('firstName', firstName))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('username', username))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('followers', followers))
      ..add(DiagnosticsProperty('following', following))
      ..add(DiagnosticsProperty('friends', friends))
      ..add(DiagnosticsProperty('userPoints', userPoints))
      ..add(DiagnosticsProperty('friendsList', friendsList))
      ..add(DiagnosticsProperty('followersList', followersList))
      ..add(DiagnosticsProperty('followingList', followingList))
      ..add(DiagnosticsProperty('blockedUsers', blockedUsers))
      ..add(DiagnosticsProperty('herdAndRole', herdAndRole))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('altUserUID', altUserUID))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('acceptedLegal', acceptedLegal))
      ..add(DiagnosticsProperty('isVerified', isVerified))
      ..add(DiagnosticsProperty('isPrivateAccount', isPrivateAccount))
      ..add(DiagnosticsProperty('fcmToken', fcmToken))
      ..add(DiagnosticsProperty('preferences', preferences))
      ..add(DiagnosticsProperty('notifications', notifications))
      ..add(DiagnosticsProperty('savedPosts', savedPosts))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('allowNSFW', allowNSFW))
      ..add(DiagnosticsProperty('blurNSFW', blurNSFW))
      ..add(
          DiagnosticsProperty('showHerdPostsInAltFeed', showHerdPostsInAltFeed))
      ..add(DiagnosticsProperty('country', country))
      ..add(DiagnosticsProperty('city', city))
      ..add(DiagnosticsProperty('timezone', timezone))
      ..add(DiagnosticsProperty('totalPosts', totalPosts))
      ..add(DiagnosticsProperty('totalComments', totalComments))
      ..add(DiagnosticsProperty('totalLikes', totalLikes))
      ..add(DiagnosticsProperty('lastActive', lastActive))
      ..add(DiagnosticsProperty('altUsername', altUsername))
      ..add(DiagnosticsProperty('altBio', altBio))
      ..add(DiagnosticsProperty('altProfileImageURL', altProfileImageURL))
      ..add(DiagnosticsProperty('altCoverImageURL', altCoverImageURL))
      ..add(DiagnosticsProperty('altFollowers', altFollowers))
      ..add(DiagnosticsProperty('altFollowing', altFollowing))
      ..add(DiagnosticsProperty('altFriends', altFriends))
      ..add(DiagnosticsProperty('altUserPoints', altUserPoints))
      ..add(DiagnosticsProperty('altFriendsList', altFriendsList))
      ..add(DiagnosticsProperty('altFollowersList', altFollowersList))
      ..add(DiagnosticsProperty('altFollowingList', altFollowingList))
      ..add(DiagnosticsProperty('altBlockedUsers', altBlockedUsers))
      ..add(DiagnosticsProperty('altTotalPosts', altTotalPosts))
      ..add(DiagnosticsProperty('altTotalComments', altTotalComments))
      ..add(DiagnosticsProperty('altTotalLikes', altTotalLikes))
      ..add(DiagnosticsProperty('altSavedPosts', altSavedPosts))
      ..add(DiagnosticsProperty('altCreatedAt', altCreatedAt))
      ..add(DiagnosticsProperty('altUpdatedAt', altUpdatedAt))
      ..add(DiagnosticsProperty('dateOfBirth', dateOfBirth))
      ..add(DiagnosticsProperty('altConnections', altConnections))
      ..add(DiagnosticsProperty('altIsPrivateAccount', altIsPrivateAccount))
      ..add(DiagnosticsProperty('groups', groups))
      ..add(DiagnosticsProperty('moderatedGroups', moderatedGroups))
      ..add(DiagnosticsProperty('altGroups', altGroups))
      ..add(DiagnosticsProperty('altModeratedGroups', altModeratedGroups))
      ..add(DiagnosticsProperty('trustScore', trustScore))
      ..add(DiagnosticsProperty('altTrustScore', altTrustScore))
      ..add(DiagnosticsProperty('reportCount', reportCount))
      ..add(DiagnosticsProperty('altReportCount', altReportCount))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('altIsActive', altIsActive))
      ..add(DiagnosticsProperty('accountStatus', accountStatus))
      ..add(DiagnosticsProperty('altAccountStatus', altAccountStatus))
      ..add(DiagnosticsProperty('interests', interests))
      ..add(DiagnosticsProperty('altInterests', altInterests))
      ..add(DiagnosticsProperty('contentPreferences', contentPreferences))
      ..add(DiagnosticsProperty('altContentPreferences', altContentPreferences))
      ..add(DiagnosticsProperty('twoFactorEnabled', twoFactorEnabled))
      ..add(DiagnosticsProperty('lastPasswordChange', lastPasswordChange))
      ..add(DiagnosticsProperty('loginHistory', loginHistory))
      ..add(DiagnosticsProperty('isPremium', isPremium))
      ..add(DiagnosticsProperty('premiumUntil', premiumUntil))
      ..add(DiagnosticsProperty('walletBalance', walletBalance))
      ..add(DiagnosticsProperty('pinnedPosts', pinnedPosts))
      ..add(DiagnosticsProperty('altPinnedPosts', altPinnedPosts))
      ..add(DiagnosticsProperty('markedForDeleteAt', markedForDeleteAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.followers, followers) ||
                other.followers == followers) &&
            (identical(other.following, following) ||
                other.following == following) &&
            (identical(other.friends, friends) || other.friends == friends) &&
            (identical(other.userPoints, userPoints) ||
                other.userPoints == userPoints) &&
            const DeepCollectionEquality()
                .equals(other.friendsList, friendsList) &&
            const DeepCollectionEquality()
                .equals(other.followersList, followersList) &&
            const DeepCollectionEquality()
                .equals(other.followingList, followingList) &&
            const DeepCollectionEquality()
                .equals(other.blockedUsers, blockedUsers) &&
            const DeepCollectionEquality()
                .equals(other.herdAndRole, herdAndRole) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.altUserUID, altUserUID) ||
                other.altUserUID == altUserUID) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            (identical(other.acceptedLegal, acceptedLegal) ||
                other.acceptedLegal == acceptedLegal) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isPrivateAccount, isPrivateAccount) ||
                other.isPrivateAccount == isPrivateAccount) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            const DeepCollectionEquality()
                .equals(other.preferences, preferences) &&
            const DeepCollectionEquality()
                .equals(other.notifications, notifications) &&
            const DeepCollectionEquality()
                .equals(other.savedPosts, savedPosts) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
            (identical(other.allowNSFW, allowNSFW) ||
                other.allowNSFW == allowNSFW) &&
            (identical(other.blurNSFW, blurNSFW) ||
                other.blurNSFW == blurNSFW) &&
            (identical(other.showHerdPostsInAltFeed, showHerdPostsInAltFeed) ||
                other.showHerdPostsInAltFeed == showHerdPostsInAltFeed) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.totalPosts, totalPosts) ||
                other.totalPosts == totalPosts) &&
            (identical(other.totalComments, totalComments) ||
                other.totalComments == totalComments) &&
            (identical(other.totalLikes, totalLikes) ||
                other.totalLikes == totalLikes) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive) &&
            (identical(other.altUsername, altUsername) ||
                other.altUsername == altUsername) &&
            (identical(other.altBio, altBio) || other.altBio == altBio) &&
            (identical(other.altProfileImageURL, altProfileImageURL) ||
                other.altProfileImageURL == altProfileImageURL) &&
            (identical(other.altCoverImageURL, altCoverImageURL) ||
                other.altCoverImageURL == altCoverImageURL) &&
            (identical(other.altFollowers, altFollowers) ||
                other.altFollowers == altFollowers) &&
            (identical(other.altFollowing, altFollowing) ||
                other.altFollowing == altFollowing) &&
            (identical(other.altFriends, altFriends) ||
                other.altFriends == altFriends) &&
            (identical(other.altUserPoints, altUserPoints) ||
                other.altUserPoints == altUserPoints) &&
            const DeepCollectionEquality()
                .equals(other.altFriendsList, altFriendsList) &&
            const DeepCollectionEquality()
                .equals(other.altFollowersList, altFollowersList) &&
            const DeepCollectionEquality()
                .equals(other.altFollowingList, altFollowingList) &&
            const DeepCollectionEquality()
                .equals(other.altBlockedUsers, altBlockedUsers) &&
            (identical(other.altTotalPosts, altTotalPosts) || other.altTotalPosts == altTotalPosts) &&
            (identical(other.altTotalComments, altTotalComments) || other.altTotalComments == altTotalComments) &&
            (identical(other.altTotalLikes, altTotalLikes) || other.altTotalLikes == altTotalLikes) &&
            const DeepCollectionEquality().equals(other.altSavedPosts, altSavedPosts) &&
            (identical(other.altCreatedAt, altCreatedAt) || other.altCreatedAt == altCreatedAt) &&
            (identical(other.altUpdatedAt, altUpdatedAt) || other.altUpdatedAt == altUpdatedAt) &&
            (identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth) &&
            const DeepCollectionEquality().equals(other.altConnections, altConnections) &&
            (identical(other.altIsPrivateAccount, altIsPrivateAccount) || other.altIsPrivateAccount == altIsPrivateAccount) &&
            const DeepCollectionEquality().equals(other.groups, groups) &&
            const DeepCollectionEquality().equals(other.moderatedGroups, moderatedGroups) &&
            const DeepCollectionEquality().equals(other.altGroups, altGroups) &&
            const DeepCollectionEquality().equals(other.altModeratedGroups, altModeratedGroups) &&
            (identical(other.trustScore, trustScore) || other.trustScore == trustScore) &&
            (identical(other.altTrustScore, altTrustScore) || other.altTrustScore == altTrustScore) &&
            (identical(other.reportCount, reportCount) || other.reportCount == reportCount) &&
            (identical(other.altReportCount, altReportCount) || other.altReportCount == altReportCount) &&
            (identical(other.isActive, isActive) || other.isActive == isActive) &&
            (identical(other.altIsActive, altIsActive) || other.altIsActive == altIsActive) &&
            (identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus) &&
            (identical(other.altAccountStatus, altAccountStatus) || other.altAccountStatus == altAccountStatus) &&
            const DeepCollectionEquality().equals(other.interests, interests) &&
            const DeepCollectionEquality().equals(other.altInterests, altInterests) &&
            const DeepCollectionEquality().equals(other.contentPreferences, contentPreferences) &&
            const DeepCollectionEquality().equals(other.altContentPreferences, altContentPreferences) &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) || other.twoFactorEnabled == twoFactorEnabled) &&
            (identical(other.lastPasswordChange, lastPasswordChange) || other.lastPasswordChange == lastPasswordChange) &&
            const DeepCollectionEquality().equals(other.loginHistory, loginHistory) &&
            (identical(other.isPremium, isPremium) || other.isPremium == isPremium) &&
            (identical(other.premiumUntil, premiumUntil) || other.premiumUntil == premiumUntil) &&
            (identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance) &&
            const DeepCollectionEquality().equals(other.pinnedPosts, pinnedPosts) &&
            const DeepCollectionEquality().equals(other.altPinnedPosts, altPinnedPosts) &&
            (identical(other.markedForDeleteAt, markedForDeleteAt) || other.markedForDeleteAt == markedForDeleteAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        firstName,
        lastName,
        username,
        email,
        createdAt,
        updatedAt,
        followers,
        following,
        friends,
        userPoints,
        const DeepCollectionEquality().hash(friendsList),
        const DeepCollectionEquality().hash(followersList),
        const DeepCollectionEquality().hash(followingList),
        const DeepCollectionEquality().hash(blockedUsers),
        const DeepCollectionEquality().hash(herdAndRole),
        role,
        altUserUID,
        bio,
        profileImageURL,
        coverImageURL,
        acceptedLegal,
        isVerified,
        isPrivateAccount,
        fcmToken,
        const DeepCollectionEquality().hash(preferences),
        const DeepCollectionEquality().hash(notifications),
        const DeepCollectionEquality().hash(savedPosts),
        isNSFW,
        allowNSFW,
        blurNSFW,
        showHerdPostsInAltFeed,
        country,
        city,
        timezone,
        totalPosts,
        totalComments,
        totalLikes,
        lastActive,
        altUsername,
        altBio,
        altProfileImageURL,
        altCoverImageURL,
        altFollowers,
        altFollowing,
        altFriends,
        altUserPoints,
        const DeepCollectionEquality().hash(altFriendsList),
        const DeepCollectionEquality().hash(altFollowersList),
        const DeepCollectionEquality().hash(altFollowingList),
        const DeepCollectionEquality().hash(altBlockedUsers),
        altTotalPosts,
        altTotalComments,
        altTotalLikes,
        const DeepCollectionEquality().hash(altSavedPosts),
        altCreatedAt,
        altUpdatedAt,
        dateOfBirth,
        const DeepCollectionEquality().hash(altConnections),
        altIsPrivateAccount,
        const DeepCollectionEquality().hash(groups),
        const DeepCollectionEquality().hash(moderatedGroups),
        const DeepCollectionEquality().hash(altGroups),
        const DeepCollectionEquality().hash(altModeratedGroups),
        trustScore,
        altTrustScore,
        reportCount,
        altReportCount,
        isActive,
        altIsActive,
        accountStatus,
        altAccountStatus,
        const DeepCollectionEquality().hash(interests),
        const DeepCollectionEquality().hash(altInterests),
        const DeepCollectionEquality().hash(contentPreferences),
        const DeepCollectionEquality().hash(altContentPreferences),
        twoFactorEnabled,
        lastPasswordChange,
        const DeepCollectionEquality().hash(loginHistory),
        isPremium,
        premiumUntil,
        walletBalance,
        const DeepCollectionEquality().hash(pinnedPosts),
        const DeepCollectionEquality().hash(altPinnedPosts),
        markedForDeleteAt
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, friendsList: $friendsList, followersList: $followersList, followingList: $followingList, blockedUsers: $blockedUsers, herdAndRole: $herdAndRole, role: $role, altUserUID: $altUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, acceptedLegal: $acceptedLegal, isVerified: $isVerified, isPrivateAccount: $isPrivateAccount, fcmToken: $fcmToken, preferences: $preferences, notifications: $notifications, savedPosts: $savedPosts, isNSFW: $isNSFW, allowNSFW: $allowNSFW, blurNSFW: $blurNSFW, showHerdPostsInAltFeed: $showHerdPostsInAltFeed, country: $country, city: $city, timezone: $timezone, totalPosts: $totalPosts, totalComments: $totalComments, totalLikes: $totalLikes, lastActive: $lastActive, altUsername: $altUsername, altBio: $altBio, altProfileImageURL: $altProfileImageURL, altCoverImageURL: $altCoverImageURL, altFollowers: $altFollowers, altFollowing: $altFollowing, altFriends: $altFriends, altUserPoints: $altUserPoints, altFriendsList: $altFriendsList, altFollowersList: $altFollowersList, altFollowingList: $altFollowingList, altBlockedUsers: $altBlockedUsers, altTotalPosts: $altTotalPosts, altTotalComments: $altTotalComments, altTotalLikes: $altTotalLikes, altSavedPosts: $altSavedPosts, altCreatedAt: $altCreatedAt, altUpdatedAt: $altUpdatedAt, dateOfBirth: $dateOfBirth, altConnections: $altConnections, altIsPrivateAccount: $altIsPrivateAccount, groups: $groups, moderatedGroups: $moderatedGroups, altGroups: $altGroups, altModeratedGroups: $altModeratedGroups, trustScore: $trustScore, altTrustScore: $altTrustScore, reportCount: $reportCount, altReportCount: $altReportCount, isActive: $isActive, altIsActive: $altIsActive, accountStatus: $accountStatus, altAccountStatus: $altAccountStatus, interests: $interests, altInterests: $altInterests, contentPreferences: $contentPreferences, altContentPreferences: $altContentPreferences, twoFactorEnabled: $twoFactorEnabled, lastPasswordChange: $lastPasswordChange, loginHistory: $loginHistory, isPremium: $isPremium, premiumUntil: $premiumUntil, walletBalance: $walletBalance, pinnedPosts: $pinnedPosts, altPinnedPosts: $altPinnedPosts, markedForDeleteAt: $markedForDeleteAt)';
  }
}

/// @nodoc
abstract mixin class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) _then) =
      _$UserModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String firstName,
      String lastName,
      String username,
      String email,
      DateTime? createdAt,
      DateTime? updatedAt,
      int followers,
      int following,
      int friends,
      int userPoints,
      List<String> friendsList,
      List<String> followersList,
      List<String> followingList,
      List<String> blockedUsers,
      Map<String, dynamic> herdAndRole,
      String? role,
      String? altUserUID,
      String? bio,
      String? profileImageURL,
      String? coverImageURL,
      bool acceptedLegal,
      bool isVerified,
      bool isPrivateAccount,
      String fcmToken,
      Map<String, dynamic> preferences,
      Map<String, dynamic> notifications,
      List<String> savedPosts,
      bool isNSFW,
      bool allowNSFW,
      bool blurNSFW,
      bool showHerdPostsInAltFeed,
      String? country,
      String? city,
      String? timezone,
      int totalPosts,
      int totalComments,
      int totalLikes,
      DateTime? lastActive,
      String? altUsername,
      String? altBio,
      String? altProfileImageURL,
      String? altCoverImageURL,
      int altFollowers,
      int altFollowing,
      int altFriends,
      int altUserPoints,
      List<String> altFriendsList,
      List<String> altFollowersList,
      List<String> altFollowingList,
      List<String> altBlockedUsers,
      int altTotalPosts,
      int altTotalComments,
      int altTotalLikes,
      List<String> altSavedPosts,
      DateTime? altCreatedAt,
      DateTime? altUpdatedAt,
      DateTime? dateOfBirth,
      List<String> altConnections,
      bool altIsPrivateAccount,
      List<String> groups,
      List<String> moderatedGroups,
      List<String> altGroups,
      List<String> altModeratedGroups,
      int trustScore,
      int altTrustScore,
      int reportCount,
      int altReportCount,
      bool isActive,
      bool altIsActive,
      String accountStatus,
      String altAccountStatus,
      List<String> interests,
      List<String> altInterests,
      Map<String, dynamic> contentPreferences,
      Map<String, dynamic> altContentPreferences,
      bool twoFactorEnabled,
      DateTime? lastPasswordChange,
      List<Map<String, dynamic>> loginHistory,
      bool isPremium,
      DateTime? premiumUntil,
      int walletBalance,
      List<String> pinnedPosts,
      List<String> altPinnedPosts,
      DateTime? markedForDeleteAt});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res> implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._self, this._then);

  final UserModel _self;
  final $Res Function(UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? username = null,
    Object? email = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? followers = null,
    Object? following = null,
    Object? friends = null,
    Object? userPoints = null,
    Object? friendsList = null,
    Object? followersList = null,
    Object? followingList = null,
    Object? blockedUsers = null,
    Object? herdAndRole = null,
    Object? role = freezed,
    Object? altUserUID = freezed,
    Object? bio = freezed,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? acceptedLegal = null,
    Object? isVerified = null,
    Object? isPrivateAccount = null,
    Object? fcmToken = null,
    Object? preferences = null,
    Object? notifications = null,
    Object? savedPosts = null,
    Object? isNSFW = null,
    Object? allowNSFW = null,
    Object? blurNSFW = null,
    Object? showHerdPostsInAltFeed = null,
    Object? country = freezed,
    Object? city = freezed,
    Object? timezone = freezed,
    Object? totalPosts = null,
    Object? totalComments = null,
    Object? totalLikes = null,
    Object? lastActive = freezed,
    Object? altUsername = freezed,
    Object? altBio = freezed,
    Object? altProfileImageURL = freezed,
    Object? altCoverImageURL = freezed,
    Object? altFollowers = null,
    Object? altFollowing = null,
    Object? altFriends = null,
    Object? altUserPoints = null,
    Object? altFriendsList = null,
    Object? altFollowersList = null,
    Object? altFollowingList = null,
    Object? altBlockedUsers = null,
    Object? altTotalPosts = null,
    Object? altTotalComments = null,
    Object? altTotalLikes = null,
    Object? altSavedPosts = null,
    Object? altCreatedAt = freezed,
    Object? altUpdatedAt = freezed,
    Object? dateOfBirth = freezed,
    Object? altConnections = null,
    Object? altIsPrivateAccount = null,
    Object? groups = null,
    Object? moderatedGroups = null,
    Object? altGroups = null,
    Object? altModeratedGroups = null,
    Object? trustScore = null,
    Object? altTrustScore = null,
    Object? reportCount = null,
    Object? altReportCount = null,
    Object? isActive = null,
    Object? altIsActive = null,
    Object? accountStatus = null,
    Object? altAccountStatus = null,
    Object? interests = null,
    Object? altInterests = null,
    Object? contentPreferences = null,
    Object? altContentPreferences = null,
    Object? twoFactorEnabled = null,
    Object? lastPasswordChange = freezed,
    Object? loginHistory = null,
    Object? isPremium = null,
    Object? premiumUntil = freezed,
    Object? walletBalance = null,
    Object? pinnedPosts = null,
    Object? altPinnedPosts = null,
    Object? markedForDeleteAt = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      following: null == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as int,
      friends: null == friends
          ? _self.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as int,
      userPoints: null == userPoints
          ? _self.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int,
      friendsList: null == friendsList
          ? _self.friendsList
          : friendsList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followersList: null == followersList
          ? _self.followersList
          : followersList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followingList: null == followingList
          ? _self.followingList
          : followingList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      blockedUsers: null == blockedUsers
          ? _self.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      herdAndRole: null == herdAndRole
          ? _self.herdAndRole
          : herdAndRole // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      altUserUID: freezed == altUserUID
          ? _self.altUserUID
          : altUserUID // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageURL: freezed == profileImageURL
          ? _self.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _self.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptedLegal: null == acceptedLegal
          ? _self.acceptedLegal
          : acceptedLegal // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrivateAccount: null == isPrivateAccount
          ? _self.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      preferences: null == preferences
          ? _self.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      notifications: null == notifications
          ? _self.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      savedPosts: null == savedPosts
          ? _self.savedPosts
          : savedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      allowNSFW: null == allowNSFW
          ? _self.allowNSFW
          : allowNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      blurNSFW: null == blurNSFW
          ? _self.blurNSFW
          : blurNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      showHerdPostsInAltFeed: null == showHerdPostsInAltFeed
          ? _self.showHerdPostsInAltFeed
          : showHerdPostsInAltFeed // ignore: cast_nullable_to_non_nullable
              as bool,
      country: freezed == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPosts: null == totalPosts
          ? _self.totalPosts
          : totalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      totalComments: null == totalComments
          ? _self.totalComments
          : totalComments // ignore: cast_nullable_to_non_nullable
              as int,
      totalLikes: null == totalLikes
          ? _self.totalLikes
          : totalLikes // ignore: cast_nullable_to_non_nullable
              as int,
      lastActive: freezed == lastActive
          ? _self.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      altUsername: freezed == altUsername
          ? _self.altUsername
          : altUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      altBio: freezed == altBio
          ? _self.altBio
          : altBio // ignore: cast_nullable_to_non_nullable
              as String?,
      altProfileImageURL: freezed == altProfileImageURL
          ? _self.altProfileImageURL
          : altProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altCoverImageURL: freezed == altCoverImageURL
          ? _self.altCoverImageURL
          : altCoverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altFollowers: null == altFollowers
          ? _self.altFollowers
          : altFollowers // ignore: cast_nullable_to_non_nullable
              as int,
      altFollowing: null == altFollowing
          ? _self.altFollowing
          : altFollowing // ignore: cast_nullable_to_non_nullable
              as int,
      altFriends: null == altFriends
          ? _self.altFriends
          : altFriends // ignore: cast_nullable_to_non_nullable
              as int,
      altUserPoints: null == altUserPoints
          ? _self.altUserPoints
          : altUserPoints // ignore: cast_nullable_to_non_nullable
              as int,
      altFriendsList: null == altFriendsList
          ? _self.altFriendsList
          : altFriendsList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altFollowersList: null == altFollowersList
          ? _self.altFollowersList
          : altFollowersList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altFollowingList: null == altFollowingList
          ? _self.altFollowingList
          : altFollowingList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altBlockedUsers: null == altBlockedUsers
          ? _self.altBlockedUsers
          : altBlockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altTotalPosts: null == altTotalPosts
          ? _self.altTotalPosts
          : altTotalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      altTotalComments: null == altTotalComments
          ? _self.altTotalComments
          : altTotalComments // ignore: cast_nullable_to_non_nullable
              as int,
      altTotalLikes: null == altTotalLikes
          ? _self.altTotalLikes
          : altTotalLikes // ignore: cast_nullable_to_non_nullable
              as int,
      altSavedPosts: null == altSavedPosts
          ? _self.altSavedPosts
          : altSavedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altCreatedAt: freezed == altCreatedAt
          ? _self.altCreatedAt
          : altCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      altUpdatedAt: freezed == altUpdatedAt
          ? _self.altUpdatedAt
          : altUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateOfBirth: freezed == dateOfBirth
          ? _self.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      altConnections: null == altConnections
          ? _self.altConnections
          : altConnections // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altIsPrivateAccount: null == altIsPrivateAccount
          ? _self.altIsPrivateAccount
          : altIsPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      groups: null == groups
          ? _self.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moderatedGroups: null == moderatedGroups
          ? _self.moderatedGroups
          : moderatedGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altGroups: null == altGroups
          ? _self.altGroups
          : altGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altModeratedGroups: null == altModeratedGroups
          ? _self.altModeratedGroups
          : altModeratedGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trustScore: null == trustScore
          ? _self.trustScore
          : trustScore // ignore: cast_nullable_to_non_nullable
              as int,
      altTrustScore: null == altTrustScore
          ? _self.altTrustScore
          : altTrustScore // ignore: cast_nullable_to_non_nullable
              as int,
      reportCount: null == reportCount
          ? _self.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      altReportCount: null == altReportCount
          ? _self.altReportCount
          : altReportCount // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      altIsActive: null == altIsActive
          ? _self.altIsActive
          : altIsActive // ignore: cast_nullable_to_non_nullable
              as bool,
      accountStatus: null == accountStatus
          ? _self.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      altAccountStatus: null == altAccountStatus
          ? _self.altAccountStatus
          : altAccountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _self.interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altInterests: null == altInterests
          ? _self.altInterests
          : altInterests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contentPreferences: null == contentPreferences
          ? _self.contentPreferences
          : contentPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      altContentPreferences: null == altContentPreferences
          ? _self.altContentPreferences
          : altContentPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      twoFactorEnabled: null == twoFactorEnabled
          ? _self.twoFactorEnabled
          : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPasswordChange: freezed == lastPasswordChange
          ? _self.lastPasswordChange
          : lastPasswordChange // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      loginHistory: null == loginHistory
          ? _self.loginHistory
          : loginHistory // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isPremium: null == isPremium
          ? _self.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumUntil: freezed == premiumUntil
          ? _self.premiumUntil
          : premiumUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      walletBalance: null == walletBalance
          ? _self.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as int,
      pinnedPosts: null == pinnedPosts
          ? _self.pinnedPosts
          : pinnedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altPinnedPosts: null == altPinnedPosts
          ? _self.altPinnedPosts
          : altPinnedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      markedForDeleteAt: freezed == markedForDeleteAt
          ? _self.markedForDeleteAt
          : markedForDeleteAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [UserModel].
extension UserModelPatterns on UserModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_UserModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_UserModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_UserModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String firstName,
            String lastName,
            String username,
            String email,
            DateTime? createdAt,
            DateTime? updatedAt,
            int followers,
            int following,
            int friends,
            int userPoints,
            List<String> friendsList,
            List<String> followersList,
            List<String> followingList,
            List<String> blockedUsers,
            Map<String, dynamic> herdAndRole,
            String? role,
            String? altUserUID,
            String? bio,
            String? profileImageURL,
            String? coverImageURL,
            bool acceptedLegal,
            bool isVerified,
            bool isPrivateAccount,
            String fcmToken,
            Map<String, dynamic> preferences,
            Map<String, dynamic> notifications,
            List<String> savedPosts,
            bool isNSFW,
            bool allowNSFW,
            bool blurNSFW,
            bool showHerdPostsInAltFeed,
            String? country,
            String? city,
            String? timezone,
            int totalPosts,
            int totalComments,
            int totalLikes,
            DateTime? lastActive,
            String? altUsername,
            String? altBio,
            String? altProfileImageURL,
            String? altCoverImageURL,
            int altFollowers,
            int altFollowing,
            int altFriends,
            int altUserPoints,
            List<String> altFriendsList,
            List<String> altFollowersList,
            List<String> altFollowingList,
            List<String> altBlockedUsers,
            int altTotalPosts,
            int altTotalComments,
            int altTotalLikes,
            List<String> altSavedPosts,
            DateTime? altCreatedAt,
            DateTime? altUpdatedAt,
            DateTime? dateOfBirth,
            List<String> altConnections,
            bool altIsPrivateAccount,
            List<String> groups,
            List<String> moderatedGroups,
            List<String> altGroups,
            List<String> altModeratedGroups,
            int trustScore,
            int altTrustScore,
            int reportCount,
            int altReportCount,
            bool isActive,
            bool altIsActive,
            String accountStatus,
            String altAccountStatus,
            List<String> interests,
            List<String> altInterests,
            Map<String, dynamic> contentPreferences,
            Map<String, dynamic> altContentPreferences,
            bool twoFactorEnabled,
            DateTime? lastPasswordChange,
            List<Map<String, dynamic>> loginHistory,
            bool isPremium,
            DateTime? premiumUntil,
            int walletBalance,
            List<String> pinnedPosts,
            List<String> altPinnedPosts,
            DateTime? markedForDeleteAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.username,
            _that.email,
            _that.createdAt,
            _that.updatedAt,
            _that.followers,
            _that.following,
            _that.friends,
            _that.userPoints,
            _that.friendsList,
            _that.followersList,
            _that.followingList,
            _that.blockedUsers,
            _that.herdAndRole,
            _that.role,
            _that.altUserUID,
            _that.bio,
            _that.profileImageURL,
            _that.coverImageURL,
            _that.acceptedLegal,
            _that.isVerified,
            _that.isPrivateAccount,
            _that.fcmToken,
            _that.preferences,
            _that.notifications,
            _that.savedPosts,
            _that.isNSFW,
            _that.allowNSFW,
            _that.blurNSFW,
            _that.showHerdPostsInAltFeed,
            _that.country,
            _that.city,
            _that.timezone,
            _that.totalPosts,
            _that.totalComments,
            _that.totalLikes,
            _that.lastActive,
            _that.altUsername,
            _that.altBio,
            _that.altProfileImageURL,
            _that.altCoverImageURL,
            _that.altFollowers,
            _that.altFollowing,
            _that.altFriends,
            _that.altUserPoints,
            _that.altFriendsList,
            _that.altFollowersList,
            _that.altFollowingList,
            _that.altBlockedUsers,
            _that.altTotalPosts,
            _that.altTotalComments,
            _that.altTotalLikes,
            _that.altSavedPosts,
            _that.altCreatedAt,
            _that.altUpdatedAt,
            _that.dateOfBirth,
            _that.altConnections,
            _that.altIsPrivateAccount,
            _that.groups,
            _that.moderatedGroups,
            _that.altGroups,
            _that.altModeratedGroups,
            _that.trustScore,
            _that.altTrustScore,
            _that.reportCount,
            _that.altReportCount,
            _that.isActive,
            _that.altIsActive,
            _that.accountStatus,
            _that.altAccountStatus,
            _that.interests,
            _that.altInterests,
            _that.contentPreferences,
            _that.altContentPreferences,
            _that.twoFactorEnabled,
            _that.lastPasswordChange,
            _that.loginHistory,
            _that.isPremium,
            _that.premiumUntil,
            _that.walletBalance,
            _that.pinnedPosts,
            _that.altPinnedPosts,
            _that.markedForDeleteAt);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String firstName,
            String lastName,
            String username,
            String email,
            DateTime? createdAt,
            DateTime? updatedAt,
            int followers,
            int following,
            int friends,
            int userPoints,
            List<String> friendsList,
            List<String> followersList,
            List<String> followingList,
            List<String> blockedUsers,
            Map<String, dynamic> herdAndRole,
            String? role,
            String? altUserUID,
            String? bio,
            String? profileImageURL,
            String? coverImageURL,
            bool acceptedLegal,
            bool isVerified,
            bool isPrivateAccount,
            String fcmToken,
            Map<String, dynamic> preferences,
            Map<String, dynamic> notifications,
            List<String> savedPosts,
            bool isNSFW,
            bool allowNSFW,
            bool blurNSFW,
            bool showHerdPostsInAltFeed,
            String? country,
            String? city,
            String? timezone,
            int totalPosts,
            int totalComments,
            int totalLikes,
            DateTime? lastActive,
            String? altUsername,
            String? altBio,
            String? altProfileImageURL,
            String? altCoverImageURL,
            int altFollowers,
            int altFollowing,
            int altFriends,
            int altUserPoints,
            List<String> altFriendsList,
            List<String> altFollowersList,
            List<String> altFollowingList,
            List<String> altBlockedUsers,
            int altTotalPosts,
            int altTotalComments,
            int altTotalLikes,
            List<String> altSavedPosts,
            DateTime? altCreatedAt,
            DateTime? altUpdatedAt,
            DateTime? dateOfBirth,
            List<String> altConnections,
            bool altIsPrivateAccount,
            List<String> groups,
            List<String> moderatedGroups,
            List<String> altGroups,
            List<String> altModeratedGroups,
            int trustScore,
            int altTrustScore,
            int reportCount,
            int altReportCount,
            bool isActive,
            bool altIsActive,
            String accountStatus,
            String altAccountStatus,
            List<String> interests,
            List<String> altInterests,
            Map<String, dynamic> contentPreferences,
            Map<String, dynamic> altContentPreferences,
            bool twoFactorEnabled,
            DateTime? lastPasswordChange,
            List<Map<String, dynamic>> loginHistory,
            bool isPremium,
            DateTime? premiumUntil,
            int walletBalance,
            List<String> pinnedPosts,
            List<String> altPinnedPosts,
            DateTime? markedForDeleteAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel():
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.username,
            _that.email,
            _that.createdAt,
            _that.updatedAt,
            _that.followers,
            _that.following,
            _that.friends,
            _that.userPoints,
            _that.friendsList,
            _that.followersList,
            _that.followingList,
            _that.blockedUsers,
            _that.herdAndRole,
            _that.role,
            _that.altUserUID,
            _that.bio,
            _that.profileImageURL,
            _that.coverImageURL,
            _that.acceptedLegal,
            _that.isVerified,
            _that.isPrivateAccount,
            _that.fcmToken,
            _that.preferences,
            _that.notifications,
            _that.savedPosts,
            _that.isNSFW,
            _that.allowNSFW,
            _that.blurNSFW,
            _that.showHerdPostsInAltFeed,
            _that.country,
            _that.city,
            _that.timezone,
            _that.totalPosts,
            _that.totalComments,
            _that.totalLikes,
            _that.lastActive,
            _that.altUsername,
            _that.altBio,
            _that.altProfileImageURL,
            _that.altCoverImageURL,
            _that.altFollowers,
            _that.altFollowing,
            _that.altFriends,
            _that.altUserPoints,
            _that.altFriendsList,
            _that.altFollowersList,
            _that.altFollowingList,
            _that.altBlockedUsers,
            _that.altTotalPosts,
            _that.altTotalComments,
            _that.altTotalLikes,
            _that.altSavedPosts,
            _that.altCreatedAt,
            _that.altUpdatedAt,
            _that.dateOfBirth,
            _that.altConnections,
            _that.altIsPrivateAccount,
            _that.groups,
            _that.moderatedGroups,
            _that.altGroups,
            _that.altModeratedGroups,
            _that.trustScore,
            _that.altTrustScore,
            _that.reportCount,
            _that.altReportCount,
            _that.isActive,
            _that.altIsActive,
            _that.accountStatus,
            _that.altAccountStatus,
            _that.interests,
            _that.altInterests,
            _that.contentPreferences,
            _that.altContentPreferences,
            _that.twoFactorEnabled,
            _that.lastPasswordChange,
            _that.loginHistory,
            _that.isPremium,
            _that.premiumUntil,
            _that.walletBalance,
            _that.pinnedPosts,
            _that.altPinnedPosts,
            _that.markedForDeleteAt);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String firstName,
            String lastName,
            String username,
            String email,
            DateTime? createdAt,
            DateTime? updatedAt,
            int followers,
            int following,
            int friends,
            int userPoints,
            List<String> friendsList,
            List<String> followersList,
            List<String> followingList,
            List<String> blockedUsers,
            Map<String, dynamic> herdAndRole,
            String? role,
            String? altUserUID,
            String? bio,
            String? profileImageURL,
            String? coverImageURL,
            bool acceptedLegal,
            bool isVerified,
            bool isPrivateAccount,
            String fcmToken,
            Map<String, dynamic> preferences,
            Map<String, dynamic> notifications,
            List<String> savedPosts,
            bool isNSFW,
            bool allowNSFW,
            bool blurNSFW,
            bool showHerdPostsInAltFeed,
            String? country,
            String? city,
            String? timezone,
            int totalPosts,
            int totalComments,
            int totalLikes,
            DateTime? lastActive,
            String? altUsername,
            String? altBio,
            String? altProfileImageURL,
            String? altCoverImageURL,
            int altFollowers,
            int altFollowing,
            int altFriends,
            int altUserPoints,
            List<String> altFriendsList,
            List<String> altFollowersList,
            List<String> altFollowingList,
            List<String> altBlockedUsers,
            int altTotalPosts,
            int altTotalComments,
            int altTotalLikes,
            List<String> altSavedPosts,
            DateTime? altCreatedAt,
            DateTime? altUpdatedAt,
            DateTime? dateOfBirth,
            List<String> altConnections,
            bool altIsPrivateAccount,
            List<String> groups,
            List<String> moderatedGroups,
            List<String> altGroups,
            List<String> altModeratedGroups,
            int trustScore,
            int altTrustScore,
            int reportCount,
            int altReportCount,
            bool isActive,
            bool altIsActive,
            String accountStatus,
            String altAccountStatus,
            List<String> interests,
            List<String> altInterests,
            Map<String, dynamic> contentPreferences,
            Map<String, dynamic> altContentPreferences,
            bool twoFactorEnabled,
            DateTime? lastPasswordChange,
            List<Map<String, dynamic>> loginHistory,
            bool isPremium,
            DateTime? premiumUntil,
            int walletBalance,
            List<String> pinnedPosts,
            List<String> altPinnedPosts,
            DateTime? markedForDeleteAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UserModel() when $default != null:
        return $default(
            _that.id,
            _that.firstName,
            _that.lastName,
            _that.username,
            _that.email,
            _that.createdAt,
            _that.updatedAt,
            _that.followers,
            _that.following,
            _that.friends,
            _that.userPoints,
            _that.friendsList,
            _that.followersList,
            _that.followingList,
            _that.blockedUsers,
            _that.herdAndRole,
            _that.role,
            _that.altUserUID,
            _that.bio,
            _that.profileImageURL,
            _that.coverImageURL,
            _that.acceptedLegal,
            _that.isVerified,
            _that.isPrivateAccount,
            _that.fcmToken,
            _that.preferences,
            _that.notifications,
            _that.savedPosts,
            _that.isNSFW,
            _that.allowNSFW,
            _that.blurNSFW,
            _that.showHerdPostsInAltFeed,
            _that.country,
            _that.city,
            _that.timezone,
            _that.totalPosts,
            _that.totalComments,
            _that.totalLikes,
            _that.lastActive,
            _that.altUsername,
            _that.altBio,
            _that.altProfileImageURL,
            _that.altCoverImageURL,
            _that.altFollowers,
            _that.altFollowing,
            _that.altFriends,
            _that.altUserPoints,
            _that.altFriendsList,
            _that.altFollowersList,
            _that.altFollowingList,
            _that.altBlockedUsers,
            _that.altTotalPosts,
            _that.altTotalComments,
            _that.altTotalLikes,
            _that.altSavedPosts,
            _that.altCreatedAt,
            _that.altUpdatedAt,
            _that.dateOfBirth,
            _that.altConnections,
            _that.altIsPrivateAccount,
            _that.groups,
            _that.moderatedGroups,
            _that.altGroups,
            _that.altModeratedGroups,
            _that.trustScore,
            _that.altTrustScore,
            _that.reportCount,
            _that.altReportCount,
            _that.isActive,
            _that.altIsActive,
            _that.accountStatus,
            _that.altAccountStatus,
            _that.interests,
            _that.altInterests,
            _that.contentPreferences,
            _that.altContentPreferences,
            _that.twoFactorEnabled,
            _that.lastPasswordChange,
            _that.loginHistory,
            _that.isPremium,
            _that.premiumUntil,
            _that.walletBalance,
            _that.pinnedPosts,
            _that.altPinnedPosts,
            _that.markedForDeleteAt);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UserModel extends UserModel with DiagnosticableTreeMixin {
  const _UserModel(
      {required this.id,
      required this.firstName,
      required this.lastName,
      required this.username,
      required this.email,
      this.createdAt,
      this.updatedAt,
      this.followers = 0,
      this.following = 0,
      this.friends = 0,
      this.userPoints = 0,
      final List<String> friendsList = const [],
      final List<String> followersList = const [],
      final List<String> followingList = const [],
      final List<String> blockedUsers = const [],
      final Map<String, dynamic> herdAndRole = const {},
      this.role,
      this.altUserUID,
      this.bio,
      this.profileImageURL,
      this.coverImageURL,
      this.acceptedLegal = false,
      this.isVerified = false,
      this.isPrivateAccount = false,
      this.fcmToken = "",
      final Map<String, dynamic> preferences = const {},
      final Map<String, dynamic> notifications = const {},
      final List<String> savedPosts = const [],
      this.isNSFW = false,
      this.allowNSFW = false,
      this.blurNSFW = false,
      this.showHerdPostsInAltFeed = true,
      this.country,
      this.city,
      this.timezone,
      this.totalPosts = 0,
      this.totalComments = 0,
      this.totalLikes = 0,
      this.lastActive,
      this.altUsername,
      this.altBio,
      this.altProfileImageURL,
      this.altCoverImageURL,
      this.altFollowers = 0,
      this.altFollowing = 0,
      this.altFriends = 0,
      this.altUserPoints = 0,
      final List<String> altFriendsList = const [],
      final List<String> altFollowersList = const [],
      final List<String> altFollowingList = const [],
      final List<String> altBlockedUsers = const [],
      this.altTotalPosts = 0,
      this.altTotalComments = 0,
      this.altTotalLikes = 0,
      final List<String> altSavedPosts = const [],
      this.altCreatedAt,
      this.altUpdatedAt,
      this.dateOfBirth,
      final List<String> altConnections = const [],
      this.altIsPrivateAccount = false,
      final List<String> groups = const [],
      final List<String> moderatedGroups = const [],
      final List<String> altGroups = const [],
      final List<String> altModeratedGroups = const [],
      this.trustScore = 0,
      this.altTrustScore = 0,
      this.reportCount = 0,
      this.altReportCount = 0,
      this.isActive = true,
      this.altIsActive = true,
      this.accountStatus = "active",
      this.altAccountStatus = "active",
      final List<String> interests = const [],
      final List<String> altInterests = const [],
      final Map<String, dynamic> contentPreferences = const {},
      final Map<String, dynamic> altContentPreferences = const {},
      this.twoFactorEnabled = false,
      this.lastPasswordChange,
      final List<Map<String, dynamic>> loginHistory = const [],
      this.isPremium = false,
      this.premiumUntil,
      this.walletBalance = 0,
      final List<String> pinnedPosts = const [],
      final List<String> altPinnedPosts = const [],
      this.markedForDeleteAt})
      : _friendsList = friendsList,
        _followersList = followersList,
        _followingList = followingList,
        _blockedUsers = blockedUsers,
        _herdAndRole = herdAndRole,
        _preferences = preferences,
        _notifications = notifications,
        _savedPosts = savedPosts,
        _altFriendsList = altFriendsList,
        _altFollowersList = altFollowersList,
        _altFollowingList = altFollowingList,
        _altBlockedUsers = altBlockedUsers,
        _altSavedPosts = altSavedPosts,
        _altConnections = altConnections,
        _groups = groups,
        _moderatedGroups = moderatedGroups,
        _altGroups = altGroups,
        _altModeratedGroups = altModeratedGroups,
        _interests = interests,
        _altInterests = altInterests,
        _contentPreferences = contentPreferences,
        _altContentPreferences = altContentPreferences,
        _loginHistory = loginHistory,
        _pinnedPosts = pinnedPosts,
        _altPinnedPosts = altPinnedPosts,
        super._();
  factory _UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  @override
  final String id;
  @override
  final String firstName;
  @override
  final String lastName;
  @override
  final String username;
  @override
  final String email;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final int followers;
  @override
  @JsonKey()
  final int following;
  @override
  @JsonKey()
  final int friends;
  @override
  @JsonKey()
  final int userPoints;
  final List<String> _friendsList;
  @override
  @JsonKey()
  List<String> get friendsList {
    if (_friendsList is EqualUnmodifiableListView) return _friendsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_friendsList);
  }

  final List<String> _followersList;
  @override
  @JsonKey()
  List<String> get followersList {
    if (_followersList is EqualUnmodifiableListView) return _followersList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followersList);
  }

  final List<String> _followingList;
  @override
  @JsonKey()
  List<String> get followingList {
    if (_followingList is EqualUnmodifiableListView) return _followingList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_followingList);
  }

  final List<String> _blockedUsers;
  @override
  @JsonKey()
  List<String> get blockedUsers {
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_blockedUsers);
  }

  final Map<String, dynamic> _herdAndRole;
  @override
  @JsonKey()
  Map<String, dynamic> get herdAndRole {
    if (_herdAndRole is EqualUnmodifiableMapView) return _herdAndRole;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_herdAndRole);
  }

  @override
  final String? role;
  @override
  final String? altUserUID;
  @override
  final String? bio;
  @override
  final String? profileImageURL;
  @override
  final String? coverImageURL;
  @override
  @JsonKey()
  final bool acceptedLegal;
  @override
  @JsonKey()
  final bool isVerified;
  @override
  @JsonKey()
  final bool isPrivateAccount;
  @override
  @JsonKey()
  final String fcmToken;
  final Map<String, dynamic> _preferences;
  @override
  @JsonKey()
  Map<String, dynamic> get preferences {
    if (_preferences is EqualUnmodifiableMapView) return _preferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_preferences);
  }

  final Map<String, dynamic> _notifications;
  @override
  @JsonKey()
  Map<String, dynamic> get notifications {
    if (_notifications is EqualUnmodifiableMapView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_notifications);
  }

  final List<String> _savedPosts;
  @override
  @JsonKey()
  List<String> get savedPosts {
    if (_savedPosts is EqualUnmodifiableListView) return _savedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_savedPosts);
  }

  @override
  @JsonKey()
  final bool isNSFW;
  @override
  @JsonKey()
  final bool allowNSFW;
  @override
  @JsonKey()
  final bool blurNSFW;
  @override
  @JsonKey()
  final bool showHerdPostsInAltFeed;
// Location
  @override
  final String? country;
  @override
  final String? city;
  @override
  final String? timezone;
// Activity metrics
  @override
  @JsonKey()
  final int totalPosts;
  @override
  @JsonKey()
  final int totalComments;
  @override
  @JsonKey()
  final int totalLikes;
  @override
  final DateTime? lastActive;
// Alt profile fields
  @override
  final String? altUsername;
  @override
  final String? altBio;
  @override
  final String? altProfileImageURL;
  @override
  final String? altCoverImageURL;
  @override
  @JsonKey()
  final int altFollowers;
  @override
  @JsonKey()
  final int altFollowing;
  @override
  @JsonKey()
  final int altFriends;
  @override
  @JsonKey()
  final int altUserPoints;
  final List<String> _altFriendsList;
  @override
  @JsonKey()
  List<String> get altFriendsList {
    if (_altFriendsList is EqualUnmodifiableListView) return _altFriendsList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altFriendsList);
  }

  final List<String> _altFollowersList;
  @override
  @JsonKey()
  List<String> get altFollowersList {
    if (_altFollowersList is EqualUnmodifiableListView)
      return _altFollowersList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altFollowersList);
  }

  final List<String> _altFollowingList;
  @override
  @JsonKey()
  List<String> get altFollowingList {
    if (_altFollowingList is EqualUnmodifiableListView)
      return _altFollowingList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altFollowingList);
  }

  final List<String> _altBlockedUsers;
  @override
  @JsonKey()
  List<String> get altBlockedUsers {
    if (_altBlockedUsers is EqualUnmodifiableListView) return _altBlockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altBlockedUsers);
  }

  @override
  @JsonKey()
  final int altTotalPosts;
  @override
  @JsonKey()
  final int altTotalComments;
  @override
  @JsonKey()
  final int altTotalLikes;
  final List<String> _altSavedPosts;
  @override
  @JsonKey()
  List<String> get altSavedPosts {
    if (_altSavedPosts is EqualUnmodifiableListView) return _altSavedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altSavedPosts);
  }

  @override
  final DateTime? altCreatedAt;
  @override
  final DateTime? altUpdatedAt;
  @override
  final DateTime? dateOfBirth;
  final List<String> _altConnections;
  @override
  @JsonKey()
  List<String> get altConnections {
    if (_altConnections is EqualUnmodifiableListView) return _altConnections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altConnections);
  }

  @override
  @JsonKey()
  final bool altIsPrivateAccount;
// Community
  final List<String> _groups;
// Community
  @override
  @JsonKey()
  List<String> get groups {
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_groups);
  }

  final List<String> _moderatedGroups;
  @override
  @JsonKey()
  List<String> get moderatedGroups {
    if (_moderatedGroups is EqualUnmodifiableListView) return _moderatedGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_moderatedGroups);
  }

  final List<String> _altGroups;
  @override
  @JsonKey()
  List<String> get altGroups {
    if (_altGroups is EqualUnmodifiableListView) return _altGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altGroups);
  }

  final List<String> _altModeratedGroups;
  @override
  @JsonKey()
  List<String> get altModeratedGroups {
    if (_altModeratedGroups is EqualUnmodifiableListView)
      return _altModeratedGroups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altModeratedGroups);
  }

// Reputation and trust
  @override
  @JsonKey()
  final int trustScore;
  @override
  @JsonKey()
  final int altTrustScore;
  @override
  @JsonKey()
  final int reportCount;
  @override
  @JsonKey()
  final int altReportCount;
// Account status
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final bool altIsActive;
  @override
  @JsonKey()
  final String accountStatus;
  @override
  @JsonKey()
  final String altAccountStatus;
// Interests
  final List<String> _interests;
// Interests
  @override
  @JsonKey()
  List<String> get interests {
    if (_interests is EqualUnmodifiableListView) return _interests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_interests);
  }

  final List<String> _altInterests;
  @override
  @JsonKey()
  List<String> get altInterests {
    if (_altInterests is EqualUnmodifiableListView) return _altInterests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altInterests);
  }

// Content engagement preferences
  final Map<String, dynamic> _contentPreferences;
// Content engagement preferences
  @override
  @JsonKey()
  Map<String, dynamic> get contentPreferences {
    if (_contentPreferences is EqualUnmodifiableMapView)
      return _contentPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_contentPreferences);
  }

  final Map<String, dynamic> _altContentPreferences;
  @override
  @JsonKey()
  Map<String, dynamic> get altContentPreferences {
    if (_altContentPreferences is EqualUnmodifiableMapView)
      return _altContentPreferences;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_altContentPreferences);
  }

// Account security
  @override
  @JsonKey()
  final bool twoFactorEnabled;
  @override
  final DateTime? lastPasswordChange;
  final List<Map<String, dynamic>> _loginHistory;
  @override
  @JsonKey()
  List<Map<String, dynamic>> get loginHistory {
    if (_loginHistory is EqualUnmodifiableListView) return _loginHistory;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_loginHistory);
  }

// Monetization / premium
  @override
  @JsonKey()
  final bool isPremium;
  @override
  final DateTime? premiumUntil;
  @override
  @JsonKey()
  final int walletBalance;
// Pinned posts (max 5 each)
  final List<String> _pinnedPosts;
// Pinned posts (max 5 each)
  @override
  @JsonKey()
  List<String> get pinnedPosts {
    if (_pinnedPosts is EqualUnmodifiableListView) return _pinnedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_pinnedPosts);
  }

  final List<String> _altPinnedPosts;
  @override
  @JsonKey()
  List<String> get altPinnedPosts {
    if (_altPinnedPosts is EqualUnmodifiableListView) return _altPinnedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_altPinnedPosts);
  }

// Account deletion
  @override
  final DateTime? markedForDeleteAt;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UserModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'UserModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('firstName', firstName))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('username', username))
      ..add(DiagnosticsProperty('email', email))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('followers', followers))
      ..add(DiagnosticsProperty('following', following))
      ..add(DiagnosticsProperty('friends', friends))
      ..add(DiagnosticsProperty('userPoints', userPoints))
      ..add(DiagnosticsProperty('friendsList', friendsList))
      ..add(DiagnosticsProperty('followersList', followersList))
      ..add(DiagnosticsProperty('followingList', followingList))
      ..add(DiagnosticsProperty('blockedUsers', blockedUsers))
      ..add(DiagnosticsProperty('herdAndRole', herdAndRole))
      ..add(DiagnosticsProperty('role', role))
      ..add(DiagnosticsProperty('altUserUID', altUserUID))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('acceptedLegal', acceptedLegal))
      ..add(DiagnosticsProperty('isVerified', isVerified))
      ..add(DiagnosticsProperty('isPrivateAccount', isPrivateAccount))
      ..add(DiagnosticsProperty('fcmToken', fcmToken))
      ..add(DiagnosticsProperty('preferences', preferences))
      ..add(DiagnosticsProperty('notifications', notifications))
      ..add(DiagnosticsProperty('savedPosts', savedPosts))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('allowNSFW', allowNSFW))
      ..add(DiagnosticsProperty('blurNSFW', blurNSFW))
      ..add(
          DiagnosticsProperty('showHerdPostsInAltFeed', showHerdPostsInAltFeed))
      ..add(DiagnosticsProperty('country', country))
      ..add(DiagnosticsProperty('city', city))
      ..add(DiagnosticsProperty('timezone', timezone))
      ..add(DiagnosticsProperty('totalPosts', totalPosts))
      ..add(DiagnosticsProperty('totalComments', totalComments))
      ..add(DiagnosticsProperty('totalLikes', totalLikes))
      ..add(DiagnosticsProperty('lastActive', lastActive))
      ..add(DiagnosticsProperty('altUsername', altUsername))
      ..add(DiagnosticsProperty('altBio', altBio))
      ..add(DiagnosticsProperty('altProfileImageURL', altProfileImageURL))
      ..add(DiagnosticsProperty('altCoverImageURL', altCoverImageURL))
      ..add(DiagnosticsProperty('altFollowers', altFollowers))
      ..add(DiagnosticsProperty('altFollowing', altFollowing))
      ..add(DiagnosticsProperty('altFriends', altFriends))
      ..add(DiagnosticsProperty('altUserPoints', altUserPoints))
      ..add(DiagnosticsProperty('altFriendsList', altFriendsList))
      ..add(DiagnosticsProperty('altFollowersList', altFollowersList))
      ..add(DiagnosticsProperty('altFollowingList', altFollowingList))
      ..add(DiagnosticsProperty('altBlockedUsers', altBlockedUsers))
      ..add(DiagnosticsProperty('altTotalPosts', altTotalPosts))
      ..add(DiagnosticsProperty('altTotalComments', altTotalComments))
      ..add(DiagnosticsProperty('altTotalLikes', altTotalLikes))
      ..add(DiagnosticsProperty('altSavedPosts', altSavedPosts))
      ..add(DiagnosticsProperty('altCreatedAt', altCreatedAt))
      ..add(DiagnosticsProperty('altUpdatedAt', altUpdatedAt))
      ..add(DiagnosticsProperty('dateOfBirth', dateOfBirth))
      ..add(DiagnosticsProperty('altConnections', altConnections))
      ..add(DiagnosticsProperty('altIsPrivateAccount', altIsPrivateAccount))
      ..add(DiagnosticsProperty('groups', groups))
      ..add(DiagnosticsProperty('moderatedGroups', moderatedGroups))
      ..add(DiagnosticsProperty('altGroups', altGroups))
      ..add(DiagnosticsProperty('altModeratedGroups', altModeratedGroups))
      ..add(DiagnosticsProperty('trustScore', trustScore))
      ..add(DiagnosticsProperty('altTrustScore', altTrustScore))
      ..add(DiagnosticsProperty('reportCount', reportCount))
      ..add(DiagnosticsProperty('altReportCount', altReportCount))
      ..add(DiagnosticsProperty('isActive', isActive))
      ..add(DiagnosticsProperty('altIsActive', altIsActive))
      ..add(DiagnosticsProperty('accountStatus', accountStatus))
      ..add(DiagnosticsProperty('altAccountStatus', altAccountStatus))
      ..add(DiagnosticsProperty('interests', interests))
      ..add(DiagnosticsProperty('altInterests', altInterests))
      ..add(DiagnosticsProperty('contentPreferences', contentPreferences))
      ..add(DiagnosticsProperty('altContentPreferences', altContentPreferences))
      ..add(DiagnosticsProperty('twoFactorEnabled', twoFactorEnabled))
      ..add(DiagnosticsProperty('lastPasswordChange', lastPasswordChange))
      ..add(DiagnosticsProperty('loginHistory', loginHistory))
      ..add(DiagnosticsProperty('isPremium', isPremium))
      ..add(DiagnosticsProperty('premiumUntil', premiumUntil))
      ..add(DiagnosticsProperty('walletBalance', walletBalance))
      ..add(DiagnosticsProperty('pinnedPosts', pinnedPosts))
      ..add(DiagnosticsProperty('altPinnedPosts', altPinnedPosts))
      ..add(DiagnosticsProperty('markedForDeleteAt', markedForDeleteAt));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.followers, followers) ||
                other.followers == followers) &&
            (identical(other.following, following) ||
                other.following == following) &&
            (identical(other.friends, friends) || other.friends == friends) &&
            (identical(other.userPoints, userPoints) ||
                other.userPoints == userPoints) &&
            const DeepCollectionEquality()
                .equals(other._friendsList, _friendsList) &&
            const DeepCollectionEquality()
                .equals(other._followersList, _followersList) &&
            const DeepCollectionEquality()
                .equals(other._followingList, _followingList) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers) &&
            const DeepCollectionEquality()
                .equals(other._herdAndRole, _herdAndRole) &&
            (identical(other.role, role) || other.role == role) &&
            (identical(other.altUserUID, altUserUID) ||
                other.altUserUID == altUserUID) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            (identical(other.acceptedLegal, acceptedLegal) ||
                other.acceptedLegal == acceptedLegal) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isPrivateAccount, isPrivateAccount) ||
                other.isPrivateAccount == isPrivateAccount) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            const DeepCollectionEquality()
                .equals(other._preferences, _preferences) &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            const DeepCollectionEquality()
                .equals(other._savedPosts, _savedPosts) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
            (identical(other.allowNSFW, allowNSFW) ||
                other.allowNSFW == allowNSFW) &&
            (identical(other.blurNSFW, blurNSFW) ||
                other.blurNSFW == blurNSFW) &&
            (identical(other.showHerdPostsInAltFeed, showHerdPostsInAltFeed) ||
                other.showHerdPostsInAltFeed == showHerdPostsInAltFeed) &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.timezone, timezone) ||
                other.timezone == timezone) &&
            (identical(other.totalPosts, totalPosts) ||
                other.totalPosts == totalPosts) &&
            (identical(other.totalComments, totalComments) ||
                other.totalComments == totalComments) &&
            (identical(other.totalLikes, totalLikes) ||
                other.totalLikes == totalLikes) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive) &&
            (identical(other.altUsername, altUsername) ||
                other.altUsername == altUsername) &&
            (identical(other.altBio, altBio) || other.altBio == altBio) &&
            (identical(other.altProfileImageURL, altProfileImageURL) ||
                other.altProfileImageURL == altProfileImageURL) &&
            (identical(other.altCoverImageURL, altCoverImageURL) ||
                other.altCoverImageURL == altCoverImageURL) &&
            (identical(other.altFollowers, altFollowers) ||
                other.altFollowers == altFollowers) &&
            (identical(other.altFollowing, altFollowing) ||
                other.altFollowing == altFollowing) &&
            (identical(other.altFriends, altFriends) ||
                other.altFriends == altFriends) &&
            (identical(other.altUserPoints, altUserPoints) ||
                other.altUserPoints == altUserPoints) &&
            const DeepCollectionEquality()
                .equals(other._altFriendsList, _altFriendsList) &&
            const DeepCollectionEquality()
                .equals(other._altFollowersList, _altFollowersList) &&
            const DeepCollectionEquality()
                .equals(other._altFollowingList, _altFollowingList) &&
            const DeepCollectionEquality()
                .equals(other._altBlockedUsers, _altBlockedUsers) &&
            (identical(other.altTotalPosts, altTotalPosts) || other.altTotalPosts == altTotalPosts) &&
            (identical(other.altTotalComments, altTotalComments) || other.altTotalComments == altTotalComments) &&
            (identical(other.altTotalLikes, altTotalLikes) || other.altTotalLikes == altTotalLikes) &&
            const DeepCollectionEquality().equals(other._altSavedPosts, _altSavedPosts) &&
            (identical(other.altCreatedAt, altCreatedAt) || other.altCreatedAt == altCreatedAt) &&
            (identical(other.altUpdatedAt, altUpdatedAt) || other.altUpdatedAt == altUpdatedAt) &&
            (identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth) &&
            const DeepCollectionEquality().equals(other._altConnections, _altConnections) &&
            (identical(other.altIsPrivateAccount, altIsPrivateAccount) || other.altIsPrivateAccount == altIsPrivateAccount) &&
            const DeepCollectionEquality().equals(other._groups, _groups) &&
            const DeepCollectionEquality().equals(other._moderatedGroups, _moderatedGroups) &&
            const DeepCollectionEquality().equals(other._altGroups, _altGroups) &&
            const DeepCollectionEquality().equals(other._altModeratedGroups, _altModeratedGroups) &&
            (identical(other.trustScore, trustScore) || other.trustScore == trustScore) &&
            (identical(other.altTrustScore, altTrustScore) || other.altTrustScore == altTrustScore) &&
            (identical(other.reportCount, reportCount) || other.reportCount == reportCount) &&
            (identical(other.altReportCount, altReportCount) || other.altReportCount == altReportCount) &&
            (identical(other.isActive, isActive) || other.isActive == isActive) &&
            (identical(other.altIsActive, altIsActive) || other.altIsActive == altIsActive) &&
            (identical(other.accountStatus, accountStatus) || other.accountStatus == accountStatus) &&
            (identical(other.altAccountStatus, altAccountStatus) || other.altAccountStatus == altAccountStatus) &&
            const DeepCollectionEquality().equals(other._interests, _interests) &&
            const DeepCollectionEquality().equals(other._altInterests, _altInterests) &&
            const DeepCollectionEquality().equals(other._contentPreferences, _contentPreferences) &&
            const DeepCollectionEquality().equals(other._altContentPreferences, _altContentPreferences) &&
            (identical(other.twoFactorEnabled, twoFactorEnabled) || other.twoFactorEnabled == twoFactorEnabled) &&
            (identical(other.lastPasswordChange, lastPasswordChange) || other.lastPasswordChange == lastPasswordChange) &&
            const DeepCollectionEquality().equals(other._loginHistory, _loginHistory) &&
            (identical(other.isPremium, isPremium) || other.isPremium == isPremium) &&
            (identical(other.premiumUntil, premiumUntil) || other.premiumUntil == premiumUntil) &&
            (identical(other.walletBalance, walletBalance) || other.walletBalance == walletBalance) &&
            const DeepCollectionEquality().equals(other._pinnedPosts, _pinnedPosts) &&
            const DeepCollectionEquality().equals(other._altPinnedPosts, _altPinnedPosts) &&
            (identical(other.markedForDeleteAt, markedForDeleteAt) || other.markedForDeleteAt == markedForDeleteAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        firstName,
        lastName,
        username,
        email,
        createdAt,
        updatedAt,
        followers,
        following,
        friends,
        userPoints,
        const DeepCollectionEquality().hash(_friendsList),
        const DeepCollectionEquality().hash(_followersList),
        const DeepCollectionEquality().hash(_followingList),
        const DeepCollectionEquality().hash(_blockedUsers),
        const DeepCollectionEquality().hash(_herdAndRole),
        role,
        altUserUID,
        bio,
        profileImageURL,
        coverImageURL,
        acceptedLegal,
        isVerified,
        isPrivateAccount,
        fcmToken,
        const DeepCollectionEquality().hash(_preferences),
        const DeepCollectionEquality().hash(_notifications),
        const DeepCollectionEquality().hash(_savedPosts),
        isNSFW,
        allowNSFW,
        blurNSFW,
        showHerdPostsInAltFeed,
        country,
        city,
        timezone,
        totalPosts,
        totalComments,
        totalLikes,
        lastActive,
        altUsername,
        altBio,
        altProfileImageURL,
        altCoverImageURL,
        altFollowers,
        altFollowing,
        altFriends,
        altUserPoints,
        const DeepCollectionEquality().hash(_altFriendsList),
        const DeepCollectionEquality().hash(_altFollowersList),
        const DeepCollectionEquality().hash(_altFollowingList),
        const DeepCollectionEquality().hash(_altBlockedUsers),
        altTotalPosts,
        altTotalComments,
        altTotalLikes,
        const DeepCollectionEquality().hash(_altSavedPosts),
        altCreatedAt,
        altUpdatedAt,
        dateOfBirth,
        const DeepCollectionEquality().hash(_altConnections),
        altIsPrivateAccount,
        const DeepCollectionEquality().hash(_groups),
        const DeepCollectionEquality().hash(_moderatedGroups),
        const DeepCollectionEquality().hash(_altGroups),
        const DeepCollectionEquality().hash(_altModeratedGroups),
        trustScore,
        altTrustScore,
        reportCount,
        altReportCount,
        isActive,
        altIsActive,
        accountStatus,
        altAccountStatus,
        const DeepCollectionEquality().hash(_interests),
        const DeepCollectionEquality().hash(_altInterests),
        const DeepCollectionEquality().hash(_contentPreferences),
        const DeepCollectionEquality().hash(_altContentPreferences),
        twoFactorEnabled,
        lastPasswordChange,
        const DeepCollectionEquality().hash(_loginHistory),
        isPremium,
        premiumUntil,
        walletBalance,
        const DeepCollectionEquality().hash(_pinnedPosts),
        const DeepCollectionEquality().hash(_altPinnedPosts),
        markedForDeleteAt
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, friendsList: $friendsList, followersList: $followersList, followingList: $followingList, blockedUsers: $blockedUsers, herdAndRole: $herdAndRole, role: $role, altUserUID: $altUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, acceptedLegal: $acceptedLegal, isVerified: $isVerified, isPrivateAccount: $isPrivateAccount, fcmToken: $fcmToken, preferences: $preferences, notifications: $notifications, savedPosts: $savedPosts, isNSFW: $isNSFW, allowNSFW: $allowNSFW, blurNSFW: $blurNSFW, showHerdPostsInAltFeed: $showHerdPostsInAltFeed, country: $country, city: $city, timezone: $timezone, totalPosts: $totalPosts, totalComments: $totalComments, totalLikes: $totalLikes, lastActive: $lastActive, altUsername: $altUsername, altBio: $altBio, altProfileImageURL: $altProfileImageURL, altCoverImageURL: $altCoverImageURL, altFollowers: $altFollowers, altFollowing: $altFollowing, altFriends: $altFriends, altUserPoints: $altUserPoints, altFriendsList: $altFriendsList, altFollowersList: $altFollowersList, altFollowingList: $altFollowingList, altBlockedUsers: $altBlockedUsers, altTotalPosts: $altTotalPosts, altTotalComments: $altTotalComments, altTotalLikes: $altTotalLikes, altSavedPosts: $altSavedPosts, altCreatedAt: $altCreatedAt, altUpdatedAt: $altUpdatedAt, dateOfBirth: $dateOfBirth, altConnections: $altConnections, altIsPrivateAccount: $altIsPrivateAccount, groups: $groups, moderatedGroups: $moderatedGroups, altGroups: $altGroups, altModeratedGroups: $altModeratedGroups, trustScore: $trustScore, altTrustScore: $altTrustScore, reportCount: $reportCount, altReportCount: $altReportCount, isActive: $isActive, altIsActive: $altIsActive, accountStatus: $accountStatus, altAccountStatus: $altAccountStatus, interests: $interests, altInterests: $altInterests, contentPreferences: $contentPreferences, altContentPreferences: $altContentPreferences, twoFactorEnabled: $twoFactorEnabled, lastPasswordChange: $lastPasswordChange, loginHistory: $loginHistory, isPremium: $isPremium, premiumUntil: $premiumUntil, walletBalance: $walletBalance, pinnedPosts: $pinnedPosts, altPinnedPosts: $altPinnedPosts, markedForDeleteAt: $markedForDeleteAt)';
  }
}

/// @nodoc
abstract mixin class _$UserModelCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$UserModelCopyWith(
          _UserModel value, $Res Function(_UserModel) _then) =
      __$UserModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String firstName,
      String lastName,
      String username,
      String email,
      DateTime? createdAt,
      DateTime? updatedAt,
      int followers,
      int following,
      int friends,
      int userPoints,
      List<String> friendsList,
      List<String> followersList,
      List<String> followingList,
      List<String> blockedUsers,
      Map<String, dynamic> herdAndRole,
      String? role,
      String? altUserUID,
      String? bio,
      String? profileImageURL,
      String? coverImageURL,
      bool acceptedLegal,
      bool isVerified,
      bool isPrivateAccount,
      String fcmToken,
      Map<String, dynamic> preferences,
      Map<String, dynamic> notifications,
      List<String> savedPosts,
      bool isNSFW,
      bool allowNSFW,
      bool blurNSFW,
      bool showHerdPostsInAltFeed,
      String? country,
      String? city,
      String? timezone,
      int totalPosts,
      int totalComments,
      int totalLikes,
      DateTime? lastActive,
      String? altUsername,
      String? altBio,
      String? altProfileImageURL,
      String? altCoverImageURL,
      int altFollowers,
      int altFollowing,
      int altFriends,
      int altUserPoints,
      List<String> altFriendsList,
      List<String> altFollowersList,
      List<String> altFollowingList,
      List<String> altBlockedUsers,
      int altTotalPosts,
      int altTotalComments,
      int altTotalLikes,
      List<String> altSavedPosts,
      DateTime? altCreatedAt,
      DateTime? altUpdatedAt,
      DateTime? dateOfBirth,
      List<String> altConnections,
      bool altIsPrivateAccount,
      List<String> groups,
      List<String> moderatedGroups,
      List<String> altGroups,
      List<String> altModeratedGroups,
      int trustScore,
      int altTrustScore,
      int reportCount,
      int altReportCount,
      bool isActive,
      bool altIsActive,
      String accountStatus,
      String altAccountStatus,
      List<String> interests,
      List<String> altInterests,
      Map<String, dynamic> contentPreferences,
      Map<String, dynamic> altContentPreferences,
      bool twoFactorEnabled,
      DateTime? lastPasswordChange,
      List<Map<String, dynamic>> loginHistory,
      bool isPremium,
      DateTime? premiumUntil,
      int walletBalance,
      List<String> pinnedPosts,
      List<String> altPinnedPosts,
      DateTime? markedForDeleteAt});
}

/// @nodoc
class __$UserModelCopyWithImpl<$Res> implements _$UserModelCopyWith<$Res> {
  __$UserModelCopyWithImpl(this._self, this._then);

  final _UserModel _self;
  final $Res Function(_UserModel) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? firstName = null,
    Object? lastName = null,
    Object? username = null,
    Object? email = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? followers = null,
    Object? following = null,
    Object? friends = null,
    Object? userPoints = null,
    Object? friendsList = null,
    Object? followersList = null,
    Object? followingList = null,
    Object? blockedUsers = null,
    Object? herdAndRole = null,
    Object? role = freezed,
    Object? altUserUID = freezed,
    Object? bio = freezed,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? acceptedLegal = null,
    Object? isVerified = null,
    Object? isPrivateAccount = null,
    Object? fcmToken = null,
    Object? preferences = null,
    Object? notifications = null,
    Object? savedPosts = null,
    Object? isNSFW = null,
    Object? allowNSFW = null,
    Object? blurNSFW = null,
    Object? showHerdPostsInAltFeed = null,
    Object? country = freezed,
    Object? city = freezed,
    Object? timezone = freezed,
    Object? totalPosts = null,
    Object? totalComments = null,
    Object? totalLikes = null,
    Object? lastActive = freezed,
    Object? altUsername = freezed,
    Object? altBio = freezed,
    Object? altProfileImageURL = freezed,
    Object? altCoverImageURL = freezed,
    Object? altFollowers = null,
    Object? altFollowing = null,
    Object? altFriends = null,
    Object? altUserPoints = null,
    Object? altFriendsList = null,
    Object? altFollowersList = null,
    Object? altFollowingList = null,
    Object? altBlockedUsers = null,
    Object? altTotalPosts = null,
    Object? altTotalComments = null,
    Object? altTotalLikes = null,
    Object? altSavedPosts = null,
    Object? altCreatedAt = freezed,
    Object? altUpdatedAt = freezed,
    Object? dateOfBirth = freezed,
    Object? altConnections = null,
    Object? altIsPrivateAccount = null,
    Object? groups = null,
    Object? moderatedGroups = null,
    Object? altGroups = null,
    Object? altModeratedGroups = null,
    Object? trustScore = null,
    Object? altTrustScore = null,
    Object? reportCount = null,
    Object? altReportCount = null,
    Object? isActive = null,
    Object? altIsActive = null,
    Object? accountStatus = null,
    Object? altAccountStatus = null,
    Object? interests = null,
    Object? altInterests = null,
    Object? contentPreferences = null,
    Object? altContentPreferences = null,
    Object? twoFactorEnabled = null,
    Object? lastPasswordChange = freezed,
    Object? loginHistory = null,
    Object? isPremium = null,
    Object? premiumUntil = freezed,
    Object? walletBalance = null,
    Object? pinnedPosts = null,
    Object? altPinnedPosts = null,
    Object? markedForDeleteAt = freezed,
  }) {
    return _then(_UserModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _self.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _self.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followers: null == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int,
      following: null == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as int,
      friends: null == friends
          ? _self.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as int,
      userPoints: null == userPoints
          ? _self.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int,
      friendsList: null == friendsList
          ? _self._friendsList
          : friendsList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followersList: null == followersList
          ? _self._followersList
          : followersList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      followingList: null == followingList
          ? _self._followingList
          : followingList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      blockedUsers: null == blockedUsers
          ? _self._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      herdAndRole: null == herdAndRole
          ? _self._herdAndRole
          : herdAndRole // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      role: freezed == role
          ? _self.role
          : role // ignore: cast_nullable_to_non_nullable
              as String?,
      altUserUID: freezed == altUserUID
          ? _self.altUserUID
          : altUserUID // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageURL: freezed == profileImageURL
          ? _self.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _self.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      acceptedLegal: null == acceptedLegal
          ? _self.acceptedLegal
          : acceptedLegal // ignore: cast_nullable_to_non_nullable
              as bool,
      isVerified: null == isVerified
          ? _self.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrivateAccount: null == isPrivateAccount
          ? _self.isPrivateAccount
          : isPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      fcmToken: null == fcmToken
          ? _self.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String,
      preferences: null == preferences
          ? _self._preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      notifications: null == notifications
          ? _self._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      savedPosts: null == savedPosts
          ? _self._savedPosts
          : savedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      allowNSFW: null == allowNSFW
          ? _self.allowNSFW
          : allowNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      blurNSFW: null == blurNSFW
          ? _self.blurNSFW
          : blurNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      showHerdPostsInAltFeed: null == showHerdPostsInAltFeed
          ? _self.showHerdPostsInAltFeed
          : showHerdPostsInAltFeed // ignore: cast_nullable_to_non_nullable
              as bool,
      country: freezed == country
          ? _self.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      city: freezed == city
          ? _self.city
          : city // ignore: cast_nullable_to_non_nullable
              as String?,
      timezone: freezed == timezone
          ? _self.timezone
          : timezone // ignore: cast_nullable_to_non_nullable
              as String?,
      totalPosts: null == totalPosts
          ? _self.totalPosts
          : totalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      totalComments: null == totalComments
          ? _self.totalComments
          : totalComments // ignore: cast_nullable_to_non_nullable
              as int,
      totalLikes: null == totalLikes
          ? _self.totalLikes
          : totalLikes // ignore: cast_nullable_to_non_nullable
              as int,
      lastActive: freezed == lastActive
          ? _self.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      altUsername: freezed == altUsername
          ? _self.altUsername
          : altUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      altBio: freezed == altBio
          ? _self.altBio
          : altBio // ignore: cast_nullable_to_non_nullable
              as String?,
      altProfileImageURL: freezed == altProfileImageURL
          ? _self.altProfileImageURL
          : altProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altCoverImageURL: freezed == altCoverImageURL
          ? _self.altCoverImageURL
          : altCoverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altFollowers: null == altFollowers
          ? _self.altFollowers
          : altFollowers // ignore: cast_nullable_to_non_nullable
              as int,
      altFollowing: null == altFollowing
          ? _self.altFollowing
          : altFollowing // ignore: cast_nullable_to_non_nullable
              as int,
      altFriends: null == altFriends
          ? _self.altFriends
          : altFriends // ignore: cast_nullable_to_non_nullable
              as int,
      altUserPoints: null == altUserPoints
          ? _self.altUserPoints
          : altUserPoints // ignore: cast_nullable_to_non_nullable
              as int,
      altFriendsList: null == altFriendsList
          ? _self._altFriendsList
          : altFriendsList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altFollowersList: null == altFollowersList
          ? _self._altFollowersList
          : altFollowersList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altFollowingList: null == altFollowingList
          ? _self._altFollowingList
          : altFollowingList // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altBlockedUsers: null == altBlockedUsers
          ? _self._altBlockedUsers
          : altBlockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altTotalPosts: null == altTotalPosts
          ? _self.altTotalPosts
          : altTotalPosts // ignore: cast_nullable_to_non_nullable
              as int,
      altTotalComments: null == altTotalComments
          ? _self.altTotalComments
          : altTotalComments // ignore: cast_nullable_to_non_nullable
              as int,
      altTotalLikes: null == altTotalLikes
          ? _self.altTotalLikes
          : altTotalLikes // ignore: cast_nullable_to_non_nullable
              as int,
      altSavedPosts: null == altSavedPosts
          ? _self._altSavedPosts
          : altSavedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altCreatedAt: freezed == altCreatedAt
          ? _self.altCreatedAt
          : altCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      altUpdatedAt: freezed == altUpdatedAt
          ? _self.altUpdatedAt
          : altUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      dateOfBirth: freezed == dateOfBirth
          ? _self.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      altConnections: null == altConnections
          ? _self._altConnections
          : altConnections // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altIsPrivateAccount: null == altIsPrivateAccount
          ? _self.altIsPrivateAccount
          : altIsPrivateAccount // ignore: cast_nullable_to_non_nullable
              as bool,
      groups: null == groups
          ? _self._groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      moderatedGroups: null == moderatedGroups
          ? _self._moderatedGroups
          : moderatedGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altGroups: null == altGroups
          ? _self._altGroups
          : altGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altModeratedGroups: null == altModeratedGroups
          ? _self._altModeratedGroups
          : altModeratedGroups // ignore: cast_nullable_to_non_nullable
              as List<String>,
      trustScore: null == trustScore
          ? _self.trustScore
          : trustScore // ignore: cast_nullable_to_non_nullable
              as int,
      altTrustScore: null == altTrustScore
          ? _self.altTrustScore
          : altTrustScore // ignore: cast_nullable_to_non_nullable
              as int,
      reportCount: null == reportCount
          ? _self.reportCount
          : reportCount // ignore: cast_nullable_to_non_nullable
              as int,
      altReportCount: null == altReportCount
          ? _self.altReportCount
          : altReportCount // ignore: cast_nullable_to_non_nullable
              as int,
      isActive: null == isActive
          ? _self.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      altIsActive: null == altIsActive
          ? _self.altIsActive
          : altIsActive // ignore: cast_nullable_to_non_nullable
              as bool,
      accountStatus: null == accountStatus
          ? _self.accountStatus
          : accountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      altAccountStatus: null == altAccountStatus
          ? _self.altAccountStatus
          : altAccountStatus // ignore: cast_nullable_to_non_nullable
              as String,
      interests: null == interests
          ? _self._interests
          : interests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altInterests: null == altInterests
          ? _self._altInterests
          : altInterests // ignore: cast_nullable_to_non_nullable
              as List<String>,
      contentPreferences: null == contentPreferences
          ? _self._contentPreferences
          : contentPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      altContentPreferences: null == altContentPreferences
          ? _self._altContentPreferences
          : altContentPreferences // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      twoFactorEnabled: null == twoFactorEnabled
          ? _self.twoFactorEnabled
          : twoFactorEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPasswordChange: freezed == lastPasswordChange
          ? _self.lastPasswordChange
          : lastPasswordChange // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      loginHistory: null == loginHistory
          ? _self._loginHistory
          : loginHistory // ignore: cast_nullable_to_non_nullable
              as List<Map<String, dynamic>>,
      isPremium: null == isPremium
          ? _self.isPremium
          : isPremium // ignore: cast_nullable_to_non_nullable
              as bool,
      premiumUntil: freezed == premiumUntil
          ? _self.premiumUntil
          : premiumUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      walletBalance: null == walletBalance
          ? _self.walletBalance
          : walletBalance // ignore: cast_nullable_to_non_nullable
              as int,
      pinnedPosts: null == pinnedPosts
          ? _self._pinnedPosts
          : pinnedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      altPinnedPosts: null == altPinnedPosts
          ? _self._altPinnedPosts
          : altPinnedPosts // ignore: cast_nullable_to_non_nullable
              as List<String>,
      markedForDeleteAt: freezed == markedForDeleteAt
          ? _self.markedForDeleteAt
          : markedForDeleteAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
