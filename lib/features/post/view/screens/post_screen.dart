import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user/view/providers/user_provider.dart';
import '../providers/post_provider.dart';

class PostScreen extends ConsumerWidget {
  final String postId; // Use postId instead of a PostModel.

  const PostScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postAsyncValue = ref.watch(postProvider(postId));

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

          // Fetch user information using `userProvider`
          final userAsyncValue = ref.watch(userProvider(post.authorId));
          int postLikes = post.likeCount;
          int commentCount = post.commentCount;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resolve userAsyncValue
                userAsyncValue.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (user) {
                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: user.profileImageURL != null
                                ? NetworkImage(user.profileImageURL!)
                                : const AssetImage(
                                        'assets/images/default_avatar.png')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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

                const SizedBox(height: 12),

                // Reaction Buttons
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(
                        bottom: BorderSide(color: Colors.black12, width: 1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        spreadRadius: -5,
                        blurRadius: 20,
                        offset: Offset(0, 10)
                      ),
                    ],
                  ),
                  width: MediaQuery.sizeOf(context).width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: _buildIconButton(Icons.share_rounded,
                            onPressed: () {}),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(5, 0, 15, 0),
                          child: Row(
                            children: [
                              _buildIconButton(Icons.comment_rounded,
                                  onPressed: () {}),
                              Text("$commentCount"),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        color: Colors.white70,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildIconButton(
                              Icons.thumb_up,
                              color: Colors.green,
                              // Adjust based on "liked" status
                              onPressed: () {
                                // Implement like functionality
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                              child: Text(
                                "$postLikes",
                              ),
                            ),
                            _buildIconButton(
                              Icons.thumb_down,
                              color: Colors.red,
                              // Adjust based on "disliked" status
                              onPressed: () {
                                // Implement dislike functionality
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    children: [
                      Text(
                        "Comments",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: 10, // Replace with dynamic comment count
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

  Widget _buildInfoColumn(int count, String label) => Row(
        children: [
          Text(
            "$count",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(label),
        ],
      );

  Widget _buildIconButton(IconData icon,
      {Color? color, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon, color: color ?? Colors.black),
      onPressed: onPressed,
      enableFeedback: true,
    );
  }
}
