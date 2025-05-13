// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_settings_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationSettingsModel implements DiagnosticableTreeMixin {
  String get userId;
  bool get pushNotificationsEnabled;
  bool get inAppNotificationsEnabled; // Per-type settings
  bool get followNotifications;
  bool get postNotifications;
  bool get likeNotifications;
  bool get commentNotifications;
  bool get replyNotifications;
  bool get connectionNotifications;
  bool get milestoneNotifications; // Thresholds
  int get likeMilestoneThreshold;
  int get commentMilestoneThreshold; // Temporary mute
  DateTime? get mutedUntil;

  /// Create a copy of NotificationSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationSettingsModelCopyWith<NotificationSettingsModel> get copyWith =>
      _$NotificationSettingsModelCopyWithImpl<NotificationSettingsModel>(
          this as NotificationSettingsModel, _$identity);

  /// Serializes this NotificationSettingsModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationSettingsModel'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty(
          'pushNotificationsEnabled', pushNotificationsEnabled))
      ..add(DiagnosticsProperty(
          'inAppNotificationsEnabled', inAppNotificationsEnabled))
      ..add(DiagnosticsProperty('followNotifications', followNotifications))
      ..add(DiagnosticsProperty('postNotifications', postNotifications))
      ..add(DiagnosticsProperty('likeNotifications', likeNotifications))
      ..add(DiagnosticsProperty('commentNotifications', commentNotifications))
      ..add(DiagnosticsProperty('replyNotifications', replyNotifications))
      ..add(DiagnosticsProperty(
          'connectionNotifications', connectionNotifications))
      ..add(
          DiagnosticsProperty('milestoneNotifications', milestoneNotifications))
      ..add(
          DiagnosticsProperty('likeMilestoneThreshold', likeMilestoneThreshold))
      ..add(DiagnosticsProperty(
          'commentMilestoneThreshold', commentMilestoneThreshold))
      ..add(DiagnosticsProperty('mutedUntil', mutedUntil));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationSettingsModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(
                    other.pushNotificationsEnabled, pushNotificationsEnabled) ||
                other.pushNotificationsEnabled == pushNotificationsEnabled) &&
            (identical(other.inAppNotificationsEnabled,
                    inAppNotificationsEnabled) ||
                other.inAppNotificationsEnabled == inAppNotificationsEnabled) &&
            (identical(other.followNotifications, followNotifications) ||
                other.followNotifications == followNotifications) &&
            (identical(other.postNotifications, postNotifications) ||
                other.postNotifications == postNotifications) &&
            (identical(other.likeNotifications, likeNotifications) ||
                other.likeNotifications == likeNotifications) &&
            (identical(other.commentNotifications, commentNotifications) ||
                other.commentNotifications == commentNotifications) &&
            (identical(other.replyNotifications, replyNotifications) ||
                other.replyNotifications == replyNotifications) &&
            (identical(
                    other.connectionNotifications, connectionNotifications) ||
                other.connectionNotifications == connectionNotifications) &&
            (identical(other.milestoneNotifications, milestoneNotifications) ||
                other.milestoneNotifications == milestoneNotifications) &&
            (identical(other.likeMilestoneThreshold, likeMilestoneThreshold) ||
                other.likeMilestoneThreshold == likeMilestoneThreshold) &&
            (identical(other.commentMilestoneThreshold,
                    commentMilestoneThreshold) ||
                other.commentMilestoneThreshold == commentMilestoneThreshold) &&
            (identical(other.mutedUntil, mutedUntil) ||
                other.mutedUntil == mutedUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      pushNotificationsEnabled,
      inAppNotificationsEnabled,
      followNotifications,
      postNotifications,
      likeNotifications,
      commentNotifications,
      replyNotifications,
      connectionNotifications,
      milestoneNotifications,
      likeMilestoneThreshold,
      commentMilestoneThreshold,
      mutedUntil);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationSettingsModel(userId: $userId, pushNotificationsEnabled: $pushNotificationsEnabled, inAppNotificationsEnabled: $inAppNotificationsEnabled, followNotifications: $followNotifications, postNotifications: $postNotifications, likeNotifications: $likeNotifications, commentNotifications: $commentNotifications, replyNotifications: $replyNotifications, connectionNotifications: $connectionNotifications, milestoneNotifications: $milestoneNotifications, likeMilestoneThreshold: $likeMilestoneThreshold, commentMilestoneThreshold: $commentMilestoneThreshold, mutedUntil: $mutedUntil)';
  }
}

