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

    // Start animation if visible
    if (widget.isVisible) {
      debugPrint("🎆 Starting forward animation");
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(AnimatedRevealOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        // Update animation for opening
        _revealAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOutQuart,
        ));
        _controller.forward();
      } else {
        // Update animation for closing (reverse)
        _revealAnimation = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(CurvedAnimation(
          parent: _controller,
          curve: Curves.easeInQuart,
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
        return Stack(
          children: [
            // The child content
            widget.child,

            // The reveal mask overlay
            if (_revealAnimation.value < 1.0)
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
