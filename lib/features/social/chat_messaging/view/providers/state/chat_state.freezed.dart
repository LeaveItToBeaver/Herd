// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ChatState {
  List<ChatModel> get chats;
  Map<String, List<MessageModel>> get messages;
  Map<String, bool> get loadingStates;
  ChatModel? get currentChat;
  bool get isLoading;
  String? get error;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ChatStateCopyWith<ChatState> get copyWith =>
      _$ChatStateCopyWithImpl<ChatState>(this as ChatState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ChatState &&
            const DeepCollectionEquality().equals(other.chats, chats) &&
            const DeepCollectionEquality().equals(other.messages, messages) &&
            const DeepCollectionEquality()
                .equals(other.loadingStates, loadingStates) &&
            (identical(other.currentChat, currentChat) ||
                other.currentChat == currentChat) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(chats),
      const DeepCollectionEquality().hash(messages),
      const DeepCollectionEquality().hash(loadingStates),
      currentChat,
      isLoading,
      error);

  @override
  String toString() {
    return 'ChatState(chats: $chats, messages: $messages, loadingStates: $loadingStates, currentChat: $currentChat, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class $ChatStateCopyWith<$Res> {
  factory $ChatStateCopyWith(ChatState value, $Res Function(ChatState) _then) =
      _$ChatStateCopyWithImpl;
  @useResult
  $Res call(
      {List<ChatModel> chats,
      Map<String, List<MessageModel>> messages,
      Map<String, bool> loadingStates,
      ChatModel? currentChat,
      bool isLoading,
      String? error});

  $ChatModelCopyWith<$Res>? get currentChat;
}

/// @nodoc
class _$ChatStateCopyWithImpl<$Res> implements $ChatStateCopyWith<$Res> {
  _$ChatStateCopyWithImpl(this._self, this._then);

