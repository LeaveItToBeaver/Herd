import 'dart:math' as math;

import 'package:flutter/material.dart';

class SuperStretchyTrailPainter extends CustomPainter {
  final Offset originalPosition;
  final Offset currentPosition;
  final Color trailColor;
  final double bubbleSize;
  final Size screenSize;

  SuperStretchyTrailPainter({
    required this.originalPosition,
    required this.currentPosition,
    required this.trailColor,
    required this.bubbleSize,
    required this.screenSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final distance = (currentPosition - originalPosition).distance;
    if (distance < 10) return;

    final paint = Paint()..style = PaintingStyle.fill;

    // Create tension effect - wide at ends, thin in middle
    final maxThickness = bubbleSize * 0.8; // Maximum thickness at drag point

    // Dynamic minimum thickness based on drag distance - starts thick, gets thinner as you drag
    final normalizedDistance =
        math.min(1.0, distance / (screenSize.width * 0.6));
    final minThickness = maxThickness *
        (0.8 - normalizedDistance * 0.75); // 80% down to 5% of max

    final tensionFactor = math.min(
        1.0, distance / (screenSize.width * 0.4)); // Build tension faster

    // Draw the main stretchy trail
    _drawRubberBandTrail(
        canvas, paint, maxThickness, minThickness, tensionFactor);

    // Add subtle energy particles along the trail
    //_drawTensionParticles(canvas, paint, tensionFactor);
  }

  // Draw a rubber band using smooth bezier curves
  void _drawRubberBandTrail(Canvas canvas, Paint paint, double maxThickness,
      double minThickness, double tensionFactor) {
    final distance = (currentPosition - originalPosition).distance;

    // Create smooth bezier curve for rubber band shape
    final path = Path();
    final direction = (currentPosition - originalPosition).normalize();
    final perpendicular = Offset(-direction.dy, direction.dx);

    // Calculate control points for smooth curves
    final quarterPoint = Offset.lerp(originalPosition, currentPosition, 0.25)!;
    final midPoint = Offset.lerp(originalPosition, currentPosition, 0.5)!;
    final threeQuarterPoint =
        Offset.lerp(originalPosition, currentPosition, 0.75)!;

    // Calculate thickness at key points
    final startThickness = _calculateRubberBandThickness(
        0.0, maxThickness, minThickness, tensionFactor);
    final quarterThickness = _calculateRubberBandThickness(
        0.25, maxThickness, minThickness, tensionFactor);
    final midThickness = _calculateRubberBandThickness(
        0.5, maxThickness, minThickness, tensionFactor);
    final threeQuarterThickness = _calculateRubberBandThickness(
        0.75, maxThickness, minThickness, tensionFactor);
    final endThickness = _calculateRubberBandThickness(
        1.0, maxThickness, minThickness, tensionFactor);

    // Create top edge with bezier curves
    final startTop = originalPosition + perpendicular * (startThickness * 0.5);
    final quarterTop = quarterPoint + perpendicular * (quarterThickness * 0.5);
    final midTop = midPoint + perpendicular * (midThickness * 0.5);
    final threeQuarterTop =
        threeQuarterPoint + perpendicular * (threeQuarterThickness * 0.5);
    final endTop = currentPosition + perpendicular * (endThickness * 0.5);

    // Create bottom edge with bezier curves
    final startBottom =
        originalPosition - perpendicular * (startThickness * 0.5);
    final quarterBottom =
        quarterPoint - perpendicular * (quarterThickness * 0.5);
    final midBottom = midPoint - perpendicular * (midThickness * 0.5);
    final threeQuarterBottom =
        threeQuarterPoint - perpendicular * (threeQuarterThickness * 0.5);
    final endBottom = currentPosition - perpendicular * (endThickness * 0.5);

    // Draw smooth top edge using cubic bezier - curves outward around the bubble
    path.moveTo(startTop.dx, startTop.dy);

    // Control points that curve outward to create rubber band bulge effect
    final topControl1 = Offset.lerp(startTop, quarterTop, 0.5)! +
        perpendicular * (quarterThickness * 0.3);
    final topControl2 = Offset.lerp(quarterTop, midTop, 0.5)! +
        perpendicular * (midThickness * 0.2);
    final topControl3 = Offset.lerp(midTop, threeQuarterTop, 0.5)! +
        perpendicular * (threeQuarterThickness * 0.2);
    final topControl4 = Offset.lerp(threeQuarterTop, endTop, 0.5)! +
        perpendicular * (endThickness * 0.3);

    path.cubicTo(
      topControl1.dx,
      topControl1.dy,
      topControl2.dx,
      topControl2.dy,
      midTop.dx,
      midTop.dy,
    );
    path.cubicTo(
      topControl3.dx,
      topControl3.dy,
      topControl4.dx,
      topControl4.dy,
      endTop.dx,
      endTop.dy,
    );

    // Connect to bottom edge
    path.lineTo(endBottom.dx, endBottom.dy);

    // Draw smooth bottom edge back using cubic bezier - curves outward
    final bottomControl4 = Offset.lerp(endBottom, threeQuarterBottom, 0.5)! -
        perpendicular * (endThickness * 0.3);
    final bottomControl3 = Offset.lerp(threeQuarterBottom, midBottom, 0.5)! -
        perpendicular * (threeQuarterThickness * 0.2);
    final bottomControl2 = Offset.lerp(midBottom, quarterBottom, 0.5)! -
        perpendicular * (midThickness * 0.2);
    final bottomControl1 = Offset.lerp(quarterBottom, startBottom, 0.5)! -
        perpendicular * (quarterThickness * 0.3);

    path.cubicTo(
      bottomControl4.dx,
      bottomControl4.dy,
      bottomControl3.dx,
      bottomControl3.dy,
      midBottom.dx,
      midBottom.dy,
    );
    path.cubicTo(
      bottomControl2.dx,
      bottomControl2.dy,
      bottomControl1.dx,
      bottomControl1.dy,
      startBottom.dx,
      startBottom.dy,
    );

    path.close();

    // Add gradient effect based on tension
    final alpha = (0.9 - tensionFactor * 0.3).clamp(0.2, 0.9);
    canvas.drawPath(path, paint..color = trailColor);

    // Draw connection points for seamless look
    _drawConnectionPoints(
        canvas, paint, maxThickness, minThickness, tensionFactor);
  }

  // Calculate thickness for rubber band effect: wide -> thin -> wide with dynamic scaling
  double _calculateRubberBandThickness(
      double t, double maxThickness, double minThickness, double tension) {
    // Ensure min thickness is always less than max thickness
    final safeMinThickness = math.min(minThickness, maxThickness * 0.95);

    // Wide at bubble point (t = 0)
    final bubbleThickness = maxThickness * 0.9;

    // Wide at drag point (t = 1)
    final dragPointThickness = maxThickness;

    if (t < 0.25) {
      // Start region: from bubble thickness down to minimum
      final localT = t / 0.25;
      final easedT = _easeInOutCubic(localT);
      return bubbleThickness * (1.0 - easedT * 0.7) + safeMinThickness * easedT;
    } else if (t > 0.75) {
      // End region: from minimum up to drag point thickness
      final localT = (t - 0.75) / 0.25;
      final easedT = _easeInOutCubic(localT);
      return safeMinThickness * (1.0 - easedT) + dragPointThickness * easedT;
    } else {
      // Middle region: gradually transition through minimum
      final midProgress = (t - 0.25) / 0.5;
      // Create a smooth dip in the middle
      final dipFactor = math.sin(midProgress * math.pi);
      final baseThickness = safeMinThickness * (1.0 + tension * 0.3);
      return baseThickness * (0.8 + dipFactor * 0.2);
    }
  }

  // Smooth cubic easing function for more natural transitions
  double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3) / 2;
  }

  // Draw connection points for seamless transitions
  void _drawConnectionPoints(Canvas canvas, Paint paint, double maxThickness,
      double minThickness, double tension) {
    // Dynamic sizing based on actual thickness calculations
    final bubbleThickness =
        _calculateRubberBandThickness(0.0, maxThickness, minThickness, tension);
    final dragThickness =
        _calculateRubberBandThickness(1.0, maxThickness, minThickness, tension);

    // Bubble connection point (at original position)
    final bubbleRadius = bubbleThickness * 0.4;
    canvas.drawCircle(
      originalPosition,
      bubbleRadius,
      paint..color = trailColor, //.withValues(alpha: 0.9),
    );

    // Drag point (wider connection at current position)
    final dragPointRadius = dragThickness * 0.4;
    canvas.drawCircle(
      currentPosition,
      dragPointRadius,
      paint..color = trailColor, //.withValues(alpha: 0.9),
    );

    // Add subtle glow effect for high tension
    if (tension > 0.5) {
      // Glow at drag point
      canvas.drawCircle(
        currentPosition,
        dragPointRadius * 1.5,
        paint..color = trailColor, //.withValues(alpha: tension * 0.2),
      );

      // Glow at bubble
      canvas.drawCircle(
        originalPosition,
        bubbleRadius * 1.3,
        paint..color = trailColor, //.withValues(alpha: tension * 0.15),
      );
    }
  }

  // // Draw subtle tension particles along the trail
  // void _drawTensionParticles(Canvas canvas, Paint paint, double tension) {
  //   if (tension < 0.3) return; // Only show when there's significant tension

  //   final distance = (currentPosition - originalPosition).distance;
  //   final particleCount = (tension * 8).floor().clamp(0, 12);

  //   for (int i = 0; i < particleCount; i++) {
  //     final t = (i + 1) / (particleCount + 1);
  //     final particlePos = Offset.lerp(originalPosition, currentPosition, t)!;

  //     // Add slight randomness for organic feel
  //     final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
  //     final offset = math.sin(time * 3 + i) * 2.0;
  //     final direction = (currentPosition - originalPosition).normalize();
  //     final perpendicular = Offset(-direction.dy, direction.dx);
  //     final adjustedPos = particlePos + perpendicular * offset;

  //     // Small energy particles
  //     final particleSize = bubbleSize * 0.02 * tension * (1.0 - t * 0.5);
  //     canvas.drawCircle(
  //       adjustedPos,
  //       particleSize,
  //       paint..color = trailColor.withValues(alpha: tension * 0.8 * (1.0 - t)),
  //     );
  //   }
  // }

  @override
  bool shouldRepaint(SuperStretchyTrailPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition;
  }
}

// Extension to normalize Offset
extension OffsetExtension on Offset {
  Offset normalize() {
    final length = distance;
    if (length == 0) return Offset.zero;
    return this / length;
  }
}
