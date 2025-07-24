import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/draggable_bubble_widget.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/screen_wide_draggable.dart';

class EnhancedSideBubble extends ConsumerStatefulWidget {
  final BubbleConfigState config;
  final dynamic appTheme;
  final Offset originalPosition; // Position in the bubble list

  const EnhancedSideBubble({
    super.key,
    required this.config,
    this.appTheme,
    required this.originalPosition,
  });

  @override
  ConsumerState<EnhancedSideBubble> createState() => _EnhancedSideBubbleState();
}

class _EnhancedSideBubbleState extends ConsumerState<EnhancedSideBubble> {
  bool _isDragMode = false;
  OverlayEntry? _dragOverlay;

  @override
  Widget build(BuildContext context) {
    if (!widget.config.shouldShow) {
      return const SizedBox.shrink();
    }

    // Get theme-aware colors
    final backgroundColor = widget.config.backgroundColor ??
        (widget.appTheme?.getSurfaceColor() ??
            Theme.of(context).colorScheme.surface);
    final foregroundColor = widget.config.foregroundColor ??
        (widget.appTheme?.getTextColor() ??
            Theme.of(context).colorScheme.onSurface);

    // Regular bubble content
    final bubbleContent = _buildBubbleContent(foregroundColor);

    // If this bubble is draggable, wrap it differently
    if (widget.config.isDraggable) {
      return _buildDraggableBubble(
          backgroundColor, foregroundColor, bubbleContent);
    } else {
      return _buildRegularBubble(
          backgroundColor, foregroundColor, bubbleContent);
    }
  }

  Widget _buildDraggableBubble(
      Color backgroundColor, Color foregroundColor, Widget content) {
    return GestureDetector(
      onLongPress: _startScreenWideDrag,
      child: _buildRegularBubble(backgroundColor, foregroundColor, content),
    );
  }

  Widget _buildRegularBubble(
      Color backgroundColor, Color foregroundColor, Widget content) {
    final enableGlassmorphism = widget.appTheme?.enableGlassmorphism ?? false;
    final enableShadows = widget.appTheme?.enableShadows ?? true;
    final shadowIntensity = widget.appTheme?.shadowIntensity ?? 1.0;

    return Padding(
      padding: widget.config.padding,
      child: DraggableBubbleWithTrail(
        size: widget.config.effectiveSize,
        trailColor: foregroundColor.withValues(alpha: 0.7),
        bubbleColor: backgroundColor,
        onTap: () => _handleTap(),
        onDragStart: () => _onLocalDragStart(),
        onDragEnd: () => _onLocalDragEnd(),
        child: Container(
          width: widget.config.effectiveSize,
          height: widget.config.effectiveSize,
          decoration: BoxDecoration(
            color:
                Colors.transparent, // Color handled by DraggableBubbleWithTrail
            borderRadius:
                BorderRadius.circular(widget.config.effectiveSize / 2),
          ),
          child: content,
        ),
      ),
    );
  }

  Widget _buildBubbleContent(Color foregroundColor) {
    // Build content based on config type
    switch (widget.config.contentType) {
      case BubbleContentType.icon:
        return Icon(
          widget.config.icon ?? Icons.circle,
          color: foregroundColor,
          size: widget.config.isLarge ? 26 : 22,
        );
      case BubbleContentType.text:
        return Text(
          widget.config.text ?? '',
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        );
      // Add other content types as needed
      default:
        return Icon(
          Icons.circle,
          color: foregroundColor,
          size: widget.config.isLarge ? 26 : 22,
        );
    }
  }

  void _handleTap() {
    if (widget.config.onTap != null) {
      widget.config.onTap!();
    } else if (widget.config.routeName != null) {
      // Handle navigation
      if (widget.config.routeParams != null) {
        context.pushNamed(
          widget.config.routeName!,
          pathParameters: widget.config.routeParams!,
        );
      } else {
        context.pushNamed(widget.config.routeName!);
      }
    }
  }

  void _onLocalDragStart() {
    // Handle local drag start (within the trail effect)
  }

  void _onLocalDragEnd() {
    // Handle local drag end (snap back to original position)
  }

  void _startScreenWideDrag() {
    // Create a screen-wide draggable overlay
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _dragOverlay = _createDragOverlay(position);
    Overlay.of(context).insert(_dragOverlay!);

    setState(() {
      _isDragMode = true;
    });
  }

  OverlayEntry _createDragOverlay(Offset startPosition) {
    return OverlayEntry(
      builder: (context) => ScreenWideDraggableBubble(
        config: widget.config,
        appTheme: widget.appTheme,
        startPosition: startPosition,
        onDragEnd: _endScreenWideDrag,
      ),
    );
  }

  void _endScreenWideDrag() {
    _dragOverlay?.remove();
    _dragOverlay = null;

    setState(() {
      _isDragMode = false;
    });
  }

  @override
  void dispose() {
    _dragOverlay?.remove();
    super.dispose();
  }
}
