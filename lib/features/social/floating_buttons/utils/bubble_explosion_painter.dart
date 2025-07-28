import 'dart:math' as math;
import 'package:flutter/material.dart';

class BubbleExplosionPainter extends CustomPainter {
  final double animationProgress; // 0.0 to 1.0
  final Color bubbleColor;
  final double bubbleSize;
  final Offset position;
  final bool
      isRevealMode; // New: whether this is revealing something underneath

  BubbleExplosionPainter({
    required this.animationProgress,
    required this.bubbleColor,
    required this.bubbleSize,
    required this.position,
    this.isRevealMode = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    if (isRevealMode) {
      _drawRevealEffect(canvas, paint, size);
    } else {
      _drawStandardExplosion(canvas, paint);
    }
  }

  void _drawRevealEffect(Canvas canvas, Paint paint, Size size) {
    // Create a reveal effect that expands outward from the bubble position
    final revealProgress = animationProgress;

    // Phase 1: Initial bubble expansion (0.0 - 0.2)
    if (revealProgress <= 0.2) {
      final expansionProgress = revealProgress / 0.2;
      final easedProgress = _easeOutBack(expansionProgress);
      final currentSize = bubbleSize * (1.0 + easedProgress * 0.5);

      paint.color =
          bubbleColor.withValues(alpha: 1.0 - expansionProgress * 0.3);
      canvas.drawCircle(position, currentSize / 2, paint);
    }

    // Phase 2: Expanding reveal circles (0.1 - 1.0)
    if (revealProgress >= 0.1) {
      final circleProgress = (revealProgress - 0.1) / 0.9;

      // Multiple expanding circles that reveal the content underneath
      final circleCount = 3;
      for (int i = 0; i < circleCount; i++) {
        final staggerDelay = i * 0.15;
        final adjustedProgress =
            ((circleProgress - staggerDelay) / (1.0 - staggerDelay))
                .clamp(0.0, 1.0);

        if (adjustedProgress <= 0) continue;

        final maxRadius = math.max(size.width, size.height) * 1.5;
        final currentRadius = maxRadius * _easeOutQuart(adjustedProgress);

        // Create a mask effect - this will be used to reveal content
        final alpha = (1.0 - adjustedProgress * 0.8).clamp(0.0, 1.0);
        final strokeWidth = bubbleSize * 0.1 * (1.0 - adjustedProgress);

        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = strokeWidth;
        paint.color = bubbleColor.withValues(alpha: alpha * 0.6);

        canvas.drawCircle(position, currentRadius, paint);

        // Add glow effect for the first circle
        if (i == 0 && adjustedProgress > 0.3) {
          paint.strokeWidth = strokeWidth * 3;
          paint.color = bubbleColor.withValues(alpha: alpha * 0.2);
          canvas.drawCircle(position, currentRadius, paint);
        }
      }
    }

    // Phase 3: Particle burst (0.3 - 0.8)
    if (revealProgress >= 0.3 && revealProgress <= 0.8) {
      final particleProgress = (revealProgress - 0.3) / 0.5;
      _drawExplosionParticles(canvas, paint, particleProgress);
    }
  }

  void _drawStandardExplosion(Canvas canvas, Paint paint) {
    // Phase 1: Bubble expansion (0.0 - 0.3)
    if (animationProgress <= 0.3) {
      _drawExpandingBubble(canvas, paint);
    }
    // Phase 2: Explosion particles (0.2 - 0.8)
    else if (animationProgress <= 0.8) {
      _drawExplosionParticles(canvas, paint, (animationProgress - 0.2) / 0.6);
    }
    // Phase 3: Ripple waves (0.6 - 1.0)
    if (animationProgress >= 0.6) {
      _drawRippleWaves(canvas, paint);
    }
  }

  void _drawExpandingBubble(Canvas canvas, Paint paint) {
    final expansionProgress = animationProgress / 0.3;
    final easedProgress = _easeOutElastic(expansionProgress);

    // Bubble grows dramatically before exploding
    final currentSize = bubbleSize * (1.0 + easedProgress * 2.5);

    // Bubble becomes more transparent as it grows
    final alpha = (1.0 - expansionProgress * 0.7).clamp(0.0, 1.0);

    paint.color = bubbleColor.withValues(alpha: alpha);

    canvas.drawCircle(
      position,
      currentSize / 2,
      paint,
    );

    // Add inner glow effect
    if (expansionProgress > 0.5) {
      final glowIntensity = (expansionProgress - 0.5) * 2;
      paint.color = bubbleColor.withValues(alpha: 0.3 * glowIntensity);
      canvas.drawCircle(
        position,
        currentSize / 2 * 1.2,
        paint,
      );
    }
  }

  void _drawExplosionParticles(
      Canvas canvas, Paint paint, double particleProgress) {
    final particleCount = 12;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi;
      final baseDistance = bubbleSize * 1.5;
      final distance = baseDistance * _easeOutQuart(particleProgress);

      final particlePos = Offset(
        position.dx + math.cos(angle) * distance,
        position.dy + math.sin(angle) * distance,
      );

      // Particles get smaller and more transparent over time
      final particleSize = bubbleSize * 0.15 * (1.0 - particleProgress);
      final alpha = (1.0 - particleProgress).clamp(0.0, 1.0);

      paint.style = PaintingStyle.fill;
      paint.color = bubbleColor.withValues(alpha: alpha);
      canvas.drawCircle(particlePos, particleSize, paint);

      // Add sparkle effect - small bright dots
      if (particleProgress < 0.7) {
        final sparkleSize = particleSize * 0.3;
        paint.color = Colors.white.withValues(alpha: alpha * 0.8);
        canvas.drawCircle(particlePos, sparkleSize, paint);
      }

      // Add trailing effect for particles
      if (particleProgress > 0.3) {
        final trailLength = distance * 0.3;
        final trailStart = Offset(
          position.dx + math.cos(angle) * (distance - trailLength),
          position.dy + math.sin(angle) * (distance - trailLength),
        );

        final gradient = RadialGradient(
          colors: [
            bubbleColor.withValues(alpha: alpha * 0.5),
            bubbleColor.withValues(alpha: 0.0),
          ],
        );

        paint.shader = gradient.createShader(
          Rect.fromCircle(center: trailStart, radius: particleSize * 2),
        );

        canvas.drawCircle(trailStart, particleSize * 0.5, paint);
        paint.shader = null;
      }
    }

    // Add secondary smaller particles for more dramatic effect
    final secondaryParticleCount = 8;
    for (int i = 0; i < secondaryParticleCount; i++) {
      final angle = ((i + 0.5) / secondaryParticleCount) * 2 * math.pi;
      final baseDistance = bubbleSize * 1.2;
      final distance = baseDistance * _easeOutQuart(particleProgress * 1.2);

      final particlePos = Offset(
        position.dx + math.cos(angle) * distance,
        position.dy + math.sin(angle) * distance,
      );

      final particleSize = bubbleSize * 0.08 * (1.0 - particleProgress);
      final alpha = (1.0 - particleProgress * 1.2).clamp(0.0, 1.0);

      paint.color = bubbleColor.withValues(alpha: alpha * 0.6);
      canvas.drawCircle(particlePos, particleSize, paint);
    }
  }

