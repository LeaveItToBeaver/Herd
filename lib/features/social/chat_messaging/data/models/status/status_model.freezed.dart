// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatusModel {
  String get id;
  String get userId;
  String? get userName;
  String? get userProfileImage;
  StatusType get type;
  String? get mediaUrl;
  String? get text;
  String? get caption;
  DateTime get createdAt;
  DateTime get expiresAt;
  List<String> get viewedBy;
  List<String> get allowedViewers; // For selected privacy
  List<String> get excludedViewers; // For except selected privacy
  StatusPrivacy get privacy;
  bool get isArchived;
  int get viewCount;
  String? get backgroundColor; // For text status
  String? get textColor; // For text status
  String? get fontStyle;

  /// Create a copy of StatusModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $StatusModelCopyWith<StatusModel> get copyWith =>
      _$StatusModelCopyWithImpl<StatusModel>(this as StatusModel, _$identity);

  /// Serializes this StatusModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is StatusModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userProfileImage, userProfileImage) ||
                other.userProfileImage == userProfileImage) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality().equals(other.viewedBy, viewedBy) &&
            const DeepCollectionEquality()
                .equals(other.allowedViewers, allowedViewers) &&
            const DeepCollectionEquality()
                .equals(other.excludedViewers, excludedViewers) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.fontStyle, fontStyle) ||
                other.fontStyle == fontStyle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        userName,
        userProfileImage,
        type,
        mediaUrl,
        text,
        caption,
        createdAt,
        expiresAt,
        const DeepCollectionEquality().hash(viewedBy),
        const DeepCollectionEquality().hash(allowedViewers),
        const DeepCollectionEquality().hash(excludedViewers),
        privacy,
        isArchived,
        viewCount,
        backgroundColor,
        textColor,
        fontStyle
      ]);

  @override
  String toString() {
    return 'StatusModel(id: $id, userId: $userId, userName: $userName, userProfileImage: $userProfileImage, type: $type, mediaUrl: $mediaUrl, text: $text, caption: $caption, createdAt: $createdAt, expiresAt: $expiresAt, viewedBy: $viewedBy, allowedViewers: $allowedViewers, excludedViewers: $excludedViewers, privacy: $privacy, isArchived: $isArchived, viewCount: $viewCount, backgroundColor: $backgroundColor, textColor: $textColor, fontStyle: $fontStyle)';
  }
}

/// @nodoc
abstract mixin class $StatusModelCopyWith<$Res> {
  factory $StatusModelCopyWith(
          StatusModel value, $Res Function(StatusModel) _then) =
      _$StatusModelCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String userId,
      String? userName,
      String? userProfileImage,
      StatusType type,
      String? mediaUrl,
      String? text,
      String? caption,
      DateTime createdAt,
      DateTime expiresAt,
      List<String> viewedBy,
      List<String> allowedViewers,
      List<String> excludedViewers,
      StatusPrivacy privacy,
      bool isArchived,
      int viewCount,
      String? backgroundColor,
      String? textColor,
      String? fontStyle});
}

/// @nodoc
class _$StatusModelCopyWithImpl<$Res> implements $StatusModelCopyWith<$Res> {
  _$StatusModelCopyWithImpl(this._self, this._then);

  final StatusModel _self;
  final $Res Function(StatusModel) _then;

