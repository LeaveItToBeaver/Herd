import '../../../../post/data/models/post_model.dart';

class HerdFeedState {
  final List<PostModel> posts;
  final bool isLoading;
  final bool isRefreshing;
  final bool hasMorePosts;
  final Object? error;
  final PostModel? lastPost;

  HerdFeedState({
    required this.posts,
    required this.isLoading,
    required this.isRefreshing,
    required this.hasMorePosts,
    this.error,
    this.lastPost,
  });

  factory HerdFeedState.initial() => HerdFeedState(
        posts: [],
        isLoading: false,
        isRefreshing: false,
        hasMorePosts: true,
        error: null,
        lastPost: null,
      );

  HerdFeedState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    bool? isRefreshing,
    bool? hasMorePosts,
    Object? error,
    PostModel? lastPost,
  }) {
    return HerdFeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      hasMorePosts: hasMorePosts ?? this.hasMorePosts,
      error: error,
      lastPost: lastPost ?? this.lastPost,
    );
  }
}
