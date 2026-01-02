import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/community/herds/data/repositories/herd_repository.dart';

import 'package:herdapp/features/community/moderation/data/models/herd_role.dart';
import 'package:herdapp/features/community/moderation/data/models/moderation_action_model.dart';

class RoleRepository {
  final FirebaseFirestore _firestore;
  final HerdRepository _herdRepository;

  RoleRepository(this._firestore, this._herdRepository);

  /// Change a user's role in a herd
  Future<void> changeUserRole({
    required String herdId,
    required String targetUserId,
    required HerdRole newRole,
    required String performedBy,
    required HerdRole performerRole,
  }) async {
    final targetDoc =
        await _herdRepository.herdMembers(herdId).doc(targetUserId).get();

    if (!targetDoc.exists) {
      throw Exception('User is not a member of this herd');
    }

    final targetData = targetDoc.data();
    if (targetData == null) {
      throw Exception('Member record is missing data');
    }
    final currentRole = parseHerdRole(targetData);

    if (!performerRole.outranks(newRole)) {
      throw Exception('Cannot assign a role equal to or higher than your role');
    }

    if (!performerRole.outranks(currentRole)) {
      throw Exception('Cannot modify role of someone at or above your level');
    }

    if (newRole == HerdRole.owner && performerRole != HerdRole.owner) {
      throw Exception('Only the owner can transfer ownership');
    }

    final batch = _firestore.batch();
    final now = DateTime.now();

    // Update target user's role
    batch.update(
      _herdRepository.herdMembers(herdId).doc(targetUserId),
      {
        'role': newRole.name,
        'promotedBy': performedBy,
        'roleChangedAt': Timestamp.fromDate(now),
        'isModerator': newRole.hasAtLeast(HerdRole.moderator),
      },
    );

    final actionId = _firestore.collection('moderationLogs').doc().id;
    final actionType = newRole.level > currentRole.level
        ? _getPromotionActionType(newRole)
        : _getDemotionActionType(currentRole);

    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: performedBy,
        timestamp: now,
        actionType: actionType,
        targetId: targetUserId,
        targetType: ModTargetType.user,
        metadata: {
          'herdId': herdId,
          'previousRole': currentRole.name,
          'newRole': newRole.name,
        },
      ).toMap(),
    );

    // Handle ownership transfer: demote current owner to admin
    if (newRole == HerdRole.owner) {
      // Demote the current owner (performer) to admin
      batch.update(
        _herdRepository.herdMembers(herdId).doc(performedBy),
        {
          'role': HerdRole.admin.name,
          'roleChangedAt': Timestamp.fromDate(now),
          'isModerator': true,
        },
      );

      // Update herd document with new owner
      batch.update(
        _firestore.collection('herds').doc(herdId),
        {
          'creatorId': targetUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      // Log the demotion of the previous owner
      final demotionActionId = _firestore.collection('moderationLogs').doc().id;
      batch.set(
        _firestore
            .collection('moderationLogs')
            .doc(herdId)
            .collection('actions')
            .doc(demotionActionId),
        ModerationAction(
          actionId: demotionActionId,
          performedBy: performedBy,
          timestamp: now,
          actionType: ModActionType.removeAdmin,
          targetId: performedBy,
          targetType: ModTargetType.user,
          reason: 'Automatically demoted to admin after transferring ownership',
          metadata: {
            'herdId': herdId,
            'previousRole': HerdRole.owner.name,
            'newRole': HerdRole.admin.name,
            'relatedAction': 'ownershipTransfer',
            'newOwnerId': targetUserId,
          },
        ).toMap(),
      );
    }

    // Update moderatorIds array for backward compatibility
    if (newRole.hasAtLeast(HerdRole.moderator)) {
      batch.update(
        _firestore.collection('herds').doc(herdId),
        {
          'moderatorIds': FieldValue.arrayUnion([targetUserId]),
        },
      );
    } else if (currentRole.hasAtLeast(HerdRole.moderator)) {
      batch.update(
        _firestore.collection('herds').doc(herdId),
        {
          'moderatorIds': FieldValue.arrayRemove([targetUserId]),
        },
      );
    }

    await batch.commit();
  }

  ModActionType _getPromotionActionType(HerdRole newRole) {
    switch (newRole) {
      case HerdRole.moderator:
        return ModActionType.addModerator;
      case HerdRole.admin:
        return ModActionType.addAdmin;
      case HerdRole.owner:
        return ModActionType.transferOwnership;
      default:
        return ModActionType.unknown;
    }
  }

  ModActionType _getDemotionActionType(HerdRole oldRole) {
    switch (oldRole) {
      case HerdRole.moderator:
        return ModActionType.removeModerator;
      case HerdRole.admin:
        return ModActionType.removeAdmin;
      default:
        return ModActionType.unknown;
    }
  }
}
