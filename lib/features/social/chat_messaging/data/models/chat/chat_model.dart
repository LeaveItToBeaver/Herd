import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'chat_model.freezed.dart';
part 'chat_model.g.dart';

@freezed
abstract class ChatModel with _$ChatModel {
  const ChatModel._();

  factory ChatModel({
    required String id,
    // For 1-on-1 chats - the other user's info
    String? otherUserId,
    String? otherUserName,
    String? otherUserUsername,
    String? otherUserProfileImage,
    String? otherUserAltProfileImage,
    @Default(false) bool otherUserIsAlt,
    // Common chat properties
    String? lastMessage,
    DateTime? lastMessageTimestamp,
    @Default(0) int unreadCount,
    @Default(false) bool isGroupChat,
    @Default(false) bool isMuted,
    @Default(false) bool isArchived,
    @Default(false) bool isPinned,
    // Group chat reference
    String? groupId, // Reference to GroupMessaging model
  }) = _ChatModel;

  factory ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);
}