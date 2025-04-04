// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

CommentModel _$CommentModelFromJson(Map<String, dynamic> json) {
  return _CommentModel.fromJson(json);
}

/// @nodoc
mixin _$CommentModel {
  String get id => throw _privateConstructorUsedError;
  String get postId => throw _privateConstructorUsedError;
  String get authorId => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  DateTime get timestamp => throw _privateConstructorUsedError;
  String? get parentId => throw _privateConstructorUsedError;
  String get path => throw _privateConstructorUsedError;
  int get depth => throw _privateConstructorUsedError;
  String? get authorUsername => throw _privateConstructorUsedError;
  String? get authorProfileImage => throw _privateConstructorUsedError;
  bool get isAltPost => throw _privateConstructorUsedError;
  String? get mediaUrl => throw _privateConstructorUsedError;
  int get likeCount => throw _privateConstructorUsedError;
  int get dislikeCount => throw _privateConstructorUsedError;
  int get replyCount => throw _privateConstructorUsedError;
  double? get hotnessScore => throw _privateConstructorUsedError;

  /// Serializes this CommentModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CommentModelCopyWith<CommentModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CommentModelCopyWith<$Res> {
  factory $CommentModelCopyWith(
          CommentModel value, $Res Function(CommentModel) then) =
      _$CommentModelCopyWithImpl<$Res, CommentModel>;
  @useResult
  $Res call(
      {String id,
      String postId,
      String authorId,
      String content,
      DateTime timestamp,
      String? parentId,
      String path,
      int depth,
      String? authorUsername,
      String? authorProfileImage,
      bool isAltPost,
      String? mediaUrl,
      int likeCount,
      int dislikeCount,
      int replyCount,
      double? hotnessScore});
}

/// @nodoc
class _$CommentModelCopyWithImpl<$Res, $Val extends CommentModel>
    implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? authorId = null,
    Object? content = null,
    Object? timestamp = null,
    Object? parentId = freezed,
    Object? path = null,
    Object? depth = null,
    Object? authorUsername = freezed,
    Object? authorProfileImage = freezed,
    Object? isAltPost = null,
    Object? mediaUrl = freezed,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? replyCount = null,
    Object? hotnessScore = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      depth: null == depth
          ? _value.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      authorUsername: freezed == authorUsername
          ? _value.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileImage: freezed == authorProfileImage
          ? _value.authorProfileImage
          : authorProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isAltPost: null == isAltPost
          ? _value.isAltPost
          : isAltPost // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _value.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hotnessScore: freezed == hotnessScore
          ? _value.hotnessScore
          : hotnessScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CommentModelImplCopyWith<$Res>
    implements $CommentModelCopyWith<$Res> {
  factory _$$CommentModelImplCopyWith(
          _$CommentModelImpl value, $Res Function(_$CommentModelImpl) then) =
      __$$CommentModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String postId,
      String authorId,
      String content,
      DateTime timestamp,
      String? parentId,
      String path,
      int depth,
      String? authorUsername,
      String? authorProfileImage,
      bool isAltPost,
      String? mediaUrl,
      int likeCount,
      int dislikeCount,
      int replyCount,
      double? hotnessScore});
}

