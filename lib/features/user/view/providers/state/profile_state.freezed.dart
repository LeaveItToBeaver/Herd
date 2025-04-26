// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileState implements DiagnosticableTreeMixin {
  UserModel? get user;
  List<PostModel> get posts;
  bool get isCurrentUser;
  bool get isFollowing;
  bool get isAltView;
  bool get hasAltProfile;
  bool get isLoading;
  bool get hasMorePosts;
  String get currentUserId;
  PostModel? get lastPost;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileStateCopyWith<ProfileState> get copyWith =>
      _$ProfileStateCopyWithImpl<ProfileState>(
          this as ProfileState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ProfileState'))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isCurrentUser', isCurrentUser))
      ..add(DiagnosticsProperty('isFollowing', isFollowing))
      ..add(DiagnosticsProperty('isAltView', isAltView))
      ..add(DiagnosticsProperty('hasAltProfile', hasAltProfile))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMorePosts', hasMorePosts))
      ..add(DiagnosticsProperty('currentUserId', currentUserId))
      ..add(DiagnosticsProperty('lastPost', lastPost));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileState &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other.posts, posts) &&
            (identical(other.isCurrentUser, isCurrentUser) ||
                other.isCurrentUser == isCurrentUser) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isAltView, isAltView) ||
                other.isAltView == isAltView) &&
            (identical(other.hasAltProfile, hasAltProfile) ||
                other.hasAltProfile == hasAltProfile) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMorePosts, hasMorePosts) ||
                other.hasMorePosts == hasMorePosts) &&
            (identical(other.currentUserId, currentUserId) ||
                other.currentUserId == currentUserId) &&
            (identical(other.lastPost, lastPost) ||
                other.lastPost == lastPost));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(posts),
      isCurrentUser,
      isFollowing,
      isAltView,
      hasAltProfile,
      isLoading,
      hasMorePosts,
      currentUserId,
      lastPost);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ProfileState(user: $user, posts: $posts, isCurrentUser: $isCurrentUser, isFollowing: $isFollowing, isAltView: $isAltView, hasAltProfile: $hasAltProfile, isLoading: $isLoading, hasMorePosts: $hasMorePosts, currentUserId: $currentUserId, lastPost: $lastPost)';
  }
}

/// @nodoc
abstract mixin class $ProfileStateCopyWith<$Res> {
  factory $ProfileStateCopyWith(
          ProfileState value, $Res Function(ProfileState) _then) =
      _$ProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {UserModel? user,
      List<PostModel> posts,
      bool isCurrentUser,
      bool isFollowing,
      bool isAltView,
      bool hasAltProfile,
      bool isLoading,
      bool hasMorePosts,
      String currentUserId,
      PostModel? lastPost});

  $UserModelCopyWith<$Res>? get user;
  $PostModelCopyWith<$Res>? get lastPost;
}

/// @nodoc
class _$ProfileStateCopyWithImpl<$Res> implements $ProfileStateCopyWith<$Res> {
  _$ProfileStateCopyWithImpl(this._self, this._then);

