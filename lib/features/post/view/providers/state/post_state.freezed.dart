// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PostState {
  List<PostModel> get posts =>
      throw _privateConstructorUsedError; // Default to empty list
  bool get isLoading =>
      throw _privateConstructorUsedError; // Default to not loading
  String? get error =>
      throw _privateConstructorUsedError; // Nullable error message
  Map<String, bool> get likedPosts => throw _privateConstructorUsedError;
  bool get isLiked =>
      throw _privateConstructorUsedError; // Default to empty map
  Map<String, bool> get dislikedPosts => throw _privateConstructorUsedError;
  bool get isDisliked => throw _privateConstructorUsedError;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PostStateCopyWith<PostState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PostStateCopyWith<$Res> {
  factory $PostStateCopyWith(PostState value, $Res Function(PostState) then) =
      _$PostStateCopyWithImpl<$Res, PostState>;
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
class _$PostStateCopyWithImpl<$Res, $Val extends PostState>
    implements $PostStateCopyWith<$Res> {
  _$PostStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

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
    return _then(_value.copyWith(
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      likedPosts: null == likedPosts
          ? _value.likedPosts
          : likedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      dislikedPosts: null == dislikedPosts
          ? _value.dislikedPosts
          : dislikedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isDisliked: null == isDisliked
          ? _value.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PostStateImplCopyWith<$Res>
    implements $PostStateCopyWith<$Res> {
  factory _$$PostStateImplCopyWith(
          _$PostStateImpl value, $Res Function(_$PostStateImpl) then) =
      __$$PostStateImplCopyWithImpl<$Res>;
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
class __$$PostStateImplCopyWithImpl<$Res>
    extends _$PostStateCopyWithImpl<$Res, _$PostStateImpl>
    implements _$$PostStateImplCopyWith<$Res> {
  __$$PostStateImplCopyWithImpl(
      _$PostStateImpl _value, $Res Function(_$PostStateImpl) _then)
      : super(_value, _then);

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
    return _then(_$PostStateImpl(
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      likedPosts: null == likedPosts
          ? _value._likedPosts
          : likedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      dislikedPosts: null == dislikedPosts
          ? _value._dislikedPosts
          : dislikedPosts // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      isDisliked: null == isDisliked
          ? _value.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$PostStateImpl implements _PostState {
  const _$PostStateImpl(
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

  @override
  String toString() {
    return 'PostState(posts: $posts, isLoading: $isLoading, error: $error, likedPosts: $likedPosts, isLiked: $isLiked, dislikedPosts: $dislikedPosts, isDisliked: $isDisliked)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PostStateImpl &&
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

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PostStateImplCopyWith<_$PostStateImpl> get copyWith =>
      __$$PostStateImplCopyWithImpl<_$PostStateImpl>(this, _$identity);
}

abstract class _PostState implements PostState {
  const factory _PostState(
      {final List<PostModel> posts,
      final bool isLoading,
      final String? error,
      final Map<String, bool> likedPosts,
      final bool isLiked,
      final Map<String, bool> dislikedPosts,
      final bool isDisliked}) = _$PostStateImpl;

  @override
  List<PostModel> get posts; // Default to empty list
  @override
  bool get isLoading; // Default to not loading
  @override
  String? get error; // Nullable error message
  @override
  Map<String, bool> get likedPosts;
  @override
  bool get isLiked; // Default to empty map
  @override
  Map<String, bool> get dislikedPosts;
  @override
  bool get isDisliked;

  /// Create a copy of PostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PostStateImplCopyWith<_$PostStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
