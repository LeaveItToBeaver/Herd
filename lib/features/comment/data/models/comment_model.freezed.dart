// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentModel implements DiagnosticableTreeMixin {
  String get id;
  String get postId;
  String get authorId;
  String get content;
  DateTime get timestamp;
  String? get parentId;
  String get path;
  int get depth;
  String? get authorUsername;
  String? get authorProfileImage;
  bool get isAltPost;
  String? get mediaUrl;
  int get likeCount;
  int get dislikeCount;
  int get replyCount;
  double? get hotnessScore;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CommentModelCopyWith<CommentModel> get copyWith =>
      _$CommentModelCopyWithImpl<CommentModel>(
          this as CommentModel, _$identity);

  /// Serializes this CommentModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('authorId', authorId))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('parentId', parentId))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('depth', depth))
      ..add(DiagnosticsProperty('authorUsername', authorUsername))
      ..add(DiagnosticsProperty('authorProfileImage', authorProfileImage))
      ..add(DiagnosticsProperty('isAltPost', isAltPost))
      ..add(DiagnosticsProperty('mediaUrl', mediaUrl))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('replyCount', replyCount))
      ..add(DiagnosticsProperty('hotnessScore', hotnessScore));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CommentModel &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentModel(id: $id, postId: $postId, authorId: $authorId, content: $content, timestamp: $timestamp, parentId: $parentId, path: $path, depth: $depth, authorUsername: $authorUsername, authorProfileImage: $authorProfileImage, isAltPost: $isAltPost, mediaUrl: $mediaUrl, likeCount: $likeCount, dislikeCount: $dislikeCount, replyCount: $replyCount, hotnessScore: $hotnessScore)';
  }
}

/// @nodoc
abstract mixin class $CommentModelCopyWith<$Res> {
  factory $CommentModelCopyWith(
          CommentModel value, $Res Function(CommentModel) _then) =
      _$CommentModelCopyWithImpl;
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
class _$CommentModelCopyWithImpl<$Res> implements $CommentModelCopyWith<$Res> {
  _$CommentModelCopyWithImpl(this._self, this._then);

  final CommentModel _self;
  final $Res Function(CommentModel) _then;

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
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parentId: freezed == parentId
          ? _self.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      path: null == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      depth: null == depth
          ? _self.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      authorUsername: freezed == authorUsername
          ? _self.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileImage: freezed == authorProfileImage
          ? _self.authorProfileImage
          : authorProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isAltPost: null == isAltPost
          ? _self.isAltPost
          : isAltPost // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _self.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _self.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _self.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hotnessScore: freezed == hotnessScore
          ? _self.hotnessScore
          : hotnessScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _CommentModel extends CommentModel with DiagnosticableTreeMixin {
  const _CommentModel(
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
  factory _CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

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

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CommentModelCopyWith<_CommentModel> get copyWith =>
      __$CommentModelCopyWithImpl<_CommentModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CommentModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CommentModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('authorId', authorId))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('parentId', parentId))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('depth', depth))
      ..add(DiagnosticsProperty('authorUsername', authorUsername))
      ..add(DiagnosticsProperty('authorProfileImage', authorProfileImage))
      ..add(DiagnosticsProperty('isAltPost', isAltPost))
      ..add(DiagnosticsProperty('mediaUrl', mediaUrl))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('replyCount', replyCount))
      ..add(DiagnosticsProperty('hotnessScore', hotnessScore));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CommentModel &&
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

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CommentModel(id: $id, postId: $postId, authorId: $authorId, content: $content, timestamp: $timestamp, parentId: $parentId, path: $path, depth: $depth, authorUsername: $authorUsername, authorProfileImage: $authorProfileImage, isAltPost: $isAltPost, mediaUrl: $mediaUrl, likeCount: $likeCount, dislikeCount: $dislikeCount, replyCount: $replyCount, hotnessScore: $hotnessScore)';
  }
}

/// @nodoc
abstract mixin class _$CommentModelCopyWith<$Res>
    implements $CommentModelCopyWith<$Res> {
  factory _$CommentModelCopyWith(
          _CommentModel value, $Res Function(_CommentModel) _then) =
      __$CommentModelCopyWithImpl;
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
class __$CommentModelCopyWithImpl<$Res>
    implements _$CommentModelCopyWith<$Res> {
  __$CommentModelCopyWithImpl(this._self, this._then);

  final _CommentModel _self;
  final $Res Function(_CommentModel) _then;

  /// Create a copy of CommentModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
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
    return _then(_CommentModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      postId: null == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      parentId: freezed == parentId
          ? _self.parentId
          : parentId // ignore: cast_nullable_to_non_nullable
              as String?,
      path: null == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String,
      depth: null == depth
          ? _self.depth
          : depth // ignore: cast_nullable_to_non_nullable
              as int,
      authorUsername: freezed == authorUsername
          ? _self.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileImage: freezed == authorProfileImage
          ? _self.authorProfileImage
          : authorProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isAltPost: null == isAltPost
          ? _self.isAltPost
          : isAltPost // ignore: cast_nullable_to_non_nullable
              as bool,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      likeCount: null == likeCount
          ? _self.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _self.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      replyCount: null == replyCount
          ? _self.replyCount
          : replyCount // ignore: cast_nullable_to_non_nullable
              as int,
      hotnessScore: freezed == hotnessScore
          ? _self.hotnessScore
          : hotnessScore // ignore: cast_nullable_to_non_nullable
              as double?,
    ));
  }
}

// dart format on
