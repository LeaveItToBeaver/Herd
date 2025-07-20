import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_filter_state.freezed.dart';

enum NotificationFilter { all, unread, follow, post, like, comment, connection }

@freezed
abstract class NotificationFilterState with _$NotificationFilterState {
  const factory NotificationFilterState({
    @Default(NotificationFilter.all) NotificationFilter activeFilter,
    @Default({}) Map<NotificationFilter, int> counts,
  }) = _NotificationFilterState;

  factory NotificationFilterState.initial() => const NotificationFilterState(
        activeFilter: NotificationFilter.all,
        counts: {},
      );
}
