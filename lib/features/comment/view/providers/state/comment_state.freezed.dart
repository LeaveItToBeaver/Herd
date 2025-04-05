// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentState implements DiagnosticableTreeMixin {
  List<CommentModel> get comments;
  bool get isLoading;
  bool get hasMore;
  String get sortBy;
  DocumentSnapshot? get lastDocument;
  String? get error;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommentStateCopyWith<CommentState> get copyWith =>
      _$CommentStateCopyWithImpl<CommentState>(
          this as CommentState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentState'))
      ..add(DiagnosticsProperty('comments', comments))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('sortBy', sortBy))
      ..add(DiagnosticsProperty('lastDocument', lastDocument))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommentState &&
            const DeepCollectionEquality().equals(other.comments, comments) &&
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
      const DeepCollectionEquality().hash(comments),
      isLoading,
      hasMore,
      sortBy,
      lastDocument,
      error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentState(comments: $comments, isLoading: $isLoading, hasMore: $hasMore, sortBy: $sortBy, lastDocument: $lastDocument, error: $error)';
  }
}

/// @nodoc
abstract mixin class $CommentStateCopyWith<$Res> {
  factory $CommentStateCopyWith(
          CommentState value, $Res Function(CommentState) _then) =
      _$CommentStateCopyWithImpl;
  @useResult
  $Res call(
      {List<CommentModel> comments,
      bool isLoading,
      bool hasMore,
      String sortBy,
      DocumentSnapshot? lastDocument,
      String? error});
}

/// @nodoc
class _$CommentStateCopyWithImpl<$Res> implements $CommentStateCopyWith<$Res> {
  _$CommentStateCopyWithImpl(this._self, this._then);