/// @nodoc
abstract mixin class $NotificationSettingsModelCopyWith<$Res> {
  factory $NotificationSettingsModelCopyWith(NotificationSettingsModel value,
          $Res Function(NotificationSettingsModel) _then) =
      _$NotificationSettingsModelCopyWithImpl;
  @useResult
  $Res call(
      {String userId,
      bool pushNotificationsEnabled,
      bool inAppNotificationsEnabled,
      bool followNotifications,
      bool postNotifications,
      bool likeNotifications,
      bool commentNotifications,
      bool replyNotifications,
      bool connectionNotifications,
      bool milestoneNotifications,
      int likeMilestoneThreshold,
      int commentMilestoneThreshold,
      DateTime? mutedUntil});
}

/// @nodoc
class _$NotificationSettingsModelCopyWithImpl<$Res>
    implements $NotificationSettingsModelCopyWith<$Res> {
  _$NotificationSettingsModelCopyWithImpl(this._self, this._then);

  final NotificationSettingsModel _self;
  final $Res Function(NotificationSettingsModel) _then;

  /// Create a copy of NotificationSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? pushNotificationsEnabled = null,
    Object? inAppNotificationsEnabled = null,
    Object? followNotifications = null,
    Object? postNotifications = null,
    Object? likeNotifications = null,
    Object? commentNotifications = null,
    Object? replyNotifications = null,
    Object? connectionNotifications = null,
    Object? milestoneNotifications = null,
    Object? likeMilestoneThreshold = null,
    Object? commentMilestoneThreshold = null,
    Object? mutedUntil = freezed,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      pushNotificationsEnabled: null == pushNotificationsEnabled
          ? _self.pushNotificationsEnabled
          : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      inAppNotificationsEnabled: null == inAppNotificationsEnabled
          ? _self.inAppNotificationsEnabled
          : inAppNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      followNotifications: null == followNotifications
          ? _self.followNotifications
          : followNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      postNotifications: null == postNotifications
          ? _self.postNotifications
          : postNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      likeNotifications: null == likeNotifications
          ? _self.likeNotifications
          : likeNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      commentNotifications: null == commentNotifications
          ? _self.commentNotifications
          : commentNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      replyNotifications: null == replyNotifications
          ? _self.replyNotifications
          : replyNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionNotifications: null == connectionNotifications
          ? _self.connectionNotifications
          : connectionNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      milestoneNotifications: null == milestoneNotifications
          ? _self.milestoneNotifications
          : milestoneNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      likeMilestoneThreshold: null == likeMilestoneThreshold
          ? _self.likeMilestoneThreshold
          : likeMilestoneThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      commentMilestoneThreshold: null == commentMilestoneThreshold
          ? _self.commentMilestoneThreshold
          : commentMilestoneThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      mutedUntil: freezed == mutedUntil
          ? _self.mutedUntil
          : mutedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _NotificationSettingsModel extends NotificationSettingsModel
    with DiagnosticableTreeMixin {
  const _NotificationSettingsModel(
      {required this.userId,
      this.pushNotificationsEnabled = true,
      this.inAppNotificationsEnabled = true,
      this.followNotifications = true,
      this.postNotifications = true,
      this.likeNotifications = true,
      this.commentNotifications = true,
      this.replyNotifications = true,
      this.connectionNotifications = true,
      this.milestoneNotifications = true,
      this.likeMilestoneThreshold = 10,
      this.commentMilestoneThreshold = 5,
      this.mutedUntil})
      : super._();
  factory _NotificationSettingsModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationSettingsModelFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final bool pushNotificationsEnabled;
  @override
  @JsonKey()
  final bool inAppNotificationsEnabled;
// Per-type settings
  @override
  @JsonKey()
  final bool followNotifications;
  @override
  @JsonKey()
  final bool postNotifications;
  @override
  @JsonKey()
  final bool likeNotifications;
  @override
  @JsonKey()
  final bool commentNotifications;
  @override
  @JsonKey()
  final bool replyNotifications;
  @override
  @JsonKey()
  final bool connectionNotifications;
  @override
  @JsonKey()
  final bool milestoneNotifications;
// Thresholds
  @override
  @JsonKey()
  final int likeMilestoneThreshold;
  @override
  @JsonKey()
  final int commentMilestoneThreshold;
// Temporary mute
  @override
  final DateTime? mutedUntil;

  /// Create a copy of NotificationSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationSettingsModelCopyWith<_NotificationSettingsModel>
      get copyWith =>
          __$NotificationSettingsModelCopyWithImpl<_NotificationSettingsModel>(
              this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NotificationSettingsModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationSettingsModel'))
      ..add(DiagnosticsProperty('userId', userId))
      ..add(DiagnosticsProperty(
          'pushNotificationsEnabled', pushNotificationsEnabled))
      ..add(DiagnosticsProperty(
          'inAppNotificationsEnabled', inAppNotificationsEnabled))
      ..add(DiagnosticsProperty('followNotifications', followNotifications))
      ..add(DiagnosticsProperty('postNotifications', postNotifications))
      ..add(DiagnosticsProperty('likeNotifications', likeNotifications))
      ..add(DiagnosticsProperty('commentNotifications', commentNotifications))
      ..add(DiagnosticsProperty('replyNotifications', replyNotifications))
      ..add(DiagnosticsProperty(
          'connectionNotifications', connectionNotifications))
      ..add(
          DiagnosticsProperty('milestoneNotifications', milestoneNotifications))
      ..add(
          DiagnosticsProperty('likeMilestoneThreshold', likeMilestoneThreshold))
      ..add(DiagnosticsProperty(
          'commentMilestoneThreshold', commentMilestoneThreshold))
      ..add(DiagnosticsProperty('mutedUntil', mutedUntil));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationSettingsModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(
                    other.pushNotificationsEnabled, pushNotificationsEnabled) ||
                other.pushNotificationsEnabled == pushNotificationsEnabled) &&
            (identical(other.inAppNotificationsEnabled,
                    inAppNotificationsEnabled) ||
                other.inAppNotificationsEnabled == inAppNotificationsEnabled) &&
            (identical(other.followNotifications, followNotifications) ||
                other.followNotifications == followNotifications) &&
            (identical(other.postNotifications, postNotifications) ||
                other.postNotifications == postNotifications) &&
            (identical(other.likeNotifications, likeNotifications) ||
                other.likeNotifications == likeNotifications) &&
            (identical(other.commentNotifications, commentNotifications) ||
                other.commentNotifications == commentNotifications) &&
            (identical(other.replyNotifications, replyNotifications) ||
                other.replyNotifications == replyNotifications) &&
            (identical(
                    other.connectionNotifications, connectionNotifications) ||
                other.connectionNotifications == connectionNotifications) &&
            (identical(other.milestoneNotifications, milestoneNotifications) ||
                other.milestoneNotifications == milestoneNotifications) &&
            (identical(other.likeMilestoneThreshold, likeMilestoneThreshold) ||
                other.likeMilestoneThreshold == likeMilestoneThreshold) &&
            (identical(other.commentMilestoneThreshold,
                    commentMilestoneThreshold) ||
                other.commentMilestoneThreshold == commentMilestoneThreshold) &&
            (identical(other.mutedUntil, mutedUntil) ||
                other.mutedUntil == mutedUntil));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      pushNotificationsEnabled,
      inAppNotificationsEnabled,
      followNotifications,
      postNotifications,
      likeNotifications,
      commentNotifications,
      replyNotifications,
      connectionNotifications,
      milestoneNotifications,
      likeMilestoneThreshold,
      commentMilestoneThreshold,
      mutedUntil);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationSettingsModel(userId: $userId, pushNotificationsEnabled: $pushNotificationsEnabled, inAppNotificationsEnabled: $inAppNotificationsEnabled, followNotifications: $followNotifications, postNotifications: $postNotifications, likeNotifications: $likeNotifications, commentNotifications: $commentNotifications, replyNotifications: $replyNotifications, connectionNotifications: $connectionNotifications, milestoneNotifications: $milestoneNotifications, likeMilestoneThreshold: $likeMilestoneThreshold, commentMilestoneThreshold: $commentMilestoneThreshold, mutedUntil: $mutedUntil)';
  }
}

