// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sign_up_form_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SignUpFormState {
  String? get firstNameError;
  String? get lastNameError;
  String? get usernameError;
  String? get emailError;
  String? get passwordError;
  String? get confirmPasswordError;
  String? get dateOfBirthError;
  DateTime? get dateOfBirth;
  bool get isLoading;
  String? get bioError;
  int get currentStep;
  bool get acceptedTerms;
  bool get acceptedPrivacy;
  Map<String, dynamic> get deviceInfo;
  File? get profileImage;
  List<String> get selectedInterests;

  /// Create a copy of SignUpFormState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $SignUpFormStateCopyWith<SignUpFormState> get copyWith =>
      _$SignUpFormStateCopyWithImpl<SignUpFormState>(
          this as SignUpFormState, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is SignUpFormState &&
            (identical(other.firstNameError, firstNameError) ||
                other.firstNameError == firstNameError) &&
            (identical(other.lastNameError, lastNameError) ||
                other.lastNameError == lastNameError) &&
            (identical(other.usernameError, usernameError) ||
                other.usernameError == usernameError) &&
            (identical(other.emailError, emailError) ||
                other.emailError == emailError) &&
            (identical(other.passwordError, passwordError) ||
                other.passwordError == passwordError) &&
            (identical(other.confirmPasswordError, confirmPasswordError) ||
                other.confirmPasswordError == confirmPasswordError) &&
            (identical(other.dateOfBirthError, dateOfBirthError) ||
                other.dateOfBirthError == dateOfBirthError) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.bioError, bioError) ||
                other.bioError == bioError) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.acceptedTerms, acceptedTerms) ||
                other.acceptedTerms == acceptedTerms) &&
            (identical(other.acceptedPrivacy, acceptedPrivacy) ||
                other.acceptedPrivacy == acceptedPrivacy) &&
            const DeepCollectionEquality()
                .equals(other.deviceInfo, deviceInfo) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            const DeepCollectionEquality()
                .equals(other.selectedInterests, selectedInterests));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      firstNameError,
      lastNameError,
      usernameError,
      emailError,
      passwordError,
      confirmPasswordError,
      dateOfBirthError,
      dateOfBirth,
      isLoading,
      bioError,
      currentStep,
      acceptedTerms,
      acceptedPrivacy,
      const DeepCollectionEquality().hash(deviceInfo),
      profileImage,
      const DeepCollectionEquality().hash(selectedInterests));

  @override
  String toString() {
    return 'SignUpFormState(firstNameError: $firstNameError, lastNameError: $lastNameError, usernameError: $usernameError, emailError: $emailError, passwordError: $passwordError, confirmPasswordError: $confirmPasswordError, dateOfBirthError: $dateOfBirthError, dateOfBirth: $dateOfBirth, isLoading: $isLoading, bioError: $bioError, currentStep: $currentStep, acceptedTerms: $acceptedTerms, acceptedPrivacy: $acceptedPrivacy, deviceInfo: $deviceInfo, profileImage: $profileImage, selectedInterests: $selectedInterests)';
  }
}

/// @nodoc
abstract mixin class $SignUpFormStateCopyWith<$Res> {
  factory $SignUpFormStateCopyWith(
          SignUpFormState value, $Res Function(SignUpFormState) _then) =
      _$SignUpFormStateCopyWithImpl;
  @useResult
  $Res call(
      {String? firstNameError,
      String? lastNameError,
      String? usernameError,
      String? emailError,
      String? passwordError,
      String? confirmPasswordError,
      String? dateOfBirthError,
      DateTime? dateOfBirth,
      bool isLoading,
      String? bioError,
      int currentStep,
      bool acceptedTerms,
      bool acceptedPrivacy,
      Map<String, dynamic> deviceInfo,
      File? profileImage,
      List<String> selectedInterests});
}

