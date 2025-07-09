// lib/core/widgets/cached_video_player.dart
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:video_player/video_player.dart';

import '../../features/post/data/models/post_media_model.dart';

/// A video player widget with caching capabilities
/// This player will:
/// 1. Check if the video is cached locally before downloading
/// 2. Cache downloaded videos for future use
/// 3. Provide consistent error/loading states
class CachedVideoPlayer extends ConsumerStatefulWidget {
  final String videoUrl;
  final String? thumbnailUrl;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final double aspectRatio;
  final BoxFit fit;
  final bool allowFullScreen;
  final bool showOptions;
  final Color controlsColor;
  final bool allowPlaybackSpeedControl;
  final Widget? placeholder;
  final Widget Function(BuildContext, String)? errorWidget;
  final VoidCallback? onVideoFinished;

  const CachedVideoPlayer({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.aspectRatio = 16 / 9,
    this.fit = BoxFit.contain,
    this.allowFullScreen = true,
    this.showOptions = true,
    this.controlsColor = Colors.white,
    this.allowPlaybackSpeedControl = true,
    this.placeholder,
    this.errorWidget,
    this.onVideoFinished,
  });

  @override
  ConsumerState<CachedVideoPlayer> createState() => _CachedVideoPlayerState();
}

enum VideoLoadingState {
  initial,
  loading,
  loaded,
  error,
}

class _CachedVideoPlayerState extends ConsumerState<CachedVideoPlayer> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  VideoLoadingState _loadingState = VideoLoadingState.initial;
  String? _errorMessage;
  String? _localVideoPath;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didUpdateWidget(CachedVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeControllers();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    if (widget.videoUrl.isEmpty) {
      setState(() {
        _loadingState = VideoLoadingState.error;
        _errorMessage = 'Video URL is empty';
      });
      return;
    }

    try {
      setState(() {
        _loadingState = VideoLoadingState.loading;
        _errorMessage = null;
      });

      // Check if video is already cached
      final cacheService =
          ref.read(MediaCacheService.mediaCacheServiceProvider);
      await cacheService.initialize();

      _localVideoPath = await cacheService.getCachedMediaPath(
        widget.videoUrl,
        mediaType: 'video',
      );

      // If not cached, download and cache it
      _localVideoPath ??= await cacheService.cacheMediaFromUrl(
        widget.videoUrl,
        mediaType: 'video',
      );

      // If we have a local path, use File source, otherwise use network source
      if (_localVideoPath != null) {
        _videoPlayerController = VideoPlayerController.file(
          File(_localVideoPath!),
        );
      } else {
        // Fallback to network source if caching fails
        _videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoUrl),
        );
      }

      // Initialize the controller
      await _videoPlayerController!.initialize();

      // Add listener for video completion
      _videoPlayerController!.addListener(_videoPlayerListener);

      // Set up Chewie controller
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        aspectRatio: _videoPlayerController!.value.aspectRatio.isFinite &&
                _videoPlayerController!.value.aspectRatio > 0
            ? _videoPlayerController!.value.aspectRatio
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
        placeholder: widget.placeholder ??
            Container(
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        errorBuilder: (context, errorMessage) {
          return widget.errorWidget?.call(context, errorMessage) ??
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error, color: Colors.red.shade400, size: 42),
                    const SizedBox(height: 12),
                    const Text(
                      'Error loading video',
                      style: TextStyle(color: Colors.white),
                    ),
                    if (errorMessage.isNotEmpty) ...[
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

      if (mounted) {
        setState(() {
          _loadingState = VideoLoadingState.loaded;
          _isInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingState = VideoLoadingState.error;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _videoPlayerListener() {
    // Check if video playback has finished
    if (_videoPlayerController != null &&
        _videoPlayerController!.value.position >=
            _videoPlayerController!.value.duration &&
        !_videoPlayerController!.value.isLooping &&
        widget.onVideoFinished != null) {
      widget.onVideoFinished!();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    if (_videoPlayerController != null) {
      _videoPlayerController!.removeListener(_videoPlayerListener);
    }
    _chewieController?.dispose();
    _videoPlayerController?.dispose();
    _isInitialized = false;
  }

  @override
  Widget build(BuildContext context) {
    switch (_loadingState) {
      case VideoLoadingState.initial:
      case VideoLoadingState.loading:
        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: widget.placeholder ??
              Container(
                color: Colors.black,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Colors.white),
                      const SizedBox(height: 16),
                      if (widget.thumbnailUrl != null &&
                          widget.thumbnailUrl!.isNotEmpty)
                        Opacity(
                          opacity: 0.7,
                          child: Image.network(
                            widget.thumbnailUrl!,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const SizedBox.shrink();
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
        );

      case VideoLoadingState.error:
        return AspectRatio(
          aspectRatio: widget.aspectRatio,
          child: widget.errorWidget
                  ?.call(context, _errorMessage ?? 'Error loading video') ??
              Container(
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
        if (_chewieController != null && _isInitialized) {
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

// Create a provider for easy access - fixed without disposeDelay parameter
final cachedVideoPlayerControllerProvider =
    Provider.family<VideoPlayerController?, String>(
  (ref, videoUrl) {
    if (videoUrl.isEmpty) return null;

    // This provider doesn't handle caching internally
    // It's meant to be used in conjunction with CachedVideoPlayer
    return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  },
);

// Extension function to easily get a CachedVideoPlayer from a PostMediaModel
extension PostMediaModelVideoExtension on PostMediaModel {
  Widget toCachedVideo({
    bool autoPlay = false,
    bool looping = false,
    bool showControls = true,
    double aspectRatio = 16 / 9,
    BoxFit fit = BoxFit.contain,
    bool allowFullScreen = true,
  }) {
    if (mediaType != 'video') {
      return const SizedBox.shrink();
    }

    return CachedVideoPlayer(
      videoUrl: url,
      thumbnailUrl: thumbnailUrl,
      autoPlay: autoPlay,
      looping: looping,
      showControls: showControls,
      aspectRatio: aspectRatio,
      fit: fit,
      allowFullScreen: allowFullScreen,
    );
  }
}
