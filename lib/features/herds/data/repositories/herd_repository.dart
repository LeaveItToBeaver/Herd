import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

import '../../../../core/utils/hot_algorithm.dart';
import '../models/herd_model.dart';

class HerdRepository {
  final FirebaseFirestore _firestore;

  // Minimum requirements to create a herd
  static const int minUserPoints = 100; // Points required to create a herd
  static const int minAccountAgeInDays = 30; // Account must be at least this old
  static const List<String> exemptUserIds = ['YOUR_USER_ID_HERE']; // Users exempt from restrictions

  HerdRepository(this._firestore);

  // Collection references
  CollectionReference<Map<String, dynamic>> get _herds =>
      _firestore.collection('herds');

  CollectionReference<Map<String, dynamic>> herdMembers(String herdId) =>
      _firestore.collection('herdMembers').doc(herdId).collection('members');

  CollectionReference<Map<String, dynamic>> herdPosts(String herdId) =>
      _firestore.collection('herdPosts').doc(herdId).collection('posts');

  CollectionReference<Map<String, dynamic>> userHerds(String userId) =>
      _firestore.collection('userHerds').doc(userId).collection('following');

  // CRUD Operations for Herds

  /// Create a new herd
  Future<String> createHerd(HerdModel herd, String userId) async {
    try {
      // Check if user is eligible to create a herd
      if (!exemptUserIds.contains(userId)) {
        bool isEligible = await checkUserEligibility(userId);
        if (!isEligible) {
          throw Exception('User is not eligible to create a herd');
        }
      }

      // Create herd document with generated ID
      final docRef = await _herds.add(herd.toMap());
      final herdId = docRef.id;

      // Update the herd document with its ID
      await docRef.update({'id': herdId});

      // Add creator as a member and moderator
      await herdMembers(herdId).doc(userId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': true,
      });

      // Add herd to user's following
      await userHerds(userId).doc(herdId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': true,
      });

