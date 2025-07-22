// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageSettings _$MessageSettingsFromJson(Map<String, dynamic> json) =>
    _MessageSettings(
      userId: json['userId'] as String,
      readReceiptsEnabled: json['readReceiptsEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      doNotDisturbEnabled: json['doNotDisturbEnabled'] as bool? ?? false,
      doNotDisturbUntil: json['doNotDisturbUntil'] == null
          ? null
          : DateTime.parse(json['doNotDisturbUntil'] as String),
      showPreviewInNotifications:
          json['showPreviewInNotifications'] as bool? ?? true,
      archiveReadChats: json['archiveReadChats'] as bool? ?? false,
      autoDeleteMessagesAfterHours:
          (json['autoDeleteMessagesAfterHours'] as num?)?.toInt() ?? 24,
      allowGroupInvites: json['allowGroupInvites'] as bool? ?? true,
      allowUnknownContacts: json['allowUnknownContacts'] as bool? ?? true,
      blockScreenshots: json['blockScreenshots'] as bool? ?? false,
      whoCanSeeLastSeen: json['whoCanSeeLastSeen'] as String? ?? 'Everyone',
      whoCanSeeProfilePhoto:
          json['whoCanSeeProfilePhoto'] as String? ?? 'Everyone',
      whoCanAddToGroups: json['whoCanAddToGroups'] as String? ?? 'Everyone',
    );

Map<String, dynamic> _$MessageSettingsToJson(_MessageSettings instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'readReceiptsEnabled': instance.readReceiptsEnabled,
      'notificationsEnabled': instance.notificationsEnabled,
      'soundEnabled': instance.soundEnabled,
      'vibrationEnabled': instance.vibrationEnabled,
      'doNotDisturbEnabled': instance.doNotDisturbEnabled,
      'doNotDisturbUntil': instance.doNotDisturbUntil?.toIso8601String(),
      'showPreviewInNotifications': instance.showPreviewInNotifications,
      'archiveReadChats': instance.archiveReadChats,
      'autoDeleteMessagesAfterHours': instance.autoDeleteMessagesAfterHours,
      'allowGroupInvites': instance.allowGroupInvites,
      'allowUnknownContacts': instance.allowUnknownContacts,
      'blockScreenshots': instance.blockScreenshots,
      'whoCanSeeLastSeen': instance.whoCanSeeLastSeen,
      'whoCanSeeProfilePhoto': instance.whoCanSeeProfilePhoto,
      'whoCanAddToGroups': instance.whoCanAddToGroups,
    };
