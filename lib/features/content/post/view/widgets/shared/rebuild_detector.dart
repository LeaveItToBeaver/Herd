import 'package:flutter/material.dart';

/// A diagnostic widget that helps identify what's causing rebuilds
class RebuildDetector extends StatelessWidget {
  final Widget child;
  final String name;
  final VoidCallback? onRebuild;

  const RebuildDetector({
    super.key,
    required this.child,
    required this.name,
    this.onRebuild,
  });

  @override
  Widget build(BuildContext context) {
    // Log every build
    debugPrint('RebuildDetector [$name] building');
    onRebuild?.call();

    // Capture key context data that might be causing rebuilds
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);

    debugPrint(' 📱 MediaQuery - viewInsets: ${mediaQuery.viewInsets}');
    debugPrint(' 📱 MediaQuery - size: ${mediaQuery.size}');
    debugPrint(' Theme brightness: ${theme.brightness}');

    return child;
  }
}

/// Extension to make it easier to wrap widgets for debugging
extension RebuildDetectorExtension on Widget {
  Widget detectRebuilds(String name, {VoidCallback? onRebuild}) {
    return RebuildDetector(
      name: name,
      onRebuild: onRebuild,
      child: this,
    );
  }
}
