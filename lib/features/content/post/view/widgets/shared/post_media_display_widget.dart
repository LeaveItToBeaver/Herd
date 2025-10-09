import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_media_model.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class PostMediaDisplay extends StatelessWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;
  final double? maxHeight;

  const PostMediaDisplay({
    super.key,
    required this.post,
    this.displayMode = HeaderDisplayMode.compact,
    this.maxHeight,
  });

  @override
  Widget build(BuildContext context) {
    final mediaItems = _getMediaItemsFromPost(post);

    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final isCompact = displayMode == HeaderDisplayMode.compact;
    final isPinned = displayMode == HeaderDisplayMode.pinned;
    
    // Use available space or fallback to reasonable defaults
    if (maxHeight != null) {
      // Use ALL available space when provided
      return MediaCarouselWidget(
        mediaItems: mediaItems,
        height: maxHeight!,
        autoPlay: !isCompact && !isPinned,
        showIndicator: isPinned ? false : mediaItems.length > 1, // No indicators for pinned posts
        onMediaTap: (media, index) {
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
    
    // Fallback to responsive heights when maxHeight not provided
    final mediaHeight = isPinned ? 200.0 : (isCompact ? 300.0 : 350.0);
    
    return MediaCarouselWidget(
      mediaItems: mediaItems,
      height: mediaHeight,
      autoPlay: !isCompact && !isPinned,
      showIndicator: isPinned ? false : mediaItems.length > 1, // No indicators for pinned posts
      onMediaTap: (media, index) {
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
        mediaItems.add(PostMediaModel(
          id: '0',
          url: url,
          thumbnailUrl: post.mediaThumbnailURL,
          mediaType: post.mediaType ?? 'image',
        ));
      }
    }

    // Validate each media item
    return mediaItems
        .where((item) => item.url.isNotEmpty && item.url.contains('://'))
        .toList();
  }
}
