// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageSettings {
  String get userId;
  bool get readReceiptsEnabled;
  bool get notificationsEnabled;
  bool get soundEnabled;
  bool get vibrationEnabled;
  bool get doNotDisturbEnabled;
  DateTime? get doNotDisturbUntil;
  bool get showPreviewInNotifications;
  bool get archiveReadChats;
  int get autoDeleteMessagesAfterHours; // 0 means disabled
  bool get allowGroupInvites;
  bool get allowUnknownContacts;
  bool get blockScreenshots;
  String get whoCanSeeLastSeen; // Everyone, Contacts, Nobody
  String get whoCanSeeProfilePhoto; // Everyone, Contacts, Nobody
  String get whoCanAddToGroups;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageSettingsCopyWith<MessageSettings> get copyWith =>
      _$MessageSettingsCopyWithImpl<MessageSettings>(
          this as MessageSettings, _$identity);

  /// Serializes this MessageSettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageSettings &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.readReceiptsEnabled, readReceiptsEnabled) ||
                other.readReceiptsEnabled == readReceiptsEnabled) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.doNotDisturbEnabled, doNotDisturbEnabled) ||
                other.doNotDisturbEnabled == doNotDisturbEnabled) &&
            (identical(other.doNotDisturbUntil, doNotDisturbUntil) ||
                other.doNotDisturbUntil == doNotDisturbUntil) &&
            (identical(other.showPreviewInNotifications,
                    showPreviewInNotifications) ||
                other.showPreviewInNotifications ==
                    showPreviewInNotifications) &&
            (identical(other.archiveReadChats, archiveReadChats) ||
                other.archiveReadChats == archiveReadChats) &&
            (identical(other.autoDeleteMessagesAfterHours,
                    autoDeleteMessagesAfterHours) ||
                other.autoDeleteMessagesAfterHours ==
                    autoDeleteMessagesAfterHours) &&
            (identical(other.allowGroupInvites, allowGroupInvites) ||
                other.allowGroupInvites == allowGroupInvites) &&
            (identical(other.allowUnknownContacts, allowUnknownContacts) ||
                other.allowUnknownContacts == allowUnknownContacts) &&
            (identical(other.blockScreenshots, blockScreenshots) ||
                other.blockScreenshots == blockScreenshots) &&
            (identical(other.whoCanSeeLastSeen, whoCanSeeLastSeen) ||
                other.whoCanSeeLastSeen == whoCanSeeLastSeen) &&
            (identical(other.whoCanSeeProfilePhoto, whoCanSeeProfilePhoto) ||
                other.whoCanSeeProfilePhoto == whoCanSeeProfilePhoto) &&
            (identical(other.whoCanAddToGroups, whoCanAddToGroups) ||
                other.whoCanAddToGroups == whoCanAddToGroups));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      readReceiptsEnabled,
      notificationsEnabled,
      soundEnabled,
      vibrationEnabled,
      doNotDisturbEnabled,
      doNotDisturbUntil,
      showPreviewInNotifications,
      archiveReadChats,
      autoDeleteMessagesAfterHours,
      allowGroupInvites,
      allowUnknownContacts,
      blockScreenshots,
      whoCanSeeLastSeen,
      whoCanSeeProfilePhoto,
      whoCanAddToGroups);

  @override
  String toString() {
    return 'MessageSettings(userId: $userId, readReceiptsEnabled: $readReceiptsEnabled, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, doNotDisturbEnabled: $doNotDisturbEnabled, doNotDisturbUntil: $doNotDisturbUntil, showPreviewInNotifications: $showPreviewInNotifications, archiveReadChats: $archiveReadChats, autoDeleteMessagesAfterHours: $autoDeleteMessagesAfterHours, allowGroupInvites: $allowGroupInvites, allowUnknownContacts: $allowUnknownContacts, blockScreenshots: $blockScreenshots, whoCanSeeLastSeen: $whoCanSeeLastSeen, whoCanSeeProfilePhoto: $whoCanSeeProfilePhoto, whoCanAddToGroups: $whoCanAddToGroups)';
  }
}

