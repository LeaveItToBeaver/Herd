import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/feed/data/models/feed_sort_type.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

part 'public_feed_state.freezed.dart';

@freezed
abstract class PublicFeedState with _$PublicFeedState {
  const factory PublicFeedState({
    required List<PostModel> posts,
    @Default(false) bool isLoading,
    @Default(true) bool hasMorePosts,
    Object? error,
    @Default(false) bool isRefreshing,
    PostModel? lastPost,
    @Default(false) bool fromCache,
    @Default(FeedSortType.hot) FeedSortType sortType,
    DateTime? lastCreatedAt,
  }) = _PublicFeedState;

  factory PublicFeedState.initial() => const PublicFeedState(
        posts: [],
        isLoading: false,
        hasMorePosts: true,
        error: null,
        isRefreshing: false,
        lastPost: null,
        fromCache: false,
        sortType: FeedSortType.hot,
        lastCreatedAt: null,
      );
}
