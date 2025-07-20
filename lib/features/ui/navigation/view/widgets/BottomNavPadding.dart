// ignore: file_names
import 'package:flutter/material.dart';

/// A widget that adds padding at the bottom of scrollable content to prevent
/// items from being hidden behind the bottom navigation bar.
class BottomNavPadding extends StatelessWidget {
  /// The height of the padding to add. Default is 70.0 which should accommodate
  /// the navigation bar height plus some extra space.
  final double height;

  const BottomNavPadding({
    super.key,
    this.height = 75.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: height);
  }
}
