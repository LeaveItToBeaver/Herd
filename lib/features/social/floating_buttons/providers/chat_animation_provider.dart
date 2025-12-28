import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_animation_provider.g.dart';

/// Provider to track when chat is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle
@Riverpod(keepAlive: true)
class ChatClosingAnimation extends _$ChatClosingAnimation {
  @override
  String? build() => null;
}

/// Provider to track when herd is closing and needs reverse animation
/// Keep alive to persist state during animation lifecycle
@Riverpod(keepAlive: true)
class HerdClosingAnimation extends _$HerdClosingAnimation {
  @override
  String? build() => null;
}

/// Provider to track the animation callback for each bubble
/// Keep alive to persist callbacks during overlay animation lifecycle
@Riverpod(keepAlive: true)
class BubbleAnimationCallback extends _$BubbleAnimationCallback {
  @override
  Map<String, VoidCallback> build() => {};
}

/// Provider to track explosion reveal animation state
typedef ExplosionRevealState = ({
  bool isActive,
  Offset center,
  double progress,
  String bubbleId,
  bool isClosing,
})?;

/// Keep alive to persist explosion reveal state during animation
@Riverpod(keepAlive: true)
class ExplosionReveal extends _$ExplosionReveal {
  @override
  ExplosionRevealState build() => null;
}