      // Return the herd ID
      return herdId;
    } catch (e, stackTrace) {
      logError('createHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Get a herd by ID
  Future<HerdModel?> getHerd(String herdId) async {
    try {
      final doc = await _herds.doc(herdId).get();
      if (!doc.exists) return null;
      return HerdModel.fromMap(doc.id, doc.data()!);
    } catch (e, stackTrace) {
      logError('getHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Update a herd's information
  Future<void> updateHerd(String herdId, Map<String, dynamic> data, String userId) async {
    try {
      // Check if user is a moderator
      final isModerator = await isHerdModerator(herdId, userId);
      if (!isModerator) {
        throw Exception('User does not have permission to update this herd');
      }

      await _herds.doc(herdId).update({
        ...data,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e, stackTrace) {
      logError('updateHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Delete a herd (only by creator)
  Future<void> deleteHerd(String herdId, String userId) async {
    try {
      // Get herd details
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      // Verify user is the creator
      if (herd.creatorId != userId) {
        throw Exception('Only the creator can delete a herd');
      }

      // Get all members
      final membersSnapshot = await herdMembers(herdId).get();

      // Begin transaction to delete everything
      await _firestore.runTransaction((transaction) async {
        // Delete herd document
        transaction.delete(_herds.doc(herdId));

        // Delete all member documents
        for (var doc in membersSnapshot.docs) {
          transaction.delete(herdMembers(herdId).doc(doc.id));

          // Remove herd from user's following
          transaction.delete(userHerds(doc.id).doc(herdId));
        }
      });

      // Note: We won't delete posts, but they will be orphaned
      // A separate cleanup process should handle orphaned posts
    } catch (e, stackTrace) {
      logError('deleteHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Join a herd
  Future<void> joinHerd(String herdId, String userId) async {
    try {
      // Check if herd is private and requires approval
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      // For private herds, create a join request instead of direct join
      if (herd.isPrivate) {
        await _createJoinRequest(herdId, userId);
        return;
      }

      // Add user to herd members
      await herdMembers(herdId).doc(userId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': false,
      });

      // Add herd to user's following
      await userHerds(userId).doc(herdId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': false,
      });

      // Increment member count
      await _herds.doc(herdId).update({
        'memberCount': FieldValue.increment(1),
      });
    } catch (e, stackTrace) {
      logError('joinHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Leave a herd
  Future<void> leaveHerd(String herdId, String userId) async {
    try {
      // Get herd details
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      // Check if user is the creator (creators can't leave)
      if (herd.creatorId == userId) {
        throw Exception('Creators cannot leave their herds. Transfer ownership or delete the herd instead.');
      }

      // Remove user from herd members
      await herdMembers(herdId).doc(userId).delete();

      // Remove herd from user's following
      await userHerds(userId).doc(herdId).delete();

      // If user was a moderator, remove from moderator list
      if (herd.moderatorIds.contains(userId)) {
        await _herds.doc(herdId).update({
          'moderatorIds': FieldValue.arrayRemove([userId]),
          'memberCount': FieldValue.increment(-1),
        });
      } else {
        // Just decrement member count
        await _herds.doc(herdId).update({
          'memberCount': FieldValue.increment(-1),
        });
      }
    } catch (e, stackTrace) {
      logError('leaveHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Check if user is a member of a herd
  Future<bool> isHerdMember(String herdId, String userId) async {
    try {
      final doc = await herdMembers(herdId).doc(userId).get();
      return doc.exists;
    } catch (e, stackTrace) {
      logError('isHerdMember', e, stackTrace);
      rethrow;
    }
  }

  /// Check if user is a moderator of a herd
  Future<bool> isHerdModerator(String herdId, String userId) async {
    try {
      // Get herd to check if user is creator (always a moderator)
      final herd = await getHerd(herdId);
      if (herd == null) return false;

      if (herd.creatorId == userId) return true;

      // Check membership
      final doc = await herdMembers(herdId).doc(userId).get();
      if (!doc.exists) return false;

      return doc.data()?['isModerator'] == true || herd.moderatorIds.contains(userId);
    } catch (e, stackTrace) {
      logError('isHerdModerator', e, stackTrace);
      return false;
    }
  }

  /// Get posts from a herd with pagination
  Future<List<PostModel>> getHerdPosts({
    required String herdId,
    int limit = 15,
    PostModel? lastPost,
    double decayFactor = 1.0,
  }) async {
    try {
      // Query for posts in the herd with pagination
      var query = herdPosts(herdId)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      // Add pagination if lastPost is provided
      if (lastPost != null && lastPost.createdAt != null) {
        query = query.startAfter([lastPost.createdAt]);
      }

      final snapshot = await query.get();

      // Convert to PostModel objects
      List<PostModel> posts = snapshot.docs
          .map((doc) => PostModel.fromMap(doc.id, doc.data()))
          .toList();

      // Apply hot sorting algorithm
      final sortedPosts = applySortingAlgorithm(posts, decayFactor: decayFactor);

      return sortedPosts;
    } catch (e, stackTrace) {
      logError('getHerdPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Stream posts from a herd in real-time
  Stream<List<PostModel>> streamHerdPosts({
    required String herdId,
    int limit = 15,
    double decayFactor = 1.0,
  }) {
    try {
      return herdPosts(herdId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        List<PostModel> posts = snapshot.docs
            .map((doc) => PostModel.fromMap(doc.id, doc.data()))
            .toList();

        // Apply hot sorting algorithm
        final sortedPosts = applySortingAlgorithm(posts, decayFactor: decayFactor);
        return sortedPosts;
      });
    } catch (e, stackTrace) {
      logError('streamHerdPosts', e, stackTrace);
      rethrow;
    }
  }

  /// Get all herds a user follows
// Fixed version of the getUserHerds method to avoid naming conflict
  Future<List<HerdModel>> getUserHerds(String userId) async {
    try {
      // Get all herds the user follows
      final snapshot = await userHerds(userId).get();

      // Get full herd details for each followed herd
      List<HerdModel> followedHerds = []; // Changed variable name from userHerds to followedHerds
      for (var doc in snapshot.docs) {
        final herdDoc = await _herds.doc(doc.id).get();
        if (herdDoc.exists) {
          followedHerds.add(HerdModel.fromMap(herdDoc.id, herdDoc.data()!));
        }
      }

      // Sort by member count (most popular first)
      followedHerds.sort((a, b) => b.memberCount.compareTo(a.memberCount));

      return followedHerds;
    } catch (e, stackTrace) {
      logError('getUserHerds', e, stackTrace);
      rethrow;
    }
  }

  /// Stream all herds a user follows
  Stream<List<HerdModel>> streamUserHerds(String userId) {
    try {
      return userHerds(userId).snapshots().asyncMap((snapshot) async {
        List<HerdModel> userHerds = [];
        for (var doc in snapshot.docs) {
          final herdDoc = await _herds.doc(doc.id).get();
          if (herdDoc.exists) {
            userHerds.add(HerdModel.fromMap(herdDoc.id, herdDoc.data()!));
          }
        }

        // Sort by member count (most popular first)
        userHerds.sort((a, b) => b.memberCount.compareTo(a.memberCount));

        return userHerds;
      });
    } catch (e, stackTrace) {
      logError('streamUserHerds', e, stackTrace);
      rethrow;
    }
  }

  /// Get trending herds
  Future<List<HerdModel>> getTrendingHerds({int limit = 10}) async {
    try {
      // Get herds ordered by memberCount + recent activity
      final snapshot = await _herds
          .orderBy('memberCount', descending: true)
          .limit(limit * 2)
          .get();

      // Convert to HerdModel objects
      List<HerdModel> herds = snapshot.docs
          .map((doc) => HerdModel.fromMap(doc.id, doc.data()))
          .toList();

      // TODO: Implement a more sophisticated trending algorithm
      // For now, we'll just sort by memberCount
      herds.sort((a, b) => b.memberCount.compareTo(a.memberCount));

      return herds.take(limit).toList();
    } catch (e, stackTrace) {
      logError('getTrendingHerds', e, stackTrace);
      rethrow;
    }
  }

  /// Search for herds by name or description
  Future<List<HerdModel>> searchHerds(String query, {int limit = 10}) async {
    try {
      // For simplicity, we'll search by name containing the query
      // In a production app, consider using Algolia or Firebase Extensions for better search
      final queryLower = query.toLowerCase();

      final snapshot = await _herds
          .orderBy('name')
          .startAt([queryLower])
          .endAt([queryLower + '\uf8ff'])
          .limit(limit)
          .get();

      // Convert to HerdModel objects
      List<HerdModel> herds = snapshot.docs
          .map((doc) => HerdModel.fromMap(doc.id, doc.data()))
          .toList();

      return herds;
    } catch (e, stackTrace) {
      logError('searchHerds', e, stackTrace);
      rethrow;
    }
  }

  /// Add a post to a herd
  Future<void> addPostToHerd(String herdId, PostModel post, String userId) async {
    try {
      // Check if user is a member of the herd
      final isMember = await isHerdMember(herdId, userId);
      if (!isMember) {
        throw Exception('You must be a member of this herd to post');
      }

      // Add post to herd posts collection
      await herdPosts(herdId).doc(post.id).set(post.toMap());

      // Increment post count in herd
      await _herds.doc(herdId).update({
        'postCount': FieldValue.increment(1),
      });
    } catch (e, stackTrace) {
      logError('addPostToHerd', e, stackTrace);
      rethrow;
    }
  }

  /// Get members of a herd with pagination
  Future<List<String>> getHerdMembers(String herdId, {int limit = 20, String? lastUserId}) async {
    try {
      var query = herdMembers(herdId)
          .orderBy('joinedAt', descending: true)
          .limit(limit);

      if (lastUserId != null) {
        final lastDoc = await herdMembers(herdId).doc(lastUserId).get();
        if (lastDoc.exists) {
          query = query.startAfterDocument(lastDoc);
        }
      }

      final snapshot = await query.get();

      // Return list of user IDs
      return snapshot.docs.map((doc) => doc.id).toList();
    } catch (e, stackTrace) {
      logError('getHerdMembers', e, stackTrace);
      rethrow;
    }
  }

  /// Add moderator to a herd
  Future<void> addModerator(String herdId, String userId, String currentUserId) async {
    try {
      // Check if current user has permission to add moderators
      final isModerator = await isHerdModerator(herdId, currentUserId);
      if (!isModerator) {
        throw Exception('You do not have permission to add moderators');
      }

      // Check if target user is a member
      final isMember = await isHerdMember(herdId, userId);
      if (!isMember) {
        throw Exception('User must be a member of the herd to become a moderator');
      }

      // Add user to moderator list in herd document
      await _herds.doc(herdId).update({
        'moderatorIds': FieldValue.arrayUnion([userId]),
      });

      // Update user's member status
      await herdMembers(herdId).doc(userId).update({
        'isModerator': true,
      });

      // Update user's following status
      await userHerds(userId).doc(herdId).update({
        'isModerator': true,
      });
    } catch (e, stackTrace) {
      logError('addModerator', e, stackTrace);
      rethrow;
    }
  }

  /// Remove moderator from a herd
  Future<void> removeModerator(String herdId, String userId, String currentUserId) async {
    try {
      // Get herd details
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      // Only creator can remove moderators
      if (herd.creatorId != currentUserId) {
        throw Exception('Only the creator can remove moderators');
      }

      // Creator cannot be removed as moderator
      if (herd.creatorId == userId) {
        throw Exception('Creator cannot be removed as moderator');
      }

      // Remove user from moderator list in herd document
      await _herds.doc(herdId).update({
        'moderatorIds': FieldValue.arrayRemove([userId]),
      });

      // Update user's member status
      await herdMembers(herdId).doc(userId).update({
        'isModerator': false,
      });

      // Update user's following status
      await userHerds(userId).doc(herdId).update({
        'isModerator': false,
      });
    } catch (e, stackTrace) {
      logError('removeModerator', e, stackTrace);
      rethrow;
    }
  }

  /// Ban a user from a herd
  Future<void> banUser(String herdId, String userId, String currentUserId) async {
    try {
      // Check if current user has permission to ban
      final isModerator = await isHerdModerator(herdId, currentUserId);
      if (!isModerator) {
        throw Exception('You do not have permission to ban users');
      }

      // Get herd details
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      // Cannot ban the creator
      if (herd.creatorId == userId) {
        throw Exception('Cannot ban the creator of the herd');
      }

      // If current user is not creator, they cannot ban other moderators
      if (herd.creatorId != currentUserId &&
          (herd.moderatorIds.contains(userId) || userId == herd.creatorId)) {
        throw Exception('Only the creator can ban moderators');
      }

      // Remove user from herd members
      await herdMembers(herdId).doc(userId).delete();

      // Remove herd from user's following
      await userHerds(userId).doc(herdId).delete();

      // If user was a moderator, remove from moderator list
      if (herd.moderatorIds.contains(userId)) {
        await _herds.doc(herdId).update({
          'moderatorIds': FieldValue.arrayRemove([userId]),
          'memberCount': FieldValue.increment(-1),
        });
      } else {
        // Just decrement member count
        await _herds.doc(herdId).update({
          'memberCount': FieldValue.increment(-1),
        });
      }

      // Add user to banned list
      await _firestore.collection('herdBans')
          .doc(herdId)
          .collection('banned')
          .doc(userId)
          .set({
        'bannedAt': FieldValue.serverTimestamp(),
        'bannedBy': currentUserId,
      });
    } catch (e, stackTrace) {
      logError('banUser', e, stackTrace);
      rethrow;
    }
  }

  /// Check if user is banned from a herd
  Future<bool> isUserBanned(String herdId, String userId) async {
    try {
      final doc = await _firestore.collection('herdBans')
          .doc(herdId)
          .collection('banned')
          .doc(userId)
          .get();

      return doc.exists;
    } catch (e, stackTrace) {
      logError('isUserBanned', e, stackTrace);
      return false;
    }
  }

  /// Check user eligibility to create a herd
  Future<bool> checkUserEligibility(String userId) async {
    try {
      // Get user document
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;

      // Check points requirement
      final userPoints = userData['userPoints'] as int? ?? 0;
      if (userPoints < minUserPoints) return false;

      // Check account age
      final createdAt = userData['createdAt'] as Timestamp?;
      if (createdAt == null) return false;

      final accountAge = DateTime.now().difference(createdAt.toDate()).inDays;
      if (accountAge < minAccountAgeInDays) return false;

      // TODO: Check for moderation marks
      // This would require a separate collection for moderation actions

      return true;
    } catch (e, stackTrace) {
      logError('checkUserEligibility', e, stackTrace);
      return false;
    }
  }

  /// Create a request to join a private herd
  Future<void> _createJoinRequest(String herdId, String userId) async {
    try {
      await _firestore.collection('herdJoinRequests')
          .doc(herdId)
          .collection('requests')
          .doc(userId)
          .set({
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending', // 'pending', 'approved', 'rejected'
      });
    } catch (e, stackTrace) {
      logError('createJoinRequest', e, stackTrace);
      rethrow;
    }
  }

  /// Approve a join request for a private herd
  Future<void> approveJoinRequest(String herdId, String userId, String currentUserId) async {
    try {
      // Check if current user has permission
      final isModerator = await isHerdModerator(herdId, currentUserId);
      if (!isModerator) {
        throw Exception('You do not have permission to approve join requests');
      }

      // Get the request
      final requestDoc = await _firestore.collection('herdJoinRequests')
          .doc(herdId)
          .collection('requests')
          .doc(userId)
          .get();

      if (!requestDoc.exists) {
        throw Exception('Join request not found');
      }

      // Update request status
      await requestDoc.reference.update({
        'status': 'approved',
        'approvedAt': FieldValue.serverTimestamp(),
        'approvedBy': currentUserId,
      });

      // Add user to herd members
      await herdMembers(herdId).doc(userId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': false,
      });

      // Add herd to user's following
      await userHerds(userId).doc(herdId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': false,
      });

      // Increment member count
      await _herds.doc(herdId).update({
        'memberCount': FieldValue.increment(1),
      });
    } catch (e, stackTrace) {
      logError('approveJoinRequest', e, stackTrace);
      rethrow;
    }
  }

  /// Calculate net votes for a post
  int calculateNetVotes(PostModel post) {
    return post.likeCount - post.dislikeCount;
  }

  /// Sort a list of posts using the hot algorithm
  List<PostModel> applySortingAlgorithm(List<PostModel> posts, {double decayFactor = 1.0}) {
    return HotAlgorithm.sortByHotScore(
        posts,
            (post) => calculateNetVotes(post),
            (post) => post.createdAt ?? DateTime.now(),
        decayFactor: decayFactor
    );
  }

  /// Helper method to log errors
  void logError(String operation, Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('Herd Repository Error during $operation: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}