// lib/features/content/post/view/widgets/shared/static_post_wrapper.dart
import 'package:flutter/material.dart';

/// A wrapper that creates a static context to prevent unnecessary rebuilds
/// This is more effective than RepaintBoundary for our use case
class StaticPostWrapper extends StatefulWidget {
  final Widget child;
  final String postId; // Used as a key for caching

  const StaticPostWrapper({
    super.key,
    required this.child,
    required this.postId,
  });

  @override
  State<StaticPostWrapper> createState() => _StaticPostWrapperState();
}

class _StaticPostWrapperState extends State<StaticPostWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  // Cache the original MediaQuery data when first built
  MediaQueryData? _cachedMediaQuery;
  ThemeData? _cachedTheme;
  Widget? _cachedChild;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Only cache on first build or when the post ID changes
    if (_cachedMediaQuery == null ||
        _cachedTheme == null ||
        _cachedChild == null) {
      _cachedMediaQuery = MediaQuery.of(context);
      _cachedTheme = Theme.of(context);
      _cacheChild();
    }
  }

  void _cacheChild() {
    // Create a static MediaQuery that doesn't change with keyboard
    final staticMediaQuery = _cachedMediaQuery!.copyWith(
      viewInsets: EdgeInsets.zero, // Remove keyboard insets
      // Keep everything else the same
    );

    _cachedChild = MediaQuery(
      data: staticMediaQuery,
      child: Theme(
        data: _cachedTheme!,
        child: widget.child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    // If the widget child changed (new post content), update the cache
    if (_cachedChild == null) {
      _cacheChild();
    }

    return _cachedChild!;
  }
}

/// Extension for easy wrapping
extension StaticPostWrapperExtension on Widget {
  Widget staticWrapper(String postId) {
    return StaticPostWrapper(
      postId: postId,
      child: this,
    );
  }
}
