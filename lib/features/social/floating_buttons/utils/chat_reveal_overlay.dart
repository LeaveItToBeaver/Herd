import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatRevealOverlay extends CustomPainter {
  final double animationProgress; // 0.0 to 1.0
  final Offset explosionCenter; // Center point of the explosion
  final double bubbleSize;
  final Color backgroundColor;

  ChatRevealOverlay({
    required this.animationProgress,
    required this.explosionCenter,
    required this.bubbleSize,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Save the canvas state
    canvas.save();

    if (animationProgress <= 0.0) {
      // Cover everything before animation starts
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor;
      canvas.drawRect(Offset.zero & size, paint);
      canvas.restore();
      return;
    }

    if (animationProgress >= 1.0) {
      // Animation complete - don't draw anything (fully revealed)
      canvas.restore();
      return;
    }

    // Calculate the maximum radius needed to cover the entire screen from any point
    final maxRadius = math.sqrt(math.pow(
                math.max(explosionCenter.dx, size.width - explosionCenter.dx),
                2) +
            math.pow(
                math.max(explosionCenter.dy, size.height - explosionCenter.dy),
                2)) +
        50;

    // Create the reveal clip path
    final revealPath = Path();

    // Main reveal circle with easing
    final easedProgress = _easeOutCubic(animationProgress);
    final currentRadius = maxRadius * easedProgress;

    revealPath.addOval(Rect.fromCircle(
      center: explosionCenter,
      radius: currentRadius,
    ));

    // Add secondary ripple circles for more dramatic effect
    if (animationProgress > 0.2) {
      final secondaryProgress =
          ((animationProgress - 0.2) / 0.8).clamp(0.0, 1.0);
      final secondaryRadius =
          maxRadius * _easeOutQuart(secondaryProgress) * 0.7;

      revealPath.addOval(Rect.fromCircle(
        center: explosionCenter,
        radius: secondaryRadius,
      ));
    }

    // Clip the canvas to the reveal area
    canvas.clipPath(revealPath);

    // Draw background that will be clipped
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor.withValues(alpha: 1.0 - easedProgress);

    canvas.drawRect(Offset.zero & size, paint);

    // Add ripple rings effect
    _drawRippleRings(canvas, size, easedProgress);

    canvas.restore();

    debugPrint(
        "🎨 Drew reveal effect: progress=$animationProgress, radius=$currentRadius");
  }

  void _drawRippleRings(Canvas canvas, Size size, double progress) {
    if (progress < 0.1) return;

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    // Draw multiple expanding rings
    for (int i = 0; i < 3; i++) {
      final ringDelay = i * 0.15;
      final ringProgress =
          ((progress - ringDelay) / (1.0 - ringDelay)).clamp(0.0, 1.0);

      if (ringProgress <= 0) continue;

      final maxRadius = math.sqrt(math.pow(
              math.max(explosionCenter.dx, size.width - explosionCenter.dx),
              2) +
          math.pow(
              math.max(explosionCenter.dy, size.height - explosionCenter.dy),
              2));

      final ringRadius =
          maxRadius * _easeOutQuart(ringProgress) * (0.8 + i * 0.1);
      final alpha = (1.0 - ringProgress) * 0.3;

      ringPaint.color = backgroundColor.withValues(alpha: alpha);

      canvas.drawCircle(explosionCenter, ringRadius, ringPaint);
    }
  }

  double _easeOutQuart(double t) {
    return 1 - math.pow(1 - t, 4).toDouble();
  }

  double _easeOutCubic(double t) {
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  @override
  bool shouldRepaint(ChatRevealOverlay oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.explosionCenter != explosionCenter ||
        oldDelegate.bubbleSize != bubbleSize ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
