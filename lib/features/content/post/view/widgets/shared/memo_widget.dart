// lib/features/content/post/view/widgets/shared/memo_widget.dart
import 'package:flutter/material.dart';

/// A widget that memoizes its child and only rebuilds when dependencies change
class MemoWidget<T> extends StatefulWidget {
  final T dependency;
  final Widget Function(T dependency) builder;
  final bool Function(T oldDep, T newDep)? shouldRebuild;

  const MemoWidget({
    super.key,
    required this.dependency,
    required this.builder,
    this.shouldRebuild,
  });

  @override
  State<MemoWidget<T>> createState() => _MemoWidgetState<T>();
}

class _MemoWidgetState<T> extends State<MemoWidget<T>> {
  late T _lastDependency;
  late Widget _cachedWidget;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _lastDependency = widget.dependency;
    _cachedWidget = widget.builder(widget.dependency);
    _isInitialized = true;
  }

  @override
  void didUpdateWidget(MemoWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    final shouldRebuild = widget.shouldRebuild ?? _defaultShouldRebuild;

    if (shouldRebuild(_lastDependency, widget.dependency)) {
      _lastDependency = widget.dependency;
      _cachedWidget = widget.builder(widget.dependency);
    }
  }

  bool _defaultShouldRebuild(T oldDep, T newDep) {
    return oldDep != newDep;
  }

  @override
  Widget build(BuildContext context) {
    return _cachedWidget;
  }
}

/// Extension to make it easier to wrap widgets with memo
extension WidgetMemo on Widget {
  Widget memo<T>(T dependency,
      {bool Function(T oldDep, T newDep)? shouldRebuild}) {
    return MemoWidget<T>(
      dependency: dependency,
      shouldRebuild: shouldRebuild,
      builder: (_) => this,
    );
  }
}
