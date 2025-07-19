import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/herds/view/providers/herd_providers.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../moderation/data/repositories/moderation_repository.dart';
import '../../../post/data/models/post_model.dart';

// Provider for pinned posts
final herdPinnedPostsProvider =
    FutureProvider.family<List<PostModel>, String>((ref, herdId) async {
  final herd = await ref.watch(herdProvider(herdId).future);
  if (herd == null || herd.pinnedPosts.isEmpty) return [];

  final List<PostModel> pinnedPosts = [];
  final firestore = FirebaseFirestore.instance;

  for (final postId in herd.pinnedPosts) {
    try {
      // Try to fetch from herd posts first (most likely location for herd pinned posts)
      final herdPostDoc = await firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId)
          .get();

      if (herdPostDoc.exists) {
        final post = PostModel.fromMap(herdPostDoc.id, herdPostDoc.data()!);
        pinnedPosts.add(post);
        continue;
      }

      // If not found in herd posts, try regular posts collection
      final publicPostDoc =
          await firestore.collection('posts').doc(postId).get();

      if (publicPostDoc.exists) {
        final post = PostModel.fromMap(publicPostDoc.id, publicPostDoc.data()!);
        pinnedPosts.add(post);
        continue;
      }

      // Finally, try alt posts collection
      final altPostDoc =
          await firestore.collection('altPosts').doc(postId).get();

      if (altPostDoc.exists) {
        final post = PostModel.fromMap(altPostDoc.id, altPostDoc.data()!);
        pinnedPosts.add(post);
        continue;
      }

      debugPrint('Pinned post $postId not found in any collection');
    } catch (e) {
      debugPrint('Error loading pinned post $postId: $e');
    }
  }

  return pinnedPosts;
});

// Alternative provider using batch reads for better performance
final herdPinnedPostsBatchProvider =
    FutureProvider.family<List<PostModel>, String>((ref, herdId) async {
  final herd = await ref.watch(herdProvider(herdId).future);
  if (herd == null || herd.pinnedPosts.isEmpty) return [];

  final List<PostModel> pinnedPosts = [];
  final firestore = FirebaseFirestore.instance;
  final batch = firestore.batch();

  try {
    // Create a list of document references to read
    final List<DocumentReference> docRefs = [];

    for (final postId in herd.pinnedPosts) {
      // Add herd post reference
      docRefs.add(firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId));

      // Add public post reference
      docRefs.add(firestore.collection('posts').doc(postId));

      // Add alt post reference
      docRefs.add(firestore.collection('altPosts').doc(postId));
    }

    // Read all documents in parallel
    final futures = docRefs.map((ref) => ref.get()).toList();
    final snapshots = await Future.wait(futures);

    // Process the results
    for (int i = 0; i < herd.pinnedPosts.length; i++) {
      final postId = herd.pinnedPosts[i];

      // Check each location for this post (3 snapshots per post)
      final herdPostSnapshot = snapshots[i * 3];
      final publicPostSnapshot = snapshots[i * 3 + 1];
      final altPostSnapshot = snapshots[i * 3 + 2];

      if (herdPostSnapshot.exists) {
        final post = PostModel.fromMap(herdPostSnapshot.id,
            herdPostSnapshot.data()! as Map<String, dynamic>);
        pinnedPosts.add(post);
      } else if (publicPostSnapshot.exists) {
        final post = PostModel.fromMap(publicPostSnapshot.id,
            publicPostSnapshot.data()! as Map<String, dynamic>);
        pinnedPosts.add(post);
      } else if (altPostSnapshot.exists) {
        final post = PostModel.fromMap(altPostSnapshot.id,
            altPostSnapshot.data()! as Map<String, dynamic>);
        pinnedPosts.add(post);
      } else {
        debugPrint('Pinned post $postId not found in any collection');
      }
    }

    return pinnedPosts;
  } catch (e) {
    debugPrint('Error loading pinned posts with batch: $e');
    return [];
  }
});
// Provider for moderation repository
final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return ModerationRepository(FirebaseFirestore.instance, herdRepository);
});

class PinnedPostsManagementScreen extends ConsumerWidget {
  final String herdId;

