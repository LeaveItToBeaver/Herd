import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track when chat is closing and needs reverse animation
final chatClosingAnimationProvider = StateProvider<String?>((ref) => null);

// Provider to track when herd is closing and needs reverse animation
final herdClosingAnimationProvider = StateProvider<String?>((ref) => null);

// Provider to track the animation callback for each bubble
final bubbleAnimationCallbackProvider =
    StateProvider<Map<String, VoidCallback>>((ref) => {});

// Provider to track explosion reveal animation state
final explosionRevealProvider = StateProvider<
    ({
      bool isActive,
      Offset center,
      double progress,
      String bubbleId,
      bool isClosing, // Added direction flag
    })?>((ref) => null);
