import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class PinnedPostsWidget extends ConsumerWidget {
  final List<PostModel> pinnedPosts;
  final bool showTitle;
  final String? emptyMessage;

  const PinnedPostsWidget({
    super.key,
    required this.pinnedPosts,
    this.showTitle = true,
    this.emptyMessage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (pinnedPosts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinned Posts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 350,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: pinnedPosts.length,
              itemBuilder: (context, index) {
                final post = pinnedPosts[index];
                return Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: PinnedPostCard(post: post),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PinnedPostCard extends ConsumerWidget {
  final PostModel post;

  const PinnedPostCard({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => context.pushNamed(
        'post',
        pathParameters: {'id': post.id},
        queryParameters: {'isAlt': post.isAlt.toString()},
      ),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: post.isAlt
                ? Border.all(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  )
                : Border.all(
                    color: theme.colorScheme.secondary.withValues(alpha: 0.3),
                    width: 1,
                  ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Use the shared PostAuthorHeader component with pin icon
                RepaintBoundary(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(2, 1, 2, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: PostAuthorHeader(
                            post: post,
                            displayMode: HeaderDisplayMode.pinned,
                          ),
                        ),
                        Icon(
                          Icons.push_pin,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ),

                // Content - Simple approach without complex constraints
                Expanded(
                  child: RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: post.mediaItems.isNotEmpty
                          ? PostMediaDisplay(
                              post: post,
                              displayMode: HeaderDisplayMode.pinned,
                            )
                          : PostContentDisplay(
                              post: post,
                              displayMode: HeaderDisplayMode.pinned,
                              initialExpanded: false,
                              onReadMore: () {
                                context.pushNamed(
                                  'post',
                                  pathParameters: {'id': post.id},
                                  queryParameters: {'isAlt': post.isAlt.toString()},
                                );
                              },
                            ),
                    ),
                  ),
                ),

                // Action bar - Use the shared PostActionBar component
                RepaintBoundary(
                  child: PostActionBar(
                    post: post,
                    displayMode: HeaderDisplayMode.pinned,
                    onCommentTap: () => context.pushNamed(
                      'post',
                      pathParameters: {'id': post.id},
                      queryParameters: {'isAlt': post.isAlt.toString()},
                    ),
                    onShareTap: post.isAlt ? null : () => _sharePost(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _sharePost(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
    );
  }
}

// Widget for loading state
class PinnedPostsLoadingWidget extends StatelessWidget {
  final bool showTitle;

  const PinnedPostsLoadingWidget({
    super.key,
    this.showTitle = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showTitle)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.push_pin,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Pinned Posts',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
            ),
          SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: 3, // Show 3 loading cards
              itemBuilder: (context, index) {
                return Container(
                  width: 280,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey[300],
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 12,
                                      width: 100,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      height: 10,
                                      width: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
