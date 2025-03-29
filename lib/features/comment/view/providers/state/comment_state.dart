// lib/features/comment/view/providers/state/comment_state.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/comment_model.dart';

part 'comment_state.freezed.dart';

// Main state for the comment list
@freezed
class CommentState with _$CommentState {
  const factory CommentState({
    required List<CommentModel> comments,
    @Default(false) bool isLoading,
    @Default(true) bool hasMore,
    @Default('hot') String sortBy,
    DocumentSnapshot? lastDocument,
    String? error,
  }) = _CommentState;

  factory CommentState.initial() => const CommentState(
    comments: [],
    isLoading: false,
    hasMore: true,
    sortBy: 'hot',
    lastDocument: null,
    error: null,
  );
}

// State for a thread of comments
@freezed
class CommentThreadState with _$CommentThreadState {
  const factory CommentThreadState({
    required CommentModel parentComment,
    required List<CommentModel> replies,
    @Default(false) bool isLoading,
    @Default(true) bool hasMore,
    DocumentSnapshot? lastDocument,
    String? error,
  }) = _CommentThreadState;
}

// State for tracking expanded comments
@freezed
class ExpandedCommentsState with _$ExpandedCommentsState {
  const factory ExpandedCommentsState({
    required Set<String> expandedCommentIds,
  }) = _ExpandedCommentsState;

  factory ExpandedCommentsState.initial() => const ExpandedCommentsState(
    expandedCommentIds: {},
  );
}

// State for comment interactions (like/dislike)
@freezed
class CommentInteractionState with _$CommentInteractionState {
  const factory CommentInteractionState({
    @Default(false) bool isLiked,
    @Default(false) bool isDisliked,
    @Default(0) int likeCount,
    @Default(0) int dislikeCount,
    @Default(false) bool isLoading,
  }) = _CommentInteractionState;
}