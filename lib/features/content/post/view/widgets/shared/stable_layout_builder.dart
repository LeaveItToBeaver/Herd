import 'dart:async';
import 'package:flutter/material.dart';

/// A layout builder that debounces layout changes to prevent frequent rebuilds
/// Useful for sidebar toggles or orientation changes
class StableLayoutBuilder extends StatefulWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints)
      builder;
  final Duration debounceDuration;

  const StableLayoutBuilder({
    super.key,
    required this.builder,
    this.debounceDuration = const Duration(milliseconds: 100),
  });

  @override
  State<StableLayoutBuilder> createState() => _StableLayoutBuilderState();
}

class _StableLayoutBuilderState extends State<StableLayoutBuilder> {
  BoxConstraints? _lastConstraints;
  Timer? _debounceTimer;
  bool _shouldRebuild = true;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onLayoutChange(BoxConstraints constraints) {
    // If constraints haven't meaningfully changed, don't rebuild
    if (_lastConstraints != null &&
        _constraintsAreSimilar(_lastConstraints!, constraints)) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      if (mounted) {
        setState(() {
          _lastConstraints = constraints;
          _shouldRebuild = true;
        });
      }
    });
  }

  bool _constraintsAreSimilar(BoxConstraints a, BoxConstraints b) {
    // Consider constraints similar if they're within a small threshold
    const threshold = 10.0;
    return (a.maxWidth - b.maxWidth).abs() < threshold &&
        (a.maxHeight - b.maxHeight).abs() < threshold &&
        (a.minWidth - b.minWidth).abs() < threshold &&
        (a.minHeight - b.minHeight).abs() < threshold;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _onLayoutChange(constraints);

        // Use the last stable constraints or current ones if first build
        final stableConstraints = _lastConstraints ?? constraints;

        return widget.builder(context, stableConstraints);
      },
    );
  }
}
