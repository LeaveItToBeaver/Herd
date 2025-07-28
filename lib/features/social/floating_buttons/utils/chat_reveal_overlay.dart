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
    if (animationProgress <= 0.0) {
      // Cover everything before animation starts
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = backgroundColor;
      canvas.drawRect(Offset.zero & size, paint);
      return;
    }

    // Create a path that covers the entire canvas
    final fullPath = Path()..addRect(Offset.zero & size);

    // Create expanding circles that will be cut out to reveal the content
    final revealPath = Path();

    // Multiple expanding circles for smooth reveal effect
    final circleCount = 3;
    for (int i = 0; i < circleCount; i++) {
      final staggerDelay = i * 0.2;
      final adjustedProgress =
          ((animationProgress - staggerDelay) / (1.0 - staggerDelay))
              .clamp(0.0, 1.0);

      if (adjustedProgress <= 0) continue;

      // Calculate radius that will eventually cover the entire screen
      final maxRadius =
          math.sqrt(math.pow(size.width, 2) + math.pow(size.height, 2)) + 100;
      final currentRadius = maxRadius * _easeOutQuart(adjustedProgress);

      // Add circle to reveal path
      revealPath.addOval(Rect.fromCircle(
        center: explosionCenter,
        radius: currentRadius,
      ));
    }

    // Subtract the reveal circles from the full canvas to create holes
    final maskPath =
        Path.combine(PathOperation.difference, fullPath, revealPath);

    // Draw the mask that covers everything except the revealed areas
    final paint = Paint()..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, paint);

    print("🎨 Drew mask path with ${revealPath.getBounds()} reveal bounds");

    // Add subtle glow around the reveal edges
    if (animationProgress > 0.3) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawPath(revealPath, glowPaint);
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
