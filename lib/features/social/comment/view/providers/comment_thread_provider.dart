import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/social/comment/data/models/comment_model.dart';
import 'package:herdapp/features/social/comment/data/repositories/comment_repository.dart';
import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';

final commentThreadProvider = StateNotifierProvider.family<
    CommentThreadNotifier,
    CommentThreadState?,
    ({String commentId, String? postId})>((ref, params) {
  final repository = ref.watch(commentRepositoryProvider);
  return CommentThreadNotifier(repository, params.commentId, params.postId);
});

class CommentThreadNotifier extends StateNotifier<CommentThreadState?> {
  final CommentRepository _repository;
  final String _commentId;
  final FirebaseFirestore _firestore;
  String? _postId;

  CommentThreadNotifier(this._repository, this._commentId, String? postId,
      {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        super(null) {
    // Load the thread when created
    loadThread();
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

      state = state!.copyWith(
        replies: [...state!.replies, ...replies],
        isLoading: false,
        hasMore: replies.length >= 30,
        lastDocument: replies.isNotEmpty
            ? await _getLastDocument(replies.last.id)
            : state!.lastDocument,
      );
    } catch (e) {
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
