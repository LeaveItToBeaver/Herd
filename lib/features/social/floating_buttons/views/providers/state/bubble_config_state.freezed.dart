// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bubble_config_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BubbleConfigState {
  String get id;
  BubbleType get type;
  BubbleContentType get contentType; // Visual properties
  double? get size;
  EdgeInsets get padding;
  Color? get backgroundColor;
  Color? get foregroundColor;
  bool get isLarge; // Content properties
  IconData? get icon;
  String? get text;
  String? get imageUrl;
  Widget? get customContent; // Behavior properties
  VoidCallback? get onTap;
  String? get routeName;
  Map<String, String>? get routeParams;
  bool get isDraggable;
  bool get isVisible;
  int get order; // Chat-specific properties
  bool get isChatBubble;
  String? get chatId;
  String? get lastMessage;
  int? get unreadCount;
  bool get isOnline; // Conditional visibility
  @JsonKey(includeFromJson: false, includeToJson: false)
  bool Function()? get visibilityCondition;

  /// Create a copy of BubbleConfigState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $BubbleConfigStateCopyWith<BubbleConfigState> get copyWith =>
      _$BubbleConfigStateCopyWithImpl<BubbleConfigState>(
          this as BubbleConfigState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is BubbleConfigState &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.padding, padding) || other.padding == padding) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.foregroundColor, foregroundColor) ||
                other.foregroundColor == foregroundColor) &&
            (identical(other.isLarge, isLarge) || other.isLarge == isLarge) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.customContent, customContent) ||
                other.customContent == customContent) &&
            (identical(other.onTap, onTap) || other.onTap == onTap) &&
            (identical(other.routeName, routeName) ||
                other.routeName == routeName) &&
            const DeepCollectionEquality()
                .equals(other.routeParams, routeParams) &&
            (identical(other.isDraggable, isDraggable) ||
                other.isDraggable == isDraggable) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isChatBubble, isChatBubble) ||
                other.isChatBubble == isChatBubble) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.visibilityCondition, visibilityCondition) ||
                other.visibilityCondition == visibilityCondition));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        contentType,
        size,
        padding,
        backgroundColor,
        foregroundColor,
        isLarge,
        icon,
        text,
        imageUrl,
        customContent,
        onTap,
        routeName,
        const DeepCollectionEquality().hash(routeParams),
        isDraggable,
        isVisible,
        order,
        isChatBubble,
        chatId,
        lastMessage,
        unreadCount,
        isOnline,
        visibilityCondition
      ]);

  @override
  String toString() {
    return 'BubbleConfigState(id: $id, type: $type, contentType: $contentType, size: $size, padding: $padding, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, isLarge: $isLarge, icon: $icon, text: $text, imageUrl: $imageUrl, customContent: $customContent, onTap: $onTap, routeName: $routeName, routeParams: $routeParams, isDraggable: $isDraggable, isVisible: $isVisible, order: $order, isChatBubble: $isChatBubble, chatId: $chatId, lastMessage: $lastMessage, unreadCount: $unreadCount, isOnline: $isOnline, visibilityCondition: $visibilityCondition)';
  }
}

/// @nodoc
abstract mixin class $BubbleConfigStateCopyWith<$Res> {
  factory $BubbleConfigStateCopyWith(
          BubbleConfigState value, $Res Function(BubbleConfigState) _then) =
      _$BubbleConfigStateCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      BubbleType type,
      BubbleContentType contentType,
      double? size,
      EdgeInsets padding,
      Color? backgroundColor,
      Color? foregroundColor,
      bool isLarge,
      IconData? icon,
      String? text,
      String? imageUrl,
      Widget? customContent,
      VoidCallback? onTap,
      String? routeName,
      Map<String, String>? routeParams,
      bool isDraggable,
      bool isVisible,
      int order,
      bool isChatBubble,
      String? chatId,
      String? lastMessage,
      int? unreadCount,
      bool isOnline,
      @JsonKey(includeFromJson: false, includeToJson: false)
      bool Function()? visibilityCondition});
}

