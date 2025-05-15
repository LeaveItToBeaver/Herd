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
  List<PostMediaModel> get mediaItems;
  String? get mediaURL;
  String? get mediaType;
  String? get mediaThumbnailURL;
  List<String> get tags;
  bool get isNSFW;
  List<String> get mentions;
  int get likeCount;
  int get dislikeCount;
  int get commentCount;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  double? get hotScore; // Herd-related fields
  String? get herdId;
  String? get herdName;
  String? get herdProfileImageURL;
  bool get isPrivateHerd;
  bool get isHerdMember;
  bool get isHerdModerator;
  bool get isHerdBanned;
  bool get isHerdBlocked;
  bool get isAlt;
  String? get feedType; // 'public', 'alt', or 'herd'
  bool get isLiked;
  bool get isDisliked;
  bool get isBookmarked;
  bool get isRichText;

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
      ..add(DiagnosticsProperty('mediaItems', mediaItems))
      ..add(DiagnosticsProperty('mediaURL', mediaURL))
      ..add(DiagnosticsProperty('mediaType', mediaType))
      ..add(DiagnosticsProperty('mediaThumbnailURL', mediaThumbnailURL))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('mentions', mentions))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('hotScore', hotScore))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('herdProfileImageURL', herdProfileImageURL))
      ..add(DiagnosticsProperty('isPrivateHerd', isPrivateHerd))
      ..add(DiagnosticsProperty('isHerdMember', isHerdMember))
      ..add(DiagnosticsProperty('isHerdModerator', isHerdModerator))
      ..add(DiagnosticsProperty('isHerdBanned', isHerdBanned))
      ..add(DiagnosticsProperty('isHerdBlocked', isHerdBlocked))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('feedType', feedType))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('isBookmarked', isBookmarked))
      ..add(DiagnosticsProperty('isRichText', isRichText));
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
            const DeepCollectionEquality()
                .equals(other.mediaItems, mediaItems) &&
            (identical(other.mediaURL, mediaURL) ||
                other.mediaURL == mediaURL) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaThumbnailURL, mediaThumbnailURL) ||
                other.mediaThumbnailURL == mediaThumbnailURL) &&
            const DeepCollectionEquality().equals(other.tags, tags) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
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
            (identical(other.herdProfileImageURL, herdProfileImageURL) ||
                other.herdProfileImageURL == herdProfileImageURL) &&
            (identical(other.isPrivateHerd, isPrivateHerd) ||
                other.isPrivateHerd == isPrivateHerd) &&
            (identical(other.isHerdMember, isHerdMember) ||
                other.isHerdMember == isHerdMember) &&
            (identical(other.isHerdModerator, isHerdModerator) ||
                other.isHerdModerator == isHerdModerator) &&
            (identical(other.isHerdBanned, isHerdBanned) ||
                other.isHerdBanned == isHerdBanned) &&
            (identical(other.isHerdBlocked, isHerdBlocked) ||
                other.isHerdBlocked == isHerdBlocked) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.feedType, feedType) ||
                other.feedType == feedType) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.isRichText, isRichText) ||
                other.isRichText == isRichText));
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
        const DeepCollectionEquality().hash(mediaItems),
        mediaURL,
        mediaType,
        mediaThumbnailURL,
        const DeepCollectionEquality().hash(tags),
        isNSFW,
        const DeepCollectionEquality().hash(mentions),
        likeCount,
        dislikeCount,
        commentCount,
        createdAt,
        updatedAt,
        hotScore,
        herdId,
        herdName,
        herdProfileImageURL,
        isPrivateHerd,
        isHerdMember,
        isHerdModerator,
        isHerdBanned,
        isHerdBlocked,
        isAlt,
        feedType,
        isLiked,
        isDisliked,
        isBookmarked,
        isRichText
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(id: $id, authorId: $authorId, authorName: $authorName, authorUsername: $authorUsername, authorProfileImageURL: $authorProfileImageURL, title: $title, content: $content, mediaItems: $mediaItems, mediaURL: $mediaURL, mediaType: $mediaType, mediaThumbnailURL: $mediaThumbnailURL, tags: $tags, isNSFW: $isNSFW, mentions: $mentions, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, createdAt: $createdAt, updatedAt: $updatedAt, hotScore: $hotScore, herdId: $herdId, herdName: $herdName, herdProfileImageURL: $herdProfileImageURL, isPrivateHerd: $isPrivateHerd, isHerdMember: $isHerdMember, isHerdModerator: $isHerdModerator, isHerdBanned: $isHerdBanned, isHerdBlocked: $isHerdBlocked, isAlt: $isAlt, feedType: $feedType, isLiked: $isLiked, isDisliked: $isDisliked, isBookmarked: $isBookmarked, isRichText: $isRichText)';
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
      List<PostMediaModel> mediaItems,
      String? mediaURL,
      String? mediaType,
      String? mediaThumbnailURL,
      List<String> tags,
      bool isNSFW,
      List<String> mentions,
      int likeCount,
      int dislikeCount,
      int commentCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      double? hotScore,
      String? herdId,
      String? herdName,
      String? herdProfileImageURL,
      bool isPrivateHerd,
      bool isHerdMember,
      bool isHerdModerator,
      bool isHerdBanned,
      bool isHerdBlocked,
      bool isAlt,
      String? feedType,
      bool isLiked,
      bool isDisliked,
      bool isBookmarked,
      bool isRichText});
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
    Object? mediaItems = null,
    Object? mediaURL = freezed,
    Object? mediaType = freezed,
    Object? mediaThumbnailURL = freezed,
    Object? tags = null,
    Object? isNSFW = null,
    Object? mentions = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? commentCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hotScore = freezed,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? herdProfileImageURL = freezed,
    Object? isPrivateHerd = null,
    Object? isHerdMember = null,
    Object? isHerdModerator = null,
    Object? isHerdBanned = null,
    Object? isHerdBlocked = null,
    Object? isAlt = null,
    Object? feedType = freezed,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? isBookmarked = null,
    Object? isRichText = null,
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
      mediaItems: null == mediaItems
          ? _self.mediaItems
          : mediaItems // ignore: cast_nullable_to_non_nullable
              as List<PostMediaModel>,
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
      tags: null == tags
          ? _self.tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
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
      herdProfileImageURL: freezed == herdProfileImageURL
          ? _self.herdProfileImageURL
          : herdProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrivateHerd: null == isPrivateHerd
          ? _self.isPrivateHerd
          : isPrivateHerd // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdMember: null == isHerdMember
          ? _self.isHerdMember
          : isHerdMember // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdModerator: null == isHerdModerator
          ? _self.isHerdModerator
          : isHerdModerator // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdBanned: null == isHerdBanned
          ? _self.isHerdBanned
          : isHerdBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdBlocked: null == isHerdBlocked
          ? _self.isHerdBlocked
          : isHerdBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
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
      isRichText: null == isRichText
          ? _self.isRichText
          : isRichText // ignore: cast_nullable_to_non_nullable
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
      final List<PostMediaModel> mediaItems = const [],
      this.mediaURL,
      this.mediaType,
      this.mediaThumbnailURL = '',
      final List<String> tags = const [],
      this.isNSFW = false,
      final List<String> mentions = const [],
      this.likeCount = 0,
      this.dislikeCount = 0,
      this.commentCount = 0,
      this.createdAt,
      this.updatedAt,
      this.hotScore,
      this.herdId,
      this.herdName,
      this.herdProfileImageURL,
      this.isPrivateHerd = false,
      this.isHerdMember = false,
      this.isHerdModerator = false,
      this.isHerdBanned = false,
      this.isHerdBlocked = false,
      this.isAlt = false,
      this.feedType,
      this.isLiked = false,
      this.isDisliked = false,
      this.isBookmarked = false,
      this.isRichText = false})
      : _mediaItems = mediaItems,
        _tags = tags,
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
  final List<PostMediaModel> _mediaItems;
  @override
  @JsonKey()
  List<PostMediaModel> get mediaItems {
    if (_mediaItems is EqualUnmodifiableListView) return _mediaItems;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_mediaItems);
  }

  @override
  final String? mediaURL;
  @override
  final String? mediaType;
  @override
  @JsonKey()
  final String? mediaThumbnailURL;
  final List<String> _tags;
  @override
  @JsonKey()
  List<String> get tags {
    if (_tags is EqualUnmodifiableListView) return _tags;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tags);
  }

  @override
  @JsonKey()
  final bool isNSFW;
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
// Herd-related fields
  @override
  final String? herdId;
  @override
  final String? herdName;
  @override
  final String? herdProfileImageURL;
  @override
  @JsonKey()
  final bool isPrivateHerd;
  @override
  @JsonKey()
  final bool isHerdMember;
  @override
  @JsonKey()
  final bool isHerdModerator;
  @override
  @JsonKey()
  final bool isHerdBanned;
  @override
  @JsonKey()
  final bool isHerdBlocked;
  @override
  @JsonKey()
  final bool isAlt;
  @override
  final String? feedType;
