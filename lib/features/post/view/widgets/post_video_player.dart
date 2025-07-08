import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/utils/router.dart';

enum VideoLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class PostVideoPlayer extends StatefulWidget {
  final String url;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final double aspectRatio;
  final BoxFit fit;
  final bool allowFullScreen;
  final bool showOptions;
  final Color controlsColor;
  final bool muted;
  final bool allowPlaybackSpeedControl;
  final void Function(double aspectRatio)? onAspectRatio;

  const PostVideoPlayer({
    super.key,
    required this.url,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
    this.onAspectRatio,
    this.fit = BoxFit.contain,
    this.allowFullScreen = true,
    this.showOptions = true,
    this.controlsColor = Colors.white,
    this.muted = true,
    this.allowPlaybackSpeedControl = true,
  });

  @override
  State<PostVideoPlayer> createState() => _PostVideoPlayerState();
}

class _PostVideoPlayerState extends State<PostVideoPlayer> with RouteAware {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  VideoLoadingState _loadingState = VideoLoadingState.initial;
  String? _errorMessage;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didUpdateWidget(PostVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _disposeControllers();
      _initializePlayer();
    }
  }

  @override
  void didPushNext() {
    // When we navigate away, pause the video to save resources
    _videoPlayerController?.pause();
    super.didPushNext();
  }

  @override
  void didPopNext() {
    // When we come back, only play if autoPlay was set
    if (_videoPlayerController != null && widget.autoPlay && !_isDisposed) {
      _videoPlayerController!.play();
    }
    super.didPopNext();
  }

  Future<void> _initializePlayer() async {
    if (_isDisposed) return;

    try {
      setState(() {
        _loadingState = VideoLoadingState.loading;
        _errorMessage = null;
      });

      // Make sure we dispose any existing controllers before creating new ones
      _disposeControllers();

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.url));

      await _videoPlayerController!.initialize();
      if (_isDisposed) return;

      // Get the real aspect ratio
      final realRatio = _videoPlayerController!.value.aspectRatio;
      widget.onAspectRatio?.call(realRatio);

      // Set the video volume as per the device's current volume
      final muted = widget.muted;
      await _videoPlayerController?.setVolume(muted ? 0 : 1);
      if (_isDisposed) return;

      // Calculate the actual aspect ratio from the video
      final videoAspectRatio = _videoPlayerController?.value.aspectRatio;

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: videoAspectRatio!.isFinite && videoAspectRatio > 0
            ? videoAspectRatio
            : widget.aspectRatio,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        showControls: widget.showControls,
        allowFullScreen: widget.allowFullScreen,
        showOptions: widget.showOptions,
        allowPlaybackSpeedChanging: widget.allowPlaybackSpeedControl,
        materialProgressColors: ChewieProgressColors(
          playedColor: widget.controlsColor,
          handleColor: widget.controlsColor,
          backgroundColor: Colors.grey.shade700,
          bufferedColor: widget.controlsColor.withValues(alpha: 0.5),
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red.shade400, size: 42),
                const SizedBox(height: 12),
                Text(
                  'Error loading video',
                  style: const TextStyle(color: Colors.white),
                ),
                ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );

      if (!_isDisposed) {
        setState(() {
          _loadingState = VideoLoadingState.loaded;
        });
      }
    } catch (e) {
      debugPrint("Video initialization error: $e");
      if (!_isDisposed) {
        setState(() {
          _loadingState = VideoLoadingState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    routeObserver.unsubscribe(this);
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    // Clean up resources in correct order
    if (_chewieController != null) {
      _chewieController!.dispose();
      _chewieController = null;
    }

    if (_videoPlayerController != null) {
      _videoPlayerController!.dispose();
      _videoPlayerController = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadingState) {
      case VideoLoadingState.initial:
      case VideoLoadingState.loading:
        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          ),
        );

      case VideoLoadingState.error:
        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      color: Colors.red.shade400, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load video',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _initializePlayer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );

      case VideoLoadingState.loaded:
        if (_chewieController != null) {
          return AspectRatio(
            aspectRatio: _chewieController!.aspectRatio ?? widget.aspectRatio,
            child: Chewie(controller: _chewieController!),
          );
        }
    }

    // Fallback
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: Container(
        color: Colors.black,
        child: const Center(
          child: Text(
            'Video player unavailable',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
