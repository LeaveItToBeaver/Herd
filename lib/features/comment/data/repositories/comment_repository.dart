// lib/features/comment/data/repositories/comment_repository.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import '../models/comment_model.dart';

class CommentRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  CommentRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  }) :
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get commentsCollection =>
      _firestore.collection('comments');

  // Create a new comment
  Future<CommentModel> createComment({
    required String postId,
    required String authorId,
    required String content,
    String? parentId,
    bool isPrivatePost = false,
    File? mediaFile,
  }) async {
    try {
      // Generate a new document ID
      final commentRef = commentsCollection.doc();
      final commentId = commentRef.id;

      // Create path based on parent
      String path;
      int depth;

      if (parentId == null) {
        // Top-level comment
        path = '$postId/$commentId';
        depth = 0;
      } else {
        // Get parent comment to determine path
        final parentDoc = await commentsCollection.doc(parentId).get();
        if (!parentDoc.exists) {
          throw Exception('Parent comment not found');
        }

        final parentData = parentDoc.data()!;
        path = '${parentData['path']}/$commentId';
        depth = (parentData['depth'] as int) + 1;

        // Increment reply count on parent
        await commentsCollection.doc(parentId).update({
          'replyCount': FieldValue.increment(1),
        });
      }

      // Upload media if provided
      String? mediaUrl;
      if (mediaFile != null) {
        mediaUrl = await _uploadCommentMedia(
          commentId: commentId,
          postId: postId,
          file: mediaFile,
        );
      }

      // Get author details
      final userDoc = await _firestore.collection('users').doc(authorId).get();
      final userData = userDoc.data();

      // Select appropriate profile image based on post privacy
      final profileImageUrl = isPrivatePost && userData?['privateProfileImageURL'] != null
          ? userData!['privateProfileImageURL']
          : userData?['profileImageURL'];

      // Create comment model
      final comment = CommentModel(
        id: commentId,
        postId: postId,
        authorId: authorId,
        content: content,
        timestamp: DateTime.now(),
        parentId: parentId,
        path: path,
        depth: depth,
        authorUsername: userData?['username'] ?? 'Unknown',
        authorProfileImage: profileImageUrl,
        isPrivatePost: isPrivatePost,
        mediaUrl: mediaUrl,
        likeCount: 0,
        dislikeCount: 0,
        replyCount: 0,
      );

      // Save to Firestore
      await commentRef.set(comment.toFirestore());

      // Update comment count on the post
      await _firestore.collection(isPrivatePost ? 'globalPrivatePosts' : 'posts')
          .doc(postId)
          .update({
        'commentCount': FieldValue.increment(1),
      });

      return comment;
    } catch (e) {
      debugPrint('Error creating comment: $e');
      rethrow;
    }
  }

  // Upload media for comment
  Future<String> _uploadCommentMedia({
    required String commentId,
    required String postId,
    required File file,
  }) async {
    try {
      // Create reference for the file
      final ref = _storage.ref()
          .child('posts/$postId/comments/$commentId/media');

      // Upload file
      final uploadTask = await ref.putFile(file);

      // Get download URL
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading comment media: $e');
      rethrow;
    }
  }

  // Get comments for a post with pagination
  Future<List<CommentModel>> getComments({
    required String postId,
    String sortBy = 'hot',
    int limit = 30,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = commentsCollection
          .where('postId', isEqualTo: postId)
          .where('parentId', isNull: true) // Top-level comments only
          .orderBy('timestamp', descending: true); // Default order

      // Apply sorting
      switch (sortBy) {
        case 'newest':
          query = query.orderBy('timestamp', descending: true);
          break;
        case 'mostLiked':
          query = query.orderBy('likeCount', descending: true);
          break;
        case 'hot':
        default:
        // For 'hot', we'll order by timestamp initially
        // and then apply our algorithm later
          query = query.orderBy('timestamp', descending: true);
          break;
      }

      // Apply pagination
      query = query.limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      final comments = querySnapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();

      // For 'hot' sorting, apply algorithm in memory
      if (sortBy == 'hot') {
        _sortCommentsByHotness(comments);
      }

      return comments;
    } catch (e) {
      debugPrint('Error getting comments: $e');
      rethrow;
    }
  }

  // Get replies to a specific comment with pagination
  Future<List<CommentModel>> getReplies({
    required String commentId,
    int limit = 30,
    DocumentSnapshot? startAfter,
  }) async {
    try {
      Query<Map<String, dynamic>> query = commentsCollection
          .where('parentId', isEqualTo: commentId)
          .orderBy('timestamp'); // Chronological order for replies

      // Apply pagination
      query = query.limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting replies: $e');
      rethrow;
    }
  }

  // Get entire thread (all descendants of a comment)
  Future<List<CommentModel>> getThread({
    required String commentId,
  }) async {
    try {
      // First get the parent comment to get its path
      final parentDoc = await commentsCollection.doc(commentId).get();
      if (!parentDoc.exists) {
        throw Exception('Comment not found');
      }

      final parentPath = parentDoc.data()!['path'] as String;

      // Then get all replies that have this path as prefix
      final querySnapshot = await commentsCollection
          .where('path', isGreaterThanOrEqualTo: parentPath)
          .where('path', isLessThan: parentPath + '\uf8ff')
          .orderBy('path')
          .orderBy('timestamp')
          .get();

      return querySnapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error getting thread: $e');
      rethrow;
    }
  }

  // Like or unlike a comment
  Future<void> toggleLikeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      // Use a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Get the comment document
        final commentDoc = await transaction.get(commentsCollection.doc(commentId));
        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        // Check if user already liked the comment
        final likeDoc = await transaction.get(
            _firestore.collection('commentLikes')
                .doc(commentId)
                .collection('users')
                .doc(userId)
        );

        if (likeDoc.exists) {
          // Remove like
          transaction.delete(
              _firestore.collection('commentLikes')
                  .doc(commentId)
                  .collection('users')
                  .doc(userId)
          );

          // Decrement like count
          transaction.update(
              commentsCollection.doc(commentId),
              {'likeCount': FieldValue.increment(-1)}
          );
        } else {
          // Add like
          transaction.set(
              _firestore.collection('commentLikes')
                  .doc(commentId)
                  .collection('users')
                  .doc(userId),
              {'timestamp': FieldValue.serverTimestamp()}
          );

          // Check if user previously disliked
          final dislikeDoc = await transaction.get(
              _firestore.collection('commentDislikes')
                  .doc(commentId)
                  .collection('users')
                  .doc(userId)
          );

          if (dislikeDoc.exists) {
            // Remove dislike
            transaction.delete(
                _firestore.collection('commentDislikes')
                    .doc(commentId)
                    .collection('users')
                    .doc(userId)
            );

            // Decrement dislike count
            transaction.update(
                commentsCollection.doc(commentId),
                {'dislikeCount': FieldValue.increment(-1)}
            );
          }

          // Increment like count
          transaction.update(
              commentsCollection.doc(commentId),
              {'likeCount': FieldValue.increment(1)}
          );
        }
      });
    } catch (e) {
      debugPrint('Error toggling like: $e');
      rethrow;
    }
  }

  // Dislike or un-dislike a comment
  Future<void> toggleDislikeComment({
    required String commentId,
    required String userId,
  }) async {
    try {
      // Use a transaction to ensure atomicity
      await _firestore.runTransaction((transaction) async {
        // Get the comment document
        final commentDoc = await transaction.get(commentsCollection.doc(commentId));
        if (!commentDoc.exists) {
          throw Exception('Comment not found');
        }

        // Check if user already disliked the comment
        final dislikeDoc = await transaction.get(
            _firestore.collection('commentDislikes')
                .doc(commentId)
                .collection('users')
                .doc(userId)
        );

        if (dislikeDoc.exists) {
          // Remove dislike
          transaction.delete(
              _firestore.collection('commentDislikes')
                  .doc(commentId)
                  .collection('users')
                  .doc(userId)
          );

          // Decrement dislike count
          transaction.update(
              commentsCollection.doc(commentId),
              {'dislikeCount': FieldValue.increment(-1)}
          );
        } else {
          // Add dislike
          transaction.set(
              _firestore.collection('commentDislikes')
                  .doc(commentId)
                  .collection('users')
                  .doc(userId),
              {'timestamp': FieldValue.serverTimestamp()}
          );

          // Check if user previously liked
          final likeDoc = await transaction.get(
              _firestore.collection('commentLikes')
                  .doc(commentId)
                  .collection('users')
                  .doc(userId)
          );

          if (likeDoc.exists) {
            // Remove like
            transaction.delete(
                _firestore.collection('commentLikes')
                    .doc(commentId)
                    .collection('users')
                    .doc(userId)
            );

            // Decrement like count
            transaction.update(
                commentsCollection.doc(commentId),
                {'likeCount': FieldValue.increment(-1)}
            );
          }

          // Increment dislike count
          transaction.update(
              commentsCollection.doc(commentId),
              {'dislikeCount': FieldValue.increment(1)}
          );
        }
      });
    } catch (e) {
      debugPrint('Error toggling dislike: $e');
      rethrow;
    }
  }

  // Check if a comment is liked by a user
  Future<bool> isCommentLikedByUser({
    required String commentId,
    required String userId,
  }) async {
    final doc = await _firestore
        .collection('commentLikes')
        .doc(commentId)
        .collection('users')
        .doc(userId)
        .get();

    return doc.exists;
  }

  // Check if a comment is disliked by a user
  Future<bool> isCommentDislikedByUser({
    required String commentId,
    required String userId,
  }) async {
    final doc = await _firestore
        .collection('commentDislikes')
        .doc(commentId)
        .collection('users')
        .doc(userId)
        .get();

    return doc.exists;
  }

  // Delete a comment
  Future<void> deleteComment({
    required String commentId,
    required String authorId,
    required String postId,
    required bool isPrivatePost,
  }) async {
    try {
      // Get the comment first to check authorization
      final commentDoc = await commentsCollection.doc(commentId).get();
      if (!commentDoc.exists) {
        throw Exception('Comment not found');
      }

      final commentData = commentDoc.data()!;

      // Only allow if user is the author
      if (commentData['authorId'] != authorId) {
        throw Exception('Not authorized to delete this comment');
      }

      // Check if comment has replies
      final repliesSnapshot = await commentsCollection
          .where('parentId', isEqualTo: commentId)
          .limit(1)
          .get();

      if (repliesSnapshot.docs.isNotEmpty) {
        // If comment has replies, just mark content as deleted but keep the structure
        await commentsCollection.doc(commentId).update({
          'content': '[deleted]',
          'mediaUrl': null,
          'authorUsername': '[deleted]',
          'authorProfileImage': null,
        });
      } else {
        // If no replies, delete the comment completely
        await commentsCollection.doc(commentId).delete();

        // If comment has a parent, decrement its reply count
        if (commentData['parentId'] != null) {
          await commentsCollection.doc(commentData['parentId']).update({
            'replyCount': FieldValue.increment(-1),
          });
        }

        // Update post comment count
        await _firestore
            .collection(isPrivatePost ? 'globalPrivatePosts' : 'posts')
            .doc(postId)
            .update({
          'commentCount': FieldValue.increment(-1),
        });
      }
    } catch (e) {
      debugPrint('Error deleting comment: $e');
      rethrow;
    }
  }

  // Helper function to sort comments by "hotness"
  void _sortCommentsByHotness(List<CommentModel> comments) {
    // For now we'll use a simple algorithm similar to Reddit's
    // Log(likes - dislikes) + (timestamp / 45000)
    final now = DateTime.now();
    comments.sort((a, b) {
      final aScore = _calculateHotScore(a, now);
      final bScore = _calculateHotScore(b, now);
      return bScore.compareTo(aScore); // Descending order
    });
  }

  double _calculateHotScore(CommentModel comment, DateTime now) {
    final netVotes = comment.likeCount - comment.dislikeCount;
    final order = netVotes > 0
        ? log(netVotes) / ln10
        : netVotes < 0
        ? -log(-netVotes) / ln10
        : 0;

    final secondsAgo = now.difference(comment.timestamp).inSeconds;
    const decay = 45000; // Tune this value based on your needs

    return order + secondsAgo / decay;
  }

  // Log base 10 constants
  static const double ln10 = 2.302585092994046;
}

// Provider for the repository
final commentRepositoryProvider = Provider<CommentRepository>((ref) {
  return CommentRepository();
});