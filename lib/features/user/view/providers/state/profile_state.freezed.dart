// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ProfileState {
  UserModel? get user =>
      throw _privateConstructorUsedError; // Make user nullable
  List<PostModel> get posts => throw _privateConstructorUsedError;
  bool get isCurrentUser => throw _privateConstructorUsedError;
  bool get isFollowing => throw _privateConstructorUsedError;
  bool get isPrivateView => throw _privateConstructorUsedError;
  bool get hasPrivateProfile => throw _privateConstructorUsedError;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) then) =
      _$ProfileStateCopyWithImpl<$Res, ProfileState>;
  @useResult
  $Res call(
      {UserModel? user,
      List<PostModel> posts,
      bool isCurrentUser,
      bool isFollowing,
      bool isPrivateView,
      bool hasPrivateProfile});
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res, $Val extends ProfileState>
    implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? posts = null,
    Object? isCurrentUser = null,
    Object? isFollowing = null,
    Object? isPrivateView = null,
    Object? hasPrivateProfile = null,
  }) {
    return _then(_value.copyWith(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isCurrentUser: null == isCurrentUser
          ? _value.isCurrentUser
          : isCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrivateView: null == isPrivateView
          ? _value.isPrivateView
          : isPrivateView // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPrivateProfile: null == hasPrivateProfile
          ? _value.hasPrivateProfile
          : hasPrivateProfile // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProfileStateImplCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$$ProfileStateImplCopyWith(
          _$ProfileStateImpl value, $Res Function(_$ProfileStateImpl) then) =
      __$$ProfileStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {UserModel? user,
      List<PostModel> posts,
      bool isCurrentUser,
      bool isFollowing,
      bool isPrivateView,
      bool hasPrivateProfile});
}

/// @nodoc
class __$$ProfileStateImplCopyWithImpl<$Res>
    extends _$ProfileStateCopyWithImpl<$Res, _$ProfileStateImpl>
    implements _$$ProfileStateImplCopyWith<$Res> {
  __$$ProfileStateImplCopyWithImpl(
      _$ProfileStateImpl _value, $Res Function(_$ProfileStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? posts = null,
    Object? isCurrentUser = null,
    Object? isFollowing = null,
    Object? isPrivateView = null,
    Object? hasPrivateProfile = null,
  }) {
    return _then(_$ProfileStateImpl(
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isCurrentUser: null == isCurrentUser
          ? _value.isCurrentUser
          : isCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _value.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isPrivateView: null == isPrivateView
          ? _value.isPrivateView
          : isPrivateView // ignore: cast_nullable_to_non_nullable
              as bool,
      hasPrivateProfile: null == hasPrivateProfile
          ? _value.hasPrivateProfile
          : hasPrivateProfile // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$ProfileStateImpl implements _ProfileState {
  const _$ProfileStateImpl(
      {required this.user,
      required final List<PostModel> posts,
      required this.isCurrentUser,
      required this.isFollowing,
      required this.isPrivateView,
      required this.hasPrivateProfile})
      : _posts = posts;

  @override
  final UserModel? user;
// Make user nullable
  final List<PostModel> _posts;
// Make user nullable
  @override
  List<PostModel> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  final bool isCurrentUser;
  @override
  final bool isFollowing;
  @override
  final bool isPrivateView;
  @override
  final bool hasPrivateProfile;

  @override
  String toString() {
    return 'ProfileState(user: $user, posts: $posts, isCurrentUser: $isCurrentUser, isFollowing: $isFollowing, isPrivateView: $isPrivateView, hasPrivateProfile: $hasPrivateProfile)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProfileStateImpl &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.isCurrentUser, isCurrentUser) ||
                other.isCurrentUser == isCurrentUser) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isPrivateView, isPrivateView) ||
                other.isPrivateView == isPrivateView) &&
            (identical(other.hasPrivateProfile, hasPrivateProfile) ||
                other.hasPrivateProfile == hasPrivateProfile));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(_posts),
      isCurrentUser,
      isFollowing,
      isPrivateView,
      hasPrivateProfile);

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      __$$ProfileStateImplCopyWithImpl<_$ProfileStateImpl>(this, _$identity);
}

abstract class _ProfileState implements ProfileState {
  const factory _ProfileState(
      {required final UserModel? user,
      required final List<PostModel> posts,
      required final bool isCurrentUser,
      required final bool isFollowing,
      required final bool isPrivateView,
      required final bool hasPrivateProfile}) = _$ProfileStateImpl;

  @override
  UserModel? get user; // Make user nullable
  @override
  List<PostModel> get posts;
  @override
  bool get isCurrentUser;
  @override
  bool get isFollowing;
  @override
  bool get isPrivateView;
  @override
  bool get hasPrivateProfile;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProfileStateImplCopyWith<_$ProfileStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
