// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationModel implements DiagnosticableTreeMixin {
  String get id;
  String?
      get recipientId; // Made optional since it's now implicit in the document path
  String get senderId; // User who triggered the notification
  NotificationType get type;
  DateTime get timestamp;
  bool get isRead;
  String? get title;
  String? get body; // Fields for specific notification types
  String? get postId;
  String? get commentId;
  String? get senderName;
  String? get senderUsername;
  String? get senderProfileImage;
  String? get senderAltProfileImage;
  bool get isAlt; // If from alt profile
  int? get count; // For metrics (e.g., "5 likes on your post")
// Navigation path for the notification
  String? get path; // Additional metadata
  Map<String, dynamic> get data;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NotificationModelCopyWith<NotificationModel> get copyWith =>
      _$NotificationModelCopyWithImpl<NotificationModel>(
          this as NotificationModel, _$identity);

  /// Serializes this NotificationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('recipientId', recipientId))
      ..add(DiagnosticsProperty('senderId', senderId))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('isRead', isRead))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('commentId', commentId))
      ..add(DiagnosticsProperty('senderName', senderName))
      ..add(DiagnosticsProperty('senderUsername', senderUsername))
      ..add(DiagnosticsProperty('senderProfileImage', senderProfileImage))
      ..add(DiagnosticsProperty('senderAltProfileImage', senderAltProfileImage))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('count', count))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NotificationModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderUsername, senderUsername) ||
                other.senderUsername == senderUsername) &&
            (identical(other.senderProfileImage, senderProfileImage) ||
                other.senderProfileImage == senderProfileImage) &&
            (identical(other.senderAltProfileImage, senderAltProfileImage) ||
                other.senderAltProfileImage == senderAltProfileImage) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other.data, data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      recipientId,
      senderId,
      type,
      timestamp,
      isRead,
      title,
      body,
      postId,
      commentId,
      senderName,
      senderUsername,
      senderProfileImage,
      senderAltProfileImage,
      isAlt,
      count,
      path,
      const DeepCollectionEquality().hash(data));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationModel(id: $id, recipientId: $recipientId, senderId: $senderId, type: $type, timestamp: $timestamp, isRead: $isRead, title: $title, body: $body, postId: $postId, commentId: $commentId, senderName: $senderName, senderUsername: $senderUsername, senderProfileImage: $senderProfileImage, senderAltProfileImage: $senderAltProfileImage, isAlt: $isAlt, count: $count, path: $path, data: $data)';
  }
}

/// @nodoc
abstract mixin class $NotificationModelCopyWith<$Res> {
  factory $NotificationModelCopyWith(
          NotificationModel value, $Res Function(NotificationModel) _then) =
      _$NotificationModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String? recipientId,
      String senderId,
      NotificationType type,
      DateTime timestamp,
      bool isRead,
      String? title,
      String? body,
      String? postId,
      String? commentId,
      String? senderName,
      String? senderUsername,
      String? senderProfileImage,
      String? senderAltProfileImage,
      bool isAlt,
      int? count,
      String? path,
      Map<String, dynamic> data});
}

