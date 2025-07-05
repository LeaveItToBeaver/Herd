// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    _NotificationModel(
      id: json['id'] as String,
      recipientId: json['recipientId'] as String?,
      senderId: json['senderId'] as String,
      type: $enumDecode(_$NotificationTypeEnumMap, json['type']),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool? ?? false,
      title: json['title'] as String?,
      body: json['body'] as String?,
      postId: json['postId'] as String?,
      commentId: json['commentId'] as String?,
      senderName: json['senderName'] as String?,
      senderUsername: json['senderUsername'] as String?,
      senderProfileImage: json['senderProfileImage'] as String?,
      senderAltProfileImage: json['senderAltProfileImage'] as String?,
      isAlt: json['isAlt'] as bool? ?? false,
      count: (json['count'] as num?)?.toInt(),
      path: json['path'] as String?,
      data: json['data'] as Map<String, dynamic>? ?? const {},
    );

Map<String, dynamic> _$NotificationModelToJson(_NotificationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'recipientId': instance.recipientId,
      'senderId': instance.senderId,
      'type': _$NotificationTypeEnumMap[instance.type]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'isRead': instance.isRead,
      'title': instance.title,
      'body': instance.body,
      'postId': instance.postId,
      'commentId': instance.commentId,
      'senderName': instance.senderName,
      'senderUsername': instance.senderUsername,
      'senderProfileImage': instance.senderProfileImage,
      'senderAltProfileImage': instance.senderAltProfileImage,
      'isAlt': instance.isAlt,
      'count': instance.count,
      'path': instance.path,
      'data': instance.data,
    };

const _$NotificationTypeEnumMap = {
  NotificationType.follow: 'follow',
  NotificationType.newPost: 'newPost',
  NotificationType.postLike: 'postLike',
  NotificationType.comment: 'comment',
  NotificationType.commentReply: 'commentReply',
  NotificationType.connectionRequest: 'connectionRequest',
  NotificationType.connectionAccepted: 'connectionAccepted',
  NotificationType.postMilestone: 'postMilestone',
};
