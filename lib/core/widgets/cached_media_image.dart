import 'dart:io';
import 'dart:typed_data'; // Proper import for Uint8List

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/media_cache_service.dart';

import '../../features/post/data/models/post_media_model.dart';

/// A widget that displays an image from a URL with integrated caching.
/// This improves upon CachedNetworkImage by:
/// 1. Using our custom MediaCacheService for persistent disk caching
/// 2. Optimizing for our PostMediaModel format
/// 3. Handling errors consistently
class CachedMediaImage extends ConsumerStatefulWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final Widget Function(BuildContext, String)? errorWidget;
  final Widget? placeholder;
  final String mediaType;
  final bool enableFadeInTransition;
  final Duration fadeInDuration;
  final bool allowLongPressActions;

  const CachedMediaImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.backgroundColor,
    this.borderRadius,
    this.errorWidget,
    this.placeholder,
    this.mediaType = 'image',
    this.enableFadeInTransition = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.allowLongPressActions = true,
  });

  @override
  ConsumerState<CachedMediaImage> createState() => _CachedMediaImageState();
}

class _CachedMediaImageState extends ConsumerState<CachedMediaImage> {
  String? _localImagePath;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didUpdateWidget(CachedMediaImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.thumbnailUrl != widget.thumbnailUrl) {
      _loadImage();
    }
  }

  Future<void> _loadImage() async {
    if (widget.imageUrl.isEmpty) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Image URL is empty';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _localImagePath = null;
    });

    try {
      final cacheService =
          ref.read(MediaCacheService.mediaCacheServiceProvider);

      // Try getting from cache first
      String? cachedPath = await cacheService.getCachedMediaPath(
        widget.imageUrl,
        mediaType: widget.mediaType,
      );

      if (cachedPath != null) {
        // Check if the file actually exists
        final file = File(cachedPath);
        if (!await file.exists()) {
          debugPrint('⚠️ Cached file doesn\'t exist: $cachedPath');
          cachedPath = null;
        }
      }

      // If not cached, try caching it
      if (cachedPath == null) {
        try {
          cachedPath = await cacheService.cacheMediaFromUrl(
            widget.imageUrl,
            mediaType: widget.mediaType,
          );
        } catch (e) {
          debugPrint('⚠️ Error caching from URL: $e');
        }
      }

      // If we have a thumbnail URL and no high-res image yet, use thumbnail as fallback
      if (cachedPath == null &&
          widget.thumbnailUrl != null &&
          widget.thumbnailUrl!.isNotEmpty) {
        cachedPath = await cacheService.getCachedMediaPath(
          widget.thumbnailUrl!,
          mediaType: 'thumbnail',
        );

        cachedPath ??= await cacheService.cacheMediaFromUrl(
          widget.thumbnailUrl!,
          mediaType: 'thumbnail',
        );
      }

      if (mounted) {
        setState(() {
          _localImagePath = cachedPath;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _showImageOptions() {
    if (!widget.allowLongPressActions) return;

    // Show options dialog (share, save, etc.)
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('Share Image'),
            onTap: () {
              Navigator.pop(context);
              // Implement sharing logic
            },
          ),
          ListTile(
            leading: const Icon(Icons.save_alt),
            title: const Text('Save to Device'),
            onTap: () {
              Navigator.pop(context);
              // Implement save logic
            },
          ),
          if (_localImagePath != null)
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Image Info'),
              onTap: () {
                Navigator.pop(context);
                _showImageInfo();
              },
            ),
        ],
      ),
    );
  }

  void _showImageInfo() {
    if (_localImagePath == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Image Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cached path: $_localImagePath'),
            const SizedBox(height: 8),
            Text('Original URL: ${widget.imageUrl}'),
            if (widget.thumbnailUrl != null) ...[
              const SizedBox(height: 8),
              Text('Thumbnail URL: ${widget.thumbnailUrl}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      // Show placeholder during loading
      content = widget.placeholder ??
          Container(
            color: widget.backgroundColor ?? Colors.grey.shade200,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          );
    } else if (_hasError || _localImagePath == null) {
      // Show error widget
      content = widget.errorWidget
              ?.call(context, _errorMessage ?? 'Failed to load image') ??
          Container(
            color: widget.backgroundColor ?? Colors.grey.shade200,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          );

      // Try fallback to standard CachedNetworkImage if local cache failed
      if (_localImagePath == null && widget.imageUrl.isNotEmpty) {
        content = CachedNetworkImage(
          imageUrl: widget.imageUrl,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          placeholder: (context, url) =>
              widget.placeholder ??
              Container(
                color: widget.backgroundColor ?? Colors.grey.shade200,
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),
          errorWidget: (context, url, error) =>
              widget.errorWidget?.call(context, error.toString()) ??
              Container(
                color: widget.backgroundColor ?? Colors.grey.shade200,
                child: Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
        );
      }
    } else {
      // Show the cached image from local file
      final imageFile = File(_localImagePath!);

      // Use a FadeIn transition for smoother loading experience
      content = widget.enableFadeInTransition
          ? FadeInImage(
              placeholder: MemoryImage(Uint8List(0)), // Empty placeholder
              image: FileImage(imageFile),
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              fadeInDuration: widget.fadeInDuration,
              fadeInCurve: Curves.easeInOut,
              imageErrorBuilder: (context, error, stackTrace) {
                return widget.errorWidget?.call(context, error.toString()) ??
                    Container(
                      color: widget.backgroundColor ?? Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
              },
            )
          : Image.file(
              imageFile,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              errorBuilder: (context, error, stackTrace) {
                return widget.errorWidget?.call(context, error.toString()) ??
                    Container(
                      color: widget.backgroundColor ?? Colors.grey.shade200,
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    );
              },
            );
    }

    // Apply border radius if specified
    if (widget.borderRadius != null) {
      content = ClipRRect(
        borderRadius: widget.borderRadius!,
        child: content,
      );
    }

    // Wrap with GestureDetector for long press options
    return GestureDetector(
      onLongPress: widget.allowLongPressActions ? _showImageOptions : null,
      child: content,
    );
  }
}

// Extension function to easily get a CachedMediaImage from a PostMediaModel
extension PostMediaModelImageExtension on PostMediaModel {
  Widget toCachedImage({
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Color? backgroundColor,
  }) {
    return CachedMediaImage(
      imageUrl: url,
      thumbnailUrl: thumbnailUrl,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      backgroundColor: backgroundColor,
      mediaType: mediaType,
    );
  }
}
