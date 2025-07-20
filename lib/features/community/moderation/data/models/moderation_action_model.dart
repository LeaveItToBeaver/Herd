import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'moderation_action_model.freezed.dart';

@freezed
abstract class ModerationAction with _$ModerationAction {
  const ModerationAction._();

  const factory ModerationAction({
    required String actionId,
    required String performedBy, // userId of moderator/owner
    required DateTime timestamp,
    required ModActionType actionType,
    required String targetId, // userId, postId, or commentId
    required ModTargetType targetType,
    String? reason,
    String? notes,
    Map<String, dynamic>? metadata, // Store additional context
    String? previousValue, // For edits, store what was changed
  }) = _ModerationAction;

  factory ModerationAction.fromMap(Map<String, dynamic> map) {
    return ModerationAction(
      actionId: map['actionId'] ?? '',
      performedBy: map['performedBy'] ?? '',
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
      actionType: ModActionType.values.firstWhere(
        (e) => e.name == map['actionType'],
        orElse: () => ModActionType.unknown,
      ),
      targetId: map['targetId'] ?? '',
      targetType: ModTargetType.values.firstWhere(
        (e) => e.name == map['targetType'],
        orElse: () => ModTargetType.unknown,
      ),
      reason: map['reason'],
      notes: map['notes'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      previousValue: map['previousValue'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'actionId': actionId,
      'performedBy': performedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'actionType': actionType.name,
      'targetId': targetId,
      'targetType': targetType.name,
      'reason': reason,
      'notes': notes,
      'metadata': metadata,
      'previousValue': previousValue,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}

// Enum for action types
enum ModActionType {
  // User actions
  banUser,
  unbanUser,
  warnUser,

  // Post actions
  removePost,
  restorePost,
  pinPost,
  unpinPost,
  lockPost,
  unlockPost,

  // Comment actions
  removeComment,
  restoreComment,
  lockComments,
  unlockComments,

  // Herd management
  editHerdInfo,
  addModerator,
  removeModerator,
  transferOwnership,

  // Report handling
  reviewReport,
  dismissReport,
  escalateReport,

  unknown,
}

// Enum for target types
enum ModTargetType {
  user,
  post,
  comment,
  herd,
  report,
  unknown,
}

// Extension for human-readable action descriptions
extension ModActionTypeExtension on ModActionType {
  String get displayName {
    switch (this) {
      case ModActionType.banUser:
        return 'Banned User';
      case ModActionType.unbanUser:
        return 'Unbanned User';
      case ModActionType.warnUser:
        return 'Warned User';
      case ModActionType.removePost:
        return 'Removed Post';
      case ModActionType.restorePost:
        return 'Restored Post';
      case ModActionType.pinPost:
        return 'Pinned Post';
      case ModActionType.unpinPost:
        return 'Unpinned Post';
      case ModActionType.lockPost:
        return 'Locked Post';
      case ModActionType.unlockPost:
        return 'Unlocked Post';
      case ModActionType.removeComment:
        return 'Removed Comment';
      case ModActionType.restoreComment:
        return 'Restored Comment';
      case ModActionType.lockComments:
        return 'Locked Comments';
      case ModActionType.unlockComments:
        return 'Unlocked Comments';
      case ModActionType.editHerdInfo:
        return 'Edited Herd Info';
      case ModActionType.addModerator:
        return 'Added Moderator';
      case ModActionType.removeModerator:
        return 'Removed Moderator';
      case ModActionType.transferOwnership:
        return 'Transferred Ownership';
      case ModActionType.reviewReport:
        return 'Reviewed Report';
      case ModActionType.dismissReport:
        return 'Dismissed Report';
      case ModActionType.escalateReport:
        return 'Escalated Report';
      default:
        return 'Unknown Action';
    }
  }

  IconData get icon {
    switch (this) {
      case ModActionType.banUser:
      case ModActionType.unbanUser:
        return Icons.block;
      case ModActionType.warnUser:
        return Icons.warning;
      case ModActionType.removePost:
      case ModActionType.removeComment:
        return Icons.delete;
      case ModActionType.restorePost:
      case ModActionType.restoreComment:
        return Icons.restore;
      case ModActionType.pinPost:
      case ModActionType.unpinPost:
        return Icons.push_pin;
      case ModActionType.lockPost:
      case ModActionType.lockComments:
        return Icons.lock;
      case ModActionType.unlockPost:
      case ModActionType.unlockComments:
        return Icons.lock_open;
      case ModActionType.editHerdInfo:
        return Icons.edit;
      case ModActionType.addModerator:
      case ModActionType.removeModerator:
        return Icons.admin_panel_settings;
      case ModActionType.transferOwnership:
        return Icons.swap_horiz;
      case ModActionType.reviewReport:
      case ModActionType.dismissReport:
      case ModActionType.escalateReport:
        return Icons.flag;
      default:
        return Icons.help_outline;
    }
  }

  Color get color {
    switch (this) {
      case ModActionType.banUser:
      case ModActionType.removePost:
      case ModActionType.removeComment:
        return Colors.red;
      case ModActionType.unbanUser:
      case ModActionType.restorePost:
      case ModActionType.restoreComment:
        return Colors.green;
      case ModActionType.warnUser:
        return Colors.orange;
      case ModActionType.pinPost:
      case ModActionType.unpinPost:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
