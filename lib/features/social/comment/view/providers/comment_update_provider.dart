import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/comment/view/providers/comment_providers.dart';
import 'package:herdapp/features/social/comment/view/providers/reply_providers.dart';
import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';

final commentUpdateProvider = StateProvider<int>((ref) => 0);

class CommentsNotifier extends StateNotifier<CommentState> {
  final CommentRepository _repository;
  final String _postId;
  String _sortBy;

  CommentsNotifier(this._repository, this._postId, this._sortBy)
      : super(CommentState.initial().copyWith(sortBy: _sortBy)) {
    // Load initial comments
    loadComments();
  }

  Future<void> invalidateRelatedProviders(
      WidgetRef ref, String postId, String? parentId) async {
    try {
      // Invalidate providers
      ref.invalidate(commentsProvider(postId));
      ref.invalidate(repliesProvider(postId));

      // Don't call loadComments() directly here
      // Instead, let the UI reload data as needed

      if (parentId != null) {
        ref.invalidate(
            commentThreadProvider((commentId: parentId, postId: postId)));
      } else {
        ref.invalidate(
            commentThreadProvider((commentId: _postId, postId: postId)));
      }

      // The UI should handle refreshing data after invalidation
    } catch (e) {
      if (kDebugMode) {
        print('Error invalidating providers: $e');
      }
    }
  }

  Future<void> loadComments() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final comments = await _repository.getComments(
        postId: _postId,
        sortBy: state.sortBy,
        limit: 30,
      );

      state = state.copyWith(
        comments: comments,
        isLoading: false,
        hasMore: comments.length >= 30,
        lastDocument: comments.isNotEmpty
            ? await _getLastDocument(comments.last.id)
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreComments() async {
    if (state.isLoading || !state.hasMore) return;

    try {
      state = state.copyWith(isLoading: true);

      final comments = await _repository.getComments(
        postId: _postId,
        sortBy: state.sortBy,
        limit: 30,
        startAfter: state.lastDocument,
      );

      state = state.copyWith(
        comments: [...state.comments, ...comments],
        isLoading: false,
        hasMore: comments.length >= 30,
        lastDocument: comments.isNotEmpty
            ? await _getLastDocument(comments.last.id)
            : state.lastDocument,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> changeSortBy(String sortBy) async {
    if (sortBy == state.sortBy) return;

    _sortBy = sortBy;
    state = state.copyWith(
      sortBy: sortBy,
      comments: [],
      isLoading: false,
      hasMore: true,
      lastDocument: null,
    );

    await loadComments();
  }

  Future<CommentModel> createComment({
    required String authorId,
    required String content,
    String? parentId,
    String? authorProfileImage,
    String? authorUsername,
    String? authorName,
    String? authorAltProfileImage,
    bool isAltPost = false,
    File? mediaFile,
    required WidgetRef ref,
  }) async {
    try {
      final comment = await _repository.createComment(
        postId: _postId,
        authorId: authorId,
        content: content,
        authorProfileImage: authorProfileImage ?? '',
        authorUsername: authorUsername ?? '',
        authorName: authorName ?? 'Anonymous',
        authorAltProfileImage: authorAltProfileImage ?? '',
        parentId: parentId,
        isAuthorAlt: isAltPost,
        isAltPost: isAltPost,
        mediaFile: mediaFile,
      );

      try {
        // If it's a top-level comment, add to the list
        if (parentId == null) {
          state = state.copyWith(
            comments: [comment, ...state.comments],
          );
        }

        // If comment has parent within our list, increment its reply count
        if (parentId != null) {
          final updatedComments = state.comments.map((c) {
            if (c.id == parentId) {
              return c.copyWith(replyCount: c.replyCount + 1);
            }
            return c;
          }).toList();

          state = state.copyWith(comments: updatedComments);
        }

        // Invalidate the replies provider for this post
        invalidateRelatedProviders(ref, _postId, parentId);
      } catch (e) {
        if (kDebugMode) {
          print('Error uploading comment: $e');
        }
      }

      return comment;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating comment: $e');
      }
      rethrow;
    }
  }

  // Helper method to get Firestore document for pagination
  Future<DocumentSnapshot?> _getLastDocument(String commentId) async {
    try {
      return await FirebaseFirestore.instance
          .collection('comments')
          .doc(_postId) // Use postId, not commentId
          .collection('postComments') // Include the subcollection
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
