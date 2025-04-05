// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reply_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReplyState implements DiagnosticableTreeMixin {
  List<CommentModel> get replies;
  bool get isLoading;
  String? get error;
  bool get hasMore;
  DocumentSnapshot? get lastDocument;

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReplyStateCopyWith<ReplyState> get copyWith =>
      _$ReplyStateCopyWithImpl<ReplyState>(this as ReplyState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ReplyState'))
      ..add(DiagnosticsProperty('replies', replies))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('lastDocument', lastDocument));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReplyState &&
            const DeepCollectionEquality().equals(other.replies, replies) &&
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
      const DeepCollectionEquality().hash(replies),
      isLoading,
      error,
      hasMore,
      lastDocument);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReplyState(replies: $replies, isLoading: $isLoading, error: $error, hasMore: $hasMore, lastDocument: $lastDocument)';
  }
}

/// @nodoc
abstract mixin class $ReplyStateCopyWith<$Res> {
  factory $ReplyStateCopyWith(
          ReplyState value, $Res Function(ReplyState) _then) =
      _$ReplyStateCopyWithImpl;
  @useResult
  $Res call(
      {List<CommentModel> replies,
      bool isLoading,
      String? error,
      bool hasMore,
      DocumentSnapshot? lastDocument});
}

/// @nodoc
class _$ReplyStateCopyWithImpl<$Res> implements $ReplyStateCopyWith<$Res> {
  _$ReplyStateCopyWithImpl(this._self, this._then);

  final ReplyState _self;
  final $Res Function(ReplyState) _then;

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
    return _then(_self.copyWith(
      replies: null == replies
          ? _self.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _self.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot?,
    ));
  }
}

/// @nodoc

class _ReplyState with DiagnosticableTreeMixin implements ReplyState {
  const _ReplyState(
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
  final DocumentSnapshot? lastDocument;

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReplyStateCopyWith<_ReplyState> get copyWith =>
      __$ReplyStateCopyWithImpl<_ReplyState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ReplyState'))
      ..add(DiagnosticsProperty('replies', replies))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('error', error))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('lastDocument', lastDocument));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReplyState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ReplyState(replies: $replies, isLoading: $isLoading, error: $error, hasMore: $hasMore, lastDocument: $lastDocument)';
  }
}

/// @nodoc
abstract mixin class _$ReplyStateCopyWith<$Res>
    implements $ReplyStateCopyWith<$Res> {
  factory _$ReplyStateCopyWith(
          _ReplyState value, $Res Function(_ReplyState) _then) =
      __$ReplyStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<CommentModel> replies,
      bool isLoading,
      String? error,
      bool hasMore,
      DocumentSnapshot? lastDocument});
}

/// @nodoc
class __$ReplyStateCopyWithImpl<$Res> implements _$ReplyStateCopyWith<$Res> {
  __$ReplyStateCopyWithImpl(this._self, this._then);

  final _ReplyState _self;
  final $Res Function(_ReplyState) _then;

  /// Create a copy of ReplyState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? replies = null,
    Object? isLoading = null,
    Object? error = freezed,
    Object? hasMore = null,
    Object? lastDocument = freezed,
  }) {
    return _then(_ReplyState(
      replies: null == replies
          ? _self._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _self.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot?,
    ));
  }
}

// dart format on
