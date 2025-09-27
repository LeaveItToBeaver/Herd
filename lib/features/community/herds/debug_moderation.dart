import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Debug utility to help troubleshoot moderation permissions
class ModerationDebugger {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Debug helper to check user permissions for a herd
  static Future<Map<String, dynamic>> checkUserPermissions(
      String herdId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return {'error': 'User not authenticated'};
    }

    final userId = currentUser.uid;
    debugPrint('Debugging permissions for user: $userId, herd: $herdId');

    try {
      // Check herd document
      final herdDoc = await _firestore.collection('herds').doc(herdId).get();
      if (!herdDoc.exists) {
        return {'error': 'Herd document not found'};
      }

      final herdData = herdDoc.data()!;
      final creatorId = herdData['creatorId'];
      final moderatorIds = List<String>.from(herdData['moderatorIds'] ?? []);
      final isCreator = creatorId == userId;
      final isModerator = moderatorIds.contains(userId);

      debugPrint('Herd Creator: $creatorId');
      debugPrint('Moderators: $moderatorIds');
      debugPrint('Current User: $userId');
      debugPrint('Is Creator: $isCreator');
      debugPrint('Is Moderator: $isModerator');

      // Check herd member document
      Map<String, dynamic>? memberData;
      final memberDoc = await _firestore
          .collection('herdMembers')
          .doc(herdId)
          .collection('members')
          .doc(userId)
          .get();

      if (memberDoc.exists) {
        memberData = memberDoc.data();
        debugPrint('Member Document: $memberData');
      } else {
        debugPrint('Member Document: Not found');
      }

      // Test banned users access
      bool canAccessBannedUsers = false;
      String? bannedUsersError;
      try {
        debugPrint('Testing banned users access...');
        final bannedQuery = await _firestore
            .collection('herdBans')
            .doc(herdId)
            .collection('banned')
            .limit(1)
            .get();
        canAccessBannedUsers = true;
        debugPrint(
            'Can access banned users - found ${bannedQuery.docs.length} documents');
      } catch (e) {
        bannedUsersError = e.toString();
        debugPrint('Cannot access banned users: $e');
      }

      // Test direct herdBans document access
      bool canAccessHerdBansDoc = false;
      String? herdBansDocError;
      try {
        debugPrint('Testing herdBans document access...');
        final herdBansDoc =
            await _firestore.collection('herdBans').doc(herdId).get();
        canAccessHerdBansDoc = true;
        debugPrint(
            'Can access herdBans document - exists: ${herdBansDoc.exists}');
      } catch (e) {
        herdBansDocError = e.toString();
        debugPrint('annot access herdBans document: $e');
      }

      return {
        'userId': userId,
        'herdId': herdId,
        'creatorId': creatorId,
        'moderatorIds': moderatorIds,
        'isCreator': isCreator,
        'isModerator': isModerator,
        'memberData': memberData,
        'canAccessBannedUsers': canAccessBannedUsers,
        'bannedUsersError': bannedUsersError,
        'canAccessHerdBansDoc': canAccessHerdBansDoc,
        'herdBansDocError': herdBansDocError,
      };
    } catch (e) {
      debugPrint('Error during permission check: $e');
      return {'error': e.toString()};
    }
  }

  /// Print debug info to console
  static Future<void> printDebugInfo(String herdId) async {
    final info = await checkUserPermissions(herdId);
    debugPrint('=== MODERATION DEBUG INFO ===');
    info.forEach((key, value) {
      debugPrint('$key: $value');
    });
    debugPrint('=============================');
  }

  /// Manual test of specific Firebase rules logic
  static Future<void> testSpecificPermissions(String herdId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      debugPrint('No authenticated user');
      return;
    }

    debugPrint('Testing specific permission logic...');

    try {
      // Test 1: Check if user is creator
      final herdDoc = await _firestore.collection('herds').doc(herdId).get();
      if (herdDoc.exists) {
        final isCreator = herdDoc.data()?['creatorId'] == currentUser.uid;
        debugPrint('🔑 Creator check: $isCreator');

        // Test 2: Check member document
        final memberDoc = await _firestore
            .collection('herdMembers')
            .doc(herdId)
            .collection('members')
            .doc(currentUser.uid)
            .get();

        if (memberDoc.exists) {
          final isModerator = memberDoc.data()?['isModerator'] == true;
          debugPrint('Moderator check: $isModerator');
          debugPrint('Member data: ${memberDoc.data()}');
        }

        // Test 3: Should have access based on creator OR moderator
        final shouldHaveAccess = isCreator ||
            (memberDoc.exists && memberDoc.data()?['isModerator'] == true);
        debugPrint('Should have access: $shouldHaveAccess');
      }
    } catch (e) {
      debugPrint('Error testing permissions: $e');
    }
  }
}
