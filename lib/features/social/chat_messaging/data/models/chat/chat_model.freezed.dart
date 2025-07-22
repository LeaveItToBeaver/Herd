// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatModel implements DiagnosticableTreeMixin {
  String get id; // For 1-on-1 chats - the other user's info
  String? get otherUserId;
  String? get otherUserName;
  String? get otherUserUsername;
  String? get otherUserProfileImage;
  String? get otherUserAltProfileImage;
  bool get otherUserIsAlt; // Common chat properties
  String? get lastMessage;
  DateTime? get lastMessageTimestamp;
  int get unreadCount;
  bool get isGroupChat;
  bool get isMuted;
  bool get isArchived;
  bool get isPinned; // Group chat reference
  String? get groupId;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatModelCopyWith<ChatModel> get copyWith =>
      _$ChatModelCopyWithImpl<ChatModel>(this as ChatModel, _$identity);

  /// Serializes this ChatModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ChatModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('otherUserId', otherUserId))
      ..add(DiagnosticsProperty('otherUserName', otherUserName))
      ..add(DiagnosticsProperty('otherUserUsername', otherUserUsername))
      ..add(DiagnosticsProperty('otherUserProfileImage', otherUserProfileImage))
      ..add(DiagnosticsProperty(
          'otherUserAltProfileImage', otherUserAltProfileImage))
      ..add(DiagnosticsProperty('otherUserIsAlt', otherUserIsAlt))
      ..add(DiagnosticsProperty('lastMessage', lastMessage))
      ..add(DiagnosticsProperty('lastMessageTimestamp', lastMessageTimestamp))
      ..add(DiagnosticsProperty('unreadCount', unreadCount))
      ..add(DiagnosticsProperty('isGroupChat', isGroupChat))
      ..add(DiagnosticsProperty('isMuted', isMuted))
      ..add(DiagnosticsProperty('isArchived', isArchived))
      ..add(DiagnosticsProperty('isPinned', isPinned))
      ..add(DiagnosticsProperty('groupId', groupId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserUsername, otherUserUsername) ||
                other.otherUserUsername == otherUserUsername) &&
            (identical(other.otherUserProfileImage, otherUserProfileImage) ||
                other.otherUserProfileImage == otherUserProfileImage) &&
            (identical(
                    other.otherUserAltProfileImage, otherUserAltProfileImage) ||
                other.otherUserAltProfileImage == otherUserAltProfileImage) &&
            (identical(other.otherUserIsAlt, otherUserIsAlt) ||
                other.otherUserIsAlt == otherUserIsAlt) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTimestamp, lastMessageTimestamp) ||
                other.lastMessageTimestamp == lastMessageTimestamp) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isGroupChat, isGroupChat) ||
                other.isGroupChat == isGroupChat) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.groupId, groupId) || other.groupId == groupId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      otherUserId,
      otherUserName,
      otherUserUsername,
      otherUserProfileImage,
      otherUserAltProfileImage,
      otherUserIsAlt,
      lastMessage,
      lastMessageTimestamp,
      unreadCount,
      isGroupChat,
      isMuted,
      isArchived,
      isPinned,
      groupId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatModel(id: $id, otherUserId: $otherUserId, otherUserName: $otherUserName, otherUserUsername: $otherUserUsername, otherUserProfileImage: $otherUserProfileImage, otherUserAltProfileImage: $otherUserAltProfileImage, otherUserIsAlt: $otherUserIsAlt, lastMessage: $lastMessage, lastMessageTimestamp: $lastMessageTimestamp, unreadCount: $unreadCount, isGroupChat: $isGroupChat, isMuted: $isMuted, isArchived: $isArchived, isPinned: $isPinned, groupId: $groupId)';
  }
}

/// @nodoc
abstract mixin class $ChatModelCopyWith<$Res> {
  factory $ChatModelCopyWith(ChatModel value, $Res Function(ChatModel) _then) =
      _$ChatModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? otherUserId,
      String? otherUserName,
      String? otherUserUsername,
      String? otherUserProfileImage,
      String? otherUserAltProfileImage,
      bool otherUserIsAlt,
      String? lastMessage,
      DateTime? lastMessageTimestamp,
      int unreadCount,
      bool isGroupChat,
      bool isMuted,
      bool isArchived,
      bool isPinned,
      String? groupId});
}