/// @nodoc
class _$BubbleConfigStateCopyWithImpl<$Res>
    implements $BubbleConfigStateCopyWith<$Res> {
  _$BubbleConfigStateCopyWithImpl(this._self, this._then);

  final BubbleConfigState _self;
  final $Res Function(BubbleConfigState) _then;

  /// Create a copy of BubbleConfigState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? contentType = null,
    Object? size = freezed,
    Object? padding = null,
    Object? backgroundColor = freezed,
    Object? foregroundColor = freezed,
    Object? isLarge = null,
    Object? icon = freezed,
    Object? text = freezed,
    Object? imageUrl = freezed,
    Object? customContent = freezed,
    Object? onTap = freezed,
    Object? routeName = freezed,
    Object? routeParams = freezed,
    Object? isDraggable = null,
    Object? isVisible = null,
    Object? order = null,
    Object? isChatBubble = null,
    Object? chatId = freezed,
    Object? lastMessage = freezed,
    Object? unreadCount = freezed,
    Object? isOnline = null,
    Object? visibilityCondition = freezed,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as BubbleType,
      contentType: null == contentType
          ? _self.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as BubbleContentType,
      size: freezed == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as double?,
      padding: null == padding
          ? _self.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
      backgroundColor: freezed == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      foregroundColor: freezed == foregroundColor
          ? _self.foregroundColor
          : foregroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      isLarge: null == isLarge
          ? _self.isLarge
          : isLarge // ignore: cast_nullable_to_non_nullable
              as bool,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as IconData?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      customContent: freezed == customContent
          ? _self.customContent
          : customContent // ignore: cast_nullable_to_non_nullable
              as Widget?,
      onTap: freezed == onTap
          ? _self.onTap
          : onTap // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
      routeName: freezed == routeName
          ? _self.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String?,
      routeParams: freezed == routeParams
          ? _self.routeParams
          : routeParams // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      isDraggable: null == isDraggable
          ? _self.isDraggable
          : isDraggable // ignore: cast_nullable_to_non_nullable
              as bool,
      isVisible: null == isVisible
          ? _self.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      isChatBubble: null == isChatBubble
          ? _self.isChatBubble
          : isChatBubble // ignore: cast_nullable_to_non_nullable
              as bool,
      chatId: freezed == chatId
          ? _self.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount: freezed == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      visibilityCondition: freezed == visibilityCondition
          ? _self.visibilityCondition
          : visibilityCondition // ignore: cast_nullable_to_non_nullable
              as bool Function()?,
    ));
  }
}

