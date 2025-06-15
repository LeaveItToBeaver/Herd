import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/widgets/media_carousel_widget.dart';
import 'package:herdapp/features/rich_text_editing/view/widgets/quill_viewer_widget.dart';
import 'package:video_player/video_player.dart';

class PostContentSection extends ConsumerWidget {
  final String postId;
  final bool isAlt;
  final bool showNSFWContent;
  final VoidCallback toggleNSFW;
  final VideoPlayerController? videoController;
  final ChewieController? chewieController;
  final Function(String)? initializeVideo;
  final bool isVideoInitialized;

  const PostContentSection({
    super.key,
    required this.postId,
    required this.isAlt,
    required this.toggleNSFW,
    this.showNSFWContent = false,
    this.videoController,
    this.chewieController,
    this.initializeVideo,
    this.isVideoInitialized = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final postAsyncValue =
        ref.watch(staticPostProvider(PostParams(id: postId, isAlt: isAlt)));

    // It's better to handle the loading/error/data states directly here
    return postAsyncValue.when(
      data: (post) {
        if (post == null) {
          return const Center(child: Text('Post not found.'));
        }

        // Initialize video if necessary (existing logic)
        if (post.mediaType == 'video' &&
            post.mediaURL != null &&
            !isVideoInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (initializeVideo != null) {
              initializeVideo!(post.mediaURL!);
            }
          });
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post title
              if (post.title != null && post.title!.isNotEmpty) ...[
                Text(
                  post.title!,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (_hasMedia(post)) ...[
                post.isNSFW && !showNSFWContent
                    ? _buildNSFWContentOverlay(context, post)
                    : _buildMedia(context, post),
              ],

              const SizedBox(height: 16),

              // Post content: Use QuillViewerWidget for rich text, fallback for plain text
              if (post.isRichText)
                QuillViewerWidget(
                  key: ValueKey(
                      'quill_viewer_${post.id}_screen'), // Add a key for PostScreen
                  jsonContent: post.content,
                  source: RichTextSource.postScreen,
                  // isExpanded is not needed here as PostScreen always shows full content
                )
              else
                Text(
                  // Fallback for plain text
                  post.content,
                  style: const TextStyle(fontSize: 16),
                )
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Center(child: Text('Error loading post: $error')),
    );
  }

  bool _hasMedia(dynamic post) {
    return post.mediaURL != null && post.mediaURL.isNotEmpty;
  }

  Widget _buildMedia(BuildContext context, dynamic post) {
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

  Widget _buildNSFWContentOverlay(BuildContext context, dynamic post) {
    // Added post parameter
    return GestureDetector(
      onTap: toggleNSFW,
      child: Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          //color: Colors.grey.shade200,
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
              //style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: toggleNSFW,
              icon: const Icon(Icons.visibility),
              label: const Text('View Content'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                //foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
