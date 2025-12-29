import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/community/moderation/data/models/moderation_action_model.dart';
import '../models/report_model.dart';
import '../../../herds/data/models/herd_model.dart';
import '../../../herds/data/models/suspended_user_info.dart';
import '../../../herds/data/repositories/herd_repository.dart';

class ModerationRepository {
  final FirebaseFirestore _firestore;
  final HerdRepository _herdRepository;

  ModerationRepository(this._firestore, this._herdRepository);
  Future<void> _appendModerationAction(
      String herdId, ModerationAction action) async {
    await _firestore
        .collection('moderationLogs')
        .doc(herdId)
        .collection('actions')
        .doc(action.actionId)
        .set(action.toMap());
  }

  // === User Moderation ===

  Future<void> banUserFromHerd({
    required String herdId,
    required String userId,
    required String moderatorId,
    String? reason,
  }) async {
    try {
      // Create moderation action
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.banUser,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason,
        metadata: {'herdId': herdId},
      );

      // Update herd document
      await _firestore.collection('herds').doc(herdId).update({
        'bannedUserIds': FieldValue.arrayUnion([userId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Append to moderation log collection
      await _appendModerationAction(herdId, action);

      // Remove user from members
      await _herdRepository.leaveHerd(herdId, userId);

      debugPrint('User $userId banned from herd $herdId');
    } catch (e) {
      debugPrint('Error banning user: $e');
      rethrow;
    }
  }

  Future<void> unbanUserFromHerd({
    required String herdId,
    required String userId,
    required String moderatorId,
    String? reason,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.unbanUser,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason,
        metadata: {'herdId': herdId},
      );

      await _firestore.collection('herds').doc(herdId).update({
        'bannedUserIds': FieldValue.arrayRemove([userId]),
      });

      await _appendModerationAction(herdId, action);

      debugPrint('User $userId unbanned from herd $herdId');
    } catch (e) {
      debugPrint('Error unbanning user: $e');
      rethrow;
    }
  }

  Future<void> suspendUserFromHerd({
    required String herdId,
    required String userId,
    required String moderatorId,
    required DateTime suspendedUntil,
    String? reason,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.suspendUser,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason,
        metadata: {
          'herdId': herdId,
          'suspendedUntil': suspendedUntil.toIso8601String(),
        },
      );

      // Append to moderation log collection
      await _appendModerationAction(herdId, action);

      // Create suspension document
      await _firestore
          .collection('herdSuspensions')
          .doc(herdId)
          .collection('suspended')
          .doc(userId)
          .set({
        'suspendedAt': FieldValue.serverTimestamp(),
        'suspendedUntil': Timestamp.fromDate(suspendedUntil),
        'suspendedBy': moderatorId,
        'reason': reason,
        'isActive': true,
      });

      debugPrint(
          'User $userId suspended from herd $herdId until $suspendedUntil');
    } catch (e) {
      debugPrint('Error suspending user: $e');
      rethrow;
    }
  }

  Future<void> unsuspendUserFromHerd({
    required String herdId,
    required String userId,
    required String moderatorId,
    String? reason,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.unsuspendUser,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason,
        metadata: {'herdId': herdId},
      );

      await _appendModerationAction(herdId, action);

      // Mark suspension as inactive
      await _firestore
          .collection('herdSuspensions')
          .doc(herdId)
          .collection('suspended')
          .doc(userId)
          .update({
        'isActive': false,
        'unsuspendedAt': FieldValue.serverTimestamp(),
        'unsuspendedBy': moderatorId,
      });

      debugPrint('User $userId unsuspended from herd $herdId');
    } catch (e) {
      debugPrint('Error unsuspending user: $e');
      rethrow;
    }
  }

