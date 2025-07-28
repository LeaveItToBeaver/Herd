import 'dart:math' as math;
import 'package:flutter/material.dart';

class ChatWrapTrailPainter extends CustomPainter {
  final Offset originalPosition;
  final Offset currentPosition;
  final Color trailColor;
  final double bubbleSize;
  final Size screenSize;
  final bool isInChatZone;
  final double chatThresholdX;
  final double animationProgress; // 0.0 to 1.0 for morphing animation

  ChatWrapTrailPainter({
    required this.originalPosition,
    required this.currentPosition,
    required this.trailColor,
    required this.bubbleSize,
    required this.screenSize,
    required this.isInChatZone,
    required this.chatThresholdX,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isInChatZone) {
      // Use regular trail if not in chat zone
      _drawRegularTrail(canvas, size);
      return;
    }

    // Draw curved trail that wraps around chat area
    _drawChatWrapTrail(canvas, size);
  }

  void _drawRegularTrail(Canvas canvas, Size size) {
    final distance = (currentPosition - originalPosition).distance;
    if (distance < 10) return;

    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = trailColor.withValues(alpha: 0.6);

    // Simple trail for non-chat zone
    final path = Path();
    final direction = (currentPosition - originalPosition).normalize();
    final perpendicular = Offset(-direction.dy, direction.dx);

    final thickness = bubbleSize * 0.3;

    path.moveTo(
      originalPosition.dx + perpendicular.dx * thickness,
      originalPosition.dy + perpendicular.dy * thickness,
    );
    path.lineTo(
      currentPosition.dx + perpendicular.dx * thickness,
      currentPosition.dy + perpendicular.dy * thickness,
    );
    path.lineTo(
      currentPosition.dx - perpendicular.dx * thickness,
      currentPosition.dy - perpendicular.dy * thickness,
    );
    path.lineTo(
      originalPosition.dx - perpendicular.dx * thickness,
      originalPosition.dy - perpendicular.dy * thickness,
    );
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawChatWrapTrail(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = trailColor.withValues(alpha: 0.4 * animationProgress);

    // Create curved path that wraps around the chat overlay
    final path = Path();

    // Control points for the curve
    final startPoint = originalPosition;
    final endPoint = currentPosition;
    final midY = (startPoint.dy + endPoint.dy) / 2;

    // Create a curved path that goes:
    // 1. From bubble start position
    // 2. Curves outward (away from chat area)
    // 3. Wraps around to the target position

    final wrapRadius = bubbleSize * 1.2;
    final curveIntensity =
        math.min(1.0, (startPoint.dx - endPoint.dx) / (screenSize.width * 0.3));

    // Calculate curve control points
    final controlPoint1 = Offset(
      startPoint.dx + (chatThresholdX - startPoint.dx) * 0.3,
      startPoint.dy,
    );

    final controlPoint2 = Offset(
      chatThresholdX + wrapRadius,
      midY,
    );

    final controlPoint3 = Offset(
      endPoint.dx + wrapRadius * curveIntensity,
      endPoint.dy,
    );

    // Draw the main curve
    path.moveTo(startPoint.dx, startPoint.dy);

    // Cubic bezier curve that wraps around
    path.cubicTo(
      controlPoint1.dx,
      controlPoint1.dy,
      controlPoint2.dx,
      controlPoint2.dy,
      controlPoint3.dx,
      controlPoint3.dy,
    );

    path.lineTo(endPoint.dx, endPoint.dy);

    // Create thickness by drawing offset curves
    final thickness = bubbleSize * 0.2 * animationProgress;

    // Offset the path for thickness
    final offsetPath = _createOffsetPath(path, thickness);
    canvas.drawPath(offsetPath, paint);

    // Add glow effect
    if (animationProgress > 0.5) {
      final glowPaint = Paint()
        ..style = PaintingStyle.stroke
        ..color =
            trailColor.withValues(alpha: 0.3 * (animationProgress - 0.5) * 2)
        ..strokeWidth = thickness * 2
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawPath(path, glowPaint);
    }
  }

  Path _createOffsetPath(Path originalPath, double thickness) {
    // Create a thicker version of the path
    // This is a simplified approach - in a real app you might want to use more sophisticated path offsetting
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness * 2;

    return originalPath;
  }

  @override
  bool shouldRepaint(ChatWrapTrailPainter oldDelegate) {
    return oldDelegate.originalPosition != originalPosition ||
        oldDelegate.currentPosition != currentPosition ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.isInChatZone != isInChatZone;
  }
}

// Extension to normalize Offset
extension OffsetExtension on Offset {
  Offset normalize() {
    final magnitude = distance;
    if (magnitude == 0) return Offset.zero;
    return this / magnitude;
  }
}
