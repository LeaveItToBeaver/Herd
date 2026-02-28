import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/exception_logging_service.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

final accountManagementRepositoryProvider =
    Provider<AccountManagementRepository>((ref) {
  return AccountManagementRepository(FirebaseFirestore.instance);
});

class AccountManagementRepository {
  final FirebaseFirestore _firestore;
  final ExceptionLoggerService _logger = ExceptionLoggerService();

  AccountManagementRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _following =>
      _firestore.collection('following');
  CollectionReference<Map<String, dynamic>> get _followers =>
      _firestore.collection('followers');

  // Helper to get user by ID (needed internally)
  Future<UserModel?> _getUserById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  // Helper to update user fields
  Future<void> _updateUser(String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Mark user account for deletion
  Future<void> markAccountForDeletion(String userId) async {
    try {
      await _updateUser(userId, {
        'markedForDeleteAt': FieldValue.serverTimestamp(),
        'accountStatus': 'marked_for_deletion',
        'altAccountStatus': 'marked_for_deletion',
        'isActive': false,
        'altIsActive': false,
      });
    } catch (e) {
      debugPrint('Error marking account for deletion: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'markAccountForDeletion',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      rethrow;
    }
  }

  /// Cancel account deletion (restore account within 30-day period)
  Future<void> cancelAccountDeletion(String userId) async {
    try {
      await _updateUser(userId, {
        'markedForDeleteAt': null,
        'accountStatus': 'active',
        'altAccountStatus': 'active',
        'isActive': true,
        'altIsActive': true,
      });
    } catch (e) {
      debugPrint('Error canceling account deletion: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'cancelAccountDeletion',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      rethrow;
    }
  }

  /// Check if account is marked for deletion
  Future<bool> isAccountMarkedForDeletion(String userId) async {
    try {
      final user = await _getUserById(userId);
      return user?.isMarkedForDeletion ?? false;
    } catch (e) {
      debugPrint('Error checking account deletion status: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'isAccountMarkedForDeletion',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return false;
    }
  }

  /// Get deletion date for account (when it will be permanently deleted)
  Future<DateTime?> getAccountDeletionDate(String userId) async {
    try {
      final user = await _getUserById(userId);
      return user?.permanentDeletionDate;
    } catch (e) {
      debugPrint('Error getting account deletion date: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getAccountDeletionDate',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return null;
    }
  }

  /// Get days remaining until permanent deletion
  Future<int?> getDaysUntilPermanentDeletion(String userId) async {
    try {
      final user = await _getUserById(userId);
      return user?.daysUntilDeletion;
    } catch (e) {
      debugPrint('Error getting days until deletion: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getDaysUntilPermanentDeletion',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return null;
    }
  }

  /// Request data export for user via Cloud Function
  /// Returns a map with 'success' boolean and 'message' string
  Future<Map<String, dynamic>> requestDataExport(String userId) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('requestDataExport');

      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Request submitted',
        'status': data['status'],
        'requestedAt': data['requestedAt'],
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'Firebase Functions error requesting data export: ${e.code} - ${e.message}');
      _logger.logException(
        errorMessage: '${e.code}: ${e.message}',
        stackTrace: StackTrace.current.toString(),
        action: 'requestDataExport',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return {
        'success': false,
        'message': e.message ?? 'Failed to submit data export request',
      };
    } catch (e) {
      debugPrint('Error requesting data export: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'requestDataExport',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again later.',
      };
    }
  }

  /// Check if user has a pending data export request
  Future<bool> hasPendingDataExport(String userId) async {
    try {
      final doc =
          await _firestore.collection('dataExportRequests').doc(userId).get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      return data['status'] == 'pending' || data['status'] == 'processing';
    } catch (e) {
      debugPrint('Error checking data export status: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'hasPendingDataExport',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return false;
    }
  }

  /// Get detailed data export status via Cloud Function
  Future<Map<String, dynamic>> getDataExportStatus(String userId) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('getDataExportStatus');

      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      return {
        'hasRequest': data['hasRequest'] ?? false,
        'status': data['status'],
        'requestedAt': data['requestedAt'],
        'completedAt': data['completedAt'],
        'exportDocId': data['exportDocId'],
        'downloadUrl': data['downloadUrl'],
        'fileSizeBytes': data['fileSizeBytes'],
        'expiresAt': data['expiresAt'],
        'isExpired': data['isExpired'] ?? false,
        'downloaded': data['downloaded'] ?? false,
        'downloadedAt': data['downloadedAt'],
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'Firebase Functions error getting data export status: ${e.code} - ${e.message}');
      _logger.logException(
        errorMessage: '${e.code}: ${e.message}',
        stackTrace: StackTrace.current.toString(),
        action: 'getDataExportStatus',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return {
        'hasRequest': false,
        'error': e.message,
      };
    } catch (e) {
      debugPrint('Error getting data export status: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getDataExportStatus',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return {
        'hasRequest': false,
        'error': e.toString(),
      };
    }
  }

  /// Reset a stuck data export request
  Future<Map<String, dynamic>> resetDataExportRequest(String userId) async {
    try {
      final functions = FirebaseFunctions.instance;
      final callable = functions.httpsCallable('resetDataExportRequest');

      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;

      return {
        'success': data['success'] ?? false,
        'message': data['message'] ?? 'Request reset',
      };
    } on FirebaseFunctionsException catch (e) {
      debugPrint(
          'Firebase Functions error resetting data export: ${e.code} - ${e.message}');
      _logger.logException(
        errorMessage: '${e.code}: ${e.message}',
        stackTrace: StackTrace.current.toString(),
        action: 'resetDataExportRequest',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return {
        'success': false,
        'message': e.message ?? 'Failed to reset data export request',
      };
    } catch (e) {
      debugPrint('Error resetting data export request: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'resetDataExportRequest',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }

  /// Get user's complete data for export (this would be used by admin/backend processes)
  Future<Map<String, dynamic>> getUserExportData(String userId) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) throw Exception('User not found');

      // Collect all user data
      final exportData = <String, dynamic>{
        'profile': user.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Note: In a real implementation, you would collect data from all relevant collections:
      // - posts
      // - comments
      // - messages
      // - connections
      // - saved posts
      // - etc.

      return exportData;
    } catch (e) {
      debugPrint('Error getting user export data: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getUserExportData',
        route: 'AccountManagementRepository',
        userId: userId,
      );
      rethrow;
    }
  }

  /// Permanently delete user account and all associated data
  /// This should only be called by automated cleanup processes after 30-day retention period
  Future<void> permanentlyDeleteAccount(String userId) async {
    try {
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_users.doc(userId));

      // Clean up following/followers relationships
      final followingSnapshot =
          await _following.doc(userId).collection('userFollowing').get();
      for (final doc in followingSnapshot.docs) {
        final followedUserId = doc.id;
        batch.delete(_followers
            .doc(followedUserId)
            .collection('userFollowers')
            .doc(userId));
        batch.update(_users.doc(followedUserId),
            {'followers': FieldValue.increment(-1)});
        batch.delete(doc.reference);
      }

      final followersSnapshot =
          await _followers.doc(userId).collection('userFollowers').get();
      for (final doc in followersSnapshot.docs) {
        final followerId = doc.id;
        batch.delete(
            _following.doc(followerId).collection('userFollowing').doc(userId));
        batch.update(
            _users.doc(followerId), {'following': FieldValue.increment(-1)});
        batch.delete(doc.reference);
      }

      // Clean up alt connections
      final altConnectionsSnapshot = await _firestore
          .collection('altConnections')
          .doc(userId)
          .collection('userConnections')
          .get();

      for (final doc in altConnectionsSnapshot.docs) {
        final connectionId = doc.id;
        // Remove this user from other user's connections
        batch.delete(_firestore
            .collection('altConnections')
            .doc(connectionId)
            .collection('userConnections')
            .doc(userId));
        // Update connection count
        batch.update(
            _users.doc(connectionId), {'altFriends': FieldValue.increment(-1)});
        // Delete this user's connection
        batch.delete(doc.reference);
      }

      // Delete connection requests
      batch.delete(_firestore.collection('altConnectionRequests').doc(userId));

      // Delete data export requests
      batch.delete(_firestore.collection('dataExportRequests').doc(userId));

      // TODO: Also delete from other collections:
      // - posts collection
      // - comments collection
      // - messages collection
      // - notifications collection
      // - any other user-related data

      await batch.commit();
    } catch (e) {
      debugPrint('Error permanently deleting account: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'permanentlyDeleteAccount',
        route: 'AccountManagementRepository',
        userId: userId,
      );
    }
  }

  /// Get list of accounts marked for deletion past 30 days (for cleanup jobs)
  Future<List<String>> getAccountsReadyForDeletion() async {
    try {
      final cutoffDate = DateTime.now().subtract(const Duration(days: 30));

      final snapshot = await _users
          .where('markedForDeleteAt',
              isLessThan: Timestamp.fromDate(cutoffDate))
          .where('accountStatus', isEqualTo: 'marked_for_deletion')
          .get();

      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      debugPrint('Error getting accounts ready for deletion: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getAccountsReadyForDeletion',
        route: 'AccountManagementRepository',
      );
      return [];
    }
  }
}