  /// Create a copy of StatusModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? userProfileImage = freezed,
    Object? type = null,
    Object? mediaUrl = freezed,
    Object? text = freezed,
    Object? caption = freezed,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? viewedBy = null,
    Object? allowedViewers = null,
    Object? excludedViewers = null,
    Object? privacy = null,
    Object? isArchived = null,
    Object? viewCount = null,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? fontStyle = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileImage: freezed == userProfileImage
          ? _self.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StatusType,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      viewedBy: null == viewedBy
          ? _self.viewedBy
          : viewedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      allowedViewers: null == allowedViewers
          ? _self.allowedViewers
          : allowedViewers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedViewers: null == excludedViewers
          ? _self.excludedViewers
          : excludedViewers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      privacy: null == privacy
          ? _self.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as StatusPrivacy,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _self.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      backgroundColor: freezed == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      textColor: freezed == textColor
          ? _self.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      fontStyle: freezed == fontStyle
          ? _self.fontStyle
          : fontStyle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [StatusModel].
extension StatusModelPatterns on StatusModel {
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
    TResult Function(_StatusModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StatusModel() when $default != null:
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
    TResult Function(_StatusModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusModel():
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
    TResult? Function(_StatusModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusModel() when $default != null:
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
            String userId,
            String? userName,
            String? userProfileImage,
            StatusType type,
            String? mediaUrl,
            String? text,
            String? caption,
            DateTime createdAt,
            DateTime expiresAt,
            List<String> viewedBy,
            List<String> allowedViewers,
            List<String> excludedViewers,
            StatusPrivacy privacy,
            bool isArchived,
            int viewCount,
            String? backgroundColor,
            String? textColor,
            String? fontStyle)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _StatusModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.userProfileImage,
            _that.type,
            _that.mediaUrl,
            _that.text,
            _that.caption,
            _that.createdAt,
            _that.expiresAt,
            _that.viewedBy,
            _that.allowedViewers,
            _that.excludedViewers,
            _that.privacy,
            _that.isArchived,
            _that.viewCount,
            _that.backgroundColor,
            _that.textColor,
            _that.fontStyle);
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
            String userId,
            String? userName,
            String? userProfileImage,
            StatusType type,
            String? mediaUrl,
            String? text,
            String? caption,
            DateTime createdAt,
            DateTime expiresAt,
            List<String> viewedBy,
            List<String> allowedViewers,
            List<String> excludedViewers,
            StatusPrivacy privacy,
            bool isArchived,
            int viewCount,
            String? backgroundColor,
            String? textColor,
            String? fontStyle)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusModel():
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.userProfileImage,
            _that.type,
            _that.mediaUrl,
            _that.text,
            _that.caption,
            _that.createdAt,
            _that.expiresAt,
            _that.viewedBy,
            _that.allowedViewers,
            _that.excludedViewers,
            _that.privacy,
            _that.isArchived,
            _that.viewCount,
            _that.backgroundColor,
            _that.textColor,
            _that.fontStyle);
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
            String userId,
            String? userName,
            String? userProfileImage,
            StatusType type,
            String? mediaUrl,
            String? text,
            String? caption,
            DateTime createdAt,
            DateTime expiresAt,
            List<String> viewedBy,
            List<String> allowedViewers,
            List<String> excludedViewers,
            StatusPrivacy privacy,
            bool isArchived,
            int viewCount,
            String? backgroundColor,
            String? textColor,
            String? fontStyle)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _StatusModel() when $default != null:
        return $default(
            _that.id,
            _that.userId,
            _that.userName,
            _that.userProfileImage,
            _that.type,
            _that.mediaUrl,
            _that.text,
            _that.caption,
            _that.createdAt,
            _that.expiresAt,
            _that.viewedBy,
            _that.allowedViewers,
            _that.excludedViewers,
            _that.privacy,
            _that.isArchived,
            _that.viewCount,
            _that.backgroundColor,
            _that.textColor,
            _that.fontStyle);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _StatusModel extends StatusModel {
  _StatusModel(
      {required this.id,
      required this.userId,
      this.userName,
      this.userProfileImage,
      required this.type,
      this.mediaUrl,
      this.text,
      this.caption,
      required this.createdAt,
      required this.expiresAt,
      final List<String> viewedBy = const [],
      final List<String> allowedViewers = const [],
      final List<String> excludedViewers = const [],
      required this.privacy,
      this.isArchived = false,
      this.viewCount = 0,
      this.backgroundColor,
      this.textColor,
      this.fontStyle})
      : _viewedBy = viewedBy,
        _allowedViewers = allowedViewers,
        _excludedViewers = excludedViewers,
        super._();
  factory _StatusModel.fromJson(Map<String, dynamic> json) =>
      _$StatusModelFromJson(json);

  @override
  final String id;
  @override
  final String userId;
  @override
  final String? userName;
  @override
  final String? userProfileImage;
  @override
  final StatusType type;
  @override
  final String? mediaUrl;
  @override
  final String? text;
  @override
  final String? caption;
  @override
  final DateTime createdAt;
  @override
  final DateTime expiresAt;
  final List<String> _viewedBy;
  @override
  @JsonKey()
  List<String> get viewedBy {
    if (_viewedBy is EqualUnmodifiableListView) return _viewedBy;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_viewedBy);
  }

  final List<String> _allowedViewers;
  @override
  @JsonKey()
  List<String> get allowedViewers {
    if (_allowedViewers is EqualUnmodifiableListView) return _allowedViewers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_allowedViewers);
  }

// For selected privacy
  final List<String> _excludedViewers;
// For selected privacy
  @override
  @JsonKey()
  List<String> get excludedViewers {
    if (_excludedViewers is EqualUnmodifiableListView) return _excludedViewers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_excludedViewers);
  }

// For except selected privacy
  @override
  final StatusPrivacy privacy;
  @override
  @JsonKey()
  final bool isArchived;
  @override
  @JsonKey()
  final int viewCount;
  @override
  final String? backgroundColor;
// For text status
  @override
  final String? textColor;
