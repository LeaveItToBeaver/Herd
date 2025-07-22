// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'call_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CallModel {
  String get id;
  String get callerId;
  String? get callerName;
  String? get callerProfileImage;
  List<String> get participantIds; // For group calls
  DateTime get initiatedAt;
  DateTime? get answeredAt;
  DateTime? get endedAt;
  CallStatus get status;
  CallType get type;
  String? get groupId; // null for 1-on-1 calls
  int get durationSeconds;
  bool get isRecorded;
  String? get recordingUrl;
  bool get isMuted;
  bool get isVideoOff;
  bool get isSpeakerOn;
  String? get endReason;

  /// Create a copy of CallModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CallModelCopyWith<CallModel> get copyWith =>
      _$CallModelCopyWithImpl<CallModel>(this as CallModel, _$identity);

  /// Serializes this CallModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CallModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.callerId, callerId) ||
                other.callerId == callerId) &&
            (identical(other.callerName, callerName) ||
                other.callerName == callerName) &&
            (identical(other.callerProfileImage, callerProfileImage) ||
                other.callerProfileImage == callerProfileImage) &&
            const DeepCollectionEquality()
                .equals(other.participantIds, participantIds) &&
            (identical(other.initiatedAt, initiatedAt) ||
                other.initiatedAt == initiatedAt) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.isRecorded, isRecorded) ||
                other.isRecorded == isRecorded) &&
            (identical(other.recordingUrl, recordingUrl) ||
                other.recordingUrl == recordingUrl) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isVideoOff, isVideoOff) ||
                other.isVideoOff == isVideoOff) &&
            (identical(other.isSpeakerOn, isSpeakerOn) ||
                other.isSpeakerOn == isSpeakerOn) &&
            (identical(other.endReason, endReason) ||
                other.endReason == endReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      callerId,
      callerName,
      callerProfileImage,
      const DeepCollectionEquality().hash(participantIds),
      initiatedAt,
      answeredAt,
      endedAt,
      status,
      type,
      groupId,
      durationSeconds,
      isRecorded,
      recordingUrl,
      isMuted,
      isVideoOff,
      isSpeakerOn,
      endReason);

  @override
  String toString() {
    return 'CallModel(id: $id, callerId: $callerId, callerName: $callerName, callerProfileImage: $callerProfileImage, participantIds: $participantIds, initiatedAt: $initiatedAt, answeredAt: $answeredAt, endedAt: $endedAt, status: $status, type: $type, groupId: $groupId, durationSeconds: $durationSeconds, isRecorded: $isRecorded, recordingUrl: $recordingUrl, isMuted: $isMuted, isVideoOff: $isVideoOff, isSpeakerOn: $isSpeakerOn, endReason: $endReason)';
  }
}

/// @nodoc
abstract mixin class $CallModelCopyWith<$Res> {
  factory $CallModelCopyWith(CallModel value, $Res Function(CallModel) _then) =
      _$CallModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String callerId,
      String? callerName,
      String? callerProfileImage,
      List<String> participantIds,
      DateTime initiatedAt,
      DateTime? answeredAt,
      DateTime? endedAt,
      CallStatus status,
      CallType type,
      String? groupId,
      int durationSeconds,
      bool isRecorded,
      String? recordingUrl,
      bool isMuted,
      bool isVideoOff,
      bool isSpeakerOn,
      String? endReason});
}

/// @nodoc
class _$CallModelCopyWithImpl<$Res> implements $CallModelCopyWith<$Res> {
  _$CallModelCopyWithImpl(this._self, this._then);

  final CallModel _self;
  final $Res Function(CallModel) _then;

