import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../data/models/notification_model.dart';

part 'notification_state.freezed.dart';

@freezed
abstract class NotificationState with _$NotificationState {
  const factory NotificationState({
    required List<NotificationModel> notifications,
    @Default(false) bool isLoading,
    @Default(true) bool hasMore,
    @Default(0) int unreadCount,
    String? lastNotificationId, // For cloud function pagination
    String? error,
  }) = _NotificationState;

  factory NotificationState.initial() => const NotificationState(
        notifications: [],
        isLoading: false,
        hasMore: true,
        unreadCount: 0,
        lastNotificationId: null,
        error: null,
      );
}
