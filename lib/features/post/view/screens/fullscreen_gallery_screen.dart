// lib/features/post/view/screens/fullscreen_gallery_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:share_plus/share_plus.dart';

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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Hide status bar
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Show status bar again
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
    );
    super.dispose();
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
      body: Stack(
        children: [
          // Make sure we're not capturing too many gestures
          PageView.builder(
            controller: _pageController,
            physics:
                const ClampingScrollPhysics(), // Try a different scroll physics
            itemCount: widget.mediaItems.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final mediaItem = widget.mediaItems[index];
              return GestureDetector(
                onTap: _toggleControls,
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity! > 300) {
                    Navigator.of(context).pop();
                  }
                },
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 3.0,
                  child: Center(
                    child: mediaItem.mediaType == 'video'
                        ? _buildVideoViewer(mediaItem)
                        : _buildImageViewer(mediaItem),
                  ),
                ),
              );
            },
          ),

          // Controls overlay
          AnimatedOpacity(
            opacity: _showControls ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    // Top controls
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Row(
                            children: [
                              if (widget.mediaItems.length > 1)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${_currentIndex + 1}/${widget.mediaItems.length}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: Icon(
                                  _isSharing
                                      ? Icons.share_outlined
                                      : Icons.share,
                                  color: Colors.white,
                                ),
                                onPressed: _isSharing
                                    ? null
                                    : () => _shareMedia(
                                        widget.mediaItems[_currentIndex]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Bottom indicator and navigation buttons
                    if (widget.mediaItems.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: Column(
                          children: [
                            // Add navigation buttons for more obvious swiping
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (_currentIndex > 0)
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_ios,
                                        color: Colors.white),
                                    onPressed: () {
                                      _pageController.previousPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                                const SizedBox(width: 20),
                                if (_currentIndex <
                                    widget.mediaItems.length - 1)
                                  IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios,
                                        color: Colors.white),
                                    onPressed: () {
                                      _pageController.nextPage(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeInOut,
                                      );
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Dots indicator
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                widget.mediaItems.length,
                                (index) => Container(
                                  width: 8,
                                  height: 8,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _currentIndex == index
                                        ? Colors.white
                                        : Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  Widget _buildVideoViewer(PostMediaModel mediaItem) {
    // In a real implementation, you'd use VideoPlayer here
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          color: Colors.black,
          child: const Center(
            child: Text(
              'Video Player Would Go Here',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Icon(
          Icons.play_circle_filled,
          size: 80,
          color: Colors.white.withOpacity(0.8),
        ),
      ],
    );
  }
}
