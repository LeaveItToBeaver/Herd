import 'package:freezed_annotation/freezed_annotation.dart';
import '../../enums/message_type.dart';
import '../../enums/message_status.dart';

part 'message_model.freezed.dart';
part 'message_model.g.dart';

@freezed
abstract class MessageModel with _$MessageModel {
  const MessageModel._();

  factory MessageModel({
    required String id,
    required String chatId,
    required String senderId,
    String? senderName,
    String? senderProfileImage,
    String? content,
    @Default(MessageType.text) MessageType type,
    @Default(MessageStatus.delivered) MessageStatus status,
    required DateTime timestamp,
    DateTime? editedAt,
    String? mediaUrl,
    String? thumbnailUrl,
    String? fileName,
    int? fileSize,
    String? replyToMessageId,
    String? forwardedFromUserId,
    String? forwardedFromChatId,
    // Map of userId to timestamp for read receipts
    @Default({}) Map<String, DateTime> readReceipts,
    // Map of userId to reaction emoji
    @Default({}) Map<String, String> reactions,
    @Default(false) bool isEdited,
    @Default(false) bool isDeleted,
    DateTime? deletedAt,
    String? deletedBy,
    @Default(false) bool isPinned,
    @Default(false) bool isStarred,
    @Default(false) bool isForwarded,
    @Default(false) bool isSelfDestructing,
    DateTime? selfDestructTime,
    String? quotedMessageId,
    String? quotedMessageContent,
    // Location data for location messages
    double? latitude,
    double? longitude,
    String? locationName,
    // Contact data for contact messages
    String? contactName,
    String? contactPhone,
    String? contactEmail,
  }) = _MessageModel;

  factory MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);
}