/// @nodoc
abstract mixin class _$NotificationSettingsModelCopyWith<$Res>
    implements $NotificationSettingsModelCopyWith<$Res> {
  factory _$NotificationSettingsModelCopyWith(_NotificationSettingsModel value,
          $Res Function(_NotificationSettingsModel) _then) =
      __$NotificationSettingsModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String userId,
      bool pushNotificationsEnabled,
      bool inAppNotificationsEnabled,
      bool followNotifications,
      bool postNotifications,
      bool likeNotifications,
      bool commentNotifications,
      bool replyNotifications,
      bool connectionNotifications,
      bool milestoneNotifications,
      int likeMilestoneThreshold,
      int commentMilestoneThreshold,
      DateTime? mutedUntil});
}

/// @nodoc
class __$NotificationSettingsModelCopyWithImpl<$Res>
    implements _$NotificationSettingsModelCopyWith<$Res> {
  __$NotificationSettingsModelCopyWithImpl(this._self, this._then);

  final _NotificationSettingsModel _self;
  final $Res Function(_NotificationSettingsModel) _then;

  /// Create a copy of NotificationSettingsModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? pushNotificationsEnabled = null,
    Object? inAppNotificationsEnabled = null,
    Object? followNotifications = null,
    Object? postNotifications = null,
    Object? likeNotifications = null,
    Object? commentNotifications = null,
    Object? replyNotifications = null,
    Object? connectionNotifications = null,
    Object? milestoneNotifications = null,
    Object? likeMilestoneThreshold = null,
    Object? commentMilestoneThreshold = null,
    Object? mutedUntil = freezed,
  }) {
    return _then(_NotificationSettingsModel(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      pushNotificationsEnabled: null == pushNotificationsEnabled
          ? _self.pushNotificationsEnabled
          : pushNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      inAppNotificationsEnabled: null == inAppNotificationsEnabled
          ? _self.inAppNotificationsEnabled
          : inAppNotificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      followNotifications: null == followNotifications
          ? _self.followNotifications
          : followNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      postNotifications: null == postNotifications
          ? _self.postNotifications
          : postNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      likeNotifications: null == likeNotifications
          ? _self.likeNotifications
          : likeNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      commentNotifications: null == commentNotifications
          ? _self.commentNotifications
          : commentNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      replyNotifications: null == replyNotifications
          ? _self.replyNotifications
          : replyNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      connectionNotifications: null == connectionNotifications
          ? _self.connectionNotifications
          : connectionNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      milestoneNotifications: null == milestoneNotifications
          ? _self.milestoneNotifications
          : milestoneNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      likeMilestoneThreshold: null == likeMilestoneThreshold
          ? _self.likeMilestoneThreshold
          : likeMilestoneThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      commentMilestoneThreshold: null == commentMilestoneThreshold
          ? _self.commentMilestoneThreshold
          : commentMilestoneThreshold // ignore: cast_nullable_to_non_nullable
              as int,
      mutedUntil: freezed == mutedUntil
          ? _self.mutedUntil
          : mutedUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
