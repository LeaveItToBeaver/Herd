import 'package:freezed_annotation/freezed_annotation.dart';
import '../../enums/call_status.dart';
import '../../enums/call_type.dart';

part 'call_model.freezed.dart';
part 'call_model.g.dart';

@freezed
abstract class CallModel with _$CallModel {
  const CallModel._();

  factory CallModel({
    required String id,
    required String callerId,
    String? callerName,
    String? callerProfileImage,
    required List<String> participantIds, // For group calls
    required DateTime initiatedAt,
    DateTime? answeredAt,
    DateTime? endedAt,
    required CallStatus status,
    required CallType type,
    String? groupId, // null for 1-on-1 calls
    @Default(0) int durationSeconds,
    @Default(false) bool isRecorded,
    String? recordingUrl,
    @Default(false) bool isMuted,
    @Default(false) bool isVideoOff,
    @Default(false) bool isSpeakerOn,
    String? endReason, // missed, declined, network_error, etc.
  }) = _CallModel;

  factory CallModel.fromJson(Map<String, dynamic> json) =>
      _$CallModelFromJson(json);
}