/// @nodoc
class _$NotificationModelCopyWithImpl<$Res>
    implements $NotificationModelCopyWith<$Res> {
  _$NotificationModelCopyWithImpl(this._self, this._then);

  final NotificationModel _self;
  final $Res Function(NotificationModel) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? recipientId = freezed,
    Object? senderId = null,
    Object? type = null,
    Object? timestamp = null,
    Object? isRead = null,
    Object? title = freezed,
    Object? body = freezed,
    Object? postId = freezed,
    Object? commentId = freezed,
    Object? senderName = freezed,
    Object? senderUsername = freezed,
    Object? senderProfileImage = freezed,
    Object? senderAltProfileImage = freezed,
    Object? isAlt = null,
    Object? count = freezed,
    Object? path = freezed,
    Object? data = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: freezed == recipientId
          ? _self.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      postId: freezed == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String?,
      commentId: freezed == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderUsername: freezed == senderUsername
          ? _self.senderUsername
          : senderUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      senderProfileImage: freezed == senderProfileImage
          ? _self.senderProfileImage
          : senderProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAltProfileImage: freezed == senderAltProfileImage
          ? _self.senderAltProfileImage
          : senderAltProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      count: freezed == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      path: freezed == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      data: null == data
          ? _self.data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

/// Adds pattern-matching-related methods to [NotificationModel].
extension NotificationModelPatterns on NotificationModel {
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
    TResult Function(_NotificationModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
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
    TResult Function(_NotificationModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel():
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
    TResult? Function(_NotificationModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
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
            String? recipientId,
            String senderId,
            NotificationType type,
            DateTime timestamp,
            bool isRead,
            String? title,
            String? body,
            String? postId,
            String? commentId,
            String? senderName,
            String? senderUsername,
            String? senderProfileImage,
            String? senderAltProfileImage,
            bool isAlt,
            int? count,
            String? path,
            Map<String, dynamic> data)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
        return $default(
            _that.id,
            _that.recipientId,
            _that.senderId,
            _that.type,
            _that.timestamp,
            _that.isRead,
            _that.title,
            _that.body,
            _that.postId,
            _that.commentId,
            _that.senderName,
            _that.senderUsername,
            _that.senderProfileImage,
            _that.senderAltProfileImage,
            _that.isAlt,
            _that.count,
            _that.path,
            _that.data);
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
            String? recipientId,
            String senderId,
            NotificationType type,
            DateTime timestamp,
            bool isRead,
            String? title,
            String? body,
            String? postId,
            String? commentId,
            String? senderName,
            String? senderUsername,
            String? senderProfileImage,
            String? senderAltProfileImage,
            bool isAlt,
            int? count,
            String? path,
            Map<String, dynamic> data)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel():
        return $default(
            _that.id,
            _that.recipientId,
            _that.senderId,
            _that.type,
            _that.timestamp,
            _that.isRead,
            _that.title,
            _that.body,
            _that.postId,
            _that.commentId,
            _that.senderName,
            _that.senderUsername,
            _that.senderProfileImage,
            _that.senderAltProfileImage,
            _that.isAlt,
            _that.count,
            _that.path,
            _that.data);
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
            String? recipientId,
            String senderId,
            NotificationType type,
            DateTime timestamp,
            bool isRead,
            String? title,
            String? body,
            String? postId,
            String? commentId,
            String? senderName,
            String? senderUsername,
            String? senderProfileImage,
            String? senderAltProfileImage,
            bool isAlt,
            int? count,
            String? path,
            Map<String, dynamic> data)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NotificationModel() when $default != null:
        return $default(
            _that.id,
            _that.recipientId,
            _that.senderId,
            _that.type,
            _that.timestamp,
            _that.isRead,
            _that.title,
            _that.body,
            _that.postId,
            _that.commentId,
            _that.senderName,
            _that.senderUsername,
            _that.senderProfileImage,
            _that.senderAltProfileImage,
            _that.isAlt,
            _that.count,
            _that.path,
            _that.data);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NotificationModel extends NotificationModel
    with DiagnosticableTreeMixin {
  const _NotificationModel(
      {required this.id,
      this.recipientId,
      required this.senderId,
      required this.type,
      required this.timestamp,
      this.isRead = false,
      this.title,
      this.body,
      this.postId,
      this.commentId,
      this.senderName,
      this.senderUsername,
      this.senderProfileImage,
      this.senderAltProfileImage,
      this.isAlt = false,
      this.count,
      this.path,
      final Map<String, dynamic> data = const {}})
      : _data = data,
        super._();
  factory _NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  @override
  final String id;
  @override
  final String? recipientId;
// Made optional since it's now implicit in the document path
  @override
  final String senderId;
// User who triggered the notification
  @override
  final NotificationType type;
  @override
  final DateTime timestamp;
  @override
  @JsonKey()
  final bool isRead;
  @override
  final String? title;
  @override
  final String? body;
// Fields for specific notification types
  @override
  final String? postId;
  @override
  final String? commentId;
  @override
  final String? senderName;
  @override
  final String? senderUsername;
  @override
  final String? senderProfileImage;
  @override
  final String? senderAltProfileImage;
  @override
  @JsonKey()
  final bool isAlt;
// If from alt profile
  @override
  final int? count;
// For metrics (e.g., "5 likes on your post")
// Navigation path for the notification
  @override
  final String? path;
// Additional metadata
  final Map<String, dynamic> _data;
// Additional metadata
  @override
  @JsonKey()
  Map<String, dynamic> get data {
    if (_data is EqualUnmodifiableMapView) return _data;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_data);
  }

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NotificationModelCopyWith<_NotificationModel> get copyWith =>
      __$NotificationModelCopyWithImpl<_NotificationModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NotificationModelToJson(
      this,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'NotificationModel'))
      ..add(DiagnosticsProperty('id', id))
      ..add(DiagnosticsProperty('recipientId', recipientId))
      ..add(DiagnosticsProperty('senderId', senderId))
      ..add(DiagnosticsProperty('type', type))
      ..add(DiagnosticsProperty('timestamp', timestamp))
      ..add(DiagnosticsProperty('isRead', isRead))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('body', body))
      ..add(DiagnosticsProperty('postId', postId))
      ..add(DiagnosticsProperty('commentId', commentId))
      ..add(DiagnosticsProperty('senderName', senderName))
      ..add(DiagnosticsProperty('senderUsername', senderUsername))
      ..add(DiagnosticsProperty('senderProfileImage', senderProfileImage))
      ..add(DiagnosticsProperty('senderAltProfileImage', senderAltProfileImage))
      ..add(DiagnosticsProperty('isAlt', isAlt))
      ..add(DiagnosticsProperty('count', count))
      ..add(DiagnosticsProperty('path', path))
      ..add(DiagnosticsProperty('data', data));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NotificationModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.recipientId, recipientId) ||
                other.recipientId == recipientId) &&
            (identical(other.senderId, senderId) ||
                other.senderId == senderId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.isRead, isRead) || other.isRead == isRead) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.postId, postId) || other.postId == postId) &&
            (identical(other.commentId, commentId) ||
                other.commentId == commentId) &&
            (identical(other.senderName, senderName) ||
                other.senderName == senderName) &&
            (identical(other.senderUsername, senderUsername) ||
                other.senderUsername == senderUsername) &&
            (identical(other.senderProfileImage, senderProfileImage) ||
                other.senderProfileImage == senderProfileImage) &&
            (identical(other.senderAltProfileImage, senderAltProfileImage) ||
                other.senderAltProfileImage == senderAltProfileImage) &&
            (identical(other.isAlt, isAlt) || other.isAlt == isAlt) &&
            (identical(other.count, count) || other.count == count) &&
            (identical(other.path, path) || other.path == path) &&
            const DeepCollectionEquality().equals(other._data, _data));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      recipientId,
      senderId,
      type,
      timestamp,
      isRead,
      title,
      body,
      postId,
      commentId,
      senderName,
      senderUsername,
      senderProfileImage,
      senderAltProfileImage,
      isAlt,
      count,
      path,
      const DeepCollectionEquality().hash(_data));

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'NotificationModel(id: $id, recipientId: $recipientId, senderId: $senderId, type: $type, timestamp: $timestamp, isRead: $isRead, title: $title, body: $body, postId: $postId, commentId: $commentId, senderName: $senderName, senderUsername: $senderUsername, senderProfileImage: $senderProfileImage, senderAltProfileImage: $senderAltProfileImage, isAlt: $isAlt, count: $count, path: $path, data: $data)';
  }
}

