import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/view/providers/user_provider.dart';
import 'package:go_router/go_router.dart';

import '../../../herds/data/models/herd_model.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../providers/post_provider.dart';
import '../providers/state/post_interaction_state.dart';

class PostWidget extends ConsumerStatefulWidget {
  final PostModel post;

  const PostWidget({super.key, required this.post});

  @override
  ConsumerState<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends ConsumerState<PostWidget> {
  bool _hasInitializedInteraction = false;

  @override
  void initState() {
    super.initState();
    // We'll initialize in didChangeDependencies instead of here
    // as ref might not be fully set up in initState
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializePostInteraction();
  }

  void _initializePostInteraction() {
    // Only initialize once to avoid repeated calls
    if (!_hasInitializedInteraction) {
      final userId = ref.read(currentUserProvider)?.id;
      if (userId != null) {
        // Initialize post interaction state immediately (safely)
        // We use Future.microtask to ensure this doesn't happen during build
        Future.microtask(() {
          if (mounted) { // Check if widget is still mounted
            ref.read(postInteractionsProvider(widget.post.id).notifier).initializeState(userId);
            _hasInitializedInteraction = true;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsyncValue = ref.watch(userProvider(widget.post.authorId));
    final interactionState = ref.watch(postInteractionsProvider(widget.post.id));
    final currentUser = ref.watch(currentUserProvider);

    return GestureDetector(
      onTap: () => context.pushNamed(
        'post',
        pathParameters: {'id': widget.post.id},
        queryParameters: {'isAlt': widget.post.isAlt.toString()},
      ),
      child: Card(
        elevation: 5,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: widget.post.isAlt
              ? BorderSide(color: Colors.blue.shade300, width: 2)
              : BorderSide.none,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Privacy indicator bar
            if (widget.post.isAlt)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock, size: 14, color: Colors.blue),
                    const SizedBox(width: 6),
                    Text(
                      'Alt Post',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userAsyncValue.when(
                    loading: () => _buildLoadingHeader(),
                    error: (error, stack) => Text('Error: $error'),
                    data: (user) => _buildUserHeader(context, user, widget.post.authorId, widget.post.isAlt),
                  ),

                  const SizedBox(height: 12),

                  if (widget.post.title!.isNotEmpty)
                    Text(
                      widget.post.title!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),

                  const SizedBox(height: 6),

                  // Use the thumbnailUrl if available, otherwise fall back to imageUrl
                  if (_shouldShowMedia())
                    _buildMediaPreview()
                  else
                    Text(
                      widget.post.content,
                      style: const TextStyle(fontSize: 16),
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 12),

                  _buildActionButtons(widget.post, interactionState),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowMedia() {
    return
      (widget.post.mediaThumbnailURL != null && widget.post.mediaThumbnailURL!.isNotEmpty) ||
          (widget.post.mediaURL != null && widget.post.mediaURL!.isNotEmpty);
  }

  Widget _buildMediaPreview() {
    // Use thumbnail in feed view if available, otherwise fall back to full image
    final String imageUrl = widget.post.mediaThumbnailURL ?? widget.post.mediaURL ?? '';

    // For GIFs, show a GIF indicator
    final bool isGif = widget.post.mediaType == 'gif';

    // For videos, show a video placeholder with play icon
    final bool isVideo = widget.post.mediaType == 'video';

    if (isVideo) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text(
                'Video',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
          Icon(
            Icons.play_circle_fill,
            size: 64,
            color: Colors.white.withOpacity(0.7),
          ),
        ],
      );
    }

    // For images and GIFs
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            height: 200, // Fixed height for consistency in the feed
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 200,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.error_outline, color: Colors.red),
              ),
            ),
          ),
        ),

        // Show GIF indicator if needed
        if (isGif)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'GIF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLoadingHeader() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundImage: AssetImage('assets/images/default_avatar.png'),
        ),
        SizedBox(width: 10),
        Text('Loading...', style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildUserHeader(BuildContext context, UserModel? user, String authorId, bool isAlt) {
    if (user == null) {
      return const Text('User not found');
    }

    // Use appropriate profile image based on post privacy
    final profileImageUrl = isAlt
        ? (user.altProfileImageURL ?? user.profileImageURL)
        : user.profileImageURL;

    // In post_widget.dart, add this near the username display
    if (widget.post.herdId != null && widget.post.herdId!.isNotEmpty) {
      FutureBuilder<HerdModel?>(
        future: ref.read(herdProvider(widget.post.herdId!).future),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return GestureDetector(
              onTap: () => context.pushNamed(
                'herd',
                pathParameters: {'id': widget.post.herdId!},
              ),
              child: Row(
                children: [
                  const Icon(Icons.group, size: 14, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(
                    'h/${snapshot.data!.name}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      );
    }

    return Row(
      children: [
        GestureDetector(
          onTap: () => context.pushNamed(
            isAlt ? 'altProfile' : 'publicProfile',
            pathParameters: {'id': authorId},
          ),
          child: CircleAvatar(
            radius: 22.0,
            backgroundColor: Colors.grey[200],
            // Only use NetworkImage if the URL exists and isn't empty
            backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            // Show placeholder icon if no image URL
            child: profileImageUrl == null || profileImageUrl.isEmpty
                ? Icon(
              Icons.account_circle,
              color: Colors.grey[400],
              size: 22.0 * 2,
            )
                : null,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => context.pushNamed(
              isAlt ? 'altProfile' : 'publicProfile',
              pathParameters: {'id': authorId},
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      isAlt
                          ? (user.username ?? '')
                          : '${user.firstName ?? ''} ${user.lastName ?? ''}'.trim(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (isAlt) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.lock, size: 14, color: Colors.blue),
                    ],
                  ],
                ),
                Text(
                  _formatTimestamp(widget.post.createdAt),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  // Fixed version without post-frame callbacks in the build method
  Widget _buildActionButtons(PostModel post, PostInteractionState interactionState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildIconButton(
          Icons.share_rounded,
          onPressed: post.isAlt ? null : () {},
          enabled: !post.isAlt,
        ),
        Row(
          children: [
            _buildIconButton(
              Icons.comment_rounded,
              onPressed: () {},
            ),
            _buildInfoColumn(interactionState.totalComments),
          ],
        ),
        // Like and dislike section with updated interaction state
        Row(
          children: [
            _buildIconButton(
              interactionState.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
              color: interactionState.isLiked ? Colors.green : null,
              onPressed: interactionState.isLoading ? null : () => _handleLikePost(post.id),
            ),
            // Display net likes (which can be negative)
            _buildInfoColumn(interactionState.totalLikes),
            _buildIconButton(
              interactionState.isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
              color: interactionState.isDisliked ? Colors.red : null,
              onPressed: interactionState.isLoading ? null : () => _handleDislikePost(post.id),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoColumn(int count) => Column(
    children: [
      Text(
        count.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: count < 0 ? Colors.red : null, // Red for negative values
        ),
      ),
    ],
  );

  Widget _buildIconButton(
      IconData icon, {
        Color? color,
        required VoidCallback? onPressed,
        bool enabled = true,
      }) =>
      IconButton(
        icon: Icon(icon, color: !enabled ? Colors.grey : (color ?? Colors.black)),
        onPressed: onPressed,
        enableFeedback: enabled,
      );

  void _handleLikePost(String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;
    final isAlt = widget.post.isAlt;

    if (userId != null) {
      ref.read(postInteractionsWithPrivacyProvider(
          PostParams(id: postId, isAlt: isAlt)
      ).notifier).likePost(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
    }
  }

  void _handleDislikePost(String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user?.id;
    final isAlt = widget.post.isAlt;

    if (userId != null) {
      ref.read(postInteractionsWithPrivacyProvider(
          PostParams(id: postId, isAlt: isAlt)
      ).notifier).dislikePost(userId);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
    }
  }
}