// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'message_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MessageModel {
  String get id;
  String get chatId;
  String get senderId;
  String? get senderName;
  String? get senderProfileImage;
  String? get content;
  MessageType get type;
  MessageStatus get status;
  DateTime get timestamp;
  DateTime? get editedAt;
  String? get mediaUrl;
  String? get thumbnailUrl;
  String? get fileName;
  int? get fileSize;
  String? get replyToMessageId;
  String? get forwardedFromUserId;
  String?
      get forwardedFromChatId; // Map of userId to timestamp for read receipts
  Map<String, DateTime> get readReceipts; // Map of userId to reaction emoji
  Map<String, String> get reactions;
  bool get isEdited;
  bool get isDeleted;
  DateTime? get deletedAt;
  String? get deletedBy;
  bool get isPinned;
  bool get isStarred;
  bool get isForwarded;
  bool get isSelfDestructing;
  DateTime? get selfDestructTime;
  String? get quotedMessageId;
  String? get quotedMessageContent; // Location data for location messages
  double? get latitude;
  double? get longitude;
  String? get locationName; // Contact data for contact messages
  String? get contactName;
  String? get contactPhone;
  String? get contactEmail;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageModelCopyWith<MessageModel> get copyWith =>
      _$MessageModelCopyWithImpl<MessageModel>(
          this as MessageModel, _$identity);

  /// Serializes this MessageModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderProfileImage, senderProfileImage) ||
                other.senderProfileImage == senderProfileImage) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.forwardedFromUserId, forwardedFromUserId) ||
                other.forwardedFromUserId == forwardedFromUserId) &&
            (identical(other.forwardedFromChatId, forwardedFromChatId) ||
                other.forwardedFromChatId == forwardedFromChatId) &&
            const DeepCollectionEquality()
                .equals(other.readReceipts, readReceipts) &&
            const DeepCollectionEquality().equals(other.reactions, reactions) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.deletedBy, deletedBy) ||
                other.deletedBy == deletedBy) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.isStarred, isStarred) ||
                other.isStarred == isStarred) &&
            (identical(other.isForwarded, isForwarded) ||
                other.isForwarded == isForwarded) &&
            (identical(other.isSelfDestructing, isSelfDestructing) ||
                other.isSelfDestructing == isSelfDestructing) &&
            (identical(other.selfDestructTime, selfDestructTime) ||
                other.selfDestructTime == selfDestructTime) &&
            (identical(other.quotedMessageId, quotedMessageId) ||
                other.quotedMessageId == quotedMessageId) &&
            (identical(other.quotedMessageContent, quotedMessageContent) ||
                other.quotedMessageContent == quotedMessageContent) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        chatId,
        senderId,
        senderName,
        senderProfileImage,
        content,
        type,
        status,
        timestamp,
        editedAt,
        mediaUrl,
        thumbnailUrl,
        fileName,
        fileSize,
        replyToMessageId,
        forwardedFromUserId,
        forwardedFromChatId,
        const DeepCollectionEquality().hash(readReceipts),
        const DeepCollectionEquality().hash(reactions),
        isEdited,
        isDeleted,
        deletedAt,
        deletedBy,
        isPinned,
        isStarred,
        isForwarded,
        isSelfDestructing,
        selfDestructTime,
        quotedMessageId,
        quotedMessageContent,
        latitude,
        longitude,
        locationName,
        contactName,
        contactPhone,
        contactEmail
      ]);

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, senderProfileImage: $senderProfileImage, content: $content, type: $type, status: $status, timestamp: $timestamp, editedAt: $editedAt, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, fileName: $fileName, fileSize: $fileSize, replyToMessageId: $replyToMessageId, forwardedFromUserId: $forwardedFromUserId, forwardedFromChatId: $forwardedFromChatId, readReceipts: $readReceipts, reactions: $reactions, isEdited: $isEdited, isDeleted: $isDeleted, deletedAt: $deletedAt, deletedBy: $deletedBy, isPinned: $isPinned, isStarred: $isStarred, isForwarded: $isForwarded, isSelfDestructing: $isSelfDestructing, selfDestructTime: $selfDestructTime, quotedMessageId: $quotedMessageId, quotedMessageContent: $quotedMessageContent, latitude: $latitude, longitude: $longitude, locationName: $locationName, contactName: $contactName, contactPhone: $contactPhone, contactEmail: $contactEmail)';
  }
}

