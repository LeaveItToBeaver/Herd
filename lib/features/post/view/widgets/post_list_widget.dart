import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

import '../providers/post_provider.dart';

class PostListWidget extends ConsumerWidget {
  final String userId;

  const PostListWidget({super.key, required this.userId, required List<PostModel> posts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsyncValue = ref.watch(userPostsProvider(userId));

    return postsAsyncValue.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const Center(child: Text('No posts available.'));
        }
        return ListView.builder(
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return PostWidget(post: post);
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}