// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'create_post_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CreatePostState implements DiagnosticableTreeMixin {
  UserModel? get user;
  PostModel? get post;
  String? get herdId;
  String? get herdName;
  bool get isImage;
  bool get isLoading;
  bool get isNSFW;
  String? get errorMessage;

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CreatePostStateCopyWith<CreatePostState> get copyWith =>
      _$CreatePostStateCopyWithImpl<CreatePostState>(
          this as CreatePostState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CreatePostState'))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('post', post))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('isImage', isImage))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('errorMessage', errorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CreatePostState &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.herdId, herdId) || other.herdId == herdId) &&
            (identical(other.herdName, herdName) ||
                other.herdName == herdName) &&
            (identical(other.isImage, isImage) || other.isImage == isImage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, post, herdId, herdName,
      isImage, isLoading, isNSFW, errorMessage);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CreatePostState(user: $user, post: $post, herdId: $herdId, herdName: $herdName, isImage: $isImage, isLoading: $isLoading, isNSFW: $isNSFW, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $CreatePostStateCopyWith<$Res> {
  factory $CreatePostStateCopyWith(
          CreatePostState value, $Res Function(CreatePostState) _then) =
      _$CreatePostStateCopyWithImpl;
  @useResult
  $Res call(
      {UserModel? user,
      PostModel? post,
      String? herdId,
      String? herdName,
      bool isImage,
      bool isLoading,
      bool isNSFW,
      String? errorMessage});

  $UserModelCopyWith<$Res>? get user;
  $PostModelCopyWith<$Res>? get post;
}

/// @nodoc
class _$CreatePostStateCopyWithImpl<$Res>
    implements $CreatePostStateCopyWith<$Res> {
  _$CreatePostStateCopyWithImpl(this._self, this._then);

  final CreatePostState _self;
  final $Res Function(CreatePostState) _then;

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? user = freezed,
    Object? post = freezed,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? isImage = null,
    Object? isLoading = null,
    Object? isNSFW = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      post: freezed == post
          ? _self.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostModel?,
      herdId: freezed == herdId
          ? _self.herdId
          : herdId // ignore: cast_nullable_to_non_nullable
              as String?,
      herdName: freezed == herdName
          ? _self.herdName
          : herdName // ignore: cast_nullable_to_non_nullable
              as String?,
      isImage: null == isImage
          ? _self.isImage
          : isImage // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_self.user!, (value) {
      return _then(_self.copyWith(user: value));
    });
  }

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<$Res>? get post {
    if (_self.post == null) {
      return null;
    }

    return $PostModelCopyWith<$Res>(_self.post!, (value) {
      return _then(_self.copyWith(post: value));
    });
  }
}

