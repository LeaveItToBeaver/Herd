import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_block_model.dart';

class UserBlockRepository {
  final FirebaseFirestore _firestore;

  UserBlockRepository(this._firestore);

  /// Get linked profile ID (alt profile ID or public profile ID)
  Future<String?> _getLinkedProfileId(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists && userDoc.data() != null) {
        return userDoc.data()!['altUserUID'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting linked profile ID: $e');
      return null;
    }
  }

  // === Block User ===

  /// Blocks a user by adding them to the current user's blocked list
  /// Also blocks their linked profile (alt/public) if it exists
  Future<void> blockUser({
    required String currentUserId,
    required String blockedUserId,
    String? username,
    String? firstName,
    String? lastName,
    bool reported = false,
    bool isAlt = false,
    String? notes,
  }) async {
    try {
      final userBlock = UserBlockModel(
        userId: blockedUserId,
        createdAt: DateTime.now(),
        isAlt: isAlt,
        username: username,
        firstName: firstName,
        lastName: lastName,
        reported: reported,
        notes: notes,
      );

      // Block the specified user
      await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(blockedUserId)
          .set(userBlock.toMap());

      debugPrint('User $blockedUserId blocked by $currentUserId');

      // Also block their linked profile (alt/public) if it exists
      final linkedProfileId = await _getLinkedProfileId(blockedUserId);
      if (linkedProfileId != null && linkedProfileId != blockedUserId) {
        final linkedUserBlock = UserBlockModel(
          userId: linkedProfileId,
          createdAt: DateTime.now(),
          isAlt: !isAlt, // If blocking alt, linked is public and vice versa
          username: username,
          firstName: firstName,
          lastName: lastName,
          reported: reported,
          notes: notes != null ? '$notes (linked profile)' : 'Blocked via linked profile',
        );

        await _firestore
            .collection('userBlocks')
            .doc(currentUserId)
            .collection('usersBlocked')
            .doc(linkedProfileId)
            .set(linkedUserBlock.toMap());

        debugPrint('Linked profile $linkedProfileId also blocked by $currentUserId');
      }
    } catch (e) {
      debugPrint('Error blocking user: $e');
      rethrow;
    }
  }

