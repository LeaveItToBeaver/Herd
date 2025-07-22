import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_settings.freezed.dart';
part 'message_settings.g.dart';

@freezed
abstract class MessageSettings with _$MessageSettings {
  const MessageSettings._();

  factory MessageSettings({
    required String userId,
    @Default(true) bool readReceiptsEnabled,
    @Default(true) bool notificationsEnabled,
    @Default(true) bool soundEnabled,
    @Default(true) bool vibrationEnabled,
    @Default(false) bool doNotDisturbEnabled,
    DateTime? doNotDisturbUntil,
    @Default(true) bool showPreviewInNotifications,
    @Default(false) bool archiveReadChats,
    @Default(24) int autoDeleteMessagesAfterHours, // 0 means disabled
    @Default(true) bool allowGroupInvites,
    @Default(true) bool allowUnknownContacts,
    @Default(false) bool blockScreenshots,
    @Default('Everyone') String whoCanSeeLastSeen, // Everyone, Contacts, Nobody
    @Default('Everyone') String whoCanSeeProfilePhoto, // Everyone, Contacts, Nobody
    @Default('Everyone') String whoCanAddToGroups, // Everyone, Contacts, Nobody
  }) = _MessageSettings;

  factory MessageSettings.fromJson(Map<String, dynamic> json) =>
      _$MessageSettingsFromJson(json);
}