  /// Create a copy of CallModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? callerId = null,
    Object? callerName = freezed,
    Object? callerProfileImage = freezed,
    Object? participantIds = null,
    Object? initiatedAt = null,
    Object? answeredAt = freezed,
    Object? endedAt = freezed,
    Object? status = null,
    Object? type = null,
    Object? groupId = freezed,
    Object? durationSeconds = null,
    Object? isRecorded = null,
    Object? recordingUrl = freezed,
    Object? isMuted = null,
    Object? isVideoOff = null,
    Object? isSpeakerOn = null,
    Object? endReason = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      callerId: null == callerId
          ? _self.callerId
          : callerId // ignore: cast_nullable_to_non_nullable
              as String,
      callerName: freezed == callerName
          ? _self.callerName
          : callerName // ignore: cast_nullable_to_non_nullable
              as String?,
      callerProfileImage: freezed == callerProfileImage
          ? _self.callerProfileImage
          : callerProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      participantIds: null == participantIds
          ? _self.participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      initiatedAt: null == initiatedAt
          ? _self.initiatedAt
          : initiatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      answeredAt: freezed == answeredAt
          ? _self.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _self.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CallStatus,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as CallType,
      groupId: freezed == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      durationSeconds: null == durationSeconds
          ? _self.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isRecorded: null == isRecorded
          ? _self.isRecorded
          : isRecorded // ignore: cast_nullable_to_non_nullable
              as bool,
      recordingUrl: freezed == recordingUrl
          ? _self.recordingUrl
          : recordingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isVideoOff: null == isVideoOff
          ? _self.isVideoOff
          : isVideoOff // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeakerOn: null == isSpeakerOn
          ? _self.isSpeakerOn
          : isSpeakerOn // ignore: cast_nullable_to_non_nullable
              as bool,
      endReason: freezed == endReason
          ? _self.endReason
          : endReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [CallModel].
extension CallModelPatterns on CallModel {
  /// A variant of `map` that fallback to returning `orElse`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>(
    TResult Function(_CallModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CallModel() when $default != null:
        return $default(_that);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// Callbacks receives the raw object, upcasted.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case final Subclass2 value:
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult map<TResult extends Object?>(
    TResult Function(_CallModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CallModel():
        return $default(_that);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `map` that fallback to returning `null`.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case final Subclass value:
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>(
    TResult? Function(_CallModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CallModel() when $default != null:
        return $default(_that);
      case _:
        return null;
    }
  }

  /// A variant of `when` that fallback to an `orElse` callback.
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return orElse();
  /// }
  /// ```

  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>(
    TResult Function(
            String id,
            String callerId,
            String? callerName,
            String? callerProfileImage,
            List<String> participantIds,
            DateTime initiatedAt,
            DateTime? answeredAt,
            DateTime? endedAt,
            CallStatus status,
            CallType type,
            String? groupId,
            int durationSeconds,
            bool isRecorded,
            String? recordingUrl,
            bool isMuted,
            bool isVideoOff,
            bool isSpeakerOn,
            String? endReason)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CallModel() when $default != null:
        return $default(
            _that.id,
            _that.callerId,
            _that.callerName,
            _that.callerProfileImage,
            _that.participantIds,
            _that.initiatedAt,
            _that.answeredAt,
            _that.endedAt,
            _that.status,
            _that.type,
            _that.groupId,
            _that.durationSeconds,
            _that.isRecorded,
            _that.recordingUrl,
            _that.isMuted,
            _that.isVideoOff,
            _that.isSpeakerOn,
            _that.endReason);
      case _:
        return orElse();
    }
  }

  /// A `switch`-like method, using callbacks.
  ///
  /// As opposed to `map`, this offers destructuring.
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case Subclass2(:final field2):
  ///     return ...;
  /// }
  /// ```

  @optionalTypeArgs
  TResult when<TResult extends Object?>(
    TResult Function(
            String id,
            String callerId,
            String? callerName,
            String? callerProfileImage,
            List<String> participantIds,
            DateTime initiatedAt,
            DateTime? answeredAt,
            DateTime? endedAt,
            CallStatus status,
            CallType type,
            String? groupId,
            int durationSeconds,
            bool isRecorded,
            String? recordingUrl,
            bool isMuted,
            bool isVideoOff,
            bool isSpeakerOn,
            String? endReason)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CallModel():
        return $default(
            _that.id,
            _that.callerId,
            _that.callerName,
            _that.callerProfileImage,
            _that.participantIds,
            _that.initiatedAt,
            _that.answeredAt,
            _that.endedAt,
            _that.status,
            _that.type,
            _that.groupId,
            _that.durationSeconds,
            _that.isRecorded,
            _that.recordingUrl,
            _that.isMuted,
            _that.isVideoOff,
            _that.isSpeakerOn,
            _that.endReason);
      case _:
        throw StateError('Unexpected subclass');
    }
  }

  /// A variant of `when` that fallback to returning `null`
  ///
  /// It is equivalent to doing:
  /// ```dart
  /// switch (sealedClass) {
  ///   case Subclass(:final field):
  ///     return ...;
  ///   case _:
  ///     return null;
  /// }
  /// ```

  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>(
    TResult? Function(
            String id,
            String callerId,
            String? callerName,
            String? callerProfileImage,
            List<String> participantIds,
            DateTime initiatedAt,
            DateTime? answeredAt,
            DateTime? endedAt,
            CallStatus status,
            CallType type,
            String? groupId,
            int durationSeconds,
            bool isRecorded,
            String? recordingUrl,
            bool isMuted,
            bool isVideoOff,
            bool isSpeakerOn,
            String? endReason)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CallModel() when $default != null:
        return $default(
            _that.id,
            _that.callerId,
            _that.callerName,
            _that.callerProfileImage,
            _that.participantIds,
            _that.initiatedAt,
            _that.answeredAt,
            _that.endedAt,
            _that.status,
            _that.type,
            _that.groupId,
            _that.durationSeconds,
            _that.isRecorded,
            _that.recordingUrl,
            _that.isMuted,
            _that.isVideoOff,
            _that.isSpeakerOn,
            _that.endReason);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CallModel extends CallModel {
  _CallModel(
      {required this.id,
      required this.callerId,
      this.callerName,
      this.callerProfileImage,
      required final List<String> participantIds,
      required this.initiatedAt,
      this.answeredAt,
      this.endedAt,
      required this.status,
      required this.type,
      this.groupId,
      this.durationSeconds = 0,
      this.isRecorded = false,
      this.recordingUrl,
      this.isMuted = false,
      this.isVideoOff = false,
      this.isSpeakerOn = false,
      this.endReason})
      : _participantIds = participantIds,
        super._();
  factory _CallModel.fromJson(Map<String, dynamic> json) =>
      _$CallModelFromJson(json);

  @override
  final String id;
  @override
  final String callerId;
  @override
  final String? callerName;
  @override
  final String? callerProfileImage;
  final List<String> _participantIds;
  @override
  List<String> get participantIds {
    if (_participantIds is EqualUnmodifiableListView) return _participantIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participantIds);
  }

// For group calls
  @override
  final DateTime initiatedAt;
  @override
  final DateTime? answeredAt;
  @override
  final DateTime? endedAt;
  @override
  final CallStatus status;
  @override
  final CallType type;
  @override
  final String? groupId;
// null for 1-on-1 calls
  @override
  @JsonKey()
  final int durationSeconds;
  @override
  @JsonKey()
  final bool isRecorded;
  @override
  final String? recordingUrl;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  @JsonKey()
  final bool isVideoOff;
  @override
  @JsonKey()
  final bool isSpeakerOn;
  @override
  final String? endReason;

  /// Create a copy of CallModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CallModelCopyWith<_CallModel> get copyWith =>
      __$CallModelCopyWithImpl<_CallModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CallModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CallModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.callerId, callerId) ||
                other.callerId == callerId) &&
            (identical(other.callerName, callerName) ||
                other.callerName == callerName) &&
            (identical(other.callerProfileImage, callerProfileImage) ||
                other.callerProfileImage == callerProfileImage) &&
            const DeepCollectionEquality()
                .equals(other._participantIds, _participantIds) &&
            (identical(other.initiatedAt, initiatedAt) ||
                other.initiatedAt == initiatedAt) &&
            (identical(other.answeredAt, answeredAt) ||
                other.answeredAt == answeredAt) &&
            (identical(other.endedAt, endedAt) || other.endedAt == endedAt) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.groupId, groupId) || other.groupId == groupId) &&
            (identical(other.durationSeconds, durationSeconds) ||
                other.durationSeconds == durationSeconds) &&
            (identical(other.isRecorded, isRecorded) ||
                other.isRecorded == isRecorded) &&
            (identical(other.recordingUrl, recordingUrl) ||
                other.recordingUrl == recordingUrl) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isVideoOff, isVideoOff) ||
                other.isVideoOff == isVideoOff) &&
            (identical(other.isSpeakerOn, isSpeakerOn) ||
                other.isSpeakerOn == isSpeakerOn) &&
            (identical(other.endReason, endReason) ||
                other.endReason == endReason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      callerId,
      callerName,
      callerProfileImage,
      const DeepCollectionEquality().hash(_participantIds),
      initiatedAt,
      answeredAt,
      endedAt,
      status,
      type,
      groupId,
      durationSeconds,
      isRecorded,
      recordingUrl,
      isMuted,
      isVideoOff,
      isSpeakerOn,
      endReason);

  @override
  String toString() {
    return 'CallModel(id: $id, callerId: $callerId, callerName: $callerName, callerProfileImage: $callerProfileImage, participantIds: $participantIds, initiatedAt: $initiatedAt, answeredAt: $answeredAt, endedAt: $endedAt, status: $status, type: $type, groupId: $groupId, durationSeconds: $durationSeconds, isRecorded: $isRecorded, recordingUrl: $recordingUrl, isMuted: $isMuted, isVideoOff: $isVideoOff, isSpeakerOn: $isSpeakerOn, endReason: $endReason)';
  }
}

