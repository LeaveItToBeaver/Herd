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
      authorName: json['authorName'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      parentId: json['parentId'] as String?,
      path: json['path'] as String,
      depth: (json['depth'] as num?)?.toInt() ?? 0,
      authorUsername: json['authorUsername'] as String?,
      authorFirstName: json['authorFirstName'] as String?,
      authorLastName: json['authorLastName'] as String?,
      authorProfileImage: json['authorProfileImage'] as String?,
      authorAltProfileImage: json['authorAltProfileImage'] as String?,
      isAuthorAlt: json['isAuthorAlt'] as bool? ?? false,
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
      'authorName': instance.authorName,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'parentId': instance.parentId,
      'path': instance.path,
      'depth': instance.depth,
      'authorUsername': instance.authorUsername,
      'authorFirstName': instance.authorFirstName,
      'authorLastName': instance.authorLastName,
      'authorProfileImage': instance.authorProfileImage,
      'authorAltProfileImage': instance.authorAltProfileImage,
      'isAuthorAlt': instance.isAuthorAlt,
      'isAltPost': instance.isAltPost,
      'mediaUrl': instance.mediaUrl,
      'likeCount': instance.likeCount,
      'dislikeCount': instance.dislikeCount,
      'replyCount': instance.replyCount,
      'hotnessScore': instance.hotnessScore,
    };
