import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/exception_logging_service.dart';
import 'package:herdapp/features/user/user_profile/data/models/alt_connection_request_model.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

final altProfileRepositoryProvider = Provider<AltProfileRepository>((ref) {
  return AltProfileRepository(FirebaseFirestore.instance);
});

class AltProfileRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ExceptionLoggerService _logger = ExceptionLoggerService();

  AltProfileRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // Helper to get user by ID (needed internally)
  Future<UserModel?> _getUserById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  Future<String> uploadAltImage({
    required String userId,
    required File file,
    required String type,
  }) async {
    final ref = _storage.ref().child('users/$userId/alt/$type');
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> requestAltConnection(String userId, String targetUserId) async {
    try {
      // Get requester information to include in the request
      final requester = await _getUserById(userId);
      if (requester == null) {
        throw Exception('Requester not found');
      }

      // Create a connection request document
      await _firestore
          .collection('altConnectionRequests')
          .doc(targetUserId)
          .collection('requests')
          .doc(userId)
          .set({
        'requesterId': userId,
        'requesterName': '${requester.firstName} ${requester.lastName}'.trim(),
        'requesterUsername': requester.username,
        'requesterProfileImageURL':
            requester.altProfileImageURL ?? requester.profileImageURL,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending'
      });
    } catch (e) {
      debugPrint('Error requesting alt connection: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'requestAltConnection',
        route: 'AltProfileRepository',
        userId: userId,
        errorDetails: {'targetUserId': targetUserId},
      );
      rethrow;
    }
  }

  // Accept a alt connection request
  Future<void> acceptAltConnection(String userId, String requesterId) async {
    try {
      // Add to alt connections (bidirectional)
      await _firestore
          .collection('altConnections')
          .doc(userId)
          .collection('userConnections')
          .doc(requesterId)
          .set({'timestamp': FieldValue.serverTimestamp()});

      await _firestore
          .collection('altConnections')
          .doc(requesterId)
          .collection('userConnections')
          .doc(userId)
          .set({'timestamp': FieldValue.serverTimestamp()});

      // Update the request status
      await _firestore
          .collection('altConnectionRequests')
          .doc(userId)
          .collection('requests')
          .doc(requesterId)
          .update({'status': 'accepted'});

      // Update connection counts for both users
      await _firestore
          .collection('users')
          .doc(userId)
          .update({'altFriends': FieldValue.increment(1)});

      await _firestore
          .collection('users')
          .doc(requesterId)
          .update({'altFriends': FieldValue.increment(1)});
    } catch (e) {
      debugPrint('Error accepting alt connection: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'acceptAltConnection',
        route: 'AltProfileRepository',
        userId: userId,
        errorDetails: {'requesterId': requesterId},
      );
      rethrow;
    }
  }

  // Reject a alt connection request
  Future<void> rejectAltConnection(String userId, String requesterId) async {
    try {
      await _firestore
          .collection('altConnectionRequests')
          .doc(userId)
          .collection('requests')
          .doc(requesterId)
          .update({'status': 'rejected'});
    } catch (e) {
      debugPrint('Error rejecting alt connection: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'rejectAltConnection',
        route: 'AltProfileRepository',
        userId: userId,
        errorDetails: {'requesterId': requesterId},
      );
      rethrow;
    }
  }

  // Get all pending alt connection requests for a user
  Stream<List<AltConnectionRequest>> getPendingConnectionRequests(
      String userId) {
    return _firestore
        .collection('altConnectionRequests')
        .doc(userId)
        .collection('requests')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return AltConnectionRequest.fromMap(doc.data());
            }).toList());
  }

  // Check if a alt connection request already exists
  Future<bool> hasAltConnectionRequest(
      String requesterId, String targetUserId) async {
    try {
      final doc = await _firestore
          .collection('altConnectionRequests')
          .doc(targetUserId)
          .collection('requests')
          .doc(requesterId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking alt connection request: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'hasAltConnectionRequest',
        route: 'AltProfileRepository',
        userId: requesterId,
        errorDetails: {'targetUserId': targetUserId},
      );
      return false;
    }
  }

  // Check if users are already altly connected
  Future<bool> areAltlyConnected(String userId1, String userId2) async {
    try {
      final doc = await _firestore
          .collection('altConnections')
          .doc(userId1)
          .collection('userConnections')
          .doc(userId2)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking alt connection: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'areAltlyConnected',
        route: 'AltProfileRepository',
        userId: userId1,
        errorDetails: {'otherUserId': userId2},
      );
      return false;
    }
  }

  // Get all alt connections for a user
  Stream<List<String>> getAltConnectionIds(String userId) {
    return _firestore
        .collection('altConnections')
        .doc(userId)
        .collection('userConnections')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  Future<int> getAltConnectionCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('altConnections')
          .doc(userId)
          .collection('userConnections')
          .count()
          .get();

      return snapshot.count ?? 0;
    } catch (e) {
      debugPrint('Error getting alt connection count: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getAltConnectionCount',
        route: 'AltProfileRepository',
        userId: userId,
      );
      return 0;
    }
  }

  // Check if alt profile exists
  Future<bool> hasAltProfile(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return false;

    final data = doc.data()!;
    return data['altBio'] != null ||
        data['altProfileImageURL'] != null ||
        data['altCoverImageURL'] != null;
  }

  // Create or update alt profile
  Future<void> updateAltProfile(
      String userId, Map<String, dynamic> altData) async {
    final Map<String, dynamic> sanitizedData = {};

    // Explicitly handle known alt fields
    if (altData.containsKey('altBio')) {
      sanitizedData['altBio'] = altData['altBio'];
    }

    if (altData.containsKey('altProfileImageURL')) {
      sanitizedData['altProfileImageURL'] = altData['altProfileImageURL'];
    }

    if (altData.containsKey('altCoverImageURL')) {
      sanitizedData['altCoverImageURL'] = altData['altCoverImageURL'];
    }

    await _users.doc(userId).update({
      ...altData,
      'altUpdatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Add alt connection
  Future<void> addAltConnection(String userId, String connectionId) async {
    // Add to alt connections collection
    await _firestore
        .collection('altConnections')
        .doc(userId)
        .collection('userConnections')
        .doc(connectionId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update counts
    await _users.doc(userId).update({'altFriends': FieldValue.increment(1)});
  }

  // Remove alt connection
  Future<void> removeAltConnection(String userId, String connectionId) async {
    await _firestore
        .collection('altConnections')
        .doc(userId)
        .collection('userConnections')
        .doc(connectionId)
        .delete();

    // Update counts
    await _users.doc(userId).update({'altFriends': FieldValue.increment(-1)});
  }

  // Check if users are altly connected
  Future<bool> isAltlyConnected(String userId, String otherUserId) async {
    final doc = await _firestore
        .collection('altConnections')
        .doc(userId)
        .collection('userConnections')
        .doc(otherUserId)
        .get();

    return doc.exists;
  }
}
