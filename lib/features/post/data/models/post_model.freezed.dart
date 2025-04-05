// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'post_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PostModel implements DiagnosticableTreeMixin {
  String get id;
  String get authorId;
  String? get authorName;
  String? get authorUsername;
  String? get authorProfileImageURL;
  String? get title;
  String get content;
  String? get mediaURL;
  String? get mediaType;
  String? get mediaThumbnailURL;
  List<String> get hashtags;
  List<String> get mentions;
  int get likeCount;
  int get dislikeCount;
  int get commentCount;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  double? get hotScore;
  String? get herdId;
  String? get herdName;
  bool get isAlt;
  String? get feedType; // New field: 'public', 'alt', or 'herd'
  bool get isLiked;
  bool get isDisliked;
  bool get isBookmarked;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<PostModel> get copyWith =>
      _$PostModelCopyWithImpl<PostModel>(this as PostModel, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('authorId', authorId))
      ..add(DiagnosticsProperty('authorName', authorName))
      ..add(DiagnosticsProperty('authorUsername', authorUsername))
      ..add(DiagnosticsProperty('authorProfileImageURL', authorProfileImageURL))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('mediaURL', mediaURL))
      ..add(DiagnosticsProperty('mediaType', mediaType))
      ..add(DiagnosticsProperty('mediaThumbnailURL', mediaThumbnailURL))
      ..add(DiagnosticsProperty('hashtags', hashtags))
      ..add(DiagnosticsProperty('mentions', mentions))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('hotScore', hotScore))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('feedType', feedType))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('isBookmarked', isBookmarked));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is PostModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.authorProfileImageURL, authorProfileImageURL) ||
                other.authorProfileImageURL == authorProfileImageURL) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.mediaURL, mediaURL) ||
                other.mediaURL == mediaURL) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaThumbnailURL, mediaThumbnailURL) ||
                other.mediaThumbnailURL == mediaThumbnailURL) &&
            const DeepCollectionEquality().equals(other.hashtags, hashtags) &&
            const DeepCollectionEquality().equals(other.mentions, mentions) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.dislikeCount, dislikeCount) ||
                other.dislikeCount == dislikeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.hotScore, hotScore) ||
                other.hotScore == hotScore) &&
            (identical(other.herdId, herdId) || other.herdId == herdId) &&
            (identical(other.herdName, herdName) ||
                other.herdName == herdName) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.feedType, feedType) ||
                other.feedType == feedType) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        authorId,
        authorName,
        authorUsername,
        authorProfileImageURL,
        title,
        content,
        mediaURL,
        mediaType,
        mediaThumbnailURL,
        const DeepCollectionEquality().hash(hashtags),
        const DeepCollectionEquality().hash(mentions),
        likeCount,
        dislikeCount,
        commentCount,
        createdAt,
        updatedAt,
        hotScore,
        herdId,
        herdName,
        isAlt,
        feedType,
        isLiked,
        isDisliked,
        isBookmarked
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(id: $id, authorId: $authorId, authorName: $authorName, authorUsername: $authorUsername, authorProfileImageURL: $authorProfileImageURL, title: $title, content: $content, mediaURL: $mediaURL, mediaType: $mediaType, mediaThumbnailURL: $mediaThumbnailURL, hashtags: $hashtags, mentions: $mentions, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, createdAt: $createdAt, updatedAt: $updatedAt, hotScore: $hotScore, herdId: $herdId, herdName: $herdName, isAlt: $isAlt, feedType: $feedType, isLiked: $isLiked, isDisliked: $isDisliked, isBookmarked: $isBookmarked)';
  }
}

