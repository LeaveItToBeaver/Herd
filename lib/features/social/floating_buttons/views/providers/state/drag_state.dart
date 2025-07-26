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
  }) = _DragState;

  // Computed properties for trail painting
  Offset get trailStartPosition => Offset(
        startPosition.dx + bubbleCenterOffset.dx,
        startPosition.dy + bubbleCenterOffset.dy,
      );

  Offset get trailCurrentPosition => Offset(
        currentPosition.dx + bubbleCenterOffset.dx,
        currentPosition.dy + bubbleCenterOffset.dy,
      );

  Color get trailColor => bubbleConfig.backgroundColor ?? Colors.blue;

  double get bubbleSizeValue => bubbleConfig.effectiveSize;
}
