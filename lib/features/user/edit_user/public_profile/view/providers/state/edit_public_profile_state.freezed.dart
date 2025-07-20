// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'edit_public_profile_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EditPublicProfileState implements DiagnosticableTreeMixin {
  String get firstName;
  String get lastName;
  String get bio;
  File? get coverImage;
  File? get profileImage;
  bool get isSubmitting;
  bool get isPublic;
  bool get isSuccess;
  String? get errorMessage;

  /// Create a copy of EditPublicProfileState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $EditPublicProfileStateCopyWith<EditPublicProfileState> get copyWith =>
      _$EditPublicProfileStateCopyWithImpl<EditPublicProfileState>(
          this as EditPublicProfileState, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'EditPublicProfileState'))
      ..add(DiagnosticsProperty('firstName', firstName))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('coverImage', coverImage))
      ..add(DiagnosticsProperty('profileImage', profileImage))
      ..add(DiagnosticsProperty('isSubmitting', isSubmitting))
      ..add(DiagnosticsProperty('isPublic', isPublic))
      ..add(DiagnosticsProperty('isSuccess', isSuccess))
      ..add(DiagnosticsProperty('errorMessage', errorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is EditPublicProfileState &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      firstName,
      lastName,
      bio,
      coverImage,
      profileImage,
      isSubmitting,
      isPublic,
      isSuccess,
      errorMessage);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EditPublicProfileState(firstName: $firstName, lastName: $lastName, bio: $bio, coverImage: $coverImage, profileImage: $profileImage, isSubmitting: $isSubmitting, isPublic: $isPublic, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class $EditPublicProfileStateCopyWith<$Res> {
  factory $EditPublicProfileStateCopyWith(EditPublicProfileState value,
          $Res Function(EditPublicProfileState) _then) =
      _$EditPublicProfileStateCopyWithImpl;
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String bio,
      File? coverImage,
      File? profileImage,
      bool isSubmitting,
      bool isPublic,
      bool isSuccess,
      String? errorMessage});
}

/// @nodoc
class _$EditPublicProfileStateCopyWithImpl<$Res>
    implements $EditPublicProfileStateCopyWith<$Res> {
  _$EditPublicProfileStateCopyWithImpl(this._self, this._then);

  final EditPublicProfileState _self;
  final $Res Function(EditPublicProfileState) _then;

  /// Create a copy of EditPublicProfileState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? bio = null,
    Object? coverImage = freezed,
    Object? profileImage = freezed,
    Object? isSubmitting = null,
    Object? isPublic = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_self.copyWith(
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _self.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as File?,
      profileImage: freezed == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as File?,
      isSubmitting: null == isSubmitting
          ? _self.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _self.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// Adds pattern-matching-related methods to [EditPublicProfileState].
extension EditPublicProfileStatePatterns on EditPublicProfileState {
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
    TResult Function(_EditPublicProfileState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EditPublicProfileState() when $default != null:
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
    TResult Function(_EditPublicProfileState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditPublicProfileState():
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
    TResult? Function(_EditPublicProfileState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditPublicProfileState() when $default != null:
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
            String firstName,
            String lastName,
            String bio,
            File? coverImage,
            File? profileImage,
            bool isSubmitting,
            bool isPublic,
            bool isSuccess,
            String? errorMessage)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _EditPublicProfileState() when $default != null:
        return $default(
            _that.firstName,
            _that.lastName,
            _that.bio,
            _that.coverImage,
            _that.profileImage,
            _that.isSubmitting,
            _that.isPublic,
            _that.isSuccess,
            _that.errorMessage);
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
            String firstName,
            String lastName,
            String bio,
            File? coverImage,
            File? profileImage,
            bool isSubmitting,
            bool isPublic,
            bool isSuccess,
            String? errorMessage)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditPublicProfileState():
        return $default(
            _that.firstName,
            _that.lastName,
            _that.bio,
            _that.coverImage,
            _that.profileImage,
            _that.isSubmitting,
            _that.isPublic,
            _that.isSuccess,
            _that.errorMessage);
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
            String firstName,
            String lastName,
            String bio,
            File? coverImage,
            File? profileImage,
            bool isSubmitting,
            bool isPublic,
            bool isSuccess,
            String? errorMessage)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _EditPublicProfileState() when $default != null:
        return $default(
            _that.firstName,
            _that.lastName,
            _that.bio,
            _that.coverImage,
            _that.profileImage,
            _that.isSubmitting,
            _that.isPublic,
            _that.isSuccess,
            _that.errorMessage);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _EditPublicProfileState
    with DiagnosticableTreeMixin
    implements EditPublicProfileState {
  const _EditPublicProfileState(
      {this.firstName = '',
      this.lastName = '',
      this.bio = '',
      this.coverImage,
      this.profileImage,
      this.isSubmitting = false,
      this.isPublic = true,
      this.isSuccess = false,
      this.errorMessage});

  @override
  @JsonKey()
  final String firstName;
  @override
  @JsonKey()
  final String lastName;
  @override
  @JsonKey()
  final String bio;
  @override
  final File? coverImage;
  @override
  final File? profileImage;
  @override
  @JsonKey()
  final bool isSubmitting;
  @override
  @JsonKey()
  final bool isPublic;
  @override
  @JsonKey()
  final bool isSuccess;
  @override
  final String? errorMessage;

  /// Create a copy of EditPublicProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$EditPublicProfileStateCopyWith<_EditPublicProfileState> get copyWith =>
      __$EditPublicProfileStateCopyWithImpl<_EditPublicProfileState>(
          this, _$identity);

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    properties
      ..add(DiagnosticsProperty('type', 'EditPublicProfileState'))
      ..add(DiagnosticsProperty('firstName', firstName))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('bio', bio))
      ..add(DiagnosticsProperty('coverImage', coverImage))
      ..add(DiagnosticsProperty('profileImage', profileImage))
      ..add(DiagnosticsProperty('isSubmitting', isSubmitting))
      ..add(DiagnosticsProperty('isPublic', isPublic))
      ..add(DiagnosticsProperty('isSuccess', isSuccess))
      ..add(DiagnosticsProperty('errorMessage', errorMessage));
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _EditPublicProfileState &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.bio, bio) || other.bio == bio) &&
            (identical(other.coverImage, coverImage) ||
                other.coverImage == coverImage) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            (identical(other.isSubmitting, isSubmitting) ||
                other.isSubmitting == isSubmitting) &&
            (identical(other.isPublic, isPublic) ||
                other.isPublic == isPublic) &&
            (identical(other.isSuccess, isSuccess) ||
                other.isSuccess == isSuccess) &&
            (identical(other.errorMessage, errorMessage) ||
                other.errorMessage == errorMessage));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      firstName,
      lastName,
      bio,
      coverImage,
      profileImage,
      isSubmitting,
      isPublic,
      isSuccess,
      errorMessage);

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'EditPublicProfileState(firstName: $firstName, lastName: $lastName, bio: $bio, coverImage: $coverImage, profileImage: $profileImage, isSubmitting: $isSubmitting, isPublic: $isPublic, isSuccess: $isSuccess, errorMessage: $errorMessage)';
  }
}

