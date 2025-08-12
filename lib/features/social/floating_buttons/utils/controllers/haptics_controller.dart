import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/services.dart';

class HapticDragController {
  Timer? _hapticTimer;
  double _lastDistance = 0;
  int _stepCount = 0;
  DateTime _lastHapticTime = DateTime.now();

  // Platform-specific settings
  static const double _iosBaseIntensity = 1.0;
  static const double _androidBaseIntensity =
      1.5; // Compensate for weaker vibration

  void startDragHaptics({
    required double distance,
    required double maxDistance,
    required double bubbleSize,
  }) {
    final now = DateTime.now();
    final normalizedDistance = math.min(1.0, distance / maxDistance);

    // Calculate step size - starts large, gets smaller as you drag further
    final baseStepSize = bubbleSize * 0.8; // Start with ~40px steps
    final minStepSize = bubbleSize * 0.3; // End with ~15px steps
    final currentStepSize =
        baseStepSize - (baseStepSize - minStepSize) * normalizedDistance;

    // Check if we've moved far enough for the next haptic step
    final distanceFromLastStep = distance - (_stepCount * currentStepSize);

    if (distanceFromLastStep >= currentStepSize) {
      _stepCount++;
      _triggerStepHaptic(normalizedDistance);
    }
  }

  void _triggerStepHaptic(double intensity) {
    final now = DateTime.now();

    // Prevent too frequent haptics (minimum 30ms apart for performance)
    if (now.difference(_lastHapticTime).inMilliseconds < 30) return;
    _lastHapticTime = now;

    // Progressive intensity based on drag distance
    if (intensity < 0.2) {
      // Light taps for initial drag
      HapticFeedback.selectionClick();
    } else if (intensity < 0.4) {
      // Light impact for mild stretch
      HapticFeedback.lightImpact();
    } else if (intensity < 0.7) {
      // Medium impact for significant stretch
      HapticFeedback.mediumImpact();
    } else {
      // Heavy impact for maximum stretch
      HapticFeedback.heavyImpact();

      // Add extra vibration for extreme stretch (Android compensation)
      if (Platform.isAndroid && intensity > 0.85) {
        Future.delayed(const Duration(milliseconds: 50), () {
          HapticFeedback.mediumImpact();
        });
      }
    }

    // Platform-specific enhancements
    _platformSpecificFeedback(intensity);
  }

  void _platformSpecificFeedback(double intensity) {
    if (Platform.isIOS) {
      // iOS has more nuanced haptics - use them progressively
      if (intensity > 0.8) {
        // Maximum stretch - use selection click for crisp feedback
        Future.delayed(const Duration(milliseconds: 20), () {
          HapticFeedback.selectionClick();
        });
      }
    } else if (Platform.isAndroid) {
      // Android needs more aggressive feedback due to weaker motors
      if (intensity > 0.6) {
        // Add a slight delay for double-tap effect on high intensity
        Future.delayed(const Duration(milliseconds: 40), () {
          HapticFeedback.lightImpact();
        });
      }
    }
  }

  void onDragUpdate({
    required double currentDistance,
    required double maxDistance,
    required double bubbleSize,
  }) {
    startDragHaptics(
      distance: currentDistance,
      maxDistance: maxDistance,
      bubbleSize: bubbleSize,
    );
    _lastDistance = currentDistance;
  }

  void onDragEnd({required double finalDistance, required double maxDistance}) {
    _hapticTimer?.cancel();

    // Final haptic based on release intensity
    final intensity = math.min(1.0, finalDistance / maxDistance);

    if (intensity > 0.7) {
      // Strong release - heavy impact
      HapticFeedback.heavyImpact();

      // Add a satisfying "snap back" haptic after delay
      Future.delayed(const Duration(milliseconds: 200), () {
        HapticFeedback.lightImpact();
      });
    } else if (intensity > 0.3) {
      // Medium release
      HapticFeedback.mediumImpact();
    } else {
      // Light release
      HapticFeedback.lightImpact();
    }

    // Reset counters
    _stepCount = 0;
    _lastDistance = 0;
  }

  void dispose() {
    _hapticTimer?.cancel();
  }
}
