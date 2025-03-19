import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

part 'private_feed_state.freezed.dart';

@freezed
class PrivateFeedState with _$PrivateFeedState {
  const factory PrivateFeedState({
    required List<PostModel> posts,
    @Default(false) bool isLoading,
    @Default(true) bool hasMorePosts,
    Object? error,
    @Default(false) bool isRefreshing,
    PostModel? lastPost,
  }) = _PrivateFeedState;

  factory PrivateFeedState.initial() => const PrivateFeedState(
    posts: [],
    isLoading: false,
    hasMorePosts: true,
    error: null,
    isRefreshing: false,
    lastPost: null,
  );
}