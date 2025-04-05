// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
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
  int? get followers;
  int? get following;
  int? get friends;
  int? get userPoints;
  String? get altUserUID;
  String? get bio;
  String? get profileImageURL;
  String? get coverImageURL; // Alt profile fields
  String? get altBio;
  String? get altProfileImageURL;
  String? get altCoverImageURL;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<UserModel> get copyWith =>
      _$UserModelCopyWithImpl<UserModel>(this as UserModel, _$identity);

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
      ..add(DiagnosticsProperty('altUserUID', altUserUID))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('altBio', altBio))
      ..add(DiagnosticsProperty('altProfileImageURL', altProfileImageURL))
      ..add(DiagnosticsProperty('altCoverImageURL', altCoverImageURL));
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
            (identical(other.altUserUID, altUserUID) ||
                other.altUserUID == altUserUID) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            (identical(other.altBio, altBio) || other.altBio == altBio) &&
            (identical(other.altProfileImageURL, altProfileImageURL) ||
                other.altProfileImageURL == altProfileImageURL) &&
            (identical(other.altCoverImageURL, altCoverImageURL) ||
                other.altCoverImageURL == altCoverImageURL));
  }

  @override
  int get hashCode => Object.hash(
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
      altUserUID,
      bio,
      profileImageURL,
      coverImageURL,
      altBio,
      altProfileImageURL,
      altCoverImageURL);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, altUserUID: $altUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, altBio: $altBio, altProfileImageURL: $altProfileImageURL, altCoverImageURL: $altCoverImageURL)';
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
      int? followers,
      int? following,
      int? friends,
      int? userPoints,
      String? altUserUID,
      String? bio,
      String? profileImageURL,
      String? coverImageURL,
      String? altBio,
      String? altProfileImageURL,
      String? altCoverImageURL});
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
    Object? followers = freezed,
    Object? following = freezed,
    Object? friends = freezed,
    Object? userPoints = freezed,
    Object? altUserUID = freezed,
    Object? bio = freezed,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? altBio = freezed,
    Object? altProfileImageURL = freezed,
    Object? altCoverImageURL = freezed,
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
    ));
  }
}

/// @nodoc

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
      this.altUserUID,
      this.bio,
      this.profileImageURL,
      this.coverImageURL,
      this.altBio,
      this.altProfileImageURL,
      this.altCoverImageURL})
      : super._();

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
  final String? altUserUID;
  @override
  final String? bio;
  @override
  final String? profileImageURL;
  @override
  final String? coverImageURL;
// Alt profile fields
  @override
  final String? altBio;
  @override
  final String? altProfileImageURL;
  @override
  final String? altCoverImageURL;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UserModelCopyWith<_UserModel> get copyWith =>
      __$UserModelCopyWithImpl<_UserModel>(this, _$identity);

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
      ..add(DiagnosticsProperty('altUserUID', altUserUID))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('profileImageURL', profileImageURL))
      ..add(DiagnosticsProperty('coverImageURL', coverImageURL))
      ..add(DiagnosticsProperty('altBio', altBio))
      ..add(DiagnosticsProperty('altProfileImageURL', altProfileImageURL))
      ..add(DiagnosticsProperty('altCoverImageURL', altCoverImageURL));
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
            (identical(other.altUserUID, altUserUID) ||
                other.altUserUID == altUserUID) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.profileImageURL, profileImageURL) ||
                other.profileImageURL == profileImageURL) &&
            (identical(other.coverImageURL, coverImageURL) ||
                other.coverImageURL == coverImageURL) &&
            (identical(other.altBio, altBio) || other.altBio == altBio) &&
            (identical(other.altProfileImageURL, altProfileImageURL) ||
                other.altProfileImageURL == altProfileImageURL) &&
            (identical(other.altCoverImageURL, altCoverImageURL) ||
                other.altCoverImageURL == altCoverImageURL));
  }

  @override
  int get hashCode => Object.hash(
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
      altUserUID,
      bio,
      profileImageURL,
      coverImageURL,
      altBio,
      altProfileImageURL,
      altCoverImageURL);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, altUserUID: $altUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, altBio: $altBio, altProfileImageURL: $altProfileImageURL, altCoverImageURL: $altCoverImageURL)';
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
      int? followers,
      int? following,
      int? friends,
      int? userPoints,
      String? altUserUID,
      String? bio,
      String? profileImageURL,
      String? coverImageURL,
      String? altBio,
      String? altProfileImageURL,
      String? altCoverImageURL});
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
    Object? followers = freezed,
    Object? following = freezed,
    Object? friends = freezed,
    Object? userPoints = freezed,
    Object? altUserUID = freezed,
    Object? bio = freezed,
    Object? profileImageURL = freezed,
    Object? coverImageURL = freezed,
    Object? altBio = freezed,
    Object? altProfileImageURL = freezed,
    Object? altCoverImageURL = freezed,
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
    ));
  }
}

// dart format on
