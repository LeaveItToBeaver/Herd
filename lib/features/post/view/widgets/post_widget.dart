import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

class PostWidget extends ConsumerWidget {
  final PostModel post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch user data for the post's author
    final userAsyncValue = ref.watch(userProvider(post.authorId));

    return GestureDetector(
      onTap: () {
        // Navigate to the PostScreen with animation
        context.go('/post/${post.id}');
      },
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User and Post Information
              userAsyncValue.when(
                loading: () => const Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundImage: AssetImage('assets/images/default_avatar.png'),
                    ),
                    SizedBox(width: 10),
                    Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                error: (error, stack) => Text('Error: $error'),
                data: (user) => Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        // Prevent navigation when profile picture is tapped
                        context.go('/profile/${post.authorId}');
                      },
                      child: CircleAvatar(
                        radius: 25,
                        backgroundImage: user.profileImageURL != null
                            ? NetworkImage(user.profileImageURL!)
                            : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        // Prevent navigation when username is tapped
                        context.go('/profile/${post.authorId}');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.username,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post.createdAt.toLocal().toString(),
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Post Content
              Text(
                post.title ?? 'There was an issue fetching this post.',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 6),

              if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(post.imageUrl!),
                )
              else
                Text(
                  post.content,
                  style: const TextStyle(fontSize: 16),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),

              const SizedBox(height: 12),

              // Reaction Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoColumn(post.likeCount, "Likes"),
                  _buildInfoColumn(post.commentCount, "Comments"),
                  _buildIconButton(Icons.share_rounded, onPressed: () {}),
                  _buildIconButton(Icons.comment_rounded, onPressed: () {}),
                  _buildIconButton(
                    Icons.thumb_up,
                    color: Colors.green, // Adjust based on "liked" status
                    onPressed: () {
                      // Implement like functionality
                    },
                  ),
                  _buildIconButton(
                    Icons.thumb_down,
                    color: Colors.red, // Adjust based on "disliked" status
                    onPressed: () {
                      // Implement dislike functionality
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(int count, String label) => Column(
    children: [
      Text(
        "$count",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      Text(label),
    ],
  );

  Widget _buildIconButton(IconData icon, {Color? color, required VoidCallback onPressed}) =>
      IconButton(
        icon: Icon(icon, color: color ?? Colors.black),
        onPressed: onPressed,
        enableFeedback: true,
      );
}
