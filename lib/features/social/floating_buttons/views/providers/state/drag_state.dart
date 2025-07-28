import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';

part 'drag_state.freezed.dart';

@freezed
abstract class DragState with _$DragState {
  const DragState._();

  const factory DragState({
    required String bubbleId,
    required BubbleConfigState bubbleConfig,
    required Offset startPosition,
    required Offset currentPosition,
    required Offset touchOffset,
    required Size bubbleSize,
    required Offset bubbleCenterOffset, // Center point of the bubble
    required GlobalKey bubbleKey,
    required Size screenSize, // Screen size for threshold calculations
    Offset? fixedTrailStartPosition,
    @Default(false)
    bool hasTriggeredChatThreshold, // Track if threshold was crossed
    @Default(false) bool isAnimatingToChat, // Track chat opening animation
    @Default(false)
    bool isChatMorphComplete, // Track if bubble has morphed into chat
    Offset? chatTargetPosition, // Where the bubble should animate to for chat
  }) = _DragState;

  // Computed properties for trail painting
  Offset get trailStartPosition =>
      fixedTrailStartPosition ??
      Offset(
        startPosition.dx + bubbleCenterOffset.dx,
        startPosition.dy + bubbleCenterOffset.dy,
      );

  Offset get trailCurrentPosition => Offset(
        currentPosition.dx + bubbleCenterOffset.dx,
        currentPosition.dy + bubbleCenterOffset.dy,
      );

  Color get trailColor => bubbleConfig.backgroundColor ?? Colors.blue;

  double get bubbleSizeValue => bubbleConfig.effectiveSize;

  // Chat threshold properties
  double get chatThresholdX =>
      screenSize.width * (2 / 3); // 1/3 from right side

  bool get isInChatZone => currentPosition.dx < chatThresholdX;

  bool get shouldTriggerChatThreshold =>
      isInChatZone && !hasTriggeredChatThreshold;
}