/// @nodoc
abstract mixin class $MessageModelCopyWith<$Res> {
  factory $MessageModelCopyWith(
          MessageModel value, $Res Function(MessageModel) _then) =
      _$MessageModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String chatId,
      String senderId,
      String? senderName,
      String? senderProfileImage,
      String? content,
      MessageType type,
      MessageStatus status,
      DateTime timestamp,
      DateTime? editedAt,
      String? mediaUrl,
      String? thumbnailUrl,
      String? fileName,
      int? fileSize,
      String? replyToMessageId,
      String? forwardedFromUserId,
      String? forwardedFromChatId,
      Map<String, DateTime> readReceipts,
      Map<String, String> reactions,
      bool isEdited,
      bool isDeleted,
      DateTime? deletedAt,
      String? deletedBy,
      bool isPinned,
      bool isStarred,
      bool isForwarded,
      bool isSelfDestructing,
      DateTime? selfDestructTime,
      String? quotedMessageId,
      String? quotedMessageContent,
      double? latitude,
      double? longitude,
      String? locationName,
      String? contactName,
      String? contactPhone,
      String? contactEmail});
}

/// @nodoc
class _$MessageModelCopyWithImpl<$Res> implements $MessageModelCopyWith<$Res> {
  _$MessageModelCopyWithImpl(this._self, this._then);

  final MessageModel _self;
  final $Res Function(MessageModel) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? senderName = freezed,
    Object? senderProfileImage = freezed,
    Object? content = freezed,
    Object? type = null,
    Object? status = null,
    Object? timestamp = null,
    Object? editedAt = freezed,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? replyToMessageId = freezed,
    Object? forwardedFromUserId = freezed,
    Object? forwardedFromChatId = freezed,
    Object? readReceipts = null,
    Object? reactions = null,
    Object? isEdited = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? deletedBy = freezed,
    Object? isPinned = null,
    Object? isStarred = null,
    Object? isForwarded = null,
    Object? isSelfDestructing = null,
    Object? selfDestructTime = freezed,
    Object? quotedMessageId = freezed,
    Object? quotedMessageContent = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationName = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _self.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: freezed == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderProfileImage: freezed == senderProfileImage
          ? _self.senderProfileImage
          : senderProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _self.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: freezed == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardedFromUserId: freezed == forwardedFromUserId
          ? _self.forwardedFromUserId
          : forwardedFromUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardedFromChatId: freezed == forwardedFromChatId
          ? _self.forwardedFromChatId
          : forwardedFromChatId // ignore: cast_nullable_to_non_nullable
              as String?,
      readReceipts: null == readReceipts
          ? _self.readReceipts
          : readReceipts // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      reactions: null == reactions
          ? _self.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      isEdited: null == isEdited
          ? _self.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleted: null == isDeleted
          ? _self.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedBy: freezed == deletedBy
          ? _self.deletedBy
          : deletedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isPinned: null == isPinned
          ? _self.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      isStarred: null == isStarred
          ? _self.isStarred
          : isStarred // ignore: cast_nullable_to_non_nullable
              as bool,
      isForwarded: null == isForwarded
          ? _self.isForwarded
          : isForwarded // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelfDestructing: null == isSelfDestructing
          ? _self.isSelfDestructing
          : isSelfDestructing // ignore: cast_nullable_to_non_nullable
              as bool,
      selfDestructTime: freezed == selfDestructTime
          ? _self.selfDestructTime
          : selfDestructTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      quotedMessageId: freezed == quotedMessageId
          ? _self.quotedMessageId
          : quotedMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      quotedMessageContent: freezed == quotedMessageContent
          ? _self.quotedMessageContent
          : quotedMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _self.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _self.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _self.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MessageModel].