/// Adds pattern-matching-related methods to [BubbleConfigState].
extension BubbleConfigStatePatterns on BubbleConfigState {
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
    TResult Function(_BubbleConfig value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BubbleConfig() when $default != null:
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
    TResult Function(_BubbleConfig value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BubbleConfig():
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
    TResult? Function(_BubbleConfig value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BubbleConfig() when $default != null:
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
            BubbleType type,
            BubbleContentType contentType,
            double? size,
            EdgeInsets padding,
            Color? backgroundColor,
            Color? foregroundColor,
            bool isLarge,
            IconData? icon,
            String? text,
            String? imageUrl,
            Widget? customContent,
            VoidCallback? onTap,
            String? routeName,
            Map<String, String>? routeParams,
            bool isDraggable,
            bool isVisible,
            int order,
            bool isChatBubble,
            String? chatId,
            String? lastMessage,
            int? unreadCount,
            bool isOnline,
            @JsonKey(includeFromJson: false, includeToJson: false)
            bool Function()? visibilityCondition)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _BubbleConfig() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.contentType,
            _that.size,
            _that.padding,
            _that.backgroundColor,
            _that.foregroundColor,
            _that.isLarge,
            _that.icon,
            _that.text,
            _that.imageUrl,
            _that.customContent,
            _that.onTap,
            _that.routeName,
            _that.routeParams,
            _that.isDraggable,
            _that.isVisible,
            _that.order,
            _that.isChatBubble,
            _that.chatId,
            _that.lastMessage,
            _that.unreadCount,
            _that.isOnline,
            _that.visibilityCondition);
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
            BubbleType type,
            BubbleContentType contentType,
            double? size,
            EdgeInsets padding,
            Color? backgroundColor,
            Color? foregroundColor,
            bool isLarge,
            IconData? icon,
            String? text,
            String? imageUrl,
            Widget? customContent,
            VoidCallback? onTap,
            String? routeName,
            Map<String, String>? routeParams,
            bool isDraggable,
            bool isVisible,
            int order,
            bool isChatBubble,
            String? chatId,
            String? lastMessage,
            int? unreadCount,
            bool isOnline,
            @JsonKey(includeFromJson: false, includeToJson: false)
            bool Function()? visibilityCondition)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BubbleConfig():
        return $default(
            _that.id,
            _that.type,
            _that.contentType,
            _that.size,
            _that.padding,
            _that.backgroundColor,
            _that.foregroundColor,
            _that.isLarge,
            _that.icon,
            _that.text,
            _that.imageUrl,
            _that.customContent,
            _that.onTap,
            _that.routeName,
            _that.routeParams,
            _that.isDraggable,
            _that.isVisible,
            _that.order,
            _that.isChatBubble,
            _that.chatId,
            _that.lastMessage,
            _that.unreadCount,
            _that.isOnline,
            _that.visibilityCondition);
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
            BubbleType type,
            BubbleContentType contentType,
            double? size,
            EdgeInsets padding,
            Color? backgroundColor,
            Color? foregroundColor,
            bool isLarge,
            IconData? icon,
            String? text,
            String? imageUrl,
            Widget? customContent,
            VoidCallback? onTap,
            String? routeName,
            Map<String, String>? routeParams,
            bool isDraggable,
            bool isVisible,
            int order,
            bool isChatBubble,
            String? chatId,
            String? lastMessage,
            int? unreadCount,
            bool isOnline,
            @JsonKey(includeFromJson: false, includeToJson: false)
            bool Function()? visibilityCondition)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _BubbleConfig() when $default != null:
        return $default(
            _that.id,
            _that.type,
            _that.contentType,
            _that.size,
            _that.padding,
            _that.backgroundColor,
            _that.foregroundColor,
            _that.isLarge,
            _that.icon,
            _that.text,
            _that.imageUrl,
            _that.customContent,
            _that.onTap,
            _that.routeName,
            _that.routeParams,
            _that.isDraggable,
            _that.isVisible,
            _that.order,
            _that.isChatBubble,
            _that.chatId,
            _that.lastMessage,
            _that.unreadCount,
            _that.isOnline,
            _that.visibilityCondition);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _BubbleConfig extends BubbleConfigState {
  const _BubbleConfig(
      {required this.id,
      this.type = BubbleType.custom,
      this.contentType = BubbleContentType.icon,
      this.size,
      this.padding = const EdgeInsets.all(0),
      this.backgroundColor,
      this.foregroundColor,
      this.isLarge = false,
      this.icon,
      this.text,
      this.imageUrl,
      this.customContent,
      this.onTap,
      this.routeName,
      final Map<String, String>? routeParams,
      this.isDraggable = false,
      this.isVisible = true,
      this.order = 0,
      this.isChatBubble = false,
      this.chatId,
      this.lastMessage,
      this.unreadCount,
      this.isOnline = false,
      @JsonKey(includeFromJson: false, includeToJson: false)
      this.visibilityCondition})
      : _routeParams = routeParams,
        super._();

  @override
  final String id;
  @override
  @JsonKey()
  final BubbleType type;
  @override
  @JsonKey()
  final BubbleContentType contentType;
// Visual properties
  @override
  final double? size;
  @override
  @JsonKey()
  final EdgeInsets padding;
  @override
  final Color? backgroundColor;
  @override
  final Color? foregroundColor;
  @override
  @JsonKey()
  final bool isLarge;
// Content properties
  @override
  final IconData? icon;
  @override
  final String? text;
  @override
  final String? imageUrl;
  @override
  final Widget? customContent;
// Behavior properties
  @override
  final VoidCallback? onTap;
  @override
  final String? routeName;
  final Map<String, String>? _routeParams;
  @override
  Map<String, String>? get routeParams {
    final value = _routeParams;
    if (value == null) return null;
    if (_routeParams is EqualUnmodifiableMapView) return _routeParams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(value);
  }

  @override
  @JsonKey()
  final bool isDraggable;
  @override
  @JsonKey()
  final bool isVisible;
  @override
  @JsonKey()
  final int order;
// Chat-specific properties
  @override
  @JsonKey()
  final bool isChatBubble;
  @override
  final String? chatId;
  @override
  final String? lastMessage;
  @override
  final int? unreadCount;
  @override
  @JsonKey()
  final bool isOnline;
// Conditional visibility
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  final bool Function()? visibilityCondition;

  /// Create a copy of BubbleConfigState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$BubbleConfigCopyWith<_BubbleConfig> get copyWith =>
      __$BubbleConfigCopyWithImpl<_BubbleConfig>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _BubbleConfig &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.contentType, contentType) ||
                other.contentType == contentType) &&
            (identical(other.size, size) || other.size == size) &&
            (identical(other.padding, padding) || other.padding == padding) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.foregroundColor, foregroundColor) ||
                other.foregroundColor == foregroundColor) &&
            (identical(other.isLarge, isLarge) || other.isLarge == isLarge) &&
            (identical(other.icon, icon) || other.icon == icon) &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.customContent, customContent) ||
                other.customContent == customContent) &&
            (identical(other.onTap, onTap) || other.onTap == onTap) &&
            (identical(other.routeName, routeName) ||
                other.routeName == routeName) &&
            const DeepCollectionEquality()
                .equals(other._routeParams, _routeParams) &&
            (identical(other.isDraggable, isDraggable) ||
                other.isDraggable == isDraggable) &&
            (identical(other.isVisible, isVisible) ||
                other.isVisible == isVisible) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.isChatBubble, isChatBubble) ||
                other.isChatBubble == isChatBubble) &&
            (identical(other.chatId, chatId) || other.chatId == chatId) &&
            (identical(other.lastMessage, lastMessage) ||
                other.lastMessage == lastMessage) &&
            (identical(other.unreadCount, unreadCount) ||
                other.unreadCount == unreadCount) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.visibilityCondition, visibilityCondition) ||
                other.visibilityCondition == visibilityCondition));
  }

  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        id,
        type,
        contentType,
        size,
        padding,
        backgroundColor,
        foregroundColor,
        isLarge,
        icon,
        text,
        imageUrl,
        customContent,
        onTap,
        routeName,
        const DeepCollectionEquality().hash(_routeParams),
        isDraggable,
        isVisible,
        order,
        isChatBubble,
        chatId,
        lastMessage,
        unreadCount,
        isOnline,
        visibilityCondition
      ]);

  @override
  String toString() {
    return 'BubbleConfigState(id: $id, type: $type, contentType: $contentType, size: $size, padding: $padding, backgroundColor: $backgroundColor, foregroundColor: $foregroundColor, isLarge: $isLarge, icon: $icon, text: $text, imageUrl: $imageUrl, customContent: $customContent, onTap: $onTap, routeName: $routeName, routeParams: $routeParams, isDraggable: $isDraggable, isVisible: $isVisible, order: $order, isChatBubble: $isChatBubble, chatId: $chatId, lastMessage: $lastMessage, unreadCount: $unreadCount, isOnline: $isOnline, visibilityCondition: $visibilityCondition)';
  }
}

