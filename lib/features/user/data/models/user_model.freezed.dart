// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserModel {
  String get id => throw _privateConstructorUsedError;
  String get firstName => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  String get username => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;
  int? get followers => throw _privateConstructorUsedError;
  int? get following => throw _privateConstructorUsedError;
  int? get friends => throw _privateConstructorUsedError;
  int? get userPoints => throw _privateConstructorUsedError;
  String? get altUserUID => throw _privateConstructorUsedError;
  String? get bio => throw _privateConstructorUsedError;
  String? get profileImageURL => throw _privateConstructorUsedError;
  String? get coverImageURL =>
      throw _privateConstructorUsedError; // Alt profile fields
  String? get altBio => throw _privateConstructorUsedError;
  String? get altProfileImageURL => throw _privateConstructorUsedError;
  String? get altCoverImageURL => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
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
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followers: freezed == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int?,
      following: freezed == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as int?,
      friends: freezed == friends
          ? _value.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as int?,
      userPoints: freezed == userPoints
          ? _value.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      altUserUID: freezed == altUserUID
          ? _value.altUserUID
          : altUserUID // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageURL: freezed == profileImageURL
          ? _value.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _value.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altBio: freezed == altBio
          ? _value.altBio
          : altBio // ignore: cast_nullable_to_non_nullable
              as String?,
      altProfileImageURL: freezed == altProfileImageURL
          ? _value.altProfileImageURL
          : altProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altCoverImageURL: freezed == altCoverImageURL
          ? _value.altCoverImageURL
          : altCoverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
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
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

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
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      username: null == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String,
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      followers: freezed == followers
          ? _value.followers
          : followers // ignore: cast_nullable_to_non_nullable
              as int?,
      following: freezed == following
          ? _value.following
          : following // ignore: cast_nullable_to_non_nullable
              as int?,
      friends: freezed == friends
          ? _value.friends
          : friends // ignore: cast_nullable_to_non_nullable
              as int?,
      userPoints: freezed == userPoints
          ? _value.userPoints
          : userPoints // ignore: cast_nullable_to_non_nullable
              as int?,
      altUserUID: freezed == altUserUID
          ? _value.altUserUID
          : altUserUID // ignore: cast_nullable_to_non_nullable
              as String?,
      bio: freezed == bio
          ? _value.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String?,
      profileImageURL: freezed == profileImageURL
          ? _value.profileImageURL
          : profileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      coverImageURL: freezed == coverImageURL
          ? _value.coverImageURL
          : coverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altBio: freezed == altBio
          ? _value.altBio
          : altBio // ignore: cast_nullable_to_non_nullable
              as String?,
      altProfileImageURL: freezed == altProfileImageURL
          ? _value.altProfileImageURL
          : altProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      altCoverImageURL: freezed == altCoverImageURL
          ? _value.altCoverImageURL
          : altCoverImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
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

  @override
  String toString() {
    return 'UserModel(id: $id, firstName: $firstName, lastName: $lastName, username: $username, email: $email, createdAt: $createdAt, updatedAt: $updatedAt, followers: $followers, following: $following, friends: $friends, userPoints: $userPoints, altUserUID: $altUserUID, bio: $bio, profileImageURL: $profileImageURL, coverImageURL: $coverImageURL, altBio: $altBio, altProfileImageURL: $altProfileImageURL, altCoverImageURL: $altCoverImageURL)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
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

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final String id,
      required final String firstName,
      required final String lastName,
      required final String username,
      required final String email,
      final DateTime? createdAt,
      final DateTime? updatedAt,
      final int? followers,
      final int? following,
      final int? friends,
      final int? userPoints,
      final String? altUserUID,
      final String? bio,
      final String? profileImageURL,
      final String? coverImageURL,
      final String? altBio,
      final String? altProfileImageURL,
      final String? altCoverImageURL}) = _$UserModelImpl;
  const _UserModel._() : super._();

  @override
  String get id;
  @override
  String get firstName;
  @override
  String get lastName;
  @override
  String get username;
  @override
  String get email;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get updatedAt;
  @override
  int? get followers;
  @override
  int? get following;
  @override
  int? get friends;
  @override
  int? get userPoints;
  @override
  String? get altUserUID;
  @override
  String? get bio;
  @override
  String? get profileImageURL;
  @override
  String? get coverImageURL; // Alt profile fields
  @override
  String? get altBio;
  @override
  String? get altProfileImageURL;
  @override
  String? get altCoverImageURL;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
