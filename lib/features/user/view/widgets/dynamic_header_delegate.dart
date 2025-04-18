import 'dart:ui';

import 'package:flutter/material.dart';

class DynamicHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;
  final double scrollProgress;
  final ImageProvider? coverImage;

  DynamicHeaderDelegate({
    required this.tabBar,
    required this.backgroundColor,
    required this.scrollProgress,
    this.coverImage,
  });

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: 10.0 * scrollProgress,
          sigmaY: 10.0 * scrollProgress,
        ),
        child: Container(
          color: backgroundColor.withOpacity(0.8 * scrollProgress),
          child: tabBar,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(DynamicHeaderDelegate oldDelegate) {
    return backgroundColor != oldDelegate.backgroundColor ||
        scrollProgress != oldDelegate.scrollProgress ||
        tabBar != oldDelegate.tabBar;
  }
}
