import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:video_player/video_player.dart';

import '../../../comment/view/providers/comment_providers.dart';
import '../../../comment/view/providers/reply_providers.dart';
import '../../../comment/view/widgets/comment_list_widget.dart';
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

  const PostScreen({
    super.key,
    required this.postId,
    this.isAlt = false,
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
                    PostParams(id: widget.postId, isAlt: widget.isAlt))
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
      print('Error initializing video: $e');
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
    final postAsyncValue = ref.watch(widget.isAlt
        ? postProviderWithPrivacy(
            PostParams(id: widget.postId, isAlt: widget.isAlt))
        : postProvider(widget.postId));
    final currentUserAsync = ref.watch(currentUserProvider);
    final currentUser = currentUserAsync.userOrNull;

    return Scaffold(
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
                child: postAsyncValue.when(
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
      body: postAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }

          // Wrap with RefreshIndicator for pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => _refreshPost(),
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
                  _buildPostContent(postAsyncValue, currentUser!),

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

  Future<void> _refreshPost() async {
    try {
      // Show a loading indicator
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Refreshing...'),
          duration: Duration(milliseconds: 800)));

      // Force invalidate all related providers
      if (widget.isAlt) {
        ref.refresh(postProviderWithPrivacy(
            PostParams(id: widget.postId, isAlt: true)));
      } else {
        ref.refresh(postProvider(widget.postId));
      }

      // Force reload comments
      await ref.read(commentsProvider(widget.postId).notifier).loadComments();
      await ref.read(repliesProvider(widget.postId).notifier).loadReplies();

      // Reload interaction data
      final user = ref.read(currentUserProvider);
      final userId = user.userId;
      if (userId != null) {
        // Use the existing interaction provider
        ref.invalidate(postInteractionsWithPrivacyProvider(
            PostParams(id: widget.postId, isAlt: widget.isAlt)));

        // Initialize the interaction state
        await ref
            .read(postInteractionsWithPrivacyProvider(
                    PostParams(id: widget.postId, isAlt: widget.isAlt))
                .notifier)
            .initializeState(userId);
      }

      // Force UI update
      if (mounted) {
        setState(() {});
      }
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

  Widget _buildPostContent(
      AsyncValue<dynamic> postAsyncValue, UserModel currentUser) {
    return postAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
      data: (post) {
        if (post == null) {
          return const Center(child: Text('Post not found.'));
        }

        final userAsyncValue = ref.watch(userProvider(post.authorId));
        int postLikes = post.likeCount;
        int commentCount = post.commentCount;

        // Initialize video if this is a video post
        if (post.mediaType == 'video' && post.mediaURL != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initializeVideo(post.mediaURL!);
          });
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                final profileImageUrl = post.isAlt
                    ? user.altProfileImageURL ?? user.profileImageURL
                    : user.profileImageURL;

                return Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // Navigate to appropriate profile
                          if (post.isAlt) {
                            context.pushNamed(
                              'altProfile',
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
                              : const AssetImage(
                                      'assets/images/default_avatar.png')
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
                                if (post.isAlt) {
                                  context.pushNamed(
                                    'altProfile',
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
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
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
                      if (currentUser.id == post.authorId)
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'edit') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      EditPostScreen(post: post),
                                ),
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

                  // Post content text
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 16),

                  // Media content (if any)
                  if (_hasMedia(post)) ...[
                    post.isNSFW && !_showNSFWContent
                        ? _buildNSFWContentOverlay()
                        : _buildMedia(post),
                  ],
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
                    onPressed:
                        post.isAlt ? null : () {}, // Disable for alt posts
                    enabled: !post.isAlt,
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
                    postId: widget.postId,
                    isAlt: widget.isAlt,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // In post_widget.dart and post_screen.dart, update the media item conversion:

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
    required String postId,
    required bool isAlt,
  }) {
    final interactionState = ref.watch(postInteractionsWithPrivacyProvider(
        PostParams(id: postId, isAlt: isAlt)));

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(
                interactionState.isLiked
                    ? Icons.thumb_up
                    : Icons.thumb_up_outlined,
                color: interactionState.isLiked ? Colors.green : Colors.grey),
            onPressed: interactionState.isLoading
                ? null
                : () => _handleLikePost(context, ref, postId),
          ),
          // Display net likes (which can be negative)
          Text(
            interactionState.totalLikes.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: interactionState.totalLikes < 0 ? Colors.red : null,
            ),
          ),
          IconButton(
            icon: Icon(
                interactionState.isDisliked
                    ? Icons.thumb_down
                    : Icons.thumb_down_outlined,
                color: interactionState.isDisliked ? Colors.red : Colors.grey),
            onPressed: interactionState.isLoading
                ? null
                : () => _handleDislikePost(context, ref, postId),
          ),
        ],
      ),
    );
  }

  void _handleLikePost(BuildContext context, WidgetRef ref, String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId != null) {
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: postId, isAlt: widget.isAlt))
              .notifier)
          .likePost(userId, isAlt: widget.isAlt);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to like posts.')),
      );
    }
  }

  void _handleDislikePost(BuildContext context, WidgetRef ref, String postId) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;

    if (userId != null) {
      ref
          .read(postInteractionsWithPrivacyProvider(
                  PostParams(id: postId, isAlt: widget.isAlt))
              .notifier)
          .dislikePost(userId, isAlt: widget.isAlt);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('You must be logged in to dislike posts.')),
      );
    }
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