  void _drawRippleWaves(Canvas canvas, Paint paint) {
    final rippleProgress = (animationProgress - 0.6) / 0.4;
    final waveCount = 3;

    paint.style = PaintingStyle.stroke;

    for (int i = 0; i < waveCount; i++) {
      final waveDelay = i * 0.2;
      final adjustedProgress =
          ((rippleProgress - waveDelay) / (1.0 - waveDelay)).clamp(0.0, 1.0);

      if (adjustedProgress <= 0) continue;

      final radius = bubbleSize * 2 * _easeOutQuart(adjustedProgress);
      final strokeWidth = bubbleSize * 0.1 * (1.0 - adjustedProgress);
      final alpha = (1.0 - adjustedProgress) * 0.6;

      paint.strokeWidth = strokeWidth;
      paint.color = bubbleColor.withValues(alpha: alpha);

      canvas.drawCircle(position, radius, paint);
    }
  }

  // Custom easing functions for different effects
  double _easeOutElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    return t == 0
        ? 0
        : t == 1
            ? 1
            : math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }

  double _easeOutQuart(double t) {
    return 1 - math.pow(1 - t, 4).toDouble();
  }

  double _easeOutBack(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  @override
  bool shouldRepaint(BubbleExplosionPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.bubbleColor != bubbleColor ||
        oldDelegate.bubbleSize != bubbleSize ||
        oldDelegate.position != position ||
        oldDelegate.isRevealMode != isRevealMode;
  }
}