  final ProfileState _self;
  final $Res Function(ProfileState) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? posts = null,
    Object? isCurrentUser = null,
    Object? isFollowing = null,
    Object? isAltView = null,
    Object? hasAltProfile = null,
    Object? isLoading = null,
    Object? hasMorePosts = null,
    Object? currentUserId = null,
    Object? lastPost = freezed,
  }) {
    return _then(_self.copyWith(
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      posts: null == posts
          ? _self.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isCurrentUser: null == isCurrentUser
          ? _self.isCurrentUser
          : isCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _self.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isAltView: null == isAltView
          ? _self.isAltView
          : isAltView // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAltProfile: null == hasAltProfile
          ? _self.hasAltProfile
          : hasAltProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMorePosts: null == hasMorePosts
          ? _self.hasMorePosts
          : hasMorePosts // ignore: cast_nullable_to_non_nullable
              as bool,
      currentUserId: null == currentUserId
          ? _self.currentUserId
          : currentUserId // ignore: cast_nullable_to_non_nullable
              as String,
      lastPost: freezed == lastPost
          ? _self.lastPost
          : lastPost // ignore: cast_nullable_to_non_nullable
              as PostModel?,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_self.user!, (value) {
      return _then(_self.copyWith(user: value));
    });
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<$Res>? get lastPost {
    if (_self.lastPost == null) {
      return null;
    }

    return $PostModelCopyWith<$Res>(_self.lastPost!, (value) {
      return _then(_self.copyWith(lastPost: value));
    });
  }
}

/// @nodoc

class _ProfileState with DiagnosticableTreeMixin implements ProfileState {
  const _ProfileState(
      {required this.user,
      required final List<PostModel> posts,
      required this.isCurrentUser,
      required this.isFollowing,
      required this.isAltView,
      required this.hasAltProfile,
      this.isLoading = false,
      this.hasMorePosts = true,
      this.currentUserId = '',
      this.lastPost})
      : _posts = posts;

  @override
  final UserModel? user;
  final List<PostModel> _posts;
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
  final bool isAltView;
  @override
  final bool hasAltProfile;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasMorePosts;
  @override
  @JsonKey()
  final String currentUserId;
  @override
  final PostModel? lastPost;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileStateCopyWith<_ProfileState> get copyWith =>
      __$ProfileStateCopyWithImpl<_ProfileState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ProfileState'))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isCurrentUser', isCurrentUser))
      ..add(DiagnosticsProperty('isFollowing', isFollowing))
      ..add(DiagnosticsProperty('isAltView', isAltView))
      ..add(DiagnosticsProperty('hasAltProfile', hasAltProfile))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMorePosts', hasMorePosts))
      ..add(DiagnosticsProperty('currentUserId', currentUserId))
      ..add(DiagnosticsProperty('lastPost', lastPost));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileState &&
            (identical(other.user, user) || other.user == user) &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.isCurrentUser, isCurrentUser) ||
                other.isCurrentUser == isCurrentUser) &&
            (identical(other.isFollowing, isFollowing) ||
                other.isFollowing == isFollowing) &&
            (identical(other.isAltView, isAltView) ||
                other.isAltView == isAltView) &&
            (identical(other.hasAltProfile, hasAltProfile) ||
                other.hasAltProfile == hasAltProfile) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMorePosts, hasMorePosts) ||
                other.hasMorePosts == hasMorePosts) &&
            (identical(other.currentUserId, currentUserId) ||
                other.currentUserId == currentUserId) &&
            (identical(other.lastPost, lastPost) ||
                other.lastPost == lastPost));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      user,
      const DeepCollectionEquality().hash(_posts),
      isCurrentUser,
      isFollowing,
      isAltView,
      hasAltProfile,
      isLoading,
      hasMorePosts,
      currentUserId,
      lastPost);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ProfileState(user: $user, posts: $posts, isCurrentUser: $isCurrentUser, isFollowing: $isFollowing, isAltView: $isAltView, hasAltProfile: $hasAltProfile, isLoading: $isLoading, hasMorePosts: $hasMorePosts, currentUserId: $currentUserId, lastPost: $lastPost)';
  }
}

/// @nodoc
abstract mixin class _$ProfileStateCopyWith<$Res>
    implements $ProfileStateCopyWith<$Res> {
  factory _$ProfileStateCopyWith(
          _ProfileState value, $Res Function(_ProfileState) _then) =
      __$ProfileStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {UserModel? user,
      List<PostModel> posts,
      bool isCurrentUser,
      bool isFollowing,
      bool isAltView,
      bool hasAltProfile,
      bool isLoading,
      bool hasMorePosts,
      String currentUserId,
      PostModel? lastPost});

  @override
  $UserModelCopyWith<$Res>? get user;
  @override
  $PostModelCopyWith<$Res>? get lastPost;
}

/// @nodoc
class __$ProfileStateCopyWithImpl<$Res>
    implements _$ProfileStateCopyWith<$Res> {
  __$ProfileStateCopyWithImpl(this._self, this._then);

  final _ProfileState _self;
  final $Res Function(_ProfileState) _then;

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = freezed,
    Object? posts = null,
    Object? isCurrentUser = null,
    Object? isFollowing = null,
    Object? isAltView = null,
    Object? hasAltProfile = null,
    Object? isLoading = null,
    Object? hasMorePosts = null,
    Object? currentUserId = null,
    Object? lastPost = freezed,
  }) {
    return _then(_ProfileState(
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      posts: null == posts
          ? _self._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isCurrentUser: null == isCurrentUser
          ? _self.isCurrentUser
          : isCurrentUser // ignore: cast_nullable_to_non_nullable
              as bool,
      isFollowing: null == isFollowing
          ? _self.isFollowing
          : isFollowing // ignore: cast_nullable_to_non_nullable
              as bool,
      isAltView: null == isAltView
          ? _self.isAltView
          : isAltView // ignore: cast_nullable_to_non_nullable
              as bool,
      hasAltProfile: null == hasAltProfile
          ? _self.hasAltProfile
          : hasAltProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMorePosts: null == hasMorePosts
          ? _self.hasMorePosts
          : hasMorePosts // ignore: cast_nullable_to_non_nullable
              as bool,
      currentUserId: null == currentUserId
          ? _self.currentUserId
          : currentUserId // ignore: cast_nullable_to_non_nullable
              as String,
      lastPost: freezed == lastPost
          ? _self.lastPost
          : lastPost // ignore: cast_nullable_to_non_nullable
              as PostModel?,
    ));
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_self.user!, (value) {
      return _then(_self.copyWith(user: value));
    });
  }

  /// Create a copy of ProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<$Res>? get lastPost {
    if (_self.lastPost == null) {
      return null;
    }

    return $PostModelCopyWith<$Res>(_self.lastPost!, (value) {
      return _then(_self.copyWith(lastPost: value));
    });
  }
}

// dart format on
