import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';

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
                onDragStart(details.globalPosition);
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
          opacity: isBeingDragged ? 0.0 : 1.0,
          child: Stack(
            children: [
              Container(
                width: config.effectiveSize,
                height: config.effectiveSize,
                decoration: BoxDecoration(
                  color: backgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: foregroundColor.withValues(alpha: 0.1),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: _buildContent(foregroundColor, context),
                ),
              ),

              // Unread count badge
              if (config.unreadCount != null && config.unreadCount! > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: backgroundColor,
                        width: 2,
                      ),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        config.unreadCount! > 99
                            ? '99+'
                            : '${config.unreadCount}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onError,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(Color foregroundColor, BuildContext context) {
    // Handle profile images
    if (config.contentType == BubbleContentType.profileImage &&
        config.imageUrl != null &&
        config.imageUrl!.isNotEmpty) {
      return Container(
        width: config.effectiveSize,
        height: config.effectiveSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(config.imageUrl!),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback will be handled by the error widget below
            },
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: foregroundColor.withValues(alpha: 0.1),
              width: 0.5,
            ),
          ),
        ),
      );
    }

    // Handle herd cover images
    if (config.contentType == BubbleContentType.herdProfileImage &&
        config.imageUrl != null &&
        config.imageUrl!.isNotEmpty) {
      return Container(
        width: config.effectiveSize,
        height: config.effectiveSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(config.imageUrl!),
            fit: BoxFit.cover,
            onError: (exception, stackTrace) {
              // Fallback will be handled by the error widget below
            },
          ),
        ),
      );
    }

    // Icon fallback or default
    if (config.icon != null) {
      return Center(
        child: Icon(
          config.icon,
          color: foregroundColor,
          size: config.isLarge ? 26 : 22,
        ),
      );
    }

    // Text fallback (initials or name)
    if (config.text != null) {
      return Center(
        child: Text(
          config.text!.length > 2
              ? config.text!.substring(0, 2).toUpperCase()
              : config.text!.toUpperCase(),
          style: TextStyle(
            color: foregroundColor,
            fontWeight: FontWeight.w600,
            fontSize: config.isLarge ? 16 : 14,
          ),
        ),
      );
    }

    // Default person icon
    return Center(
      child: Icon(
        Icons.person,
        color: foregroundColor,
        size: config.isLarge ? 26 : 22,
      ),
    );
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
