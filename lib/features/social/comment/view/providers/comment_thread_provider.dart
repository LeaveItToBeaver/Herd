import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/comment/data/models/comment_model.dart';
import 'package:herdapp/features/social/comment/data/repositories/comment_repository.dart';
import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';

part 'comment_thread_provider.g.dart';

@riverpod
class CommentThread extends _$CommentThread {
  late final String _commentId;
  late final CommentRepository _repository;
  late final FirebaseFirestore _firestore;
  String? _postId;

  @override
  CommentThreadState? build({required String commentId, String? postId}) {
    _commentId = commentId;
    _postId = postId;
    _repository = ref.watch(commentRepositoryProvider);
    _firestore = FirebaseFirestore.instance;

    // Load the thread when created
    loadThread();

    return null;
  }

  Future<void> loadThread() async {
    try {
      // First get the parent comment to determine postId
      // You need to query all comments collections to find where this comment is
      final commentDoc = await _getCommentDoc();

      if (commentDoc == null || !commentDoc.exists) {
        throw Exception('Comment not found');
      }

      final parentComment = CommentModel.fromFirestore(commentDoc);
      _postId = parentComment.postId; // Store the postId for later queries

      // Then load its replies using the correct postId
      if (_postId != null) {
        final replies = await _repository.getReplies(
          postId: _postId!,
          commentId: _commentId,
          limit: 30,
        );

        // Check if still mounted after async operation
        if (!ref.mounted) return;

        state = CommentThreadState(
          parentComment: parentComment,
          replies: replies,
          hasMore: replies.length >= 30,
          lastDocument: replies.isNotEmpty
              ? await _getLastDocument(replies.last.id)
              : null,
        );
      } else {
        throw Exception('Unable to determine post ID for comment');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading thread: $e');
      }
      // State remains null to indicate error
    }
  }

  Future<DocumentSnapshot?> _getCommentDoc() async {
    if (_postId != null) {
      // If we already know the postId, use it directly
      return await _firestore
          .collection('comments')
          .doc(_postId)
          .collection('postComments')
          .doc(_commentId)
          .get();
    }

    final postsSnapshot = await _firestore.collection('posts').limit(50).get();

    for (final postDoc in postsSnapshot.docs) {
      final postId = postDoc.id;

      final commentDoc = await _firestore
          .collection('comments')
          .doc(postId)
          .collection('postComments')
          .doc(_commentId)
          .get();

      if (commentDoc.exists) {
        _postId = postId;
        return commentDoc;
      }
    }

    final altPostsSnapshot =
        await _firestore.collection('altPosts').limit(50).get();

    for (final postDoc in altPostsSnapshot.docs) {
      final postId = postDoc.id;

      final commentDoc = await _firestore
          .collection('comments')
          .doc(postId)
          .collection('postComments')
          .doc(_commentId)
          .get();

      if (commentDoc.exists) {
        _postId = postId;
        return commentDoc;
      }
    }

    return null;
  }

  Future<void> loadMoreReplies() async {
    if (state == null ||
        state!.isLoading ||
        !state!.hasMore ||
        _postId == null) {
      return;
    }

    try {
      state = state!.copyWith(isLoading: true);

      final replies = await _repository.getReplies(
        postId: _postId!,
        commentId: _commentId,
        limit: 30,
        startAfter: state!.lastDocument,
      );

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      state = state!.copyWith(
        replies: [...state!.replies, ...replies],
        isLoading: false,
        hasMore: replies.length >= 30,
        lastDocument: replies.isNotEmpty
            ? await _getLastDocument(replies.last.id)
            : state!.lastDocument,
      );
    } catch (e) {
      // Check if still mounted before updating error state
      if (!ref.mounted) return;

      state = state!.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Helper to get document for pagination
  Future<DocumentSnapshot?> _getLastDocument(String commentId) async {
    if (_postId == null) return null;

    try {
      return await _firestore
          .collection('comments')
          .doc(_postId)
          .collection('postComments')
          .doc(commentId)
          .get();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting document: $e');
      }
      return null;
    }
  }
}
