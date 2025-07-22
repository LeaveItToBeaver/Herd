// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group_messaging.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GroupMessaging implements DiagnosticableTreeMixin {
  String get id;
  String get name;
  String? get description;
  String? get groupImage;
  List<String> get participants;
  String get adminId;
  String? get adminName;
  String? get adminUsername;
  List<String>? get moderatorIds;
  List<String>? get bannedUserIds;
  bool get isPrivate;
  bool get allowMembersToAddOthers;
  bool get allowMembersToEditGroupInfo;
  DateTime? get createdAt;
  DateTime? get updatedAt;
  int get maxParticipants;
  String? get inviteLink;
  bool get isArchived;
  bool get isMuted;
  String? get lastMessage;
  DateTime? get lastMessageTimestamp;

  /// Create a copy of GroupMessaging
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $GroupMessagingCopyWith<GroupMessaging> get copyWith =>
      _$GroupMessagingCopyWithImpl<GroupMessaging>(
          this as GroupMessaging, _$identity);

  /// Serializes this GroupMessaging to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GroupMessaging'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('groupImage', groupImage))
      ..add(DiagnosticsProperty('participants', participants))
      ..add(DiagnosticsProperty('adminId', adminId))
      ..add(DiagnosticsProperty('adminName', adminName))
      ..add(DiagnosticsProperty('adminUsername', adminUsername))
      ..add(DiagnosticsProperty('moderatorIds', moderatorIds))
      ..add(DiagnosticsProperty('bannedUserIds', bannedUserIds))
      ..add(DiagnosticsProperty('isPrivate', isPrivate))
      ..add(DiagnosticsProperty(
          'allowMembersToAddOthers', allowMembersToAddOthers))
      ..add(DiagnosticsProperty(
          'allowMembersToEditGroupInfo', allowMembersToEditGroupInfo))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('maxParticipants', maxParticipants))
      ..add(DiagnosticsProperty('inviteLink', inviteLink))
      ..add(DiagnosticsProperty('isArchived', isArchived))
      ..add(DiagnosticsProperty('isMuted', isMuted))
      ..add(DiagnosticsProperty('lastMessage', lastMessage))
      ..add(DiagnosticsProperty('lastMessageTimestamp', lastMessageTimestamp));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is GroupMessaging &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.groupImage, groupImage) ||
                other.groupImage == groupImage) &&
            const DeepCollectionEquality()
                .equals(other.participants, participants) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            (identical(other.adminName, adminName) ||
                other.adminName == adminName) &&
            (identical(other.adminUsername, adminUsername) ||
                other.adminUsername == adminUsername) &&
            const DeepCollectionEquality()
                .equals(other.moderatorIds, moderatorIds) &&
            const DeepCollectionEquality()
                .equals(other.bannedUserIds, bannedUserIds) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(
                    other.allowMembersToAddOthers, allowMembersToAddOthers) ||
                other.allowMembersToAddOthers == allowMembersToAddOthers) &&
            (identical(other.allowMembersToEditGroupInfo,
                    allowMembersToEditGroupInfo) ||
                other.allowMembersToEditGroupInfo ==
                    allowMembersToEditGroupInfo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.inviteLink, inviteLink) ||
                other.inviteLink == inviteLink) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTimestamp, lastMessageTimestamp) ||
                other.lastMessageTimestamp == lastMessageTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        groupImage,
        const DeepCollectionEquality().hash(participants),
        adminId,
        adminName,
        adminUsername,
        const DeepCollectionEquality().hash(moderatorIds),
        const DeepCollectionEquality().hash(bannedUserIds),
        isPrivate,
        allowMembersToAddOthers,
        allowMembersToEditGroupInfo,
        createdAt,
        updatedAt,
        maxParticipants,
        inviteLink,
        isArchived,
        isMuted,
        lastMessage,
        lastMessageTimestamp
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GroupMessaging(id: $id, name: $name, description: $description, groupImage: $groupImage, participants: $participants, adminId: $adminId, adminName: $adminName, adminUsername: $adminUsername, moderatorIds: $moderatorIds, bannedUserIds: $bannedUserIds, isPrivate: $isPrivate, allowMembersToAddOthers: $allowMembersToAddOthers, allowMembersToEditGroupInfo: $allowMembersToEditGroupInfo, createdAt: $createdAt, updatedAt: $updatedAt, maxParticipants: $maxParticipants, inviteLink: $inviteLink, isArchived: $isArchived, isMuted: $isMuted, lastMessage: $lastMessage, lastMessageTimestamp: $lastMessageTimestamp)';
  }
}

