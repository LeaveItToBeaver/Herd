// dart format width=80
// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportModel {
  String get reportId;
  String get reportedBy; // userId
  DateTime get timestamp;
  String get targetId; // postId, commentId, or userId
  ReportTargetType get targetType;
  ReportReason get reason;
  String? get description;
  ReportStatus get status;
  String? get reviewedBy; // moderator who reviewed
  DateTime? get reviewedAt;
  String? get resolution;
  Map<String, dynamic>? get metadata;

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ReportModelCopyWith<ReportModel> get copyWith =>
      _$ReportModelCopyWithImpl<ReportModel>(this as ReportModel, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ReportModel &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.reportedBy, reportedBy) ||
                other.reportedBy == reportedBy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            const DeepCollectionEquality().equals(other.metadata, metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      reportId,
      reportedBy,
      timestamp,
      targetId,
      targetType,
      reason,
      description,
      status,
      reviewedBy,
      reviewedAt,
      resolution,
      const DeepCollectionEquality().hash(metadata));

  @override
  String toString() {
    return 'ReportModel(reportId: $reportId, reportedBy: $reportedBy, timestamp: $timestamp, targetId: $targetId, targetType: $targetType, reason: $reason, description: $description, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, resolution: $resolution, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class $ReportModelCopyWith<$Res> {
  factory $ReportModelCopyWith(
          ReportModel value, $Res Function(ReportModel) _then) =
      _$ReportModelCopyWithImpl;
  @useResult
  $Res call(
      {String reportId,
      String reportedBy,
      DateTime timestamp,
      String targetId,
      ReportTargetType targetType,
      ReportReason reason,
      String? description,
      ReportStatus status,
      String? reviewedBy,
      DateTime? reviewedAt,
      String? resolution,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class _$ReportModelCopyWithImpl<$Res> implements $ReportModelCopyWith<$Res> {
  _$ReportModelCopyWithImpl(this._self, this._then);

  final ReportModel _self;
  final $Res Function(ReportModel) _then;

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? reportId = null,
    Object? reportedBy = null,
    Object? timestamp = null,
    Object? targetId = null,
    Object? targetType = null,
    Object? reason = null,
    Object? description = freezed,
    Object? status = null,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? resolution = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_self.copyWith(
      reportId: null == reportId
          ? _self.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      reportedBy: null == reportedBy
          ? _self.reportedBy
          : reportedBy // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      targetId: null == targetId
          ? _self.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetType: null == targetType
          ? _self.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as ReportTargetType,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as ReportReason,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportStatus,
      reviewedBy: freezed == reviewedBy
          ? _self.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _self.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self.metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

/// @nodoc

class _ReportModel extends ReportModel {
  const _ReportModel(
      {required this.reportId,
      required this.reportedBy,
      required this.timestamp,
      required this.targetId,
      required this.targetType,
      required this.reason,
      this.description,
      this.status = ReportStatus.pending,
      this.reviewedBy,
      this.reviewedAt,
      this.resolution,
      final Map<String, dynamic>? metadata})
      : _metadata = metadata,
        super._();

  @override
  final String reportId;
  @override
  final String reportedBy;
// userId
  @override
  final DateTime timestamp;
  @override
  final String targetId;
// postId, commentId, or userId
  @override
  final ReportTargetType targetType;
  @override
  final ReportReason reason;
  @override
  final String? description;
  @override
  @JsonKey()
  final ReportStatus status;
  @override
  final String? reviewedBy;
// moderator who reviewed
  @override
  final DateTime? reviewedAt;
  @override
  final String? resolution;
  final Map<String, dynamic>? _metadata;
  @override
  Map<String, dynamic>? get metadata {
    final value = _metadata;
    if (value == null) return null;
    if (_metadata is EqualUnmodifiableMapView) return _metadata;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ReportModelCopyWith<_ReportModel> get copyWith =>
      __$ReportModelCopyWithImpl<_ReportModel>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ReportModel &&
            (identical(other.reportId, reportId) ||
                other.reportId == reportId) &&
            (identical(other.reportedBy, reportedBy) ||
                other.reportedBy == reportedBy) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.targetId, targetId) ||
                other.targetId == targetId) &&
            (identical(other.targetType, targetType) ||
                other.targetType == targetType) &&
            (identical(other.reason, reason) || other.reason == reason) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.reviewedBy, reviewedBy) ||
                other.reviewedBy == reviewedBy) &&
            (identical(other.reviewedAt, reviewedAt) ||
                other.reviewedAt == reviewedAt) &&
            (identical(other.resolution, resolution) ||
                other.resolution == resolution) &&
            const DeepCollectionEquality().equals(other._metadata, _metadata));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      reportId,
      reportedBy,
      timestamp,
      targetId,
      targetType,
      reason,
      description,
      status,
      reviewedBy,
      reviewedAt,
      resolution,
      const DeepCollectionEquality().hash(_metadata));

  @override
  String toString() {
    return 'ReportModel(reportId: $reportId, reportedBy: $reportedBy, timestamp: $timestamp, targetId: $targetId, targetType: $targetType, reason: $reason, description: $description, status: $status, reviewedBy: $reviewedBy, reviewedAt: $reviewedAt, resolution: $resolution, metadata: $metadata)';
  }
}

/// @nodoc
abstract mixin class _$ReportModelCopyWith<$Res>
    implements $ReportModelCopyWith<$Res> {
  factory _$ReportModelCopyWith(
          _ReportModel value, $Res Function(_ReportModel) _then) =
      __$ReportModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String reportId,
      String reportedBy,
      DateTime timestamp,
      String targetId,
      ReportTargetType targetType,
      ReportReason reason,
      String? description,
      ReportStatus status,
      String? reviewedBy,
      DateTime? reviewedAt,
      String? resolution,
      Map<String, dynamic>? metadata});
}

/// @nodoc
class __$ReportModelCopyWithImpl<$Res> implements _$ReportModelCopyWith<$Res> {
  __$ReportModelCopyWithImpl(this._self, this._then);

  final _ReportModel _self;
  final $Res Function(_ReportModel) _then;

  /// Create a copy of ReportModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? reportId = null,
    Object? reportedBy = null,
    Object? timestamp = null,
    Object? targetId = null,
    Object? targetType = null,
    Object? reason = null,
    Object? description = freezed,
    Object? status = null,
    Object? reviewedBy = freezed,
    Object? reviewedAt = freezed,
    Object? resolution = freezed,
    Object? metadata = freezed,
  }) {
    return _then(_ReportModel(
      reportId: null == reportId
          ? _self.reportId
          : reportId // ignore: cast_nullable_to_non_nullable
              as String,
      reportedBy: null == reportedBy
          ? _self.reportedBy
          : reportedBy // ignore: cast_nullable_to_non_nullable
              as String,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      targetId: null == targetId
          ? _self.targetId
          : targetId // ignore: cast_nullable_to_non_nullable
              as String,
      targetType: null == targetType
          ? _self.targetType
          : targetType // ignore: cast_nullable_to_non_nullable
              as ReportTargetType,
      reason: null == reason
          ? _self.reason
          : reason // ignore: cast_nullable_to_non_nullable
              as ReportReason,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as ReportStatus,
      reviewedBy: freezed == reviewedBy
          ? _self.reviewedBy
          : reviewedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      reviewedAt: freezed == reviewedAt
          ? _self.reviewedAt
          : reviewedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      resolution: freezed == resolution
          ? _self.resolution
          : resolution // ignore: cast_nullable_to_non_nullable
              as String?,
      metadata: freezed == metadata
          ? _self._metadata
          : metadata // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>?,
    ));
  }
}

// dart format on
