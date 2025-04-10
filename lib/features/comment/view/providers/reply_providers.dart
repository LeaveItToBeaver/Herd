import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';
import 'state/reply_state.dart';

// Provider to store all replies for a post
final repliesProvider =
    StateNotifierProvider.family<RepliesNotifier, ReplyState, String>(
        (ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  return RepliesNotifier(repository, postId);
});

class RepliesNotifier extends StateNotifier<ReplyState> {
  final CommentRepository _repository;
  final String _postId;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RepliesNotifier(this._repository, this._postId)
      : super(ReplyState.initial()) {
    // Load initial replies
    loadReplies();
  }

  Future<void> loadReplies() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Query all comments that have a parentId (meaning they're replies)
      final querySnapshot = await _firestore
          .collection('comments')
          .doc(_postId)
          .collection('postComments')
          .where('parentId', isNull: false)
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      final replies = querySnapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        replies: replies,
        isLoading: false,
        hasMore: replies.length >= 50,
        lastDocument: replies.isNotEmpty ? querySnapshot.docs.last : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreReplies() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final querySnapshot = await _firestore
          .collection('comments')
          .doc(_postId)
          .collection('postComments')
          .where('parentId', isNull: false)
          .orderBy('timestamp', descending: true)
          .startAfterDocument(state.lastDocument!)
          .limit(50)
          .get();

      final replies = querySnapshot.docs
          .map((doc) => CommentModel.fromFirestore(doc))
          .toList();

      state = state.copyWith(
        replies: [...state.replies, ...replies],
        isLoading: false,
        hasMore: replies.length >= 50,
        lastDocument:
            replies.isNotEmpty ? querySnapshot.docs.last : state.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  // Add a reply to a comment
  Future<CommentModel> addReply({
    required String parentId,
    required String authorId,
    required String content,
    bool isAltPost = false,
    File? mediaFile,
  }) async {
    try {
      final reply = await _repository.createComment(
        postId: _postId,
        authorId: authorId,
        content: content,
        parentId: parentId,
        isAltPost: isAltPost,
        mediaFile: mediaFile,
      );

      // Add to local state if we need immediate UI update
      state = state.copyWith(
        replies: [reply, ...state.replies],
      );

      return reply;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating reply: $e');
      }
      rethrow;
    }
  }

  // Get replies for a specific comment
  List<CommentModel> getRepliesForComment(String commentId) {
    return state.replies.where((reply) => reply.parentId == commentId).toList();
  }

  // Check if a comment has replies
  bool hasReplies(String commentId) {
    return state.replies.any((reply) => reply.parentId == commentId);
  }
}
