// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_interaction_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostInteractionState implements DiagnosticableTreeMixin {
  int get totalLikes; // Net likes (likes - dislikes)
  int get totalRawLikes; // Raw like count
  int get totalComments; // Total comments
  int get totalRawDislikes; // Raw dislike count
  bool get isLoading; // Loading state
  String? get error; // Error message
  bool get isLiked; // Whether user has liked
  bool get isDisliked;

  /// Create a copy of PostInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostInteractionStateCopyWith<PostInteractionState> get copyWith =>
      _$PostInteractionStateCopyWithImpl<PostInteractionState>(
          this as PostInteractionState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostInteractionState'))
      ..add(DiagnosticsProperty('totalLikes', totalLikes))
      ..add(DiagnosticsProperty('totalRawLikes', totalRawLikes))
      ..add(DiagnosticsProperty('totalComments', totalComments))
      ..add(DiagnosticsProperty('totalRawDislikes', totalRawDislikes))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostInteractionState &&
            (identical(other.totalLikes, totalLikes) ||
                other.totalLikes == totalLikes) &&
            (identical(other.totalRawLikes, totalRawLikes) ||
                other.totalRawLikes == totalRawLikes) &&
            (identical(other.totalComments, totalComments) ||
                other.totalComments == totalComments) &&
            (identical(other.totalRawDislikes, totalRawDislikes) ||
                other.totalRawDislikes == totalRawDislikes) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalLikes, totalRawLikes,
      totalComments, totalRawDislikes, isLoading, error, isLiked, isDisliked);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostInteractionState(totalLikes: $totalLikes, totalRawLikes: $totalRawLikes, totalComments: $totalComments, totalRawDislikes: $totalRawDislikes, isLoading: $isLoading, error: $error, isLiked: $isLiked, isDisliked: $isDisliked)';
  }
}

/// @nodoc
abstract mixin class $PostInteractionStateCopyWith<$Res> {
  factory $PostInteractionStateCopyWith(PostInteractionState value,
          $Res Function(PostInteractionState) _then) =
      _$PostInteractionStateCopyWithImpl;
  @useResult
  $Res call(
      {int totalLikes,
      int totalRawLikes,
      int totalComments,
      int totalRawDislikes,
      bool isLoading,
      String? error,
      bool isLiked,
      bool isDisliked});
}

