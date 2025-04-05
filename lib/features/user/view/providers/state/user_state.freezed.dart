// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserState implements DiagnosticableTreeMixin {
  String get id;
  String get firstName;
  String get lastName;
  String get username;
  String get email;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  int? get followers;
  int? get following;
  int? get friends;
  int? get userPoints;
  String? get privateUserUID;
  String? get bio;
  String? get profileImageURL;
  String? get coverImageURL; // Add fields for private profile
  String? get privateBio;
  String? get privateProfileImageURL;
  String? get privateCoverImageURL;
  int? get privateFollowers;
  int? get privateFollowing;
  int? get privateFriends;
  int? get privateUserPoints;
  DateTime? get privateCreatedAt;
  DateTime? get privateUpdatedAt;
  List<String>? get privateConnections;
  List<String>? get groups;

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserStateCopyWith<UserState> get copyWith =>
      _$UserStateCopyWithImpl<UserState>(this as UserState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'UserState'))
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
      ..add(DiagnosticsProperty('privateUserUID', privateUserUID))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('privateBio', privateBio))
      ..add(
          DiagnosticsProperty('privateProfileImageURL', privateProfileImageURL))
      ..add(DiagnosticsProperty('privateCoverImageURL', privateCoverImageURL))
      ..add(DiagnosticsProperty('privateFollowers', privateFollowers))
      ..add(DiagnosticsProperty('privateFollowing', privateFollowing))
      ..add(DiagnosticsProperty('privateFriends', privateFriends))
      ..add(DiagnosticsProperty('privateUserPoints', privateUserPoints))
      ..add(DiagnosticsProperty('privateCreatedAt', privateCreatedAt))
      ..add(DiagnosticsProperty('privateUpdatedAt', privateUpdatedAt))
      ..add(DiagnosticsProperty('privateConnections', privateConnections))
      ..add(DiagnosticsProperty('groups', groups));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UserState &&
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
            (identical(other.privateUserUID, privateUserUID) ||
                other.privateUserUID == privateUserUID) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            (identical(other.privateBio, privateBio) ||
                other.privateBio == privateBio) &&
            (identical(other.privateProfileImageURL, privateProfileImageURL) ||
                other.privateProfileImageURL == privateProfileImageURL) &&
            (identical(other.privateCoverImageURL, privateCoverImageURL) ||
                other.privateCoverImageURL == privateCoverImageURL) &&
            (identical(other.privateFollowers, privateFollowers) ||
                other.privateFollowers == privateFollowers) &&
            (identical(other.privateFollowing, privateFollowing) ||
                other.privateFollowing == privateFollowing) &&
            (identical(other.privateFriends, privateFriends) ||
                other.privateFriends == privateFriends) &&
            (identical(other.privateUserPoints, privateUserPoints) ||
                other.privateUserPoints == privateUserPoints) &&
            (identical(other.privateCreatedAt, privateCreatedAt) ||
                other.privateCreatedAt == privateCreatedAt) &&
            (identical(other.privateUpdatedAt, privateUpdatedAt) ||
                other.privateUpdatedAt == privateUpdatedAt) &&
            const DeepCollectionEquality()
                .equals(other.privateConnections, privateConnections) &&
            const DeepCollectionEquality().equals(other.groups, groups));
  }

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
        privateUserUID,
        bio,
        profileImageURL,
        coverImageURL,
        privateBio,
        privateProfileImageURL,
        privateCoverImageURL,
        privateFollowers,
        privateFollowing,
        privateFriends,
        privateUserPoints,
        privateCreatedAt,
        privateUpdatedAt,
        const DeepCollectionEquality().hash(privateConnections),
        const DeepCollectionEquality().hash(groups)
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserState(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, privateUserUID: $privateUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, privateBio: $privateBio, privateProfileImageURL: $privateProfileImageURL, privateCoverImageURL: $privateCoverImageURL, privateFollowers: $privateFollowers, privateFollowing: $privateFollowing, privateFriends: $privateFriends, privateUserPoints: $privateUserPoints, privateCreatedAt: $privateCreatedAt, privateUpdatedAt: $privateUpdatedAt, privateConnections: $privateConnections, groups: $groups)';
  }
}

