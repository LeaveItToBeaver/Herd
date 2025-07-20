import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_media_model.dart';

class MediaCarouselWidget extends StatefulWidget {
  final List<PostMediaModel> mediaItems;
  final bool autoPlay;
  final double height;
  final bool showIndicator;
  final Function(PostMediaModel, int)? onMediaTap;
  final bool isFullscreen;

  const MediaCarouselWidget({
    super.key,
    required this.mediaItems,
    this.autoPlay = false,
    this.height = 250.0,
    this.showIndicator = true,
    this.onMediaTap,
    this.isFullscreen = false,
  });

  @override
  State<MediaCarouselWidget> createState() => _MediaCarouselWidgetState();
}

class _MediaCarouselWidgetState extends State<MediaCarouselWidget> {
  int _currentIndex = 0;
  final List<CachedNetworkImageProvider> _imageProviders = [];
  bool _isDisposed = false;
  bool _didInitializeImages = false;

  @override
  void initState() {
    super.initState();
    // Don't call precacheImage here - moved to didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only initialize images once to avoid repeated cache operations
    if (!_didInitializeImages) {
      _limitedPrefetchMedia();
      _didInitializeImages = true;
    }
  }

  @override
  void didUpdateWidget(MediaCarouselWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If media items changed, clear and recreate the providers
    if (oldWidget.mediaItems != widget.mediaItems) {
      _clearImageProviders();
      // Reset flag so images will be prefetched again
      _didInitializeImages = false;
      // Trigger prefetch on next frame
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _limitedPrefetchMedia();
          _didInitializeImages = true;
        }
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _clearImageProviders();
    super.dispose();
  }

  void _clearImageProviders() {
    // Clear image providers and ensure they're released
    for (var provider in _imageProviders) {
      // Explicitly evict the image from cache
      provider.evict().then((_) {
        // Additional cleanup
        if (!_isDisposed) {
          PaintingBinding.instance.imageCache.clear();
          PaintingBinding.instance.imageCache.clearLiveImages();
        }
      });
    }
    _imageProviders.clear();
  }

  // Only prefetch visible and immediately adjacent images
  void _limitedPrefetchMedia() {
    if (widget.mediaItems.isEmpty || !mounted) return;

    // Only prefetch current + adjacent images (max 3)
    final startIdx = (_currentIndex - 1).clamp(0, widget.mediaItems.length - 1);
    final endIdx = (_currentIndex + 1).clamp(0, widget.mediaItems.length - 1);

    for (int i = startIdx; i <= endIdx; i++) {
      final media = widget.mediaItems[i];

      // Skip video items
      if (media.mediaType == 'video') continue;

      // Prefetch the main image if it's an image
      if (media.url.isNotEmpty) {
        final provider = CachedNetworkImageProvider(
          media.url,
          cacheKey: _generateCacheKey(media.url),
        );
        _imageProviders.add(provider);
        // Now it's safe to call precacheImage since we're in didChangeDependencies
        precacheImage(provider, context);
      }

      // Also prefetch thumbnail if available and different from main URL
      if (media.thumbnailUrl != null &&
          media.thumbnailUrl!.isNotEmpty &&
          media.thumbnailUrl != media.url) {
        final thumbnailProvider = CachedNetworkImageProvider(
          media.thumbnailUrl!,
          cacheKey: _generateCacheKey(media.thumbnailUrl!),
        );
        _imageProviders.add(thumbnailProvider);
        precacheImage(thumbnailProvider, context);
      }
    }
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
            viewportFraction: 1.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: widget.mediaItems.length > 1,
            autoPlay: widget.autoPlay,
            scrollPhysics: const PageScrollPhysics(),
            onPageChanged: (index, reason) {
              if (_isDisposed) return;

              setState(() {
                _currentIndex = index;
              });

              // Only prefetch when page changes - this is now safe
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  _limitedPrefetchMedia();
                }
              });

              debugPrint(
                  "Carousel page changed to $index of ${widget.mediaItems.length}, reason: $reason");
            },
          ),
          itemBuilder: (context, index, realIndex) {
            // debugPrint(
            //     "Building carousel item $index of ${widget.mediaItems.length}");
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
    // Only build the currently visible item and adjacent ones
    final isNearCurrent = (index - _currentIndex).abs() <= 1;

    // For non-visible items far from current, return a placeholder
    if (!isNearCurrent) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

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
    // If this is a video item without a valid thumbnail,
    // return a placeholder widget.
    if (mediaItem.mediaType == 'video') {
      if (mediaItem.thumbnailUrl == null || mediaItem.thumbnailUrl!.isEmpty) {
        return Container(
          color: Colors.black87,
          child: const Center(
            child: Icon(Icons.error, size: 48, color: Colors.red),
          ),
        );
      }
    }

    // Use the thumbnail if available; otherwise, fall back to the URL.
    final String imageUrl = widget.isFullscreen
        ? (mediaItem.url.isNotEmpty
            ? mediaItem.url
            : 'https://via.placeholder.com/400')
        : (mediaItem.thumbnailUrl != null && mediaItem.thumbnailUrl!.isNotEmpty
            ? mediaItem.thumbnailUrl!
            : (mediaItem.url.isNotEmpty
                ? mediaItem.url
                : 'https://via.placeholder.com/400'));

    return GestureDetector(
      onTap: () => widget.onMediaTap?.call(mediaItem, index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.isFullscreen ? 0 : 10),
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
                  memCacheHeight: 1024, // Limit memory cache size
                  memCacheWidth: 1024, // Limit memory cache size
                  maxWidthDiskCache: 1200, // Limit disk cache size
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  fadeInDuration: const Duration(milliseconds: 300),
                  placeholder: (context, url) => Container(
                    color: Colors.grey[200],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[200],
                    child: const Center(
                        child: Icon(Icons.error, color: Colors.red)),
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
                color: Colors.black.withValues(alpha: 0.6),
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
    // Only initialize videos when they are visible to avoid memory leaks
    if (index != _currentIndex) {
      // Show thumbnail instead when video is not in focus
      return GestureDetector(
        onTap: () => widget.onMediaTap?.call(mediaItem, index),
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildImageItem(mediaItem, index),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 40,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: PostVideoPlayer(
        key: ValueKey('video-${mediaItem.id}-$index'),
        url: mediaItem.url,
        autoPlay: false, // Don't auto-play to reduce resource usage
        looping: false, // Don't loop to ensure video stops
        showControls: true,
        allowFullScreen: true,
        muted: true,
      ),
    );
  }

  String _generateCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }
}
