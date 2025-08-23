// lib/features/content/post/view/widgets/shared/isolated_post_wrapper.dart
import 'package:flutter/material.dart';

/// A wrapper that isolates widgets from MediaQuery changes (like keyboard)
/// to prevent unnecessary rebuilds
class IsolatedPostWrapper extends StatelessWidget {
  final Widget child;
  final bool preventKeyboardRebuild;

  const IsolatedPostWrapper({
    super.key,
    required this.child,
    this.preventKeyboardRebuild = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!preventKeyboardRebuild) {
      return child;
    }

    // Get the original MediaQuery
    final originalMediaQuery = MediaQuery.of(context);

    // Create a modified MediaQuery that prevents keyboard changes from affecting the child
    final fixedMediaQuery = originalMediaQuery.copyWith(
      viewInsets: EdgeInsets.zero, // Remove keyboard insets
      viewPadding: originalMediaQuery.viewPadding, // Keep safe area
    );

    return MediaQuery(
      data: fixedMediaQuery,
      child: RepaintBoundary(
        child: child,
      ),
    );
  }
}
