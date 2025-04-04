// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reply_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$ReplyState {
  List<CommentModel> get replies => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  DocumentSnapshot<Object?>? get lastDocument =>
      throw _privateConstructorUsedError;

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReplyStateCopyWith<ReplyState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReplyStateCopyWith<$Res> {
  factory $ReplyStateCopyWith(
          ReplyState value, $Res Function(ReplyState) then) =
      _$ReplyStateCopyWithImpl<$Res, ReplyState>;
  @useResult
  $Res call(
      {List<CommentModel> replies,
      bool isLoading,
      String? error,
      bool hasMore,
      DocumentSnapshot<Object?>? lastDocument});
}

/// @nodoc
class _$ReplyStateCopyWithImpl<$Res, $Val extends ReplyState>
    implements $ReplyStateCopyWith<$Res> {
  _$ReplyStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? replies = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? hasMore = null,
    Object? lastDocument = freezed,
  }) {
    return _then(_value.copyWith(
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReplyStateImplCopyWith<$Res>
    implements $ReplyStateCopyWith<$Res> {
  factory _$$ReplyStateImplCopyWith(
          _$ReplyStateImpl value, $Res Function(_$ReplyStateImpl) then) =
      __$$ReplyStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CommentModel> replies,
      bool isLoading,
      String? error,
      bool hasMore,
      DocumentSnapshot<Object?>? lastDocument});
}

/// @nodoc
class __$$ReplyStateImplCopyWithImpl<$Res>
    extends _$ReplyStateCopyWithImpl<$Res, _$ReplyStateImpl>
    implements _$$ReplyStateImplCopyWith<$Res> {
  __$$ReplyStateImplCopyWithImpl(
      _$ReplyStateImpl _value, $Res Function(_$ReplyStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? replies = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? hasMore = null,
    Object? lastDocument = freezed,
  }) {
    return _then(_$ReplyStateImpl(
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
    ));
  }
}

/// @nodoc

class _$ReplyStateImpl implements _ReplyState {
  const _$ReplyStateImpl(
      {required final List<CommentModel> replies,
      required this.isLoading,
      this.error,
      this.hasMore = true,
      this.lastDocument})
      : _replies = replies;

  final List<CommentModel> _replies;
  @override
  List<CommentModel> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  final bool isLoading;
  @override
  final String? error;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final DocumentSnapshot<Object?>? lastDocument;

  @override
  String toString() {
    return 'ReplyState(replies: $replies, isLoading: $isLoading, error: $error, hasMore: $hasMore, lastDocument: $lastDocument)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReplyStateImpl &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.lastDocument, lastDocument) ||
                other.lastDocument == lastDocument));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_replies),
      isLoading,
      error,
      hasMore,
      lastDocument);

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReplyStateImplCopyWith<_$ReplyStateImpl> get copyWith =>
      __$$ReplyStateImplCopyWithImpl<_$ReplyStateImpl>(this, _$identity);
}

abstract class _ReplyState implements ReplyState {
  const factory _ReplyState(
      {required final List<CommentModel> replies,
      required final bool isLoading,
      final String? error,
      final bool hasMore,
      final DocumentSnapshot<Object?>? lastDocument}) = _$ReplyStateImpl;

  @override
  List<CommentModel> get replies;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  bool get hasMore;
  @override
  DocumentSnapshot<Object?>? get lastDocument;

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReplyStateImplCopyWith<_$ReplyStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