extension MessageModelPatterns on MessageModel {
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
    TResult Function(_MessageModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageModel() when $default != null:
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
    TResult Function(_MessageModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageModel():
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
    TResult? Function(_MessageModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageModel() when $default != null:
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
            String chatId,
            String senderId,
            String? senderName,
            String? senderProfileImage,
            String? content,
            MessageType type,
            MessageStatus status,
            DateTime timestamp,
            DateTime? editedAt,
            String? mediaUrl,
            String? thumbnailUrl,
            String? fileName,
            int? fileSize,
            String? replyToMessageId,
            String? forwardedFromUserId,
            String? forwardedFromChatId,
            Map<String, DateTime> readReceipts,
            Map<String, String> reactions,
            bool isEdited,
            bool isDeleted,
            DateTime? deletedAt,
            String? deletedBy,
            bool isPinned,
            bool isStarred,
            bool isForwarded,
            bool isSelfDestructing,
            DateTime? selfDestructTime,
            String? quotedMessageId,
            String? quotedMessageContent,
            double? latitude,
            double? longitude,
            String? locationName,
            String? contactName,
            String? contactPhone,
            String? contactEmail)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageModel() when $default != null:
        return $default(
            _that.id,
            _that.chatId,
            _that.senderId,
            _that.senderName,
            _that.senderProfileImage,
            _that.content,
            _that.type,
            _that.status,
            _that.timestamp,
            _that.editedAt,
            _that.mediaUrl,
            _that.thumbnailUrl,
            _that.fileName,
            _that.fileSize,
            _that.replyToMessageId,
            _that.forwardedFromUserId,
            _that.forwardedFromChatId,
            _that.readReceipts,
            _that.reactions,
            _that.isEdited,
            _that.isDeleted,
            _that.deletedAt,
            _that.deletedBy,
            _that.isPinned,
            _that.isStarred,
            _that.isForwarded,
            _that.isSelfDestructing,
            _that.selfDestructTime,
            _that.quotedMessageId,
            _that.quotedMessageContent,
            _that.latitude,
            _that.longitude,
            _that.locationName,
            _that.contactName,
            _that.contactPhone,
            _that.contactEmail);
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
            String chatId,
            String senderId,
            String? senderName,
            String? senderProfileImage,
            String? content,
            MessageType type,
            MessageStatus status,
            DateTime timestamp,
            DateTime? editedAt,
            String? mediaUrl,
            String? thumbnailUrl,
            String? fileName,
            int? fileSize,
            String? replyToMessageId,
            String? forwardedFromUserId,
            String? forwardedFromChatId,
            Map<String, DateTime> readReceipts,
            Map<String, String> reactions,
            bool isEdited,
            bool isDeleted,
            DateTime? deletedAt,
            String? deletedBy,
            bool isPinned,
            bool isStarred,
            bool isForwarded,
            bool isSelfDestructing,
            DateTime? selfDestructTime,
            String? quotedMessageId,
            String? quotedMessageContent,
            double? latitude,
            double? longitude,
            String? locationName,
            String? contactName,
            String? contactPhone,
            String? contactEmail)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageModel():
        return $default(
            _that.id,
            _that.chatId,
            _that.senderId,
            _that.senderName,
            _that.senderProfileImage,
            _that.content,
            _that.type,
            _that.status,
            _that.timestamp,
            _that.editedAt,
            _that.mediaUrl,
            _that.thumbnailUrl,
            _that.fileName,
            _that.fileSize,
            _that.replyToMessageId,
            _that.forwardedFromUserId,
            _that.forwardedFromChatId,
            _that.readReceipts,
            _that.reactions,
            _that.isEdited,
            _that.isDeleted,
            _that.deletedAt,
            _that.deletedBy,
            _that.isPinned,
            _that.isStarred,
            _that.isForwarded,
            _that.isSelfDestructing,
            _that.selfDestructTime,
            _that.quotedMessageId,
            _that.quotedMessageContent,
            _that.latitude,
            _that.longitude,
            _that.locationName,
            _that.contactName,
            _that.contactPhone,
            _that.contactEmail);
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
            String chatId,
            String senderId,
            String? senderName,
            String? senderProfileImage,
            String? content,
            MessageType type,
            MessageStatus status,
            DateTime timestamp,
            DateTime? editedAt,
            String? mediaUrl,
            String? thumbnailUrl,
            String? fileName,
            int? fileSize,
            String? replyToMessageId,
            String? forwardedFromUserId,
            String? forwardedFromChatId,
            Map<String, DateTime> readReceipts,
            Map<String, String> reactions,
            bool isEdited,
            bool isDeleted,
            DateTime? deletedAt,
            String? deletedBy,
            bool isPinned,
            bool isStarred,
            bool isForwarded,
            bool isSelfDestructing,
            DateTime? selfDestructTime,
            String? quotedMessageId,
            String? quotedMessageContent,
            double? latitude,
            double? longitude,
            String? locationName,
            String? contactName,
            String? contactPhone,
            String? contactEmail)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageModel() when $default != null:
        return $default(
            _that.id,
            _that.chatId,
            _that.senderId,
            _that.senderName,
            _that.senderProfileImage,
            _that.content,
            _that.type,
            _that.status,
            _that.timestamp,
            _that.editedAt,
            _that.mediaUrl,
            _that.thumbnailUrl,
            _that.fileName,
            _that.fileSize,
            _that.replyToMessageId,
            _that.forwardedFromUserId,
            _that.forwardedFromChatId,
            _that.readReceipts,
            _that.reactions,
            _that.isEdited,
            _that.isDeleted,
            _that.deletedAt,
            _that.deletedBy,
            _that.isPinned,
            _that.isStarred,
            _that.isForwarded,
            _that.isSelfDestructing,
            _that.selfDestructTime,
            _that.quotedMessageId,
            _that.quotedMessageContent,
            _that.latitude,
            _that.longitude,
            _that.locationName,
            _that.contactName,
            _that.contactPhone,
            _that.contactEmail);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _MessageModel extends MessageModel {
  _MessageModel(
      {required this.id,
      required this.chatId,
      required this.senderId,
      this.senderName,
      this.senderProfileImage,
      this.content,
      this.type = MessageType.text,
      this.status = MessageStatus.delivered,
      required this.timestamp,
      this.editedAt,
      this.mediaUrl,
      this.thumbnailUrl,
      this.fileName,
      this.fileSize,
      this.replyToMessageId,
      this.forwardedFromUserId,
      this.forwardedFromChatId,
      final Map<String, DateTime> readReceipts = const {},
      final Map<String, String> reactions = const {},
      this.isEdited = false,
      this.isDeleted = false,
      this.deletedAt,
      this.deletedBy,
      this.isPinned = false,
      this.isStarred = false,
      this.isForwarded = false,
      this.isSelfDestructing = false,
      this.selfDestructTime,
      this.quotedMessageId,
      this.quotedMessageContent,
      this.latitude,
      this.longitude,
      this.locationName,
      this.contactName,
      this.contactPhone,
      this.contactEmail})
      : _readReceipts = readReceipts,
        _reactions = reactions,
        super._();
  factory _MessageModel.fromJson(Map<String, dynamic> json) =>
      _$MessageModelFromJson(json);

  @override
  final String id;
  @override
  final String chatId;
  @override
  final String senderId;
  @override
  final String? senderName;
  @override
  final String? senderProfileImage;
  @override
  final String? content;
  @override
  @JsonKey()
  final MessageType type;
  @override
  @JsonKey()
  final MessageStatus status;
  @override
  final DateTime timestamp;
  @override
  final DateTime? editedAt;
  @override
  final String? mediaUrl;
  @override
  final String? thumbnailUrl;
  @override
  final String? fileName;
  @override
  final int? fileSize;
  @override
  final String? replyToMessageId;
  @override
  final String? forwardedFromUserId;
  @override
  final String? forwardedFromChatId;
// Map of userId to timestamp for read receipts
  final Map<String, DateTime> _readReceipts;
// Map of userId to timestamp for read receipts
  @override
  @JsonKey()
  Map<String, DateTime> get readReceipts {
    if (_readReceipts is EqualUnmodifiableMapView) return _readReceipts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_readReceipts);
  }

// Map of userId to reaction emoji
  final Map<String, String> _reactions;
// Map of userId to reaction emoji
  @override
  @JsonKey()
  Map<String, String> get reactions {
    if (_reactions is EqualUnmodifiableMapView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_reactions);
  }

