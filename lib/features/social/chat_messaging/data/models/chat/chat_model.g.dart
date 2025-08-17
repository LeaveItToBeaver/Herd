// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ChatModel _$ChatModelFromJson(Map<String, dynamic> json) => _ChatModel(
      id: json['id'] as String,
      otherUserId: json['otherUserId'] as String?,
      otherUserName: json['otherUserName'] as String?,
      otherUserUsername: json['otherUserUsername'] as String?,
      otherUserProfileImage: json['otherUserProfileImage'] as String?,
      otherUserAltProfileImage: json['otherUserAltProfileImage'] as String?,
      otherUserIsAlt: json['otherUserIsAlt'] as bool? ?? false,
      isAlt: json['isAlt'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTimestamp: json['lastMessageTimestamp'] == null
          ? null
          : DateTime.parse(json['lastMessageTimestamp'] as String),
      unreadCount: (json['unreadCount'] as num?)?.toInt() ?? 0,
      isGroupChat: json['isGroupChat'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      isArchived: json['isArchived'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      groupId: json['groupId'] as String?,
    );

Map<String, dynamic> _$ChatModelToJson(_ChatModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'otherUserId': instance.otherUserId,
      'otherUserName': instance.otherUserName,
      'otherUserUsername': instance.otherUserUsername,
      'otherUserProfileImage': instance.otherUserProfileImage,
      'otherUserAltProfileImage': instance.otherUserAltProfileImage,
      'otherUserIsAlt': instance.otherUserIsAlt,
      'isAlt': instance.isAlt,
      'lastMessage': instance.lastMessage,
      'lastMessageTimestamp': instance.lastMessageTimestamp?.toIso8601String(),
      'unreadCount': instance.unreadCount,
      'isGroupChat': instance.isGroupChat,
      'isMuted': instance.isMuted,
      'isArchived': instance.isArchived,
      'isPinned': instance.isPinned,
      'groupId': instance.groupId,
    };