/// @nodoc
class _$PostInteractionStateCopyWithImpl<$Res>
    implements $PostInteractionStateCopyWith<$Res> {
  _$PostInteractionStateCopyWithImpl(this._self, this._then);

  final PostInteractionState _self;
  final $Res Function(PostInteractionState) _then;

  /// Create a copy of PostInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? totalLikes = null,
    Object? totalRawLikes = null,
    Object? totalComments = null,
    Object? totalRawDislikes = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isLiked = null,
    Object? isDisliked = null,
  }) {
    return _then(_self.copyWith(
      totalLikes: null == totalLikes
          ? _self.totalLikes
          : totalLikes // ignore: cast_nullable_to_non_nullable
              as int,
      totalRawLikes: null == totalRawLikes
          ? _self.totalRawLikes
          : totalRawLikes // ignore: cast_nullable_to_non_nullable
              as int,
      totalComments: null == totalComments
          ? _self.totalComments
          : totalComments // ignore: cast_nullable_to_non_nullable
              as int,
      totalRawDislikes: null == totalRawDislikes
          ? _self.totalRawDislikes
          : totalRawDislikes // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [PostInteractionState].
extension PostInteractionStatePatterns on PostInteractionState {
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
    TResult Function(_PostInteractionState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostInteractionState() when $default != null:
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
    TResult Function(_PostInteractionState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostInteractionState():
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
    TResult? Function(_PostInteractionState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostInteractionState() when $default != null:
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
            int totalLikes,
            int totalRawLikes,
            int totalComments,
            int totalRawDislikes,
            bool isLoading,
            String? error,
            bool isLiked,
            bool isDisliked)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _PostInteractionState() when $default != null:
        return $default(
            _that.totalLikes,
            _that.totalRawLikes,
            _that.totalComments,
            _that.totalRawDislikes,
            _that.isLoading,
            _that.error,
            _that.isLiked,
            _that.isDisliked);
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
            int totalLikes,
            int totalRawLikes,
            int totalComments,
            int totalRawDislikes,
            bool isLoading,
            String? error,
            bool isLiked,
            bool isDisliked)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostInteractionState():
        return $default(
            _that.totalLikes,
            _that.totalRawLikes,
            _that.totalComments,
            _that.totalRawDislikes,
            _that.isLoading,
            _that.error,
            _that.isLiked,
            _that.isDisliked);
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
            int totalLikes,
            int totalRawLikes,
            int totalComments,
            int totalRawDislikes,
            bool isLoading,
            String? error,
            bool isLiked,
            bool isDisliked)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _PostInteractionState() when $default != null:
        return $default(
            _that.totalLikes,
            _that.totalRawLikes,
            _that.totalComments,
            _that.totalRawDislikes,
            _that.isLoading,
            _that.error,
            _that.isLiked,
            _that.isDisliked);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _PostInteractionState
    with DiagnosticableTreeMixin
    implements PostInteractionState {
  const _PostInteractionState(
      {this.totalLikes = 0,
      this.totalRawLikes = 0,
      this.totalComments = 0,
      this.totalRawDislikes = 0,
      this.isLoading = false,
      this.error,
      this.isLiked = false,
      this.isDisliked = false});

  @override
  @JsonKey()
  final int totalLikes;
// Net likes (likes - dislikes)
  @override
  @JsonKey()
  final int totalRawLikes;
// Raw like count
  @override
  @JsonKey()
  final int totalComments;
// Total comments
  @override
  @JsonKey()
  final int totalRawDislikes;
// Raw dislike count
  @override
  @JsonKey()
  final bool isLoading;
// Loading state
  @override
  final String? error;
// Error message
  @override
  @JsonKey()
  final bool isLiked;
// Whether user has liked
  @override
  @JsonKey()
  final bool isDisliked;

  /// Create a copy of PostInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostInteractionStateCopyWith<_PostInteractionState> get copyWith =>
      __$PostInteractionStateCopyWithImpl<_PostInteractionState>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostInteractionState'))
      ..add(DiagnosticsProperty('totalLikes', totalLikes))
      ..add(DiagnosticsProperty('totalRawLikes', totalRawLikes))
      ..add(DiagnosticsProperty('totalComments', totalComments))
      ..add(DiagnosticsProperty('totalRawDislikes', totalRawDislikes))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostInteractionState &&
            (identical(other.totalLikes, totalLikes) ||
                other.totalLikes == totalLikes) &&
            (identical(other.totalRawLikes, totalRawLikes) ||
                other.totalRawLikes == totalRawLikes) &&
            (identical(other.totalComments, totalComments) ||
                other.totalComments == totalComments) &&
            (identical(other.totalRawDislikes, totalRawDislikes) ||
                other.totalRawDislikes == totalRawDislikes) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked));
  }

  @override
  int get hashCode => Object.hash(runtimeType, totalLikes, totalRawLikes,
      totalComments, totalRawDislikes, isLoading, error, isLiked, isDisliked);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostInteractionState(totalLikes: $totalLikes, totalRawLikes: $totalRawLikes, totalComments: $totalComments, totalRawDislikes: $totalRawDislikes, isLoading: $isLoading, error: $error, isLiked: $isLiked, isDisliked: $isDisliked)';
  }
}

/// @nodoc
abstract mixin class _$PostInteractionStateCopyWith<$Res>
    implements $PostInteractionStateCopyWith<$Res> {
  factory _$PostInteractionStateCopyWith(_PostInteractionState value,
          $Res Function(_PostInteractionState) _then) =
      __$PostInteractionStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {int totalLikes,
      int totalRawLikes,
      int totalComments,
      int totalRawDislikes,
      bool isLoading,
      String? error,
      bool isLiked,
      bool isDisliked});
}

/// @nodoc
class __$PostInteractionStateCopyWithImpl<$Res>
    implements _$PostInteractionStateCopyWith<$Res> {
  __$PostInteractionStateCopyWithImpl(this._self, this._then);

  final _PostInteractionState _self;
  final $Res Function(_PostInteractionState) _then;

  /// Create a copy of PostInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? totalLikes = null,
    Object? totalRawLikes = null,
    Object? totalComments = null,
    Object? totalRawDislikes = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? isLiked = null,
    Object? isDisliked = null,
  }) {
    return _then(_PostInteractionState(
      totalLikes: null == totalLikes
          ? _self.totalLikes
          : totalLikes // ignore: cast_nullable_to_non_nullable
              as int,
      totalRawLikes: null == totalRawLikes
          ? _self.totalRawLikes
          : totalRawLikes // ignore: cast_nullable_to_non_nullable
              as int,
      totalComments: null == totalComments
          ? _self.totalComments
          : totalComments // ignore: cast_nullable_to_non_nullable
              as int,
      totalRawDislikes: null == totalRawDislikes
          ? _self.totalRawDislikes
          : totalRawDislikes // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