/// @nodoc
class _$ChatModelCopyWithImpl<$Res> implements $ChatModelCopyWith<$Res> {
  _$ChatModelCopyWithImpl(this._self, this._then);

  final ChatModel _self;
  final $Res Function(ChatModel) _then;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? otherUserId = freezed,
    Object? otherUserName = freezed,
    Object? otherUserUsername = freezed,
    Object? otherUserProfileImage = freezed,
    Object? otherUserAltProfileImage = freezed,
    Object? otherUserIsAlt = null,
    Object? lastMessage = freezed,
    Object? lastMessageTimestamp = freezed,
    Object? unreadCount = null,
    Object? isGroupChat = null,
    Object? isMuted = null,
    Object? isArchived = null,
    Object? isPinned = null,
    Object? groupId = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserId: freezed == otherUserId
          ? _self.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserName: freezed == otherUserName
          ? _self.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserUsername: freezed == otherUserUsername
          ? _self.otherUserUsername
          : otherUserUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserProfileImage: freezed == otherUserProfileImage
          ? _self.otherUserProfileImage
          : otherUserProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserAltProfileImage: freezed == otherUserAltProfileImage
          ? _self.otherUserAltProfileImage
          : otherUserAltProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserIsAlt: null == otherUserIsAlt
          ? _self.otherUserIsAlt
          : otherUserIsAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: freezed == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTimestamp: freezed == lastMessageTimestamp
          ? _self.lastMessageTimestamp
          : lastMessageTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGroupChat: null == isGroupChat
          ? _self.isGroupChat
          : isGroupChat // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isPinned: null == isPinned
          ? _self.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: freezed == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [ChatModel].
extension ChatModelPatterns on ChatModel {
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
    TResult Function(_ChatModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatModel() when $default != null:
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
    TResult Function(_ChatModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatModel():
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
    TResult? Function(_ChatModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatModel() when $default != null:
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
            String? otherUserId,
            String? otherUserName,
            String? otherUserUsername,
            String? otherUserProfileImage,
            String? otherUserAltProfileImage,
            bool otherUserIsAlt,
            String? lastMessage,
            DateTime? lastMessageTimestamp,
            int unreadCount,
            bool isGroupChat,
            bool isMuted,
            bool isArchived,
            bool isPinned,
            String? groupId)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatModel() when $default != null:
        return $default(
            _that.id,
            _that.otherUserId,
            _that.otherUserName,
            _that.otherUserUsername,
            _that.otherUserProfileImage,
            _that.otherUserAltProfileImage,
            _that.otherUserIsAlt,
            _that.lastMessage,
            _that.lastMessageTimestamp,
            _that.unreadCount,
            _that.isGroupChat,
            _that.isMuted,
            _that.isArchived,
            _that.isPinned,
            _that.groupId);
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
            String? otherUserId,
            String? otherUserName,
            String? otherUserUsername,
            String? otherUserProfileImage,
            String? otherUserAltProfileImage,
            bool otherUserIsAlt,
            String? lastMessage,
            DateTime? lastMessageTimestamp,
            int unreadCount,
            bool isGroupChat,
            bool isMuted,
            bool isArchived,
            bool isPinned,
            String? groupId)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatModel():
        return $default(
            _that.id,
            _that.otherUserId,
            _that.otherUserName,
            _that.otherUserUsername,
            _that.otherUserProfileImage,
            _that.otherUserAltProfileImage,
            _that.otherUserIsAlt,
            _that.lastMessage,
            _that.lastMessageTimestamp,
            _that.unreadCount,
            _that.isGroupChat,
            _that.isMuted,
            _that.isArchived,
            _that.isPinned,
            _that.groupId);
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
            String? otherUserId,
            String? otherUserName,
            String? otherUserUsername,
            String? otherUserProfileImage,
            String? otherUserAltProfileImage,
            bool otherUserIsAlt,
            String? lastMessage,
            DateTime? lastMessageTimestamp,
            int unreadCount,
            bool isGroupChat,
            bool isMuted,
            bool isArchived,
            bool isPinned,
            String? groupId)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatModel() when $default != null:
        return $default(
            _that.id,
            _that.otherUserId,
            _that.otherUserName,
            _that.otherUserUsername,
            _that.otherUserProfileImage,
            _that.otherUserAltProfileImage,
            _that.otherUserIsAlt,
            _that.lastMessage,
            _that.lastMessageTimestamp,
            _that.unreadCount,
            _that.isGroupChat,
            _that.isMuted,
            _that.isArchived,
            _that.isPinned,
            _that.groupId);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ChatModel extends ChatModel with DiagnosticableTreeMixin {
  _ChatModel(
      {required this.id,
      this.otherUserId,
      this.otherUserName,
      this.otherUserUsername,
      this.otherUserProfileImage,
      this.otherUserAltProfileImage,
      this.otherUserIsAlt = false,
      this.lastMessage,
      this.lastMessageTimestamp,
      this.unreadCount = 0,
      this.isGroupChat = false,
      this.isMuted = false,
      this.isArchived = false,
      this.isPinned = false,
      this.groupId})
      : super._();
  factory _ChatModel.fromJson(Map<String, dynamic> json) =>
      _$ChatModelFromJson(json);

  @override
  final String id;
// For 1-on-1 chats - the other user's info
  @override
  final String? otherUserId;
  @override
  final String? otherUserName;
  @override
  final String? otherUserUsername;
  @override
  final String? otherUserProfileImage;
  @override
  final String? otherUserAltProfileImage;
  @override
  @JsonKey()
  final bool otherUserIsAlt;
// Common chat properties
  @override
  final String? lastMessage;
  @override
  final DateTime? lastMessageTimestamp;
  @override
  @JsonKey()
  final int unreadCount;
  @override
  @JsonKey()
  final bool isGroupChat;
  @override
  @JsonKey()
  final bool isMuted;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final bool isPinned;
// Group chat reference
  @override
  final String? groupId;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatModelCopyWith<_ChatModel> get copyWith =>
      __$ChatModelCopyWithImpl<_ChatModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ChatModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'ChatModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('otherUserId', otherUserId))
      ..add(DiagnosticsProperty('otherUserName', otherUserName))
      ..add(DiagnosticsProperty('otherUserUsername', otherUserUsername))
      ..add(DiagnosticsProperty('otherUserProfileImage', otherUserProfileImage))
      ..add(DiagnosticsProperty(
          'otherUserAltProfileImage', otherUserAltProfileImage))
      ..add(DiagnosticsProperty('otherUserIsAlt', otherUserIsAlt))
      ..add(DiagnosticsProperty('lastMessage', lastMessage))
      ..add(DiagnosticsProperty('lastMessageTimestamp', lastMessageTimestamp))
      ..add(DiagnosticsProperty('unreadCount', unreadCount))
      ..add(DiagnosticsProperty('isGroupChat', isGroupChat))
      ..add(DiagnosticsProperty('isMuted', isMuted))
      ..add(DiagnosticsProperty('isArchived', isArchived))
      ..add(DiagnosticsProperty('isPinned', isPinned))
      ..add(DiagnosticsProperty('groupId', groupId));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.otherUserId, otherUserId) ||
                other.otherUserId == otherUserId) &&
            (identical(other.otherUserName, otherUserName) ||
                other.otherUserName == otherUserName) &&
            (identical(other.otherUserUsername, otherUserUsername) ||
                other.otherUserUsername == otherUserUsername) &&
            (identical(other.otherUserProfileImage, otherUserProfileImage) ||
                other.otherUserProfileImage == otherUserProfileImage) &&
            (identical(
                    other.otherUserAltProfileImage, otherUserAltProfileImage) ||
                other.otherUserAltProfileImage == otherUserAltProfileImage) &&
            (identical(other.otherUserIsAlt, otherUserIsAlt) ||
                other.otherUserIsAlt == otherUserIsAlt) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.lastMessageTimestamp, lastMessageTimestamp) ||
                other.lastMessageTimestamp == lastMessageTimestamp) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isGroupChat, isGroupChat) ||
                other.isGroupChat == isGroupChat) &&
            (identical(other.isMuted, isMuted) || other.isMuted == isMuted) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.groupId, groupId) || other.groupId == groupId));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      otherUserId,
      otherUserName,
      otherUserUsername,
      otherUserProfileImage,
      otherUserAltProfileImage,
      otherUserIsAlt,
      lastMessage,
      lastMessageTimestamp,
      unreadCount,
      isGroupChat,
      isMuted,
      isArchived,
      isPinned,
      groupId);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'ChatModel(id: $id, otherUserId: $otherUserId, otherUserName: $otherUserName, otherUserUsername: $otherUserUsername, otherUserProfileImage: $otherUserProfileImage, otherUserAltProfileImage: $otherUserAltProfileImage, otherUserIsAlt: $otherUserIsAlt, lastMessage: $lastMessage, lastMessageTimestamp: $lastMessageTimestamp, unreadCount: $unreadCount, isGroupChat: $isGroupChat, isMuted: $isMuted, isArchived: $isArchived, isPinned: $isPinned, groupId: $groupId)';
  }
}

