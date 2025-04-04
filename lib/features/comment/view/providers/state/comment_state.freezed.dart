// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$CommentState {
  List<CommentModel> get comments => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  String get sortBy => throw _privateConstructorUsedError;
  DocumentSnapshot<Object?>? get lastDocument =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentStateCopyWith<CommentState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentStateCopyWith<$Res> {
  factory $CommentStateCopyWith(
          CommentState value, $Res Function(CommentState) then) =
      _$CommentStateCopyWithImpl<$Res, CommentState>;
  @useResult
  $Res call(
      {List<CommentModel> comments,
      bool isLoading,
      bool hasMore,
      String sortBy,
      DocumentSnapshot<Object?>? lastDocument,
      String? error});
}

/// @nodoc
class _$CommentStateCopyWithImpl<$Res, $Val extends CommentState>
    implements $CommentStateCopyWith<$Res> {
  _$CommentStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comments = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? sortBy = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      comments: null == comments
          ? _value.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentStateImplCopyWith<$Res>
    implements $CommentStateCopyWith<$Res> {
  factory _$$CommentStateImplCopyWith(
          _$CommentStateImpl value, $Res Function(_$CommentStateImpl) then) =
      __$$CommentStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<CommentModel> comments,
      bool isLoading,
      bool hasMore,
      String sortBy,
      DocumentSnapshot<Object?>? lastDocument,
      String? error});
}