/// @nodoc
abstract mixin class $PostModelCopyWith<$Res> {
  factory $PostModelCopyWith(PostModel value, $Res Function(PostModel) _then) =
      _$PostModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String authorId,
      String? authorName,
      String? authorUsername,
      String? authorProfileImageURL,
      String? title,
      String content,
      String? mediaURL,
      String? mediaType,
      String? mediaThumbnailURL,
      List<String> hashtags,
      List<String> mentions,
      int likeCount,
      int dislikeCount,
      int commentCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      double? hotScore,
      String? herdId,
      String? herdName,
      bool isAlt,
      String? feedType,
      bool isLiked,
      bool isDisliked,
      bool isBookmarked});
}

/// @nodoc
class _$PostModelCopyWithImpl<$Res> implements $PostModelCopyWith<$Res> {
  _$PostModelCopyWithImpl(this._self, this._then);

  final PostModel _self;
  final $Res Function(PostModel) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = freezed,
    Object? authorUsername = freezed,
    Object? authorProfileImageURL = freezed,
    Object? title = freezed,
    Object? content = null,
    Object? mediaURL = freezed,
    Object? mediaType = freezed,
    Object? mediaThumbnailURL = freezed,
    Object? hashtags = null,
    Object? mentions = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? commentCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hotScore = freezed,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? isAlt = null,
    Object? feedType = freezed,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? isBookmarked = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: freezed == authorName
          ? _self.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorUsername: freezed == authorUsername
          ? _self.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileImageURL: freezed == authorProfileImageURL
          ? _self.authorProfileImageURL
          : authorProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      mediaURL: freezed == mediaURL
          ? _self.mediaURL
          : mediaURL // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: freezed == mediaType
          ? _self.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaThumbnailURL: freezed == mediaThumbnailURL
          ? _self.mediaThumbnailURL
          : mediaThumbnailURL // ignore: cast_nullable_to_non_nullable
              as String?,
      hashtags: null == hashtags
          ? _self.hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mentions: null == mentions
          ? _self.mentions
          : mentions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likeCount: null == likeCount
          ? _self.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _self.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _self.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hotScore: freezed == hotScore
          ? _self.hotScore
          : hotScore // ignore: cast_nullable_to_non_nullable
              as double?,
      herdId: freezed == herdId
          ? _self.herdId
          : herdId // ignore: cast_nullable_to_non_nullable
              as String?,
      herdName: freezed == herdName
          ? _self.herdName
          : herdName // ignore: cast_nullable_to_non_nullable
              as String?,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      feedType: freezed == feedType
          ? _self.feedType
          : feedType // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _self.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

class _PostModel extends PostModel with DiagnosticableTreeMixin {
  const _PostModel(
      {required this.id,
      required this.authorId,
      this.authorName,
      this.authorUsername,
      this.authorProfileImageURL,
      this.title,
      required this.content,
      this.mediaURL,
      this.mediaType,
      this.mediaThumbnailURL = '',
      final List<String> hashtags = const [],
      final List<String> mentions = const [],
      this.likeCount = 0,
      this.dislikeCount = 0,
      this.commentCount = 0,
      this.createdAt,
      this.updatedAt,
      this.hotScore,
      this.herdId,
      this.herdName,
      this.isAlt = false,
      this.feedType,
      this.isLiked = false,
      this.isDisliked = false,
      this.isBookmarked = false})
      : _hashtags = hashtags,
        _mentions = mentions,
        super._();

  @override
  final String id;
  @override
  final String authorId;
  @override
  final String? authorName;
  @override
  final String? authorUsername;
  @override
  final String? authorProfileImageURL;
  @override
  final String? title;
  @override
  final String content;
  @override
  final String? mediaURL;
  @override
  final String? mediaType;
  @override
  @JsonKey()
  final String? mediaThumbnailURL;
  final List<String> _hashtags;
  @override
  @JsonKey()
  List<String> get hashtags {
    if (_hashtags is EqualUnmodifiableListView) return _hashtags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_hashtags);
  }