  Future<void> removeMemberFromHerd({
    required String herdId,
    required String userId,
    required String moderatorId,
    String? reason,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.removeMemberFromHerd,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason,
        metadata: {'herdId': herdId},
      );

      await _appendModerationAction(herdId, action);

      // Remove user from herd members
      await _herdRepository.leaveHerd(herdId, userId);

      debugPrint('User $userId removed from herd $herdId by moderator');
    } catch (e) {
      debugPrint('Error removing member from herd: $e');
      rethrow;
    }
  }

  // === Post Moderation ===

  Future<void> pinPost({
    required String herdId,
    required String postId,
    required String moderatorId,
  }) async {
    try {
      final herdDoc = await _firestore.collection('herds').doc(herdId).get();
      final herd = HerdModel.fromMap(herdDoc.id, herdDoc.data()!);

      if (!herd.canPinMorePosts()) {
        throw Exception('Maximum pinned posts reached (5)');
      }

      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.pinPost,
        targetId: postId,
        targetType: ModTargetType.post,
        metadata: {'herdId': herdId},
      );

      await _firestore.collection('herds').doc(herdId).update({
        'pinnedPosts': FieldValue.arrayUnion([postId]),
      });

      await _appendModerationAction(herdId, action);

      // Update the post to mark it as pinned
      await _updatePostPinStatus(herdId, postId, true);
    } catch (e) {
      debugPrint('Error pinning post: $e');
      rethrow;
    }
  }

  Future<void> unpinPost({
    required String herdId,
    required String postId,
    required String moderatorId,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.unpinPost,
        targetId: postId,
        targetType: ModTargetType.post,
        metadata: {'herdId': herdId},
      );

      await _firestore.collection('herds').doc(herdId).update({
        'pinnedPosts': FieldValue.arrayRemove([postId]),
      });

      await _appendModerationAction(herdId, action);

      await _updatePostPinStatus(herdId, postId, false);
    } catch (e) {
      debugPrint('Error unpinning post: $e');
      rethrow;
    }
  }

  Future<void> removePost({
    required String herdId,
    required String postId,
    required String moderatorId,
    String? reason,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: moderatorId,
        timestamp: DateTime.now(),
        actionType: ModActionType.removePost,
        targetId: postId,
        targetType: ModTargetType.post,
        reason: reason,
        metadata: {'herdId': herdId},
      );

      await _appendModerationAction(herdId, action);

      // Mark post as removed (don't delete, just hide)
      await _firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId)
          .update({
        'isRemoved': true,
        'removedBy': moderatorId,
        'removedAt': FieldValue.serverTimestamp(),
        'removalReason': reason,
      });
    } catch (e) {
      debugPrint('Error removing post: $e');
      rethrow;
    }
  }

  // === Moderator Management ===

  Future<void> addModerator({
    required String herdId,
    required String userId,
    required String addedBy,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: addedBy,
        timestamp: DateTime.now(),
        actionType: ModActionType.addModerator,
        targetId: userId,
        targetType: ModTargetType.user,
        metadata: {'herdId': herdId},
      );

      await _herdRepository.addModerator(herdId, userId, addedBy);

      await _appendModerationAction(herdId, action);
    } catch (e) {
      debugPrint('Error adding moderator: $e');
      rethrow;
    }
  }

  Future<void> removeModerator({
    required String herdId,
    required String userId,
    required String removedBy,
  }) async {
    try {
      final actionId = _firestore.collection('dummy').doc().id;
      final action = ModerationAction(
        actionId: actionId,
        performedBy: removedBy,
        timestamp: DateTime.now(),
        actionType: ModActionType.removeModerator,
        targetId: userId,
        targetType: ModTargetType.user,
        metadata: {'herdId': herdId},
      );

      await _herdRepository.removeModerator(herdId, userId, removedBy);

      await _appendModerationAction(herdId, action);
    } catch (e) {
      debugPrint('Error removing moderator: $e');
      rethrow;
    }
  }

  // === Report Management ===

  Future<void> reportContent({
    required String reportedBy,
    required String targetId,
    required ReportTargetType targetType,
    required ReportReason reason,
    String? description,
    String? herdId,
  }) async {
    try {
      final reportId = _firestore.collection('reports').doc().id;
      final report = ReportModel(
        reportId: reportId,
        reportedBy: reportedBy,
        timestamp: DateTime.now(),
        targetId: targetId,
        targetType: targetType,
        reason: reason,
        description: description,
        status: ReportStatus.pending,
        metadata: herdId != null ? {'herdId': herdId} : null,
      );

      // Add to reports collection
      await _firestore.collection('reports').doc(reportId).set(report.toMap());

      // If it's a herd post, add to herd's reported posts
      if (herdId != null && targetType == ReportTargetType.post) {
        await _firestore.collection('herds').doc(herdId).update({
          'reportedPosts': FieldValue.arrayUnion([targetId]),
        });
      }
    } catch (e) {
      debugPrint('Error reporting content: $e');
      rethrow;
    }
  }

  // === Query Methods ===

  Stream<List<ModerationAction>> streamModerationLog(String herdId) {
    return _firestore
        .collection('moderationLogs')
        .doc(herdId)
        .collection('actions')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((d) => ModerationAction.fromMap(d.data()))
            .toList());
  }

  Future<List<ReportModel>> getPendingReports(String herdId) async {
    try {
      final snapshot = await _firestore
          .collection('reports')
          .where('metadata.herdId', isEqualTo: herdId)
          .where('status', isEqualTo: ReportStatus.pending.name)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ReportModel.fromMap(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting pending reports: $e');
      return [];
    }
  }

  // === Helper Methods ===

  Future<void> _updatePostPinStatus(
      String herdId, String postId, bool isPinned) async {
    try {
      await _firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId)
          .update({
        'isPinnedToHerd': isPinned,
        'pinnedAt': isPinned ? FieldValue.serverTimestamp() : null,
      });
    } catch (e) {
      debugPrint('Error updating post pin status: $e');
    }
  }

  Future<bool> isUserBanned(String herdId, String userId) async {
    try {
      final herdDoc = await _firestore.collection('herds').doc(herdId).get();
      if (!herdDoc.exists) return false;

      final bannedUsers =
          List<String>.from(herdDoc.data()!['bannedUserIds'] ?? []);
      return bannedUsers.contains(userId);
    } catch (e) {
      debugPrint('Error checking ban status: $e');
      return false;
    }
  }

  Future<bool> isUserSuspended(String herdId, String userId) async {
    try {
      final suspensionDoc = await _firestore
          .collection('herdSuspensions')
          .doc(herdId)
          .collection('suspended')
          .doc(userId)
          .get();

      if (!suspensionDoc.exists) return false;

      final data = suspensionDoc.data()!;
      final isActive = data['isActive'] ?? false;
      final suspendedUntil = (data['suspendedUntil'] as Timestamp).toDate();

      return isActive && DateTime.now().isBefore(suspendedUntil);
    } catch (e) {
      debugPrint('Error checking suspension status: $e');
      return false;
    }
  }

  Future<List<SuspendedUserInfo>> getSuspendedUsers(String herdId) async {
    try {
      final snapshot = await _firestore
          .collection('herdSuspensions')
          .doc(herdId)
          .collection('suspended')
          .where('isActive', isEqualTo: true)
          .orderBy('suspendedAt', descending: true)
          .get();

      List<SuspendedUserInfo> suspendedUsers = [];

      for (final doc in snapshot.docs) {
        try {
          final userId = doc.id;
          final suspensionData = doc.data();

          // Get user data
          final userDoc =
              await _firestore.collection('users').doc(userId).get();
          if (!userDoc.exists) continue;

          final userData = userDoc.data()!;

          // Get moderator username if available
          final moderatorId = suspensionData['suspendedBy'];
          String? moderatorUsername;
          if (moderatorId != null) {
            final modDoc =
                await _firestore.collection('users').doc(moderatorId).get();
            if (modDoc.exists) {
              moderatorUsername = modDoc.data()!['username'];
            }
          }

          final suspendedUser = SuspendedUserInfo.fromMap(
            userId: userId,
            userData: userData,
            suspensionData: suspensionData,
            suspendedByUsername: moderatorUsername,
          );

          // Only include if still suspended
          if (suspendedUser.isCurrentlySuspended) {
            suspendedUsers.add(suspendedUser);
          }
        } catch (e) {
          debugPrint('Error processing suspended user ${doc.id}: $e');
          continue;
        }
      }

      return suspendedUsers;
    } catch (e) {
      debugPrint('Error getting suspended users: $e');
      return [];
    }
  }
}
