import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/community/herds/data/models/herd_member_info.dart';
import 'package:herdapp/features/community/herds/data/models/banned_user_info.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

import '../../../../../core/utils/hot_algorithm.dart';
import '../models/herd_model.dart';

class HerdRepository {
  final FirebaseFirestore _firestore;

  // Minimum requirements to create a herd
  static const int minUserPoints = 100; // Points required to create a herd
  static const int minAccountAgeInDays =
      30; // Account must be at least this old

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

  CollectionReference<Map<String, dynamic>> exemptUserIds() =>
      _firestore.collection('exemptUserIds');

  Future<String> createHerd(HerdModel herd, String userId) async {
    try {
      await _validateHerdCreation(herd.name);

      await exemptUserIds().doc(userId).get().then((doc) async {
        if (doc.exists) {
          return;
        } else {
          bool isEligible = await checkUserEligibility(userId);
          if (!isEligible) {
            throw Exception('User is not eligible to create a herd');
          }
        }
      });

      final docRef = await _herds.add(herd.toMap());

      final herdId = docRef.id;

      await docRef.update({'id': herdId});

      await herdMembers(herdId).doc(userId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': true,
      });

      await userHerds(userId).doc(herdId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': true,
      });

      await _herds.doc(herdId).update({
        'memberCount': FieldValue.increment(1),
      });