/// @nodoc
abstract mixin class _$EditPublicProfileStateCopyWith<$Res>
    implements $EditPublicProfileStateCopyWith<$Res> {
  factory _$EditPublicProfileStateCopyWith(_EditPublicProfileState value,
          $Res Function(_EditPublicProfileState) _then) =
      __$EditPublicProfileStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String firstName,
      String lastName,
      String bio,
      File? coverImage,
      File? profileImage,
      bool isSubmitting,
      bool isPublic,
      bool isSuccess,
      String? errorMessage});
}

/// @nodoc
class __$EditPublicProfileStateCopyWithImpl<$Res>
    implements _$EditPublicProfileStateCopyWith<$Res> {
  __$EditPublicProfileStateCopyWithImpl(this._self, this._then);

  final _EditPublicProfileState _self;
  final $Res Function(_EditPublicProfileState) _then;

  /// Create a copy of EditPublicProfileState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? firstName = null,
    Object? lastName = null,
    Object? bio = null,
    Object? coverImage = freezed,
    Object? profileImage = freezed,
    Object? isSubmitting = null,
    Object? isPublic = null,
    Object? isSuccess = null,
    Object? errorMessage = freezed,
  }) {
    return _then(_EditPublicProfileState(
      firstName: null == firstName
          ? _self.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: null == lastName
          ? _self.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      bio: null == bio
          ? _self.bio
          : bio // ignore: cast_nullable_to_non_nullable
              as String,
      coverImage: freezed == coverImage
          ? _self.coverImage
          : coverImage // ignore: cast_nullable_to_non_nullable
              as File?,
      profileImage: freezed == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as File?,
      isSubmitting: null == isSubmitting
          ? _self.isSubmitting
          : isSubmitting // ignore: cast_nullable_to_non_nullable
              as bool,
      isPublic: null == isPublic
          ? _self.isPublic
          : isPublic // ignore: cast_nullable_to_non_nullable
              as bool,
      isSuccess: null == isSuccess
          ? _self.isSuccess
          : isSuccess // ignore: cast_nullable_to_non_nullable
              as bool,
      errorMessage: freezed == errorMessage
          ? _self.errorMessage
          : errorMessage // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

// dart format on
