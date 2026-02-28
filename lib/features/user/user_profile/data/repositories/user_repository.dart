import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/user/user_profile/data/models/alt_connection_request_model.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/account_management_repository.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/alt_profile_repository.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/pinned_post_repository.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_follow_repository.dart';
import 'package:herdapp/features/user/user_profile/data/repositories/user_search_repository.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(FirebaseFirestore.instance);
});

/// Facade over the split user repositories.
///
/// Core CRUD lives here directly. Domain-specific operations are delegated to:
/// - [UserSearchRepository] – user search & username lookup
/// - [UserFollowRepository] – follow/unfollow & follower streams
/// - [AltProfileRepository] – alt profile & alt connections
/// - [PinnedPostRepository] – pinning/unpinning posts to profiles
/// - [AccountManagementRepository] – account deletion & data export
///
/// New code should prefer injecting the focused repository directly.
/// This class keeps backward compatibility so existing call-sites don't break.
class UserRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Delegates
  late final UserSearchRepository _search;
  late final UserFollowRepository _follow;
  late final AltProfileRepository _alt;
  late final PinnedPostRepository _pinned;
  late final AccountManagementRepository _account;

  UserRepository(this._firestore) {
    _search = UserSearchRepository(_firestore);
    _follow = UserFollowRepository(_firestore);
    _alt = AltProfileRepository(_firestore);
    _pinned = PinnedPostRepository(_firestore);
    _account = AccountManagementRepository(_firestore);
  }

  // ---------------------------------------------------------------------------
  // Core collection references
  // ---------------------------------------------------------------------------

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  // ---------------------------------------------------------------------------
  // Core CRUD
  // ---------------------------------------------------------------------------

  /// Create new user
  Future<void> createUser(String userId, UserModel user) async {
    await _users.doc(userId).set(user.toMap());
  }

  /// Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _users.doc(userId).get();
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  }

  /// Update user
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _users.doc(userId).update({
      ...data,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete user (simple version – see also [permanentlyDeleteAccount])
  Future<void> deleteUser(String userId) async {
    final batch = _firestore.batch();
    final following = _firestore.collection('following');
    final followers = _firestore.collection('followers');

    // Delete the user document
    batch.delete(_users.doc(userId));

    // Clean up following relationships
    final followingSnapshot =
        await following.doc(userId).collection('userFollowing').get();
    for (final doc in followingSnapshot.docs) {
      final followedUserId = doc.id;
      batch.delete(followers
          .doc(followedUserId)
          .collection('userFollowers')
          .doc(userId));
      batch.update(
          _users.doc(followedUserId), {'followers': FieldValue.increment(-1)});
      batch.delete(doc.reference);
    }

    // Clean up follower relationships
    final followersSnapshot =
        await followers.doc(userId).collection('userFollowers').get();
    for (final doc in followersSnapshot.docs) {
      final followerId = doc.id;
      batch.delete(
          following.doc(followerId).collection('userFollowing').doc(userId));
      batch.update(
          _users.doc(followerId), {'following': FieldValue.increment(-1)});
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  /// Stream user changes
  Stream<UserModel?> streamUser(String userId) {
    return _users.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserModel.fromMap(doc.id, doc.data()!);
    });
  }

  /// Upload profile image
  Future<String> uploadImage({
    required String userId,
    required File file,
    required String type,
  }) async {
    final ref = _storage.ref().child('users/$userId/$type');
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  /// Increment user points
  Future<void> incrementUserPoints(String userId, int points) async {
    await _users
        .doc(userId)
        .update({'userPoints': FieldValue.increment(points)});
  }

  // ---------------------------------------------------------------------------
  // Delegated: Search  (prefer injecting UserSearchRepository directly)
  // ---------------------------------------------------------------------------

  Future<List<UserModel>> searchUsers(String query,
          {FeedType profileType = FeedType.public}) =>
      _search.searchUsers(query, profileType: profileType);

  Future<List<UserModel>> searchAll(String query) => _search.searchAll(query);

  Future<List<UserModel>> searchByUsername(String username,
          {FeedType profileType = FeedType.public}) =>
      _search.searchByUsername(username, profileType: profileType);

  Future<List<UserModel>> searchByFullName(String query) =>
      _search.searchByFullName(query);

  Future<bool> isUsernameAvailable(String username) =>
      _search.isUsernameAvailable(username);

  Future<UserModel?> getUserByUsername(String username) =>
      _search.getUserByUsername(username);

  // ---------------------------------------------------------------------------
  // Delegated: Follow  (prefer injecting UserFollowRepository directly)
  // ---------------------------------------------------------------------------

  Future<void> followUser(String userId, String followUserId) =>
      _follow.followUser(userId, followUserId);

  Future<void> unfollowUser(String userId, String unfollowUserId) =>
      _follow.unfollowUser(userId, unfollowUserId);

  Future<bool> isFollowing(String userId, String otherUserId) =>
      _follow.isFollowing(userId, otherUserId);

  Stream<List<UserModel>> getFollowers(String userId) =>
      _follow.getFollowers(userId);

  Stream<List<UserModel>> getFollowing(String userId) =>
      _follow.getFollowing(userId);

  Future<int?> getFollowerCount(String userId) =>
      _follow.getFollowerCount(userId);

  Future<int?> getFollowingCount(String userId) =>
      _follow.getFollowingCount(userId);

  // ---------------------------------------------------------------------------
  // Delegated: Alt Profile  (prefer injecting AltProfileRepository directly)
  // ---------------------------------------------------------------------------

  Future<String> uploadAltImage({
    required String userId,
    required File file,
    required String type,
  }) =>
      _alt.uploadAltImage(userId: userId, file: file, type: type);

  Future<void> requestAltConnection(String userId, String targetUserId) =>
      _alt.requestAltConnection(userId, targetUserId);

  Future<void> acceptAltConnection(String userId, String requesterId) =>
      _alt.acceptAltConnection(userId, requesterId);

  Future<void> rejectAltConnection(String userId, String requesterId) =>
      _alt.rejectAltConnection(userId, requesterId);

  Stream<List<AltConnectionRequest>> getPendingConnectionRequests(
          String userId) =>
      _alt.getPendingConnectionRequests(userId);

  Future<bool> hasAltConnectionRequest(
          String requesterId, String targetUserId) =>
      _alt.hasAltConnectionRequest(requesterId, targetUserId);

  Future<bool> areAltlyConnected(String userId1, String userId2) =>
      _alt.areAltlyConnected(userId1, userId2);

  Stream<List<String>> getAltConnectionIds(String userId) =>
      _alt.getAltConnectionIds(userId);

  Future<int> getAltConnectionCount(String userId) =>
      _alt.getAltConnectionCount(userId);

  Future<bool> hasAltProfile(String userId) => _alt.hasAltProfile(userId);

  Future<void> updateAltProfile(
          String userId, Map<String, dynamic> altData) =>
      _alt.updateAltProfile(userId, altData);

  Future<void> addAltConnection(String userId, String connectionId) =>
      _alt.addAltConnection(userId, connectionId);

  Future<void> removeAltConnection(String userId, String connectionId) =>
      _alt.removeAltConnection(userId, connectionId);

  Future<bool> isAltlyConnected(String userId, String otherUserId) =>
      _alt.isAltlyConnected(userId, otherUserId);

  // ---------------------------------------------------------------------------
  // Delegated: Pinned Posts  (prefer injecting PinnedPostRepository directly)
  // ---------------------------------------------------------------------------

  Future<void> pinPostToProfile(String userId, String postId,
          {bool isAlt = false}) =>
      _pinned.pinPostToProfile(userId, postId, isAlt: isAlt);

  Future<void> unpinPostFromProfile(String userId, String postId,
          {bool isAlt = false}) =>
      _pinned.unpinPostFromProfile(userId, postId, isAlt: isAlt);

  Future<List<String>> getPinnedPosts(String userId,
          {bool isAlt = false}) =>
      _pinned.getPinnedPosts(userId, isAlt: isAlt);

  Future<bool> isPostPinnedToProfile(String userId, String postId,
          {bool isAlt = false}) =>
      _pinned.isPostPinnedToProfile(userId, postId, isAlt: isAlt);

  // ---------------------------------------------------------------------------
  // Delegated: Account Management  (prefer injecting AccountManagementRepository directly)
  // ---------------------------------------------------------------------------

  Future<void> markAccountForDeletion(String userId) =>
      _account.markAccountForDeletion(userId);

  Future<void> cancelAccountDeletion(String userId) =>
      _account.cancelAccountDeletion(userId);

  Future<bool> isAccountMarkedForDeletion(String userId) =>
      _account.isAccountMarkedForDeletion(userId);

  Future<DateTime?> getAccountDeletionDate(String userId) =>
      _account.getAccountDeletionDate(userId);

  Future<int?> getDaysUntilPermanentDeletion(String userId) =>
      _account.getDaysUntilPermanentDeletion(userId);

  Future<Map<String, dynamic>> requestDataExport(String userId) =>
      _account.requestDataExport(userId);

  Future<bool> hasPendingDataExport(String userId) =>
      _account.hasPendingDataExport(userId);

  Future<Map<String, dynamic>> getDataExportStatus(String userId) =>
      _account.getDataExportStatus(userId);

  Future<Map<String, dynamic>> resetDataExportRequest(String userId) =>
      _account.resetDataExportRequest(userId);

  Future<Map<String, dynamic>> getUserExportData(String userId) =>
      _account.getUserExportData(userId);

  Future<void> permanentlyDeleteAccount(String userId) =>
      _account.permanentlyDeleteAccount(userId);

  Future<List<String>> getAccountsReadyForDeletion() =>
      _account.getAccountsReadyForDeletion();
}
