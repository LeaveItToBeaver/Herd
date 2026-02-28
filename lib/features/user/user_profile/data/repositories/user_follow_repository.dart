import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

final userFollowRepositoryProvider = Provider<UserFollowRepository>((ref) {
  return UserFollowRepository(FirebaseFirestore.instance);
});

class UserFollowRepository {
  final FirebaseFirestore _firestore;

  UserFollowRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _following =>
      _firestore.collection('following');
  CollectionReference<Map<String, dynamic>> get _followers =>
      _firestore.collection('followers');

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
        final userDoc = await _users.doc(doc.id).get();
        if (userDoc.exists) {
          followers.add(UserModel.fromMap(userDoc.id, userDoc.data()!));
        }
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
        final userDoc = await _users.doc(doc.id).get();
        if (userDoc.exists) {
          following.add(UserModel.fromMap(userDoc.id, userDoc.data()!));
        }
      }
      return following;
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
}
