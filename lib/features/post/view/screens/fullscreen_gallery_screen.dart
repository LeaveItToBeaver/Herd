// lib/features/post/view/screens/fullscreen_gallery_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class FullscreenGalleryScreen extends ConsumerStatefulWidget {
  final List<PostMediaModel> mediaItems;
  final int initialIndex;
  final String postId;

  const FullscreenGalleryScreen({
    Key? key,
    required this.mediaItems,
    required this.initialIndex,
    required this.postId,
  }) : super(key: key);

  @override
  ConsumerState<FullscreenGalleryScreen> createState() =>
      _FullscreenGalleryScreenState();
}

class _FullscreenGalleryScreenState
    extends ConsumerState<FullscreenGalleryScreen> {
  late PageController _pageController;
  bool _isSharing = false;
  bool _showControls = true;
  int _currentIndex = 0;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _videoReady = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize video controller if the first item is a video
    if (widget.mediaItems[_currentIndex].mediaType == 'video') {
      _initFullscreenVideo(widget.mediaItems[_currentIndex].url);
    }
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initFullscreenVideo(String url) async {
    // if already initialized for this URL, skip
    if (_chewieController?.videoPlayerController.dataSource == url) return;

    _chewieController?.dispose();
    _videoController?.dispose();
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true, // autoplay in fullscreen
      looping: false,
      showControls: true, // still show play/pause
      allowFullScreen: false, // already fullscreen
      aspectRatio: _videoController!.value.aspectRatio,
    );
    setState(() => _videoReady = true);
    if (mounted) setState(() => _videoReady = true);
  }

  Future<void> _shareMedia(PostMediaModel media) async {
    if (_isSharing) return;

    setState(() {
      _isSharing = true;
    });

    try {
      await Share.share(
        'Check out this ${media.mediaType} from Herd: ${media.url}',
        subject: 'Sharing from Herd',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed to share media: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // AppBar provides the back button and system UI restoration
      appBar: _showControls
          ? AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.pop(),
              ),
              actions: [
                if (widget.mediaItems.length > 1)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        '${_currentIndex + 1}/${widget.mediaItems.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                IconButton(
                  icon: Icon(
                    _isSharing ? Icons.share_outlined : Icons.share,
                    color: Colors.white,
                  ),
                  onPressed: _isSharing
                      ? null
                      : () => _shareMedia(widget.mediaItems[_currentIndex]),
                ),
                const SizedBox(width: 8),
              ],
            )
          : PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: AppBar(
                backgroundColor: Colors.black,
                elevation: 0,
                toolbarHeight: 0,
              ),
            ),
      body: GestureDetector(
        onTap: _toggleControls,
        // Handle vertical swipe to dismiss
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity != null &&
              details.primaryVelocity! > 300) {
            context.pop();
          }
        },
        child: Stack(
          children: [
            // Main PageView for swiping through images
            PageView.builder(
              controller: _pageController,
              // Use clamping physics for better swipe feel
              physics: const ClampingScrollPhysics(),
              itemCount: widget.mediaItems.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _videoReady = false;
                });

                final item = widget.mediaItems[index];
                if (item.mediaType == 'video') {
                  _initFullscreenVideo(item.url);
                } else {
                  _chewieController?.dispose();
                  _videoController?.dispose();
                }
              },
              itemBuilder: (context, index) {
                final mediaItem = widget.mediaItems[index];
                return InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: mediaItem.mediaType == 'video'
                        ? (_videoReady && _chewieController != null
                            ? Chewie(controller: _chewieController!)
                            : const Center(
                                child: CircularProgressIndicator(),
                              ))
                        : _buildImageViewer(mediaItem),
                  ),
                );
              },
            ),

            // Bottom navigation controls - only shown when _showControls is true
            if (_showControls && widget.mediaItems.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_currentIndex > 0)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios,
                            color: Colors.white),
                        onPressed: () {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                    const SizedBox(width: 20),
                    if (_currentIndex < widget.mediaItems.length - 1)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white),
                        onPressed: () {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                  ],
                ),
              ),

            // Page indicators
            if (_showControls && widget.mediaItems.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 20,
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
                            ? Colors.white
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageViewer(PostMediaModel mediaItem) {
    // Validate URL before trying to load it
    if (mediaItem.url.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.image_not_supported, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text(
              "Image not available",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: mediaItem.url,
      fit: BoxFit.contain,
      placeholder: (context, url) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
      errorWidget: (context, url, error) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              'Error loading image: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
