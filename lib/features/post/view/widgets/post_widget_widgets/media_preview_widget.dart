import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:herdapp/features/post/view/widgets/media_carousel_widget.dart';

class MediaPreviewWidget extends StatelessWidget {
  final PostModel post;
  final double height;
  final bool autoPlay;
  final bool Function(int)? showIndicatorCondition;
  final void Function(PostMediaModel media, int index)? onMediaTap;

  const MediaPreviewWidget({
    super.key,
    required this.post,
    this.height = 350,
    this.autoPlay = false,
    this.showIndicatorCondition,
    this.onMediaTap,
  });

  @override
  Widget build(BuildContext context) {
    List<PostMediaModel> mediaItems = _getMediaItemsFromPost(post);

    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Create a carousel with improved configuration
    return MediaCarouselWidget(
      mediaItems: mediaItems,
      height: height,
      autoPlay: autoPlay,
      showIndicator: showIndicatorCondition?.call(mediaItems.length) ??
          (mediaItems.length > 1), // Only show indicators if multiple items
      onMediaTap: onMediaTap ??
          (media, index) {
            // Default navigation to fullscreen gallery
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

  List<PostMediaModel> _getMediaItemsFromPost(PostModel post) {
    List<PostMediaModel> mediaItems = [];

    // Check for new media items format first
    if (post.mediaItems.isNotEmpty) {
      mediaItems = post.mediaItems;
    }
    // Fall back to legacy format
    else if (post.mediaURL != null && post.mediaURL!.isNotEmpty) {
      final url = post.mediaURL!;
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
}
