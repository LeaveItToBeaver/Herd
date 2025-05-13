import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'notification_model.dart';

part 'notification_settings_model.freezed.dart';
part 'notification_settings_model.g.dart';

@freezed
abstract class NotificationSettingsModel with _$NotificationSettingsModel {
  const NotificationSettingsModel._(); // For custom methods

  const factory NotificationSettingsModel({
    required String userId,
    @Default(true) bool pushNotificationsEnabled,
    @Default(true) bool inAppNotificationsEnabled,
    // Per-type settings
    @Default(true) bool followNotifications,
    @Default(true) bool postNotifications,
    @Default(true) bool likeNotifications,
    @Default(true) bool commentNotifications,
    @Default(true) bool replyNotifications,
    @Default(true) bool connectionNotifications,
    @Default(true) bool milestoneNotifications,
    // Thresholds
    @Default(10) int likeMilestoneThreshold,
    @Default(5) int commentMilestoneThreshold,
    // Temporary mute
    DateTime? mutedUntil,
  }) = _NotificationSettingsModel;

  factory NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  factory NotificationSettingsModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationSettingsModel(
      userId: doc.id,
      pushNotificationsEnabled: data['pushNotificationsEnabled'] ?? true,
      inAppNotificationsEnabled: data['inAppNotificationsEnabled'] ?? true,
      followNotifications: data['followNotifications'] ?? true,
      postNotifications: data['postNotifications'] ?? true,
      likeNotifications: data['likeNotifications'] ?? true,
      commentNotifications: data['commentNotifications'] ?? true,
      replyNotifications: data['replyNotifications'] ?? true,
      connectionNotifications: data['connectionNotifications'] ?? true,
      milestoneNotifications: data['milestoneNotifications'] ?? true,
      likeMilestoneThreshold: data['likeMilestoneThreshold'] ?? 10,
      commentMilestoneThreshold: data['commentMilestoneThreshold'] ?? 5,
      mutedUntil: data['mutedUntil'] != null
          ? (data['mutedUntil'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    final Map<String, dynamic> result = {
      'pushNotificationsEnabled': pushNotificationsEnabled,
      'inAppNotificationsEnabled': inAppNotificationsEnabled,
      'followNotifications': followNotifications,
      'postNotifications': postNotifications,
      'likeNotifications': likeNotifications,
      'commentNotifications': commentNotifications,
      'replyNotifications': replyNotifications,
      'connectionNotifications': connectionNotifications,
      'milestoneNotifications': milestoneNotifications,
      'likeMilestoneThreshold': likeMilestoneThreshold,
      'commentMilestoneThreshold': commentMilestoneThreshold,
    };

    if (mutedUntil != null) {
      result['mutedUntil'] = Timestamp.fromDate(mutedUntil!);
    }

    return result;
  }

  // Helper to check if currently muted
  bool get isMuted {
    if (mutedUntil == null) return false;
    return DateTime.now().isBefore(mutedUntil!);
  }

  // Helper to check if a specific notification type is enabled
  bool isEnabledForType(NotificationType type) {
    if (isMuted) return false;

    switch (type) {
      case NotificationType.follow:
        return followNotifications;
      case NotificationType.newPost:
        return postNotifications;
      case NotificationType.postLike:
        return likeNotifications;
      case NotificationType.comment:
        return commentNotifications;
      case NotificationType.commentReply:
        return replyNotifications;
      case NotificationType.connectionRequest:
      case NotificationType.connectionAccepted:
        return connectionNotifications;
      case NotificationType.postMilestone:
        return milestoneNotifications;
      default:
        return true;
    }
  }
}
