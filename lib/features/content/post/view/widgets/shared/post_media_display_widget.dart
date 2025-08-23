// lib/features/content/post/view/widgets/shared/post_media_display.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_media_model.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class PostMediaDisplay extends StatelessWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;

  const PostMediaDisplay({
    super.key,
    required this.post,
    this.displayMode = HeaderDisplayMode.compact,
  });

  @override
  Widget build(BuildContext context) {
    final mediaItems = _getMediaItemsFromPost(post);

    if (mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    final isCompact = displayMode == HeaderDisplayMode.compact;

    return MediaCarouselWidget(
      mediaItems: mediaItems,
      height: isCompact ? 300 : 350,
      autoPlay: !isCompact,
      showIndicator: mediaItems.length > 1,
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
