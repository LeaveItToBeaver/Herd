import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/helpers/like_dislike_helper.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:shimmer/shimmer.dart';

import '../../../create_post/create_post_controller.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../../../user/view/providers/user_provider.dart';
import '../../../user/view/widgets/user_profile_image.dart';
import '../../data/models/post_media_model.dart';
import '../../data/models/post_model.dart';
import '../providers/post_provider.dart';
import '../providers/state/post_interaction_state.dart';
import 'media_carousel_widget.dart';

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
          color: theme.colorScheme.surface,
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

              // NSFW Indicator - Add this here

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

  Widget _buildActualContent(ThemeData theme) {
    return _shouldShowMedia()
        ? _buildMediaPreview(widget.post)
        : _buildContentText(theme);
  }

  Widget _buildNSFWOverlay() {
    return GestureDetector(
      onTap: () {
        // Correctly update the state variable for revealing THIS post
        setState(() {
          _isNsfwRevealed = true;
        });
      },
      child: Container(
        height: 200, // Or adjust height as needed
        width: double.infinity,
        decoration: BoxDecoration(
          // Consider using a blur effect instead of just grey
          color: Colors.grey.shade700.withOpacity(0.85),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility_off, size: 48, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'NSFW Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap to view',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNsfwHiddenMessage() {
    return Container(
      height: 150, // Or adjust height
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.block, size: 40, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'NSFW Content Hidden',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Adjust your settings to view',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeIndicator({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthorHeader(String formattedTimestamp) {
    debugPrint(
        'Building author header for post ${widget.post.id}, timestamp: $formattedTimestamp');
    return Consumer(
      builder: (context, ref, child) {
        final userAsyncValue = ref.watch(userProvider(widget.post.authorId));

        return userAsyncValue.when(
          loading: () => _buildLoadingHeader(),
          error: (error, stack) => Text('Error loading user',
              style: TextStyle(color: Colors.red.shade300)),
          data: (user) {
            if (user == null) return const Text('User not found');

            // Use appropriate profile image based on post privacy
            final profileImageUrl = widget.post.isAlt
                ? (user.altProfileImageURL ?? user.profileImageURL)
                : user.profileImageURL;

            // Use appropriate name based on post privacy
            final displayName = widget.post.isAlt
                ? (user.username)
                : '${user.firstName} ${user.lastName}'.trim();

            return Row(
              children: [
                // Profile image
                GestureDetector(
                  onTap: () => _navigateToProfile(user.id),
                  child: CircleAvatar(
                    radius: widget.isCompact ? 16 : 20,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage:
                        profileImageUrl != null && profileImageUrl.isNotEmpty
                            ? NetworkImage(profileImageUrl)
                            : null,
                    child: profileImageUrl == null || profileImageUrl.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                            size: widget.isCompact ? 16 : 20,
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                // User info
                Expanded(
                  child: GestureDetector(
                    onTap: () => _navigateToProfile(user.id),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Username
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: widget.isCompact ? 13 : 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (widget.post.isAlt) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.lock,
                                  size: 12, color: Colors.blue.shade400),
                            ],
                          ],
                        ),

                        // Timestamp - always show
                        Text(
                          formattedTimestamp,
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Post options menu
                _buildPostMenu(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildHerdHeader(String formattedTimestamp) {
    debugPrint(
        'Building herd header for post ${widget.post.id}, timestamp: $formattedTimestamp');
    return Consumer(
      builder: (context, ref, child) {
        final herdId = widget.post.herdId!;
        final herdAsyncValue = ref.watch(herdProvider(herdId));
        final userAsyncValue = ref.watch(userProvider(widget.post.authorId));

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Herd name row
            herdAsyncValue.when(
              loading: () => _buildShimmerText(width: 150, height: 18),
              error: (_, __) => const Text('Unknown herd',
                  style: TextStyle(fontStyle: FontStyle.italic)),
              data: (herd) {
                if (herd == null) return const Text('Unknown herd');

                return GestureDetector(
                  onTap: () =>
                      context.pushNamed('herd', pathParameters: {'id': herdId}),
                  child: Row(
                    children: [
                      // Use the UserProfileImage widget for herd avatar
                      UserProfileImage(
                        radius: widget.isCompact ? 16 : 20,
                        profileImageUrl: herd.profileImageURL,
                      ),

                      const SizedBox(width: 12),

                      // Herd name (without h/ prefix)
                      Expanded(
                        child: Text(
                          herd.name, // No h/ prefix
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: widget.isCompact ? 14 : 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Post menu
                      _buildPostMenu(),
                    ],
                  ),
                );
              },
            ),

            // Author and timestamp row - always show
            Padding(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0),
              child: Row(
                children: [
                  userAsyncValue.when(
                    loading: () => _buildShimmerText(width: 100, height: 12),
                    error: (_, __) => const Text('Unknown user',
                        style: TextStyle(
                            fontStyle: FontStyle.italic, fontSize: 12)),
                    data: (user) {
                      final displayName = user != null
                          ? (widget.post.isAlt
                              ? (user.username)
                              : '${user.firstName} ${user.lastName}'.trim())
                          : 'Anonymous';

                      return GestureDetector(
                        onTap: () =>
                            user != null ? _navigateToProfile(user.id) : null,
                        child: Text(
                          'Posted by $displayName',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: widget.isCompact ? 11 : 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedTimestamp,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: widget.isCompact ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
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
        const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      ],
    );
  }

  Widget _buildPostMenu() {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    final isCurrentUserAuthor = userId == widget.post.authorId;

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade700),
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'report':
            _showReportDialog();
            break;
          case 'edit':
            _navigateToEditScreen(context);
            break;
          case 'delete':
            _showDeleteConfirmation(context);
            break;
          case 'save':
            _savePost();
            break;
        }
      },
      itemBuilder: (context) => [
        if (isCurrentUserAuthor)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, size: 20),
                SizedBox(width: 8),
                Text('Edit post'),
              ],
            ),
          ),
        if (isCurrentUserAuthor)
          const PopupMenuItem(
            value: 'delete',
            child: Row(
              children: [
                Icon(Icons.delete_outline, color: Colors.red, size: 20),
                SizedBox(width: 8),
                Text('Delete post', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        const PopupMenuItem(
          value: 'save',
          child: Row(
            children: [
              Icon(Icons.bookmark_border, size: 20),
              SizedBox(width: 8),
              Text('Save post'),
            ],
          ),
        ),
        if (!isCurrentUserAuthor)
          const PopupMenuItem(
            value: 'report',
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 20),
                SizedBox(width: 8),
                Text('Report post'),
              ],
            ),
          ),
      ],
    );
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
            widget.post.content,
            style: TextStyle(
              fontSize: widget.isCompact ? 14 : 15,
              color: theme.colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
            maxLines: _isExpanded ? null : (widget.isCompact ? 3 : 4),
            overflow: _isExpanded ? null : TextOverflow.ellipsis,
          ),
          if (widget.post.content.length > 200 && !_isExpanded)
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
    List<PostMediaModel> mediaItems = getMediaItemsFromPost(post);

    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Create a carousel with improved configuration
    return MediaCarouselWidget(
      mediaItems: mediaItems,
      height: 350,
      autoPlay: false,
      showIndicator:
          mediaItems.length > 1, // Only show indicators if multiple items
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
    required VoidCallback? onPressed,
  }) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(
        icon,
        size: 18,
        color: color ?? Colors.grey.shade700,
      ),
      label: Text(
        count,
        style: TextStyle(
          color: color ?? Colors.grey.shade700,
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
