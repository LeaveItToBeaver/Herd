import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/moderation/data/models/moderation_action_model.dart';
import '../models/report_model.dart';
import '../../../herds/data/models/herd_model.dart';
import '../../../herds/data/repositories/herd_repository.dart';

class ModerationRepository {
  final FirebaseFirestore _firestore;
  final HerdRepository _herdRepository;

  ModerationRepository(this._firestore, this._herdRepository);

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
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });

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
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });

      debugPrint('User $userId unbanned from herd $herdId');
    } catch (e) {
      debugPrint('Error unbanning user: $e');
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
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });

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
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });

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

      // Add to moderation log
      await _firestore.collection('herds').doc(herdId).update({
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });

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

      await _firestore.collection('herds').doc(herdId).update({
        'moderatorIds': FieldValue.arrayUnion([userId]),
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });
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

      await _firestore.collection('herds').doc(herdId).update({
        'moderatorIds': FieldValue.arrayRemove([userId]),
        'moderationLog': FieldValue.arrayUnion([action.toMap()]),
      });
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
        .collection('herds')
        .doc(herdId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return [];
      final data = snapshot.data()!;
      final logs = data['moderationLog'] as List<dynamic>? ?? [];
      return logs
          .map((log) => ModerationAction.fromMap(log as Map<String, dynamic>))
          .toList()
        ..sort(
            (a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
    });
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
}