/// @nodoc
class _$SignUpFormStateCopyWithImpl<$Res>
    implements $SignUpFormStateCopyWith<$Res> {
  _$SignUpFormStateCopyWithImpl(this._self, this._then);

  final SignUpFormState _self;
  final $Res Function(SignUpFormState) _then;

  /// Create a copy of SignUpFormState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? firstNameError = freezed,
    Object? lastNameError = freezed,
    Object? usernameError = freezed,
    Object? emailError = freezed,
    Object? passwordError = freezed,
    Object? confirmPasswordError = freezed,
    Object? dateOfBirthError = freezed,
    Object? dateOfBirth = freezed,
    Object? isLoading = null,
    Object? bioError = freezed,
    Object? currentStep = null,
    Object? acceptedTerms = null,
    Object? acceptedPrivacy = null,
    Object? deviceInfo = null,
    Object? profileImage = freezed,
    Object? selectedInterests = null,
  }) {
    return _then(_self.copyWith(
      firstNameError: freezed == firstNameError
          ? _self.firstNameError
          : firstNameError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastNameError: freezed == lastNameError
          ? _self.lastNameError
          : lastNameError // ignore: cast_nullable_to_non_nullable
              as String?,
      usernameError: freezed == usernameError
          ? _self.usernameError
          : usernameError // ignore: cast_nullable_to_non_nullable
              as String?,
      emailError: freezed == emailError
          ? _self.emailError
          : emailError // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordError: freezed == passwordError
          ? _self.passwordError
          : passwordError // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmPasswordError: freezed == confirmPasswordError
          ? _self.confirmPasswordError
          : confirmPasswordError // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirthError: freezed == dateOfBirthError
          ? _self.dateOfBirthError
          : dateOfBirthError // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _self.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      bioError: freezed == bioError
          ? _self.bioError
          : bioError // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStep: null == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedTerms: null == acceptedTerms
          ? _self.acceptedTerms
          : acceptedTerms // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptedPrivacy: null == acceptedPrivacy
          ? _self.acceptedPrivacy
          : acceptedPrivacy // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceInfo: null == deviceInfo
          ? _self.deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      profileImage: freezed == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as File?,
      selectedInterests: null == selectedInterests
          ? _self.selectedInterests
          : selectedInterests // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

/// Adds pattern-matching-related methods to [SignUpFormState].
extension SignUpFormStatePatterns on SignUpFormState {
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
    TResult Function(_SignUpFormState value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SignUpFormState() when $default != null:
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
    TResult Function(_SignUpFormState value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpFormState():
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
    TResult? Function(_SignUpFormState value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpFormState() when $default != null:
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
            String? firstNameError,
            String? lastNameError,
            String? usernameError,
            String? emailError,
            String? passwordError,
            String? confirmPasswordError,
            String? dateOfBirthError,
            DateTime? dateOfBirth,
            bool isLoading,
            String? bioError,
            int currentStep,
            bool acceptedTerms,
            bool acceptedPrivacy,
            Map<String, dynamic> deviceInfo,
            File? profileImage,
            List<String> selectedInterests)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _SignUpFormState() when $default != null:
        return $default(
            _that.firstNameError,
            _that.lastNameError,
            _that.usernameError,
            _that.emailError,
            _that.passwordError,
            _that.confirmPasswordError,
            _that.dateOfBirthError,
            _that.dateOfBirth,
            _that.isLoading,
            _that.bioError,
            _that.currentStep,
            _that.acceptedTerms,
            _that.acceptedPrivacy,
            _that.deviceInfo,
            _that.profileImage,
            _that.selectedInterests);
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
            String? firstNameError,
            String? lastNameError,
            String? usernameError,
            String? emailError,
            String? passwordError,
            String? confirmPasswordError,
            String? dateOfBirthError,
            DateTime? dateOfBirth,
            bool isLoading,
            String? bioError,
            int currentStep,
            bool acceptedTerms,
            bool acceptedPrivacy,
            Map<String, dynamic> deviceInfo,
            File? profileImage,
            List<String> selectedInterests)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpFormState():
        return $default(
            _that.firstNameError,
            _that.lastNameError,
            _that.usernameError,
            _that.emailError,
            _that.passwordError,
            _that.confirmPasswordError,
            _that.dateOfBirthError,
            _that.dateOfBirth,
            _that.isLoading,
            _that.bioError,
            _that.currentStep,
            _that.acceptedTerms,
            _that.acceptedPrivacy,
            _that.deviceInfo,
            _that.profileImage,
            _that.selectedInterests);
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
            String? firstNameError,
            String? lastNameError,
            String? usernameError,
            String? emailError,
            String? passwordError,
            String? confirmPasswordError,
            String? dateOfBirthError,
            DateTime? dateOfBirth,
            bool isLoading,
            String? bioError,
            int currentStep,
            bool acceptedTerms,
            bool acceptedPrivacy,
            Map<String, dynamic> deviceInfo,
            File? profileImage,
            List<String> selectedInterests)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _SignUpFormState() when $default != null:
        return $default(
            _that.firstNameError,
            _that.lastNameError,
            _that.usernameError,
            _that.emailError,
            _that.passwordError,
            _that.confirmPasswordError,
            _that.dateOfBirthError,
            _that.dateOfBirth,
            _that.isLoading,
            _that.bioError,
            _that.currentStep,
            _that.acceptedTerms,
            _that.acceptedPrivacy,
            _that.deviceInfo,
            _that.profileImage,
            _that.selectedInterests);
      case _:
        return null;
    }
  }
}

/// @nodoc

class _SignUpFormState implements SignUpFormState {
  const _SignUpFormState(
      {this.firstNameError,
      this.lastNameError,
      this.usernameError,
      this.emailError,
      this.passwordError,
      this.confirmPasswordError,
      this.dateOfBirthError,
      this.dateOfBirth,
      this.isLoading = false,
      this.bioError,
      this.currentStep = 0,
      this.acceptedTerms = false,
      this.acceptedPrivacy = false,
      final Map<String, dynamic> deviceInfo = const {},
      this.profileImage,
      final List<String> selectedInterests = const []})
      : _deviceInfo = deviceInfo,
        _selectedInterests = selectedInterests;

  @override
  final String? firstNameError;
  @override
  final String? lastNameError;
  @override
  final String? usernameError;
  @override
  final String? emailError;
  @override
  final String? passwordError;
  @override
  final String? confirmPasswordError;
  @override
  final String? dateOfBirthError;
  @override
  final DateTime? dateOfBirth;
  @override
  @JsonKey()
  final bool isLoading;
  @override
  final String? bioError;
  @override
  @JsonKey()
  final int currentStep;
  @override
  @JsonKey()
  final bool acceptedTerms;
  @override
  @JsonKey()
  final bool acceptedPrivacy;
  final Map<String, dynamic> _deviceInfo;
  @override
  @JsonKey()
  Map<String, dynamic> get deviceInfo {
    if (_deviceInfo is EqualUnmodifiableMapView) return _deviceInfo;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_deviceInfo);
  }

  @override
  final File? profileImage;
  final List<String> _selectedInterests;
  @override
  @JsonKey()
  List<String> get selectedInterests {
    if (_selectedInterests is EqualUnmodifiableListView)
      return _selectedInterests;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedInterests);
  }

  /// Create a copy of SignUpFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$SignUpFormStateCopyWith<_SignUpFormState> get copyWith =>
      __$SignUpFormStateCopyWithImpl<_SignUpFormState>(this, _$identity);

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _SignUpFormState &&
            (identical(other.firstNameError, firstNameError) ||
                other.firstNameError == firstNameError) &&
            (identical(other.lastNameError, lastNameError) ||
                other.lastNameError == lastNameError) &&
            (identical(other.usernameError, usernameError) ||
                other.usernameError == usernameError) &&
            (identical(other.emailError, emailError) ||
                other.emailError == emailError) &&
            (identical(other.passwordError, passwordError) ||
                other.passwordError == passwordError) &&
            (identical(other.confirmPasswordError, confirmPasswordError) ||
                other.confirmPasswordError == confirmPasswordError) &&
            (identical(other.dateOfBirthError, dateOfBirthError) ||
                other.dateOfBirthError == dateOfBirthError) &&
            (identical(other.dateOfBirth, dateOfBirth) ||
                other.dateOfBirth == dateOfBirth) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.bioError, bioError) ||
                other.bioError == bioError) &&
            (identical(other.currentStep, currentStep) ||
                other.currentStep == currentStep) &&
            (identical(other.acceptedTerms, acceptedTerms) ||
                other.acceptedTerms == acceptedTerms) &&
            (identical(other.acceptedPrivacy, acceptedPrivacy) ||
                other.acceptedPrivacy == acceptedPrivacy) &&
            const DeepCollectionEquality()
                .equals(other._deviceInfo, _deviceInfo) &&
            (identical(other.profileImage, profileImage) ||
                other.profileImage == profileImage) &&
            const DeepCollectionEquality()
                .equals(other._selectedInterests, _selectedInterests));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      firstNameError,
      lastNameError,
      usernameError,
      emailError,
      passwordError,
      confirmPasswordError,
      dateOfBirthError,
      dateOfBirth,
      isLoading,
      bioError,
      currentStep,
      acceptedTerms,
      acceptedPrivacy,
      const DeepCollectionEquality().hash(_deviceInfo),
      profileImage,
      const DeepCollectionEquality().hash(_selectedInterests));

  @override
  String toString() {
    return 'SignUpFormState(firstNameError: $firstNameError, lastNameError: $lastNameError, usernameError: $usernameError, emailError: $emailError, passwordError: $passwordError, confirmPasswordError: $confirmPasswordError, dateOfBirthError: $dateOfBirthError, dateOfBirth: $dateOfBirth, isLoading: $isLoading, bioError: $bioError, currentStep: $currentStep, acceptedTerms: $acceptedTerms, acceptedPrivacy: $acceptedPrivacy, deviceInfo: $deviceInfo, profileImage: $profileImage, selectedInterests: $selectedInterests)';
  }
}

