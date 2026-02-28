import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/exception_logging_service.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

final pinnedPostRepositoryProvider = Provider<PinnedPostRepository>((ref) {
  return PinnedPostRepository(FirebaseFirestore.instance);
});

class PinnedPostRepository {
  final FirebaseFirestore _firestore;
  final ExceptionLoggerService _logger = ExceptionLoggerService();

  PinnedPostRepository(this._firestore);

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

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

  Future<void> pinPostToProfile(String userId, String postId,
      {bool isAlt = false}) async {
    try {
      final user = await _getUserById(userId);
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

      await _updateUser(userId, updatedPinned);

      // Update the post document to mark it as pinned
      await _updatePostPinStatus(postId,
          isAlt: isAlt, isPinned: true, userId: userId);
    } catch (e) {
      debugPrint('Error pinning post to profile: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'pinPostToProfile',
        route: 'PinnedPostRepository',
        userId: userId,
        errorDetails: {'postId': postId, 'isAlt': isAlt},
      );
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
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: '_updatePostPinStatus',
        route: 'PinnedPostRepository',
        userId: userId,
        errorDetails: {
          'postId': postId,
          'isAlt': isAlt,
          'isPinned': isPinned,
        },
      );
      // Don't rethrow here as this is a secondary update
    }
  }

  Future<void> unpinPostFromProfile(String userId, String postId,
      {bool isAlt = false}) async {
    try {
      // Get current user data
      final user = await _getUserById(userId);
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

      await _updateUser(userId, updateData);

      // Update the post document to mark it as unpinned
      await _updatePostPinStatus(postId,
          isAlt: isAlt, isPinned: false, userId: userId);
    } catch (e) {
      debugPrint('Error unpinning post from profile: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'unpinPostFromProfile',
        route: 'PinnedPostRepository',
        userId: userId,
        errorDetails: {'postId': postId, 'isAlt': isAlt},
      );
      rethrow;
    }
  }

  /// Get pinned posts for a user profile
  Future<List<String>> getPinnedPosts(String userId,
      {bool isAlt = false}) async {
    try {
      final user = await _getUserById(userId);
      if (user == null) return [];

      return isAlt ? user.altPinnedPosts : user.pinnedPosts;
    } catch (e) {
      debugPrint('Error getting pinned posts: $e');
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'getPinnedPosts',
        route: 'PinnedPostRepository',
        userId: userId,
        errorDetails: {'isAlt': isAlt},
      );
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
      _logger.logException(
        errorMessage: e.toString(),
        stackTrace: StackTrace.current.toString(),
        action: 'isPostPinnedToProfile',
        route: 'PinnedPostRepository',
        userId: userId,
        errorDetails: {'postId': postId, 'isAlt': isAlt},
      );
      return false;
    }
  }
}
