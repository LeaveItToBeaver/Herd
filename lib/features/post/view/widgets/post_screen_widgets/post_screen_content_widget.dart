import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';
import 'package:herdapp/features/post/view/widgets/media_carousel_widget.dart';
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
    // Only watch the specific post data you need
    final post = ref.watch(
        staticPostProvider(PostParams(id: postId, isAlt: isAlt))
            .select((value) => value.value));

    debugPrint('Rebuilding PostContentSection for postId: $postId');

    if (post == null) return const SizedBox.shrink();

    if (post.mediaType == 'video' &&
        post.mediaURL != null &&
        !isVideoInitialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        initializeVideo!(post.mediaURL!);
      });
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post title
          Text(
            post.title ?? '',
            style: theme.textTheme.titleLarge?.copyWith(
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
            post.isNSFW && !showNSFWContent
                ? _buildNSFWContentOverlay(context)
                : _buildMedia(context, post),
          ],
        ],
      ),
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

  Widget _buildNSFWContentOverlay(BuildContext context) {
    return GestureDetector(
      onTap: toggleNSFW, // Use the callback instead of setState
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
              onPressed: toggleNSFW, // Use the callback instead of setState
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
  // Other helper methods
}
