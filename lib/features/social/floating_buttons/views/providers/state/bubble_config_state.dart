import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_type.dart';

part 'bubble_config_state.freezed.dart';

@freezed
abstract class BubbleConfigState with _$BubbleConfigState {
  const BubbleConfigState._();

  const factory BubbleConfigState({
    required String id,
    @Default(BubbleType.custom) BubbleType type,
    @Default(BubbleContentType.icon) BubbleContentType contentType,

    // Visual properties
    double? size,
    @Default(EdgeInsets.all(4)) EdgeInsets padding,
    Color? backgroundColor,
    Color? foregroundColor,
    @Default(false) bool isLarge,

    // Content properties
    IconData? icon,
    String? text,
    String? imageUrl,
    Widget? customContent,

    // Behavior properties
    VoidCallback? onTap,
    String? routeName,
    Map<String, String>? routeParams,
    @Default(false) bool isDraggable,
    @Default(true) bool isVisible,
    @Default(0) int order,

    // Chat-specific properties
    @Default(false) bool isChatBubble,
    String? chatId,
    String? lastMessage,
    int? unreadCount,
    @Default(false) bool isOnline,

    // Conditional visibility
    @JsonKey(includeFromJson: false, includeToJson: false)
    bool Function()? visibilityCondition,
  }) = _BubbleConfig;

  // Helper methods
  bool get shouldShow => isVisible && (visibilityCondition?.call() ?? true);

  double get effectiveSize => size ?? 54.0;

  // Check if this bubble needs spacing after it
  bool needsSpacingAfter(BubbleConfigState? nextBubble) {
    if (nextBubble == null) return false;

    // Add spacing between different bubble groups
    if (order < 100 && nextBubble.order >= 100)
      return true; // After system bubbles
    if (order < 200 && nextBubble.order >= 200)
      return true; // After feed toggle
    if (order < 500 && nextBubble.order >= 500)
      return true; // After custom bubbles
    if (order < 1000 && nextBubble.order >= 1000)
      return true; // After chat bubbles

    return false;
  }

  // Check if this is a system bubble
  bool get isSystemBubble => order < 100;

  // Check if this is a feed toggle bubble
  bool get isFeedToggle => order >= 100 && order < 200;

  // Check if this is a custom bubble
  bool get isCustomBubble => order >= 200 && order < 500;

  // Check if this is a community/chat bubble
  bool get isCommunityBubble => order >= 500;
}
