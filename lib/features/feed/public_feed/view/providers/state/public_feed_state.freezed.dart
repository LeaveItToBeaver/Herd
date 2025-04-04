// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PublicFeedState {
  List<PostModel> get posts => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasMorePosts => throw _privateConstructorUsedError;
  Object? get error => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  PostModel? get lastPost => throw _privateConstructorUsedError;

  /// Create a copy of PublicFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PublicFeedStateCopyWith<PublicFeedState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PublicFeedStateCopyWith<$Res> {
  factory $PublicFeedStateCopyWith(
          PublicFeedState value, $Res Function(PublicFeedState) then) =
      _$PublicFeedStateCopyWithImpl<$Res, PublicFeedState>;
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      bool hasMorePosts,
      Object? error,
      bool isRefreshing,
      PostModel? lastPost});
}

/// @nodoc
class _$PublicFeedStateCopyWithImpl<$Res, $Val extends PublicFeedState>
    implements $PublicFeedStateCopyWith<$Res> {
  _$PublicFeedStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PublicFeedState
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
    return _then(_value.copyWith(
      posts: null == posts
          ? _value.posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMorePosts: null == hasMorePosts
          ? _value.hasMorePosts
          : hasMorePosts // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error ? _value.error : error,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPost: freezed == lastPost
          ? _value.lastPost
          : lastPost // ignore: cast_nullable_to_non_nullable
              as PostModel?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PublicFeedStateImplCopyWith<$Res>
    implements $PublicFeedStateCopyWith<$Res> {
  factory _$$PublicFeedStateImplCopyWith(_$PublicFeedStateImpl value,
          $Res Function(_$PublicFeedStateImpl) then) =
      __$$PublicFeedStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      bool hasMorePosts,
      Object? error,
      bool isRefreshing,
      PostModel? lastPost});
}

/// @nodoc
class __$$PublicFeedStateImplCopyWithImpl<$Res>
    extends _$PublicFeedStateCopyWithImpl<$Res, _$PublicFeedStateImpl>
    implements _$$PublicFeedStateImplCopyWith<$Res> {
  __$$PublicFeedStateImplCopyWithImpl(
      _$PublicFeedStateImpl _value, $Res Function(_$PublicFeedStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PublicFeedState
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
    return _then(_$PublicFeedStateImpl(
      posts: null == posts
          ? _value._posts
          : posts // ignore: cast_nullable_to_non_nullable
              as List<PostModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMorePosts: null == hasMorePosts
          ? _value.hasMorePosts
          : hasMorePosts // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error ? _value.error : error,
      isRefreshing: null == isRefreshing
          ? _value.isRefreshing
          : isRefreshing // ignore: cast_nullable_to_non_nullable
              as bool,
      lastPost: freezed == lastPost
          ? _value.lastPost
          : lastPost // ignore: cast_nullable_to_non_nullable
              as PostModel?,
    ));
  }
}

/// @nodoc

class _$PublicFeedStateImpl implements _PublicFeedState {
  const _$PublicFeedStateImpl(
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

  @override
  String toString() {
    return 'PublicFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PublicFeedStateImpl &&
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

  /// Create a copy of PublicFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PublicFeedStateImplCopyWith<_$PublicFeedStateImpl> get copyWith =>
      __$$PublicFeedStateImplCopyWithImpl<_$PublicFeedStateImpl>(
          this, _$identity);
}

abstract class _PublicFeedState implements PublicFeedState {
  const factory _PublicFeedState(
      {required final List<PostModel> posts,
      final bool isLoading,
      final bool hasMorePosts,
      final Object? error,
      final bool isRefreshing,
      final PostModel? lastPost}) = _$PublicFeedStateImpl;

  @override
  List<PostModel> get posts;
  @override
  bool get isLoading;
  @override
  bool get hasMorePosts;
  @override
  Object? get error;
  @override
  bool get isRefreshing;
  @override
  PostModel? get lastPost;

  /// Create a copy of PublicFeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PublicFeedStateImplCopyWith<_$PublicFeedStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
