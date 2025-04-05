// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'alt_feed_states.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AltFeedState implements DiagnosticableTreeMixin {
  List<PostModel> get posts;
  bool get isLoading;
  bool get hasMorePosts;
  Object? get error;
  bool get isRefreshing;
  PostModel? get lastPost;

  /// Create a copy of AltFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AltFeedStateCopyWith<AltFeedState> get copyWith =>
      _$AltFeedStateCopyWithImpl<AltFeedState>(
          this as AltFeedState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'AltFeedState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMorePosts', hasMorePosts))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isRefreshing', isRefreshing))
      ..add(DiagnosticsProperty('lastPost', lastPost));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AltFeedState &&
            const DeepCollectionEquality().equals(other.posts, posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMorePosts, hasMorePosts) ||
                other.hasMorePosts == hasMorePosts) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.lastPost, lastPost) ||
                other.lastPost == lastPost));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(posts),
      isLoading,
      hasMorePosts,
      const DeepCollectionEquality().hash(error),
      isRefreshing,
      lastPost);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AltFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost)';
  }
}

/// @nodoc
abstract mixin class $AltFeedStateCopyWith<$Res> {
  factory $AltFeedStateCopyWith(
          AltFeedState value, $Res Function(AltFeedState) _then) =
      _$AltFeedStateCopyWithImpl;
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      bool hasMorePosts,
      Object? error,
      bool isRefreshing,
      PostModel? lastPost});

  $PostModelCopyWith<$Res>? get lastPost;
}

/// @nodoc
class _$AltFeedStateCopyWithImpl<$Res> implements $AltFeedStateCopyWith<$Res> {
  _$AltFeedStateCopyWithImpl(this._self, this._then);

  final AltFeedState _self;
  final $Res Function(AltFeedState) _then;

  /// Create a copy of AltFeedState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
    Object? isLoading = null,
    Object? hasMorePosts = null,
    Object? error = freezed,
    Object? isRefreshing = null,
    Object? lastPost = freezed,
  }) {
    return _then(_self.copyWith(
      posts: null == posts
          ? _self.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMorePosts: null == hasMorePosts
          ? _self.hasMorePosts
          : hasMorePosts // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error ? _self.error : error,
      isRefreshing: null == isRefreshing
          ? _self.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPost: freezed == lastPost
          ? _self.lastPost
          : lastPost // ignore: cast_nullable_to_non_nullable
              as PostModel?,
    ));
  }

  /// Create a copy of AltFeedState
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

class _AltFeedState with DiagnosticableTreeMixin implements AltFeedState {
  const _AltFeedState(
      {required final List<PostModel> posts,
      this.isLoading = false,
      this.hasMorePosts = true,
      this.error,
      this.isRefreshing = false,
      this.lastPost})
      : _posts = posts;

  final List<PostModel> _posts;
  @override
  List<PostModel> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasMorePosts;
  @override
  final Object? error;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  final PostModel? lastPost;

  /// Create a copy of AltFeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AltFeedStateCopyWith<_AltFeedState> get copyWith =>
      __$AltFeedStateCopyWithImpl<_AltFeedState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'AltFeedState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMorePosts', hasMorePosts))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isRefreshing', isRefreshing))
      ..add(DiagnosticsProperty('lastPost', lastPost));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AltFeedState &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMorePosts, hasMorePosts) ||
                other.hasMorePosts == hasMorePosts) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.lastPost, lastPost) ||
                other.lastPost == lastPost));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_posts),
      isLoading,
      hasMorePosts,
      const DeepCollectionEquality().hash(error),
      isRefreshing,
      lastPost);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AltFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost)';
  }
}

/// @nodoc
abstract mixin class _$AltFeedStateCopyWith<$Res>
    implements $AltFeedStateCopyWith<$Res> {
  factory _$AltFeedStateCopyWith(
          _AltFeedState value, $Res Function(_AltFeedState) _then) =
      __$AltFeedStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      bool hasMorePosts,
      Object? error,
      bool isRefreshing,
      PostModel? lastPost});

  @override
  $PostModelCopyWith<$Res>? get lastPost;
}

/// @nodoc
class __$AltFeedStateCopyWithImpl<$Res>
    implements _$AltFeedStateCopyWith<$Res> {
  __$AltFeedStateCopyWithImpl(this._self, this._then);

  final _AltFeedState _self;
  final $Res Function(_AltFeedState) _then;

  /// Create a copy of AltFeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? posts = null,
    Object? isLoading = null,
    Object? hasMorePosts = null,
    Object? error = freezed,
    Object? isRefreshing = null,
    Object? lastPost = freezed,
  }) {
    return _then(_AltFeedState(
      posts: null == posts
          ? _self._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMorePosts: null == hasMorePosts
          ? _self.hasMorePosts
          : hasMorePosts // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error ? _self.error : error,
      isRefreshing: null == isRefreshing
          ? _self.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPost: freezed == lastPost
          ? _self.lastPost
          : lastPost // ignore: cast_nullable_to_non_nullable
              as PostModel?,
    ));
  }

  /// Create a copy of AltFeedState
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
