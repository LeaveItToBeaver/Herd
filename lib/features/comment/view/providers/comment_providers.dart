import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/comment/view/providers/reply_providers.dart';
import 'package:herdapp/features/comment/view/providers/state/comment_state.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';

import '../../../user/view/providers/current_user_provider.dart';
import '../../data/models/comment_model.dart';
import '../../data/repositories/comment_repository.dart';

final commentSortProvider = StateProvider<String>((ref) => 'hot');

// Provider for the expanded comments (which comments should show their replies)
final expandedCommentsProvider =
    StateNotifierProvider<ExpandedCommentsNotifier, ExpandedCommentsState>(
        (ref) {
  return ExpandedCommentsNotifier();
});

class ExpandedCommentsNotifier extends StateNotifier<ExpandedCommentsState> {
  ExpandedCommentsNotifier() : super(ExpandedCommentsState.initial());

  void toggleExpanded(String commentId) {
    final expandedIds = Set<String>.from(state.expandedCommentIds);
    if (expandedIds.contains(commentId)) {
      expandedIds.remove(commentId);
    } else {
      expandedIds.add(commentId);
    }
    state = state.copyWith(expandedCommentIds: expandedIds);
  }

  void collapseAll() {
    state = state.copyWith(expandedCommentIds: {});
  }
}

// Provider for comment list for a specific post
final commentsProvider =
    StateNotifierProvider.family<CommentsNotifier, CommentState, String>(
        (ref, postId) {
  final repository = ref.watch(commentRepositoryProvider);
  final sortBy = ref.watch(commentSortProvider);
  return CommentsNotifier(repository, postId, sortBy);
});

// Provider for comment update count
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

final commentInteractionProvider = StateNotifierProvider.family<
    CommentInteractionNotifier,
    CommentInteractionState,
    ({String commentId, String postId})>((ref, params) {
  final repository = ref.watch(commentRepositoryProvider);
  final currentUser = ref.read(currentUserProvider);

  // Use the extension method to safely extract the ID
  final userId = currentUser.userId ?? '';

  return CommentInteractionNotifier(
      repository, params.commentId, userId, params.postId);
});

class CommentInteractionNotifier
    extends StateNotifier<CommentInteractionState> {
  final CommentRepository _repository;
  final String _commentId;
  final String _userId;
  final String _postId;

  CommentInteractionNotifier(
      this._repository, this._commentId, this._userId, this._postId)
      : super(const CommentInteractionState()) {
    _loadInteractionState();
  }

  // Initialize state when the provider is created
  void initializeState() {
    _loadInteractionState();
  }

  Future<void> _loadInteractionState() async {
    try {
      final isLiked = await _repository.isCommentLikedByUser(
          commentId: _commentId, userId: _userId);

      final isDisliked = await _repository.isCommentDislikedByUser(
          commentId: _commentId, userId: _userId);

      // Get the comment to get current like/dislike counts
      final commentDoc = await FirebaseFirestore.instance
          .collection('comments')
          .doc(_postId)
          .collection('postComments')
          .doc(_commentId)
          .get();

      if (commentDoc.exists) {
        final data = commentDoc.data()!;
        state = CommentInteractionState(
          isLiked: isLiked,
          isDisliked: isDisliked,
          likeCount: data['likeCount'] ?? 0,
          dislikeCount: data['dislikeCount'] ?? 0,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading interaction state: $e');
      }
    }
  }

  Future<void> toggleLike() async {
    if (state.isLoading) return;

    // Optimistic update
    final wasLiked = state.isLiked;
    final wasDisliked = state.isDisliked;

    // Calculate new counts
    final newLikeCount = wasLiked ? state.likeCount - 1 : state.likeCount + 1;

    final newDislikeCount =
        wasDisliked && !wasLiked ? state.dislikeCount - 1 : state.dislikeCount;

    // Update state optimistically
    state = CommentInteractionState(
      isLiked: !wasLiked,
      isDisliked: false, // Remove dislike if present
      likeCount: newLikeCount,
      dislikeCount: newDislikeCount,
      isLoading: true,
    );

    try {
      // Perform the action
      await _repository.toggleLikeComment(
        commentId: _commentId,
        userId: _userId,
        postId: _postId,
      );

      // Mark loading complete
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling like: $e');
      }

      // Revert on error
      state = CommentInteractionState(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        likeCount: state.likeCount + (wasLiked ? 1 : -1),
        dislikeCount: wasDisliked && !wasLiked
            ? state.dislikeCount + 1
            : state.dislikeCount,
        isLoading: false,
      );
    }
  }

  Future<void> toggleDislike() async {
    if (state.isLoading) return;

    // Optimistic update
    final wasLiked = state.isLiked;
    final wasDisliked = state.isDisliked;

    // Calculate new counts
    final newDislikeCount =
        wasDisliked ? state.dislikeCount - 1 : state.dislikeCount + 1;

    final newLikeCount =
        wasLiked && !wasDisliked ? state.likeCount - 1 : state.likeCount;

    // Update state optimistically
    state = CommentInteractionState(
      isDisliked: !wasDisliked,
      isLiked: false, // Remove like if present
      dislikeCount: newDislikeCount,
      likeCount: newLikeCount,
      isLoading: true,
    );

    try {
      // Perform the action
      await _repository.toggleDislikeComment(
        commentId: _commentId,
        userId: _userId,
        postId: _postId,
      );

      // Mark loading complete
      state = state.copyWith(isLoading: false);
    } catch (e) {
      if (kDebugMode) {
        print('Error toggling dislike: $e');
      }

      // Revert on error
      state = CommentInteractionState(
        isLiked: wasLiked,
        isDisliked: wasDisliked,
        likeCount:
            wasLiked && !wasDisliked ? state.likeCount + 1 : state.likeCount,
        dislikeCount: state.dislikeCount + (wasDisliked ? 1 : -1),
        isLoading: false,
      );
    }
  }
}
