import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/global_drag_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';

class GlobalBubbleWrapper extends ConsumerStatefulWidget {
  final BubbleConfigState config;
  final dynamic appTheme;

  const GlobalBubbleWrapper({
    super.key,
    required this.config,
    this.appTheme,
  });

  @override
  ConsumerState<GlobalBubbleWrapper> createState() =>
      _GlobalBubbleWrapperState();
}

class _GlobalBubbleWrapperState extends ConsumerState<GlobalBubbleWrapper> {
  final GlobalKey _bubbleKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Register this bubble with the global system
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(globalDraggableProvider.notifier)
          .registerBubble(widget.config.id, _bubbleKey);
    });
  }

  @override
  void dispose() {
    // Unregister bubble
    ref
        .read(globalDraggableProvider.notifier)
        .unregisterBubble(widget.config.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.shouldShow) {
      return const SizedBox.shrink();
    }

    final globalState = ref.watch(globalDraggableProvider);
    final isBeingDragged = globalState.activeBubbleId == widget.config.id;

    // Get theme-aware colors
    final backgroundColor = widget.config.backgroundColor ??
        (widget.appTheme?.getSurfaceColor() ??
            Theme.of(context).colorScheme.surface);
    final foregroundColor = widget.config.foregroundColor ??
        (widget.appTheme?.getTextColor() ??
            Theme.of(context).colorScheme.onSurface);

    return Padding(
      key: _bubbleKey,
      padding: widget.config.padding,
      child: GestureDetector(
        onTap: isBeingDragged ? null : _handleTap,
        onPanStart: (details) => _startDrag(details),
        child: Opacity(
          opacity: isBeingDragged ? 0.3 : 1.0, // Fade original during drag
          child: Container(
            width: widget.config.effectiveSize,
            height: widget.config.effectiveSize,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: _buildBubbleContent(foregroundColor),
          ),
        ),
      ),
    );
  }

  Widget _buildBubbleContent(Color foregroundColor) {
    switch (widget.config.contentType) {
      case BubbleContentType.icon:
        return Icon(
          widget.config.icon ?? Icons.circle,
          color: foregroundColor,
          size: widget.config.isLarge ? 26 : 22,
        );
      case BubbleContentType.text:
        return Center(
          child: Text(
            widget.config.text ?? '',
            style: TextStyle(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        );
      default:
        return Icon(
          Icons.circle,
          color: foregroundColor,
          size: widget.config.isLarge ? 26 : 22,
        );
    }
  }

  void _handleTap() {
    HapticFeedback.lightImpact();

    if (widget.config.onTap != null) {
      widget.config.onTap!();
    } else if (widget.config.routeName != null) {
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

  void _startDrag(DragStartDetails details) {
    HapticFeedback.mediumImpact();

    final renderBox =
        _bubbleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      ref.read(globalDraggableProvider.notifier).startDrag(
            widget.config.id,
            position,
            context,
            widget.config,
            widget.appTheme,
          );
    }
  }
}