  @override
  @JsonKey()
  final bool isEdited;
  @override
  @JsonKey()
  final bool isDeleted;
  @override
  final DateTime? deletedAt;
  @override
  final String? deletedBy;
  @override
  @JsonKey()
  final bool isPinned;
  @override
  @JsonKey()
  final bool isStarred;
  @override
  @JsonKey()
  final bool isForwarded;
  @override
  @JsonKey()
  final bool isSelfDestructing;
  @override
  final DateTime? selfDestructTime;
  @override
  final String? quotedMessageId;
  @override
  final String? quotedMessageContent;
// Location data for location messages
  @override
  final double? latitude;
  @override
  final double? longitude;
  @override
  final String? locationName;
// Contact data for contact messages
  @override
  final String? contactName;
  @override
  final String? contactPhone;
  @override
  final String? contactEmail;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageModelCopyWith<_MessageModel> get copyWith =>
      __$MessageModelCopyWithImpl<_MessageModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$MessageModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MessageModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderProfileImage, senderProfileImage) ||
                other.senderProfileImage == senderProfileImage) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.editedAt, editedAt) ||
                other.editedAt == editedAt) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.fileName, fileName) ||
                other.fileName == fileName) &&
            (identical(other.fileSize, fileSize) ||
                other.fileSize == fileSize) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.forwardedFromUserId, forwardedFromUserId) ||
                other.forwardedFromUserId == forwardedFromUserId) &&
            (identical(other.forwardedFromChatId, forwardedFromChatId) ||
                other.forwardedFromChatId == forwardedFromChatId) &&
            const DeepCollectionEquality()
                .equals(other._readReceipts, _readReceipts) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions) &&
            (identical(other.isEdited, isEdited) ||
                other.isEdited == isEdited) &&
            (identical(other.isDeleted, isDeleted) ||
                other.isDeleted == isDeleted) &&
            (identical(other.deletedAt, deletedAt) ||
                other.deletedAt == deletedAt) &&
            (identical(other.deletedBy, deletedBy) ||
                other.deletedBy == deletedBy) &&
            (identical(other.isPinned, isPinned) ||
                other.isPinned == isPinned) &&
            (identical(other.isStarred, isStarred) ||
                other.isStarred == isStarred) &&
            (identical(other.isForwarded, isForwarded) ||
                other.isForwarded == isForwarded) &&
            (identical(other.isSelfDestructing, isSelfDestructing) ||
                other.isSelfDestructing == isSelfDestructing) &&
            (identical(other.selfDestructTime, selfDestructTime) ||
                other.selfDestructTime == selfDestructTime) &&
            (identical(other.quotedMessageId, quotedMessageId) ||
                other.quotedMessageId == quotedMessageId) &&
            (identical(other.quotedMessageContent, quotedMessageContent) ||
                other.quotedMessageContent == quotedMessageContent) &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.locationName, locationName) ||
                other.locationName == locationName) &&
            (identical(other.contactName, contactName) ||
                other.contactName == contactName) &&
            (identical(other.contactPhone, contactPhone) ||
                other.contactPhone == contactPhone) &&
            (identical(other.contactEmail, contactEmail) ||
                other.contactEmail == contactEmail));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        chatId,
        senderId,
        senderName,
        senderProfileImage,
        content,
        type,
        status,
        timestamp,
        editedAt,
        mediaUrl,
        thumbnailUrl,
        fileName,
        fileSize,
        replyToMessageId,
        forwardedFromUserId,
        forwardedFromChatId,
        const DeepCollectionEquality().hash(_readReceipts),
        const DeepCollectionEquality().hash(_reactions),
        isEdited,
        isDeleted,
        deletedAt,
        deletedBy,
        isPinned,
        isStarred,
        isForwarded,
        isSelfDestructing,
        selfDestructTime,
        quotedMessageId,
        quotedMessageContent,
        latitude,
        longitude,
        locationName,
        contactName,
        contactPhone,
        contactEmail
      ]);

  @override
  String toString() {
    return 'MessageModel(id: $id, chatId: $chatId, senderId: $senderId, senderName: $senderName, senderProfileImage: $senderProfileImage, content: $content, type: $type, status: $status, timestamp: $timestamp, editedAt: $editedAt, mediaUrl: $mediaUrl, thumbnailUrl: $thumbnailUrl, fileName: $fileName, fileSize: $fileSize, replyToMessageId: $replyToMessageId, forwardedFromUserId: $forwardedFromUserId, forwardedFromChatId: $forwardedFromChatId, readReceipts: $readReceipts, reactions: $reactions, isEdited: $isEdited, isDeleted: $isDeleted, deletedAt: $deletedAt, deletedBy: $deletedBy, isPinned: $isPinned, isStarred: $isStarred, isForwarded: $isForwarded, isSelfDestructing: $isSelfDestructing, selfDestructTime: $selfDestructTime, quotedMessageId: $quotedMessageId, quotedMessageContent: $quotedMessageContent, latitude: $latitude, longitude: $longitude, locationName: $locationName, contactName: $contactName, contactPhone: $contactPhone, contactEmail: $contactEmail)';
  }
}

