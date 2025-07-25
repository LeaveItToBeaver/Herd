import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

class AdvancedHaptics {
  static void bubbleWrapSequence(double intensity) async {
    if (intensity < 0.3) {
      // Single pop
      HapticFeedback.selectionClick();
    } else if (intensity < 0.6) {
      // Double pop
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 30));
      HapticFeedback.selectionClick();
    } else {
      // Triple pop with crescendo
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 25));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 25));
      HapticFeedback.heavyImpact();
    }
  }

  static void stretchingRubberBand(double tension) async {
    // Simulate the feeling of stretching rubber
    final count = (tension * 3).round().clamp(1, 5);

    for (int i = 0; i < count; i++) {
      if (i == 0) {
        HapticFeedback.lightImpact();
      } else {
        HapticFeedback.selectionClick();
      }

      if (i < count - 1) {
        await Future.delayed(Duration(milliseconds: (50 / (i + 1)).round()));
      }
    }
  }

  static void snapBack() async {
    // Satisfying snap back feeling
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.selectionClick();
  }
}
