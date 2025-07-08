// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_feed_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicFeedState implements DiagnosticableTreeMixin {
  List<PostModel> get posts;
  bool get isLoading;
  bool get hasMorePosts;
  Object? get error;
  bool get isRefreshing;
  PostModel? get lastPost;
  bool get fromCache;

  /// Create a copy of PublicFeedState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PublicFeedStateCopyWith<PublicFeedState> get copyWith =>
      _$PublicFeedStateCopyWithImpl<PublicFeedState>(
          this as PublicFeedState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PublicFeedState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMorePosts', hasMorePosts))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isRefreshing', isRefreshing))
      ..add(DiagnosticsProperty('lastPost', lastPost))
      ..add(DiagnosticsProperty('fromCache', fromCache));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PublicFeedState &&
            const DeepCollectionEquality().equals(other.posts, posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMorePosts, hasMorePosts) ||
                other.hasMorePosts == hasMorePosts) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.lastPost, lastPost) ||
                other.lastPost == lastPost) &&
            (identical(other.fromCache, fromCache) ||
                other.fromCache == fromCache));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(posts),
      isLoading,
      hasMorePosts,
      const DeepCollectionEquality().hash(error),
      isRefreshing,
      lastPost,
      fromCache);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PublicFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost, fromCache: $fromCache)';
  }
}

/// @nodoc
abstract mixin class $PublicFeedStateCopyWith<$Res> {
  factory $PublicFeedStateCopyWith(
          PublicFeedState value, $Res Function(PublicFeedState) _then) =
      _$PublicFeedStateCopyWithImpl;
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      bool hasMorePosts,
      Object? error,
      bool isRefreshing,
      PostModel? lastPost,
      bool fromCache});

  $PostModelCopyWith<$Res>? get lastPost;
}

/// @nodoc
class _$PublicFeedStateCopyWithImpl<$Res>
    implements $PublicFeedStateCopyWith<$Res> {
  _$PublicFeedStateCopyWithImpl(this._self, this._then);

  final PublicFeedState _self;
  final $Res Function(PublicFeedState) _then;

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
    Object? fromCache = null,
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
      fromCache: null == fromCache
          ? _self.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PublicFeedState
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

/// Adds pattern-matching-related methods to [PublicFeedState].
extension PublicFeedStatePatterns on PublicFeedState {
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
    TResult Function(_PublicFeedState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PublicFeedState() when $default != null:
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
    TResult Function(_PublicFeedState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublicFeedState():
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
    TResult? Function(_PublicFeedState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublicFeedState() when $default != null:
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
            List<PostModel> posts,
            bool isLoading,
            bool hasMorePosts,
            Object? error,
            bool isRefreshing,
            PostModel? lastPost,
            bool fromCache)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PublicFeedState() when $default != null:
        return $default(_that.posts, _that.isLoading, _that.hasMorePosts,
            _that.error, _that.isRefreshing, _that.lastPost, _that.fromCache);
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
            List<PostModel> posts,
            bool isLoading,
            bool hasMorePosts,
            Object? error,
            bool isRefreshing,
            PostModel? lastPost,
            bool fromCache)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublicFeedState():
        return $default(_that.posts, _that.isLoading, _that.hasMorePosts,
            _that.error, _that.isRefreshing, _that.lastPost, _that.fromCache);
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
            List<PostModel> posts,
            bool isLoading,
            bool hasMorePosts,
            Object? error,
            bool isRefreshing,
            PostModel? lastPost,
            bool fromCache)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PublicFeedState() when $default != null:
        return $default(_that.posts, _that.isLoading, _that.hasMorePosts,
            _that.error, _that.isRefreshing, _that.lastPost, _that.fromCache);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PublicFeedState with DiagnosticableTreeMixin implements PublicFeedState {
  const _PublicFeedState(
      {required final List<PostModel> posts,
      this.isLoading = false,
      this.hasMorePosts = true,
      this.error,
      this.isRefreshing = false,
      this.lastPost,
      this.fromCache = false})
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
  @JsonKey()
  final bool fromCache;

  /// Create a copy of PublicFeedState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PublicFeedStateCopyWith<_PublicFeedState> get copyWith =>
      __$PublicFeedStateCopyWithImpl<_PublicFeedState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PublicFeedState'))
      ..add(DiagnosticsProperty('posts', posts))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMorePosts', hasMorePosts))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isRefreshing', isRefreshing))
      ..add(DiagnosticsProperty('lastPost', lastPost))
      ..add(DiagnosticsProperty('fromCache', fromCache));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PublicFeedState &&
            const DeepCollectionEquality().equals(other._posts, _posts) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMorePosts, hasMorePosts) ||
                other.hasMorePosts == hasMorePosts) &&
            const DeepCollectionEquality().equals(other.error, error) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.lastPost, lastPost) ||
                other.lastPost == lastPost) &&
            (identical(other.fromCache, fromCache) ||
                other.fromCache == fromCache));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_posts),
      isLoading,
      hasMorePosts,
      const DeepCollectionEquality().hash(error),
      isRefreshing,
      lastPost,
      fromCache);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PublicFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost, fromCache: $fromCache)';
  }
}

/// @nodoc
abstract mixin class _$PublicFeedStateCopyWith<$Res>
    implements $PublicFeedStateCopyWith<$Res> {
  factory _$PublicFeedStateCopyWith(
          _PublicFeedState value, $Res Function(_PublicFeedState) _then) =
      __$PublicFeedStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<PostModel> posts,
      bool isLoading,
      bool hasMorePosts,
      Object? error,
      bool isRefreshing,
      PostModel? lastPost,
      bool fromCache});

  @override
  $PostModelCopyWith<$Res>? get lastPost;
}

/// @nodoc
class __$PublicFeedStateCopyWithImpl<$Res>
    implements _$PublicFeedStateCopyWith<$Res> {
  __$PublicFeedStateCopyWithImpl(this._self, this._then);

  final _PublicFeedState _self;
  final $Res Function(_PublicFeedState) _then;

  /// Create a copy of PublicFeedState
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
    Object? fromCache = null,
  }) {
    return _then(_PublicFeedState(
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
      fromCache: null == fromCache
          ? _self.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }

  /// Create a copy of PublicFeedState
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
