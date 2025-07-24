import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DraggableBubbleWithTrail extends StatefulWidget {
  final Widget child;
  final double size;
  final Color trailColor;
  final Color bubbleColor;
  final VoidCallback? onTap;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Duration snapBackDuration;

  const DraggableBubbleWithTrail({
    super.key,
    required this.child,
    this.size = 54.0,
    this.trailColor = Colors.blue,
    this.bubbleColor = Colors.white,
    this.onTap,
    this.onDragStart,
    this.onDragEnd,
    this.snapBackDuration = const Duration(milliseconds: 800),
  });

  @override
  State<DraggableBubbleWithTrail> createState() =>
      _DraggableBubbleWithTrailState();
}

class _DraggableBubbleWithTrailState extends State<DraggableBubbleWithTrail>
    with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _snapBackController;
  late AnimationController _pulseController;

  // Animations
  late Animation<Offset> _snapBackAnimation;
  late Animation<double> _pulseAnimation;

  // Drag state
  Offset _dragOffset = Offset.zero;
  Offset _originalPosition = Offset.zero;
  bool _isDragging = false;

  // Trail properties
  double _trailStrength = 0.0;

  @override
  void initState() {
    super.initState();

    // Snap back animation
    _snapBackController = AnimationController(
      duration: widget.snapBackDuration,
      vsync: this,
    );

    // Pulse animation for tactile feedback
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _snapBackController,
      curve: Curves.elasticOut, // Bouncy spring effect
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.elasticOut,
    ));

    _snapBackAnimation.addListener(() {
      setState(() {
        _dragOffset = _snapBackAnimation.value;
        _trailStrength = (1.0 - _snapBackController.value).clamp(0.0, 1.0);
      });
    });

    _snapBackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isDragging = false;
          _dragOffset = Offset.zero;
          _trailStrength = 0.0;
        });
      }
    });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startDrag() {
    setState(() {
      _isDragging = true;
    });

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Pulse animation
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    widget.onDragStart?.call();
  }

  void _updateDrag(Offset localPosition, Offset globalPosition) {
    setState(() {
      _dragOffset = localPosition;
      // Calculate trail strength based on distance
      final distance = _dragOffset.distance;
      _trailStrength = (distance / 100.0).clamp(0.0, 1.0);
    });
  }

  void _endDrag() {
    if (!_isDragging) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Snap back animation
    _snapBackAnimation = Tween<Offset>(
      begin: _dragOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _snapBackController,
      curve: Curves.elasticOut,
    ));

    _snapBackController.reset();
    _snapBackController.forward();

    widget.onDragEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isDragging ? null : widget.onTap,
      onPanStart: (details) => _startDrag(),
      onPanUpdate: (details) => _updateDrag(
        details.localPosition - Offset(widget.size / 2, widget.size / 2),
        details.globalPosition,
      ),
      onPanEnd: (details) => _endDrag(),
      child: AnimatedBuilder(
        animation: Listenable.merge([_snapBackAnimation, _pulseAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: GoopyTrailPainter(
              originalPosition: Offset.zero,
              currentPosition: _dragOffset,
              trailStrength: _trailStrength,
              trailColor: widget.trailColor,
              bubbleSize: widget.size,
            ),
            child: Transform.translate(
              offset: _dragOffset,
              child: Transform.scale(
                scale: _isDragging ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.bubbleColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (_isDragging)
                        BoxShadow(
                          color: widget.trailColor.withValues(alpha: 0.3),
                          blurRadius: 20 * _trailStrength,
                          spreadRadius: 5 * _trailStrength,
                        ),
                    ],
                  ),
                  child: widget.child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class GoopyTrailPainter extends CustomPainter {
  final Offset originalPosition;
  final Offset currentPosition;
  final double trailStrength;
  final Color trailColor;
  final double bubbleSize;

  GoopyTrailPainter({
    required this.originalPosition,
    required this.currentPosition,
    required this.trailStrength,
    required this.trailColor,
    required this.bubbleSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trailStrength <= 0.0) return;

    final paint = Paint()
      ..color = trailColor.withValues(alpha: 0.6 * trailStrength)
      ..style = PaintingStyle.fill;

    final distance = currentPosition.distance;
    if (distance < 5) return; // Don't draw trail for tiny movements

    // Calculate trail properties
    final maxThickness = bubbleSize * 0.4;
    final minThickness = bubbleSize * 0.1;
    final trailThickness =
        minThickness + (maxThickness - minThickness) * trailStrength;

    // Create the goopy trail path
    final path = _createGoopyTrailPath(
      originalPosition + Offset(bubbleSize / 2, bubbleSize / 2),
      currentPosition + Offset(bubbleSize / 2, bubbleSize / 2),
      trailThickness,
    );

    canvas.drawPath(path, paint);

    // Add some blob effects along the trail
    _drawTrailBlobs(canvas, paint, trailThickness);
  }

  Path _createGoopyTrailPath(Offset start, Offset end, double thickness) {
    final path = Path();

    // Calculate perpendicular vector for trail width
    final direction = end - start;
    final perpendicular = Offset(-direction.dy, direction.dx).normalize();

    // Create the trail outline using bezier curves for smooth, goopy effect
    final startTop = start + perpendicular * (thickness / 2);
    final startBottom = start - perpendicular * (thickness / 2);
    final endTop = end + perpendicular * (thickness / 4); // Thinner at the end
    final endBottom = end - perpendicular * (thickness / 4);

    // Create control points for smooth curves
    final distance = direction.distance;
    final controlOffset = distance * 0.3;

    final control1Top = startTop + direction.normalize() * controlOffset;
    final control2Top = endTop - direction.normalize() * controlOffset;
    final control1Bottom = startBottom + direction.normalize() * controlOffset;
    final control2Bottom = endBottom - direction.normalize() * controlOffset;

    // Draw the trail path
    path.moveTo(startTop.dx, startTop.dy);
    path.cubicTo(
      control1Top.dx,
      control1Top.dy,
      control2Top.dx,
      control2Top.dy,
      endTop.dx,
      endTop.dy,
    );

    // Connect to bottom
    path.lineTo(endBottom.dx, endBottom.dy);

    path.cubicTo(
      control2Bottom.dx,
      control2Bottom.dy,
      control1Bottom.dx,
      control1Bottom.dy,
      startBottom.dx,
      startBottom.dy,
    );

    path.close();

    return path;
  }

  void _drawTrailBlobs(Canvas canvas, Paint paint, double thickness) {
    final distance = currentPosition.distance;
    final blobCount = (distance / 30).floor().clamp(0, 8);

    for (int i = 1; i <= blobCount; i++) {
      final t = i / (blobCount + 1);
      final blobPosition = Offset.lerp(
        originalPosition + Offset(bubbleSize / 2, bubbleSize / 2),
        currentPosition + Offset(bubbleSize / 2, bubbleSize / 2),
        t,
      )!;

      // Vary blob size based on position and trail strength
      final blobSize = (thickness * 0.3) * (1.0 - t * 0.5) * trailStrength;

      // Add some randomness to blob positions for organic feel
      final wobble = math.sin(t * math.pi * 4) * thickness * 0.1;
      final direction = currentPosition.normalize();
      final perpendicular = Offset(-direction.dy, direction.dx);
      final wobbleOffset = perpendicular * wobble;

      canvas.drawCircle(
        blobPosition + wobbleOffset,
        blobSize,
        paint
          ..color =
              trailColor.withValues(alpha: 0.3 * trailStrength * (1.0 - t)),
      );
    }
  }

  @override
  bool shouldRepaint(GoopyTrailPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition ||
        oldDelegate.trailStrength != trailStrength;
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