/// @nodoc
abstract mixin class _$CallModelCopyWith<$Res>
    implements $CallModelCopyWith<$Res> {
  factory _$CallModelCopyWith(
          _CallModel value, $Res Function(_CallModel) _then) =
      __$CallModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String callerId,
      String? callerName,
      String? callerProfileImage,
      List<String> participantIds,
      DateTime initiatedAt,
      DateTime? answeredAt,
      DateTime? endedAt,
      CallStatus status,
      CallType type,
      String? groupId,
      int durationSeconds,
      bool isRecorded,
      String? recordingUrl,
      bool isMuted,
      bool isVideoOff,
      bool isSpeakerOn,
      String? endReason});
}

/// @nodoc
class __$CallModelCopyWithImpl<$Res> implements _$CallModelCopyWith<$Res> {
  __$CallModelCopyWithImpl(this._self, this._then);

  final _CallModel _self;
  final $Res Function(_CallModel) _then;

  /// Create a copy of CallModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? callerId = null,
    Object? callerName = freezed,
    Object? callerProfileImage = freezed,
    Object? participantIds = null,
    Object? initiatedAt = null,
    Object? answeredAt = freezed,
    Object? endedAt = freezed,
    Object? status = null,
    Object? type = null,
    Object? groupId = freezed,
    Object? durationSeconds = null,
    Object? isRecorded = null,
    Object? recordingUrl = freezed,
    Object? isMuted = null,
    Object? isVideoOff = null,
    Object? isSpeakerOn = null,
    Object? endReason = freezed,
  }) {
    return _then(_CallModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      callerId: null == callerId
          ? _self.callerId
          : callerId // ignore: cast_nullable_to_non_nullable
              as String,
      callerName: freezed == callerName
          ? _self.callerName
          : callerName // ignore: cast_nullable_to_non_nullable
              as String?,
      callerProfileImage: freezed == callerProfileImage
          ? _self.callerProfileImage
          : callerProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      participantIds: null == participantIds
          ? _self._participantIds
          : participantIds // ignore: cast_nullable_to_non_nullable
              as List<String>,
      initiatedAt: null == initiatedAt
          ? _self.initiatedAt
          : initiatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      answeredAt: freezed == answeredAt
          ? _self.answeredAt
          : answeredAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      endedAt: freezed == endedAt
          ? _self.endedAt
          : endedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as CallStatus,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as CallType,
      groupId: freezed == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
      durationSeconds: null == durationSeconds
          ? _self.durationSeconds
          : durationSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      isRecorded: null == isRecorded
          ? _self.isRecorded
          : isRecorded // ignore: cast_nullable_to_non_nullable
              as bool,
      recordingUrl: freezed == recordingUrl
          ? _self.recordingUrl
          : recordingUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isVideoOff: null == isVideoOff
          ? _self.isVideoOff
          : isVideoOff // ignore: cast_nullable_to_non_nullable
              as bool,
      isSpeakerOn: null == isSpeakerOn
          ? _self.isSpeakerOn
          : isSpeakerOn // ignore: cast_nullable_to_non_nullable
              as bool,
      endReason: freezed == endReason
          ? _self.endReason
          : endReason // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