/// @nodoc
abstract mixin class $GroupMessagingCopyWith<$Res> {
  factory $GroupMessagingCopyWith(
          GroupMessaging value, $Res Function(GroupMessaging) _then) =
      _$GroupMessagingCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? groupImage,
      List<String> participants,
      String adminId,
      String? adminName,
      String? adminUsername,
      List<String>? moderatorIds,
      List<String>? bannedUserIds,
      bool isPrivate,
      bool allowMembersToAddOthers,
      bool allowMembersToEditGroupInfo,
      DateTime? createdAt,
      DateTime? updatedAt,
      int maxParticipants,
      String? inviteLink,
      bool isArchived,
      bool isMuted,
      String? lastMessage,
      DateTime? lastMessageTimestamp});
}

/// @nodoc
class _$GroupMessagingCopyWithImpl<$Res>
    implements $GroupMessagingCopyWith<$Res> {
  _$GroupMessagingCopyWithImpl(this._self, this._then);

  final GroupMessaging _self;
  final $Res Function(GroupMessaging) _then;

  /// Create a copy of GroupMessaging
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? groupImage = freezed,
    Object? participants = null,
    Object? adminId = null,
    Object? adminName = freezed,
    Object? adminUsername = freezed,
    Object? moderatorIds = freezed,
    Object? bannedUserIds = freezed,
    Object? isPrivate = null,
    Object? allowMembersToAddOthers = null,
    Object? allowMembersToEditGroupInfo = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? maxParticipants = null,
    Object? inviteLink = freezed,
    Object? isArchived = null,
    Object? isMuted = null,
    Object? lastMessage = freezed,
    Object? lastMessageTimestamp = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      groupImage: freezed == groupImage
          ? _self.groupImage
          : groupImage // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _self.participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      adminId: null == adminId
          ? _self.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      adminName: freezed == adminName
          ? _self.adminName
          : adminName // ignore: cast_nullable_to_non_nullable
              as String?,
      adminUsername: freezed == adminUsername
          ? _self.adminUsername
          : adminUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      moderatorIds: freezed == moderatorIds
          ? _self.moderatorIds
          : moderatorIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      bannedUserIds: freezed == bannedUserIds
          ? _self.bannedUserIds
          : bannedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isPrivate: null == isPrivate
          ? _self.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMembersToAddOthers: null == allowMembersToAddOthers
          ? _self.allowMembersToAddOthers
          : allowMembersToAddOthers // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMembersToEditGroupInfo: null == allowMembersToEditGroupInfo
          ? _self.allowMembersToEditGroupInfo
          : allowMembersToEditGroupInfo // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxParticipants: null == maxParticipants
          ? _self.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      inviteLink: freezed == inviteLink
          ? _self.inviteLink
          : inviteLink // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: freezed == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTimestamp: freezed == lastMessageTimestamp
          ? _self.lastMessageTimestamp
          : lastMessageTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// Adds pattern-matching-related methods to [GroupMessaging].
extension GroupMessagingPatterns on GroupMessaging {
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
    TResult Function(_GroupMessaging value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupMessaging() when $default != null:
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
    TResult Function(_GroupMessaging value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMessaging():
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
    TResult? Function(_GroupMessaging value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMessaging() when $default != null:
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
            String name,
            String? description,
            String? groupImage,
            List<String> participants,
            String adminId,
            String? adminName,
            String? adminUsername,
            List<String>? moderatorIds,
            List<String>? bannedUserIds,
            bool isPrivate,
            bool allowMembersToAddOthers,
            bool allowMembersToEditGroupInfo,
            DateTime? createdAt,
            DateTime? updatedAt,
            int maxParticipants,
            String? inviteLink,
            bool isArchived,
            bool isMuted,
            String? lastMessage,
            DateTime? lastMessageTimestamp)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _GroupMessaging() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.groupImage,
            _that.participants,
            _that.adminId,
            _that.adminName,
            _that.adminUsername,
            _that.moderatorIds,
            _that.bannedUserIds,
            _that.isPrivate,
            _that.allowMembersToAddOthers,
            _that.allowMembersToEditGroupInfo,
            _that.createdAt,
            _that.updatedAt,
            _that.maxParticipants,
            _that.inviteLink,
            _that.isArchived,
            _that.isMuted,
            _that.lastMessage,
            _that.lastMessageTimestamp);
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
            String name,
            String? description,
            String? groupImage,
            List<String> participants,
            String adminId,
            String? adminName,
            String? adminUsername,
            List<String>? moderatorIds,
            List<String>? bannedUserIds,
            bool isPrivate,
            bool allowMembersToAddOthers,
            bool allowMembersToEditGroupInfo,
            DateTime? createdAt,
            DateTime? updatedAt,
            int maxParticipants,
            String? inviteLink,
            bool isArchived,
            bool isMuted,
            String? lastMessage,
            DateTime? lastMessageTimestamp)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMessaging():
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.groupImage,
            _that.participants,
            _that.adminId,
            _that.adminName,
            _that.adminUsername,
            _that.moderatorIds,
            _that.bannedUserIds,
            _that.isPrivate,
            _that.allowMembersToAddOthers,
            _that.allowMembersToEditGroupInfo,
            _that.createdAt,
            _that.updatedAt,
            _that.maxParticipants,
            _that.inviteLink,
            _that.isArchived,
            _that.isMuted,
            _that.lastMessage,
            _that.lastMessageTimestamp);
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
            String name,
            String? description,
            String? groupImage,
            List<String> participants,
            String adminId,
            String? adminName,
            String? adminUsername,
            List<String>? moderatorIds,
            List<String>? bannedUserIds,
            bool isPrivate,
            bool allowMembersToAddOthers,
            bool allowMembersToEditGroupInfo,
            DateTime? createdAt,
            DateTime? updatedAt,
            int maxParticipants,
            String? inviteLink,
            bool isArchived,
            bool isMuted,
            String? lastMessage,
            DateTime? lastMessageTimestamp)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _GroupMessaging() when $default != null:
        return $default(
            _that.id,
            _that.name,
            _that.description,
            _that.groupImage,
            _that.participants,
            _that.adminId,
            _that.adminName,
            _that.adminUsername,
            _that.moderatorIds,
            _that.bannedUserIds,
            _that.isPrivate,
            _that.allowMembersToAddOthers,
            _that.allowMembersToEditGroupInfo,
            _that.createdAt,
            _that.updatedAt,
            _that.maxParticipants,
            _that.inviteLink,
            _that.isArchived,
            _that.isMuted,
            _that.lastMessage,
            _that.lastMessageTimestamp);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _GroupMessaging extends GroupMessaging with DiagnosticableTreeMixin {
  _GroupMessaging(
      {required this.id,
      required this.name,
      this.description,
      this.groupImage,
      required final List<String> participants,
      required this.adminId,
      this.adminName,
      this.adminUsername,
      final List<String>? moderatorIds,
      final List<String>? bannedUserIds,
      this.isPrivate = false,
      this.allowMembersToAddOthers = true,
      this.allowMembersToEditGroupInfo = true,
      this.createdAt,
      this.updatedAt,
      this.maxParticipants = 0,
      this.inviteLink,
      this.isArchived = false,
      this.isMuted = false,
      this.lastMessage,
      this.lastMessageTimestamp})
      : _participants = participants,
        _moderatorIds = moderatorIds,
        _bannedUserIds = bannedUserIds,
        super._();
  factory _GroupMessaging.fromJson(Map<String, dynamic> json) =>
      _$GroupMessagingFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? groupImage;
  final List<String> _participants;
  @override
  List<String> get participants {
    if (_participants is EqualUnmodifiableListView) return _participants;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_participants);
  }

  @override
  final String adminId;
  @override
  final String? adminName;
  @override
  final String? adminUsername;
  final List<String>? _moderatorIds;
  @override
  List<String>? get moderatorIds {
    final value = _moderatorIds;
    if (value == null) return null;
    if (_moderatorIds is EqualUnmodifiableListView) return _moderatorIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  final List<String>? _bannedUserIds;
  @override
  List<String>? get bannedUserIds {
    final value = _bannedUserIds;
    if (value == null) return null;
    if (_bannedUserIds is EqualUnmodifiableListView) return _bannedUserIds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  @JsonKey()
  final bool isPrivate;
  @override
  @JsonKey()
  final bool allowMembersToAddOthers;
  @override
  @JsonKey()
  final bool allowMembersToEditGroupInfo;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? updatedAt;
  @override
  @JsonKey()
  final int maxParticipants;
  @override
  final String? inviteLink;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  final String? lastMessage;
  @override
  final DateTime? lastMessageTimestamp;

  /// Create a copy of GroupMessaging
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$GroupMessagingCopyWith<_GroupMessaging> get copyWith =>
      __$GroupMessagingCopyWithImpl<_GroupMessaging>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$GroupMessagingToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'GroupMessaging'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('name', name))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('groupImage', groupImage))
      ..add(DiagnosticsProperty('participants', participants))
      ..add(DiagnosticsProperty('adminId', adminId))
      ..add(DiagnosticsProperty('adminName', adminName))
      ..add(DiagnosticsProperty('adminUsername', adminUsername))
      ..add(DiagnosticsProperty('moderatorIds', moderatorIds))
      ..add(DiagnosticsProperty('bannedUserIds', bannedUserIds))
      ..add(DiagnosticsProperty('isPrivate', isPrivate))
      ..add(DiagnosticsProperty(
          'allowMembersToAddOthers', allowMembersToAddOthers))
      ..add(DiagnosticsProperty(
          'allowMembersToEditGroupInfo', allowMembersToEditGroupInfo))
      ..add(DiagnosticsProperty('createdAt', createdAt))
      ..add(DiagnosticsProperty('updatedAt', updatedAt))
      ..add(DiagnosticsProperty('maxParticipants', maxParticipants))
      ..add(DiagnosticsProperty('inviteLink', inviteLink))
      ..add(DiagnosticsProperty('isArchived', isArchived))
      ..add(DiagnosticsProperty('isMuted', isMuted))
      ..add(DiagnosticsProperty('lastMessage', lastMessage))
      ..add(DiagnosticsProperty('lastMessageTimestamp', lastMessageTimestamp));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _GroupMessaging &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.groupImage, groupImage) ||
                other.groupImage == groupImage) &&
            const DeepCollectionEquality()
                .equals(other._participants, _participants) &&
            (identical(other.adminId, adminId) || other.adminId == adminId) &&
            (identical(other.adminName, adminName) ||
                other.adminName == adminName) &&
            (identical(other.adminUsername, adminUsername) ||
                other.adminUsername == adminUsername) &&
            const DeepCollectionEquality()
                .equals(other._moderatorIds, _moderatorIds) &&
            const DeepCollectionEquality()
                .equals(other._bannedUserIds, _bannedUserIds) &&
            (identical(other.isPrivate, isPrivate) ||
                other.isPrivate == isPrivate) &&
            (identical(
                    other.allowMembersToAddOthers, allowMembersToAddOthers) ||
                other.allowMembersToAddOthers == allowMembersToAddOthers) &&
            (identical(other.allowMembersToEditGroupInfo,
                    allowMembersToEditGroupInfo) ||
                other.allowMembersToEditGroupInfo ==
                    allowMembersToEditGroupInfo) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.maxParticipants, maxParticipants) ||
                other.maxParticipants == maxParticipants) &&
            (identical(other.inviteLink, inviteLink) ||
                other.inviteLink == inviteLink) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTimestamp, lastMessageTimestamp) ||
                other.lastMessageTimestamp == lastMessageTimestamp));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        name,
        description,
        groupImage,
        const DeepCollectionEquality().hash(_participants),
        adminId,
        adminName,
        adminUsername,
        const DeepCollectionEquality().hash(_moderatorIds),
        const DeepCollectionEquality().hash(_bannedUserIds),
        isPrivate,
        allowMembersToAddOthers,
        allowMembersToEditGroupInfo,
        createdAt,
        updatedAt,
        maxParticipants,
        inviteLink,
        isArchived,
        isMuted,
        lastMessage,
        lastMessageTimestamp
      ]);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'GroupMessaging(id: $id, name: $name, description: $description, groupImage: $groupImage, participants: $participants, adminId: $adminId, adminName: $adminName, adminUsername: $adminUsername, moderatorIds: $moderatorIds, bannedUserIds: $bannedUserIds, isPrivate: $isPrivate, allowMembersToAddOthers: $allowMembersToAddOthers, allowMembersToEditGroupInfo: $allowMembersToEditGroupInfo, createdAt: $createdAt, updatedAt: $updatedAt, maxParticipants: $maxParticipants, inviteLink: $inviteLink, isArchived: $isArchived, isMuted: $isMuted, lastMessage: $lastMessage, lastMessageTimestamp: $lastMessageTimestamp)';
  }
}

