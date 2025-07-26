// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'drag_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DragState {
  String get bubbleId;
  BubbleConfigState get bubbleConfig;
  Offset get startPosition;
  Offset get currentPosition;
  Offset get touchOffset;
  Size get bubbleSize;
  Offset get bubbleCenterOffset; // Center point of the bubble
  GlobalKey get bubbleKey;

  /// Create a copy of DragState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $DragStateCopyWith<DragState> get copyWith =>
      _$DragStateCopyWithImpl<DragState>(this as DragState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is DragState &&
            (identical(other.bubbleId, bubbleId) ||
                other.bubbleId == bubbleId) &&
            (identical(other.bubbleConfig, bubbleConfig) ||
                other.bubbleConfig == bubbleConfig) &&
            (identical(other.startPosition, startPosition) ||
                other.startPosition == startPosition) &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition) &&
            (identical(other.touchOffset, touchOffset) ||
                other.touchOffset == touchOffset) &&
            (identical(other.bubbleSize, bubbleSize) ||
                other.bubbleSize == bubbleSize) &&
            (identical(other.bubbleCenterOffset, bubbleCenterOffset) ||
                other.bubbleCenterOffset == bubbleCenterOffset) &&
            (identical(other.bubbleKey, bubbleKey) ||
                other.bubbleKey == bubbleKey));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      bubbleId,
      bubbleConfig,
      startPosition,
      currentPosition,
      touchOffset,
      bubbleSize,
      bubbleCenterOffset,
      bubbleKey);

  @override
  String toString() {
    return 'DragState(bubbleId: $bubbleId, bubbleConfig: $bubbleConfig, startPosition: $startPosition, currentPosition: $currentPosition, touchOffset: $touchOffset, bubbleSize: $bubbleSize, bubbleCenterOffset: $bubbleCenterOffset, bubbleKey: $bubbleKey)';
  }
}

/// @nodoc
abstract mixin class $DragStateCopyWith<$Res> {
  factory $DragStateCopyWith(DragState value, $Res Function(DragState) _then) =
      _$DragStateCopyWithImpl;
  @useResult
  $Res call(
      {String bubbleId,
      BubbleConfigState bubbleConfig,
      Offset startPosition,
      Offset currentPosition,
      Offset touchOffset,
      Size bubbleSize,
      Offset bubbleCenterOffset,
      GlobalKey bubbleKey});

  $BubbleConfigStateCopyWith<$Res> get bubbleConfig;
}

/// @nodoc
class _$DragStateCopyWithImpl<$Res> implements $DragStateCopyWith<$Res> {
  _$DragStateCopyWithImpl(this._self, this._then);

  final DragState _self;
  final $Res Function(DragState) _then;

  /// Create a copy of DragState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? bubbleId = null,
    Object? bubbleConfig = null,
    Object? startPosition = null,
    Object? currentPosition = null,
    Object? touchOffset = null,
    Object? bubbleSize = null,
    Object? bubbleCenterOffset = null,
    Object? bubbleKey = null,
  }) {
    return _then(_self.copyWith(
      bubbleId: null == bubbleId
          ? _self.bubbleId
          : bubbleId // ignore: cast_nullable_to_non_nullable
              as String,
      bubbleConfig: null == bubbleConfig
          ? _self.bubbleConfig
          : bubbleConfig // ignore: cast_nullable_to_non_nullable
              as BubbleConfigState,
      startPosition: null == startPosition
          ? _self.startPosition
          : startPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      currentPosition: null == currentPosition
          ? _self.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      touchOffset: null == touchOffset
          ? _self.touchOffset
          : touchOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      bubbleSize: null == bubbleSize
          ? _self.bubbleSize
          : bubbleSize // ignore: cast_nullable_to_non_nullable
              as Size,
      bubbleCenterOffset: null == bubbleCenterOffset
          ? _self.bubbleCenterOffset
          : bubbleCenterOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      bubbleKey: null == bubbleKey
          ? _self.bubbleKey
          : bubbleKey // ignore: cast_nullable_to_non_nullable
              as GlobalKey,
    ));
  }

  /// Create a copy of DragState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BubbleConfigStateCopyWith<$Res> get bubbleConfig {
    return $BubbleConfigStateCopyWith<$Res>(_self.bubbleConfig, (value) {
      return _then(_self.copyWith(bubbleConfig: value));
    });
  }
}