  final CommentState _self;
  final $Res Function(CommentState) _then;

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
    return _then(_self.copyWith(
      comments: null == comments
          ? _self.comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      lastDocument: freezed == lastDocument
          ? _self.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _CommentState with DiagnosticableTreeMixin implements CommentState {
  const _CommentState(
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
  final DocumentSnapshot? lastDocument;
  @override
  final String? error;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommentStateCopyWith<_CommentState> get copyWith =>
      __$CommentStateCopyWithImpl<_CommentState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentState'))
      ..add(DiagnosticsProperty('comments', comments))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('sortBy', sortBy))
      ..add(DiagnosticsProperty('lastDocument', lastDocument))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommentState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentState(comments: $comments, isLoading: $isLoading, hasMore: $hasMore, sortBy: $sortBy, lastDocument: $lastDocument, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$CommentStateCopyWith<$Res>
    implements $CommentStateCopyWith<$Res> {
  factory _$CommentStateCopyWith(
          _CommentState value, $Res Function(_CommentState) _then) =
      __$CommentStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<CommentModel> comments,
      bool isLoading,
      bool hasMore,
      String sortBy,
      DocumentSnapshot? lastDocument,
      String? error});
}

/// @nodoc
class __$CommentStateCopyWithImpl<$Res>
    implements _$CommentStateCopyWith<$Res> {
  __$CommentStateCopyWithImpl(this._self, this._then);

  final _CommentState _self;
  final $Res Function(_CommentState) _then;

  /// Create a copy of CommentState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? comments = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? sortBy = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_CommentState(
      comments: null == comments
          ? _self._comments
          : comments // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      sortBy: null == sortBy
          ? _self.sortBy
          : sortBy // ignore: cast_nullable_to_non_nullable
              as String,
      lastDocument: freezed == lastDocument
          ? _self.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
mixin _$CommentThreadState implements DiagnosticableTreeMixin {
  CommentModel get parentComment;
  List<CommentModel> get replies;
  bool get isLoading;
  bool get hasMore;
  DocumentSnapshot? get lastDocument;
  String? get error;

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommentThreadStateCopyWith<CommentThreadState> get copyWith =>
      _$CommentThreadStateCopyWithImpl<CommentThreadState>(
          this as CommentThreadState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentThreadState'))
      ..add(DiagnosticsProperty('parentComment', parentComment))
      ..add(DiagnosticsProperty('replies', replies))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('lastDocument', lastDocument))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommentThreadState &&
            (identical(other.parentComment, parentComment) ||
                other.parentComment == parentComment) &&
            const DeepCollectionEquality().equals(other.replies, replies) &&
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
      const DeepCollectionEquality().hash(replies),
      isLoading,
      hasMore,
      lastDocument,
      error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentThreadState(parentComment: $parentComment, replies: $replies, isLoading: $isLoading, hasMore: $hasMore, lastDocument: $lastDocument, error: $error)';
  }
}

/// @nodoc
abstract mixin class $CommentThreadStateCopyWith<$Res> {
  factory $CommentThreadStateCopyWith(
          CommentThreadState value, $Res Function(CommentThreadState) _then) =
      _$CommentThreadStateCopyWithImpl;
  @useResult
  $Res call(
      {CommentModel parentComment,
      List<CommentModel> replies,
      bool isLoading,
      bool hasMore,
      DocumentSnapshot? lastDocument,
      String? error});

  $CommentModelCopyWith<$Res> get parentComment;
}

/// @nodoc
class _$CommentThreadStateCopyWithImpl<$Res>
    implements $CommentThreadStateCopyWith<$Res> {
  _$CommentThreadStateCopyWithImpl(this._self, this._then);

  final CommentThreadState _self;
  final $Res Function(CommentThreadState) _then;

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
    return _then(_self.copyWith(
      parentComment: null == parentComment
          ? _self.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as CommentModel,
      replies: null == replies
          ? _self.replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _self.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommentModelCopyWith<$Res> get parentComment {
    return $CommentModelCopyWith<$Res>(_self.parentComment, (value) {
      return _then(_self.copyWith(parentComment: value));
    });
  }
}

/// @nodoc

class _CommentThreadState
    with DiagnosticableTreeMixin
    implements CommentThreadState {
  const _CommentThreadState(
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
  final DocumentSnapshot? lastDocument;
  @override
  final String? error;

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommentThreadStateCopyWith<_CommentThreadState> get copyWith =>
      __$CommentThreadStateCopyWithImpl<_CommentThreadState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentThreadState'))
      ..add(DiagnosticsProperty('parentComment', parentComment))
      ..add(DiagnosticsProperty('replies', replies))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('lastDocument', lastDocument))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommentThreadState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentThreadState(parentComment: $parentComment, replies: $replies, isLoading: $isLoading, hasMore: $hasMore, lastDocument: $lastDocument, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$CommentThreadStateCopyWith<$Res>
    implements $CommentThreadStateCopyWith<$Res> {
  factory _$CommentThreadStateCopyWith(
          _CommentThreadState value, $Res Function(_CommentThreadState) _then) =
      __$CommentThreadStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {CommentModel parentComment,
      List<CommentModel> replies,
      bool isLoading,
      bool hasMore,
      DocumentSnapshot? lastDocument,
      String? error});

  @override
  $CommentModelCopyWith<$Res> get parentComment;
}

/// @nodoc
class __$CommentThreadStateCopyWithImpl<$Res>
    implements _$CommentThreadStateCopyWith<$Res> {
  __$CommentThreadStateCopyWithImpl(this._self, this._then);

  final _CommentThreadState _self;
  final $Res Function(_CommentThreadState) _then;

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? parentComment = null,
    Object? replies = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_CommentThreadState(
      parentComment: null == parentComment
          ? _self.parentComment
          : parentComment // ignore: cast_nullable_to_non_nullable
              as CommentModel,
      replies: null == replies
          ? _self._replies
          : replies // ignore: cast_nullable_to_non_nullable
              as List<CommentModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      lastDocument: freezed == lastDocument
          ? _self.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of CommentThreadState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $CommentModelCopyWith<$Res> get parentComment {
    return $CommentModelCopyWith<$Res>(_self.parentComment, (value) {
      return _then(_self.copyWith(parentComment: value));
    });
  }
}

/// @nodoc
mixin _$ExpandedCommentsState implements DiagnosticableTreeMixin {
  Set<String> get expandedCommentIds;

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ExpandedCommentsStateCopyWith<ExpandedCommentsState> get copyWith =>
      _$ExpandedCommentsStateCopyWithImpl<ExpandedCommentsState>(
          this as ExpandedCommentsState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ExpandedCommentsState'))
      ..add(DiagnosticsProperty('expandedCommentIds', expandedCommentIds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ExpandedCommentsState &&
            const DeepCollectionEquality()
                .equals(other.expandedCommentIds, expandedCommentIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(expandedCommentIds));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ExpandedCommentsState(expandedCommentIds: $expandedCommentIds)';
  }
}

/// @nodoc
abstract mixin class $ExpandedCommentsStateCopyWith<$Res> {
  factory $ExpandedCommentsStateCopyWith(ExpandedCommentsState value,
          $Res Function(ExpandedCommentsState) _then) =
      _$ExpandedCommentsStateCopyWithImpl;
  @useResult
  $Res call({Set<String> expandedCommentIds});
}

/// @nodoc
class _$ExpandedCommentsStateCopyWithImpl<$Res>
    implements $ExpandedCommentsStateCopyWith<$Res> {
  _$ExpandedCommentsStateCopyWithImpl(this._self, this._then);

  final ExpandedCommentsState _self;
  final $Res Function(ExpandedCommentsState) _then;

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? expandedCommentIds = null,
  }) {
    return _then(_self.copyWith(
      expandedCommentIds: null == expandedCommentIds
          ? _self.expandedCommentIds
          : expandedCommentIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc

class _ExpandedCommentsState
    with DiagnosticableTreeMixin
    implements ExpandedCommentsState {
  const _ExpandedCommentsState({required final Set<String> expandedCommentIds})
      : _expandedCommentIds = expandedCommentIds;

  final Set<String> _expandedCommentIds;
  @override
  Set<String> get expandedCommentIds {
    if (_expandedCommentIds is EqualUnmodifiableSetView)
      return _expandedCommentIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableSetView(_expandedCommentIds);
  }

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ExpandedCommentsStateCopyWith<_ExpandedCommentsState> get copyWith =>
      __$ExpandedCommentsStateCopyWithImpl<_ExpandedCommentsState>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ExpandedCommentsState'))
      ..add(DiagnosticsProperty('expandedCommentIds', expandedCommentIds));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ExpandedCommentsState &&
            const DeepCollectionEquality()
                .equals(other._expandedCommentIds, _expandedCommentIds));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(_expandedCommentIds));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ExpandedCommentsState(expandedCommentIds: $expandedCommentIds)';
  }
}

/// @nodoc
abstract mixin class _$ExpandedCommentsStateCopyWith<$Res>
    implements $ExpandedCommentsStateCopyWith<$Res> {
  factory _$ExpandedCommentsStateCopyWith(_ExpandedCommentsState value,
          $Res Function(_ExpandedCommentsState) _then) =
      __$ExpandedCommentsStateCopyWithImpl;
  @override
  @useResult
  $Res call({Set<String> expandedCommentIds});
}

/// @nodoc
class __$ExpandedCommentsStateCopyWithImpl<$Res>
    implements _$ExpandedCommentsStateCopyWith<$Res> {
  __$ExpandedCommentsStateCopyWithImpl(this._self, this._then);

  final _ExpandedCommentsState _self;
  final $Res Function(_ExpandedCommentsState) _then;

  /// Create a copy of ExpandedCommentsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? expandedCommentIds = null,
  }) {
    return _then(_ExpandedCommentsState(
      expandedCommentIds: null == expandedCommentIds
          ? _self._expandedCommentIds
          : expandedCommentIds // ignore: cast_nullable_to_non_nullable
              as Set<String>,
    ));
  }
}

/// @nodoc
mixin _$CommentInteractionState implements DiagnosticableTreeMixin {
  bool get isLiked;
  bool get isDisliked;
  int get likeCount;
  int get dislikeCount;
  bool get isLoading;

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommentInteractionStateCopyWith<CommentInteractionState> get copyWith =>
      _$CommentInteractionStateCopyWithImpl<CommentInteractionState>(
          this as CommentInteractionState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentInteractionState'))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('isLoading', isLoading));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommentInteractionState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentInteractionState(isLiked: $isLiked, isDisliked: $isDisliked, likeCount: $likeCount, dislikeCount: $dislikeCount, isLoading: $isLoading)';
  }
}

/// @nodoc
abstract mixin class $CommentInteractionStateCopyWith<$Res> {
  factory $CommentInteractionStateCopyWith(CommentInteractionState value,
          $Res Function(CommentInteractionState) _then) =
      _$CommentInteractionStateCopyWithImpl;
  @useResult
  $Res call(
      {bool isLiked,
      bool isDisliked,
      int likeCount,
      int dislikeCount,
      bool isLoading});
}

/// @nodoc
class _$CommentInteractionStateCopyWithImpl<$Res>
    implements $CommentInteractionStateCopyWith<$Res> {
  _$CommentInteractionStateCopyWithImpl(this._self, this._then);

  final CommentInteractionState _self;
  final $Res Function(CommentInteractionState) _then;

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
    return _then(_self.copyWith(
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      likeCount: null == likeCount
          ? _self.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _self.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _CommentInteractionState
    with DiagnosticableTreeMixin
    implements CommentInteractionState {
  const _CommentInteractionState(
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

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommentInteractionStateCopyWith<_CommentInteractionState> get copyWith =>
      __$CommentInteractionStateCopyWithImpl<_CommentInteractionState>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentInteractionState'))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('isLoading', isLoading));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommentInteractionState &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentInteractionState(isLiked: $isLiked, isDisliked: $isDisliked, likeCount: $likeCount, dislikeCount: $dislikeCount, isLoading: $isLoading)';
  }
}

/// @nodoc
abstract mixin class _$CommentInteractionStateCopyWith<$Res>
    implements $CommentInteractionStateCopyWith<$Res> {
  factory _$CommentInteractionStateCopyWith(_CommentInteractionState value,
          $Res Function(_CommentInteractionState) _then) =
      __$CommentInteractionStateCopyWithImpl;
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
class __$CommentInteractionStateCopyWithImpl<$Res>
    implements _$CommentInteractionStateCopyWith<$Res> {
  __$CommentInteractionStateCopyWithImpl(this._self, this._then);

  final _CommentInteractionState _self;
  final $Res Function(_CommentInteractionState) _then;

  /// Create a copy of CommentInteractionState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? isLoading = null,
  }) {
    return _then(_CommentInteractionState(
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      likeCount: null == likeCount
          ? _self.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _self.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