      return herdId;
    } catch (e, stackTrace) {
      logError('createHerd', e, stackTrace);
      rethrow;
    }
  }

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

  Future<void> updateHerd(
      String herdId, Map<String, dynamic> data, String userId) async {
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

  Future<void> deleteHerd(String herdId, String userId) async {
    try {
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (herd.creatorId != userId) {
        throw Exception('Only the creator can delete a herd');
      }

      final membersSnapshot = await herdMembers(herdId).get();

      await _firestore.runTransaction((transaction) async {
        // Delete herd document
        transaction.delete(_herds.doc(herdId));

        for (var doc in membersSnapshot.docs) {
          transaction.delete(herdMembers(herdId).doc(doc.id));
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

  Future<void> joinHerd(String herdId, String userId) async {
    try {
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (herd.isPrivate) {
        await _createJoinRequest(herdId, userId);
        return;
      }

      await herdMembers(herdId).doc(userId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': false,
      });

      await userHerds(userId).doc(herdId).set({
        'joinedAt': FieldValue.serverTimestamp(),
        'isModerator': false,
        'name': herd.name,
      });

      await _herds.doc(herdId).update({
        'memberCount': FieldValue.increment(1),
      });
    } catch (e, stackTrace) {
      logError('joinHerd', e, stackTrace);
      rethrow;
    }
  }

  Future<void> leaveHerd(String herdId, String userId) async {
    try {
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (herd.creatorId == userId) {
        throw Exception(
            'Creators cannot leave their herds. Transfer ownership or delete the herd instead.');
      }

      await herdMembers(herdId).doc(userId).delete();

      await userHerds(userId).doc(herdId).delete();

      if (herd.moderatorIds.contains(userId)) {
        await _herds.doc(herdId).update({
          'moderatorIds': FieldValue.arrayRemove([userId]),
          'memberCount': FieldValue.increment(-1),
        });
      } else {
        await _herds.doc(herdId).update({
          'memberCount': FieldValue.increment(-1),
        });
      }
    } catch (e, stackTrace) {
      logError('leaveHerd', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> isHerdMember(String herdId, String userId) async {
    try {
      final doc = await herdMembers(herdId).doc(userId).get();
      return doc.exists;
    } catch (e, stackTrace) {
      logError('isHerdMember', e, stackTrace);
      rethrow;
    }
  }

  Future<bool> isHerdModerator(String herdId, String userId) async {
    try {
      final herd = await getHerd(herdId);
      if (herd == null) return false;

      if (herd.creatorId == userId) return true;

      final doc = await herdMembers(herdId).doc(userId).get();
      if (!doc.exists) return false;

      return doc.data()?['isModerator'] == true ||
          herd.moderatorIds.contains(userId);
    } catch (e, stackTrace) {
      logError('isHerdModerator', e, stackTrace);
      return false;
    }
  }

  Future<List<PostModel>> getHerdPosts({
    required String herdId,
    int limit = 15,
    double? lastHotScore,
    String? lastPostId,
  }) async {
    try {
      Query<Map<String, dynamic>> herdPostsQuery = _firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .orderBy('hotScore', descending: true);

      herdPostsQuery = herdPostsQuery.orderBy(FieldPath.documentId);

      if (lastHotScore != null && lastPostId != null) {
        herdPostsQuery = herdPostsQuery.startAfter([lastHotScore, lastPostId]);
      }

      herdPostsQuery = herdPostsQuery.limit(limit);

      final refSnapshot = await herdPostsQuery.get();

      if (refSnapshot.docs.isEmpty) {
        return [];
      }

      final postRefs = refSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'sourceCollection': data['sourceCollection'] ?? 'altPosts',
          'hotScore': data['hotScore'] ?? 0.0,
        };
      }).toList();

      List<PostModel> completePosts = [];

      for (int i = 0; i < postRefs.length; i += 10) {
        final end = (i + 10 < postRefs.length) ? i + 10 : postRefs.length;
        final batch = postRefs.sublist(i, end);
        final batchIds = batch.map((ref) => ref['id'] as String).toList();

        if (batchIds.isEmpty) continue;

        final altPostsQuery = _firestore
            .collection('altPosts')
            .where(FieldPath.documentId, whereIn: batchIds);

        final altPostsSnapshot = await altPostsQuery.get();
        final remainingIds = List<String>.from(batchIds);

        for (final doc in altPostsSnapshot.docs) {
          final postData = doc.data();
          final refIndex = batch.indexWhere((ref) => ref['id'] == doc.id);

          if (refIndex >= 0) {
            postData['hotScore'] = batch[refIndex]['hotScore'];
          }

          completePosts.add(PostModel.fromMap(doc.id, postData));
          remainingIds.remove(doc.id);
        }

        if (remainingIds.isNotEmpty) {
          final publicPostsQuery = _firestore
              .collection('posts')
              .where(FieldPath.documentId, whereIn: remainingIds);

          final publicPostsSnapshot = await publicPostsQuery.get();

          for (final doc in publicPostsSnapshot.docs) {
            final postData = doc.data();
            final refIndex = batch.indexWhere((ref) => ref['id'] == doc.id);
            if (refIndex >= 0) {
              postData['hotScore'] = batch[refIndex]['hotScore'];
            }
            completePosts.add(PostModel.fromMap(doc.id, postData));
          }
        }
      }

      completePosts
          .sort((a, b) => (b.hotScore ?? 0).compareTo(a.hotScore ?? 0));

      return completePosts;
    } catch (e, stackTrace) {
      logError('getHerdPosts', e, stackTrace);
      rethrow;
    }
  }

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

        final sortedPosts =
            applySortingAlgorithm(posts, decayFactor: decayFactor);
        return sortedPosts;
      });
    } catch (e, stackTrace) {
      logError('streamHerdPosts', e, stackTrace);
      rethrow;
    }
  }

  Future<List<HerdModel>> getUserHerds(String userId) async {
    try {
      final snapshot = await userHerds(userId).get();

      List<HerdModel> followedHerds = [];
      for (var doc in snapshot.docs) {
        final herdDoc = await _herds.doc(doc.id).get();
        if (herdDoc.exists) {
          followedHerds.add(HerdModel.fromMap(herdDoc.id, herdDoc.data()!));
        }
      }

      // Sort by name or any other field in memory
      followedHerds.sort((a, b) => a.name.compareTo(b.name));

      return followedHerds;
    } catch (e, stackTrace) {
      logError('getUserHerds', e, stackTrace);
      rethrow;
    }
  }

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

        userHerds.sort((a, b) => b.memberCount.compareTo(a.memberCount));

        return userHerds;
      });
    } catch (e, stackTrace) {
      logError('streamUserHerds', e, stackTrace);
      rethrow;
    }
  }

  Future<List<HerdModel>> getTrendingHerds({int limit = 10}) async {
    try {
      // Get herds ordered by memberCount + recent activity
      final snapshot = await _herds
          .orderBy('memberCount', descending: true)
          .limit(limit * 2)
          .get();

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

  Future<List<HerdModel>> searchHerds(String query, {int limit = 20}) async {
    try {
      final queryLower = query.toLowerCase();
      final snapshot = await _herds.limit(50).get();

      // Filter the herds client-side for any that contain the query string
      List<HerdModel> herds = snapshot.docs
          .map((doc) => HerdModel.fromMap(doc.id, doc.data()))
          .where((herd) =>
              herd.name.toLowerCase().contains(queryLower) ||
              (herd.description.toLowerCase().contains(queryLower)))
          .take(limit)
          .toList();
      return herds;
    } catch (e, stackTrace) {
      logError('searchHerds', e, stackTrace);
      rethrow;
    }
  }

  Future<void> addPostToHerd(
      String herdId, PostModel post, String userId) async {
    try {
      final isMember = await isHerdMember(herdId, userId);
      if (!isMember) {
        throw Exception('You must be a member of this herd to post');
      }

      await herdPosts(herdId).doc(post.id).set(post.toMap());

      await _herds.doc(herdId).update({
        'postCount': FieldValue.increment(1),
      });
    } catch (e, stackTrace) {
      logError('addPostToHerd', e, stackTrace);
      rethrow;
    }
  }

  Future<List<HerdMemberInfo>> getHerdMembersWithInfo(String herdId,
      {int limit = 20, String? lastUserId}) async {
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

      // Get member IDs and their herd-specific data
      List<HerdMemberInfo> membersInfo = [];

      for (var doc in snapshot.docs) {
        final memberId = doc.id;
        final memberData = doc.data();

        try {
          // Fetch user data from users collection
          final userDoc =
              await _firestore.collection('users').doc(memberId).get();

          if (userDoc.exists) {
            final user = UserModel.fromMap(userDoc.id, userDoc.data()!);

            membersInfo.add(HerdMemberInfo(
              userId: user.id,
              username: user.username,
              altUsername: user.altUsername,
              profileImageURL: user.profileImageURL,
              altProfileImageURL: user.altProfileImageURL,
              isVerified: user.isVerified,
              joinedAt: _parseDateTime(memberData['joinedAt']),
              isModerator: memberData['isModerator'] ?? false,
              userPoints: user.userPoints,
              altUserPoints: user.altUserPoints,
              isActive: user.isActive,
              bio: user.bio,
              altBio: user.altBio,
            ));
          }
        } catch (e) {
          // Log error but continue with other members
          debugPrint('Error fetching user data for member $memberId: $e');
        }
      }

      return membersInfo;
    } catch (e, stackTrace) {
      logError('getHerdMembersWithInfo', e, stackTrace);
      rethrow;
    }
  }

  Future<List<String>> getHerdMembers(String herdId,
      {int limit = 20, String? lastUserId}) async {
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

  Future<void> addModerator(
      String herdId, String userId, String currentUserId) async {
    try {
      final isModerator = await isHerdModerator(herdId, currentUserId);
      if (!isModerator) {
        throw Exception('You do not have permission to add moderators');
      }

      final isMember = await isHerdMember(herdId, userId);
      if (!isMember) {
        throw Exception(
            'User must be a member of the herd to become a moderator');
      }

      await _herds.doc(herdId).update({
        'moderatorIds': FieldValue.arrayUnion([userId]),
      });

      await herdMembers(herdId).doc(userId).update({
        'isModerator': true,
      });

      await userHerds(userId).doc(herdId).update({
        'isModerator': true,
      });
    } catch (e, stackTrace) {
      logError('addModerator', e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeModerator(
      String herdId, String userId, String currentUserId) async {
    try {
      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (herd.creatorId != currentUserId) {
        throw Exception('Only the creator can remove moderators');
      }

      if (herd.creatorId == userId) {
        throw Exception('Creator cannot be removed as moderator');
      }

      await _herds.doc(herdId).update({
        'moderatorIds': FieldValue.arrayRemove([userId]),
      });

      await herdMembers(herdId).doc(userId).update({
        'isModerator': false,
      });

      await userHerds(userId).doc(herdId).update({
        'isModerator': false,
      });
    } catch (e, stackTrace) {
      logError('removeModerator', e, stackTrace);
      rethrow;
    }
  }

  Future<void> banUser(
      String herdId, String userId, String currentUserId) async {
    try {
      final isModerator = await isHerdModerator(herdId, currentUserId);
      if (!isModerator) {
        throw Exception('You do not have permission to ban users');
      }

      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (herd.creatorId == userId) {
        throw Exception('Cannot ban the creator of the herd');
      }

      // If current user is not creator, they cannot ban other moderators
      if (herd.creatorId != currentUserId &&
          (herd.moderatorIds.contains(userId) || userId == herd.creatorId)) {
        throw Exception('Only the creator can ban moderators');
      }

      await herdMembers(herdId).doc(userId).delete();

      await userHerds(userId).doc(herdId).delete();
      if (herd.moderatorIds.contains(userId)) {
        await _herds.doc(herdId).update({
          'moderatorIds': FieldValue.arrayRemove([userId]),
          'memberCount': FieldValue.increment(-1),
        });
      } else {
        await _herds.doc(herdId).update({
          'memberCount': FieldValue.increment(-1),
        });
      }

      await _firestore
          .collection('herdBans')
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

  Future<void> unbanUser(
      String herdId, String userId, String currentUserId) async {
    try {
      final isModerator = await isHerdModerator(herdId, currentUserId);
      if (!isModerator) {
        throw Exception('You do not have permission to unban users');
      }

      await _firestore
          .collection('herdBans')
          .doc(herdId)
          .collection('banned')
          .doc(userId)
          .delete();

      await _herds.doc(herdId).update({
        'bannedUserIds': FieldValue.arrayRemove([userId]),
      });
    } catch (e, stackTrace) {
      logError('unbanUser', e, stackTrace);
      rethrow;
    }
  }

  Future<List<BannedUserInfo>> getBannedUsers(String herdId) async {
    try {
      final snapshot = await _firestore
          .collection('herdBans')
          .doc(herdId)
          .collection('banned')
          .get();

      List<BannedUserInfo> bannedUsers = [];

      for (var doc in snapshot.docs) {
        final userId = doc.id;
        final banData = doc.data();

        try {
          final userDoc =
              await _firestore.collection('users').doc(userId).get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;

            String? bannedByUsername;
            if (banData['bannedBy'] != null) {
              final bannedByDoc = await _firestore
                  .collection('users')
                  .doc(banData['bannedBy'])
                  .get();
              if (bannedByDoc.exists) {
                bannedByUsername = bannedByDoc.data()?['username'];
              }
            }

            bannedUsers.add(BannedUserInfo.fromMap(
              userId: userId,
              userData: userData,
              banData: banData,
              bannedByUsername: bannedByUsername,
            ));
          }
        } catch (e) {
          debugPrint('Error fetching banned user data for $userId: $e');
        }
      }

      return bannedUsers;
    } catch (e, stackTrace) {
      logError('getBannedUsers', e, stackTrace);
      rethrow;
    }
  }

  /// Check user eligibility to create a herd
  Future<bool> checkUserEligibility(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return false;

      final userData = userDoc.data()!;

      if (userData['isActive'] != true) return false;

      if (userData['accountStatus'] != 'active') return false;

      // Additional eligibility checks can be added here
      // For example: minimum account age, user points, etc.

      return true;
    } catch (e, stackTrace) {
      debugPrint('checkUserEligibility error: $e\nStack: $stackTrace');
      return false;
    }
  }

  Future<void> _createJoinRequest(String herdId, String userId) async {
    try {
      await _firestore
          .collection('herdJoinRequests')
          .doc(herdId)
          .collection('requests')
          .doc(userId)
          .set({
        'requestedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
    } catch (e, stackTrace) {
      debugPrint('_createJoinRequest error: $e\nStack: $stackTrace');
      rethrow;
    }
  }

  int calculateNetVotes(PostModel post) {
    return post.likeCount - post.dislikeCount;
  }

  List<PostModel> applySortingAlgorithm(List<PostModel> posts,
      {double decayFactor = 1.0}) {
    return HotAlgorithm.sortByHotScore(posts, (post) => calculateNetVotes(post),
        (post) => post.createdAt ?? DateTime.now(),
        decayFactor: decayFactor);
  }

  void logError(String operation, Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('Herd Repository Error during $operation: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }

  Future<void> pinPostToHerd(
      String herdId, String postId, String userId) async {
    try {
      // Check if user is a moderator of the herd
      final isModerator = await isHerdModerator(herdId, userId);
      if (!isModerator) {
        throw Exception('Only moderators can pin posts in this herd');
      }

      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (herd.pinnedPosts.contains(postId)) {
        throw Exception('Post is already pinned');
      }

      if (herd.pinnedPosts.length >= 5) {
        throw Exception('Maximum number of pinned posts reached (5)');
      }

      final postDoc = await herdPosts(herdId).doc(postId).get();
      if (!postDoc.exists) {
        throw Exception('Post not found in this herd');
      }

      final updatedPinned = [...herd.pinnedPosts, postId];

      await _herds.doc(herdId).update({
        'pinnedPosts': updatedPinned,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _updateHerdPostPinStatus(herdId, postId, isPinned: true);
    } catch (e, stackTrace) {
      logError('pinPostToHerd', e, stackTrace);
      rethrow;
    }
  }

  Future<void> unpinPostFromHerd(
      String herdId, String postId, String userId) async {
    try {
      final isModerator = await isHerdModerator(herdId, userId);
      if (!isModerator) {
        throw Exception('Only moderators can unpin posts in this herd');
      }

      final herd = await getHerd(herdId);
      if (herd == null) {
        throw Exception('Herd not found');
      }

      if (!herd.pinnedPosts.contains(postId)) {
        throw Exception('Post is not pinned');
      }

      final updatedPinned =
          herd.pinnedPosts.where((id) => id != postId).toList();

      await _herds.doc(herdId).update({
        'pinnedPosts': updatedPinned,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await _updateHerdPostPinStatus(herdId, postId, isPinned: false);
    } catch (e, stackTrace) {
      logError('unpinPostFromHerd', e, stackTrace);
      rethrow;
    }
  }

  Future<List<String?>> getHerdPinnedPosts(String herdId) async {
    try {
      final herd = await getHerd(herdId);
      return herd?.pinnedPosts ?? [];
    } catch (e, stackTrace) {
      logError('getHerdPinnedPosts', e, stackTrace);
      return [];
    }
  }

  Future<bool> isPostPinnedToHerd(String herdId, String postId) async {
    try {
      final pinnedPosts = await getHerdPinnedPosts(herdId);
      return pinnedPosts.contains(postId);
    } catch (e, stackTrace) {
      logError('isPostPinnedToHerd', e, stackTrace);
      return false;
    }
  }

  Future<List<PostModel>> fetchHerdPinnedPosts(String herdId) async {
    try {
      final pinnedPostIds = await getHerdPinnedPosts(herdId);
      if (pinnedPostIds.isEmpty) return [];

      List<PostModel> pinnedPosts = [];

      // Fetch each pinned post
      for (final postId in pinnedPostIds) {
        try {
          final postDoc = await herdPosts(herdId).doc(postId).get();
          if (postDoc.exists) {
            final post = PostModel.fromMap(postDoc.id, postDoc.data()!);
            pinnedPosts.add(post);
          }
        } catch (e) {
          debugPrint('Error fetching pinned post $postId: $e');
          // Continue with other posts
        }
      }

      pinnedPosts.sort((a, b) {
        if (a.pinnedAt == null && b.pinnedAt == null) return 0;
        if (a.pinnedAt == null) return 1;
        if (b.pinnedAt == null) return -1;
        return b.pinnedAt!.compareTo(a.pinnedAt!);
      });

      return pinnedPosts;
    } catch (e, stackTrace) {
      logError('fetchHerdPinnedPosts', e, stackTrace);
      return [];
    }
  }

  /// Helper method to update post pin status in herd post
  Future<void> _updateHerdPostPinStatus(String herdId, String postId,
      {required bool isPinned}) async {
    try {
      final updateData = <String, dynamic>{
        'isPinnedToHerd': isPinned,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (isPinned) {
        updateData['pinnedAt'] = FieldValue.serverTimestamp();
      } else {
        updateData['pinnedAt'] = null;
      }

      await herdPosts(herdId).doc(postId).update(updateData);
    } catch (e) {
      debugPrint('Error updating herd post pin status: $e');
      // Don't rethrow here as this is a secondary update
    }
  }

  bool _isValidHerdName(String name) {
    // Allow only letters, numbers, and basic punctuation (no spaces or dashes)
    final regex = RegExp(r'^[a-zA-Z0-9\.\,\!\?]+$');
    return regex.hasMatch(name.trim());
  }

  /// Check if a herd name already exists (case insensitive)
  Future<bool> _herdNameExists(String name) async {
    try {
      final normalizedName = name.toLowerCase().trim();
      final querySnapshot =
          await _herds.where('name', isEqualTo: normalizedName).limit(1).get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e, stackTrace) {
      logError('_herdNameExists', e, stackTrace);
      return false; // In case of error, allow creation to proceed
    }
  }

  /// Public method to check if herd name exists (for real-time validation)
  Future<bool> checkHerdNameExists(String name) async {
    return await _herdNameExists(name);
  }

  /// Validate herd creation requirements
  Future<void> _validateHerdCreation(String name) async {
    if (name.trim().isEmpty) {
      throw Exception('Herd name cannot be empty');
    }

    if (name.length > 30) {
      throw Exception('Herd name cannot be longer than 30 characters');
    }

    if (name.contains(' ')) {
      throw Exception('Herd name cannot contain spaces');
    }

    if (!_isValidHerdName(name)) {
      throw Exception(
          'Herd name can only contain letters, numbers, and basic punctuation (. , ! ?) - no spaces or dashes allowed');
    }

    final nameExists = await _herdNameExists(name);
    if (nameExists) {
      throw Exception(
          'A herd with this name already exists. Please choose a different name.');
    }
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