/// @nodoc
abstract mixin class $UserStateCopyWith<$Res> {
  factory $UserStateCopyWith(UserState value, $Res Function(UserState) _then) =
      _$UserStateCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String firstName,
      String lastName,
      String username,
      String email,
      DateTime? createdAt,
      DateTime? updatedAt,
      int? followers,
      int? following,
      int? friends,
      int? userPoints,
      String? privateUserUID,
      String? bio,
      String? profileImageURL,
      String? coverImageURL,
      String? privateBio,
      String? privateProfileImageURL,
      String? privateCoverImageURL,
      int? privateFollowers,
      int? privateFollowing,
      int? privateFriends,
      int? privateUserPoints,
      DateTime? privateCreatedAt,
      DateTime? privateUpdatedAt,
      List<String>? privateConnections,
      List<String>? groups});
}

/// @nodoc
class _$UserStateCopyWithImpl<$Res> implements $UserStateCopyWith<$Res> {
  _$UserStateCopyWithImpl(this._self, this._then);

  final UserState _self;
  final $Res Function(UserState) _then;

  /// Create a copy of UserState
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
    Object? followers = freezed,
    Object? following = freezed,
    Object? friends = freezed,
    Object? userPoints = freezed,
    Object? privateUserUID = freezed,
    Object? bio = freezed,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? privateBio = freezed,
    Object? privateProfileImageURL = freezed,
    Object? privateCoverImageURL = freezed,
    Object? privateFollowers = freezed,
    Object? privateFollowing = freezed,
    Object? privateFriends = freezed,
    Object? privateUserPoints = freezed,
    Object? privateCreatedAt = freezed,
    Object? privateUpdatedAt = freezed,
    Object? privateConnections = freezed,
    Object? groups = freezed,
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
      followers: freezed == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int?,
      following: freezed == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as int?,
      friends: freezed == friends
          ? _self.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as int?,
      userPoints: freezed == userPoints
          ? _self.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      privateUserUID: freezed == privateUserUID
          ? _self.privateUserUID
          : privateUserUID // ignore: cast_nullable_to_non_nullable
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
      privateBio: freezed == privateBio
          ? _self.privateBio
          : privateBio // ignore: cast_nullable_to_non_nullable
              as String?,
      privateProfileImageURL: freezed == privateProfileImageURL
          ? _self.privateProfileImageURL
          : privateProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      privateCoverImageURL: freezed == privateCoverImageURL
          ? _self.privateCoverImageURL
          : privateCoverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      privateFollowers: freezed == privateFollowers
          ? _self.privateFollowers
          : privateFollowers // ignore: cast_nullable_to_non_nullable
              as int?,
      privateFollowing: freezed == privateFollowing
          ? _self.privateFollowing
          : privateFollowing // ignore: cast_nullable_to_non_nullable
              as int?,
      privateFriends: freezed == privateFriends
          ? _self.privateFriends
          : privateFriends // ignore: cast_nullable_to_non_nullable
              as int?,
      privateUserPoints: freezed == privateUserPoints
          ? _self.privateUserPoints
          : privateUserPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      privateCreatedAt: freezed == privateCreatedAt
          ? _self.privateCreatedAt
          : privateCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      privateUpdatedAt: freezed == privateUpdatedAt
          ? _self.privateUpdatedAt
          : privateUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      privateConnections: freezed == privateConnections
          ? _self.privateConnections
          : privateConnections // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      groups: freezed == groups
          ? _self.groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

class _UserState with DiagnosticableTreeMixin implements UserState {
  const _UserState(
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
      this.privateUserUID,
      this.bio,
      this.profileImageURL,
      this.coverImageURL,
      this.privateBio,
      this.privateProfileImageURL,
      this.privateCoverImageURL,
      this.privateFollowers = 0,
      this.privateFollowing = 0,
      this.privateFriends = 0,
      this.privateUserPoints = 0,
      this.privateCreatedAt,
      this.privateUpdatedAt,
      final List<String>? privateConnections,
      final List<String>? groups})
      : _privateConnections = privateConnections,
        _groups = groups;

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
  final int? followers;
  @override
  @JsonKey()
  final int? following;
  @override
  @JsonKey()
  final int? friends;
  @override
  @JsonKey()
  final int? userPoints;
  @override
  final String? privateUserUID;
  @override
  final String? bio;
  @override
  final String? profileImageURL;
  @override
  final String? coverImageURL;
// Add fields for private profile
  @override
  final String? privateBio;
  @override
  final String? privateProfileImageURL;
  @override
  final String? privateCoverImageURL;
  @override
  @JsonKey()
  final int? privateFollowers;
  @override
  @JsonKey()
  final int? privateFollowing;
  @override
  @JsonKey()
  final int? privateFriends;
  @override
  @JsonKey()
  final int? privateUserPoints;
  @override
  final DateTime? privateCreatedAt;
  @override
  final DateTime? privateUpdatedAt;
  final List<String>? _privateConnections;
  @override
  List<String>? get privateConnections {
    final value = _privateConnections;
    if (value == null) return null;
    if (_privateConnections is EqualUnmodifiableListView)
      return _privateConnections;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _groups;
  @override
  List<String>? get groups {
    final value = _groups;
    if (value == null) return null;
    if (_groups is EqualUnmodifiableListView) return _groups;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  /// Create a copy of UserState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserStateCopyWith<_UserState> get copyWith =>
      __$UserStateCopyWithImpl<_UserState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'UserState'))
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
      ..add(DiagnosticsProperty('privateUserUID', privateUserUID))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('privateBio', privateBio))
      ..add(
          DiagnosticsProperty('privateProfileImageURL', privateProfileImageURL))
      ..add(DiagnosticsProperty('privateCoverImageURL', privateCoverImageURL))
      ..add(DiagnosticsProperty('privateFollowers', privateFollowers))
      ..add(DiagnosticsProperty('privateFollowing', privateFollowing))
      ..add(DiagnosticsProperty('privateFriends', privateFriends))
      ..add(DiagnosticsProperty('privateUserPoints', privateUserPoints))
      ..add(DiagnosticsProperty('privateCreatedAt', privateCreatedAt))
      ..add(DiagnosticsProperty('privateUpdatedAt', privateUpdatedAt))
      ..add(DiagnosticsProperty('privateConnections', privateConnections))
      ..add(DiagnosticsProperty('groups', groups));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UserState &&
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
            (identical(other.privateUserUID, privateUserUID) ||
                other.privateUserUID == privateUserUID) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            (identical(other.privateBio, privateBio) ||
                other.privateBio == privateBio) &&
            (identical(other.privateProfileImageURL, privateProfileImageURL) ||
                other.privateProfileImageURL == privateProfileImageURL) &&
            (identical(other.privateCoverImageURL, privateCoverImageURL) ||
                other.privateCoverImageURL == privateCoverImageURL) &&
            (identical(other.privateFollowers, privateFollowers) ||
                other.privateFollowers == privateFollowers) &&
            (identical(other.privateFollowing, privateFollowing) ||
                other.privateFollowing == privateFollowing) &&
            (identical(other.privateFriends, privateFriends) ||
                other.privateFriends == privateFriends) &&
            (identical(other.privateUserPoints, privateUserPoints) ||
                other.privateUserPoints == privateUserPoints) &&
            (identical(other.privateCreatedAt, privateCreatedAt) ||
                other.privateCreatedAt == privateCreatedAt) &&
            (identical(other.privateUpdatedAt, privateUpdatedAt) ||
                other.privateUpdatedAt == privateUpdatedAt) &&
            const DeepCollectionEquality()
                .equals(other._privateConnections, _privateConnections) &&
            const DeepCollectionEquality().equals(other._groups, _groups));
  }

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
        privateUserUID,
        bio,
        profileImageURL,
        coverImageURL,
        privateBio,
        privateProfileImageURL,
        privateCoverImageURL,
        privateFollowers,
        privateFollowing,
        privateFriends,
        privateUserPoints,
        privateCreatedAt,
        privateUpdatedAt,
        const DeepCollectionEquality().hash(_privateConnections),
        const DeepCollectionEquality().hash(_groups)
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserState(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, privateUserUID: $privateUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, privateBio: $privateBio, privateProfileImageURL: $privateProfileImageURL, privateCoverImageURL: $privateCoverImageURL, privateFollowers: $privateFollowers, privateFollowing: $privateFollowing, privateFriends: $privateFriends, privateUserPoints: $privateUserPoints, privateCreatedAt: $privateCreatedAt, privateUpdatedAt: $privateUpdatedAt, privateConnections: $privateConnections, groups: $groups)';
  }
}

