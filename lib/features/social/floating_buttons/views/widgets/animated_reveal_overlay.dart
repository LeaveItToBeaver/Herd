import 'package:flutter/material.dart';
import 'package:herdapp/features/social/floating_buttons/utils/chat_reveal_overlay.dart';

class AnimatedRevealOverlay extends StatefulWidget {
  final Widget child;
  final Offset explosionCenter;
  final Color backgroundColor;
  final bool isVisible;
  final bool isReversed;
  final VoidCallback? onAnimationComplete;
  final Duration duration;

  const AnimatedRevealOverlay({
    super.key,
    required this.child,
    required this.explosionCenter,
    required this.backgroundColor,
    required this.isVisible,
    this.isReversed = false,
    this.onAnimationComplete,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<AnimatedRevealOverlay> createState() => _AnimatedRevealOverlayState();
}

class _AnimatedRevealOverlayState extends State<AnimatedRevealOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _revealAnimation;

  @override
  void initState() {
    super.initState();

    debugPrint(
        "🎆 AnimatedRevealOverlay initState: isVisible=${widget.isVisible}, isReversed=${widget.isReversed}");
    debugPrint(
        "🎆 Animation setup: begin=${widget.isReversed ? 1.0 : 0.0}, end=${widget.isReversed ? 0.0 : 1.0}");

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _revealAnimation = Tween<double>(
      begin: widget.isReversed ? 1.0 : 0.0,
      end: widget.isReversed ? 0.0 : 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.isReversed ? Curves.easeInQuart : Curves.easeOutQuart,
    ));

    _controller.addStatusListener((status) {
      debugPrint("🎆 Animation status changed: $status");
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete?.call();
      }
    });

    // Start animation based on visibility and direction
    if (widget.isVisible && !widget.isReversed) {
      debugPrint("🎆 Starting forward animation (opening)");
      _controller.forward();
    } else if (!widget.isVisible && widget.isReversed) {
      debugPrint("🎆 Starting reverse animation (closing)");
      _controller.forward(); // Forward goes from 1.0 to 0.0 for reverse
    }
  }

  @override
  void didUpdateWidget(AnimatedRevealOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle immediate state changes for better responsiveness
    if (widget.isVisible != oldWidget.isVisible ||
        widget.isReversed != oldWidget.isReversed) {
      debugPrint(
          "🎆 Widget updated - isVisible: ${widget.isVisible}, isReversed: ${widget.isReversed}");

      if (widget.isReversed && !widget.isVisible) {
        // Closing animation - start immediately
        debugPrint("🎆 Starting immediate close animation");
        _revealAnimation = Tween<double>(
          begin: _controller.value, // Start from current position
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInQuart,
        ));
        _controller.reset();
        _controller.forward();
      } else if (widget.isVisible && !widget.isReversed) {
        // Opening animation
        debugPrint("🎆 Starting open animation");
        _revealAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuart,
        ));
        _controller.reset();
        _controller.forward();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _revealAnimation,
      builder: (context, child) {
        final shouldShowMask =
            (widget.isReversed && _revealAnimation.value >= 0.0) ||
                (!widget.isReversed && _revealAnimation.value < 1.0);

        return Stack(
          children: [
            // The child content
            widget.child,

            // The reveal mask overlay - show during animation
            // For opening: show when < 1.0, For closing: show when >= 0.0
            if (shouldShowMask)
              Positioned.fill(
                child: CustomPaint(
                  painter: ChatRevealOverlay(
                    animationProgress: _revealAnimation.value,
                    explosionCenter: widget.explosionCenter,
                    bubbleSize: 50.0, // You can make this configurable
                    backgroundColor: widget.backgroundColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
