// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MessageModel _$MessageModelFromJson(Map<String, dynamic> json) =>
    _MessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String?,
      senderProfileImage: json['senderProfileImage'] as String?,
      content: json['content'] as String?,
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      status: $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
          MessageStatus.delivered,
      timestamp: DateTime.parse(json['timestamp'] as String),
      editedAt: json['editedAt'] == null
          ? null
          : DateTime.parse(json['editedAt'] as String),
      mediaUrl: json['mediaUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      fileName: json['fileName'] as String?,
      fileSize: (json['fileSize'] as num?)?.toInt(),
      replyToMessageId: json['replyToMessageId'] as String?,
      forwardedFromUserId: json['forwardedFromUserId'] as String?,
      forwardedFromChatId: json['forwardedFromChatId'] as String?,
      readReceipts: (json['readReceipts'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, DateTime.parse(e as String)),
          ) ??
          const {},
      reactions: (json['reactions'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      isEdited: json['isEdited'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
      isPinned: json['isPinned'] as bool? ?? false,
      isStarred: json['isStarred'] as bool? ?? false,
      isForwarded: json['isForwarded'] as bool? ?? false,
      isSelfDestructing: json['isSelfDestructing'] as bool? ?? false,
      selfDestructTime: json['selfDestructTime'] == null
          ? null
          : DateTime.parse(json['selfDestructTime'] as String),
      quotedMessageId: json['quotedMessageId'] as String?,
      quotedMessageContent: json['quotedMessageContent'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationName: json['locationName'] as String?,
      contactName: json['contactName'] as String?,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
    );

Map<String, dynamic> _$MessageModelToJson(_MessageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'chatId': instance.chatId,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderProfileImage': instance.senderProfileImage,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'status': _$MessageStatusEnumMap[instance.status]!,
      'timestamp': instance.timestamp.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'mediaUrl': instance.mediaUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'fileName': instance.fileName,
      'fileSize': instance.fileSize,
      'replyToMessageId': instance.replyToMessageId,
      'forwardedFromUserId': instance.forwardedFromUserId,
      'forwardedFromChatId': instance.forwardedFromChatId,
      'readReceipts':
          instance.readReceipts.map((k, e) => MapEntry(k, e.toIso8601String())),
      'reactions': instance.reactions,
      'isEdited': instance.isEdited,
      'isDeleted': instance.isDeleted,
      'isPinned': instance.isPinned,
      'isStarred': instance.isStarred,
      'isForwarded': instance.isForwarded,
      'isSelfDestructing': instance.isSelfDestructing,
      'selfDestructTime': instance.selfDestructTime?.toIso8601String(),
      'quotedMessageId': instance.quotedMessageId,
      'quotedMessageContent': instance.quotedMessageContent,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'locationName': instance.locationName,
      'contactName': instance.contactName,
      'contactPhone': instance.contactPhone,
      'contactEmail': instance.contactEmail,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.video: 'video',
  MessageType.audio: 'audio',
  MessageType.gif: 'gif',
  MessageType.file: 'file',
  MessageType.richText: 'richText',
  MessageType.location: 'location',
  MessageType.contact: 'contact',
  MessageType.sticker: 'sticker',
};

const _$MessageStatusEnumMap = {
  MessageStatus.draft: 'draft',
  MessageStatus.sending: 'sending',
  MessageStatus.delivered: 'delivered',
  MessageStatus.failed: 'failed',
  MessageStatus.read: 'read',
};
