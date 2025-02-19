import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/post_model.dart';

part 'post_state.freezed.dart';

@freezed
class PostState with _$PostState {
  const factory PostState({
    @Default([]) List<PostModel> posts, // Default to empty list
    @Default(false) bool isLoading, // Default to not loading
    String? error, // Nullable error message
    @Default({}) Map<String, bool> likedPosts,
    @Default(false) bool isLiked, // Default to empty map
    @Default({}) Map<String, bool> dislikedPosts,
    @Default(false) bool isDisliked// Default to empty map
  }) = _PostState;
}
