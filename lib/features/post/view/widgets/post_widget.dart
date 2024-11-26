import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';

class PostWidget extends ConsumerWidget {
  final PostModel post;

  const PostWidget({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch user data for the post's author
    final userAsyncValue = ref.watch(userProvider(post.authorId));

    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Information
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
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: user.profileImageURL != null
                        ? NetworkImage(user.profileImageURL!)
                        : const AssetImage('assets/images/default_avatar.png') as ImageProvider,
                  ),
                  const SizedBox(width: 10),
                  Column(
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
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Post Content
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
    );
  }
}
