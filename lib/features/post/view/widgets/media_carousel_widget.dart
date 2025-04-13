import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';

class MediaCarouselWidget extends StatefulWidget {
  final List<PostMediaModel> mediaItems;
  final bool autoPlay;
  final double height;
  final bool showIndicator;
  final Function(PostMediaModel, int)? onMediaTap;
  final bool isFullscreen;

  const MediaCarouselWidget({
    Key? key,
    required this.mediaItems,
    this.autoPlay = false,
    this.height = 250.0,
    this.showIndicator = true,
    this.onMediaTap,
    this.isFullscreen = false,
  }) : super(key: key);

  @override
  State<MediaCarouselWidget> createState() => _MediaCarouselWidgetState();
}

class _MediaCarouselWidgetState extends State<MediaCarouselWidget> {
  int _currentIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Prefetch media after the widget is built
    _prefetchMedia();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.mediaItems.length,
          options: CarouselOptions(
            height: widget.height,
            viewportFraction: 1.0, // Set to full width for better swiping
            enlargeCenterPage:
                false, // Disable for better swipe detection and sizing
            enableInfiniteScroll: widget.mediaItems.length > 1,
            autoPlay: widget.autoPlay,
            scrollPhysics:
                const PageScrollPhysics(), // Important for proper page behavior
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              debugPrint(
                  "Carousel page changed to $index of ${widget.mediaItems.length}, reason: $reason");
            },
          ),
          itemBuilder: (context, index, realIndex) {
            debugPrint(
                "Building carousel item $index of ${widget.mediaItems.length}");
            final mediaItem = widget.mediaItems[index];
            return _buildMediaItem(mediaItem, index);
          },
        ),
        if (widget.showIndicator && widget.mediaItems.length > 1)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.mediaItems.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.blue
                        : Colors.grey.shade300,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMediaItem(PostMediaModel mediaItem, int index) {
    // Determine what type of media to build
    if (mediaItem.mediaType == 'video') {
      return _buildVideoItem(mediaItem, index);
    } else if (mediaItem.mediaType == 'gif') {
      return _buildGifItem(mediaItem, index);
    } else {
      return _buildImageItem(mediaItem, index);
    }
  }

  Widget _buildImageItem(PostMediaModel mediaItem, int index) {
    // Validate URL - don't try to load empty URLs
    final String imageUrl = widget.isFullscreen
        ? (mediaItem.url.isNotEmpty
            ? mediaItem.url
            : 'https://via.placeholder.com/400')
        : (mediaItem.thumbnailUrl != null && mediaItem.thumbnailUrl!.isNotEmpty
            ? mediaItem.thumbnailUrl!
            : (mediaItem.url.isNotEmpty
                ? mediaItem.url
                : 'https://via.placeholder.com/400'));

    debugPrint('Loading image: $imageUrl');

    return GestureDetector(
      onTap: () => widget.onMediaTap?.call(mediaItem, index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 10),
          // Remove shadow for smoother swiping
          // boxShadow: widget.isFullscreen
          //     ? null
          //     : [
          //         BoxShadow(
          //           color: Colors.black.withOpacity(0.2),
          //           blurRadius: 5,
          //           offset: const Offset(0, 3),
          //         ),
          //       ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 10),
          child: imageUrl.isEmpty
              ? Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(Icons.image_not_supported,
                        size: 48, color: Colors.grey),
                  ),
                )
              : CachedNetworkImage(
                  cacheKey: _generateCacheKey(imageUrl),
                  memCacheHeight: 1024,
                  memCacheWidth: 1024,
                  imageUrl: imageUrl,
                  fit: BoxFit.contain, // Changed from cover to contain
                  width: double.infinity,
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.error, color: Colors.red),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildGifItem(PostMediaModel mediaItem, int index) {
    return GestureDetector(
      onTap: () => widget.onMediaTap?.call(mediaItem, index),
      child: Stack(
        children: [
          _buildImageItem(mediaItem, index),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'GIF',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoItem(PostMediaModel mediaItem, int index) {
    return GestureDetector(
      onTap: () => widget.onMediaTap?.call(mediaItem, index),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 10),
              color: Colors.black87,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 10),
              child: Center(
                child: Icon(
                  Icons.play_circle_fill,
                  size: 64,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'VIDEO',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _generateCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  void _prefetchMedia() {
    for (final media in widget.mediaItems) {
      if (media.url.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(media.url), context);
      }
      if (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty) {
        precacheImage(CachedNetworkImageProvider(media.thumbnailUrl!), context);
      }
    }
  }
}