  final List<String> _mentions;
  @override
  @JsonKey()
  List<String> get mentions {
    if (_mentions is EqualUnmodifiableListView) return _mentions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mentions);
  }

  @override
  @JsonKey()
  final int likeCount;
  @override
  @JsonKey()
  final int dislikeCount;
  @override
  @JsonKey()
  final int commentCount;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  final double? hotScore;
  @override
  final String? herdId;
  @override
  final String? herdName;
  @override
  @JsonKey()
  final bool isAlt;
  @override
  final String? feedType;
// New field: 'public', 'alt', or 'herd'
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isDisliked;
  @override
  @JsonKey()
  final bool isBookmarked;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$PostModelCopyWith<_PostModel> get copyWith =>
      __$PostModelCopyWithImpl<_PostModel>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'PostModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('authorId', authorId))
      ..add(DiagnosticsProperty('authorName', authorName))
      ..add(DiagnosticsProperty('authorUsername', authorUsername))
      ..add(DiagnosticsProperty('authorProfileImageURL', authorProfileImageURL))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('content', content))
      ..add(DiagnosticsProperty('mediaURL', mediaURL))
      ..add(DiagnosticsProperty('mediaType', mediaType))
      ..add(DiagnosticsProperty('mediaThumbnailURL', mediaThumbnailURL))
      ..add(DiagnosticsProperty('hashtags', hashtags))
      ..add(DiagnosticsProperty('mentions', mentions))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('hotScore', hotScore))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('feedType', feedType))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('isBookmarked', isBookmarked));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _PostModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.authorId, authorId) ||
                other.authorId == authorId) &&
            (identical(other.authorName, authorName) ||
                other.authorName == authorName) &&
            (identical(other.authorUsername, authorUsername) ||
                other.authorUsername == authorUsername) &&
            (identical(other.authorProfileImageURL, authorProfileImageURL) ||
                other.authorProfileImageURL == authorProfileImageURL) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.mediaURL, mediaURL) ||
                other.mediaURL == mediaURL) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaThumbnailURL, mediaThumbnailURL) ||
                other.mediaThumbnailURL == mediaThumbnailURL) &&
            const DeepCollectionEquality().equals(other._hashtags, _hashtags) &&
            const DeepCollectionEquality().equals(other._mentions, _mentions) &&
            (identical(other.likeCount, likeCount) ||
                other.likeCount == likeCount) &&
            (identical(other.dislikeCount, dislikeCount) ||
                other.dislikeCount == dislikeCount) &&
            (identical(other.commentCount, commentCount) ||
                other.commentCount == commentCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.hotScore, hotScore) ||
                other.hotScore == hotScore) &&
            (identical(other.herdId, herdId) || other.herdId == herdId) &&
            (identical(other.herdName, herdName) ||
                other.herdName == herdName) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.feedType, feedType) ||
                other.feedType == feedType) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        authorId,
        authorName,
        authorUsername,
        authorProfileImageURL,
        title,
        content,
        mediaURL,
        mediaType,
        mediaThumbnailURL,
        const DeepCollectionEquality().hash(_hashtags),
        const DeepCollectionEquality().hash(_mentions),
        likeCount,
        dislikeCount,
        commentCount,
        createdAt,
        updatedAt,
        hotScore,
        herdId,
        herdName,
        isAlt,
        feedType,
        isLiked,
        isDisliked,
        isBookmarked
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(id: $id, authorId: $authorId, authorName: $authorName, authorUsername: $authorUsername, authorProfileImageURL: $authorProfileImageURL, title: $title, content: $content, mediaURL: $mediaURL, mediaType: $mediaType, mediaThumbnailURL: $mediaThumbnailURL, hashtags: $hashtags, mentions: $mentions, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, createdAt: $createdAt, updatedAt: $updatedAt, hotScore: $hotScore, herdId: $herdId, herdName: $herdName, isAlt: $isAlt, feedType: $feedType, isLiked: $isLiked, isDisliked: $isDisliked, isBookmarked: $isBookmarked)';
  }
}

