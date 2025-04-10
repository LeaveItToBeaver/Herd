import 'package:flutter/material.dart';

/// A wrapper around NoTransitionPage that ensures a unique key
/// Use this instead of NoTransitionPage to avoid duplicate key issues
class UniquePage<T> extends Page<T> {
  final Widget child;
  final bool opaque;
  final bool maintainState;
  final bool fullscreenDialog;
  final Duration? transitionDuration;
  final Color? barrierColor;
  final bool barrierDismissible;
  final String? barrierLabel;
  final Object? extra;

  UniquePage({
    required this.child,
    this.opaque = true,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.transitionDuration,
    this.barrierColor,
    this.barrierDismissible = false,
    this.barrierLabel,
    this.extra,
    super.name,
    super.arguments,
    super.restorationId,
  }) : super(
          // Create a truly unique key by combining route info with timestamp
          key: ValueKey(
              '${child.runtimeType}-${DateTime.now().microsecondsSinceEpoch}'),
        );

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder<T>(
      settings: this,
      opaque: opaque,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      transitionDuration: const Duration(milliseconds: 0),
      pageBuilder: (context, animation, secondaryAnimation) => child,
    );
  }
}
