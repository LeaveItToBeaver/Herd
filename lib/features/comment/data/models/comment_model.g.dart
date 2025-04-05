// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CommentModel _$CommentModelFromJson(Map<String, dynamic> json) =>
    _CommentModel(
      id: json['id'] as String,
      postId: json['postId'] as String,
      authorId: json['authorId'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      parentId: json['parentId'] as String?,
      path: json['path'] as String,
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      authorUsername: json['authorUsername'] as String?,
      authorProfileImage: json['authorProfileImage'] as String?,
      isAltPost: json['isAltPost'] as bool? ?? false,
      mediaUrl: json['mediaUrl'] as String?,
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      dislikeCount: (json['dislikeCount'] as num?)?.toInt() ?? 0,
      replyCount: (json['replyCount'] as num?)?.toInt() ?? 0,
      hotnessScore: (json['hotnessScore'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$CommentModelToJson(_CommentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'postId': instance.postId,
      'authorId': instance.authorId,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'parentId': instance.parentId,
      'path': instance.path,
      'depth': instance.depth,
      'authorUsername': instance.authorUsername,
      'authorProfileImage': instance.authorProfileImage,
      'isAltPost': instance.isAltPost,
      'mediaUrl': instance.mediaUrl,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'replyCount': instance.replyCount,
      'hotnessScore': instance.hotnessScore,
    };