/// @nodoc
abstract mixin class _$UserStateCopyWith<$Res>
    implements $UserStateCopyWith<$Res> {
  factory _$UserStateCopyWith(
          _UserState value, $Res Function(_UserState) _then) =
      __$UserStateCopyWithImpl;
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
      int? followers,
      int? following,
      int? friends,
      int? userPoints,
      String? privateUserUID,
      String? bio,
      String? profileImageURL,
      String? coverImageURL,
      String? privateBio,
      String? privateProfileImageURL,
      String? privateCoverImageURL,
      int? privateFollowers,
      int? privateFollowing,
      int? privateFriends,
      int? privateUserPoints,
      DateTime? privateCreatedAt,
      DateTime? privateUpdatedAt,
      List<String>? privateConnections,
      List<String>? groups});
}

/// @nodoc
class __$UserStateCopyWithImpl<$Res> implements _$UserStateCopyWith<$Res> {
  __$UserStateCopyWithImpl(this._self, this._then);

  final _UserState _self;
  final $Res Function(_UserState) _then;

  /// Create a copy of UserState
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
    Object? followers = freezed,
    Object? following = freezed,
    Object? friends = freezed,
    Object? userPoints = freezed,
    Object? privateUserUID = freezed,
    Object? bio = freezed,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? privateBio = freezed,
    Object? privateProfileImageURL = freezed,
    Object? privateCoverImageURL = freezed,
    Object? privateFollowers = freezed,
    Object? privateFollowing = freezed,
    Object? privateFriends = freezed,
    Object? privateUserPoints = freezed,
    Object? privateCreatedAt = freezed,
    Object? privateUpdatedAt = freezed,
    Object? privateConnections = freezed,
    Object? groups = freezed,
  }) {
    return _then(_UserState(
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
      followers: freezed == followers
          ? _self.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int?,
      following: freezed == following
          ? _self.following
          : following // ignore: cast_nullable_to_non_nullable
              as int?,
      friends: freezed == friends
          ? _self.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as int?,
      userPoints: freezed == userPoints
          ? _self.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      privateUserUID: freezed == privateUserUID
          ? _self.privateUserUID
          : privateUserUID // ignore: cast_nullable_to_non_nullable
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
      privateBio: freezed == privateBio
          ? _self.privateBio
          : privateBio // ignore: cast_nullable_to_non_nullable
              as String?,
      privateProfileImageURL: freezed == privateProfileImageURL
          ? _self.privateProfileImageURL
          : privateProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      privateCoverImageURL: freezed == privateCoverImageURL
          ? _self.privateCoverImageURL
          : privateCoverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      privateFollowers: freezed == privateFollowers
          ? _self.privateFollowers
          : privateFollowers // ignore: cast_nullable_to_non_nullable
              as int?,
      privateFollowing: freezed == privateFollowing
          ? _self.privateFollowing
          : privateFollowing // ignore: cast_nullable_to_non_nullable
              as int?,
      privateFriends: freezed == privateFriends
          ? _self.privateFriends
          : privateFriends // ignore: cast_nullable_to_non_nullable
              as int?,
      privateUserPoints: freezed == privateUserPoints
          ? _self.privateUserPoints
          : privateUserPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      privateCreatedAt: freezed == privateCreatedAt
          ? _self.privateCreatedAt
          : privateCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      privateUpdatedAt: freezed == privateUpdatedAt
          ? _self.privateUpdatedAt
          : privateUpdatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      privateConnections: freezed == privateConnections
          ? _self._privateConnections
          : privateConnections // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      groups: freezed == groups
          ? _self._groups
          : groups // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

// dart format on
