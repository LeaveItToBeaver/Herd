import '../../../data/models/post_model.dart';

class PostState {
  final List<PostModel> posts;
  final bool isLoading;
  final String? error;
  final Map<String, bool> likedPosts;
  final Map<String, bool> dislikedPosts;

  const PostState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
    this.likedPosts = const {},
    this.dislikedPosts = const {},
  });

  PostState copyWith({
    List<PostModel>? posts,
    bool? isLoading,
    String? error,
    Map<String, bool>? likedPosts,
    Map<String, bool>? dislikedPosts,
  }) {
    return PostState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      likedPosts: likedPosts ?? this.likedPosts,
      dislikedPosts: dislikedPosts ?? this.dislikedPosts,
    );
  }
}