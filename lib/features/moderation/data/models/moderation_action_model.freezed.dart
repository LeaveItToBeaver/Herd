// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'moderation_action_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ModerationAction {
  String get actionId;
  String get performedBy; // userId of moderator/owner
  DateTime get timestamp;
  ModActionType get actionType;
  String get targetId; // userId, postId, or commentId
  ModTargetType get targetType;
  String? get reason;
  String? get notes;
  Map<String, dynamic>? get metadata; // Store additional context
  String? get previousValue;

  /// Create a copy of ModerationAction
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ModerationActionCopyWith<ModerationAction> get copyWith =>
      _$ModerationActionCopyWithImpl<ModerationAction>(
          this as ModerationAction, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ModerationAction &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other.metadata, metadata) &&
            (identical(other.previousValue, previousValue) ||
                other.previousValue == previousValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      actionId,
      performedBy,
      timestamp,
      actionType,
      targetId,
      targetType,
      reason,
      notes,
      const DeepCollectionEquality().hash(metadata),
      previousValue);

  @override
  String toString() {
    return 'ModerationAction(actionId: $actionId, performedBy: $performedBy, timestamp: $timestamp, actionType: $actionType, targetId: $targetId, targetType: $targetType, reason: $reason, notes: $notes, metadata: $metadata, previousValue: $previousValue)';
  }
}

/// @nodoc
abstract mixin class $ModerationActionCopyWith<$Res> {
  factory $ModerationActionCopyWith(
          ModerationAction value, $Res Function(ModerationAction) _then) =
      _$ModerationActionCopyWithImpl;
  @useResult
  $Res call(
      {String actionId,
      String performedBy,
      DateTime timestamp,
      ModActionType actionType,
      String targetId,
      ModTargetType targetType,
      String? reason,
      String? notes,
      Map<String, dynamic>? metadata,
      String? previousValue});
}

/// @nodoc
class _$ModerationActionCopyWithImpl<$Res>
    implements $ModerationActionCopyWith<$Res> {
  _$ModerationActionCopyWithImpl(this._self, this._then);

  final ModerationAction _self;
  final $Res Function(ModerationAction) _then;

  /// Create a copy of ModerationAction
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? actionId = null,
    Object? performedBy = null,
    Object? timestamp = null,
    Object? actionType = null,
    Object? targetId = null,
    Object? targetType = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? previousValue = freezed,
  }) {
    return _then(_self.copyWith(
      actionId: null == actionId
          ? _self.actionId
          : actionId // ignore: cast_nullable_to_non_nullable
              as String,
      performedBy: null == performedBy
          ? _self.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as ModActionType,
      targetId: null == targetId
          ? _self.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetType: null == targetType
          ? _self.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as ModTargetType,
      reason: freezed == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      previousValue: freezed == previousValue
          ? _self.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _ModerationAction extends ModerationAction {
  const _ModerationAction(
      {required this.actionId,
      required this.performedBy,
      required this.timestamp,
      required this.actionType,
      required this.targetId,
      required this.targetType,
      this.reason,
      this.notes,
      final Map<String, dynamic>? metadata,
      this.previousValue})
      : _metadata = metadata,
        super._();

  @override
  final String actionId;
  @override
  final String performedBy;
// userId of moderator/owner
  @override
  final DateTime timestamp;
  @override
  final ModActionType actionType;
  @override
  final String targetId;
// userId, postId, or commentId
  @override
  final ModTargetType targetType;
  @override
  final String? reason;
  @override
  final String? notes;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

// Store additional context
  @override
  final String? previousValue;

  /// Create a copy of ModerationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ModerationActionCopyWith<_ModerationAction> get copyWith =>
      __$ModerationActionCopyWithImpl<_ModerationAction>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ModerationAction &&
            (identical(other.actionId, actionId) ||
                other.actionId == actionId) &&
            (identical(other.performedBy, performedBy) ||
                other.performedBy == performedBy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.actionType, actionType) ||
                other.actionType == actionType) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.notes, notes) || other.notes == notes) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata) &&
            (identical(other.previousValue, previousValue) ||
                other.previousValue == previousValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      actionId,
      performedBy,
      timestamp,
      actionType,
      targetId,
      targetType,
      reason,
      notes,
      const DeepCollectionEquality().hash(_metadata),
      previousValue);

  @override
  String toString() {
    return 'ModerationAction(actionId: $actionId, performedBy: $performedBy, timestamp: $timestamp, actionType: $actionType, targetId: $targetId, targetType: $targetType, reason: $reason, notes: $notes, metadata: $metadata, previousValue: $previousValue)';
  }
}

/// @nodoc
abstract mixin class _$ModerationActionCopyWith<$Res>
    implements $ModerationActionCopyWith<$Res> {
  factory _$ModerationActionCopyWith(
          _ModerationAction value, $Res Function(_ModerationAction) _then) =
      __$ModerationActionCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String actionId,
      String performedBy,
      DateTime timestamp,
      ModActionType actionType,
      String targetId,
      ModTargetType targetType,
      String? reason,
      String? notes,
      Map<String, dynamic>? metadata,
      String? previousValue});
}

/// @nodoc
class __$ModerationActionCopyWithImpl<$Res>
    implements _$ModerationActionCopyWith<$Res> {
  __$ModerationActionCopyWithImpl(this._self, this._then);

  final _ModerationAction _self;
  final $Res Function(_ModerationAction) _then;

  /// Create a copy of ModerationAction
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? actionId = null,
    Object? performedBy = null,
    Object? timestamp = null,
    Object? actionType = null,
    Object? targetId = null,
    Object? targetType = null,
    Object? reason = freezed,
    Object? notes = freezed,
    Object? metadata = freezed,
    Object? previousValue = freezed,
  }) {
    return _then(_ModerationAction(
      actionId: null == actionId
          ? _self.actionId
          : actionId // ignore: cast_nullable_to_non_nullable
              as String,
      performedBy: null == performedBy
          ? _self.performedBy
          : performedBy // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      actionType: null == actionType
          ? _self.actionType
          : actionType // ignore: cast_nullable_to_non_nullable
              as ModActionType,
      targetId: null == targetId
          ? _self.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetType: null == targetType
          ? _self.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as ModTargetType,
      reason: freezed == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as String?,
      notes: freezed == notes
          ? _self.notes
          : notes // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
      previousValue: freezed == previousValue
          ? _self.previousValue
          : previousValue // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
