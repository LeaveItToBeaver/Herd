import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/helpers/like_dislike_helper.dart';
import 'package:herdapp/features/post/view/providers/pinned_post_provider.dart';
import 'package:herdapp/features/post/view/widgets/build_post_content.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/author_header_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/herd_header.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/media_preview_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/nsfw_hidden_message.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/nsfw_overlay_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/post_menu_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_widget_widgets/type_indicator_widget.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:shimmer/shimmer.dart';

import '../../../create_post/create_post_controller.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../../data/models/post_media_model.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/state/post_interaction_state.dart';

class PostWidget extends ConsumerStatefulWidget {
  final PostModel post;
  final bool isCompact; // Optional flag for more compact display in lists

  const PostWidget({
    super.key,
    required this.post,
    this.isCompact = false,
  });

  @override
  ConsumerState<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends ConsumerState<PostWidget>
    with AutomaticKeepAliveClientMixin {
  bool _hasInitializedInteraction = false;
  bool _isExpanded = false;
  bool _isNsfwRevealed = false;

  @override
  bool get wantKeepAlive => true; // Keep widget state when scrolling

  @override
  void initState() {
    super.initState();

    _hasInitializedInteraction = true;
  }

  void _initializePostInteraction() {
    // Only initialize once to avoid repeated calls
    if (!_hasInitializedInteraction && mounted) {
      final user = ref.read(currentUserProvider);
      final userId = user.userId;
      if (userId != null) {
        // Use a Future to avoid modifying state during build
        Future.microtask(() {
          if (mounted) {
            ref
                .read(postInteractionsWithPrivacyProvider(PostParams(
                        id: widget.post.id, isAlt: widget.post.isAlt))
                    .notifier)
                .initializeState(userId);

            // Now we can mark it as initialized
            if (mounted) {
              setState(() {
                _hasInitializedInteraction = true;
              });
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final theme = Theme.of(context);
    final user = ref.read(currentUserProvider);
    final bool userAllowsNsfw = user.allowNSFW ?? false;
    final bool userPrefersBlur = user.blurNSFW ?? true;
    // final interactionState = ref.watch(postInteractionsWithPrivacyProvider(
    //     PostParams(id: widget.post.id, isAlt: widget.post.isAlt)));

    // Format the timestamp here, so it's always available

    final bool shouldShowOverlay = widget.post.isNSFW &&
        userAllowsNsfw && // User must allow NSFW
        userPrefersBlur && // User must prefer blurring
        !_isNsfwRevealed; // This post hasn't been revealed yet

    // Determine if the actual content should be shown
    final bool shouldShowContent =
        !widget.post.isNSFW || // Always show if not NSFW
            (userAllowsNsfw && // Or if user allows NSFW AND
                (!userPrefersBlur || // they don't prefer blurring OR
                    _isNsfwRevealed)); // this post has been revealed

    final formattedTimestamp = _formatTimestamp(widget.post.createdAt);

    return GestureDetector(
      onTap: () => context.pushNamed(
        'post',
        pathParameters: {'id': widget.post.id},
        queryParameters: {'isAlt': widget.post.isAlt.toString()},
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
            vertical: 6, horizontal: widget.isCompact ? 6 : 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: widget.post.isAlt
              ? Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.2), width: 1)
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Type Indicators
              widget.post.isAlt && !widget.post.isNSFW
                  ? _buildTypeIndicator(
                      icon: Icons.public,
                      label: 'Alt Post',
                      color: theme.colorScheme.primary,
                    )
                  : widget.post.isAlt && widget.post.isNSFW
                      ? _buildTypeIndicator(
                          icon: Icons.public,
                          label: 'Alt Post (NSFW)',
                          color: Colors.redAccent,
                        )
                      : !widget.post.isAlt && widget.post.isNSFW
                          ? _buildTypeIndicator(
                              icon: Icons.warning_amber_rounded,
                              label: 'NSFW Content',
                              color: Colors.red,
                            )
                          : const SizedBox.shrink(),

              if (widget.post.herdId != null &&
                  widget.post.herdId!.isNotEmpty &&
                  !widget.post.isAlt)
                _buildTypeIndicator(
                  icon: Icons.group_outlined,
                  label: 'Herd Post',
                  color: theme.colorScheme.secondary,
                ),

              // Post Content
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    widget.post.herdId != null && widget.post.herdId!.isNotEmpty
                        ? _buildHerdHeader(formattedTimestamp)
                        : _buildAuthorHeader(formattedTimestamp),

                    // Title and Content
                    if (widget.post.title != null &&
                        widget.post.title!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        widget.post.title!,
                        style: TextStyle(
                          fontSize: widget.isCompact ? 16 : 18,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Either media or text content with NSFW blur option
                    const SizedBox(height: 4),

                    // --- NSFW Content Handling Logic ---
                    if (widget.post.isNSFW && !userAllowsNsfw)
                      // Case 1: Post is NSFW, but user settings hide it completely
                      _buildNsfwHiddenMessage()
                    else if (shouldShowOverlay)
                      // Case 2: Post is NSFW, user allows it, prefers blur, and it's not revealed yet
                      _buildNSFWOverlay()
                    else if (shouldShowContent)
                      // Case 3: Show the actual content (media or text)
                      _buildActualContent(theme)
                    else
                      // Fallback (should ideally not be reached with correct logic)
                      const SizedBox.shrink(),
                    // --- End NSFW Content Handling ---

                    const SizedBox(height: 4),

                    // Action row
                    _buildActionBar(
                      ref.read(postInteractionsWithPrivacyProvider(PostParams(
                          id: widget.post.id, isAlt: widget.post.isAlt))),
                      theme,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNSFWOverlay() {
    return NSFWOverlayWidget(
      onTap: () {
        setState(() {
          _isNsfwRevealed = true;
        });
      },
      height: 200,
    );
  }

  // I need to add images and media to the rich text viewer if they exist.
  Widget _buildActualContent(ThemeData theme) {
    return PostContentWidget(
      post: widget.post,
      isExpanded: _isExpanded,
      isCompact: widget.isCompact,
      onToggleExpansion: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      buildMediaPreview: _buildMediaPreview,
      shouldShowMedia: _shouldShowMedia(),
    );
  }

  Widget _buildNsfwHiddenMessage() {
    return const NSFWHiddenMessageWidget();
  }

  Widget _buildTypeIndicator({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return TypeIndicatorWidget(
      icon: icon,
      label: label,
      color: color,
    );
  }

  Widget _buildAuthorHeader(String formattedTimestamp) {
    return AuthorHeaderWidget(
      post: widget.post,
      formattedTimestamp: formattedTimestamp,
      isCompact: widget.isCompact,
      onProfileTap: () => _navigateToProfile(widget.post.authorId),
      postMenu: _buildPostMenu(),
      buildLoadingHeader: _buildLoadingHeader,
    );
  }

  Widget _buildHerdHeader(String formattedTimestamp) {
    return HerdHeaderWidget(
      post: widget.post,
      formattedTimestamp: formattedTimestamp,
      isCompact: widget.isCompact,
      onProfileTap: () => _navigateToProfile(widget.post.authorId),
      postMenu: _buildPostMenu(),
      buildShimmerText: _buildShimmerText,
    );
  }

  Widget _buildLoadingHeader() {
    return Row(
      children: [
        _buildShimmerCircle(radius: widget.isCompact ? 16 : 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerText(width: 120, height: 14),
            const SizedBox(height: 4),
            _buildShimmerText(width: 80, height: 12),
          ],
        ),
        const Spacer(),
        const Icon(
          Icons.more_vert,
          size: 20,
          //color: Colors.grey
        ),
      ],
    );
  }

  Widget _buildPostMenu() {
    return PostMenuWidget(
      post: widget.post,
      onEdit: () => _navigateToEditScreen(context),
      onDelete: () => _showDeleteConfirmation(context),
      onSave: _savePost,
      onReport: _showReportDialog,
      onPinToProfile: _pinToProfile,
      onUnpinFromProfile: _unpinFromProfile,
      onPinToHerd: _pinToHerd,
      onUnpinFromHerd: _unpinFromHerd,
    );
  }

  void _pinToProfile({required bool isAlt}) async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.pinToProfile(userId, widget.post.id, isAlt: isAlt);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAlt
                ? 'Post pinned to alt profile'
                : 'Post pinned to profile'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _unpinFromProfile({required bool isAlt}) async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.unpinFromProfile(userId, widget.post.id, isAlt: isAlt);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAlt
                ? 'Post unpinned from alt profile'
                : 'Post unpinned from profile'),
            //backgroundColor: Colors.orange,
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

  void _pinToHerd() async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId == null || widget.post.herdId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.pinToHerd(widget.post.herdId!, widget.post.id, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post pinned to herd'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _unpinFromHerd() async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId == null || widget.post.herdId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.unpinFromHerd(
          widget.post.herdId!, widget.post.id, userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post unpinned from herd'),
            //backgroundColor: Colors.orange,
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

  Widget _buildShimmerCircle({required double radius}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }

  Widget _buildShimmerText({required double width, required double height}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildContentText(ThemeData theme) {
    // This method now primarily serves as a fallback for non-rich text
    // or if rich text rendering failed (though QuillViewerWidget has its own error display)
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.post.content, // Display plain text content
            style: TextStyle(
              fontSize: widget.isCompact ? 14 : 15,
              color: theme.colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
            maxLines: _isExpanded ? null : (widget.isCompact ? 3 : 4),
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (!_isExpanded &&
              widget.post.content.length >
                  (widget.isCompact
                      ? 100
                      : 150)) // Adjust length check as needed
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Read more',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _shouldShowMedia() {
    return (widget.post.mediaItems.isNotEmpty) ||
        (widget.post.mediaThumbnailURL != null &&
            widget.post.mediaThumbnailURL!.isNotEmpty) ||
        (widget.post.mediaURL != null && widget.post.mediaURL!.isNotEmpty);
  }

  List<PostMediaModel> getMediaItemsFromPost(dynamic post) {
    List<PostMediaModel> mediaItems = [];

    // Check for new media items format first
    if (post.mediaItems != null && post.mediaItems.isNotEmpty) {
      mediaItems = post.mediaItems;
    }
    // Fall back to legacy format
    else if (post.mediaURL != null && post.mediaURL.toString().isNotEmpty) {
      final url = post.mediaURL.toString();
      if (url.isNotEmpty && url.contains('://')) {
        // Basic URL validation
        mediaItems.add(PostMediaModel(
          id: '0',
          url: url,
          thumbnailUrl: post.mediaThumbnailURL,
          mediaType: post.mediaType ?? 'image',
        ));
        debugPrint('Post: ${post.id} is using legacy media URL');
      } else {
        debugPrint('Invalid legacy URL: $url');
      }
    }

    // Validate each media item to ensure it has a valid URL
    mediaItems = mediaItems
        .where((item) => item.url.isNotEmpty && item.url.contains('://'))
        .toList();

    if (mediaItems.isEmpty) {
      debugPrint('No valid media found for post ${post.id}');
    }

    return mediaItems;
  }

  Widget _buildMediaPreview(PostModel post) {
    return MediaPreviewWidget(
      post: post,
      height: 350,
      autoPlay: false,
      showIndicatorCondition: (mediaCount) => mediaCount > 1,
      onMediaTap: (media, index) {
        // Use GoRouter to navigate to the fullscreen gallery
        context.pushNamed(
          'gallery',
          pathParameters: {'postId': post.id},
          queryParameters: {
            'index': index.toString(),
            'isAlt': post.isAlt.toString(),
          },
        );
      },
    );
  }

  Widget _buildActionBar(
      PostInteractionState interactionState, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 0),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: theme.dividerColor.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        children: [
          // Like button - always show
          Consumer(
            builder: (context, ref, child) {
              // Use PostParams with herdId to get the correct interaction state
              final params =
                  PostParams(id: widget.post.id, isAlt: widget.post.isAlt);

              final likeState = ref.watch(
                  postInteractionsWithPrivacyProvider(params).select((state) =>
                      (state.isLiked, state.totalLikes, state.isLoading)));

              return _buildActionButton(
                likeState.$1 ? Icons.thumb_up : Icons.thumb_up_outlined,
                likeState.$3 ? '...' : '${likeState.$2}',
                color: likeState.$1 ? Colors.green : null,
                onPressed: likeState.$3 ? null : () => _handleLikePost(),
              );
            },
          ),

          // Dislike button
          Consumer(
            builder: (context, ref, child) {
              final params =
                  PostParams(id: widget.post.id, isAlt: widget.post.isAlt);

              final dislikeState = ref.watch(
                  postInteractionsWithPrivacyProvider(params)
                      .select((state) => (state.isDisliked, state.isLoading)));

              return _buildActionButton(
                dislikeState.$1 ? Icons.thumb_down : Icons.thumb_down_outlined,
                '', // No count displayed for dislikes
                color: dislikeState.$1 ? Colors.red : null,
                onPressed: dislikeState.$2 ? null : () => _handleDislikePost(),
              );
            },
          ),
          Consumer(
            builder: (context, ref, child) {
              // Watch the specific post stream for real-time updates
              final postAsyncValue = ref.watch(postProvider(widget.post.id));
              // Get the latest comment count, defaulting to the initial post data
              // or the interaction state if available and potentially more up-to-date
              final commentCount = postAsyncValue.when(
                data: (post) =>
                    post?.commentCount ?? interactionState.totalComments,
                loading: () =>
                    interactionState.totalComments, // Use state while loading
                error: (_, __) =>
                    interactionState.totalComments, // Use state on error
              );
              return _buildActionButton(
                Icons.chat_bubble_outline,
                commentCount.toString(), // Use the potentially updated count
                theme: theme,
                onPressed: () => context.pushNamed(
                  'post',
                  pathParameters: {'id': widget.post.id},
                  queryParameters: {'isAlt': widget.post.isAlt.toString()},
                ),
              );
            },
          ),

          // Spacer
          const Spacer(),

          // Share button - always show but disabled for alt posts
          IconButton(
            icon: const Icon(Icons.share_outlined, size: 20),
            onPressed: widget.post.isAlt ? null : () => _sharePost(),
            tooltip: widget.post.isAlt ? 'Cannot share alt posts' : 'Share',
            color: widget.post.isAlt ? theme.disabledColor : null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String count, {
    Color? color,
    ThemeData? theme,
    required VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: color ?? theme?.buttonTheme.colorScheme?.primary,
      ),
      label: Text(
        count,
        style: TextStyle(
          color: color ?? theme?.buttonTheme.colorScheme?.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
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

  void _navigateToProfile(String userId) {
    context.pushNamed(
      widget.post.isAlt ? 'altProfile' : 'publicProfile',
      pathParameters: {'id': userId},
    );
  }

  void _handleLikePost() {
    LikeDislikeHelper.handleLikePost(
      context: context,
      ref: ref,
      postId: widget.post.id,
      isAlt: widget.post.isAlt,
      herdId: widget.post.herdId,
    );
  }

  void _handleDislikePost() {
    LikeDislikeHelper.handleDislikePost(
      context: context,
      ref: ref,
      postId: widget.post.id,
      isAlt: widget.post.isAlt,
      herdId: widget.post.herdId,
    );
  }

  void _sharePost() {
    // Only allow sharing public posts
    if (widget.post.isAlt) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
    );
    // Implement actual sharing functionality
  }

  void _savePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post saved')),
    );
    // Implement bookmark functionality
  }

  void _showDeleteConfirmation(BuildContext context) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    if (userId != widget.post.authorId) {
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
                      widget.post.id,
                      userId!,
                      isAlt: widget.post.isAlt,
                      herdId: widget.post.herdId,
                    );

                if (context.mounted) {
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

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content:
            const Text('Please select the reason for reporting this post:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _navigateToEditScreen(BuildContext context) {
    context.pushNamed(
      'editPost',
      pathParameters: {'id': widget.post.id},
      queryParameters: {'isAlt': widget.post.isAlt.toString()},
    );
  }
}
