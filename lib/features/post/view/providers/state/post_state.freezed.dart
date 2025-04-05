// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostState implements DiagnosticableTreeMixin {
  List<PostModel> get posts; // Default to empty list
  bool get isLoading; // Default to not loading
  String? get error; // Nullable error message
  Map<String, bool> get likedPosts;
  bool get isLiked; // Default to empty map
  Map<String, bool> get dislikedPosts;
  bool get isDisliked;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostStateCopyWith<PostState> get copyWith =>
      _$PostStateCopyWithImpl<PostState>(this as PostState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('likedPosts', likedPosts))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('dislikedPosts', dislikedPosts))
      ..add(DiagnosticsProperty('isDisliked', isDisliked));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostState &&
            const DeepCollectionEquality().equals(other.posts, posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other.likedPosts, likedPosts) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            const DeepCollectionEquality()
                .equals(other.dislikedPosts, dislikedPosts) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(posts),
      isLoading,
      error,
      const DeepCollectionEquality().hash(likedPosts),
      isLiked,
      const DeepCollectionEquality().hash(dislikedPosts),
      isDisliked);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostState(posts: $posts, isLoading: $isLoading, error: $error, likedPosts: $likedPosts, isLiked: $isLiked, dislikedPosts: $dislikedPosts, isDisliked: $isDisliked)';
  }
}

/// @nodoc
abstract mixin class $PostStateCopyWith<$Res> {
  factory $PostStateCopyWith(PostState value, $Res Function(PostState) _then) =
      _$PostStateCopyWithImpl;
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      String? error,
      Map<String, bool> likedPosts,
      bool isLiked,
      Map<String, bool> dislikedPosts,
      bool isDisliked});
}

/// @nodoc
class _$PostStateCopyWithImpl<$Res> implements $PostStateCopyWith<$Res> {
  _$PostStateCopyWithImpl(this._self, this._then);

  final PostState _self;
  final $Res Function(PostState) _then;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? posts = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? likedPosts = null,
    Object? isLiked = null,
    Object? dislikedPosts = null,
    Object? isDisliked = null,
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
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      likedPosts: null == likedPosts
          ? _self.likedPosts
          : likedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      dislikedPosts: null == dislikedPosts
          ? _self.dislikedPosts
          : dislikedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _PostState with DiagnosticableTreeMixin implements PostState {
  const _PostState(
      {final List<PostModel> posts = const [],
      this.isLoading = false,
      this.error,
      final Map<String, bool> likedPosts = const {},
      this.isLiked = false,
      final Map<String, bool> dislikedPosts = const {},
      this.isDisliked = false})
      : _posts = posts,
        _likedPosts = likedPosts,
        _dislikedPosts = dislikedPosts;

  final List<PostModel> _posts;
  @override
  @JsonKey()
  List<PostModel> get posts {
    if (_posts is EqualUnmodifiableListView) return _posts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_posts);
  }

// Default to empty list
  @override
  @JsonKey()
  final bool isLoading;
// Default to not loading
  @override
  final String? error;
// Nullable error message
  final Map<String, bool> _likedPosts;
// Nullable error message
  @override
  @JsonKey()
  Map<String, bool> get likedPosts {
    if (_likedPosts is EqualUnmodifiableMapView) return _likedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_likedPosts);
  }

  @override
  @JsonKey()
  final bool isLiked;
// Default to empty map
  final Map<String, bool> _dislikedPosts;
// Default to empty map
  @override
  @JsonKey()
  Map<String, bool> get dislikedPosts {
    if (_dislikedPosts is EqualUnmodifiableMapView) return _dislikedPosts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_dislikedPosts);
  }

  @override
  @JsonKey()
  final bool isDisliked;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostStateCopyWith<_PostState> get copyWith =>
      __$PostStateCopyWithImpl<_PostState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('likedPosts', likedPosts))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('dislikedPosts', dislikedPosts))
      ..add(DiagnosticsProperty('isDisliked', isDisliked));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostState &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            const DeepCollectionEquality()
                .equals(other._likedPosts, _likedPosts) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            const DeepCollectionEquality()
                .equals(other._dislikedPosts, _dislikedPosts) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_posts),
      isLoading,
      error,
      const DeepCollectionEquality().hash(_likedPosts),
      isLiked,
      const DeepCollectionEquality().hash(_dislikedPosts),
      isDisliked);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostState(posts: $posts, isLoading: $isLoading, error: $error, likedPosts: $likedPosts, isLiked: $isLiked, dislikedPosts: $dislikedPosts, isDisliked: $isDisliked)';
  }
}

/// @nodoc
abstract mixin class _$PostStateCopyWith<$Res>
    implements $PostStateCopyWith<$Res> {
  factory _$PostStateCopyWith(
          _PostState value, $Res Function(_PostState) _then) =
      __$PostStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      String? error,
      Map<String, bool> likedPosts,
      bool isLiked,
      Map<String, bool> dislikedPosts,
      bool isDisliked});
}

/// @nodoc
class __$PostStateCopyWithImpl<$Res> implements _$PostStateCopyWith<$Res> {
  __$PostStateCopyWithImpl(this._self, this._then);

  final _PostState _self;
  final $Res Function(_PostState) _then;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? posts = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? likedPosts = null,
    Object? isLiked = null,
    Object? dislikedPosts = null,
    Object? isDisliked = null,
  }) {
    return _then(_PostState(
      posts: null == posts
          ? _self._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      likedPosts: null == likedPosts
          ? _self._likedPosts
          : likedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      dislikedPosts: null == dislikedPosts
          ? _self._dislikedPosts
          : dislikedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