/// @nodoc
abstract mixin class _$ChatModelCopyWith<$Res>
    implements $ChatModelCopyWith<$Res> {
  factory _$ChatModelCopyWith(
          _ChatModel value, $Res Function(_ChatModel) _then) =
      __$ChatModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? otherUserId,
      String? otherUserName,
      String? otherUserUsername,
      String? otherUserProfileImage,
      String? otherUserAltProfileImage,
      bool otherUserIsAlt,
      String? lastMessage,
      DateTime? lastMessageTimestamp,
      int unreadCount,
      bool isGroupChat,
      bool isMuted,
      bool isArchived,
      bool isPinned,
      String? groupId});
}

/// @nodoc
class __$ChatModelCopyWithImpl<$Res> implements _$ChatModelCopyWith<$Res> {
  __$ChatModelCopyWithImpl(this._self, this._then);

  final _ChatModel _self;
  final $Res Function(_ChatModel) _then;

  /// Create a copy of ChatModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? otherUserId = freezed,
    Object? otherUserName = freezed,
    Object? otherUserUsername = freezed,
    Object? otherUserProfileImage = freezed,
    Object? otherUserAltProfileImage = freezed,
    Object? otherUserIsAlt = null,
    Object? lastMessage = freezed,
    Object? lastMessageTimestamp = freezed,
    Object? unreadCount = null,
    Object? isGroupChat = null,
    Object? isMuted = null,
    Object? isArchived = null,
    Object? isPinned = null,
    Object? groupId = freezed,
  }) {
    return _then(_ChatModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      otherUserId: freezed == otherUserId
          ? _self.otherUserId
          : otherUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserName: freezed == otherUserName
          ? _self.otherUserName
          : otherUserName // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserUsername: freezed == otherUserUsername
          ? _self.otherUserUsername
          : otherUserUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserProfileImage: freezed == otherUserProfileImage
          ? _self.otherUserProfileImage
          : otherUserProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserAltProfileImage: freezed == otherUserAltProfileImage
          ? _self.otherUserAltProfileImage
          : otherUserAltProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      otherUserIsAlt: null == otherUserIsAlt
          ? _self.otherUserIsAlt
          : otherUserIsAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      lastMessage: freezed == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessageTimestamp: freezed == lastMessageTimestamp
          ? _self.lastMessageTimestamp
          : lastMessageTimestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      unreadCount: null == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int,
      isGroupChat: null == isGroupChat
          ? _self.isGroupChat
          : isGroupChat // ignore: cast_nullable_to_non_nullable
              as bool,
      isMuted: null == isMuted
          ? _self.isMuted
          : isMuted // ignore: cast_nullable_to_non_nullable
              as bool,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      isPinned: null == isPinned
          ? _self.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      groupId: freezed == groupId
          ? _self.groupId
          : groupId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
