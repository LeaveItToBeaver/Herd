import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_interaction_state.freezed.dart';

@freezed
abstract class PostInteractionState with _$PostInteractionState {
  const factory PostInteractionState(
      // Add post model
      {@Default(0) int totalLikes, // Net likes (likes - dislikes)
      @Default(0) int totalRawLikes, // Raw like count
      @Default(0) int totalComments, // Total comments
      @Default(0) int totalRawDislikes, // Raw dislike count
      @Default(false) bool isLoading, // Loading state
      String? error, // Error message
      @Default(false) bool isLiked, // Whether user has liked
      @Default(false) bool isDisliked, // Whether user has disliked
      @Default(false) bool isInitialized // Whether data has been loaded
      }) = _PostInteractionState;

  factory PostInteractionState.initial() => const PostInteractionState();
}
