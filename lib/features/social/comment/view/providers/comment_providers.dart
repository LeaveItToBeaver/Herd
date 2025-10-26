import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/features/social/comment/data/models/comment_model.dart';
import 'package:herdapp/features/social/comment/data/repositories/comment_repository.dart';
import 'package:herdapp/features/social/comment/view/providers/reply_providers.dart';
import 'package:herdapp/features/social/comment/view/providers/state/comment_state.dart';
import 'package:herdapp/features/social/comment/view/providers/comment_thread_provider.dart';
import 'package:herdapp/features/social/comment/view/providers/comment_sort_provider.dart';

part 'comment_providers.g.dart';

// Provider for comment update count
@riverpod
class CommentUpdate extends _$CommentUpdate {
  @override
  int build() => 0;

  void increment() => state++;
}

// Provider for comment list for a specific post
@riverpod
class Comments extends _$Comments {
  late final String _postId;
  late final CommentRepository _repository;

  @override
  CommentState build(String postId) {
    _postId = postId;
    _repository = ref.watch(commentRepositoryProvider);
    final sortBy = ref.watch(commentSortProvider);

    // Load initial comments
    loadComments();

    return CommentState.initial().copyWith(sortBy: sortBy);
  }

  Future<void> invalidateRelatedProviders(
      WidgetRef widgetRef, String postId, String? parentId) async {
    try {
      // Invalidate providers
      widgetRef.invalidate(commentsProvider(postId));
      widgetRef.invalidate(repliesProvider(postId));

      // Don't call loadComments() directly here
      // Instead, let the UI reload data as needed

      if (parentId != null) {
        widgetRef.invalidate(
            commentThreadProvider(commentId: parentId, postId: postId));
      } else {
        widgetRef.invalidate(
            commentThreadProvider(commentId: _postId, postId: postId));
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

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      state = state.copyWith(
        comments: comments,
        isLoading: false,
        hasMore: comments.length >= 30,
        lastDocument: comments.isNotEmpty
            ? await _getLastDocument(comments.last.id)
            : null,
      );
    } catch (e) {
      // Check if still mounted before updating error state
      if (!ref.mounted) return;

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

      // Check if still mounted after async operation
      if (!ref.mounted) return;

      state = state.copyWith(
        comments: [...state.comments, ...comments],
        isLoading: false,
        hasMore: comments.length >= 30,
        lastDocument: comments.isNotEmpty
            ? await _getLastDocument(comments.last.id)
            : state.lastDocument,
      );
    } catch (e) {
      // Check if still mounted before updating error state
      if (!ref.mounted) return;

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> changeSortBy(String sortBy) async {
    if (sortBy == state.sortBy) return;

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
    required WidgetRef widgetRef,
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
        invalidateRelatedProviders(widgetRef, _postId, parentId);
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