// 'public', 'alt', or 'herd'
  @override
  @JsonKey()
  final bool isLiked;
  @override
  @JsonKey()
  final bool isDisliked;
  @override
  @JsonKey()
  final bool isBookmarked;
  @override
  @JsonKey()
  final bool isRichText;

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
      ..add(DiagnosticsProperty('mediaItems', mediaItems))
      ..add(DiagnosticsProperty('mediaURL', mediaURL))
      ..add(DiagnosticsProperty('mediaType', mediaType))
      ..add(DiagnosticsProperty('mediaThumbnailURL', mediaThumbnailURL))
      ..add(DiagnosticsProperty('tags', tags))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('mentions', mentions))
      ..add(DiagnosticsProperty('likeCount', likeCount))
      ..add(DiagnosticsProperty('dislikeCount', dislikeCount))
      ..add(DiagnosticsProperty('commentCount', commentCount))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('hotScore', hotScore))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('herdProfileImageURL', herdProfileImageURL))
      ..add(DiagnosticsProperty('isPrivateHerd', isPrivateHerd))
      ..add(DiagnosticsProperty('isHerdMember', isHerdMember))
      ..add(DiagnosticsProperty('isHerdModerator', isHerdModerator))
      ..add(DiagnosticsProperty('isHerdBanned', isHerdBanned))
      ..add(DiagnosticsProperty('isHerdBlocked', isHerdBlocked))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('feedType', feedType))
      ..add(DiagnosticsProperty('isLiked', isLiked))
      ..add(DiagnosticsProperty('isDisliked', isDisliked))
      ..add(DiagnosticsProperty('isBookmarked', isBookmarked))
      ..add(DiagnosticsProperty('isRichText', isRichText));
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
            const DeepCollectionEquality()
                .equals(other._mediaItems, _mediaItems) &&
            (identical(other.mediaURL, mediaURL) ||
                other.mediaURL == mediaURL) &&
            (identical(other.mediaType, mediaType) ||
                other.mediaType == mediaType) &&
            (identical(other.mediaThumbnailURL, mediaThumbnailURL) ||
                other.mediaThumbnailURL == mediaThumbnailURL) &&
            const DeepCollectionEquality().equals(other._tags, _tags) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
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
            (identical(other.herdProfileImageURL, herdProfileImageURL) ||
                other.herdProfileImageURL == herdProfileImageURL) &&
            (identical(other.isPrivateHerd, isPrivateHerd) ||
                other.isPrivateHerd == isPrivateHerd) &&
            (identical(other.isHerdMember, isHerdMember) ||
                other.isHerdMember == isHerdMember) &&
            (identical(other.isHerdModerator, isHerdModerator) ||
                other.isHerdModerator == isHerdModerator) &&
            (identical(other.isHerdBanned, isHerdBanned) ||
                other.isHerdBanned == isHerdBanned) &&
            (identical(other.isHerdBlocked, isHerdBlocked) ||
                other.isHerdBlocked == isHerdBlocked) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.feedType, feedType) ||
                other.feedType == feedType) &&
            (identical(other.isLiked, isLiked) || other.isLiked == isLiked) &&
            (identical(other.isDisliked, isDisliked) ||
                other.isDisliked == isDisliked) &&
            (identical(other.isBookmarked, isBookmarked) ||
                other.isBookmarked == isBookmarked) &&
            (identical(other.isRichText, isRichText) ||
                other.isRichText == isRichText));
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
        const DeepCollectionEquality().hash(_mediaItems),
        mediaURL,
        mediaType,
        mediaThumbnailURL,
        const DeepCollectionEquality().hash(_tags),
        isNSFW,
        const DeepCollectionEquality().hash(_mentions),
        likeCount,
        dislikeCount,
        commentCount,
        createdAt,
        updatedAt,
        hotScore,
        herdId,
        herdName,
        herdProfileImageURL,
        isPrivateHerd,
        isHerdMember,
        isHerdModerator,
        isHerdBanned,
        isHerdBlocked,
        isAlt,
        feedType,
        isLiked,
        isDisliked,
        isBookmarked,
        isRichText
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'PostModel(id: $id, authorId: $authorId, authorName: $authorName, authorUsername: $authorUsername, authorProfileImageURL: $authorProfileImageURL, title: $title, content: $content, mediaItems: $mediaItems, mediaURL: $mediaURL, mediaType: $mediaType, mediaThumbnailURL: $mediaThumbnailURL, tags: $tags, isNSFW: $isNSFW, mentions: $mentions, likeCount: $likeCount, dislikeCount: $dislikeCount, commentCount: $commentCount, createdAt: $createdAt, updatedAt: $updatedAt, hotScore: $hotScore, herdId: $herdId, herdName: $herdName, herdProfileImageURL: $herdProfileImageURL, isPrivateHerd: $isPrivateHerd, isHerdMember: $isHerdMember, isHerdModerator: $isHerdModerator, isHerdBanned: $isHerdBanned, isHerdBlocked: $isHerdBlocked, isAlt: $isAlt, feedType: $feedType, isLiked: $isLiked, isDisliked: $isDisliked, isBookmarked: $isBookmarked, isRichText: $isRichText)';
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
      List<PostMediaModel> mediaItems,
      String? mediaURL,
      String? mediaType,
      String? mediaThumbnailURL,
      List<String> tags,
      bool isNSFW,
      List<String> mentions,
      int likeCount,
      int dislikeCount,
      int commentCount,
      DateTime? createdAt,
      DateTime? updatedAt,
      double? hotScore,
      String? herdId,
      String? herdName,
      String? herdProfileImageURL,
      bool isPrivateHerd,
      bool isHerdMember,
      bool isHerdModerator,
      bool isHerdBanned,
      bool isHerdBlocked,
      bool isAlt,
      String? feedType,
      bool isLiked,
      bool isDisliked,
      bool isBookmarked,
      bool isRichText});
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
    Object? mediaItems = null,
    Object? mediaURL = freezed,
    Object? mediaType = freezed,
    Object? mediaThumbnailURL = freezed,
    Object? tags = null,
    Object? isNSFW = null,
    Object? mentions = null,
    Object? likeCount = null,
    Object? dislikeCount = null,
    Object? commentCount = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? hotScore = freezed,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? herdProfileImageURL = freezed,
    Object? isPrivateHerd = null,
    Object? isHerdMember = null,
    Object? isHerdModerator = null,
    Object? isHerdBanned = null,
    Object? isHerdBlocked = null,
    Object? isAlt = null,
    Object? feedType = freezed,
    Object? isLiked = null,
    Object? isDisliked = null,
    Object? isBookmarked = null,
    Object? isRichText = null,
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
      mediaItems: null == mediaItems
          ? _self._mediaItems
          : mediaItems // ignore: cast_nullable_to_non_nullable
              as List<PostMediaModel>,
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
      tags: null == tags
          ? _self._tags
          : tags // ignore: cast_nullable_to_non_nullable
              as List<String>,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
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
      herdProfileImageURL: freezed == herdProfileImageURL
          ? _self.herdProfileImageURL
          : herdProfileImageURL // ignore: cast_nullable_to_non_nullable
              as String?,
      isPrivateHerd: null == isPrivateHerd
          ? _self.isPrivateHerd
          : isPrivateHerd // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdMember: null == isHerdMember
          ? _self.isHerdMember
          : isHerdMember // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdModerator: null == isHerdModerator
          ? _self.isHerdModerator
          : isHerdModerator // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdBanned: null == isHerdBanned
          ? _self.isHerdBanned
          : isHerdBanned // ignore: cast_nullable_to_non_nullable
              as bool,
      isHerdBlocked: null == isHerdBlocked
          ? _self.isHerdBlocked
          : isHerdBlocked // ignore: cast_nullable_to_non_nullable
              as bool,
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
      isRichText: null == isRichText
          ? _self.isRichText
          : isRichText // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
