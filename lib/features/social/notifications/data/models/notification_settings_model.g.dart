// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_settings_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationSettingsModel _$NotificationSettingsModelFromJson(
        Map<String, dynamic> json) =>
    _NotificationSettingsModel(
      userId: json['userId'] as String,
      pushNotificationsEnabled:
          json['pushNotificationsEnabled'] as bool? ?? true,
      inAppNotificationsEnabled:
          json['inAppNotificationsEnabled'] as bool? ?? true,
      followNotifications: json['followNotifications'] as bool? ?? true,
      postNotifications: json['postNotifications'] as bool? ?? true,
      likeNotifications: json['likeNotifications'] as bool? ?? true,
      commentNotifications: json['commentNotifications'] as bool? ?? true,
      replyNotifications: json['replyNotifications'] as bool? ?? true,
      connectionNotifications: json['connectionNotifications'] as bool? ?? true,
      milestoneNotifications: json['milestoneNotifications'] as bool? ?? true,
      likeMilestoneThreshold:
          (json['likeMilestoneThreshold'] as num?)?.toInt() ?? 10,
      commentMilestoneThreshold:
          (json['commentMilestoneThreshold'] as num?)?.toInt() ?? 5,
      mutedUntil: json['mutedUntil'] == null
          ? null
          : DateTime.parse(json['mutedUntil'] as String),
    );

Map<String, dynamic> _$NotificationSettingsModelToJson(
        _NotificationSettingsModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'pushNotificationsEnabled': instance.pushNotificationsEnabled,
      'inAppNotificationsEnabled': instance.inAppNotificationsEnabled,
      'followNotifications': instance.followNotifications,
      'postNotifications': instance.postNotifications,
      'likeNotifications': instance.likeNotifications,
      'commentNotifications': instance.commentNotifications,
      'replyNotifications': instance.replyNotifications,
      'connectionNotifications': instance.connectionNotifications,
      'milestoneNotifications': instance.milestoneNotifications,
      'likeMilestoneThreshold': instance.likeMilestoneThreshold,
      'commentMilestoneThreshold': instance.commentMilestoneThreshold,
      'mutedUntil': instance.mutedUntil?.toIso8601String(),
    };