/// @nodoc
abstract mixin class _$NotificationModelCopyWith<$Res>
    implements $NotificationModelCopyWith<$Res> {
  factory _$NotificationModelCopyWith(
          _NotificationModel value, $Res Function(_NotificationModel) _then) =
      __$NotificationModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String? recipientId,
      String senderId,
      NotificationType type,
      DateTime timestamp,
      bool isRead,
      String? title,
      String? body,
      String? postId,
      String? commentId,
      String? senderName,
      String? senderUsername,
      String? senderProfileImage,
      String? senderAltProfileImage,
      bool isAlt,
      int? count,
      String? path,
      Map<String, dynamic> data});
}

/// @nodoc
class __$NotificationModelCopyWithImpl<$Res>
    implements _$NotificationModelCopyWith<$Res> {
  __$NotificationModelCopyWithImpl(this._self, this._then);

  final _NotificationModel _self;
  final $Res Function(_NotificationModel) _then;

  /// Create a copy of NotificationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? recipientId = freezed,
    Object? senderId = null,
    Object? type = null,
    Object? timestamp = null,
    Object? isRead = null,
    Object? title = freezed,
    Object? body = freezed,
    Object? postId = freezed,
    Object? commentId = freezed,
    Object? senderName = freezed,
    Object? senderUsername = freezed,
    Object? senderProfileImage = freezed,
    Object? senderAltProfileImage = freezed,
    Object? isAlt = null,
    Object? count = freezed,
    Object? path = freezed,
    Object? data = null,
  }) {
    return _then(_NotificationModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      recipientId: freezed == recipientId
          ? _self.recipientId
          : recipientId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderId: null == senderId
          ? _self.senderId
          : senderId // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as NotificationType,
      timestamp: null == timestamp
          ? _self.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      isRead: null == isRead
          ? _self.isRead
          : isRead // ignore: cast_nullable_to_non_nullable
              as bool,
      title: freezed == title
          ? _self.title
          : title // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _self.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      postId: freezed == postId
          ? _self.postId
          : postId // ignore: cast_nullable_to_non_nullable
              as String?,
      commentId: freezed == commentId
          ? _self.commentId
          : commentId // ignore: cast_nullable_to_non_nullable
              as String?,
      senderName: freezed == senderName
          ? _self.senderName
          : senderName // ignore: cast_nullable_to_non_nullable
              as String?,
      senderUsername: freezed == senderUsername
          ? _self.senderUsername
          : senderUsername // ignore: cast_nullable_to_non_nullable
              as String?,
      senderProfileImage: freezed == senderProfileImage
          ? _self.senderProfileImage
          : senderProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      senderAltProfileImage: freezed == senderAltProfileImage
          ? _self.senderAltProfileImage
          : senderAltProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      isAlt: null == isAlt
          ? _self.isAlt
          : isAlt // ignore: cast_nullable_to_non_nullable
              as bool,
      count: freezed == count
          ? _self.count
          : count // ignore: cast_nullable_to_non_nullable
              as int?,
      path: freezed == path
          ? _self.path
          : path // ignore: cast_nullable_to_non_nullable
              as String?,
      data: null == data
          ? _self._data
          : data // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
    ));
  }
}

// dart format on
