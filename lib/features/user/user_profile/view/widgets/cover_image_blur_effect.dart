// Create a dedicated widget for the blur effect
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:herdapp/features/user/user_profile/view/widgets/user_cover_image.dart';

class CoverImageBlurEffect extends StatefulWidget {
  final String? coverImageUrl;
  final Color dominantColor;
  final ScrollController scrollController;

  const CoverImageBlurEffect({
    super.key,
    required this.coverImageUrl,
    required this.dominantColor,
    required this.scrollController,
  });

  @override
  State<CoverImageBlurEffect> createState() => _CoverImageBlurEffectState();
}

class _CoverImageBlurEffectState extends State<CoverImageBlurEffect> {
  final _localScrollController = ScrollController();
  double _scrollProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _localScrollController.addListener(_syncScrollPosition);

    // Set up synchronization between controllers
    widget.scrollController.addListener(_syncScrollPosition);
  }

  @override
  void dispose() {
    _localScrollController.removeListener(_syncScrollPosition);
    widget.scrollController.removeListener(_syncScrollPosition);
    _localScrollController.dispose();
    super.dispose();
  }

  void _syncScrollPosition() {
    // We're only tracking this for blur effects, so just update the progress
    final scrollExtent = widget.scrollController.position.maxScrollExtent;
    final scrollPosition = widget.scrollController.position.pixels;
    final newProgress = (scrollPosition / (scrollExtent * 0.2)).clamp(0.0, 1.0);

    if (newProgress != _scrollProgress) {
      setState(() {
        _scrollProgress = newProgress;
      });
    }
  }

  double get _discreteBlurLevel {
    if (_scrollProgress < 0.2) return 0;
    if (_scrollProgress < 0.5) return 0.5;
    if (_scrollProgress < 0.8) return 1.0;
    return 1.5;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cover image
        UserCoverImage(
          isSelected: false,
          coverImageUrl: widget.coverImageUrl,
        ),

        Positioned.fill(
          child: RepaintBoundary(
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: _discreteBlurLevel,
                  sigmaY: _discreteBlurLevel,
                ),
                child: Container(
                  color: widget.dominantColor
                      .withValues(alpha: 0.2 * _scrollProgress),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
