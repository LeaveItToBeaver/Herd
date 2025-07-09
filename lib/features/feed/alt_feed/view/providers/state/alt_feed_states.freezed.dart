// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
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
  bool get fromCache;
  FeedSortType get sortType;
  DateTime? get lastCreatedAt;

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
      ..add(DiagnosticsProperty('lastPost', lastPost))
      ..add(DiagnosticsProperty('fromCache', fromCache))
      ..add(DiagnosticsProperty('sortType', sortType))
      ..add(DiagnosticsProperty('lastCreatedAt', lastCreatedAt));
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
                other.lastPost == lastPost) &&
            (identical(other.fromCache, fromCache) ||
                other.fromCache == fromCache) &&
            (identical(other.sortType, sortType) ||
                other.sortType == sortType) &&
            (identical(other.lastCreatedAt, lastCreatedAt) ||
                other.lastCreatedAt == lastCreatedAt));
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
      fromCache,
      sortType,
      lastCreatedAt);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AltFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost, fromCache: $fromCache, sortType: $sortType, lastCreatedAt: $lastCreatedAt)';
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
      PostModel? lastPost,
      bool fromCache,
      FeedSortType sortType,
      DateTime? lastCreatedAt});

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
    Object? fromCache = null,
    Object? sortType = null,
    Object? lastCreatedAt = freezed,
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
      sortType: null == sortType
          ? _self.sortType
          : sortType // ignore: cast_nullable_to_non_nullable
              as FeedSortType,
      lastCreatedAt: freezed == lastCreatedAt
          ? _self.lastCreatedAt
          : lastCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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

/// Adds pattern-matching-related methods to [AltFeedState].
extension AltFeedStatePatterns on AltFeedState {
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
    TResult Function(_AltFeedState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AltFeedState() when $default != null:
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
    TResult Function(_AltFeedState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AltFeedState():
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
    TResult? Function(_AltFeedState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AltFeedState() when $default != null:
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
            bool fromCache,
            FeedSortType sortType,
            DateTime? lastCreatedAt)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AltFeedState() when $default != null:
        return $default(
            _that.posts,
            _that.isLoading,
            _that.hasMorePosts,
            _that.error,
            _that.isRefreshing,
            _that.lastPost,
            _that.fromCache,
            _that.sortType,
            _that.lastCreatedAt);
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
            bool fromCache,
            FeedSortType sortType,
            DateTime? lastCreatedAt)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AltFeedState():
        return $default(
            _that.posts,
            _that.isLoading,
            _that.hasMorePosts,
            _that.error,
            _that.isRefreshing,
            _that.lastPost,
            _that.fromCache,
            _that.sortType,
            _that.lastCreatedAt);
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
            bool fromCache,
            FeedSortType sortType,
            DateTime? lastCreatedAt)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AltFeedState() when $default != null:
        return $default(
            _that.posts,
            _that.isLoading,
            _that.hasMorePosts,
            _that.error,
            _that.isRefreshing,
            _that.lastPost,
            _that.fromCache,
            _that.sortType,
            _that.lastCreatedAt);
      case _:
        return null;
    }
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
      this.lastPost,
      this.fromCache = false,
      this.sortType = FeedSortType.hot,
      this.lastCreatedAt})
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
  @override
  @JsonKey()
  final FeedSortType sortType;
  @override
  final DateTime? lastCreatedAt;

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
      ..add(DiagnosticsProperty('lastPost', lastPost))
      ..add(DiagnosticsProperty('fromCache', fromCache))
      ..add(DiagnosticsProperty('sortType', sortType))
      ..add(DiagnosticsProperty('lastCreatedAt', lastCreatedAt));
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
                other.lastPost == lastPost) &&
            (identical(other.fromCache, fromCache) ||
                other.fromCache == fromCache) &&
            (identical(other.sortType, sortType) ||
                other.sortType == sortType) &&
            (identical(other.lastCreatedAt, lastCreatedAt) ||
                other.lastCreatedAt == lastCreatedAt));
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
      fromCache,
      sortType,
      lastCreatedAt);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'AltFeedState(posts: $posts, isLoading: $isLoading, hasMorePosts: $hasMorePosts, error: $error, isRefreshing: $isRefreshing, lastPost: $lastPost, fromCache: $fromCache, sortType: $sortType, lastCreatedAt: $lastCreatedAt)';
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
      PostModel? lastPost,
      bool fromCache,
      FeedSortType sortType,
      DateTime? lastCreatedAt});

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
    Object? fromCache = null,
    Object? sortType = null,
    Object? lastCreatedAt = freezed,
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
      fromCache: null == fromCache
          ? _self.fromCache
          : fromCache // ignore: cast_nullable_to_non_nullable
              as bool,
      sortType: null == sortType
          ? _self.sortType
          : sortType // ignore: cast_nullable_to_non_nullable
              as FeedSortType,
      lastCreatedAt: freezed == lastCreatedAt
          ? _self.lastCreatedAt
          : lastCreatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
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
