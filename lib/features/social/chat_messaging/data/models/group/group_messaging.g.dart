// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_messaging.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GroupMessaging _$GroupMessagingFromJson(Map<String, dynamic> json) =>
    _GroupMessaging(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      groupImage: json['groupImage'] as String?,
      participants: (json['participants'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      adminId: json['adminId'] as String,
      adminName: json['adminName'] as String?,
      adminUsername: json['adminUsername'] as String?,
      moderatorIds: (json['moderatorIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      bannedUserIds: (json['bannedUserIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isPrivate: json['isPrivate'] as bool? ?? false,
      allowMembersToAddOthers: json['allowMembersToAddOthers'] as bool? ?? true,
      allowMembersToEditGroupInfo:
          json['allowMembersToEditGroupInfo'] as bool? ?? true,
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      maxParticipants: (json['maxParticipants'] as num?)?.toInt() ?? 0,
      inviteLink: json['inviteLink'] as String?,
      isArchived: json['isArchived'] as bool? ?? false,
      isMuted: json['isMuted'] as bool? ?? false,
      lastMessage: json['lastMessage'] as String?,
      lastMessageTimestamp: json['lastMessageTimestamp'] == null
          ? null
          : DateTime.parse(json['lastMessageTimestamp'] as String),
    );

Map<String, dynamic> _$GroupMessagingToJson(_GroupMessaging instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'groupImage': instance.groupImage,
      'participants': instance.participants,
      'adminId': instance.adminId,
      'adminName': instance.adminName,
      'adminUsername': instance.adminUsername,
      'moderatorIds': instance.moderatorIds,
      'bannedUserIds': instance.bannedUserIds,
      'isPrivate': instance.isPrivate,
      'allowMembersToAddOthers': instance.allowMembersToAddOthers,
      'allowMembersToEditGroupInfo': instance.allowMembersToEditGroupInfo,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'maxParticipants': instance.maxParticipants,
      'inviteLink': instance.inviteLink,
      'isArchived': instance.isArchived,
      'isMuted': instance.isMuted,
      'lastMessage': instance.lastMessage,
      'lastMessageTimestamp': instance.lastMessageTimestamp?.toIso8601String(),
    };