  /// Unblocks a user by removing them from the current user's blocked list
  /// Also unblocks their linked profile (alt/public) if it exists
  Future<void> unblockUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    try {
      // Unblock the specified user
      await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(blockedUserId)
          .delete();

      debugPrint('User $blockedUserId unblocked by $currentUserId');

      // Also unblock their linked profile if it exists
      final linkedProfileId = await _getLinkedProfileId(blockedUserId);
      if (linkedProfileId != null && linkedProfileId != blockedUserId) {
        await _firestore
            .collection('userBlocks')
            .doc(currentUserId)
            .collection('usersBlocked')
            .doc(linkedProfileId)
            .delete();

        debugPrint('Linked profile $linkedProfileId also unblocked by $currentUserId');
      }
    } catch (e) {
      debugPrint('Error unblocking user: $e');
      rethrow;
    }
  }

  /// Checks if a user is blocked by the current user
  /// Also checks if their linked profile (alt/public) is blocked
  Future<bool> isUserBlocked({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      // Check if the specific user is blocked
      final doc = await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(targetUserId)
          .get();

      if (doc.exists) {
        return true;
      }

      // Also check if their linked profile is blocked
      final linkedProfileId = await _getLinkedProfileId(targetUserId);
      if (linkedProfileId != null && linkedProfileId != targetUserId) {
        final linkedDoc = await _firestore
            .collection('userBlocks')
            .doc(currentUserId)
            .collection('usersBlocked')
            .doc(linkedProfileId)
            .get();

        return linkedDoc.exists;
      }

      return false;
    } catch (e) {
      debugPrint('Error checking if user is blocked: $e');
      return false;
    }
  }

  /// Gets a specific blocked user's details
  Future<UserBlockModel?> getBlockedUser({
    required String currentUserId,
    required String blockedUserId,
  }) async {
    try {
      final doc = await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(blockedUserId)
          .get();

      if (doc.exists && doc.data() != null) {
        return UserBlockModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting blocked user: $e');
      return null;
    }
  }

  /// Gets all blocked users for the current user
  Future<List<UserBlockModel>> getBlockedUsers({
    required String currentUserId,
    int? limit,
  }) async {
    try {
      Query query = _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs
          .map((doc) =>
              UserBlockModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error getting blocked users: $e');
      return [];
    }
  }

  /// Stream of blocked users for real-time updates
  Stream<List<UserBlockModel>> streamBlockedUsers({
    required String currentUserId,
    int? limit,
  }) {
    try {
      Query query = _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .orderBy('createdAt', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map((snapshot) => snapshot.docs
          .map((doc) =>
              UserBlockModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
    } catch (e) {
      debugPrint('Error streaming blocked users: $e');
      return Stream.value([]);
    }
  }

  /// Updates notes for a blocked user
  Future<void> updateBlockNotes({
    required String currentUserId,
    required String blockedUserId,
    String? notes,
  }) async {
    try {
      await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(blockedUserId)
          .update({'notes': notes});

      debugPrint('Updated notes for blocked user $blockedUserId');
    } catch (e) {
      debugPrint('Error updating block notes: $e');
      rethrow;
    }
  }

  /// Marks a blocked user as reported/unreported
  Future<void> updateBlockReportedStatus({
    required String currentUserId,
    required String blockedUserId,
    required bool reported,
  }) async {
    try {
      await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(blockedUserId)
          .update({'reported': reported});

      debugPrint(
          'Updated reported status for blocked user $blockedUserId to $reported');
    } catch (e) {
      debugPrint('Error updating block reported status: $e');
      rethrow;
    }
  }

  /// Marks a blocked user as alt/not alt
  Future<void> updateBlockAltStatus({
    required String currentUserId,
    required String blockedUserId,
    required bool isAlt,
  }) async {
    try {
      await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .doc(blockedUserId)
          .update({'isAlt': isAlt});

      debugPrint(
          'Updated alt status for blocked user $blockedUserId to $isAlt');
    } catch (e) {
      debugPrint('Error updating block alt status: $e');
      rethrow;
    }
  }

  /// Gets count of blocked users for the current user
  Future<int> getBlockedUsersCount({
    required String currentUserId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection('userBlocks')
          .doc(currentUserId)
          .collection('usersBlocked')
          .count()
          .get();

      return querySnapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting blocked users count: $e');
      return 0;
    }
  }

  /// Batch operation to block multiple users at once
  Future<void> blockMultipleUsers({
    required String currentUserId,
    required List<UserBlockModel> blockedUsers,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final userBlock in blockedUsers) {
        final docRef = _firestore
            .collection('userBlocks')
            .doc(currentUserId)
            .collection('usersBlocked')
            .doc(userBlock.userId);

        batch.set(docRef, userBlock.toMap());
      }

      await batch.commit();
      debugPrint('Blocked ${blockedUsers.length} users in batch operation');
    } catch (e) {
      debugPrint('Error in batch block operation: $e');
      rethrow;
    }
  }

  /// Batch operation to unblock multiple users at once
  Future<void> unblockMultipleUsers({
    required String currentUserId,
    required List<String> blockedUserIds,
  }) async {
    try {
      final batch = _firestore.batch();

      for (final blockedUserId in blockedUserIds) {
        final docRef = _firestore
            .collection('userBlocks')
            .doc(currentUserId)
            .collection('usersBlocked')
            .doc(blockedUserId);

        batch.delete(docRef);
      }

      await batch.commit();
      debugPrint('Unblocked ${blockedUserIds.length} users in batch operation');
    } catch (e) {
      debugPrint('Error in batch unblock operation: $e');
      rethrow;
    }
  }
}
