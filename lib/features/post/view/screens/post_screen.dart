import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import '../../../user/view/providers/user_provider.dart';

class PostScreen extends ConsumerWidget {
  final PostModel post;

  const PostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsyncValue = ref.watch(userProvider(post.authorId)); // Fetch user

    return Scaffold(
      appBar: AppBar(
        title: Text(post.title ?? ''),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Information
            userAsyncValue.when(
              loading: () => const CircularProgressIndicator(),
              error: (error, stack) => Text('Error: $error'),
              data: (user) => Row(
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

            const SizedBox(height: 12),

            // Comments Section
            Text(
              "Comments",
              style: Theme.of(context).textTheme.titleLarge,
            ),

            // Add a placeholder for comments
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5, // Replace with dynamic comment count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("User $index"),
                  subtitle: const Text("This is a comment."),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