/// @nodoc
class __$$CommentStateImplCopyWithImpl<$Res>
    extends _$CommentStateCopyWithImpl<$Res, _$CommentStateImpl>
    implements _$$CommentStateImplCopyWith<$Res> {
  __$$CommentStateImplCopyWithImpl(
      _$CommentStateImpl _value, $Res Function(_$CommentStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? comments = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? sortBy = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_$CommentStateImpl(
      comments: null == comments
          ? _value._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _value.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CommentStateImpl implements _CommentState {
  const _$CommentStateImpl(
      {required final List<CommentModel> comments,
      this.isLoading = false,
      this.hasMore = true,
      this.sortBy = 'hot',
      this.lastDocument,
      this.error})
      : _comments = comments;

  final List<CommentModel> _comments;
  @override
  List<CommentModel> get comments {
    if (_comments is EqualUnmodifiableListView) return _comments;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_comments);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final String sortBy;
  @override
  final DocumentSnapshot<Object?>? lastDocument;
  @override
  final String? error;

  @override
  String toString() {
    return 'CommentState(comments: $comments, isLoading: $isLoading, hasMore: $hasMore, sortBy: $sortBy, lastDocument: $lastDocument, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentStateImpl &&
            const DeepCollectionEquality().equals(other._comments, _comments) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.sortBy, sortBy) || other.sortBy == sortBy) &&
            (identical(other.lastDocument, lastDocument) ||
                other.lastDocument == lastDocument) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_comments),
      isLoading,
      hasMore,
      sortBy,
      lastDocument,
      error);

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentStateImplCopyWith<_$CommentStateImpl> get copyWith =>
      __$$CommentStateImplCopyWithImpl<_$CommentStateImpl>(this, _$identity);
}

abstract class _CommentState implements CommentState {
  const factory _CommentState(
      {required final List<CommentModel> comments,
      final bool isLoading,
      final bool hasMore,
      final String sortBy,
      final DocumentSnapshot<Object?>? lastDocument,
      final String? error}) = _$CommentStateImpl;

  @override
  List<CommentModel> get comments;
  @override
  bool get isLoading;
  @override
  bool get hasMore;
  @override
  String get sortBy;
  @override
  DocumentSnapshot<Object?>? get lastDocument;
  @override
  String? get error;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentStateImplCopyWith<_$CommentStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommentThreadState {
  CommentModel get parentComment => throw _privateConstructorUsedError;
  List<CommentModel> get replies => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  bool get hasMore => throw _privateConstructorUsedError;
  DocumentSnapshot<Object?>? get lastDocument =>
      throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentThreadStateCopyWith<CommentThreadState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentThreadStateCopyWith<$Res> {
  factory $CommentThreadStateCopyWith(
          CommentThreadState value, $Res Function(CommentThreadState) then) =
      _$CommentThreadStateCopyWithImpl<$Res, CommentThreadState>;
  @useResult
  $Res call(
      {CommentModel parentComment,
      List<CommentModel> replies,
      bool isLoading,
      bool hasMore,
      DocumentSnapshot<Object?>? lastDocument,
      String? error});

  $CommentModelCopyWith<$Res> get parentComment;
}

/// @nodoc
class _$CommentThreadStateCopyWithImpl<$Res, $Val extends CommentThreadState>
    implements $CommentThreadStateCopyWith<$Res> {
  _$CommentThreadStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentComment = null,
    Object? replies = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      parentComment: null == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as CommentModel,
      replies: null == replies
          ? _value.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommentModelCopyWith<$Res> get parentComment {
    return $CommentModelCopyWith<$Res>(_value.parentComment, (value) {
      return _then(_value.copyWith(parentComment: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CommentThreadStateImplCopyWith<$Res>
    implements $CommentThreadStateCopyWith<$Res> {
  factory _$$CommentThreadStateImplCopyWith(_$CommentThreadStateImpl value,
          $Res Function(_$CommentThreadStateImpl) then) =
      __$$CommentThreadStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {CommentModel parentComment,
      List<CommentModel> replies,
      bool isLoading,
      bool hasMore,
      DocumentSnapshot<Object?>? lastDocument,
      String? error});

  @override
  $CommentModelCopyWith<$Res> get parentComment;
}

/// @nodoc
class __$$CommentThreadStateImplCopyWithImpl<$Res>
    extends _$CommentThreadStateCopyWithImpl<$Res, _$CommentThreadStateImpl>
    implements _$$CommentThreadStateImplCopyWith<$Res> {
  __$$CommentThreadStateImplCopyWithImpl(_$CommentThreadStateImpl _value,
      $Res Function(_$CommentThreadStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? parentComment = null,
    Object? replies = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_$CommentThreadStateImpl(
      parentComment: null == parentComment
          ? _value.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as CommentModel,
      replies: null == replies
          ? _value._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _value.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$CommentThreadStateImpl implements _CommentThreadState {
  const _$CommentThreadStateImpl(
      {required this.parentComment,
      required final List<CommentModel> replies,
      this.isLoading = false,
      this.hasMore = true,
      this.lastDocument,
      this.error})
      : _replies = replies;

  @override
  final CommentModel parentComment;
  final List<CommentModel> _replies;
  @override
  List<CommentModel> get replies {
    if (_replies is EqualUnmodifiableListView) return _replies;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_replies);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  final DocumentSnapshot<Object?>? lastDocument;
  @override
  final String? error;

  @override
  String toString() {
    return 'CommentThreadState(parentComment: $parentComment, replies: $replies, isLoading: $isLoading, hasMore: $hasMore, lastDocument: $lastDocument, error: $error)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentThreadStateImpl &&
            (identical(other.parentComment, parentComment) ||
                other.parentComment == parentComment) &&
            const DeepCollectionEquality().equals(other._replies, _replies) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.lastDocument, lastDocument) ||
                other.lastDocument == lastDocument) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      parentComment,
      const DeepCollectionEquality().hash(_replies),
      isLoading,
      hasMore,
      lastDocument,
      error);

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentThreadStateImplCopyWith<_$CommentThreadStateImpl> get copyWith =>
      __$$CommentThreadStateImplCopyWithImpl<_$CommentThreadStateImpl>(
          this, _$identity);
}

abstract class _CommentThreadState implements CommentThreadState {
  const factory _CommentThreadState(
      {required final CommentModel parentComment,
      required final List<CommentModel> replies,
      final bool isLoading,
      final bool hasMore,
      final DocumentSnapshot<Object?>? lastDocument,
      final String? error}) = _$CommentThreadStateImpl;

  @override
  CommentModel get parentComment;
  @override
  List<CommentModel> get replies;
  @override
  bool get isLoading;
  @override
  bool get hasMore;
  @override
  DocumentSnapshot<Object?>? get lastDocument;
  @override
  String? get error;

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentThreadStateImplCopyWith<_$CommentThreadStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ExpandedCommentsState {
  Set<String> get expandedCommentIds => throw _privateConstructorUsedError;

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ExpandedCommentsStateCopyWith<ExpandedCommentsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExpandedCommentsStateCopyWith<$Res> {
  factory $ExpandedCommentsStateCopyWith(ExpandedCommentsState value,
          $Res Function(ExpandedCommentsState) then) =
      _$ExpandedCommentsStateCopyWithImpl<$Res, ExpandedCommentsState>;
  @useResult
  $Res call({Set<String> expandedCommentIds});
}

/// @nodoc
class _$ExpandedCommentsStateCopyWithImpl<$Res,
        $Val extends ExpandedCommentsState>
    implements $ExpandedCommentsStateCopyWith<$Res> {
  _$ExpandedCommentsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expandedCommentIds = null,
  }) {
    return _then(_value.copyWith(
      expandedCommentIds: null == expandedCommentIds
          ? _value.expandedCommentIds
          : expandedCommentIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExpandedCommentsStateImplCopyWith<$Res>
    implements $ExpandedCommentsStateCopyWith<$Res> {
  factory _$$ExpandedCommentsStateImplCopyWith(
          _$ExpandedCommentsStateImpl value,
          $Res Function(_$ExpandedCommentsStateImpl) then) =
      __$$ExpandedCommentsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({Set<String> expandedCommentIds});
}

/// @nodoc
class __$$ExpandedCommentsStateImplCopyWithImpl<$Res>
    extends _$ExpandedCommentsStateCopyWithImpl<$Res,
        _$ExpandedCommentsStateImpl>
    implements _$$ExpandedCommentsStateImplCopyWith<$Res> {
  __$$ExpandedCommentsStateImplCopyWithImpl(_$ExpandedCommentsStateImpl _value,
      $Res Function(_$ExpandedCommentsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expandedCommentIds = null,
  }) {
    return _then(_$ExpandedCommentsStateImpl(
      expandedCommentIds: null == expandedCommentIds
          ? _value._expandedCommentIds
          : expandedCommentIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _$ExpandedCommentsStateImpl implements _ExpandedCommentsState {
  const _$ExpandedCommentsStateImpl(
      {required final Set<String> expandedCommentIds})
      : _expandedCommentIds = expandedCommentIds;

  final Set<String> _expandedCommentIds;
  @override
  Set<String> get expandedCommentIds {
    if (_expandedCommentIds is EqualUnmodifiableSetView)
      return _expandedCommentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_expandedCommentIds);
  }

  @override
  String toString() {
    return 'ExpandedCommentsState(expandedCommentIds: $expandedCommentIds)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExpandedCommentsStateImpl &&
            const DeepCollectionEquality()
                .equals(other._expandedCommentIds, _expandedCommentIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_expandedCommentIds));

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ExpandedCommentsStateImplCopyWith<_$ExpandedCommentsStateImpl>
      get copyWith => __$$ExpandedCommentsStateImplCopyWithImpl<
          _$ExpandedCommentsStateImpl>(this, _$identity);
}

abstract class _ExpandedCommentsState implements ExpandedCommentsState {
  const factory _ExpandedCommentsState(
          {required final Set<String> expandedCommentIds}) =
      _$ExpandedCommentsStateImpl;

  @override
  Set<String> get expandedCommentIds;

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ExpandedCommentsStateImplCopyWith<_$ExpandedCommentsStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$CommentInteractionState {
  bool get isLiked => throw _privateConstructorUsedError;
  bool get isDisliked => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get dislikeCount => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentInteractionStateCopyWith<CommentInteractionState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentInteractionStateCopyWith<$Res> {
  factory $CommentInteractionStateCopyWith(CommentInteractionState value,
          $Res Function(CommentInteractionState) then) =
      _$CommentInteractionStateCopyWithImpl<$Res, CommentInteractionState>;
  @useResult
  $Res call(
      {bool isLiked,
      bool isDisliked,
      int likeCount,
      int dislikeCount,
      bool isLoading});
}

/// @nodoc
class _$CommentInteractionStateCopyWithImpl<$Res,
        $Val extends CommentInteractionState>
    implements $CommentInteractionStateCopyWith<$Res> {
  _$CommentInteractionStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? isLoading = null,
  }) {
    return _then(_value.copyWith(
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _value.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _value.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentInteractionStateImplCopyWith<$Res>
    implements $CommentInteractionStateCopyWith<$Res> {
  factory _$$CommentInteractionStateImplCopyWith(
          _$CommentInteractionStateImpl value,
          $Res Function(_$CommentInteractionStateImpl) then) =
      __$$CommentInteractionStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool isLiked,
      bool isDisliked,
      int likeCount,
      int dislikeCount,
      bool isLoading});
}

/// @nodoc
class __$$CommentInteractionStateImplCopyWithImpl<$Res>
    extends _$CommentInteractionStateCopyWithImpl<$Res,
        _$CommentInteractionStateImpl>
    implements _$$CommentInteractionStateImplCopyWith<$Res> {
  __$$CommentInteractionStateImplCopyWithImpl(
      _$CommentInteractionStateImpl _value,
      $Res Function(_$CommentInteractionStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? isLoading = null,
  }) {
    return _then(_$CommentInteractionStateImpl(
      isLiked: null == isLiked
          ? _value.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _value.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _value.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _$CommentInteractionStateImpl implements _CommentInteractionState {
  const _$CommentInteractionStateImpl(
      {this.isLiked = false,
      this.isDisliked = false,
      this.likeCount = 0,
      this.dislikeCount = 0,
      this.isLoading = false});

  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isDisliked;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int dislikeCount;
  @override
  @JsonKey()
  final bool isLoading;

  @override
  String toString() {
    return 'CommentInteractionState(isLiked: $isLiked, isDisliked: $isDisliked, likeCount: $likeCount, dislikeCount: $dislikeCount, isLoading: $isLoading)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentInteractionStateImpl &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.dislikeCount, dislikeCount) ||
                other.dislikeCount == dislikeCount) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, isLiked, isDisliked, likeCount, dislikeCount, isLoading);

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentInteractionStateImplCopyWith<_$CommentInteractionStateImpl>
      get copyWith => __$$CommentInteractionStateImplCopyWithImpl<
          _$CommentInteractionStateImpl>(this, _$identity);
}

abstract class _CommentInteractionState implements CommentInteractionState {
  const factory _CommentInteractionState(
      {final bool isLiked,
      final bool isDisliked,
      final int likeCount,
      final int dislikeCount,
      final bool isLoading}) = _$CommentInteractionStateImpl;

  @override
  bool get isLiked;
  @override
  bool get isDisliked;
  @override
  int get likeCount;
  @override
  int get dislikeCount;
  @override
  bool get isLoading;

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentInteractionStateImplCopyWith<_$CommentInteractionStateImpl>
      get copyWith => throw _privateConstructorUsedError;
}