/// @nodoc
class __$$CommentModelImplCopyWithImpl<$Res>
    extends _$CommentModelCopyWithImpl<$Res, _$CommentModelImpl>
    implements _$$CommentModelImplCopyWith<$Res> {
  __$$CommentModelImplCopyWithImpl(
      _$CommentModelImpl _value, $Res Function(_$CommentModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? postId = null,
    Object? authorId = null,
    Object? content = null,
    Object? timestamp = null,
    Object? parentId = freezed,
    Object? path = null,
    Object? depth = null,
    Object? authorUsername = freezed,
    Object? authorProfileImage = freezed,
    Object? isAltPost = null,
    Object? mediaUrl = freezed,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? replyCount = null,
    Object? hotnessScore = freezed,
  }) {
    return _then(_$CommentModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _value.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _value.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parentId: freezed == parentId
          ? _value.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      path: null == path
          ? _value.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      depth: null == depth
          ? _value.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      authorUsername: freezed == authorUsername
          ? _value.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileImage: freezed == authorProfileImage
          ? _value.authorProfileImage
          : authorProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isAltPost: null == isAltPost
          ? _value.isAltPost
          : isAltPost // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaUrl: freezed == mediaUrl
          ? _value.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _value.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _value.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _value.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hotnessScore: freezed == hotnessScore
          ? _value.hotnessScore
          : hotnessScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CommentModelImpl extends _CommentModel {
  const _$CommentModelImpl(
      {required this.id,
      required this.postId,
      required this.authorId,
      required this.content,
      required this.timestamp,
      this.parentId,
      required this.path,
      this.depth = 0,
      this.authorUsername,
      this.authorProfileImage,
      this.isAltPost = false,
      this.mediaUrl,
      this.likeCount = 0,
      this.dislikeCount = 0,
      this.replyCount = 0,
      this.hotnessScore})
      : super._();

  factory _$CommentModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$CommentModelImplFromJson(json);

  @override
  final String id;
  @override
  final String postId;
  @override
  final String authorId;
  @override
  final String content;
  @override
  final DateTime timestamp;
  @override
  final String? parentId;
  @override
  final String path;
  @override
  @JsonKey()
  final int depth;
  @override
  final String? authorUsername;
  @override
  final String? authorProfileImage;
  @override
  @JsonKey()
  final bool isAltPost;
  @override
  final String? mediaUrl;
  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int dislikeCount;
  @override
  @JsonKey()
  final int replyCount;
  @override
  final double? hotnessScore;

  @override
  String toString() {
    return 'CommentModel(id: $id, postId: $postId, authorId: $authorId, content: $content, timestamp: $timestamp, parentId: $parentId, path: $path, depth: $depth, authorUsername: $authorUsername, authorProfileImage: $authorProfileImage, isAltPost: $isAltPost, mediaUrl: $mediaUrl, likeCount: $likeCount, dislikeCount: $dislikeCount, replyCount: $replyCount, hotnessScore: $hotnessScore)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CommentModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.parentId, parentId) ||
                other.parentId == parentId) &&
            (identical(other.path, path) || other.path == path) &&
            (identical(other.depth, depth) || other.depth == depth) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.authorProfileImage, authorProfileImage) ||
                other.authorProfileImage == authorProfileImage) &&
            (identical(other.isAltPost, isAltPost) ||
                other.isAltPost == isAltPost) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.dislikeCount, dislikeCount) ||
                other.dislikeCount == dislikeCount) &&
            (identical(other.replyCount, replyCount) ||
                other.replyCount == replyCount) &&
            (identical(other.hotnessScore, hotnessScore) ||
                other.hotnessScore == hotnessScore));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      postId,
      authorId,
      content,
      timestamp,
      parentId,
      path,
      depth,
      authorUsername,
      authorProfileImage,
      isAltPost,
      mediaUrl,
      likeCount,
      dislikeCount,
      replyCount,
      hotnessScore);

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CommentModelImplCopyWith<_$CommentModelImpl> get copyWith =>
      __$$CommentModelImplCopyWithImpl<_$CommentModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CommentModelImplToJson(
      this,
    );
  }
}

abstract class _CommentModel extends CommentModel {
  const factory _CommentModel(
      {required final String id,
      required final String postId,
      required final String authorId,
      required final String content,
      required final DateTime timestamp,
      final String? parentId,
      required final String path,
      final int depth,
      final String? authorUsername,
      final String? authorProfileImage,
      final bool isAltPost,
      final String? mediaUrl,
      final int likeCount,
      final int dislikeCount,
      final int replyCount,
      final double? hotnessScore}) = _$CommentModelImpl;
  const _CommentModel._() : super._();

  factory _CommentModel.fromJson(Map<String, dynamic> json) =
      _$CommentModelImpl.fromJson;

  @override
  String get id;
  @override
  String get postId;
  @override
  String get authorId;
  @override
  String get content;
  @override
  DateTime get timestamp;
  @override
  String? get parentId;
  @override
  String get path;
  @override
  int get depth;
  @override
  String? get authorUsername;
  @override
  String? get authorProfileImage;
  @override
  bool get isAltPost;
  @override
  String? get mediaUrl;
  @override
  int get likeCount;
  @override
  int get dislikeCount;
  @override
  int get replyCount;
  @override
  double? get hotnessScore;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CommentModelImplCopyWith<_$CommentModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
