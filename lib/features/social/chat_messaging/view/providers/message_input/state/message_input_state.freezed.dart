// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_input_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageInputState {
  String get text;
  bool get isTyping;
  bool get isSending;
  String? get replyToMessageId;
  String? get error;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageInputStateCopyWith<MessageInputState> get copyWith =>
      _$MessageInputStateCopyWithImpl<MessageInputState>(
          this as MessageInputState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageInputState &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isTyping, isTyping) ||
                other.isTyping == isTyping) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, text, isTyping, isSending, replyToMessageId, error);

  @override
  String toString() {
    return 'MessageInputState(text: $text, isTyping: $isTyping, isSending: $isSending, replyToMessageId: $replyToMessageId, error: $error)';
  }
}

/// @nodoc
abstract mixin class $MessageInputStateCopyWith<$Res> {
  factory $MessageInputStateCopyWith(
          MessageInputState value, $Res Function(MessageInputState) _then) =
      _$MessageInputStateCopyWithImpl;
  @useResult
  $Res call(
      {String text,
      bool isTyping,
      bool isSending,
      String? replyToMessageId,
      String? error});
}

/// @nodoc
class _$MessageInputStateCopyWithImpl<$Res>
    implements $MessageInputStateCopyWith<$Res> {
  _$MessageInputStateCopyWithImpl(this._self, this._then);

  final MessageInputState _self;
  final $Res Function(MessageInputState) _then;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? isTyping = null,
    Object? isSending = null,
    Object? replyToMessageId = freezed,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isTyping: null == isTyping
          ? _self.isTyping
          : isTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _self.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MessageInputState].
extension MessageInputStatePatterns on MessageInputState {
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
    TResult Function(_MessageInputState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
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
    TResult Function(_MessageInputState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState():
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
    TResult? Function(_MessageInputState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
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
    TResult Function(String text, bool isTyping, bool isSending,
            String? replyToMessageId, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
        return $default(_that.text, _that.isTyping, _that.isSending,
            _that.replyToMessageId, _that.error);
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
    TResult Function(String text, bool isTyping, bool isSending,
            String? replyToMessageId, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState():
        return $default(_that.text, _that.isTyping, _that.isSending,
            _that.replyToMessageId, _that.error);
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
    TResult? Function(String text, bool isTyping, bool isSending,
            String? replyToMessageId, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
        return $default(_that.text, _that.isTyping, _that.isSending,
            _that.replyToMessageId, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MessageInputState implements MessageInputState {
  const _MessageInputState(
      {this.text = '',
      this.isTyping = false,
      this.isSending = false,
      this.replyToMessageId,
      this.error});

  @override
  @JsonKey()
  final String text;
  @override
  @JsonKey()
  final bool isTyping;
  @override
  @JsonKey()
  final bool isSending;
  @override
  final String? replyToMessageId;
  @override
  final String? error;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageInputStateCopyWith<_MessageInputState> get copyWith =>
      __$MessageInputStateCopyWithImpl<_MessageInputState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MessageInputState &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isTyping, isTyping) ||
                other.isTyping == isTyping) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, text, isTyping, isSending, replyToMessageId, error);

  @override
  String toString() {
    return 'MessageInputState(text: $text, isTyping: $isTyping, isSending: $isSending, replyToMessageId: $replyToMessageId, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$MessageInputStateCopyWith<$Res>
    implements $MessageInputStateCopyWith<$Res> {
  factory _$MessageInputStateCopyWith(
          _MessageInputState value, $Res Function(_MessageInputState) _then) =
      __$MessageInputStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String text,
      bool isTyping,
      bool isSending,
      String? replyToMessageId,
      String? error});
}

/// @nodoc
class __$MessageInputStateCopyWithImpl<$Res>
    implements _$MessageInputStateCopyWith<$Res> {
  __$MessageInputStateCopyWithImpl(this._self, this._then);

  final _MessageInputState _self;
  final $Res Function(_MessageInputState) _then;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? isTyping = null,
    Object? isSending = null,
    Object? replyToMessageId = freezed,
    Object? error = freezed,
  }) {
    return _then(_MessageInputState(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isTyping: null == isTyping
          ? _self.isTyping
          : isTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _self.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
