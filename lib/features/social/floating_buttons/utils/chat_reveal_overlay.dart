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

    // Main reveal circle - use LIMITED range (0 → 0.6) so reveal completes earlier
    // This makes the overlay fully visible by 60% of animation instead of 100%
    final effectiveProgress = (animationProgress * 0.85).clamp(0.0, 0.85);
    final currentRadius = maxRadius * effectiveProgress;

    // Create the inverse clip path (everything EXCEPT the reveal area)
    final maskPath = Path();
    maskPath.addRect(Offset.zero & size); // Full screen rect

    final revealPath = Path();
    revealPath.addOval(Rect.fromCircle(
      center: explosionCenter,
      radius: currentRadius,
    ));

    // Add secondary ripple circles for more dramatic effect
    if (animationProgress > 0.2) {
      final secondaryProgress =
          ((animationProgress - 0.2) / 0.8).clamp(0.0, 1.0);
      // Use the same limited range for consistency
      final secondaryEffectiveProgress =
          (secondaryProgress * 0.6).clamp(0.0, 0.6);
      final secondaryRadius = maxRadius * secondaryEffectiveProgress * 0.7;

      revealPath.addOval(Rect.fromCircle(
        center: explosionCenter,
        radius: secondaryRadius,
      ));
    }

    // Subtract the reveal area from the full screen (inverse masking)
    final maskWithHole =
        Path.combine(PathOperation.difference, maskPath, revealPath);

    // Clip to the mask (everything except the revealed area)
    canvas.clipPath(maskWithHole);

    // Draw background that covers everything except the revealed area
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = backgroundColor;

    canvas.drawRect(Offset.zero & size, paint);

    canvas.restore();

    // Draw ripple rings on top without clipping
    canvas.save();
    _drawRippleRings(canvas, size, animationProgress); // Use direct progress
    canvas.restore();

    debugPrint(
        "Drew reveal effect: progress=$animationProgress, effectiveProgress=$effectiveProgress, radius=$currentRadius, maxRadius=$maxRadius");
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

  @override
  bool shouldRepaint(ChatRevealOverlay oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.explosionCenter != explosionCenter ||
        oldDelegate.bubbleSize != bubbleSize ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}