// For text status
  @override
  final String? fontStyle;

  /// Create a copy of StatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$StatusModelCopyWith<_StatusModel> get copyWith =>
      __$StatusModelCopyWithImpl<_StatusModel>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$StatusModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _StatusModel &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.userProfileImage, userProfileImage) ||
                other.userProfileImage == userProfileImage) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.mediaUrl, mediaUrl) ||
                other.mediaUrl == mediaUrl) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.caption, caption) || other.caption == caption) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt) &&
            const DeepCollectionEquality().equals(other._viewedBy, _viewedBy) &&
            const DeepCollectionEquality()
                .equals(other._allowedViewers, _allowedViewers) &&
            const DeepCollectionEquality()
                .equals(other._excludedViewers, _excludedViewers) &&
            (identical(other.privacy, privacy) || other.privacy == privacy) &&
            (identical(other.isArchived, isArchived) ||
                other.isArchived == isArchived) &&
            (identical(other.viewCount, viewCount) ||
                other.viewCount == viewCount) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.fontStyle, fontStyle) ||
                other.fontStyle == fontStyle));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        userId,
        userName,
        userProfileImage,
        type,
        mediaUrl,
        text,
        caption,
        createdAt,
        expiresAt,
        const DeepCollectionEquality().hash(_viewedBy),
        const DeepCollectionEquality().hash(_allowedViewers),
        const DeepCollectionEquality().hash(_excludedViewers),
        privacy,
        isArchived,
        viewCount,
        backgroundColor,
        textColor,
        fontStyle
      ]);

  @override
  String toString() {
    return 'StatusModel(id: $id, userId: $userId, userName: $userName, userProfileImage: $userProfileImage, type: $type, mediaUrl: $mediaUrl, text: $text, caption: $caption, createdAt: $createdAt, expiresAt: $expiresAt, viewedBy: $viewedBy, allowedViewers: $allowedViewers, excludedViewers: $excludedViewers, privacy: $privacy, isArchived: $isArchived, viewCount: $viewCount, backgroundColor: $backgroundColor, textColor: $textColor, fontStyle: $fontStyle)';
  }
}

/// @nodoc
abstract mixin class _$StatusModelCopyWith<$Res>
    implements $StatusModelCopyWith<$Res> {
  factory _$StatusModelCopyWith(
          _StatusModel value, $Res Function(_StatusModel) _then) =
      __$StatusModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String? userName,
      String? userProfileImage,
      StatusType type,
      String? mediaUrl,
      String? text,
      String? caption,
      DateTime createdAt,
      DateTime expiresAt,
      List<String> viewedBy,
      List<String> allowedViewers,
      List<String> excludedViewers,
      StatusPrivacy privacy,
      bool isArchived,
      int viewCount,
      String? backgroundColor,
      String? textColor,
      String? fontStyle});
}

/// @nodoc
class __$StatusModelCopyWithImpl<$Res> implements _$StatusModelCopyWith<$Res> {
  __$StatusModelCopyWithImpl(this._self, this._then);

  final _StatusModel _self;
  final $Res Function(_StatusModel) _then;

  /// Create a copy of StatusModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? userName = freezed,
    Object? userProfileImage = freezed,
    Object? type = null,
    Object? mediaUrl = freezed,
    Object? text = freezed,
    Object? caption = freezed,
    Object? createdAt = null,
    Object? expiresAt = null,
    Object? viewedBy = null,
    Object? allowedViewers = null,
    Object? excludedViewers = null,
    Object? privacy = null,
    Object? isArchived = null,
    Object? viewCount = null,
    Object? backgroundColor = freezed,
    Object? textColor = freezed,
    Object? fontStyle = freezed,
  }) {
    return _then(_StatusModel(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      userName: freezed == userName
          ? _self.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String?,
      userProfileImage: freezed == userProfileImage
          ? _self.userProfileImage
          : userProfileImage // ignore: cast_nullable_to_non_nullable
              as String?,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as StatusType,
      mediaUrl: freezed == mediaUrl
          ? _self.mediaUrl
          : mediaUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      caption: freezed == caption
          ? _self.caption
          : caption // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _self.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      expiresAt: null == expiresAt
          ? _self.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      viewedBy: null == viewedBy
          ? _self._viewedBy
          : viewedBy // ignore: cast_nullable_to_non_nullable
              as List<String>,
      allowedViewers: null == allowedViewers
          ? _self._allowedViewers
          : allowedViewers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      excludedViewers: null == excludedViewers
          ? _self._excludedViewers
          : excludedViewers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      privacy: null == privacy
          ? _self.privacy
          : privacy // ignore: cast_nullable_to_non_nullable
              as StatusPrivacy,
      isArchived: null == isArchived
          ? _self.isArchived
          : isArchived // ignore: cast_nullable_to_non_nullable
              as bool,
      viewCount: null == viewCount
          ? _self.viewCount
          : viewCount // ignore: cast_nullable_to_non_nullable
              as int,
      backgroundColor: freezed == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      textColor: freezed == textColor
          ? _self.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String?,
      fontStyle: freezed == fontStyle
          ? _self.fontStyle
          : fontStyle // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