/// @nodoc
abstract mixin class _$PostModelCopyWith<$Res>
    implements $PostModelCopyWith<$Res> {
  factory _$PostModelCopyWith(
          _PostModel value, $Res Function(_PostModel) _then) =
      __$PostModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String authorId,
      String? authorName,
      String? authorUsername,
      String? authorProfileImageURL,
      String? title,
      String content,
      String? mediaURL,
      String? mediaType,
      String? mediaThumbnailURL,
      List<String> hashtags,
      List<String> mentions,
      int likeCount,
      int dislikeCount,
      int commentCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      double? hotScore,
      String? herdId,
      String? herdName,
      bool isAlt,
      String? feedType,
      bool isLiked,
      bool isDisliked,
      bool isBookmarked});
}

/// @nodoc
class __$PostModelCopyWithImpl<$Res> implements _$PostModelCopyWith<$Res> {
  __$PostModelCopyWithImpl(this._self, this._then);

  final _PostModel _self;
  final $Res Function(_PostModel) _then;

  /// Create a copy of PostModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? authorId = null,
    Object? authorName = freezed,
    Object? authorUsername = freezed,
    Object? authorProfileImageURL = freezed,
    Object? title = freezed,
    Object? content = null,
    Object? mediaURL = freezed,
    Object? mediaType = freezed,
    Object? mediaThumbnailURL = freezed,
    Object? hashtags = null,
    Object? mentions = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? commentCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hotScore = freezed,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? isAlt = null,
    Object? feedType = freezed,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? isBookmarked = null,
  }) {
    return _then(_PostModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      authorId: null == authorId
          ? _self.authorId
          : authorId // ignore: cast_nullable_to_non_nullable
              as String,
      authorName: freezed == authorName
          ? _self.authorName
          : authorName // ignore: cast_nullable_to_non_nullable
              as String?,
      authorUsername: freezed == authorUsername
          ? _self.authorUsername
          : authorUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      authorProfileImageURL: freezed == authorProfileImageURL
          ? _self.authorProfileImageURL
          : authorProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      content: null == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      mediaURL: freezed == mediaURL
          ? _self.mediaURL
          : mediaURL // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaType: freezed == mediaType
          ? _self.mediaType
          : mediaType // ignore: cast_nullable_to_non_nullable
              as String?,
      mediaThumbnailURL: freezed == mediaThumbnailURL
          ? _self.mediaThumbnailURL
          : mediaThumbnailURL // ignore: cast_nullable_to_non_nullable
              as String?,
      hashtags: null == hashtags
          ? _self._hashtags
          : hashtags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      mentions: null == mentions
          ? _self._mentions
          : mentions // ignore: cast_nullable_to_non_nullable
              as List<String>,
      likeCount: null == likeCount
          ? _self.likeCount
          : likeCount // ignore: cast_nullable_to_non_nullable
              as int,
      dislikeCount: null == dislikeCount
          ? _self.dislikeCount
          : dislikeCount // ignore: cast_nullable_to_non_nullable
              as int,
      commentCount: null == commentCount
          ? _self.commentCount
          : commentCount // ignore: cast_nullable_to_non_nullable
              as int,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      hotScore: freezed == hotScore
          ? _self.hotScore
          : hotScore // ignore: cast_nullable_to_non_nullable
              as double?,
      herdId: freezed == herdId
          ? _self.herdId
          : herdId // ignore: cast_nullable_to_non_nullable
              as String?,
      herdName: freezed == herdName
          ? _self.herdName
          : herdName // ignore: cast_nullable_to_non_nullable
              as String?,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      feedType: freezed == feedType
          ? _self.feedType
          : feedType // ignore: cast_nullable_to_non_nullable
              as String?,
      isLiked: null == isLiked
          ? _self.isLiked
          : isLiked // ignore: cast_nullable_to_non_nullable
              as bool,
      isDisliked: null == isDisliked
          ? _self.isDisliked
          : isDisliked // ignore: cast_nullable_to_non_nullable
              as bool,
      isBookmarked: null == isBookmarked
          ? _self.isBookmarked
          : isBookmarked // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
