// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'call_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CallModel _$CallModelFromJson(Map<String, dynamic> json) => _CallModel(
      id: json['id'] as String,
      callerId: json['callerId'] as String,
      callerName: json['callerName'] as String?,
      callerProfileImage: json['callerProfileImage'] as String?,
      participantIds: (json['participantIds'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      initiatedAt: DateTime.parse(json['initiatedAt'] as String),
      answeredAt: json['answeredAt'] == null
          ? null
          : DateTime.parse(json['answeredAt'] as String),
      endedAt: json['endedAt'] == null
          ? null
          : DateTime.parse(json['endedAt'] as String),
      status: $enumDecode(_$CallStatusEnumMap, json['status']),
      type: $enumDecode(_$CallTypeEnumMap, json['type']),
      groupId: json['groupId'] as String?,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      isRecorded: json['isRecorded'] as bool? ?? false,
      recordingUrl: json['recordingUrl'] as String?,
      isMuted: json['isMuted'] as bool? ?? false,
      isVideoOff: json['isVideoOff'] as bool? ?? false,
      isSpeakerOn: json['isSpeakerOn'] as bool? ?? false,
      endReason: json['endReason'] as String?,
    );

Map<String, dynamic> _$CallModelToJson(_CallModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'callerId': instance.callerId,
      'callerName': instance.callerName,
      'callerProfileImage': instance.callerProfileImage,
      'participantIds': instance.participantIds,
      'initiatedAt': instance.initiatedAt.toIso8601String(),
      'answeredAt': instance.answeredAt?.toIso8601String(),
      'endedAt': instance.endedAt?.toIso8601String(),
      'status': _$CallStatusEnumMap[instance.status]!,
      'type': _$CallTypeEnumMap[instance.type]!,
      'groupId': instance.groupId,
      'durationSeconds': instance.durationSeconds,
      'isRecorded': instance.isRecorded,
      'recordingUrl': instance.recordingUrl,
      'isMuted': instance.isMuted,
      'isVideoOff': instance.isVideoOff,
      'isSpeakerOn': instance.isSpeakerOn,
      'endReason': instance.endReason,
    };

const _$CallStatusEnumMap = {
  CallStatus.initiating: 'initiating',
  CallStatus.ringing: 'ringing',
  CallStatus.connecting: 'connecting',
  CallStatus.connected: 'connected',
  CallStatus.ended: 'ended',
  CallStatus.missed: 'missed',
  CallStatus.declined: 'declined',
  CallStatus.busy: 'busy',
  CallStatus.failed: 'failed',
  CallStatus.cancelled: 'cancelled',
};

const _$CallTypeEnumMap = {
  CallType.audio: 'audio',
  CallType.video: 'video',
};