/// @nodoc
abstract mixin class _$SignUpFormStateCopyWith<$Res>
    implements $SignUpFormStateCopyWith<$Res> {
  factory _$SignUpFormStateCopyWith(
          _SignUpFormState value, $Res Function(_SignUpFormState) _then) =
      __$SignUpFormStateCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? firstNameError,
      String? lastNameError,
      String? usernameError,
      String? emailError,
      String? passwordError,
      String? confirmPasswordError,
      String? dateOfBirthError,
      DateTime? dateOfBirth,
      bool isLoading,
      String? bioError,
      int currentStep,
      bool acceptedTerms,
      bool acceptedPrivacy,
      Map<String, dynamic> deviceInfo,
      File? profileImage,
      List<String> selectedInterests});
}

/// @nodoc
class __$SignUpFormStateCopyWithImpl<$Res>
    implements _$SignUpFormStateCopyWith<$Res> {
  __$SignUpFormStateCopyWithImpl(this._self, this._then);

  final _SignUpFormState _self;
  final $Res Function(_SignUpFormState) _then;

  /// Create a copy of SignUpFormState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? firstNameError = freezed,
    Object? lastNameError = freezed,
    Object? usernameError = freezed,
    Object? emailError = freezed,
    Object? passwordError = freezed,
    Object? confirmPasswordError = freezed,
    Object? dateOfBirthError = freezed,
    Object? dateOfBirth = freezed,
    Object? isLoading = null,
    Object? bioError = freezed,
    Object? currentStep = null,
    Object? acceptedTerms = null,
    Object? acceptedPrivacy = null,
    Object? deviceInfo = null,
    Object? profileImage = freezed,
    Object? selectedInterests = null,
  }) {
    return _then(_SignUpFormState(
      firstNameError: freezed == firstNameError
          ? _self.firstNameError
          : firstNameError // ignore: cast_nullable_to_non_nullable
              as String?,
      lastNameError: freezed == lastNameError
          ? _self.lastNameError
          : lastNameError // ignore: cast_nullable_to_non_nullable
              as String?,
      usernameError: freezed == usernameError
          ? _self.usernameError
          : usernameError // ignore: cast_nullable_to_non_nullable
              as String?,
      emailError: freezed == emailError
          ? _self.emailError
          : emailError // ignore: cast_nullable_to_non_nullable
              as String?,
      passwordError: freezed == passwordError
          ? _self.passwordError
          : passwordError // ignore: cast_nullable_to_non_nullable
              as String?,
      confirmPasswordError: freezed == confirmPasswordError
          ? _self.confirmPasswordError
          : confirmPasswordError // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirthError: freezed == dateOfBirthError
          ? _self.dateOfBirthError
          : dateOfBirthError // ignore: cast_nullable_to_non_nullable
              as String?,
      dateOfBirth: freezed == dateOfBirth
          ? _self.dateOfBirth
          : dateOfBirth // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isLoading: null == isLoading
          ? _self.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      bioError: freezed == bioError
          ? _self.bioError
          : bioError // ignore: cast_nullable_to_non_nullable
              as String?,
      currentStep: null == currentStep
          ? _self.currentStep
          : currentStep // ignore: cast_nullable_to_non_nullable
              as int,
      acceptedTerms: null == acceptedTerms
          ? _self.acceptedTerms
          : acceptedTerms // ignore: cast_nullable_to_non_nullable
              as bool,
      acceptedPrivacy: null == acceptedPrivacy
          ? _self.acceptedPrivacy
          : acceptedPrivacy // ignore: cast_nullable_to_non_nullable
              as bool,
      deviceInfo: null == deviceInfo
          ? _self._deviceInfo
          : deviceInfo // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      profileImage: freezed == profileImage
          ? _self.profileImage
          : profileImage // ignore: cast_nullable_to_non_nullable
              as File?,
      selectedInterests: null == selectedInterests
          ? _self._selectedInterests
          : selectedInterests // ignore: cast_nullable_to_non_nullable
              as List<String>,
    ));
  }
}

// dart format on