/// @nodoc
abstract mixin class $MessageSettingsCopyWith<$Res> {
  factory $MessageSettingsCopyWith(
          MessageSettings value, $Res Function(MessageSettings) _then) =
      _$MessageSettingsCopyWithImpl;
  @useResult
  $Res call(
      {String userId,
      bool readReceiptsEnabled,
      bool notificationsEnabled,
      bool soundEnabled,
      bool vibrationEnabled,
      bool doNotDisturbEnabled,
      DateTime? doNotDisturbUntil,
      bool showPreviewInNotifications,
      bool archiveReadChats,
      int autoDeleteMessagesAfterHours,
      bool allowGroupInvites,
      bool allowUnknownContacts,
      bool blockScreenshots,
      String whoCanSeeLastSeen,
      String whoCanSeeProfilePhoto,
      String whoCanAddToGroups});
}

/// @nodoc
class _$MessageSettingsCopyWithImpl<$Res>
    implements $MessageSettingsCopyWith<$Res> {
  _$MessageSettingsCopyWithImpl(this._self, this._then);

  final MessageSettings _self;
  final $Res Function(MessageSettings) _then;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? readReceiptsEnabled = null,
    Object? notificationsEnabled = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? doNotDisturbEnabled = null,
    Object? doNotDisturbUntil = freezed,
    Object? showPreviewInNotifications = null,
    Object? archiveReadChats = null,
    Object? autoDeleteMessagesAfterHours = null,
    Object? allowGroupInvites = null,
    Object? allowUnknownContacts = null,
    Object? blockScreenshots = null,
    Object? whoCanSeeLastSeen = null,
    Object? whoCanSeeProfilePhoto = null,
    Object? whoCanAddToGroups = null,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      readReceiptsEnabled: null == readReceiptsEnabled
          ? _self.readReceiptsEnabled
          : readReceiptsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationsEnabled: null == notificationsEnabled
          ? _self.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      soundEnabled: null == soundEnabled
          ? _self.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrationEnabled: null == vibrationEnabled
          ? _self.vibrationEnabled
          : vibrationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbEnabled: null == doNotDisturbEnabled
          ? _self.doNotDisturbEnabled
          : doNotDisturbEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbUntil: freezed == doNotDisturbUntil
          ? _self.doNotDisturbUntil
          : doNotDisturbUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      showPreviewInNotifications: null == showPreviewInNotifications
          ? _self.showPreviewInNotifications
          : showPreviewInNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      archiveReadChats: null == archiveReadChats
          ? _self.archiveReadChats
          : archiveReadChats // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDeleteMessagesAfterHours: null == autoDeleteMessagesAfterHours
          ? _self.autoDeleteMessagesAfterHours
          : autoDeleteMessagesAfterHours // ignore: cast_nullable_to_non_nullable
              as int,
      allowGroupInvites: null == allowGroupInvites
          ? _self.allowGroupInvites
          : allowGroupInvites // ignore: cast_nullable_to_non_nullable
              as bool,
      allowUnknownContacts: null == allowUnknownContacts
          ? _self.allowUnknownContacts
          : allowUnknownContacts // ignore: cast_nullable_to_non_nullable
              as bool,
      blockScreenshots: null == blockScreenshots
          ? _self.blockScreenshots
          : blockScreenshots // ignore: cast_nullable_to_non_nullable
              as bool,
      whoCanSeeLastSeen: null == whoCanSeeLastSeen
          ? _self.whoCanSeeLastSeen
          : whoCanSeeLastSeen // ignore: cast_nullable_to_non_nullable
              as String,
      whoCanSeeProfilePhoto: null == whoCanSeeProfilePhoto
          ? _self.whoCanSeeProfilePhoto
          : whoCanSeeProfilePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      whoCanAddToGroups: null == whoCanAddToGroups
          ? _self.whoCanAddToGroups
          : whoCanAddToGroups // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [MessageSettings].
extension MessageSettingsPatterns on MessageSettings {
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
    TResult Function(_MessageSettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageSettings() when $default != null:
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
    TResult Function(_MessageSettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageSettings():
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
    TResult? Function(_MessageSettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageSettings() when $default != null:
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
            String userId,
            bool readReceiptsEnabled,
            bool notificationsEnabled,
            bool soundEnabled,
            bool vibrationEnabled,
            bool doNotDisturbEnabled,
            DateTime? doNotDisturbUntil,
            bool showPreviewInNotifications,
            bool archiveReadChats,
            int autoDeleteMessagesAfterHours,
            bool allowGroupInvites,
            bool allowUnknownContacts,
            bool blockScreenshots,
            String whoCanSeeLastSeen,
            String whoCanSeeProfilePhoto,
            String whoCanAddToGroups)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageSettings() when $default != null:
        return $default(
            _that.userId,
            _that.readReceiptsEnabled,
            _that.notificationsEnabled,
            _that.soundEnabled,
            _that.vibrationEnabled,
            _that.doNotDisturbEnabled,
            _that.doNotDisturbUntil,
            _that.showPreviewInNotifications,
            _that.archiveReadChats,
            _that.autoDeleteMessagesAfterHours,
            _that.allowGroupInvites,
            _that.allowUnknownContacts,
            _that.blockScreenshots,
            _that.whoCanSeeLastSeen,
            _that.whoCanSeeProfilePhoto,
            _that.whoCanAddToGroups);
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
            String userId,
            bool readReceiptsEnabled,
            bool notificationsEnabled,
            bool soundEnabled,
            bool vibrationEnabled,
            bool doNotDisturbEnabled,
            DateTime? doNotDisturbUntil,
            bool showPreviewInNotifications,
            bool archiveReadChats,
            int autoDeleteMessagesAfterHours,
            bool allowGroupInvites,
            bool allowUnknownContacts,
            bool blockScreenshots,
            String whoCanSeeLastSeen,
            String whoCanSeeProfilePhoto,
            String whoCanAddToGroups)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageSettings():
        return $default(
            _that.userId,
            _that.readReceiptsEnabled,
            _that.notificationsEnabled,
            _that.soundEnabled,
            _that.vibrationEnabled,
            _that.doNotDisturbEnabled,
            _that.doNotDisturbUntil,
            _that.showPreviewInNotifications,
            _that.archiveReadChats,
            _that.autoDeleteMessagesAfterHours,
            _that.allowGroupInvites,
            _that.allowUnknownContacts,
            _that.blockScreenshots,
            _that.whoCanSeeLastSeen,
            _that.whoCanSeeProfilePhoto,
            _that.whoCanAddToGroups);
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
            String userId,
            bool readReceiptsEnabled,
            bool notificationsEnabled,
            bool soundEnabled,
            bool vibrationEnabled,
            bool doNotDisturbEnabled,
            DateTime? doNotDisturbUntil,
            bool showPreviewInNotifications,
            bool archiveReadChats,
            int autoDeleteMessagesAfterHours,
            bool allowGroupInvites,
            bool allowUnknownContacts,
            bool blockScreenshots,
            String whoCanSeeLastSeen,
            String whoCanSeeProfilePhoto,
            String whoCanAddToGroups)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageSettings() when $default != null:
        return $default(
            _that.userId,
            _that.readReceiptsEnabled,
            _that.notificationsEnabled,
            _that.soundEnabled,
            _that.vibrationEnabled,
            _that.doNotDisturbEnabled,
            _that.doNotDisturbUntil,
            _that.showPreviewInNotifications,
            _that.archiveReadChats,
            _that.autoDeleteMessagesAfterHours,
            _that.allowGroupInvites,
            _that.allowUnknownContacts,
            _that.blockScreenshots,
            _that.whoCanSeeLastSeen,
            _that.whoCanSeeProfilePhoto,
            _that.whoCanAddToGroups);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MessageSettings extends MessageSettings {
  _MessageSettings(
      {required this.userId,
      this.readReceiptsEnabled = true,
      this.notificationsEnabled = true,
      this.soundEnabled = true,
      this.vibrationEnabled = true,
      this.doNotDisturbEnabled = false,
      this.doNotDisturbUntil,
      this.showPreviewInNotifications = true,
      this.archiveReadChats = false,
      this.autoDeleteMessagesAfterHours = 24,
      this.allowGroupInvites = true,
      this.allowUnknownContacts = true,
      this.blockScreenshots = false,
      this.whoCanSeeLastSeen = 'Everyone',
      this.whoCanSeeProfilePhoto = 'Everyone',
      this.whoCanAddToGroups = 'Everyone'})
      : super._();
  factory _MessageSettings.fromJson(Map<String, dynamic> json) =>
      _$MessageSettingsFromJson(json);

  @override
  final String userId;
  @override
  @JsonKey()
  final bool readReceiptsEnabled;
  @override
  @JsonKey()
  final bool notificationsEnabled;
  @override
  @JsonKey()
  final bool soundEnabled;
  @override
  @JsonKey()
  final bool vibrationEnabled;
  @override
  @JsonKey()
  final bool doNotDisturbEnabled;
  @override
  final DateTime? doNotDisturbUntil;
  @override
  @JsonKey()
  final bool showPreviewInNotifications;
  @override
  @JsonKey()
  final bool archiveReadChats;
  @override
  @JsonKey()
  final int autoDeleteMessagesAfterHours;
// 0 means disabled
  @override
  @JsonKey()
  final bool allowGroupInvites;
  @override
  @JsonKey()
  final bool allowUnknownContacts;
  @override
  @JsonKey()
  final bool blockScreenshots;
  @override
  @JsonKey()
  final String whoCanSeeLastSeen;
// Everyone, Contacts, Nobody
  @override
  @JsonKey()
  final String whoCanSeeProfilePhoto;
// Everyone, Contacts, Nobody
  @override
  @JsonKey()
  final String whoCanAddToGroups;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageSettingsCopyWith<_MessageSettings> get copyWith =>
      __$MessageSettingsCopyWithImpl<_MessageSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MessageSettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MessageSettings &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.readReceiptsEnabled, readReceiptsEnabled) ||
                other.readReceiptsEnabled == readReceiptsEnabled) &&
            (identical(other.notificationsEnabled, notificationsEnabled) ||
                other.notificationsEnabled == notificationsEnabled) &&
            (identical(other.soundEnabled, soundEnabled) ||
                other.soundEnabled == soundEnabled) &&
            (identical(other.vibrationEnabled, vibrationEnabled) ||
                other.vibrationEnabled == vibrationEnabled) &&
            (identical(other.doNotDisturbEnabled, doNotDisturbEnabled) ||
                other.doNotDisturbEnabled == doNotDisturbEnabled) &&
            (identical(other.doNotDisturbUntil, doNotDisturbUntil) ||
                other.doNotDisturbUntil == doNotDisturbUntil) &&
            (identical(other.showPreviewInNotifications,
                    showPreviewInNotifications) ||
                other.showPreviewInNotifications ==
                    showPreviewInNotifications) &&
            (identical(other.archiveReadChats, archiveReadChats) ||
                other.archiveReadChats == archiveReadChats) &&
            (identical(other.autoDeleteMessagesAfterHours,
                    autoDeleteMessagesAfterHours) ||
                other.autoDeleteMessagesAfterHours ==
                    autoDeleteMessagesAfterHours) &&
            (identical(other.allowGroupInvites, allowGroupInvites) ||
                other.allowGroupInvites == allowGroupInvites) &&
            (identical(other.allowUnknownContacts, allowUnknownContacts) ||
                other.allowUnknownContacts == allowUnknownContacts) &&
            (identical(other.blockScreenshots, blockScreenshots) ||
                other.blockScreenshots == blockScreenshots) &&
            (identical(other.whoCanSeeLastSeen, whoCanSeeLastSeen) ||
                other.whoCanSeeLastSeen == whoCanSeeLastSeen) &&
            (identical(other.whoCanSeeProfilePhoto, whoCanSeeProfilePhoto) ||
                other.whoCanSeeProfilePhoto == whoCanSeeProfilePhoto) &&
            (identical(other.whoCanAddToGroups, whoCanAddToGroups) ||
                other.whoCanAddToGroups == whoCanAddToGroups));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      readReceiptsEnabled,
      notificationsEnabled,
      soundEnabled,
      vibrationEnabled,
      doNotDisturbEnabled,
      doNotDisturbUntil,
      showPreviewInNotifications,
      archiveReadChats,
      autoDeleteMessagesAfterHours,
      allowGroupInvites,
      allowUnknownContacts,
      blockScreenshots,
      whoCanSeeLastSeen,
      whoCanSeeProfilePhoto,
      whoCanAddToGroups);

  @override
  String toString() {
    return 'MessageSettings(userId: $userId, readReceiptsEnabled: $readReceiptsEnabled, notificationsEnabled: $notificationsEnabled, soundEnabled: $soundEnabled, vibrationEnabled: $vibrationEnabled, doNotDisturbEnabled: $doNotDisturbEnabled, doNotDisturbUntil: $doNotDisturbUntil, showPreviewInNotifications: $showPreviewInNotifications, archiveReadChats: $archiveReadChats, autoDeleteMessagesAfterHours: $autoDeleteMessagesAfterHours, allowGroupInvites: $allowGroupInvites, allowUnknownContacts: $allowUnknownContacts, blockScreenshots: $blockScreenshots, whoCanSeeLastSeen: $whoCanSeeLastSeen, whoCanSeeProfilePhoto: $whoCanSeeProfilePhoto, whoCanAddToGroups: $whoCanAddToGroups)';
  }
}

