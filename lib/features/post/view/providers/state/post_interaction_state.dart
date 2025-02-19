import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../data/models/post_model.dart';

part 'post_interaction_state.freezed.dart';

@freezed
class PostInteractionState with _$PostInteractionState {
  const factory PostInteractionState({
    @Default(0) int totalLikes,
    @Default(false) bool isLoading, // Default to not loading
    String? error,
    @Default(false) bool isLiked,
    @Default(false) bool isDisliked// Default to empty map
  }) = _PostInteractionState;
}
