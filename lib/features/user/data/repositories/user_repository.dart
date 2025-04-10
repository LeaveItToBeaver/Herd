import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/alt_connection_request_model.dart';
import '../models/user_model.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  UserRepository(this._firestore);

  // Collection references
  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _following =>
      _firestore.collection('following');
  CollectionReference<Map<String, dynamic>> get _followers =>
      _firestore.collection('followers');

  // Create new user
  Future<void> createUser(String userId, UserModel user) async {
    await _users.doc(userId).set(user.toMap());
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  // Search users
// Search users
  Future<List<UserModel>> searchUsers(String query) async {
    // Try both lowercase and original casing
    final lowerQuery = query.toLowerCase();
    final capitalQuery = query.length > 0
        ? query[0].toUpperCase() + query.substring(1).toLowerCase()
        : "";

    // Try searching with lowercase
    final userSnapLower = await _users
        .where('username', isGreaterThanOrEqualTo: lowerQuery)
        .where('username', isLessThan: '$lowerQuery\uf8ff')
        .limit(10)
        .get();

    // Try searching with capitalized first letter
    final userSnapCapital = await _users
        .where('username', isGreaterThanOrEqualTo: capitalQuery)
        .where('username', isLessThan: '$capitalQuery\uf8ff')
        .limit(10)
        .get();

    // Combine results
    final allDocs = [...userSnapLower.docs, ...userSnapCapital.docs];
    final uniqueDocsMap =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    // Properly type the documents to ensure we're working with Map<String, dynamic>
    for (var doc in allDocs) {
      if (!uniqueDocsMap.containsKey(doc.id)) {
        uniqueDocsMap[doc.id] = doc;
      }
    }

    final uniqueDocs = uniqueDocsMap.values.toList();

    return uniqueDocs
        .map((doc) => UserModel.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Username availability check
  Future<bool> isUsernameAvailable(String username) async {
    final QuerySnapshot result = await _users
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    return result.docs.isEmpty;
  }

  // Get user by username
  Future<UserModel?> getUserByUsername(String username) async {
    final query = await _users
        .where('username', isEqualTo: username.toLowerCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) return null;
    final doc = query.docs.first;
    return UserModel.fromMap(doc.id, doc.data());
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    // Existing code - this should be fine as it just updates the fields provided in the data map
    await _users.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String> uploadImage({
    required String userId,
    required File file,
    required String type,
  }) async {
    final ref = _storage.ref().child('users/$userId/$type.jpg');
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    // Delete user document
    await _users.doc(userId).delete();

    // Clean up following/followers
    await _following.doc(userId).collection('userFollowing').get().then(
        (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()));

    await _following.doc(userId).collection('userFollowing').get().then(
        (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()));

    await _followers.doc(userId).collection('userFollowers').get().then(
        (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete()));
  }

  // Follow user
  Future<void> followUser(String userId, String followUserId) async {
    // Add followUser to user's following
    await _following
        .doc(userId)
        .collection('userFollowing')
        .doc(followUserId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Add user to followUser's followers
    await _followers
        .doc(followUserId)
        .collection('userFollowers')
        .doc(userId)
        .set({
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Update follower/following counts
    await _users.doc(userId).update({'following': FieldValue.increment(1)});
    await _users
        .doc(followUserId)
        .update({'followers': FieldValue.increment(1)});
  }

  // Unfollow user
  Future<void> unfollowUser(String userId, String unfollowUserId) async {
    // Remove from following
    await _following
        .doc(userId)
        .collection('userFollowing')
        .doc(unfollowUserId)
        .delete();

    // Remove from followers
    await _followers
        .doc(unfollowUserId)
        .collection('userFollowers')
        .doc(userId)
        .delete();

    // Update follower/following counts
    await _users.doc(userId).update({'following': FieldValue.increment(-1)});
    await _users
        .doc(unfollowUserId)
        .update({'followers': FieldValue.increment(-1)});
  }

  // Check if following
  Future<bool> isFollowing(String userId, String otherUserId) async {
    final doc = await _following
        .doc(userId)
        .collection('userFollowing')
        .doc(otherUserId)
        .get();

    return doc.exists;
  }

  // Get followers
  Stream<List<UserModel>> getFollowers(String userId) {
    return _followers
        .doc(userId)
        .collection('userFollowers')
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserModel> followers = [];
      for (var doc in snapshot.docs) {
        final user = await getUserById(doc.id);
        if (user != null) followers.add(user);
      }
      return followers;
    });
  }

  // Get following
  Stream<List<UserModel>> getFollowing(String userId) {
    return _following
        .doc(userId)
        .collection('userFollowing')
        .snapshots()
        .asyncMap((snapshot) async {
      List<UserModel> following = [];
      for (var doc in snapshot.docs) {
        final user = await getUserById(doc.id);
        if (user != null) following.add(user);
      }
      return following;
    });
  }

  // Stream user changes
  Stream<UserModel?> streamUser(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  // Get follower count
  Future<int?> getFollowerCount(String userId) async {
    final snapshot =
        await _followers.doc(userId).collection('userFollowers').count().get();

    return snapshot.count;
  }

  // Get following count
  Future<int?> getFollowingCount(String userId) async {
    final snapshot =
        await _following.doc(userId).collection('userFollowing').count().get();

    return snapshot.count;
  }

  Future<void> incrementUserPoints(String userId, int points) async {
    await _users
        .doc(userId)
        .update({'userPoints': FieldValue.increment(points)});
  }

  // Alt user methods:
  Future<String> uploadAltImage({
    required String userId,
    required File file,
    required String type,
  }) async {
    final ref = _storage.ref().child('users/$userId/alt/$type.jpg');
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> requestAltConnection(String userId, String targetUserId) async {
    try {
      // Get requester information to include in the request
      final requester = await getUserById(userId);
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
      print('Error requesting alt connection: $e');
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
      print('Error accepting alt connection: $e');
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
      print('Error rejecting alt connection: $e');
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
      print('Error checking alt connection request: $e');
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
      print('Error checking alt connection: $e');
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
      print('Error getting alt connection count: $e');
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