/// @nodoc
abstract mixin class _$MessageSettingsCopyWith<$Res>
    implements $MessageSettingsCopyWith<$Res> {
  factory _$MessageSettingsCopyWith(
          _MessageSettings value, $Res Function(_MessageSettings) _then) =
      __$MessageSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String userId,
      bool readReceiptsEnabled,
      bool notificationsEnabled,
      bool soundEnabled,
      bool vibrationEnabled,
      bool doNotDisturbEnabled,
      DateTime? doNotDisturbUntil,
      bool showPreviewInNotifications,
      bool archiveReadChats,
      int autoDeleteMessagesAfterHours,
      bool allowGroupInvites,
      bool allowUnknownContacts,
      bool blockScreenshots,
      String whoCanSeeLastSeen,
      String whoCanSeeProfilePhoto,
      String whoCanAddToGroups});
}

/// @nodoc
class __$MessageSettingsCopyWithImpl<$Res>
    implements _$MessageSettingsCopyWith<$Res> {
  __$MessageSettingsCopyWithImpl(this._self, this._then);

  final _MessageSettings _self;
  final $Res Function(_MessageSettings) _then;

  /// Create a copy of MessageSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? readReceiptsEnabled = null,
    Object? notificationsEnabled = null,
    Object? soundEnabled = null,
    Object? vibrationEnabled = null,
    Object? doNotDisturbEnabled = null,
    Object? doNotDisturbUntil = freezed,
    Object? showPreviewInNotifications = null,
    Object? archiveReadChats = null,
    Object? autoDeleteMessagesAfterHours = null,
    Object? allowGroupInvites = null,
    Object? allowUnknownContacts = null,
    Object? blockScreenshots = null,
    Object? whoCanSeeLastSeen = null,
    Object? whoCanSeeProfilePhoto = null,
    Object? whoCanAddToGroups = null,
  }) {
    return _then(_MessageSettings(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      readReceiptsEnabled: null == readReceiptsEnabled
          ? _self.readReceiptsEnabled
          : readReceiptsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      notificationsEnabled: null == notificationsEnabled
          ? _self.notificationsEnabled
          : notificationsEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      soundEnabled: null == soundEnabled
          ? _self.soundEnabled
          : soundEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      vibrationEnabled: null == vibrationEnabled
          ? _self.vibrationEnabled
          : vibrationEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbEnabled: null == doNotDisturbEnabled
          ? _self.doNotDisturbEnabled
          : doNotDisturbEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      doNotDisturbUntil: freezed == doNotDisturbUntil
          ? _self.doNotDisturbUntil
          : doNotDisturbUntil // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      showPreviewInNotifications: null == showPreviewInNotifications
          ? _self.showPreviewInNotifications
          : showPreviewInNotifications // ignore: cast_nullable_to_non_nullable
              as bool,
      archiveReadChats: null == archiveReadChats
          ? _self.archiveReadChats
          : archiveReadChats // ignore: cast_nullable_to_non_nullable
              as bool,
      autoDeleteMessagesAfterHours: null == autoDeleteMessagesAfterHours
          ? _self.autoDeleteMessagesAfterHours
          : autoDeleteMessagesAfterHours // ignore: cast_nullable_to_non_nullable
              as int,
      allowGroupInvites: null == allowGroupInvites
          ? _self.allowGroupInvites
          : allowGroupInvites // ignore: cast_nullable_to_non_nullable
              as bool,
      allowUnknownContacts: null == allowUnknownContacts
          ? _self.allowUnknownContacts
          : allowUnknownContacts // ignore: cast_nullable_to_non_nullable
              as bool,
      blockScreenshots: null == blockScreenshots
          ? _self.blockScreenshots
          : blockScreenshots // ignore: cast_nullable_to_non_nullable
              as bool,
      whoCanSeeLastSeen: null == whoCanSeeLastSeen
          ? _self.whoCanSeeLastSeen
          : whoCanSeeLastSeen // ignore: cast_nullable_to_non_nullable
              as String,
      whoCanSeeProfilePhoto: null == whoCanSeeProfilePhoto
          ? _self.whoCanSeeProfilePhoto
          : whoCanSeeProfilePhoto // ignore: cast_nullable_to_non_nullable
              as String,
      whoCanAddToGroups: null == whoCanAddToGroups
          ? _self.whoCanAddToGroups
          : whoCanAddToGroups // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

// dart format on