  final ChatState _self;
  final $Res Function(ChatState) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? chats = null,
    Object? messages = null,
    Object? loadingStates = null,
    Object? currentChat = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      chats: null == chats
          ? _self.chats
          : chats // ignore: cast_nullable_to_non_nullable
              as List<ChatModel>,
      messages: null == messages
          ? _self.messages
          : messages // ignore: cast_nullable_to_non_nullable
              as Map<String, List<MessageModel>>,
      loadingStates: null == loadingStates
          ? _self.loadingStates
          : loadingStates // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      currentChat: freezed == currentChat
          ? _self.currentChat
          : currentChat // ignore: cast_nullable_to_non_nullable
              as ChatModel?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatModelCopyWith<$Res>? get currentChat {
    if (_self.currentChat == null) {
      return null;
    }

    return $ChatModelCopyWith<$Res>(_self.currentChat!, (value) {
      return _then(_self.copyWith(currentChat: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ChatState].
extension ChatStatePatterns on ChatState {
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
    TResult Function(_ChatState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatState() when $default != null:
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
    TResult Function(_ChatState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatState():
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
    TResult? Function(_ChatState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatState() when $default != null:
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
            List<ChatModel> chats,
            Map<String, List<MessageModel>> messages,
            Map<String, bool> loadingStates,
            ChatModel? currentChat,
            bool isLoading,
            String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ChatState() when $default != null:
        return $default(_that.chats, _that.messages, _that.loadingStates,
            _that.currentChat, _that.isLoading, _that.error);
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
            List<ChatModel> chats,
            Map<String, List<MessageModel>> messages,
            Map<String, bool> loadingStates,
            ChatModel? currentChat,
            bool isLoading,
            String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatState():
        return $default(_that.chats, _that.messages, _that.loadingStates,
            _that.currentChat, _that.isLoading, _that.error);
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
            List<ChatModel> chats,
            Map<String, List<MessageModel>> messages,
            Map<String, bool> loadingStates,
            ChatModel? currentChat,
            bool isLoading,
            String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ChatState() when $default != null:
        return $default(_that.chats, _that.messages, _that.loadingStates,
            _that.currentChat, _that.isLoading, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _ChatState implements ChatState {
  const _ChatState(
      {final List<ChatModel> chats = const [],
      final Map<String, List<MessageModel>> messages = const {},
      final Map<String, bool> loadingStates = const {},
      this.currentChat,
      this.isLoading = false,
      this.error})
      : _chats = chats,
        _messages = messages,
        _loadingStates = loadingStates;

  final List<ChatModel> _chats;
  @override
  @JsonKey()
  List<ChatModel> get chats {
    if (_chats is EqualUnmodifiableListView) return _chats;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_chats);
  }

  final Map<String, List<MessageModel>> _messages;
  @override
  @JsonKey()
  Map<String, List<MessageModel>> get messages {
    if (_messages is EqualUnmodifiableMapView) return _messages;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_messages);
  }

  final Map<String, bool> _loadingStates;
  @override
  @JsonKey()
  Map<String, bool> get loadingStates {
    if (_loadingStates is EqualUnmodifiableMapView) return _loadingStates;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_loadingStates);
  }

  @override
  final ChatModel? currentChat;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? error;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ChatStateCopyWith<_ChatState> get copyWith =>
      __$ChatStateCopyWithImpl<_ChatState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ChatState &&
            const DeepCollectionEquality().equals(other._chats, _chats) &&
            const DeepCollectionEquality().equals(other._messages, _messages) &&
            const DeepCollectionEquality()
                .equals(other._loadingStates, _loadingStates) &&
            (identical(other.currentChat, currentChat) ||
                other.currentChat == currentChat) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_chats),
      const DeepCollectionEquality().hash(_messages),
      const DeepCollectionEquality().hash(_loadingStates),
      currentChat,
      isLoading,
      error);

  @override
  String toString() {
    return 'ChatState(chats: $chats, messages: $messages, loadingStates: $loadingStates, currentChat: $currentChat, isLoading: $isLoading, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$ChatStateCopyWith<$Res>
    implements $ChatStateCopyWith<$Res> {
  factory _$ChatStateCopyWith(
          _ChatState value, $Res Function(_ChatState) _then) =
      __$ChatStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {List<ChatModel> chats,
      Map<String, List<MessageModel>> messages,
      Map<String, bool> loadingStates,
      ChatModel? currentChat,
      bool isLoading,
      String? error});

  @override
  $ChatModelCopyWith<$Res>? get currentChat;
}

/// @nodoc
class __$ChatStateCopyWithImpl<$Res> implements _$ChatStateCopyWith<$Res> {
  __$ChatStateCopyWithImpl(this._self, this._then);

  final _ChatState _self;
  final $Res Function(_ChatState) _then;

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? chats = null,
    Object? messages = null,
    Object? loadingStates = null,
    Object? currentChat = freezed,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_ChatState(
      chats: null == chats
          ? _self._chats
          : chats // ignore: cast_nullable_to_non_nullable
              as List<ChatModel>,
      messages: null == messages
          ? _self._messages
          : messages // ignore: cast_nullable_to_non_nullable
              as Map<String, List<MessageModel>>,
      loadingStates: null == loadingStates
          ? _self._loadingStates
          : loadingStates // ignore: cast_nullable_to_non_nullable
              as Map<String, bool>,
      currentChat: freezed == currentChat
          ? _self.currentChat
          : currentChat // ignore: cast_nullable_to_non_nullable
              as ChatModel?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of ChatState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ChatModelCopyWith<$Res>? get currentChat {
    if (_self.currentChat == null) {
      return null;
    }

    return $ChatModelCopyWith<$Res>(_self.currentChat!, (value) {
      return _then(_self.copyWith(currentChat: value));
    });
  }
}

/// @nodoc
mixin _$MessageInputState {
  String get text;
  bool get isTyping;
  bool get isSending;
  String? get replyToMessageId;
  String? get error;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $MessageInputStateCopyWith<MessageInputState> get copyWith =>
      _$MessageInputStateCopyWithImpl<MessageInputState>(
          this as MessageInputState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is MessageInputState &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isTyping, isTyping) ||
                other.isTyping == isTyping) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, text, isTyping, isSending, replyToMessageId, error);

  @override
  String toString() {
    return 'MessageInputState(text: $text, isTyping: $isTyping, isSending: $isSending, replyToMessageId: $replyToMessageId, error: $error)';
  }
}

/// @nodoc
abstract mixin class $MessageInputStateCopyWith<$Res> {
  factory $MessageInputStateCopyWith(
          MessageInputState value, $Res Function(MessageInputState) _then) =
      _$MessageInputStateCopyWithImpl;
  @useResult
  $Res call(
      {String text,
      bool isTyping,
      bool isSending,
      String? replyToMessageId,
      String? error});
}

/// @nodoc
class _$MessageInputStateCopyWithImpl<$Res>
    implements $MessageInputStateCopyWith<$Res> {
  _$MessageInputStateCopyWithImpl(this._self, this._then);

  final MessageInputState _self;
  final $Res Function(MessageInputState) _then;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? text = null,
    Object? isTyping = null,
    Object? isSending = null,
    Object? replyToMessageId = freezed,
    Object? error = freezed,
  }) {
    return _then(_self.copyWith(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isTyping: null == isTyping
          ? _self.isTyping
          : isTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _self.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [MessageInputState].
extension MessageInputStatePatterns on MessageInputState {
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
    TResult Function(_MessageInputState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
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
    TResult Function(_MessageInputState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState():
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
    TResult? Function(_MessageInputState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
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
    TResult Function(String text, bool isTyping, bool isSending,
            String? replyToMessageId, String? error)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
        return $default(_that.text, _that.isTyping, _that.isSending,
            _that.replyToMessageId, _that.error);
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
    TResult Function(String text, bool isTyping, bool isSending,
            String? replyToMessageId, String? error)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState():
        return $default(_that.text, _that.isTyping, _that.isSending,
            _that.replyToMessageId, _that.error);
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
    TResult? Function(String text, bool isTyping, bool isSending,
            String? replyToMessageId, String? error)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _MessageInputState() when $default != null:
        return $default(_that.text, _that.isTyping, _that.isSending,
            _that.replyToMessageId, _that.error);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _MessageInputState implements MessageInputState {
  const _MessageInputState(
      {this.text = '',
      this.isTyping = false,
      this.isSending = false,
      this.replyToMessageId,
      this.error});

  @override
  @JsonKey()
  final String text;
  @override
  @JsonKey()
  final bool isTyping;
  @override
  @JsonKey()
  final bool isSending;
  @override
  final String? replyToMessageId;
  @override
  final String? error;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$MessageInputStateCopyWith<_MessageInputState> get copyWith =>
      __$MessageInputStateCopyWithImpl<_MessageInputState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _MessageInputState &&
            (identical(other.text, text) || other.text == text) &&
            (identical(other.isTyping, isTyping) ||
                other.isTyping == isTyping) &&
            (identical(other.isSending, isSending) ||
                other.isSending == isSending) &&
            (identical(other.replyToMessageId, replyToMessageId) ||
                other.replyToMessageId == replyToMessageId) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, text, isTyping, isSending, replyToMessageId, error);

  @override
  String toString() {
    return 'MessageInputState(text: $text, isTyping: $isTyping, isSending: $isSending, replyToMessageId: $replyToMessageId, error: $error)';
  }
}

/// @nodoc
abstract mixin class _$MessageInputStateCopyWith<$Res>
    implements $MessageInputStateCopyWith<$Res> {
  factory _$MessageInputStateCopyWith(
          _MessageInputState value, $Res Function(_MessageInputState) _then) =
      __$MessageInputStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String text,
      bool isTyping,
      bool isSending,
      String? replyToMessageId,
      String? error});
}

/// @nodoc
class __$MessageInputStateCopyWithImpl<$Res>
    implements _$MessageInputStateCopyWith<$Res> {
  __$MessageInputStateCopyWithImpl(this._self, this._then);

  final _MessageInputState _self;
  final $Res Function(_MessageInputState) _then;

  /// Create a copy of MessageInputState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? text = null,
    Object? isTyping = null,
    Object? isSending = null,
    Object? replyToMessageId = freezed,
    Object? error = freezed,
  }) {
    return _then(_MessageInputState(
      text: null == text
          ? _self.text
          : text // ignore: cast_nullable_to_non_nullable
              as String,
      isTyping: null == isTyping
          ? _self.isTyping
          : isTyping // ignore: cast_nullable_to_non_nullable
              as bool,
      isSending: null == isSending
          ? _self.isSending
          : isSending // ignore: cast_nullable_to_non_nullable
              as bool,
      replyToMessageId: freezed == replyToMessageId
          ? _self.replyToMessageId
          : replyToMessageId // ignore: cast_nullable_to_non_nullable
              as String?,
      error: freezed == error
          ? _self.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
