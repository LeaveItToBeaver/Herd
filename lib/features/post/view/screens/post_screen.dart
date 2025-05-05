import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/helpers/like_dislike_helper.dart';
import 'package:herdapp/features/post/view/providers/state/post_interaction_state.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:video_player/video_player.dart';

import '../../../comment/view/providers/comment_providers.dart';
import '../../../comment/view/providers/reply_providers.dart';
import '../../../comment/view/widgets/comment_list_widget.dart';
import '../../../create_post/create_post_controller.dart';
import '../../../user/data/models/user_model.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../../../user/view/providers/user_provider.dart';
import '../../data/models/post_media_model.dart';
import '../providers/post_provider.dart' hide commentsProvider;
import '../widgets/media_carousel_widget.dart';
import 'edit_post_screen.dart';

class PostScreen extends ConsumerStatefulWidget {
  final String postId;
  final bool isAlt;
  final String? herdId;

  const PostScreen({
    super.key,
    required this.postId,
    this.isAlt = false,
    this.herdId,
  });

  @override
  ConsumerState<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends ConsumerState<PostScreen> {
  final FocusNode _commentFocusNode = FocusNode();
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoInitialized = false;
  bool _showNSFWContent = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      final userId = user.userId;
      if (userId != null) {
        // Use the updated provider with PostParams
        ref
            .read(postInteractionsWithPrivacyProvider(
                    // Pass params needed by interactions provider
                    PostParams(
                        id: widget.postId,
                        isAlt: widget.isAlt,
                        herdId: widget.herdId))
                .notifier)
            .initializeState(userId);
      }
    });
  }

  @override
  @override
  void dispose() {
    _commentFocusNode.dispose();
    _disposeVideoControllers();
    super.dispose();
  }

  void _disposeVideoControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _isVideoInitialized = false;
  }

  Future<void> _initializeVideo(String videoUrl) async {
    if (_isVideoInitialized) return;

    // Dispose any existing controllers first
    _disposeVideoControllers();

    try {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: const Center(child: CircularProgressIndicator()),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.blue.withOpacity(0.5),
        ),
      );

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      // Show an error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load video: $e')),
        );
      }
    }
  }

