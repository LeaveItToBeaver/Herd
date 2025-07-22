import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'group_messaging.freezed.dart';
part 'group_messaging.g.dart';

@freezed
abstract class GroupMessaging with _$GroupMessaging {
  const GroupMessaging._();

  factory GroupMessaging({
    required String id,
    required String name,
    String? description,
    String? groupImage,
    required List<String> participants,
    required String adminId,
    String? adminName,
    String? adminUsername,
    List<String>? moderatorIds,
    List<String>? bannedUserIds,
    @Default(false) bool isPrivate,
    @Default(true) bool allowMembersToAddOthers,
    @Default(true) bool allowMembersToEditGroupInfo,
    DateTime? createdAt,
    DateTime? updatedAt,
    @Default(0) int maxParticipants,
    String? inviteLink,
    @Default(false) bool isArchived,
    @Default(false) bool isMuted,
    String? lastMessage,
    DateTime? lastMessageTimestamp,
  }) = _GroupMessaging;

  factory GroupMessaging.fromJson(Map<String, dynamic> json) =>
      _$GroupMessagingFromJson(json);
}