/// @nodoc
abstract mixin class _$GroupMessagingCopyWith<$Res>
    implements $GroupMessagingCopyWith<$Res> {
  factory _$GroupMessagingCopyWith(
          _GroupMessaging value, $Res Function(_GroupMessaging) _then) =
      __$GroupMessagingCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String? description,
      String? groupImage,
      List<String> participants,
      String adminId,
      String? adminName,
      String? adminUsername,
      List<String>? moderatorIds,
      List<String>? bannedUserIds,
      bool isPrivate,
      bool allowMembersToAddOthers,
      bool allowMembersToEditGroupInfo,
      DateTime? createdAt,
      DateTime? updatedAt,
      int maxParticipants,
      String? inviteLink,
      bool isArchived,
      bool isMuted,
      String? lastMessage,
      DateTime? lastMessageTimestamp});
}

/// @nodoc
class __$GroupMessagingCopyWithImpl<$Res>
    implements _$GroupMessagingCopyWith<$Res> {
  __$GroupMessagingCopyWithImpl(this._self, this._then);

  final _GroupMessaging _self;
  final $Res Function(_GroupMessaging) _then;

  /// Create a copy of GroupMessaging
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? groupImage = freezed,
    Object? participants = null,
    Object? adminId = null,
    Object? adminName = freezed,
    Object? adminUsername = freezed,
    Object? moderatorIds = freezed,
    Object? bannedUserIds = freezed,
    Object? isPrivate = null,
    Object? allowMembersToAddOthers = null,
    Object? allowMembersToEditGroupInfo = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? maxParticipants = null,
    Object? inviteLink = freezed,
    Object? isArchived = null,
    Object? isMuted = null,
    Object? lastMessage = freezed,
    Object? lastMessageTimestamp = freezed,
  }) {
    return _then(_GroupMessaging(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _self.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _self.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      groupImage: freezed == groupImage
          ? _self.groupImage
          : groupImage // ignore: cast_nullable_to_non_nullable
              as String?,
      participants: null == participants
          ? _self._participants
          : participants // ignore: cast_nullable_to_non_nullable
              as List<String>,
      adminId: null == adminId
          ? _self.adminId
          : adminId // ignore: cast_nullable_to_non_nullable
              as String,
      adminName: freezed == adminName
          ? _self.adminName
          : adminName // ignore: cast_nullable_to_non_nullable
              as String?,
      adminUsername: freezed == adminUsername
          ? _self.adminUsername
          : adminUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      moderatorIds: freezed == moderatorIds
          ? _self._moderatorIds
          : moderatorIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      bannedUserIds: freezed == bannedUserIds
          ? _self._bannedUserIds
          : bannedUserIds // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      isPrivate: null == isPrivate
          ? _self.isPrivate
          : isPrivate // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMembersToAddOthers: null == allowMembersToAddOthers
          ? _self.allowMembersToAddOthers
          : allowMembersToAddOthers // ignore: cast_nullable_to_non_nullable
              as bool,
      allowMembersToEditGroupInfo: null == allowMembersToEditGroupInfo
          ? _self.allowMembersToEditGroupInfo
          : allowMembersToEditGroupInfo // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: freezed == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      updatedAt: freezed == updatedAt
          ? _self.updatedAt
          : updatedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      maxParticipants: null == maxParticipants
          ? _self.maxParticipants
          : maxParticipants // ignore: cast_nullable_to_non_nullable
              as int,
      inviteLink: freezed == inviteLink
          ? _self.inviteLink
          : inviteLink // ignore: cast_nullable_to_non_nullable
              as String?,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: freezed == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTimestamp: freezed == lastMessageTimestamp
          ? _self.lastMessageTimestamp
          : lastMessageTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

// dart format on