/// @nodoc
abstract mixin class _$BubbleConfigCopyWith<$Res>
    implements $BubbleConfigStateCopyWith<$Res> {
  factory _$BubbleConfigCopyWith(
          _BubbleConfig value, $Res Function(_BubbleConfig) _then) =
      __$BubbleConfigCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      BubbleType type,
      BubbleContentType contentType,
      double? size,
      EdgeInsets padding,
      Color? backgroundColor,
      Color? foregroundColor,
      bool isLarge,
      IconData? icon,
      String? text,
      String? imageUrl,
      Widget? customContent,
      VoidCallback? onTap,
      String? routeName,
      Map<String, String>? routeParams,
      bool isDraggable,
      bool isVisible,
      int order,
      bool isChatBubble,
      String? chatId,
      String? lastMessage,
      int? unreadCount,
      bool isOnline,
      @JsonKey(includeFromJson: false, includeToJson: false)
      bool Function()? visibilityCondition});
}

/// @nodoc
class __$BubbleConfigCopyWithImpl<$Res>
    implements _$BubbleConfigCopyWith<$Res> {
  __$BubbleConfigCopyWithImpl(this._self, this._then);

  final _BubbleConfig _self;
  final $Res Function(_BubbleConfig) _then;

  /// Create a copy of BubbleConfigState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? contentType = null,
    Object? size = freezed,
    Object? padding = null,
    Object? backgroundColor = freezed,
    Object? foregroundColor = freezed,
    Object? isLarge = null,
    Object? icon = freezed,
    Object? text = freezed,
    Object? imageUrl = freezed,
    Object? customContent = freezed,
    Object? onTap = freezed,
    Object? routeName = freezed,
    Object? routeParams = freezed,
    Object? isDraggable = null,
    Object? isVisible = null,
    Object? order = null,
    Object? isChatBubble = null,
    Object? chatId = freezed,
    Object? lastMessage = freezed,
    Object? unreadCount = freezed,
    Object? isOnline = null,
    Object? visibilityCondition = freezed,
  }) {
    return _then(_BubbleConfig(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as BubbleType,
      contentType: null == contentType
          ? _self.contentType
          : contentType // ignore: cast_nullable_to_non_nullable
              as BubbleContentType,
      size: freezed == size
          ? _self.size
          : size // ignore: cast_nullable_to_non_nullable
              as double?,
      padding: null == padding
          ? _self.padding
          : padding // ignore: cast_nullable_to_non_nullable
              as EdgeInsets,
      backgroundColor: freezed == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      foregroundColor: freezed == foregroundColor
          ? _self.foregroundColor
          : foregroundColor // ignore: cast_nullable_to_non_nullable
              as Color?,
      isLarge: null == isLarge
          ? _self.isLarge
          : isLarge // ignore: cast_nullable_to_non_nullable
              as bool,
      icon: freezed == icon
          ? _self.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as IconData?,
      text: freezed == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _self.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      customContent: freezed == customContent
          ? _self.customContent
          : customContent // ignore: cast_nullable_to_non_nullable
              as Widget?,
      onTap: freezed == onTap
          ? _self.onTap
          : onTap // ignore: cast_nullable_to_non_nullable
              as VoidCallback?,
      routeName: freezed == routeName
          ? _self.routeName
          : routeName // ignore: cast_nullable_to_non_nullable
              as String?,
      routeParams: freezed == routeParams
          ? _self._routeParams
          : routeParams // ignore: cast_nullable_to_non_nullable
              as Map<String, String>?,
      isDraggable: null == isDraggable
          ? _self.isDraggable
          : isDraggable // ignore: cast_nullable_to_non_nullable
              as bool,
      isVisible: null == isVisible
          ? _self.isVisible
          : isVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      isChatBubble: null == isChatBubble
          ? _self.isChatBubble
          : isChatBubble // ignore: cast_nullable_to_non_nullable
              as bool,
      chatId: freezed == chatId
          ? _self.chatId
          : chatId // ignore: cast_nullable_to_non_nullable
              as String?,
      lastMessage: freezed == lastMessage
          ? _self.lastMessage
          : lastMessage // ignore: cast_nullable_to_non_nullable
              as String?,
      unreadCount: freezed == unreadCount
          ? _self.unreadCount
          : unreadCount // ignore: cast_nullable_to_non_nullable
              as int?,
      isOnline: null == isOnline
          ? _self.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      visibilityCondition: freezed == visibilityCondition
          ? _self.visibilityCondition
          : visibilityCondition // ignore: cast_nullable_to_non_nullable
              as bool Function()?,
    ));
  }
}

// dart format on