/// Adds pattern-matching-related methods to [CreatePostState].
extension CreatePostStatePatterns on CreatePostState {
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
    TResult Function(_CreatePostState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreatePostState() when $default != null:
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
    TResult Function(_CreatePostState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreatePostState():
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
    TResult? Function(_CreatePostState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreatePostState() when $default != null:
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
            UserModel? user,
            PostModel? post,
            String? herdId,
            String? herdName,
            bool isImage,
            bool isLoading,
            bool isNSFW,
            String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CreatePostState() when $default != null:
        return $default(_that.user, _that.post, _that.herdId, _that.herdName,
            _that.isImage, _that.isLoading, _that.isNSFW, _that.errorMessage);
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
            UserModel? user,
            PostModel? post,
            String? herdId,
            String? herdName,
            bool isImage,
            bool isLoading,
            bool isNSFW,
            String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreatePostState():
        return $default(_that.user, _that.post, _that.herdId, _that.herdName,
            _that.isImage, _that.isLoading, _that.isNSFW, _that.errorMessage);
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
            UserModel? user,
            PostModel? post,
            String? herdId,
            String? herdName,
            bool isImage,
            bool isLoading,
            bool isNSFW,
            String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CreatePostState() when $default != null:
        return $default(_that.user, _that.post, _that.herdId, _that.herdName,
            _that.isImage, _that.isLoading, _that.isNSFW, _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _CreatePostState with DiagnosticableTreeMixin implements CreatePostState {
  const _CreatePostState(
      {required this.user,
      required this.post,
      this.herdId,
      this.herdName,
      this.isImage = false,
      this.isLoading = false,
      this.isNSFW = false,
      this.errorMessage});

  @override
  final UserModel? user;
  @override
  final PostModel? post;
  @override
  final String? herdId;
  @override
  final String? herdName;
  @override
  @JsonKey()
  final bool isImage;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  @JsonKey()
  final bool isNSFW;
  @override
  final String? errorMessage;

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CreatePostStateCopyWith<_CreatePostState> get copyWith =>
      __$CreatePostStateCopyWithImpl<_CreatePostState>(this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'CreatePostState'))
      ..add(DiagnosticsProperty('user', user))
      ..add(DiagnosticsProperty('post', post))
      ..add(DiagnosticsProperty('herdId', herdId))
      ..add(DiagnosticsProperty('herdName', herdName))
      ..add(DiagnosticsProperty('isImage', isImage))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('isNSFW', isNSFW))
      ..add(DiagnosticsProperty('errorMessage', errorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CreatePostState &&
            (identical(other.user, user) || other.user == user) &&
            (identical(other.post, post) || other.post == post) &&
            (identical(other.herdId, herdId) || other.herdId == herdId) &&
            (identical(other.herdName, herdName) ||
                other.herdName == herdName) &&
            (identical(other.isImage, isImage) || other.isImage == isImage) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isNSFW, isNSFW) || other.isNSFW == isNSFW) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(runtimeType, user, post, herdId, herdName,
      isImage, isLoading, isNSFW, errorMessage);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'CreatePostState(user: $user, post: $post, herdId: $herdId, herdName: $herdName, isImage: $isImage, isLoading: $isLoading, isNSFW: $isNSFW, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$CreatePostStateCopyWith<$Res>
    implements $CreatePostStateCopyWith<$Res> {
  factory _$CreatePostStateCopyWith(
          _CreatePostState value, $Res Function(_CreatePostState) _then) =
      __$CreatePostStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {UserModel? user,
      PostModel? post,
      String? herdId,
      String? herdName,
      bool isImage,
      bool isLoading,
      bool isNSFW,
      String? errorMessage});

  @override
  $UserModelCopyWith<$Res>? get user;
  @override
  $PostModelCopyWith<$Res>? get post;
}

/// @nodoc
class __$CreatePostStateCopyWithImpl<$Res>
    implements _$CreatePostStateCopyWith<$Res> {
  __$CreatePostStateCopyWithImpl(this._self, this._then);

  final _CreatePostState _self;
  final $Res Function(_CreatePostState) _then;

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? user = freezed,
    Object? post = freezed,
    Object? herdId = freezed,
    Object? herdName = freezed,
    Object? isImage = null,
    Object? isLoading = null,
    Object? isNSFW = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_CreatePostState(
      user: freezed == user
          ? _self.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
      post: freezed == post
          ? _self.post
          : post // ignore: cast_nullable_to_non_nullable
              as PostModel?,
      herdId: freezed == herdId
          ? _self.herdId
          : herdId // ignore: cast_nullable_to_non_nullable
              as String?,
      herdName: freezed == herdName
          ? _self.herdName
          : herdName // ignore: cast_nullable_to_non_nullable
              as String?,
      isImage: null == isImage
          ? _self.isImage
          : isImage // ignore: cast_nullable_to_non_nullable
              as bool,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      isNSFW: null == isNSFW
          ? _self.isNSFW
          : isNSFW // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_self.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_self.user!, (value) {
      return _then(_self.copyWith(user: value));
    });
  }

  /// Create a copy of CreatePostState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $PostModelCopyWith<$Res>? get post {
    if (_self.post == null) {
      return null;
    }

    return $PostModelCopyWith<$Res>(_self.post!, (value) {
      return _then(_self.copyWith(post: value));
    });
  }
}

// dart format on
