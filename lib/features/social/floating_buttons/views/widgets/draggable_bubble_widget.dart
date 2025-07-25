import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';

class DraggableBubble extends StatelessWidget {
  final BubbleConfigState config;
  final dynamic appTheme;
  final GlobalKey globalKey;
  final Function(Offset) onDragStart;
  final Function(Offset) onDragUpdate;
  final VoidCallback onDragEnd;
  final bool isBeingDragged;

  const DraggableBubble({
    super.key,
    required this.config,
    this.appTheme,
    required this.globalKey,
    required this.onDragStart,
    required this.onDragUpdate,
    required this.onDragEnd,
    this.isBeingDragged = false,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor =
        config.backgroundColor ?? Theme.of(context).colorScheme.surface;
    final foregroundColor =
        config.foregroundColor ?? Theme.of(context).colorScheme.onSurface;

    return Padding(
      key: globalKey,
      padding: config.padding,
      child: GestureDetector(
        onPanStart: config.isDraggable
            ? (details) {
                onDragStart(
                    details.globalPosition); // Pass original global position
              }
            : null,
        onPanUpdate: config.isDraggable
            ? (details) => onDragUpdate(details.delta)
            : null,
        onPanEnd: config.isDraggable ? (_) => onDragEnd() : null,
        onTap: !isBeingDragged ? () => _handleTap(context) : null,
        onLongPress:
            config.isDraggable ? () => HapticFeedback.mediumImpact() : null,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: 1.0,
          child: Container(
            width: config.effectiveSize,
            height: config.effectiveSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              border: config.isDraggable
                  ? Border.all(
                      color: foregroundColor.withValues(alpha: 0.2),
                      width: 1.5,
                    )
                  : Border.all(
                      color: foregroundColor.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: config.isDraggable ? 10 : 8,
                  spreadRadius: config.isDraggable ? 3 : 2,
                ),
              ],
            ),
            child: Center(
              child: _buildContent(foregroundColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color foregroundColor) {
    if (config.icon != null) {
      return Icon(
        config.icon,
        color: foregroundColor,
        size: config.isLarge ? 26 : 22,
      );
    } else if (config.text != null) {
      return Text(
        config.text!,
        style: TextStyle(
          color: foregroundColor,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  void _handleTap(BuildContext context) {
    HapticFeedback.lightImpact();

    if (config.onTap != null) {
      config.onTap!();
    } else if (config.routeName != null) {
      if (config.routeParams != null) {
        context.pushNamed(
          config.routeName!,
          pathParameters: config.routeParams!,
        );
      } else {
        context.pushNamed(config.routeName!);
      }
    }
  }
}