/// Adds pattern-matching-related methods to [DragState].
extension DragStatePatterns on DragState {
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
    TResult Function(_DragState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DragState() when $default != null:
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
    TResult Function(_DragState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DragState():
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
    TResult? Function(_DragState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DragState() when $default != null:
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
            String bubbleId,
            BubbleConfigState bubbleConfig,
            Offset startPosition,
            Offset currentPosition,
            Offset touchOffset,
            Size bubbleSize,
            Offset bubbleCenterOffset,
            GlobalKey bubbleKey)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _DragState() when $default != null:
        return $default(
            _that.bubbleId,
            _that.bubbleConfig,
            _that.startPosition,
            _that.currentPosition,
            _that.touchOffset,
            _that.bubbleSize,
            _that.bubbleCenterOffset,
            _that.bubbleKey);
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
            String bubbleId,
            BubbleConfigState bubbleConfig,
            Offset startPosition,
            Offset currentPosition,
            Offset touchOffset,
            Size bubbleSize,
            Offset bubbleCenterOffset,
            GlobalKey bubbleKey)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DragState():
        return $default(
            _that.bubbleId,
            _that.bubbleConfig,
            _that.startPosition,
            _that.currentPosition,
            _that.touchOffset,
            _that.bubbleSize,
            _that.bubbleCenterOffset,
            _that.bubbleKey);
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
            String bubbleId,
            BubbleConfigState bubbleConfig,
            Offset startPosition,
            Offset currentPosition,
            Offset touchOffset,
            Size bubbleSize,
            Offset bubbleCenterOffset,
            GlobalKey bubbleKey)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _DragState() when $default != null:
        return $default(
            _that.bubbleId,
            _that.bubbleConfig,
            _that.startPosition,
            _that.currentPosition,
            _that.touchOffset,
            _that.bubbleSize,
            _that.bubbleCenterOffset,
            _that.bubbleKey);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _DragState extends DragState {
  const _DragState(
      {required this.bubbleId,
      required this.bubbleConfig,
      required this.startPosition,
      required this.currentPosition,
      required this.touchOffset,
      required this.bubbleSize,
      required this.bubbleCenterOffset,
      required this.bubbleKey})
      : super._();

  @override
  final String bubbleId;
  @override
  final BubbleConfigState bubbleConfig;
  @override
  final Offset startPosition;
  @override
  final Offset currentPosition;
  @override
  final Offset touchOffset;
  @override
  final Size bubbleSize;
  @override
  final Offset bubbleCenterOffset;
// Center point of the bubble
  @override
  final GlobalKey bubbleKey;

  /// Create a copy of DragState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$DragStateCopyWith<_DragState> get copyWith =>
      __$DragStateCopyWithImpl<_DragState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _DragState &&
            (identical(other.bubbleId, bubbleId) ||
                other.bubbleId == bubbleId) &&
            (identical(other.bubbleConfig, bubbleConfig) ||
                other.bubbleConfig == bubbleConfig) &&
            (identical(other.startPosition, startPosition) ||
                other.startPosition == startPosition) &&
            (identical(other.currentPosition, currentPosition) ||
                other.currentPosition == currentPosition) &&
            (identical(other.touchOffset, touchOffset) ||
                other.touchOffset == touchOffset) &&
            (identical(other.bubbleSize, bubbleSize) ||
                other.bubbleSize == bubbleSize) &&
            (identical(other.bubbleCenterOffset, bubbleCenterOffset) ||
                other.bubbleCenterOffset == bubbleCenterOffset) &&
            (identical(other.bubbleKey, bubbleKey) ||
                other.bubbleKey == bubbleKey));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      bubbleId,
      bubbleConfig,
      startPosition,
      currentPosition,
      touchOffset,
      bubbleSize,
      bubbleCenterOffset,
      bubbleKey);

  @override
  String toString() {
    return 'DragState(bubbleId: $bubbleId, bubbleConfig: $bubbleConfig, startPosition: $startPosition, currentPosition: $currentPosition, touchOffset: $touchOffset, bubbleSize: $bubbleSize, bubbleCenterOffset: $bubbleCenterOffset, bubbleKey: $bubbleKey)';
  }
}

/// @nodoc
abstract mixin class _$DragStateCopyWith<$Res>
    implements $DragStateCopyWith<$Res> {
  factory _$DragStateCopyWith(
          _DragState value, $Res Function(_DragState) _then) =
      __$DragStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String bubbleId,
      BubbleConfigState bubbleConfig,
      Offset startPosition,
      Offset currentPosition,
      Offset touchOffset,
      Size bubbleSize,
      Offset bubbleCenterOffset,
      GlobalKey bubbleKey});

  @override
  $BubbleConfigStateCopyWith<$Res> get bubbleConfig;
}

/// @nodoc
class __$DragStateCopyWithImpl<$Res> implements _$DragStateCopyWith<$Res> {
  __$DragStateCopyWithImpl(this._self, this._then);

  final _DragState _self;
  final $Res Function(_DragState) _then;

  /// Create a copy of DragState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? bubbleId = null,
    Object? bubbleConfig = null,
    Object? startPosition = null,
    Object? currentPosition = null,
    Object? touchOffset = null,
    Object? bubbleSize = null,
    Object? bubbleCenterOffset = null,
    Object? bubbleKey = null,
  }) {
    return _then(_DragState(
      bubbleId: null == bubbleId
          ? _self.bubbleId
          : bubbleId // ignore: cast_nullable_to_non_nullable
              as String,
      bubbleConfig: null == bubbleConfig
          ? _self.bubbleConfig
          : bubbleConfig // ignore: cast_nullable_to_non_nullable
              as BubbleConfigState,
      startPosition: null == startPosition
          ? _self.startPosition
          : startPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      currentPosition: null == currentPosition
          ? _self.currentPosition
          : currentPosition // ignore: cast_nullable_to_non_nullable
              as Offset,
      touchOffset: null == touchOffset
          ? _self.touchOffset
          : touchOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      bubbleSize: null == bubbleSize
          ? _self.bubbleSize
          : bubbleSize // ignore: cast_nullable_to_non_nullable
              as Size,
      bubbleCenterOffset: null == bubbleCenterOffset
          ? _self.bubbleCenterOffset
          : bubbleCenterOffset // ignore: cast_nullable_to_non_nullable
              as Offset,
      bubbleKey: null == bubbleKey
          ? _self.bubbleKey
          : bubbleKey // ignore: cast_nullable_to_non_nullable
              as GlobalKey,
    ));
  }

  /// Create a copy of DragState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $BubbleConfigStateCopyWith<$Res> get bubbleConfig {
    return $BubbleConfigStateCopyWith<$Res>(_self.bubbleConfig, (value) {
      return _then(_self.copyWith(bubbleConfig: value));
    });
  }
}

// dart format on
