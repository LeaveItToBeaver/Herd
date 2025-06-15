import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/view/widgets/post_screen_widgets/post_screen_action_bar_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_screen_widgets/post_screen_content_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_screen_widgets/post_screen_header_widget.dart';
import 'package:herdapp/features/post/view/widgets/post_screen_widgets/post_screen_privacy_badges_widget.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:video_player/video_player.dart';
import 'package:herdapp/features/post/view/widgets/post_screen_widgets/post_screen_comment_widget.dart';

import '../../../comment/view/providers/comment_providers.dart';
import '../../../comment/view/providers/reply_providers.dart';
import '../../../user/view/providers/current_user_provider.dart';
import '../providers/post_provider.dart' hide commentsProvider;

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final staticPostAsyncValue = ref.watch(
        staticPostProvider(PostParams(id: widget.postId, isAlt: widget.isAlt)));

    final currentUserAsync =
        ref.watch(currentUserProvider.select((value) => value.userOrNull));

    final interactionParams = PostParams(
        id: widget.postId, isAlt: widget.isAlt, herdId: widget.herdId);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        // backgroundColor: widget.isAlt
        //     ? theme.appBarTheme.foregroundColor
        //     : theme.appBarTheme.foregroundColor,
        title: LayoutBuilder(builder: (context, constraints) {
          return Row(
            children: [
              if (widget.isAlt)
                const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.public_rounded, size: 20),
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
            //color: widget.isAlt ? Colors.grey : Colors.white,
          ),
        ],
      ),
      body: staticPostAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (post) {
          if (post == null) {
            return const Center(child: Text('Post not found.'));
          }
          if (currentUserAsync == null) {
            return const Center(
                child: Text('User not found.')); // Handle missing user
          }

          // Wrap with RefreshIndicator for pull-to-refresh
          return RefreshIndicator(
            onRefresh: () => _refreshPost(interactionParams),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Privacy badges
                  PostPrivacyBadges(
                    isAlt: post.isAlt,
                    isNSFW: post.isNSFW,
                  ),

                  // Author header
                  PostAuthorHeader(
                    postId: widget.postId,
                    isAlt: widget.isAlt,
                  ),

                  // Post content
                  PostContentSection(
                    postId: widget.postId,
                    isAlt: widget.isAlt,
                    showNSFWContent: _showNSFWContent,
                    toggleNSFW: _toggleNSFW,
                    videoController: _videoController,
                    chewieController: _chewieController,
                    isVideoInitialized: _isVideoInitialized,
                    initializeVideo: _initializeVideo,
                  ),

                  // Action bar
                  PostActionBar(
                    postId: widget.postId,
                    isAlt: widget.isAlt,
                    herdId: widget.herdId,
                    onCommentTap: _scrollToComments,
                    onShareTap: post.isAlt ? null : _sharePost,
                  ),

                  // Comments section
                  PostCommentSection(
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

  void _toggleNSFW() {
    setState(() {
      _showNSFWContent = !_showNSFWContent;
    });
  }

  void _scrollToComments() {
    // Implement scrolling to comments section
  }

  void _sharePost() {
    if (widget.isAlt) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing post...')),
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
}