// In your PostScreen widget
  @override
  Widget build(BuildContext context) {
    final staticPostAsyncValue = ref.watch(staticPostProvider(PostParams(
        id: widget.postId,
        isAlt: widget
            .isAlt))); // Don't pass herdId if static provider doesn't need it
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.userOrNull;

    // We still need PostParams for the interaction provider later
    final interactionParams = PostParams(
        id: widget.postId, isAlt: widget.isAlt, herdId: widget.herdId);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: widget.isAlt ? Colors.blue : Colors.white,
        title: LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: [
              if (widget.isAlt)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.lock, size: 20),
                ),
              Expanded(
                child: staticPostAsyncValue.when(
                  data: (post) => Text(
                    post?.title ?? 'Post',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    softWrap: false,
                  ),
                  loading: () => const Text('Loading...'),
                  error: (error, stack) => const Text('Error'),
                ),
              ),
            ],
          );
        }),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: widget.isAlt
                ? null
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Sharing post...')),
                    );
                  },
            color: widget.isAlt ? Colors.grey : Colors.white,
          ),
        ],
      ),

      // Main content with RefreshIndicator for pull-to-refresh
      body: staticPostAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }
          if (currentUser == null) {
            return const Center(
                child: Text('User not found.')); // Handle missing user
          }

          // Wrap with RefreshIndicator for pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => _refreshPost(interactionParams),
            child: SingleChildScrollView(
              // Important: physics needed for RefreshIndicator to work
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy badge (if needed)
                  if (post.isAlt)
                    Container(
                      color: Colors.blue.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.lock, size: 16, color: Colors.blue),
                          const SizedBox(width: 8),
                          const Text(
                            'Alt Post',
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

                  // NSFW badge - Add this section
                  if (post.isNSFW)
                    Container(
                      color: Colors.red.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              size: 16, color: Colors.red),
                          const SizedBox(width: 8),
                          const Text(
                            'NSFW Content',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'This post contains sensitive content',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Post content
                  _buildPostContent(post, currentUser!),

                  // Comments section header
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "Comments",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  // Comments list widget
                  CommentListWidget(
                    postId: widget.postId,
                    isAltPost: widget.isAlt,
                  ),

                  // Extra bottom padding
                  const SizedBox(height: 80),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _refreshPost(PostParams interactionParams) async {
    // Accept params
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Refreshing...'),
          duration: Duration(milliseconds: 800)));

      // 1. Invalidate the static provider to force a re-fetch
      ref.invalidate(staticPostProvider(
          PostParams(id: widget.postId, isAlt: widget.isAlt)));

      // 2. Reload comments (no change needed here)
      await ref.read(commentsProvider(widget.postId).notifier).loadComments();
      await ref.read(repliesProvider(widget.postId).notifier).loadReplies();

      // 3. Reload interaction data
      final user = ref.read(currentUserProvider);
      final userId = user.userId;
      if (userId != null) {
        // Invalidate and re-initialize the interactions provider
        ref.invalidate(postInteractionsWithPrivacyProvider(interactionParams));
        await ref
            .read(
                postInteractionsWithPrivacyProvider(interactionParams).notifier)
            .initializeState(userId);
      }

      // No need for setState({}) here as provider invalidation triggers rebuilds
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error refreshing: $e')));
      }
    }
  }

  Widget _buildNSFWContentOverlay() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showNSFWContent = true;
        });
      },
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.visibility_off, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'NSFW Content',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'This post contains sensitive content',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _showNSFWContent = true;
                });
              },
              icon: const Icon(Icons.visibility),
              label: const Text('View Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostContent(PostModel post, UserModel currentUser) {
    final theme = Theme.of(context);

    debugPrint(
        'Building _buildPostContent UI for post ${post.id}'); // Should print less often now

    // Initialize video logic (needs adjustment if it relied on AsyncValue lifecycle)
    // Consider moving initialization to initState or based on the staticPostProvider's data state
    // This needs careful handling to avoid re-initializing on every build.
    // Maybe trigger _initializeVideo only when the post.mediaURL changes.
    // For now, keep the existing logic but be aware it might run frequently.
    if (post.mediaType == 'video' &&
        post.mediaURL != null &&
        !_isVideoInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _initializeVideo(post.mediaURL!);
      });
    } else if (post.mediaType != 'video' && _isVideoInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _disposeVideoControllers();
        // Consider setState if _isVideoInitialized needs update for UI
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Consumer(builder: (context, ref, child) {
          // Watch the provider for the specific author of this post
          final userAsyncValue = ref.watch(userProvider(post.authorId));

          // Handle loading, error, and data states for the author's details
          return userAsyncValue.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(12.0),
              // Show a simple loading indicator or a shimmer placeholder
              child: Row(
                children: [
                  CircleAvatar(radius: 25, backgroundColor: Colors.grey),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                          height: 8,
                          width: 100,
                          child: LinearProgressIndicator()),
                      SizedBox(height: 4),
                      SizedBox(
                          height: 8,
                          width: 60,
                          child: LinearProgressIndicator()),
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

              // --- Build the actual author header using 'user', 'post', and 'currentUser' ---
              // Determine which profile image to use based on post privacy (isAlt)
              final profileImageUrl = post.isAlt
                  ? user.altProfileImageURL ??
                      user.profileImageURL // Fallback to public if alt is null
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
                            : const AssetImage(
                                    'assets/images/default_avatar.png')
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
                              // Use author's username from 'user' object
                              user.username ?? 'Anonymous',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Text(
                            // Use post's timestamp from 'post' object
                            _formatTimestamp(post.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit/delete menu: Show only if the logged-in user ('currentUser') is the author
                    if (currentUser.id == post.authorId)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'edit') {
                            context.pushNamed(
                              'editPost',
                              pathParameters: {'id': post.id},
                              queryParameters: {'isAlt': post.isAlt.toString()},
                              extra: post, // Pass the static post object
                            );
                          } else if (value == 'delete') {
                            // Pass post.id from the static post object
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
            }, // End of data case
          ); // End of userAsyncValue.when
        }),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post title
              Text(
                post.title!,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Post content text
              Text(
                post.content,
                style: const TextStyle(fontSize: 16),
              ),

              const SizedBox(height: 16),

              // Media content (if any)
              // Pass post object which contains media info
              if (_hasMedia(post)) ...[
                // Use a StatefulWidget or Consumer if NSFW state needs local management
                // Assuming _showNSFWContent is managed by the parent _PostScreenState
                post.isNSFW && !_showNSFWContent
                    ? _buildNSFWContentOverlay() // This depends on _showNSFWContent state
                    : _buildMedia(post), // This depends on post data
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          // width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Share Button (conditionally enabled)
              _buildShareButton(post.isAlt), // Pass isAlt flag

              // Comment Button (using Consumer to watch comment count)
              _buildCommentButton(post.id, post.isAlt), // Pass IDs

              // Like/Dislike Buttons (already uses Consumer internally)
              _buildLikeDislikeButtons(),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildShareButton(bool isAlt) {
    return TextButton.icon(
      icon: Icon(
        Icons.share_rounded,
        size: 24, // Adjusted size
        color: isAlt ? Colors.grey.shade400 : Colors.grey.shade700,
      ),
      label: Text(
        'Share',
        style: TextStyle(
          color: isAlt ? Colors.grey.shade400 : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
      onPressed: isAlt ? null : _sharePost, // Disable for alt posts
      style: TextButton.styleFrom(
        minimumSize: Size.zero,
        padding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // Adjust padding
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }

  Widget _buildCommentButton(String postId, bool isAlt) {
    return Consumer(
      builder: (context, ref, child) {
        // Watch the interaction state which includes the totalComments count
        final interactionState = ref.watch(postInteractionsWithPrivacyProvider(
            PostParams(id: postId, isAlt: isAlt)));
        // Directly access the totalComments integer from the state
        final commentCount = interactionState.totalComments;

        // Convert the integer count directly to a string for display
        // No need for .when() as commentCount is an int, not an AsyncValue
        final countDisplay = commentCount.toString();

        return TextButton.icon(
          icon: Icon(
            Icons.comment_rounded,
            size: 24, // Adjusted size
            color: Colors.grey.shade700,
          ),
          label: Text(
            countDisplay, // Use the direct string representation
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          onPressed: () {
            // Scroll to comments or open comments section
            // TODO: Implement scroll/navigation to comments
            debugPrint("Comment button tapped");
          },
          style: TextButton.styleFrom(
            minimumSize: Size.zero,
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 8), // Adjust padding
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      },
    );
  }

  Widget _buildLikeDislikeButtons() {
    // Make sure PostParams uses widget.postId and widget.isAlt
    final params = PostParams(
        id: widget.postId, isAlt: widget.isAlt, herdId: widget.herdId);

    return Consumer(
      builder: (context, ref, child) {
        // Use select to minimize rebuilds
        final interactionState = ref.watch(
            postInteractionsWithPrivacyProvider(params).select((state) => (
                  state.isLiked,
                  state.isDisliked,
                  state
                      .totalLikes, // Ensure totalLikes is updated by the provider
                  state.isLoading
                )));

        final isLiked = interactionState.$1;
        final isDisliked = interactionState.$2;
        final totalLikes = interactionState.$3;
        final isLoading = interactionState.$4;

        // Use a Row or specific layout widgets
        return Row(
          mainAxisSize: MainAxisSize.min, // Take minimum space needed
          children: [
            SizedBox(
              // Wrap IconButton in SizedBox for consistent sizing
              width: 48, height: 48,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
                  color: isLiked ? Colors.green : Colors.grey.shade700,
                  size: 24, // Adjusted size
                ),
                onPressed: isLoading ? null : _handleLikePost,
              ),
            ),
            SizedBox(
              // Add SizedBox for spacing and consistent layout
              width: 30, // Adjust width as needed
              child: Center(
                child: Text(
                  totalLikes.toString(),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            SizedBox(
              // Wrap IconButton in SizedBox
              width: 48, height: 48,
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: Icon(
                  isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
                  color: isDisliked ? Colors.red : Colors.grey.shade700,
                  size: 24, // Adjusted size
                ),
                onPressed: isLoading ? null : _handleDislikePost,
              ),
            ),
          ],
        );
      },
    );
  }

  List<PostMediaModel> getMediaItemsFromPost(dynamic post) {
    List<PostMediaModel> mediaItems = [];

    // Check for new media items format first
    if (post.mediaItems != null && post.mediaItems.isNotEmpty) {
      mediaItems = post.mediaItems;
      debugPrint('Found ${mediaItems.length} media items in post');
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
        debugPrint('Using legacy media URL: $url');
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

  bool _hasMedia(dynamic post) {
    return post.mediaURL != null && post.mediaURL.isNotEmpty;
  }

  Widget _buildMedia(dynamic post) {
    List<PostMediaModel> mediaItems = getMediaItemsFromPost(post);

    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Create a carousel
    return MediaCarouselWidget(
      mediaItems: mediaItems,
      height: 350,
      autoPlay: false,
      showIndicator:
          mediaItems.length > 1, // Only show indicators if multiple items
      onMediaTap: (media, index) {
        debugPrint("Tapped media item at index $index");

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
    final user = ref.read(currentUserProvider);
    final post = ref
        .watch(postProviderWithPrivacy(
          PostParams(id: postId, isAlt: widget.isAlt),
        ))
        .value;

    if (post == null || user.userId != post.authorId) {
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
                      postId,
                      user.userId!,
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
        size: 32,
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

// // Update the _buildLikeDislikeButtons method
//   Widget _buildLikeDislikeButtons() {
//     return Consumer(
//       builder: (context, ref, child) {
//         final params = PostParams(
//             id: widget.postId, isAlt: widget.isAlt, herdId: widget.herdId);
//         // Use select to minimize rebuilds
//         final interactionState = ref.watch(
//             postInteractionsWithPrivacyProvider(params).select((state) => (
//                   state.isLiked,
//                   state.isDisliked,
//                   state.totalLikes,
//                   state.isLoading
//                 )));
//         final isLiked = interactionState.$1;
//         final isDisliked = interactionState.$2;
//         final totalLikes = interactionState.$3;
//         final isLoading = interactionState.$4;
//         // Use a Row with defined constraints
//         return SizedBox(
//           height: 48,
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 icon: Icon(
//                   isLiked ? Icons.thumb_up : Icons.thumb_up_outlined,
//                   color: isLiked ? Colors.green : Colors.grey,
//                 ),
//                 onPressed: isLoading ? null : _handleLikePost,
//               ),
//               Text(totalLikes.toString()),
//               IconButton(
//                 icon: Icon(
//                   isDisliked ? Icons.thumb_down : Icons.thumb_down_outlined,
//                   color: isDisliked ? Colors.red : Colors.grey,
//                 ),
//                 onPressed: isLoading ? null : _handleDislikePost,
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

  void _sharePost() {
    // Only allow sharing public posts
    if (widget.isAlt) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
    );
    // Implement actual sharing functionality
  }

  void _handleLikePost() {
    LikeDislikeHelper.handleLikePost(
      context: context,
      ref: ref,
      postId: widget.postId,
      isAlt: widget.isAlt,
      herdId: widget.herdId,
    );
  }

  void _handleDislikePost() {
    LikeDislikeHelper.handleDislikePost(
      context: context,
      ref: ref,
      postId: widget.postId,
      isAlt: widget.isAlt,
      herdId: widget.herdId,
    );
  }

  ImageProvider? _getCurrentUserProfileImage() {
    final currentUser = ref.read(currentUserProvider);

    final profileImageUrl = widget.isAlt
        ? (currentUser.safeAltProfileImageURL ??
            currentUser.safeAltProfileImageURL)
        : currentUser.safeAltProfileImageURL;

    return profileImageUrl != null
        ? NetworkImage(profileImageUrl)
        : const AssetImage('assets/images/default_avatar.png');
  }
}
