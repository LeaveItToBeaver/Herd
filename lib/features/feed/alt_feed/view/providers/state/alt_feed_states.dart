import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:flutter/foundation.dart';

part 'alt_feed_states.freezed.dart';

@freezed
abstract class AltFeedState with _$AltFeedState {
  const factory AltFeedState({
    required List<PostModel> posts,
    @Default(false) bool isLoading,
    @Default(true) bool hasMorePosts,
    Object? error,
    @Default(false) bool isRefreshing,
    PostModel? lastPost,
  }) = _AltFeedState;

  factory AltFeedState.initial() => const AltFeedState(
    posts: [],
    isLoading: false,
    hasMorePosts: true,
    error: null,
    isRefreshing: false,
    lastPost: null,
  );
}