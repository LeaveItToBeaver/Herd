import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

import '../../../data/models/comment_model.dart';

part 'reply_state.freezed.dart';

@freezed
abstract class ReplyState with _$ReplyState {
  const factory ReplyState({
    required List<CommentModel> replies,
    required bool isLoading,
    String? error,
    @Default(true) bool hasMore,
    DocumentSnapshot? lastDocument,
  }) = _ReplyState;

  factory ReplyState.initial() => const ReplyState(
    replies: [],
    isLoading: false,
    hasMore: true,
  );
}