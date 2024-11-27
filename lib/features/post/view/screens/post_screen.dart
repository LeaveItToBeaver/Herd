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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resolve userAsyncValue
                userAsyncValue.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (user) {
                    return Row(
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
                    );
                  },
                ),
                const SizedBox(height: 12),
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
                Text(
                  "Comments",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
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
          );
        },
      ),
    );
  }
}
