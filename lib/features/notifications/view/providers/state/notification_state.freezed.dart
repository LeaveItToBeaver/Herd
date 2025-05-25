// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationState implements DiagnosticableTreeMixin {
  List<NotificationModel> get notifications;
  bool get isLoading;
  bool get hasMore;
  int get unreadCount;
  String? get lastNotificationId; // For cloud function pagination
  String? get error;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationStateCopyWith<NotificationState> get copyWith =>
      _$NotificationStateCopyWithImpl<NotificationState>(
          this as NotificationState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationState'))
      ..add(DiagnosticsProperty('notifications', notifications))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('unreadCount', unreadCount))
      ..add(DiagnosticsProperty('lastNotificationId', lastNotificationId))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationState &&
            const DeepCollectionEquality()
                .equals(other.notifications, notifications) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.lastNotificationId, lastNotificationId) ||
                other.lastNotificationId == lastNotificationId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(notifications),
      isLoading,
      hasMore,
      unreadCount,
      lastNotificationId,
      error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationState(notifications: $notifications, isLoading: $isLoading, hasMore: $hasMore, unreadCount: $unreadCount, lastNotificationId: $lastNotificationId, error: $error)';
  }
}

/// @nodoc
abstract mixin class $NotificationStateCopyWith<$Res> {
  factory $NotificationStateCopyWith(
          NotificationState value, $Res Function(NotificationState) _then) =
      _$NotificationStateCopyWithImpl;
  @useResult
  $Res call(
      {List<NotificationModel> notifications,
      bool isLoading,
      bool hasMore,
      int unreadCount,
      String? lastNotificationId,
      String? error});
}

/// @nodoc
class _$NotificationStateCopyWithImpl<$Res>
    implements $NotificationStateCopyWith<$Res> {
  _$NotificationStateCopyWithImpl(this._self, this._then);

  final NotificationState _self;
  final $Res Function(NotificationState) _then;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? notifications = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? unreadCount = null,
    Object? lastNotificationId = freezed,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      notifications: null == notifications
          ? _self.notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastNotificationId: freezed == lastNotificationId
          ? _self.lastNotificationId
          : lastNotificationId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _NotificationState
    with DiagnosticableTreeMixin
    implements NotificationState {
  const _NotificationState(
      {required final List<NotificationModel> notifications,
      this.isLoading = false,
      this.hasMore = true,
      this.unreadCount = 0,
      this.lastNotificationId,
      this.error})
      : _notifications = notifications;

  final List<NotificationModel> _notifications;
  @override
  List<NotificationModel> get notifications {
    if (_notifications is EqualUnmodifiableListView) return _notifications;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_notifications);
  }

  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool hasMore;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  final String? lastNotificationId;
// For cloud function pagination
  @override
  final String? error;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationStateCopyWith<_NotificationState> get copyWith =>
      __$NotificationStateCopyWithImpl<_NotificationState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationState'))
      ..add(DiagnosticsProperty('notifications', notifications))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('hasMore', hasMore))
      ..add(DiagnosticsProperty('unreadCount', unreadCount))
      ..add(DiagnosticsProperty('lastNotificationId', lastNotificationId))
      ..add(DiagnosticsProperty('error', error));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationState &&
            const DeepCollectionEquality()
                .equals(other._notifications, _notifications) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.hasMore, hasMore) || other.hasMore == hasMore) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.lastNotificationId, lastNotificationId) ||
                other.lastNotificationId == lastNotificationId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_notifications),
      isLoading,
      hasMore,
      unreadCount,
      lastNotificationId,
      error);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationState(notifications: $notifications, isLoading: $isLoading, hasMore: $hasMore, unreadCount: $unreadCount, lastNotificationId: $lastNotificationId, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$NotificationStateCopyWith<$Res>
    implements $NotificationStateCopyWith<$Res> {
  factory _$NotificationStateCopyWith(
          _NotificationState value, $Res Function(_NotificationState) _then) =
      __$NotificationStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<NotificationModel> notifications,
      bool isLoading,
      bool hasMore,
      int unreadCount,
      String? lastNotificationId,
      String? error});
}

/// @nodoc
class __$NotificationStateCopyWithImpl<$Res>
    implements _$NotificationStateCopyWith<$Res> {
  __$NotificationStateCopyWithImpl(this._self, this._then);

  final _NotificationState _self;
  final $Res Function(_NotificationState) _then;

  /// Create a copy of NotificationState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? notifications = null,
    Object? isLoading = null,
    Object? hasMore = null,
    Object? unreadCount = null,
    Object? lastNotificationId = freezed,
    Object? error = freezed,
  }) {
    return _then(_NotificationState(
      notifications: null == notifications
          ? _self._notifications
          : notifications // ignore: cast_nullable_to_non_nullable
              as List<NotificationModel>,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      hasMore: null == hasMore
          ? _self.hasMore
          : hasMore // ignore: cast_nullable_to_non_nullable
              as bool,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      lastNotificationId: freezed == lastNotificationId
          ? _self.lastNotificationId
          : lastNotificationId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
