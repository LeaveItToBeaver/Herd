import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/create_post/create_post_controller.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:herdapp/features/user/view/providers/current_user_provider.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';

class PostAuthorHeader extends ConsumerWidget {
  final String postId;
  final bool isAlt;

  const PostAuthorHeader({
    super.key,
    required this.postId,
    required this.isAlt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch the post data
    final postAsyncValue = ref.watch(
        staticPostProvider(PostParams(id: postId, isAlt: isAlt))
            .select((value) => value.value));

    // Fetch current user data
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.userOrNull;

    // If post is not loaded yet, show placeholder
    if (postAsyncValue == null) {
      return const Padding(
        padding: EdgeInsets.all(12.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final post = postAsyncValue;

    return Consumer(builder: (context, ref, child) {
      // Watch the provider for the specific author of this post
      final userAsyncValue = ref.watch(userProvider(post.authorId));

      // Handle loading, error, and data states for the author's details
      return userAsyncValue.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(12.0),
          // Show a simple loading indicator or a shimmer placeholder
          child: Row(
            children: [
              //CircleAvatar(radius: 25, backgroundColor: Colors.grey),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      height: 8, width: 100, child: LinearProgressIndicator()),
                  SizedBox(height: 4),
                  SizedBox(
                      height: 8, width: 60, child: LinearProgressIndicator()),
                ],
              ),
            ],
          ),
        ),
        error: (error, stack) => Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            const CircleAvatar(radius: 25, child: Icon(Icons.error)),
            const SizedBox(width: 10),
            Text('Error loading author: $error'),
          ]),
        ),
        data: (user) {
          // Handle the case where the author user might not be found
          if (user == null) {
            return const Padding(
              padding: EdgeInsets.all(12.0),
              child: Row(children: [
                CircleAvatar(radius: 25, child: Icon(Icons.person_off)),
                SizedBox(width: 10),
                Text('Author not found'),
              ]),
            );
          }

          // Determine which profile image to use based on post privacy (isAlt)
          final profileImageUrl = post.isAlt
              ? user.altProfileImageURL ?? user.profileImageURL
              : user.profileImageURL;

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Navigate to appropriate profile using user.id
                    context.pushNamed(
                      post.isAlt ? 'altProfile' : 'publicProfile',
                      pathParameters: {'id': user.id},
                    );
                  },
                  child: CircleAvatar(
                    radius: 25,
                    backgroundImage: profileImageUrl != null &&
                            profileImageUrl.isNotEmpty
                        ? NetworkImage(profileImageUrl)
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                    // Add error builder for NetworkImage if needed
                    onBackgroundImageError: (_, __) {
                      // Optionally handle image load errors
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to appropriate profile using user.id
                          context.pushNamed(
                            post.isAlt ? 'altProfile' : 'publicProfile',
                            pathParameters: {'id': user.id},
                          );
                        },
                        child: Text(
                          isAlt
                              ? user.username
                              : '${user.firstName} ${user.lastName}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        // Use post's timestamp from 'post' object
                        _formatTimestamp(post.createdAt),
                        style: TextStyle(
                          //color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit/delete menu: Show only if the logged-in user is the author
                if (currentUser != null && currentUser.id == post.authorId)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      if (value == 'edit') {
                        context.pushNamed(
                          'editPost',
                          pathParameters: {'id': post.id},
                          queryParameters: {'isAlt': post.isAlt.toString()},
                          extra: post, // Pass the post object
                        );
                      } else if (value == 'delete') {
                        // Pass post.id for deletion
                        _showDeleteConfirmation(context, ref, post);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit),
                            SizedBox(width: 8),
                            Text('Edit Post'),
                          ],
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete Post',
                                style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      );
    });
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, PostModel post) {
    final currentUser = ref.read(currentUserProvider);

    if (currentUser.userId != post.authorId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only delete your own posts')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Deleting post...')),
              );

              try {
                await ref.read(postControllerProvider.notifier).deletePost(
                      post.id,
                      currentUser.userId!,
                      isAlt: post.isAlt,
                      herdId: post.herdId,
                    );

                if (context.mounted) {
                  // Navigate back after deletion
                  context.pop();

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete post: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'Unknown time';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} ${(difference.inDays / 365).floor() == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} ${(difference.inDays / 30).floor() == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
}
