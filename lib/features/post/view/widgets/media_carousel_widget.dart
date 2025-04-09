import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
            viewportFraction: widget.isFullscreen
                ? 1.0
                : 0.95, // Slightly larger to improve swipe detection
            enlargeCenterPage: !widget.isFullscreen,
            enableInfiniteScroll: widget.mediaItems.length > 1,
            autoPlay: widget.autoPlay,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              // Add debug print to verify when page changes
              debugPrint("Carousel changed to page $index, reason: $reason");
            },
          ),
          itemBuilder: (context, index, realIndex) {
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
                        ? Theme.of(context).primaryColor
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
          boxShadow: widget.isFullscreen
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
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
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
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
}