/// @nodoc
abstract mixin class _$MessageModelCopyWith<$Res>
    implements $MessageModelCopyWith<$Res> {
  factory _$MessageModelCopyWith(
          _MessageModel value, $Res Function(_MessageModel) _then) =
      __$MessageModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String chatId,
      String senderId,
      String? senderName,
      String? senderProfileImage,
      String? content,
      MessageType type,
      MessageStatus status,
      DateTime timestamp,
      DateTime? editedAt,
      String? mediaUrl,
      String? thumbnailUrl,
      String? fileName,
      int? fileSize,
      String? replyToMessageId,
      String? forwardedFromUserId,
      String? forwardedFromChatId,
      Map<String, DateTime> readReceipts,
      Map<String, String> reactions,
      bool isEdited,
      bool isDeleted,
      DateTime? deletedAt,
      String? deletedBy,
      bool isPinned,
      bool isStarred,
      bool isForwarded,
      bool isSelfDestructing,
      DateTime? selfDestructTime,
      String? quotedMessageId,
      String? quotedMessageContent,
      double? latitude,
      double? longitude,
      String? locationName,
      String? contactName,
      String? contactPhone,
      String? contactEmail});
}

/// @nodoc
class __$MessageModelCopyWithImpl<$Res>
    implements _$MessageModelCopyWith<$Res> {
  __$MessageModelCopyWithImpl(this._self, this._then);

  final _MessageModel _self;
  final $Res Function(_MessageModel) _then;

  /// Create a copy of MessageModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? chatId = null,
    Object? senderId = null,
    Object? senderName = freezed,
    Object? senderProfileImage = freezed,
    Object? content = freezed,
    Object? type = null,
    Object? status = null,
    Object? timestamp = null,
    Object? editedAt = freezed,
    Object? mediaUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? fileName = freezed,
    Object? fileSize = freezed,
    Object? replyToMessageId = freezed,
    Object? forwardedFromUserId = freezed,
    Object? forwardedFromChatId = freezed,
    Object? readReceipts = null,
    Object? reactions = null,
    Object? isEdited = null,
    Object? isDeleted = null,
    Object? deletedAt = freezed,
    Object? deletedBy = freezed,
    Object? isPinned = null,
    Object? isStarred = null,
    Object? isForwarded = null,
    Object? isSelfDestructing = null,
    Object? selfDestructTime = freezed,
    Object? quotedMessageId = freezed,
    Object? quotedMessageContent = freezed,
    Object? latitude = freezed,
    Object? longitude = freezed,
    Object? locationName = freezed,
    Object? contactName = freezed,
    Object? contactPhone = freezed,
    Object? contactEmail = freezed,
  }) {
    return _then(_MessageModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      chatId: null == chatId
          ? _self.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      senderName: freezed == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderProfileImage: freezed == senderProfileImage
          ? _self.senderProfileImage
          : senderProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      content: freezed == content
          ? _self.content
          : content // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as MessageType,
      status: null == status
          ? _self.status
          : status // ignore: cast_nullable_to_non_nullable
              as MessageStatus,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      editedAt: freezed == editedAt
          ? _self.editedAt
          : editedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      thumbnailUrl: freezed == thumbnailUrl
          ? _self.thumbnailUrl
          : thumbnailUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      fileName: freezed == fileName
          ? _self.fileName
          : fileName // ignore: cast_nullable_to_non_nullable
              as String?,
      fileSize: freezed == fileSize
          ? _self.fileSize
          : fileSize // ignore: cast_nullable_to_non_nullable
              as int?,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardedFromUserId: freezed == forwardedFromUserId
          ? _self.forwardedFromUserId
          : forwardedFromUserId // ignore: cast_nullable_to_non_nullable
              as String?,
      forwardedFromChatId: freezed == forwardedFromChatId
          ? _self.forwardedFromChatId
          : forwardedFromChatId // ignore: cast_nullable_to_non_nullable
              as String?,
      readReceipts: null == readReceipts
          ? _self._readReceipts
          : readReceipts // ignore: cast_nullable_to_non_nullable
              as Map<String, DateTime>,
      reactions: null == reactions
          ? _self._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      isEdited: null == isEdited
          ? _self.isEdited
          : isEdited // ignore: cast_nullable_to_non_nullable
              as bool,
      isDeleted: null == isDeleted
          ? _self.isDeleted
          : isDeleted // ignore: cast_nullable_to_non_nullable
              as bool,
      deletedAt: freezed == deletedAt
          ? _self.deletedAt
          : deletedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deletedBy: freezed == deletedBy
          ? _self.deletedBy
          : deletedBy // ignore: cast_nullable_to_non_nullable
              as String?,
      isPinned: null == isPinned
          ? _self.isPinned
          : isPinned // ignore: cast_nullable_to_non_nullable
              as bool,
      isStarred: null == isStarred
          ? _self.isStarred
          : isStarred // ignore: cast_nullable_to_non_nullable
              as bool,
      isForwarded: null == isForwarded
          ? _self.isForwarded
          : isForwarded // ignore: cast_nullable_to_non_nullable
              as bool,
      isSelfDestructing: null == isSelfDestructing
          ? _self.isSelfDestructing
          : isSelfDestructing // ignore: cast_nullable_to_non_nullable
              as bool,
      selfDestructTime: freezed == selfDestructTime
          ? _self.selfDestructTime
          : selfDestructTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      quotedMessageId: freezed == quotedMessageId
          ? _self.quotedMessageId
          : quotedMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      quotedMessageContent: freezed == quotedMessageContent
          ? _self.quotedMessageContent
          : quotedMessageContent // ignore: cast_nullable_to_non_nullable
              as String?,
      latitude: freezed == latitude
          ? _self.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double?,
      longitude: freezed == longitude
          ? _self.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double?,
      locationName: freezed == locationName
          ? _self.locationName
          : locationName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactName: freezed == contactName
          ? _self.contactName
          : contactName // ignore: cast_nullable_to_non_nullable
              as String?,
      contactPhone: freezed == contactPhone
          ? _self.contactPhone
          : contactPhone // ignore: cast_nullable_to_non_nullable
              as String?,
      contactEmail: freezed == contactEmail
          ? _self.contactEmail
          : contactEmail // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
