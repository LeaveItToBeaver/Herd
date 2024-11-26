import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  Future<List<UserModel>> searchUsers(String query) async {
    final userSnap = await _users
        .where('username', isGreaterThanOrEqualTo: query.toLowerCase())
        .where('username',
        isLessThan: '${query.toLowerCase()}\uf8ff')
        .limit(20)
        .get();

    return userSnap.docs
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
    await _following
        .doc(userId)
        .collection('userFollowing')
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete())
    );

    await _following
        .doc(userId)
        .collection('userFollowing')
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete())
    );

    await _followers
        .doc(userId)
        .collection('userFollowers')
        .get()
        .then(
            (snapshot) => snapshot.docs.forEach((doc) => doc.reference.delete())
    );
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
    await _users.doc(userId).update({
      'following': FieldValue.increment(1)
    });
    await _users.doc(followUserId).update({
      'followers': FieldValue.increment(1)
    });
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
    await _users.doc(userId).update({
      'following': FieldValue.increment(-1)
    });
    await _users.doc(unfollowUserId).update({
      'followers': FieldValue.increment(-1)
    });
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
    final snapshot = await _followers
        .doc(userId)
        .collection('userFollowers')
        .count()
        .get();

    return snapshot.count;
  }

  // Get following count
  Future<int?> getFollowingCount(String userId) async {
    final snapshot = await _following
        .doc(userId)
        .collection('userFollowing')
        .count()
        .get();

    return snapshot.count;
  }
}