  const PinnedPostsManagementScreen({super.key, required this.herdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final herdAsync = ref.watch(herdProvider(herdId));
    final pinnedPostsAsync = ref.watch(herdPinnedPostsBatchProvider(herdId));
    final currentUser = ref.watch(authProvider);

    return herdAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Pinned Posts')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (herd) {
        if (herd == null || currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Herd not found')),
          );
        }

        final isModerator = herd.isModerator(currentUser.uid) ||
            herd.isCreator(currentUser.uid);

        if (!isModerator) {
          return Scaffold(
            appBar: AppBar(title: const Text('Pinned Posts')),
            body: const Center(
              child: Text('Only moderators and owners can manage pinned posts'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Pinned Posts'),
                Text(
                  '${herd.pinnedPosts.length}/5 posts pinned',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.normal),
                ),
              ],
            ),
          ),
          body: pinnedPostsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error loading pinned posts: $error'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        ref.invalidate(herdPinnedPostsProvider(herdId)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (pinnedPosts) {
              if (pinnedPosts.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.push_pin, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No pinned posts yet',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Pinned posts will appear here',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: pinnedPosts.length,
                itemBuilder: (context, index) {
                  final post = pinnedPosts[index];
                  return _buildPinnedPostCard(context, ref, post, herd, index);
                },
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPinnedPostCard(
      BuildContext context, WidgetRef ref, PostModel post, herd, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with pin icon and position
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.push_pin,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Pinned Post #${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Spacer(),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'unpin') {
                      _showUnpinDialog(context, ref, post, herd);
                    } else if (value == 'view') {
                      context.pushNamed(
                        'post',
                        pathParameters: {'id': post.id},
                        queryParameters: {'isAlt': post.isAlt.toString()},
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View Post'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'unpin',
                      child: Row(
                        children: [
                          Icon(Icons.push_pin_outlined, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Unpin Post',
                              style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Post content preview
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Author info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundImage: post.authorProfileImageURL != null
                          ? NetworkImage(post.authorProfileImageURL!)
                          : null,
                      child: post.authorProfileImageURL == null
                          ? Text(
                              (post.authorUsername ?? 'U')[0].toUpperCase(),
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorUsername ?? 'Unknown',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            post.age,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Post title
                if (post.title != null && post.title!.isNotEmpty) ...[
                  Text(
                    post.title!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                ],

                // Post content preview
                Text(
                  _getContentPreview(post.content),
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 12),

                // Post stats
                Row(
                  children: [
                    Icon(Icons.thumb_up_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${post.likeCount - post.dislikeCount}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.comment_outlined,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      '${post.commentCount}',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    if (post.isAlt)
                      Icon(Icons.lock, size: 16, color: Colors.blue[400]),
                  ],
                ),
              ],
            ),
          ),

          // Action buttons
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Post'),
                    onPressed: () {
                      context.pushNamed(
                        'post',
                        pathParameters: {'id': post.id},
                        queryParameters: {'isAlt': post.isAlt.toString()},
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.push_pin_outlined),
                    label: const Text('Unpin'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _showUnpinDialog(context, ref, post, herd),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getContentPreview(String content) {
    try {
      // Try to parse rich text content and extract plain text
      if (content.startsWith('[') || content.startsWith('{')) {
        // This looks like JSON content from rich text editor
        return 'Rich text content...';
      }
      return content.length > 150 ? '${content.substring(0, 150)}...' : content;
    } catch (e) {
      return content.length > 150 ? '${content.substring(0, 150)}...' : content;
    }
  }

  void _showUnpinDialog(
      BuildContext context, WidgetRef ref, PostModel post, herd) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unpin Post'),
        content: Text(
            'Are you sure you want to unpin "${post.title ?? 'this post'}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _unpinPost(context, ref, post, herd);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Unpin'),
          ),
        ],
      ),
    );
  }

  Future<void> _unpinPost(
      BuildContext context, WidgetRef ref, PostModel post, herd) async {
    try {
      final currentUser = ref.read(authProvider);
      if (currentUser == null) return;

      final moderationRepository = ref.read(moderationRepositoryProvider);

      await moderationRepository.unpinPost(
        herdId: herdId,
        postId: post.id,
        moderatorId: currentUser.uid,
      );

      // Refresh the data
      ref.invalidate(herdProvider(herdId));
      ref.invalidate(herdPinnedPostsProvider(herdId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post unpinned successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
