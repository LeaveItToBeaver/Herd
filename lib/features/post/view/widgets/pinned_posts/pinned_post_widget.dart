import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/widgets/build_post_content.dart';
import 'package:herdapp/features/post/view/widgets/media_carousel_widget.dart';
import 'package:herdapp/features/user/view/widgets/user_profile_image.dart';

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
            height: 300,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with pin icon
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  UserProfileImage(
                    radius: 16,
                    profileImageUrl: post.isAlt
                        ? post.authorProfileImageURL
                        : post.authorProfileImageURL,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.authorUsername ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          post.age,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.push_pin,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
            ),

            // Content preview
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title if available
                    if (post.title != null && post.title!.isNotEmpty) ...[
                      Text(
                        post.title!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Media preview or text content
                    if (post.mediaItems.isNotEmpty) ...[
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: MediaCarouselWidget(
                            mediaItems: post.mediaItems,
                            height: 150,
                            showIndicator: false,
                            autoPlay: false,
                          ),
                        ),
                      ),
                    ] else ...[
                      Expanded(
                        child: _buildContentPreview(theme, context),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Footer with stats
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.thumb_up_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount - post.dislikeCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  if (post.isAlt)
                    Icon(
                      Icons.lock,
                      size: 14,
                      color: Colors.blue[400],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContentPreview(ThemeData theme, context) {
    return PostContentWidget(
      post: post,
      isExpanded: false, // Always collapsed in preview
      isCompact: true, // Use compact mode for card
      onToggleExpansion: () {
        // Navigate to full post instead of expanding in place
        context.pushNamed(
          'post',
          pathParameters: {'id': post.id},
          queryParameters: {'isAlt': post.isAlt.toString()},
        );
      },
      buildMediaPreview: (post) {
        // Return a simple container since we handle media separately
        return const SizedBox.shrink();
      },
      shouldShowMedia: false, // We handle media separately in the pinned card
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
