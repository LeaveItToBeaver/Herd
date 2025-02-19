import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../../../user/view/providers/user_provider.dart';
import '../providers/post_provider.dart';

class PostScreen extends ConsumerStatefulWidget {
  final String postId;

  const PostScreen({super.key, required this.postId});

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      final userId = user?.id;
      if (userId != null) {
        ref.read(postInteractionsProvider(widget.postId).notifier)
            .initializeState(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final postAsyncValue = ref.watch(postProvider(widget.postId));

    return Scaffold(
      appBar: AppBar(
        title: postAsyncValue.when(
          data: (post) => Text(post?.title ?? 'Post'),
          loading: () => const Text('Loading...'),
          error: (error, stack) => const Text('Error'),
        ),
      ),
      body: postAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          final userAsyncValue = ref.watch(userProvider(post.authorId));
          int postLikes = post.likeCount;
          int commentCount = post.commentCount;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                userAsyncValue.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (user) {
                    if (user == null) {
                      return const Text('User not found');
                    }

                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: user.profileImageURL != null
                                ? NetworkImage(user.profileImageURL!)
                                : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username ?? 'Anonymous',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                post.createdAt.toLocal().toString(),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),

                // Post content
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 2),
                  child: Column(
                    children: [
                      if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(post.imageUrl!),
                        )
                      else
                        Text(
                          post.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Reaction buttons
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12, width: 1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: -5,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onPressed: () {},
                      ),
                      _buildActionButton(
                        icon: Icons.comment_rounded,
                        label: commentCount.toString(),
                        onPressed: () {},
                      ),
                      _buildLikeDislikeButtons(
                          context: context,
                          ref: ref,
                          likes: postLikes
                      ),
                    ],
                  ),
                ),

                // Comments section
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Comments",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text("User $index"),
                            subtitle: const Text("This is a comment."),
                          );
                        },
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconButton(
              icon: Icon(icon, color: color ?? Colors.black),
              onPressed: onPressed,
            ),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeDislikeButtons({
    required BuildContext context,
    required WidgetRef ref,
    required int likes,
  }){
    final interactionState = ref.watch(postInteractionsProvider(widget.postId));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                Icons.thumb_up,
                color: interactionState.isLiked ? Colors.green : Colors.grey
            ),
            onPressed: () => _handleLikePost(context, ref, widget.postId),
          ),
          Text(likes.toString()),
          IconButton(
            icon: Icon(
                Icons.thumb_down,
                color: interactionState.isDisliked ? Colors.red : Colors.grey
            ),
            onPressed: () => _handleDislikePost(context, ref, widget.postId),
          ),
        ],
      ),
    );
  }

  void _handleLikePost(BuildContext context, WidgetRef ref, String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;

    if (userId != null) {
      ref.read(postInteractionsProvider(postId).notifier).likePost(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
    }
  }

  void _handleDislikePost(BuildContext context, WidgetRef ref, String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;

    if (userId != null) {
      ref.read(postInteractionsProvider(postId).notifier).dislikePost(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to dislike posts.')),
      );
    }
  }
}
