import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/feed/providers/feed_type_provider.dart';
import 'package:herdapp/features/user/user_profile/data/models/alt_connection_request_model.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

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

  String capitalize(String s) {
    if (s.isEmpty) return '';
    return s[0].toUpperCase() + s.substring(1);
  }

  // Search users
  Future<List<UserModel>> searchUsers(String query,
      {FeedType profileType = FeedType.public}) async {
    if (query.isEmpty) return [];

    // Convert query to lowercase for more flexible search
    final lowerQuery = query.toLowerCase();
    final capitalizedQuery = query.isNotEmpty
        ? query[0].toUpperCase() + query.substring(1).toLowerCase()
        : "";

    // Split query for potential full name search
    final parts = query.trim().split(' ');
    final isFullNameSearch = parts.length > 1;

    final List<Future<QuerySnapshot<Map<String, dynamic>>>> searches = [];

    if (profileType == FeedType.public) {
      // For public feed, search first and last name
      if (isFullNameSearch) {
        // Full name search - combine first and last name conditions
        final firstName = parts[0].toLowerCase();
        final lastName = parts.sublist(1).join(' ').toLowerCase();

        searches.add(_users
            .where('firstName', isEqualTo: firstName)
            .where('lastName', isEqualTo: lastName)
            .limit(10)
            .get());

        // Also try capitalized versions
        searches.add(_users
            .where('firstName', isEqualTo: capitalize(firstName))
            .where('lastName', isEqualTo: capitalize(lastName))
            .limit(10)
            .get());
      } else {
        // Single word search - check first name or last name
        searches.addAll([
          _users
              .where('firstName', isGreaterThanOrEqualTo: lowerQuery)
              .where('firstName', isLessThan: '$lowerQuery\uf8ff')
              .limit(10)
              .get(),
          _users
              .where('firstName', isGreaterThanOrEqualTo: capitalizedQuery)
              .where('firstName', isLessThan: '$capitalizedQuery\uf8ff')
              .limit(10)
              .get(),
          _users
              .where('lastName', isGreaterThanOrEqualTo: lowerQuery)
              .where('lastName', isLessThan: '$lowerQuery\uf8ff')
              .limit(10)
              .get(),
          _users
              .where('lastName', isGreaterThanOrEqualTo: capitalizedQuery)
              .where('lastName', isLessThan: '$capitalizedQuery\uf8ff')
              .limit(10)
              .get(),
        ]);
      }
    } else {
      // For alt feed, only search username
      searches.add(_users
          .where('username', isGreaterThanOrEqualTo: lowerQuery)
          .where('username', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get());
    }

    // Execute searches and collect results
    final results = await Future.wait(searches);
    final uniqueDocsMap =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (var querySnapshot in results) {
      for (var doc in querySnapshot.docs) {
        if (!uniqueDocsMap.containsKey(doc.id)) {
          uniqueDocsMap[doc.id] = doc;
        }
      }
    }

    // Convert to UserModels with appropriate filtering
    List<UserModel> users = [];
    for (var doc in uniqueDocsMap.values) {
      final user = UserModel.fromMap(doc.id, doc.data());

      // Filter based on feed type
      if (profileType == FeedType.alt) {
        if (user.username.isEmpty) continue;
      } else {
        if (user.firstName.isEmpty && user.lastName.isEmpty) continue;
      }

      users.add(user);
    }

    return users;
  }

  Future<List<UserModel>> searchAll(
    String query,
  ) async {
    if (query.isEmpty) return [];

    // Convert query to lowercase and capitalized for more flexible search
    final lowerQuery = query.toLowerCase();
    final capitalQuery = query.isNotEmpty
        ? query[0].toUpperCase() + query.substring(1).toLowerCase()
        : "";

    // Determine which fields to search based on profile type
    final List<Future<QuerySnapshot<Map<String, dynamic>>>> searches = [];

    // Only search public profile fields for public feed
    searches.addAll([
      // Search by first name - lowercase
      _users
          .where('firstName', isGreaterThanOrEqualTo: lowerQuery)
          .where('firstName', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get(),

      // Search by first name - capitalized
      _users
          .where('firstName', isGreaterThanOrEqualTo: capitalQuery)
          .where('firstName', isLessThan: '$capitalQuery\uf8ff')
          .limit(10)
          .get(),

      // Search by last name - lowercase
      _users
          .where('lastName', isGreaterThanOrEqualTo: lowerQuery)
          .where('lastName', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get(),

      // Search by last name - capitalized
      _users
          .where('lastName', isGreaterThanOrEqualTo: capitalQuery)
          .where('lastName', isLessThan: '$capitalQuery\uf8ff')
          .limit(10)
          .get(),
    ]);
    // Only search alt profile fields for alt feed
    searches.addAll([
      // Search by username ONLY
      _users
          .where('username', isGreaterThanOrEqualTo: lowerQuery)
          .where('username', isLessThan: '$lowerQuery\uf8ff')
          .limit(10)
          .get(),

      // Do NOT search by firstName/lastName/username for alt profiles to maintain anonymity
    ]);

    // Execute all searches in parallel
    final results = await Future.wait(searches);

    // Combine results and remove duplicates
    final uniqueDocsMap =
        <String, QueryDocumentSnapshot<Map<String, dynamic>>>{};

    for (var querySnapshot in results) {
      for (var doc in querySnapshot.docs) {
        if (!uniqueDocsMap.containsKey(doc.id)) {
          uniqueDocsMap[doc.id] = doc;
        }
      }
    }

    // Convert to UserModels but ensure profile type separation
    List<UserModel> users = [];

    for (var doc in uniqueDocsMap.values) {
      final user = UserModel.fromMap(doc.id, doc.data());
      users.add(user);
    }

    return users;
  }

  // Username-specific search that respects profile type
  Future<List<UserModel>> searchByUsername(String username,
      {FeedType profileType = FeedType.public}) async {
    if (username.isEmpty) return [];

    final lowerUsername = username.toLowerCase();

    try {
      QuerySnapshot<Map<String, dynamic>> snapshot;

      // Use different field based on the feed type
      if (profileType == FeedType.alt) {
        snapshot = await _users
            .where('username', isEqualTo: lowerUsername)
            .limit(1)
            .get();
      } else {
        snapshot = await _users
            .where('username', isEqualTo: lowerUsername)
            .limit(1)
            .get();
      }

      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error searching by username: $e');
      return [];
    }
  }

  // Search for users by both first and last name combined (public only)
  Future<List<UserModel>> searchByFullName(String query) async {
    // This handles searching for "first last" combined pattern
    // ONLY for public profiles - not applicable to alt profiles
    if (query.isEmpty) return [];

    final queryParts = query.trim().split(' ');
    if (queryParts.length < 2) {
      // Single word query should use the regular search
      return searchUsers(query, profileType: FeedType.public);
    }

    // Get first name and last name parts for searching
    final firstName = queryParts[0];
    final lastName = queryParts.sublist(1).join(' ');

    // Get all users that match firstName
    final firstNameMatches =
        await searchUsers(firstName, profileType: FeedType.public);

    // Filter to those that also match lastName
    final lowerLastName = lastName.toLowerCase();
    return firstNameMatches
        .where((user) => user.lastName.toLowerCase().contains(lowerLastName))
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
    final ref = _storage.ref().child('users/$userId/$type');
    final uploadTask = ref.putFile(file);

    final snapshot = await uploadTask;
    final downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    final batch = _firestore.batch();

    // Delete the user document
    batch.delete(_users.doc(userId));

    // Get the list of users that the deleted user was following
    final followingSnapshot =
        await _following.doc(userId).collection('userFollowing').get();
    for (final doc in followingSnapshot.docs) {
      final followedUserId = doc.id;
      // Remove the deleted user from the `followers` list of the user they were following
      batch.delete(_followers
          .doc(followedUserId)
          .collection('userFollowers')
          .doc(userId));
      // Decrement the followers count for that user
      batch.update(
          _users.doc(followedUserId), {'followers': FieldValue.increment(-1)});
      // Delete the document in the deleted user's `following` subcollection
      batch.delete(doc.reference);
    }

    // Get the list of users who were following the deleted user
    final followersSnapshot =
        await _followers.doc(userId).collection('userFollowers').get();
    for (final doc in followersSnapshot.docs) {
      final followerId = doc.id;
      // Remove the deleted user from the `following` list of their follower
      batch.delete(
          _following.doc(followerId).collection('userFollowing').doc(userId));
      // Decrement the following count for that user
      batch.update(
          _users.doc(followerId), {'following': FieldValue.increment(-1)});
      // Delete the document in the deleted user's `followers` subcollection
      batch.delete(doc.reference);
    }

    await batch.commit();
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
    final ref = _storage.ref().child('users/$userId/alt/$type');
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
      debugPrint('Error requesting alt connection: $e');
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

  Future<void> pinPostToProfile(String userId, String postId,
      {bool isAlt = false}) async {
    try {
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final currentPinnedPosts = isAlt ? user.altPinnedPosts : user.pinnedPosts;
      if (currentPinnedPosts.contains(postId)) {
        // Post is already pinned, do nothing
        return;
      }

      if (currentPinnedPosts.contains(postId)) {
        // If already pinned, remove it first
        await _users.doc(userId).update({
          isAlt ? 'altPinnedPosts' : 'pinnedPosts':
              FieldValue.arrayRemove([postId]),
        });
      }

      if (currentPinnedPosts.length >= 5) {
        throw Exception('Maximum number of pinned posts reached (5)');
      }

      final updatePinned = [...currentPinnedPosts, postId];

      final updatedPinned = isAlt
          ? {'altPinnedPosts': updatePinned}
          : {'pinnedPosts': updatePinned};

      await updateUser(userId, updatedPinned);

      // Update the post document to mark it as pinned
      await _updatePostPinStatus(postId,
          isAlt: isAlt, isPinned: true, userId: userId);
    } catch (e) {
      debugPrint('Error pinning post to profile: $e');
      rethrow;
    }
  }

  Future<void> _updatePostPinStatus(String postId,
      {required bool isAlt,
      required bool isPinned,
      required String userId}) async {
    try {
      // Determine which collection to update
      CollectionReference collection;
      if (isAlt) {
        collection = _firestore.collection('altPosts');
      } else {
        collection = _firestore.collection('posts');
      }

      // Update the post document
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isAlt) {
        updateData['isPinnedToAltProfile'] = isPinned;
      } else {
        updateData['isPinnedToProfile'] = isPinned;
      }

      if (isPinned) {
        updateData['pinnedAt'] = FieldValue.serverTimestamp();
      } else {
        updateData['pinnedAt'] = null;
      }

      await collection.doc(postId).update(updateData);
    } catch (e) {
      debugPrint('Error updating post pin status: $e');
      // Don't rethrow here as this is a secondary update
    }
  }

  Future<void> unpinPostFromProfile(String userId, String postId,
      {bool isAlt = false}) async {
    try {
      // Get current user data
      final user = await getUserById(userId);
      if (user == null) {
        throw Exception('User not found');
      }

      final currentPinned = isAlt ? user.altPinnedPosts : user.pinnedPosts;

      // Check if post is actually pinned
      if (!currentPinned.contains(postId)) {
        throw Exception('Post is not pinned');
      }

      // Remove the post from pinned list
      final updatedPinned = currentPinned.where((id) => id != postId).toList();

      // Update user document
      final updateData = isAlt
          ? {'altPinnedPosts': updatedPinned}
          : {'pinnedPosts': updatedPinned};

      await updateUser(userId, updateData);

      // Update the post document to mark it as unpinned
      await _updatePostPinStatus(postId,
          isAlt: isAlt, isPinned: false, userId: userId);
    } catch (e) {
      debugPrint('Error unpinning post from profile: $e');
      rethrow;
    }
  }

  /// Get pinned posts for a user profile
  Future<List<String>> getPinnedPosts(String userId,
      {bool isAlt = false}) async {
    try {
      final user = await getUserById(userId);
      if (user == null) return [];

      return isAlt ? user.altPinnedPosts : user.pinnedPosts;
    } catch (e) {
      debugPrint('Error getting pinned posts: $e');
      return [];
    }
  }

  /// Check if a post is pinned to a user's profile
  Future<bool> isPostPinnedToProfile(String userId, String postId,
      {bool isAlt = false}) async {
    try {
      final pinnedPosts = await getPinnedPosts(userId, isAlt: isAlt);
      return pinnedPosts.contains(postId);
    } catch (e) {
      debugPrint('Error checking if post is pinned: $e');
      return false;
    }
  }

  // Account deletion methods

  /// Mark user account for deletion
  Future<void> markAccountForDeletion(String userId) async {
    try {
      await updateUser(userId, {
        'markedForDeleteAt': FieldValue.serverTimestamp(),
        'accountStatus': 'marked_for_deletion',
        'altAccountStatus': 'marked_for_deletion',
        'isActive': false,
        'altIsActive': false,
      });
    } catch (e) {
      debugPrint('Error marking account for deletion: $e');
      rethrow;
    }
  }

  /// Cancel account deletion (restore account within 30-day period)
  Future<void> cancelAccountDeletion(String userId) async {
    try {
      await updateUser(userId, {
        'markedForDeleteAt': null,
        'accountStatus': 'active',
        'altAccountStatus': 'active',
        'isActive': true,
        'altIsActive': true,
      });
    } catch (e) {
      debugPrint('Error canceling account deletion: $e');
      rethrow;
    }
  }

  /// Check if account is marked for deletion
  Future<bool> isAccountMarkedForDeletion(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.isMarkedForDeletion ?? false;
    } catch (e) {
      debugPrint('Error checking account deletion status: $e');
      return false;
    }
  }

  /// Get deletion date for account (when it will be permanently deleted)
  Future<DateTime?> getAccountDeletionDate(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.permanentDeletionDate;
    } catch (e) {
      debugPrint('Error getting account deletion date: $e');
      return null;
    }
  }

  /// Get days remaining until permanent deletion
  Future<int?> getDaysUntilPermanentDeletion(String userId) async {
    try {
      final user = await getUserById(userId);
      return user?.daysUntilDeletion;
    } catch (e) {
      debugPrint('Error getting days until deletion: $e');
      return null;
    }
  }

  /// Request data export for user
  Future<void> requestDataExport(String userId) async {
    try {
      // Create a data export request document
      await _firestore.collection('dataExportRequests').doc(userId).set({
        'userId': userId,
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'exportType': 'full_account_data',
      });
    } catch (e) {
      debugPrint('Error requesting data export: $e');
      rethrow;
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
      return false;
    }
  }

  /// Get user's complete data for export (this would be used by admin/backend processes)
  Future<Map<String, dynamic>> getUserExportData(String userId) async {
    try {
      final user = await getUserById(userId);
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
      rethrow;
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
      return [];
    }
  }
}
