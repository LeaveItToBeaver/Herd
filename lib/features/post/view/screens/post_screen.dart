import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../../../user/view/providers/user_provider.dart';
import '../providers/post_provider.dart';

class PostScreen extends ConsumerStatefulWidget {
  final String postId;
  final bool isPrivate;

  const PostScreen({
    super.key,
    required this.postId,
    this.isPrivate = false,
  });

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
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.isPrivate ? Colors.blue : Colors.black,
        title: Row(
          children: [
            if (widget.isPrivate)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Icon(Icons.lock, size: 20),
              ),
            postAsyncValue.when(
              data: (post) => Text(post?.title ?? 'Post'),
              loading: () => const Text('Loading...'),
              error: (error, stack) => const Text('Error'),
            ),
          ],
        ),
        actions: [
          // Add share button (disabled for private posts)
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: widget.isPrivate
                ? null // Disable for private posts
                : () {
              // Share post logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sharing post...')),
              );
            },
            color: widget.isPrivate ? Colors.grey : Colors.white,
          ),
        ],
      ),
      body: postAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          // Verify that the user can see this post
          if (post.isPrivate && currentUser?.id != post.authorId) {
            // Check if this user has permission to view private posts
            // For now, we're just checking if they're the author
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'This is a private post',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You don\'t have permission to view this content.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/publicFeed'),
                      child: const Text('Go to public feed'),
                    ),
                  ],
                ),
              ),
            );
          }

          final userAsyncValue = ref.watch(userProvider(post.authorId));
          int postLikes = post.likeCount;
          int commentCount = post.commentCount;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Privacy badge for private posts
                if (post.isPrivate)
                  Container(
                    color: Colors.blue.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.lock, size: 16, color: Colors.blue),
                        const SizedBox(width: 8),
                        const Text(
                          'Private Post',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Only visible to your connections',
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                userAsyncValue.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (error, stack) => Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text('Error: $error'),
                  ),
                  data: (user) {
                    if (user == null) {
                      return const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('User not found'),
                      );
                    }

                    // Determine which profile image to use based on privacy
                    final profileImageUrl = post.isPrivate
                        ? user.privateProfileImageURL ?? user.profileImageURL
                        : user.profileImageURL;

                    return Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Navigate to appropriate profile
                              if (post.isPrivate) {
                                context.pushNamed(
                                  'privateProfile',
                                  pathParameters: {'id': user.id},
                                );
                              } else {
                                context.pushNamed(
                                  'publicProfile',
                                  pathParameters: {'id': user.id},
                                );
                              }
                            },
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: profileImageUrl != null
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to appropriate profile
                                    if (post.isPrivate) {
                                      context.pushNamed(
                                        'privateProfile',
                                        pathParameters: {'id': user.id},
                                      );
                                    } else {
                                      context.pushNamed(
                                        'publicProfile',
                                        pathParameters: {'id': user.id},
                                      );
                                    }
                                  },
                                  child: Text(
                                    user.username ?? 'Anonymous',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  _formatTimestamp(post.createdAt),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Edit/delete menu for post owner
                          if (currentUser?.id == post.authorId)
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  // TODO: Implement edit post
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Edit post not implemented yet')),
                                  );
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(context, post.id);
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
                                      Text('Delete Post', style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
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
                  padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post title
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Post content (text or image)
                      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) ...[
                        Text(
                          post.content,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            post.imageUrl!,
                            errorBuilder: (context, error, stackTrace) =>
                            const Center(child: Text('Failed to load image')),
                          ),
                        ),
                      ] else
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
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      top: BorderSide(color: Colors.grey.shade200),
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildActionButton(
                        icon: Icons.share_rounded,
                        label: 'Share',
                        onPressed: post.isPrivate ? null : () {}, // Disable for private posts
                        enabled: !post.isPrivate,
                      ),
                      _buildActionButton(
                        icon: Icons.comment_rounded,
                        label: commentCount.toString(),
                        onPressed: () {
                          // TODO: Implement opening comments section
                        },
                      ),
                      _buildLikeDislikeButtons(
                        context: context,
                        ref: ref,
                        likes: postLikes,
                        postId: widget.postId,
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Comments",
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.add_comment),
                            label: const Text("Add Comment"),
                            onPressed: () {
                              // TODO: Implement add comment
                            },
                          ),
                        ],
                      ),
                      // Comment form
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: currentUser?.profileImageURL != null
                                  ? NetworkImage(currentUser!.profileImageURL!)
                                  : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText: 'Write a comment...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.send),
                              onPressed: () {
                                // TODO: Implement send comment
                              },
                            ),
                          ],
                        ),
                      ),
                      // Sample comments - replace with actual comments
                      ...List.generate(3, (index) =>
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const CircleAvatar(
                                  radius: 16,
                                  backgroundImage: AssetImage('assets/images/default_avatar.png'),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            "User ${index + 1}",
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "2h ago",
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "This is a sample comment. Replace with actual comment data from your database.",
                                        style: TextStyle(
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          TextButton.icon(
                                            icon: const Icon(Icons.thumb_up_outlined, size: 14),
                                            label: const Text("Like", style: TextStyle(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () {},
                                          ),
                                          TextButton.icon(
                                            icon: const Icon(Icons.reply, size: 14),
                                            label: const Text("Reply", style: TextStyle(fontSize: 12)),
                                            style: TextButton.styleFrom(
                                              minimumSize: Size.zero,
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () {},
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ),
                      // Show more comments button
                      Center(
                        child: TextButton(
                          onPressed: () {
                            // TODO: Implement load more comments
                          },
                          child: const Text("Show More Comments"),
                        ),
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

  void _showDeleteConfirmation(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
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
                // TODO: Implement post deletion.
                //await ref.read(postControllerProvider.notifier).deletePost(postId);

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

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
    bool enabled = true,
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
              icon: Icon(
                icon,
                color: enabled ? Colors.black : Colors.grey,
              ),
              onPressed: onPressed,
            ),
            Text(
              label,
              style: TextStyle(
                color: enabled ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLikeDislikeButtons({
    required BuildContext context,
    required WidgetRef ref,
    required int likes,
    required String postId,
  }){
    final interactionState = ref.watch(postInteractionsProvider(postId));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                interactionState.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                color: interactionState.isLiked ? Colors.green : Colors.grey
            ),
            onPressed: () => _handleLikePost(context, ref, postId),
          ),
          Text(likes.toString()),
          IconButton(
            icon: Icon(
                interactionState.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                color: interactionState.isDisliked ? Colors.red : Colors.grey
            ),
            onPressed: () => _handleDislikePost(context, ref, postId),
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