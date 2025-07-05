import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:herdapp/core/utils/get_signed_url.dart';

class CachedMediaImage extends ConsumerStatefulWidget {
  final String mediaUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const CachedMediaImage({
    super.key,
    required this.mediaUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  @override
  ConsumerState<CachedMediaImage> createState() => _CachedMediaImageState();
}

class _CachedMediaImageState extends ConsumerState<CachedMediaImage> {
  // State to hold the determined ImageProvider. It's nullable to represent the loading state.
  ImageProvider? _imageProvider;

  @override
  void initState() {
    super.initState();
    // Start the asynchronous process of finding the right image provider.
    _determineImageProvider();
  }

  @override
  void didUpdateWidget(CachedMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the mediaUrl changes, we need to re-run the logic.
    if (widget.mediaUrl != oldWidget.mediaUrl) {
      // Reset to loading state and fetch new provider
      _imageProvider = null;
      _determineImageProvider();
    }
  }

  Future<void> _determineImageProvider() async {
    // Get the media cache service from Riverpod.
    final service = ref.read(MediaCacheService.mediaCacheServiceProvider);

    // Asynchronously check if the image exists in our custom file cache.
    // We use the original widget's mediaUrl here.
    final file =
        await service.getFileFromCache(widget.mediaUrl, mediaType: 'image');

    // If the widget is no longer in the tree, don't call setState.
    if (!mounted) return;

    if (file != null) {
      // File found in cache, use FileImage.
      setState(() {
        _imageProvider = FileImage(file);
      });
    } else {
      // File not found, use CachedNetworkImageProvider for network fetching.
      final baseUrl = gsu(widget.mediaUrl);
      final cacheKey = service.generateCacheKey(baseUrl);
      setState(() {
        _imageProvider =
            CachedNetworkImageProvider(widget.mediaUrl, cacheKey: cacheKey);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_imageProvider != null) {
      // If we have a provider, build the Image widget.
      return Image(
        image: _imageProvider!,
        fit: widget.fit,
        width: widget.width,
        height: widget.height,
        // A frameBuilder adds a nice fade-in effect when the image loads.
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          return AnimatedOpacity(
            opacity: frame == null ? 0 : 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            child: child,
          );
        },
        errorBuilder: (context, error, stackTrace) {
          // Display a placeholder on error.
          return _buildPlaceholder();
        },
      );
    } else {
      // While _imageProvider is null (loading), show a placeholder.
      return _buildPlaceholder();
    }
  }

  // A helper method for a consistent placeholder.
  Widget _buildPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
    );
  }
}
