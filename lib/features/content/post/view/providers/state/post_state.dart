import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/post_model.dart';
import 'package:flutter/foundation.dart';

part 'post_state.freezed.dart';

@freezed
abstract class PostState with _$PostState {
  const factory PostState({
    @Default([]) List<PostModel> posts, // Default to empty list
    @Default(false) bool isLoading, // Default to not loading
    String? error, // Nullable error message
    @Default({}) Map<String, bool> likedPosts,
    @Default(false) bool isLiked, // Default to empty map
    @Default({}) Map<String, bool> dislikedPosts,
    @Default(false) bool isDisliked // Default to empty map
  }) = _PostState;
}
