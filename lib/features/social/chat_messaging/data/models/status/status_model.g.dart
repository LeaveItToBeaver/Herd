// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'status_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatusModel _$StatusModelFromJson(Map<String, dynamic> json) => _StatusModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String?,
      userProfileImage: json['userProfileImage'] as String?,
      type: $enumDecode(_$StatusTypeEnumMap, json['type']),
      mediaUrl: json['mediaUrl'] as String?,
      text: json['text'] as String?,
      caption: json['caption'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      expiresAt: DateTime.parse(json['expiresAt'] as String),
      viewedBy: (json['viewedBy'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      allowedViewers: (json['allowedViewers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      excludedViewers: (json['excludedViewers'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      privacy: $enumDecode(_$StatusPrivacyEnumMap, json['privacy']),
      isArchived: json['isArchived'] as bool? ?? false,
      viewCount: (json['viewCount'] as num?)?.toInt() ?? 0,
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      fontStyle: json['fontStyle'] as String?,
    );

Map<String, dynamic> _$StatusModelToJson(_StatusModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userName': instance.userName,
      'userProfileImage': instance.userProfileImage,
      'type': _$StatusTypeEnumMap[instance.type]!,
      'mediaUrl': instance.mediaUrl,
      'text': instance.text,
      'caption': instance.caption,
      'createdAt': instance.createdAt.toIso8601String(),
      'expiresAt': instance.expiresAt.toIso8601String(),
      'viewedBy': instance.viewedBy,
      'allowedViewers': instance.allowedViewers,
      'excludedViewers': instance.excludedViewers,
      'privacy': _$StatusPrivacyEnumMap[instance.privacy]!,
      'isArchived': instance.isArchived,
      'viewCount': instance.viewCount,
      'backgroundColor': instance.backgroundColor,
      'textColor': instance.textColor,
      'fontStyle': instance.fontStyle,
    };

const _$StatusTypeEnumMap = {
  StatusType.image: 'image',
  StatusType.video: 'video',
  StatusType.text: 'text',
  StatusType.gif: 'gif',
  StatusType.audio: 'audio',
};

const _$StatusPrivacyEnumMap = {
  StatusPrivacy.everyone: 'everyone',
  StatusPrivacy.contacts: 'contacts',
  StatusPrivacy.selected: 'selected',
  StatusPrivacy.exceptSelected: 'exceptSelected',
};
