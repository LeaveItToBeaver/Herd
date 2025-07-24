import 'package:flutter/material.dart';
import 'package:herdapp/features/social/floating_buttons/utils/super_stretchy_painter.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';

class ScreenWideDraggableBubble extends StatefulWidget {
  final BubbleConfigState config;
  final dynamic appTheme;
  final Offset startPosition;
  final VoidCallback onDragEnd;

  const ScreenWideDraggableBubble({
    super.key,
    required this.config,
    this.appTheme,
    required this.startPosition,
    required this.onDragEnd,
  });

  @override
  State<ScreenWideDraggableBubble> createState() =>
      _ScreenWideDraggableBubbleState();
}

class _ScreenWideDraggableBubbleState extends State<ScreenWideDraggableBubble>
    with TickerProviderStateMixin {
  late AnimationController _snapBackController;
  late Animation<Offset> _snapBackAnimation;

  Offset _currentPosition = Offset.zero;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentPosition = widget.startPosition;

    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _currentPosition,
      end: widget.startPosition,
    ).animate(CurvedAnimation(
      parent: _snapBackController,
      curve: Curves.elasticOut,
    ));

    _snapBackAnimation.addListener(() {
      setState(() {
        _currentPosition = _snapBackAnimation.value;
      });
    });

    _snapBackController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onDragEnd();
      }
    });
  }

  @override
  void dispose() {
    _snapBackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final backgroundColor = widget.config.backgroundColor ?? Colors.blue;
    final foregroundColor = widget.config.foregroundColor ?? Colors.white;

    return Positioned.fill(
      child: Stack(
        children: [
          // Custom paint for the super stretchy trail
          CustomPaint(
            painter: SuperStretchyTrailPainter(
              originalPosition: widget.startPosition +
                  Offset(widget.config.effectiveSize / 2,
                      widget.config.effectiveSize / 2),
              currentPosition: _currentPosition +
                  Offset(widget.config.effectiveSize / 2,
                      widget.config.effectiveSize / 2),
              trailColor: backgroundColor.withValues(alpha: 0.8),
              bubbleSize: widget.config.effectiveSize,
              screenSize: screenSize,
            ),
            child: Container(),
          ),

          // The draggable bubble
          Positioned(
            left: _currentPosition.dx,
            top: _currentPosition.dy,
            child: GestureDetector(
              onPanStart: (details) {
                setState(() {
                  _isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  _currentPosition += details.delta;
                  // Keep bubble within screen bounds
                  _currentPosition = Offset(
                    _currentPosition.dx.clamp(
                        0, screenSize.width - widget.config.effectiveSize),
                    _currentPosition.dy.clamp(
                        0, screenSize.height - widget.config.effectiveSize),
                  );
                });
              },
              onPanEnd: (details) {
                setState(() {
                  _isDragging = false;
                });
                _snapBack();
              },
              child: Container(
                width: widget.config.effectiveSize,
                height: widget.config.effectiveSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: backgroundColor.withValues(alpha: 0.4),
                      blurRadius: _isDragging ? 20 : 10,
                      spreadRadius: _isDragging ? 5 : 2,
                    ),
                  ],
                ),
                child: Icon(
                  widget.config.icon ?? Icons.circle,
                  color: foregroundColor,
                  size: widget.config.isLarge ? 26 : 22,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _snapBack() {
    _snapBackAnimation = Tween<Offset>(
      begin: _currentPosition,
      end: widget.startPosition,
    ).animate(CurvedAnimation(
      parent: _snapBackController,
      curve: Curves.elasticOut,
    ));

    _snapBackController.reset();
    _snapBackController.forward();
  }
}
