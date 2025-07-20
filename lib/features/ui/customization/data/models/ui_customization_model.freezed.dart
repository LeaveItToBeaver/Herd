// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ui_customization_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UICustomizationModel {
  String get userId;
  @TimestampOrStringDateTimeConverter()
  DateTime get lastUpdated; // Global App Theme Settings
  AppThemeSettings get appTheme; // Profile Page Customization
  ProfileCustomization get profileCustomization; // Component Styles
  ComponentStyles get componentStyles; // Layout Preferences
  LayoutPreferences get layoutPreferences; // Animation Settings
  AnimationSettings get animationSettings; // Typography Settings
  TypographySettings get typography;

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $UICustomizationModelCopyWith<UICustomizationModel> get copyWith =>
      _$UICustomizationModelCopyWithImpl<UICustomizationModel>(
          this as UICustomizationModel, _$identity);

  /// Serializes this UICustomizationModel to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is UICustomizationModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.appTheme, appTheme) ||
                other.appTheme == appTheme) &&
            (identical(other.profileCustomization, profileCustomization) ||
                other.profileCustomization == profileCustomization) &&
            (identical(other.componentStyles, componentStyles) ||
                other.componentStyles == componentStyles) &&
            (identical(other.layoutPreferences, layoutPreferences) ||
                other.layoutPreferences == layoutPreferences) &&
            (identical(other.animationSettings, animationSettings) ||
                other.animationSettings == animationSettings) &&
            (identical(other.typography, typography) ||
                other.typography == typography));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      lastUpdated,
      appTheme,
      profileCustomization,
      componentStyles,
      layoutPreferences,
      animationSettings,
      typography);

  @override
  String toString() {
    return 'UICustomizationModel(userId: $userId, lastUpdated: $lastUpdated, appTheme: $appTheme, profileCustomization: $profileCustomization, componentStyles: $componentStyles, layoutPreferences: $layoutPreferences, animationSettings: $animationSettings, typography: $typography)';
  }
}

/// @nodoc
abstract mixin class $UICustomizationModelCopyWith<$Res> {
  factory $UICustomizationModelCopyWith(UICustomizationModel value,
          $Res Function(UICustomizationModel) _then) =
      _$UICustomizationModelCopyWithImpl;
  @useResult
  $Res call(
      {String userId,
      @TimestampOrStringDateTimeConverter() DateTime lastUpdated,
      AppThemeSettings appTheme,
      ProfileCustomization profileCustomization,
      ComponentStyles componentStyles,
      LayoutPreferences layoutPreferences,
      AnimationSettings animationSettings,
      TypographySettings typography});

  $AppThemeSettingsCopyWith<$Res> get appTheme;
  $ProfileCustomizationCopyWith<$Res> get profileCustomization;
  $ComponentStylesCopyWith<$Res> get componentStyles;
  $LayoutPreferencesCopyWith<$Res> get layoutPreferences;
  $AnimationSettingsCopyWith<$Res> get animationSettings;
  $TypographySettingsCopyWith<$Res> get typography;
}

/// @nodoc
class _$UICustomizationModelCopyWithImpl<$Res>
    implements $UICustomizationModelCopyWith<$Res> {
  _$UICustomizationModelCopyWithImpl(this._self, this._then);

  final UICustomizationModel _self;
  final $Res Function(UICustomizationModel) _then;

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? lastUpdated = null,
    Object? appTheme = null,
    Object? profileCustomization = null,
    Object? componentStyles = null,
    Object? layoutPreferences = null,
    Object? animationSettings = null,
    Object? typography = null,
  }) {
    return _then(_self.copyWith(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      appTheme: null == appTheme
          ? _self.appTheme
          : appTheme // ignore: cast_nullable_to_non_nullable
              as AppThemeSettings,
      profileCustomization: null == profileCustomization
          ? _self.profileCustomization
          : profileCustomization // ignore: cast_nullable_to_non_nullable
              as ProfileCustomization,
      componentStyles: null == componentStyles
          ? _self.componentStyles
          : componentStyles // ignore: cast_nullable_to_non_nullable
              as ComponentStyles,
      layoutPreferences: null == layoutPreferences
          ? _self.layoutPreferences
          : layoutPreferences // ignore: cast_nullable_to_non_nullable
              as LayoutPreferences,
      animationSettings: null == animationSettings
          ? _self.animationSettings
          : animationSettings // ignore: cast_nullable_to_non_nullable
              as AnimationSettings,
      typography: null == typography
          ? _self.typography
          : typography // ignore: cast_nullable_to_non_nullable
              as TypographySettings,
    ));
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppThemeSettingsCopyWith<$Res> get appTheme {
    return $AppThemeSettingsCopyWith<$Res>(_self.appTheme, (value) {
      return _then(_self.copyWith(appTheme: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCustomizationCopyWith<$Res> get profileCustomization {
    return $ProfileCustomizationCopyWith<$Res>(_self.profileCustomization,
        (value) {
      return _then(_self.copyWith(profileCustomization: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ComponentStylesCopyWith<$Res> get componentStyles {
    return $ComponentStylesCopyWith<$Res>(_self.componentStyles, (value) {
      return _then(_self.copyWith(componentStyles: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutPreferencesCopyWith<$Res> get layoutPreferences {
    return $LayoutPreferencesCopyWith<$Res>(_self.layoutPreferences, (value) {
      return _then(_self.copyWith(layoutPreferences: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnimationSettingsCopyWith<$Res> get animationSettings {
    return $AnimationSettingsCopyWith<$Res>(_self.animationSettings, (value) {
      return _then(_self.copyWith(animationSettings: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TypographySettingsCopyWith<$Res> get typography {
    return $TypographySettingsCopyWith<$Res>(_self.typography, (value) {
      return _then(_self.copyWith(typography: value));
    });
  }
}

/// Adds pattern-matching-related methods to [UICustomizationModel].
extension UICustomizationModelPatterns on UICustomizationModel {
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
    TResult Function(_UICustomizationModel value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UICustomizationModel() when $default != null:
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
    TResult Function(_UICustomizationModel value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UICustomizationModel():
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
    TResult? Function(_UICustomizationModel value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UICustomizationModel() when $default != null:
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
            String userId,
            @TimestampOrStringDateTimeConverter() DateTime lastUpdated,
            AppThemeSettings appTheme,
            ProfileCustomization profileCustomization,
            ComponentStyles componentStyles,
            LayoutPreferences layoutPreferences,
            AnimationSettings animationSettings,
            TypographySettings typography)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _UICustomizationModel() when $default != null:
        return $default(
            _that.userId,
            _that.lastUpdated,
            _that.appTheme,
            _that.profileCustomization,
            _that.componentStyles,
            _that.layoutPreferences,
            _that.animationSettings,
            _that.typography);
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
            String userId,
            @TimestampOrStringDateTimeConverter() DateTime lastUpdated,
            AppThemeSettings appTheme,
            ProfileCustomization profileCustomization,
            ComponentStyles componentStyles,
            LayoutPreferences layoutPreferences,
            AnimationSettings animationSettings,
            TypographySettings typography)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UICustomizationModel():
        return $default(
            _that.userId,
            _that.lastUpdated,
            _that.appTheme,
            _that.profileCustomization,
            _that.componentStyles,
            _that.layoutPreferences,
            _that.animationSettings,
            _that.typography);
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
            String userId,
            @TimestampOrStringDateTimeConverter() DateTime lastUpdated,
            AppThemeSettings appTheme,
            ProfileCustomization profileCustomization,
            ComponentStyles componentStyles,
            LayoutPreferences layoutPreferences,
            AnimationSettings animationSettings,
            TypographySettings typography)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _UICustomizationModel() when $default != null:
        return $default(
            _that.userId,
            _that.lastUpdated,
            _that.appTheme,
            _that.profileCustomization,
            _that.componentStyles,
            _that.layoutPreferences,
            _that.animationSettings,
            _that.typography);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _UICustomizationModel extends UICustomizationModel {
  const _UICustomizationModel(
      {required this.userId,
      @TimestampOrStringDateTimeConverter() required this.lastUpdated,
      this.appTheme = const AppThemeSettings(),
      this.profileCustomization = const ProfileCustomization(),
      this.componentStyles = const ComponentStyles(),
      this.layoutPreferences = const LayoutPreferences(),
      this.animationSettings = const AnimationSettings(),
      this.typography = const TypographySettings()})
      : super._();
  factory _UICustomizationModel.fromJson(Map<String, dynamic> json) =>
      _$UICustomizationModelFromJson(json);

  @override
  final String userId;
  @override
  @TimestampOrStringDateTimeConverter()
  final DateTime lastUpdated;
// Global App Theme Settings
  @override
  @JsonKey()
  final AppThemeSettings appTheme;
// Profile Page Customization
  @override
  @JsonKey()
  final ProfileCustomization profileCustomization;
// Component Styles
  @override
  @JsonKey()
  final ComponentStyles componentStyles;
// Layout Preferences
  @override
  @JsonKey()
  final LayoutPreferences layoutPreferences;
// Animation Settings
  @override
  @JsonKey()
  final AnimationSettings animationSettings;
// Typography Settings
  @override
  @JsonKey()
  final TypographySettings typography;

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$UICustomizationModelCopyWith<_UICustomizationModel> get copyWith =>
      __$UICustomizationModelCopyWithImpl<_UICustomizationModel>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$UICustomizationModelToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _UICustomizationModel &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.lastUpdated, lastUpdated) ||
                other.lastUpdated == lastUpdated) &&
            (identical(other.appTheme, appTheme) ||
                other.appTheme == appTheme) &&
            (identical(other.profileCustomization, profileCustomization) ||
                other.profileCustomization == profileCustomization) &&
            (identical(other.componentStyles, componentStyles) ||
                other.componentStyles == componentStyles) &&
            (identical(other.layoutPreferences, layoutPreferences) ||
                other.layoutPreferences == layoutPreferences) &&
            (identical(other.animationSettings, animationSettings) ||
                other.animationSettings == animationSettings) &&
            (identical(other.typography, typography) ||
                other.typography == typography));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      userId,
      lastUpdated,
      appTheme,
      profileCustomization,
      componentStyles,
      layoutPreferences,
      animationSettings,
      typography);

  @override
  String toString() {
    return 'UICustomizationModel(userId: $userId, lastUpdated: $lastUpdated, appTheme: $appTheme, profileCustomization: $profileCustomization, componentStyles: $componentStyles, layoutPreferences: $layoutPreferences, animationSettings: $animationSettings, typography: $typography)';
  }
}

/// @nodoc
abstract mixin class _$UICustomizationModelCopyWith<$Res>
    implements $UICustomizationModelCopyWith<$Res> {
  factory _$UICustomizationModelCopyWith(_UICustomizationModel value,
          $Res Function(_UICustomizationModel) _then) =
      __$UICustomizationModelCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String userId,
      @TimestampOrStringDateTimeConverter() DateTime lastUpdated,
      AppThemeSettings appTheme,
      ProfileCustomization profileCustomization,
      ComponentStyles componentStyles,
      LayoutPreferences layoutPreferences,
      AnimationSettings animationSettings,
      TypographySettings typography});

  @override
  $AppThemeSettingsCopyWith<$Res> get appTheme;
  @override
  $ProfileCustomizationCopyWith<$Res> get profileCustomization;
  @override
  $ComponentStylesCopyWith<$Res> get componentStyles;
  @override
  $LayoutPreferencesCopyWith<$Res> get layoutPreferences;
  @override
  $AnimationSettingsCopyWith<$Res> get animationSettings;
  @override
  $TypographySettingsCopyWith<$Res> get typography;
}

/// @nodoc
class __$UICustomizationModelCopyWithImpl<$Res>
    implements _$UICustomizationModelCopyWith<$Res> {
  __$UICustomizationModelCopyWithImpl(this._self, this._then);

  final _UICustomizationModel _self;
  final $Res Function(_UICustomizationModel) _then;

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? userId = null,
    Object? lastUpdated = null,
    Object? appTheme = null,
    Object? profileCustomization = null,
    Object? componentStyles = null,
    Object? layoutPreferences = null,
    Object? animationSettings = null,
    Object? typography = null,
  }) {
    return _then(_UICustomizationModel(
      userId: null == userId
          ? _self.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      lastUpdated: null == lastUpdated
          ? _self.lastUpdated
          : lastUpdated // ignore: cast_nullable_to_non_nullable
              as DateTime,
      appTheme: null == appTheme
          ? _self.appTheme
          : appTheme // ignore: cast_nullable_to_non_nullable
              as AppThemeSettings,
      profileCustomization: null == profileCustomization
          ? _self.profileCustomization
          : profileCustomization // ignore: cast_nullable_to_non_nullable
              as ProfileCustomization,
      componentStyles: null == componentStyles
          ? _self.componentStyles
          : componentStyles // ignore: cast_nullable_to_non_nullable
              as ComponentStyles,
      layoutPreferences: null == layoutPreferences
          ? _self.layoutPreferences
          : layoutPreferences // ignore: cast_nullable_to_non_nullable
              as LayoutPreferences,
      animationSettings: null == animationSettings
          ? _self.animationSettings
          : animationSettings // ignore: cast_nullable_to_non_nullable
              as AnimationSettings,
      typography: null == typography
          ? _self.typography
          : typography // ignore: cast_nullable_to_non_nullable
              as TypographySettings,
    ));
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AppThemeSettingsCopyWith<$Res> get appTheme {
    return $AppThemeSettingsCopyWith<$Res>(_self.appTheme, (value) {
      return _then(_self.copyWith(appTheme: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProfileCustomizationCopyWith<$Res> get profileCustomization {
    return $ProfileCustomizationCopyWith<$Res>(_self.profileCustomization,
        (value) {
      return _then(_self.copyWith(profileCustomization: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ComponentStylesCopyWith<$Res> get componentStyles {
    return $ComponentStylesCopyWith<$Res>(_self.componentStyles, (value) {
      return _then(_self.copyWith(componentStyles: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $LayoutPreferencesCopyWith<$Res> get layoutPreferences {
    return $LayoutPreferencesCopyWith<$Res>(_self.layoutPreferences, (value) {
      return _then(_self.copyWith(layoutPreferences: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $AnimationSettingsCopyWith<$Res> get animationSettings {
    return $AnimationSettingsCopyWith<$Res>(_self.animationSettings, (value) {
      return _then(_self.copyWith(animationSettings: value));
    });
  }

  /// Create a copy of UICustomizationModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TypographySettingsCopyWith<$Res> get typography {
    return $TypographySettingsCopyWith<$Res>(_self.typography, (value) {
      return _then(_self.copyWith(typography: value));
    });
  }
}

/// @nodoc
mixin _$AppThemeSettings {
// Core colors (stored as hex strings) with safe defaults
  String get primaryColor;
  String get secondaryColor;
  String get backgroundColor;
  String get surfaceColor;
  String get textColor;
  String get secondaryTextColor;
  String get errorColor;
  String get warningColor;
  String get successColor; // "On" Colors with safe defaults
  String get onPrimaryColor;
  String get onSecondaryColor;
  String get onBackgroundColor;
  String get onErrorColor;
  String get onSurfaceColor; // Container Colors with safe defaults
  String get primaryContainerColor;
  String get onPrimaryContainerColor;
  String get secondaryContainerColor;
  String get onSecondaryContainerColor;
  String get tertiaryContainerColor;
  String get onTertiaryContainerColor; // Tertiary Color
  String get tertiaryColor; // Utility Colors with safe defaults
  String get outlineColor;
  String get shadowColor;
  String get surfaceVariantColor;
  String get onSurfaceVariantColor;
  String get disabledColor;
  String get hintColor; // Theme mode as string with safe default
  String get themeMode;
  bool get useMaterial3; // Special effects with safe defaults
  bool get enableGlassmorphism;
  bool get enableGradients;
  bool get enableShadows; // Changed default to true
  double get shadowIntensity;

  /// Create a copy of AppThemeSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AppThemeSettingsCopyWith<AppThemeSettings> get copyWith =>
      _$AppThemeSettingsCopyWithImpl<AppThemeSettings>(
          this as AppThemeSettings, _$identity);

  /// Serializes this AppThemeSettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppThemeSettings &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.surfaceColor, surfaceColor) ||
                other.surfaceColor == surfaceColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.secondaryTextColor, secondaryTextColor) ||
                other.secondaryTextColor == secondaryTextColor) &&
            (identical(other.errorColor, errorColor) ||
                other.errorColor == errorColor) &&
            (identical(other.warningColor, warningColor) ||
                other.warningColor == warningColor) &&
            (identical(other.successColor, successColor) ||
                other.successColor == successColor) &&
            (identical(other.onPrimaryColor, onPrimaryColor) ||
                other.onPrimaryColor == onPrimaryColor) &&
            (identical(other.onSecondaryColor, onSecondaryColor) ||
                other.onSecondaryColor == onSecondaryColor) &&
            (identical(other.onBackgroundColor, onBackgroundColor) ||
                other.onBackgroundColor == onBackgroundColor) &&
            (identical(other.onErrorColor, onErrorColor) ||
                other.onErrorColor == onErrorColor) &&
            (identical(other.onSurfaceColor, onSurfaceColor) ||
                other.onSurfaceColor == onSurfaceColor) &&
            (identical(other.primaryContainerColor, primaryContainerColor) ||
                other.primaryContainerColor == primaryContainerColor) &&
            (identical(other.onPrimaryContainerColor, onPrimaryContainerColor) ||
                other.onPrimaryContainerColor == onPrimaryContainerColor) &&
            (identical(other.secondaryContainerColor, secondaryContainerColor) ||
                other.secondaryContainerColor == secondaryContainerColor) &&
            (identical(other.onSecondaryContainerColor, onSecondaryContainerColor) ||
                other.onSecondaryContainerColor == onSecondaryContainerColor) &&
            (identical(other.tertiaryContainerColor, tertiaryContainerColor) ||
                other.tertiaryContainerColor == tertiaryContainerColor) &&
            (identical(other.onTertiaryContainerColor, onTertiaryContainerColor) ||
                other.onTertiaryContainerColor == onTertiaryContainerColor) &&
            (identical(other.tertiaryColor, tertiaryColor) ||
                other.tertiaryColor == tertiaryColor) &&
            (identical(other.outlineColor, outlineColor) ||
                other.outlineColor == outlineColor) &&
            (identical(other.shadowColor, shadowColor) ||
                other.shadowColor == shadowColor) &&
            (identical(other.surfaceVariantColor, surfaceVariantColor) ||
                other.surfaceVariantColor == surfaceVariantColor) &&
            (identical(other.onSurfaceVariantColor, onSurfaceVariantColor) ||
                other.onSurfaceVariantColor == onSurfaceVariantColor) &&
            (identical(other.disabledColor, disabledColor) ||
                other.disabledColor == disabledColor) &&
            (identical(other.hintColor, hintColor) ||
                other.hintColor == hintColor) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.useMaterial3, useMaterial3) ||
                other.useMaterial3 == useMaterial3) &&
            (identical(other.enableGlassmorphism, enableGlassmorphism) ||
                other.enableGlassmorphism == enableGlassmorphism) &&
            (identical(other.enableGradients, enableGradients) ||
                other.enableGradients == enableGradients) &&
            (identical(other.enableShadows, enableShadows) ||
                other.enableShadows == enableShadows) &&
            (identical(other.shadowIntensity, shadowIntensity) || other.shadowIntensity == shadowIntensity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        primaryColor,
        secondaryColor,
        backgroundColor,
        surfaceColor,
        textColor,
        secondaryTextColor,
        errorColor,
        warningColor,
        successColor,
        onPrimaryColor,
        onSecondaryColor,
        onBackgroundColor,
        onErrorColor,
        onSurfaceColor,
        primaryContainerColor,
        onPrimaryContainerColor,
        secondaryContainerColor,
        onSecondaryContainerColor,
        tertiaryContainerColor,
        onTertiaryContainerColor,
        tertiaryColor,
        outlineColor,
        shadowColor,
        surfaceVariantColor,
        onSurfaceVariantColor,
        disabledColor,
        hintColor,
        themeMode,
        useMaterial3,
        enableGlassmorphism,
        enableGradients,
        enableShadows,
        shadowIntensity
      ]);

  @override
  String toString() {
    return 'AppThemeSettings(primaryColor: $primaryColor, secondaryColor: $secondaryColor, backgroundColor: $backgroundColor, surfaceColor: $surfaceColor, textColor: $textColor, secondaryTextColor: $secondaryTextColor, errorColor: $errorColor, warningColor: $warningColor, successColor: $successColor, onPrimaryColor: $onPrimaryColor, onSecondaryColor: $onSecondaryColor, onBackgroundColor: $onBackgroundColor, onErrorColor: $onErrorColor, onSurfaceColor: $onSurfaceColor, primaryContainerColor: $primaryContainerColor, onPrimaryContainerColor: $onPrimaryContainerColor, secondaryContainerColor: $secondaryContainerColor, onSecondaryContainerColor: $onSecondaryContainerColor, tertiaryContainerColor: $tertiaryContainerColor, onTertiaryContainerColor: $onTertiaryContainerColor, tertiaryColor: $tertiaryColor, outlineColor: $outlineColor, shadowColor: $shadowColor, surfaceVariantColor: $surfaceVariantColor, onSurfaceVariantColor: $onSurfaceVariantColor, disabledColor: $disabledColor, hintColor: $hintColor, themeMode: $themeMode, useMaterial3: $useMaterial3, enableGlassmorphism: $enableGlassmorphism, enableGradients: $enableGradients, enableShadows: $enableShadows, shadowIntensity: $shadowIntensity)';
  }
}

/// @nodoc
abstract mixin class $AppThemeSettingsCopyWith<$Res> {
  factory $AppThemeSettingsCopyWith(
          AppThemeSettings value, $Res Function(AppThemeSettings) _then) =
      _$AppThemeSettingsCopyWithImpl;
  @useResult
  $Res call(
      {String primaryColor,
      String secondaryColor,
      String backgroundColor,
      String surfaceColor,
      String textColor,
      String secondaryTextColor,
      String errorColor,
      String warningColor,
      String successColor,
      String onPrimaryColor,
      String onSecondaryColor,
      String onBackgroundColor,
      String onErrorColor,
      String onSurfaceColor,
      String primaryContainerColor,
      String onPrimaryContainerColor,
      String secondaryContainerColor,
      String onSecondaryContainerColor,
      String tertiaryContainerColor,
      String onTertiaryContainerColor,
      String tertiaryColor,
      String outlineColor,
      String shadowColor,
      String surfaceVariantColor,
      String onSurfaceVariantColor,
      String disabledColor,
      String hintColor,
      String themeMode,
      bool useMaterial3,
      bool enableGlassmorphism,
      bool enableGradients,
      bool enableShadows,
      double shadowIntensity});
}

/// @nodoc
class _$AppThemeSettingsCopyWithImpl<$Res>
    implements $AppThemeSettingsCopyWith<$Res> {
  _$AppThemeSettingsCopyWithImpl(this._self, this._then);

  final AppThemeSettings _self;
  final $Res Function(AppThemeSettings) _then;

  /// Create a copy of AppThemeSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? backgroundColor = null,
    Object? surfaceColor = null,
    Object? textColor = null,
    Object? secondaryTextColor = null,
    Object? errorColor = null,
    Object? warningColor = null,
    Object? successColor = null,
    Object? onPrimaryColor = null,
    Object? onSecondaryColor = null,
    Object? onBackgroundColor = null,
    Object? onErrorColor = null,
    Object? onSurfaceColor = null,
    Object? primaryContainerColor = null,
    Object? onPrimaryContainerColor = null,
    Object? secondaryContainerColor = null,
    Object? onSecondaryContainerColor = null,
    Object? tertiaryContainerColor = null,
    Object? onTertiaryContainerColor = null,
    Object? tertiaryColor = null,
    Object? outlineColor = null,
    Object? shadowColor = null,
    Object? surfaceVariantColor = null,
    Object? onSurfaceVariantColor = null,
    Object? disabledColor = null,
    Object? hintColor = null,
    Object? themeMode = null,
    Object? useMaterial3 = null,
    Object? enableGlassmorphism = null,
    Object? enableGradients = null,
    Object? enableShadows = null,
    Object? shadowIntensity = null,
  }) {
    return _then(_self.copyWith(
      primaryColor: null == primaryColor
          ? _self.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _self.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundColor: null == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceColor: null == surfaceColor
          ? _self.surfaceColor
          : surfaceColor // ignore: cast_nullable_to_non_nullable
              as String,
      textColor: null == textColor
          ? _self.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryTextColor: null == secondaryTextColor
          ? _self.secondaryTextColor
          : secondaryTextColor // ignore: cast_nullable_to_non_nullable
              as String,
      errorColor: null == errorColor
          ? _self.errorColor
          : errorColor // ignore: cast_nullable_to_non_nullable
              as String,
      warningColor: null == warningColor
          ? _self.warningColor
          : warningColor // ignore: cast_nullable_to_non_nullable
              as String,
      successColor: null == successColor
          ? _self.successColor
          : successColor // ignore: cast_nullable_to_non_nullable
              as String,
      onPrimaryColor: null == onPrimaryColor
          ? _self.onPrimaryColor
          : onPrimaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSecondaryColor: null == onSecondaryColor
          ? _self.onSecondaryColor
          : onSecondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      onBackgroundColor: null == onBackgroundColor
          ? _self.onBackgroundColor
          : onBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String,
      onErrorColor: null == onErrorColor
          ? _self.onErrorColor
          : onErrorColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSurfaceColor: null == onSurfaceColor
          ? _self.onSurfaceColor
          : onSurfaceColor // ignore: cast_nullable_to_non_nullable
              as String,
      primaryContainerColor: null == primaryContainerColor
          ? _self.primaryContainerColor
          : primaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      onPrimaryContainerColor: null == onPrimaryContainerColor
          ? _self.onPrimaryContainerColor
          : onPrimaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryContainerColor: null == secondaryContainerColor
          ? _self.secondaryContainerColor
          : secondaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSecondaryContainerColor: null == onSecondaryContainerColor
          ? _self.onSecondaryContainerColor
          : onSecondaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      tertiaryContainerColor: null == tertiaryContainerColor
          ? _self.tertiaryContainerColor
          : tertiaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      onTertiaryContainerColor: null == onTertiaryContainerColor
          ? _self.onTertiaryContainerColor
          : onTertiaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      tertiaryColor: null == tertiaryColor
          ? _self.tertiaryColor
          : tertiaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      outlineColor: null == outlineColor
          ? _self.outlineColor
          : outlineColor // ignore: cast_nullable_to_non_nullable
              as String,
      shadowColor: null == shadowColor
          ? _self.shadowColor
          : shadowColor // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceVariantColor: null == surfaceVariantColor
          ? _self.surfaceVariantColor
          : surfaceVariantColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSurfaceVariantColor: null == onSurfaceVariantColor
          ? _self.onSurfaceVariantColor
          : onSurfaceVariantColor // ignore: cast_nullable_to_non_nullable
              as String,
      disabledColor: null == disabledColor
          ? _self.disabledColor
          : disabledColor // ignore: cast_nullable_to_non_nullable
              as String,
      hintColor: null == hintColor
          ? _self.hintColor
          : hintColor // ignore: cast_nullable_to_non_nullable
              as String,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
      useMaterial3: null == useMaterial3
          ? _self.useMaterial3
          : useMaterial3 // ignore: cast_nullable_to_non_nullable
              as bool,
      enableGlassmorphism: null == enableGlassmorphism
          ? _self.enableGlassmorphism
          : enableGlassmorphism // ignore: cast_nullable_to_non_nullable
              as bool,
      enableGradients: null == enableGradients
          ? _self.enableGradients
          : enableGradients // ignore: cast_nullable_to_non_nullable
              as bool,
      enableShadows: null == enableShadows
          ? _self.enableShadows
          : enableShadows // ignore: cast_nullable_to_non_nullable
              as bool,
      shadowIntensity: null == shadowIntensity
          ? _self.shadowIntensity
          : shadowIntensity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [AppThemeSettings].
extension AppThemeSettingsPatterns on AppThemeSettings {
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
    TResult Function(_AppThemeSettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppThemeSettings() when $default != null:
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
    TResult Function(_AppThemeSettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppThemeSettings():
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
    TResult? Function(_AppThemeSettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppThemeSettings() when $default != null:
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
            String primaryColor,
            String secondaryColor,
            String backgroundColor,
            String surfaceColor,
            String textColor,
            String secondaryTextColor,
            String errorColor,
            String warningColor,
            String successColor,
            String onPrimaryColor,
            String onSecondaryColor,
            String onBackgroundColor,
            String onErrorColor,
            String onSurfaceColor,
            String primaryContainerColor,
            String onPrimaryContainerColor,
            String secondaryContainerColor,
            String onSecondaryContainerColor,
            String tertiaryContainerColor,
            String onTertiaryContainerColor,
            String tertiaryColor,
            String outlineColor,
            String shadowColor,
            String surfaceVariantColor,
            String onSurfaceVariantColor,
            String disabledColor,
            String hintColor,
            String themeMode,
            bool useMaterial3,
            bool enableGlassmorphism,
            bool enableGradients,
            bool enableShadows,
            double shadowIntensity)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AppThemeSettings() when $default != null:
        return $default(
            _that.primaryColor,
            _that.secondaryColor,
            _that.backgroundColor,
            _that.surfaceColor,
            _that.textColor,
            _that.secondaryTextColor,
            _that.errorColor,
            _that.warningColor,
            _that.successColor,
            _that.onPrimaryColor,
            _that.onSecondaryColor,
            _that.onBackgroundColor,
            _that.onErrorColor,
            _that.onSurfaceColor,
            _that.primaryContainerColor,
            _that.onPrimaryContainerColor,
            _that.secondaryContainerColor,
            _that.onSecondaryContainerColor,
            _that.tertiaryContainerColor,
            _that.onTertiaryContainerColor,
            _that.tertiaryColor,
            _that.outlineColor,
            _that.shadowColor,
            _that.surfaceVariantColor,
            _that.onSurfaceVariantColor,
            _that.disabledColor,
            _that.hintColor,
            _that.themeMode,
            _that.useMaterial3,
            _that.enableGlassmorphism,
            _that.enableGradients,
            _that.enableShadows,
            _that.shadowIntensity);
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
            String primaryColor,
            String secondaryColor,
            String backgroundColor,
            String surfaceColor,
            String textColor,
            String secondaryTextColor,
            String errorColor,
            String warningColor,
            String successColor,
            String onPrimaryColor,
            String onSecondaryColor,
            String onBackgroundColor,
            String onErrorColor,
            String onSurfaceColor,
            String primaryContainerColor,
            String onPrimaryContainerColor,
            String secondaryContainerColor,
            String onSecondaryContainerColor,
            String tertiaryContainerColor,
            String onTertiaryContainerColor,
            String tertiaryColor,
            String outlineColor,
            String shadowColor,
            String surfaceVariantColor,
            String onSurfaceVariantColor,
            String disabledColor,
            String hintColor,
            String themeMode,
            bool useMaterial3,
            bool enableGlassmorphism,
            bool enableGradients,
            bool enableShadows,
            double shadowIntensity)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppThemeSettings():
        return $default(
            _that.primaryColor,
            _that.secondaryColor,
            _that.backgroundColor,
            _that.surfaceColor,
            _that.textColor,
            _that.secondaryTextColor,
            _that.errorColor,
            _that.warningColor,
            _that.successColor,
            _that.onPrimaryColor,
            _that.onSecondaryColor,
            _that.onBackgroundColor,
            _that.onErrorColor,
            _that.onSurfaceColor,
            _that.primaryContainerColor,
            _that.onPrimaryContainerColor,
            _that.secondaryContainerColor,
            _that.onSecondaryContainerColor,
            _that.tertiaryContainerColor,
            _that.onTertiaryContainerColor,
            _that.tertiaryColor,
            _that.outlineColor,
            _that.shadowColor,
            _that.surfaceVariantColor,
            _that.onSurfaceVariantColor,
            _that.disabledColor,
            _that.hintColor,
            _that.themeMode,
            _that.useMaterial3,
            _that.enableGlassmorphism,
            _that.enableGradients,
            _that.enableShadows,
            _that.shadowIntensity);
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
            String primaryColor,
            String secondaryColor,
            String backgroundColor,
            String surfaceColor,
            String textColor,
            String secondaryTextColor,
            String errorColor,
            String warningColor,
            String successColor,
            String onPrimaryColor,
            String onSecondaryColor,
            String onBackgroundColor,
            String onErrorColor,
            String onSurfaceColor,
            String primaryContainerColor,
            String onPrimaryContainerColor,
            String secondaryContainerColor,
            String onSecondaryContainerColor,
            String tertiaryContainerColor,
            String onTertiaryContainerColor,
            String tertiaryColor,
            String outlineColor,
            String shadowColor,
            String surfaceVariantColor,
            String onSurfaceVariantColor,
            String disabledColor,
            String hintColor,
            String themeMode,
            bool useMaterial3,
            bool enableGlassmorphism,
            bool enableGradients,
            bool enableShadows,
            double shadowIntensity)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AppThemeSettings() when $default != null:
        return $default(
            _that.primaryColor,
            _that.secondaryColor,
            _that.backgroundColor,
            _that.surfaceColor,
            _that.textColor,
            _that.secondaryTextColor,
            _that.errorColor,
            _that.warningColor,
            _that.successColor,
            _that.onPrimaryColor,
            _that.onSecondaryColor,
            _that.onBackgroundColor,
            _that.onErrorColor,
            _that.onSurfaceColor,
            _that.primaryContainerColor,
            _that.onPrimaryContainerColor,
            _that.secondaryContainerColor,
            _that.onSecondaryContainerColor,
            _that.tertiaryContainerColor,
            _that.onTertiaryContainerColor,
            _that.tertiaryColor,
            _that.outlineColor,
            _that.shadowColor,
            _that.surfaceVariantColor,
            _that.onSurfaceVariantColor,
            _that.disabledColor,
            _that.hintColor,
            _that.themeMode,
            _that.useMaterial3,
            _that.enableGlassmorphism,
            _that.enableGradients,
            _that.enableShadows,
            _that.shadowIntensity);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AppThemeSettings extends AppThemeSettings {
  const _AppThemeSettings(
      {this.primaryColor = '#3D5AFE',
      this.secondaryColor = '#00C853',
      this.backgroundColor = '#FFFFFF',
      this.surfaceColor = '#F5F5F5',
      this.textColor = '#212121',
      this.secondaryTextColor = '#757575',
      this.errorColor = '#D32F2F',
      this.warningColor = '#FF9800',
      this.successColor = '#4CAF50',
      this.onPrimaryColor = '#FFFFFF',
      this.onSecondaryColor = '#000000',
      this.onBackgroundColor = '#000000',
      this.onErrorColor = '#FFFFFF',
      this.onSurfaceColor = '#212121',
      this.primaryContainerColor = '#E8EAF6',
      this.onPrimaryContainerColor = '#1A237E',
      this.secondaryContainerColor = '#E8F5E9',
      this.onSecondaryContainerColor = '#1B5E20',
      this.tertiaryContainerColor = '#FFECB3',
      this.onTertiaryContainerColor = '#FF6F00',
      this.tertiaryColor = '#FFAB00',
      this.outlineColor = '#BDBDBD',
      this.shadowColor = '#000000',
      this.surfaceVariantColor = '#E0E0E0',
      this.onSurfaceVariantColor = '#424242',
      this.disabledColor = '#BDBDBD',
      this.hintColor = '#9E9E9E',
      this.themeMode = 'system',
      this.useMaterial3 = true,
      this.enableGlassmorphism = false,
      this.enableGradients = false,
      this.enableShadows = true,
      this.shadowIntensity = 1.0})
      : super._();
  factory _AppThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$AppThemeSettingsFromJson(json);

// Core colors (stored as hex strings) with safe defaults
  @override
  @JsonKey()
  final String primaryColor;
  @override
  @JsonKey()
  final String secondaryColor;
  @override
  @JsonKey()
  final String backgroundColor;
  @override
  @JsonKey()
  final String surfaceColor;
  @override
  @JsonKey()
  final String textColor;
  @override
  @JsonKey()
  final String secondaryTextColor;
  @override
  @JsonKey()
  final String errorColor;
  @override
  @JsonKey()
  final String warningColor;
  @override
  @JsonKey()
  final String successColor;
// "On" Colors with safe defaults
  @override
  @JsonKey()
  final String onPrimaryColor;
  @override
  @JsonKey()
  final String onSecondaryColor;
  @override
  @JsonKey()
  final String onBackgroundColor;
  @override
  @JsonKey()
  final String onErrorColor;
  @override
  @JsonKey()
  final String onSurfaceColor;
// Container Colors with safe defaults
  @override
  @JsonKey()
  final String primaryContainerColor;
  @override
  @JsonKey()
  final String onPrimaryContainerColor;
  @override
  @JsonKey()
  final String secondaryContainerColor;
  @override
  @JsonKey()
  final String onSecondaryContainerColor;
  @override
  @JsonKey()
  final String tertiaryContainerColor;
  @override
  @JsonKey()
  final String onTertiaryContainerColor;
// Tertiary Color
  @override
  @JsonKey()
  final String tertiaryColor;
// Utility Colors with safe defaults
  @override
  @JsonKey()
  final String outlineColor;
  @override
  @JsonKey()
  final String shadowColor;
  @override
  @JsonKey()
  final String surfaceVariantColor;
  @override
  @JsonKey()
  final String onSurfaceVariantColor;
  @override
  @JsonKey()
  final String disabledColor;
  @override
  @JsonKey()
  final String hintColor;
// Theme mode as string with safe default
  @override
  @JsonKey()
  final String themeMode;
  @override
  @JsonKey()
  final bool useMaterial3;
// Special effects with safe defaults
  @override
  @JsonKey()
  final bool enableGlassmorphism;
  @override
  @JsonKey()
  final bool enableGradients;
  @override
  @JsonKey()
  final bool enableShadows;
// Changed default to true
  @override
  @JsonKey()
  final double shadowIntensity;

  /// Create a copy of AppThemeSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AppThemeSettingsCopyWith<_AppThemeSettings> get copyWith =>
      __$AppThemeSettingsCopyWithImpl<_AppThemeSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AppThemeSettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AppThemeSettings &&
            (identical(other.primaryColor, primaryColor) ||
                other.primaryColor == primaryColor) &&
            (identical(other.secondaryColor, secondaryColor) ||
                other.secondaryColor == secondaryColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.surfaceColor, surfaceColor) ||
                other.surfaceColor == surfaceColor) &&
            (identical(other.textColor, textColor) ||
                other.textColor == textColor) &&
            (identical(other.secondaryTextColor, secondaryTextColor) ||
                other.secondaryTextColor == secondaryTextColor) &&
            (identical(other.errorColor, errorColor) ||
                other.errorColor == errorColor) &&
            (identical(other.warningColor, warningColor) ||
                other.warningColor == warningColor) &&
            (identical(other.successColor, successColor) ||
                other.successColor == successColor) &&
            (identical(other.onPrimaryColor, onPrimaryColor) ||
                other.onPrimaryColor == onPrimaryColor) &&
            (identical(other.onSecondaryColor, onSecondaryColor) ||
                other.onSecondaryColor == onSecondaryColor) &&
            (identical(other.onBackgroundColor, onBackgroundColor) ||
                other.onBackgroundColor == onBackgroundColor) &&
            (identical(other.onErrorColor, onErrorColor) ||
                other.onErrorColor == onErrorColor) &&
            (identical(other.onSurfaceColor, onSurfaceColor) ||
                other.onSurfaceColor == onSurfaceColor) &&
            (identical(other.primaryContainerColor, primaryContainerColor) ||
                other.primaryContainerColor == primaryContainerColor) &&
            (identical(other.onPrimaryContainerColor, onPrimaryContainerColor) ||
                other.onPrimaryContainerColor == onPrimaryContainerColor) &&
            (identical(other.secondaryContainerColor, secondaryContainerColor) ||
                other.secondaryContainerColor == secondaryContainerColor) &&
            (identical(other.onSecondaryContainerColor, onSecondaryContainerColor) ||
                other.onSecondaryContainerColor == onSecondaryContainerColor) &&
            (identical(other.tertiaryContainerColor, tertiaryContainerColor) ||
                other.tertiaryContainerColor == tertiaryContainerColor) &&
            (identical(other.onTertiaryContainerColor, onTertiaryContainerColor) ||
                other.onTertiaryContainerColor == onTertiaryContainerColor) &&
            (identical(other.tertiaryColor, tertiaryColor) ||
                other.tertiaryColor == tertiaryColor) &&
            (identical(other.outlineColor, outlineColor) ||
                other.outlineColor == outlineColor) &&
            (identical(other.shadowColor, shadowColor) ||
                other.shadowColor == shadowColor) &&
            (identical(other.surfaceVariantColor, surfaceVariantColor) ||
                other.surfaceVariantColor == surfaceVariantColor) &&
            (identical(other.onSurfaceVariantColor, onSurfaceVariantColor) ||
                other.onSurfaceVariantColor == onSurfaceVariantColor) &&
            (identical(other.disabledColor, disabledColor) ||
                other.disabledColor == disabledColor) &&
            (identical(other.hintColor, hintColor) ||
                other.hintColor == hintColor) &&
            (identical(other.themeMode, themeMode) ||
                other.themeMode == themeMode) &&
            (identical(other.useMaterial3, useMaterial3) ||
                other.useMaterial3 == useMaterial3) &&
            (identical(other.enableGlassmorphism, enableGlassmorphism) ||
                other.enableGlassmorphism == enableGlassmorphism) &&
            (identical(other.enableGradients, enableGradients) ||
                other.enableGradients == enableGradients) &&
            (identical(other.enableShadows, enableShadows) ||
                other.enableShadows == enableShadows) &&
            (identical(other.shadowIntensity, shadowIntensity) || other.shadowIntensity == shadowIntensity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        primaryColor,
        secondaryColor,
        backgroundColor,
        surfaceColor,
        textColor,
        secondaryTextColor,
        errorColor,
        warningColor,
        successColor,
        onPrimaryColor,
        onSecondaryColor,
        onBackgroundColor,
        onErrorColor,
        onSurfaceColor,
        primaryContainerColor,
        onPrimaryContainerColor,
        secondaryContainerColor,
        onSecondaryContainerColor,
        tertiaryContainerColor,
        onTertiaryContainerColor,
        tertiaryColor,
        outlineColor,
        shadowColor,
        surfaceVariantColor,
        onSurfaceVariantColor,
        disabledColor,
        hintColor,
        themeMode,
        useMaterial3,
        enableGlassmorphism,
        enableGradients,
        enableShadows,
        shadowIntensity
      ]);

  @override
  String toString() {
    return 'AppThemeSettings(primaryColor: $primaryColor, secondaryColor: $secondaryColor, backgroundColor: $backgroundColor, surfaceColor: $surfaceColor, textColor: $textColor, secondaryTextColor: $secondaryTextColor, errorColor: $errorColor, warningColor: $warningColor, successColor: $successColor, onPrimaryColor: $onPrimaryColor, onSecondaryColor: $onSecondaryColor, onBackgroundColor: $onBackgroundColor, onErrorColor: $onErrorColor, onSurfaceColor: $onSurfaceColor, primaryContainerColor: $primaryContainerColor, onPrimaryContainerColor: $onPrimaryContainerColor, secondaryContainerColor: $secondaryContainerColor, onSecondaryContainerColor: $onSecondaryContainerColor, tertiaryContainerColor: $tertiaryContainerColor, onTertiaryContainerColor: $onTertiaryContainerColor, tertiaryColor: $tertiaryColor, outlineColor: $outlineColor, shadowColor: $shadowColor, surfaceVariantColor: $surfaceVariantColor, onSurfaceVariantColor: $onSurfaceVariantColor, disabledColor: $disabledColor, hintColor: $hintColor, themeMode: $themeMode, useMaterial3: $useMaterial3, enableGlassmorphism: $enableGlassmorphism, enableGradients: $enableGradients, enableShadows: $enableShadows, shadowIntensity: $shadowIntensity)';
  }
}

/// @nodoc
abstract mixin class _$AppThemeSettingsCopyWith<$Res>
    implements $AppThemeSettingsCopyWith<$Res> {
  factory _$AppThemeSettingsCopyWith(
          _AppThemeSettings value, $Res Function(_AppThemeSettings) _then) =
      __$AppThemeSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String primaryColor,
      String secondaryColor,
      String backgroundColor,
      String surfaceColor,
      String textColor,
      String secondaryTextColor,
      String errorColor,
      String warningColor,
      String successColor,
      String onPrimaryColor,
      String onSecondaryColor,
      String onBackgroundColor,
      String onErrorColor,
      String onSurfaceColor,
      String primaryContainerColor,
      String onPrimaryContainerColor,
      String secondaryContainerColor,
      String onSecondaryContainerColor,
      String tertiaryContainerColor,
      String onTertiaryContainerColor,
      String tertiaryColor,
      String outlineColor,
      String shadowColor,
      String surfaceVariantColor,
      String onSurfaceVariantColor,
      String disabledColor,
      String hintColor,
      String themeMode,
      bool useMaterial3,
      bool enableGlassmorphism,
      bool enableGradients,
      bool enableShadows,
      double shadowIntensity});
}

/// @nodoc
class __$AppThemeSettingsCopyWithImpl<$Res>
    implements _$AppThemeSettingsCopyWith<$Res> {
  __$AppThemeSettingsCopyWithImpl(this._self, this._then);

  final _AppThemeSettings _self;
  final $Res Function(_AppThemeSettings) _then;

  /// Create a copy of AppThemeSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? primaryColor = null,
    Object? secondaryColor = null,
    Object? backgroundColor = null,
    Object? surfaceColor = null,
    Object? textColor = null,
    Object? secondaryTextColor = null,
    Object? errorColor = null,
    Object? warningColor = null,
    Object? successColor = null,
    Object? onPrimaryColor = null,
    Object? onSecondaryColor = null,
    Object? onBackgroundColor = null,
    Object? onErrorColor = null,
    Object? onSurfaceColor = null,
    Object? primaryContainerColor = null,
    Object? onPrimaryContainerColor = null,
    Object? secondaryContainerColor = null,
    Object? onSecondaryContainerColor = null,
    Object? tertiaryContainerColor = null,
    Object? onTertiaryContainerColor = null,
    Object? tertiaryColor = null,
    Object? outlineColor = null,
    Object? shadowColor = null,
    Object? surfaceVariantColor = null,
    Object? onSurfaceVariantColor = null,
    Object? disabledColor = null,
    Object? hintColor = null,
    Object? themeMode = null,
    Object? useMaterial3 = null,
    Object? enableGlassmorphism = null,
    Object? enableGradients = null,
    Object? enableShadows = null,
    Object? shadowIntensity = null,
  }) {
    return _then(_AppThemeSettings(
      primaryColor: null == primaryColor
          ? _self.primaryColor
          : primaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryColor: null == secondaryColor
          ? _self.secondaryColor
          : secondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      backgroundColor: null == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceColor: null == surfaceColor
          ? _self.surfaceColor
          : surfaceColor // ignore: cast_nullable_to_non_nullable
              as String,
      textColor: null == textColor
          ? _self.textColor
          : textColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryTextColor: null == secondaryTextColor
          ? _self.secondaryTextColor
          : secondaryTextColor // ignore: cast_nullable_to_non_nullable
              as String,
      errorColor: null == errorColor
          ? _self.errorColor
          : errorColor // ignore: cast_nullable_to_non_nullable
              as String,
      warningColor: null == warningColor
          ? _self.warningColor
          : warningColor // ignore: cast_nullable_to_non_nullable
              as String,
      successColor: null == successColor
          ? _self.successColor
          : successColor // ignore: cast_nullable_to_non_nullable
              as String,
      onPrimaryColor: null == onPrimaryColor
          ? _self.onPrimaryColor
          : onPrimaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSecondaryColor: null == onSecondaryColor
          ? _self.onSecondaryColor
          : onSecondaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      onBackgroundColor: null == onBackgroundColor
          ? _self.onBackgroundColor
          : onBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String,
      onErrorColor: null == onErrorColor
          ? _self.onErrorColor
          : onErrorColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSurfaceColor: null == onSurfaceColor
          ? _self.onSurfaceColor
          : onSurfaceColor // ignore: cast_nullable_to_non_nullable
              as String,
      primaryContainerColor: null == primaryContainerColor
          ? _self.primaryContainerColor
          : primaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      onPrimaryContainerColor: null == onPrimaryContainerColor
          ? _self.onPrimaryContainerColor
          : onPrimaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryContainerColor: null == secondaryContainerColor
          ? _self.secondaryContainerColor
          : secondaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSecondaryContainerColor: null == onSecondaryContainerColor
          ? _self.onSecondaryContainerColor
          : onSecondaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      tertiaryContainerColor: null == tertiaryContainerColor
          ? _self.tertiaryContainerColor
          : tertiaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      onTertiaryContainerColor: null == onTertiaryContainerColor
          ? _self.onTertiaryContainerColor
          : onTertiaryContainerColor // ignore: cast_nullable_to_non_nullable
              as String,
      tertiaryColor: null == tertiaryColor
          ? _self.tertiaryColor
          : tertiaryColor // ignore: cast_nullable_to_non_nullable
              as String,
      outlineColor: null == outlineColor
          ? _self.outlineColor
          : outlineColor // ignore: cast_nullable_to_non_nullable
              as String,
      shadowColor: null == shadowColor
          ? _self.shadowColor
          : shadowColor // ignore: cast_nullable_to_non_nullable
              as String,
      surfaceVariantColor: null == surfaceVariantColor
          ? _self.surfaceVariantColor
          : surfaceVariantColor // ignore: cast_nullable_to_non_nullable
              as String,
      onSurfaceVariantColor: null == onSurfaceVariantColor
          ? _self.onSurfaceVariantColor
          : onSurfaceVariantColor // ignore: cast_nullable_to_non_nullable
              as String,
      disabledColor: null == disabledColor
          ? _self.disabledColor
          : disabledColor // ignore: cast_nullable_to_non_nullable
              as String,
      hintColor: null == hintColor
          ? _self.hintColor
          : hintColor // ignore: cast_nullable_to_non_nullable
              as String,
      themeMode: null == themeMode
          ? _self.themeMode
          : themeMode // ignore: cast_nullable_to_non_nullable
              as String,
      useMaterial3: null == useMaterial3
          ? _self.useMaterial3
          : useMaterial3 // ignore: cast_nullable_to_non_nullable
              as bool,
      enableGlassmorphism: null == enableGlassmorphism
          ? _self.enableGlassmorphism
          : enableGlassmorphism // ignore: cast_nullable_to_non_nullable
              as bool,
      enableGradients: null == enableGradients
          ? _self.enableGradients
          : enableGradients // ignore: cast_nullable_to_non_nullable
              as bool,
      enableShadows: null == enableShadows
          ? _self.enableShadows
          : enableShadows // ignore: cast_nullable_to_non_nullable
              as bool,
      shadowIntensity: null == shadowIntensity
          ? _self.shadowIntensity
          : shadowIntensity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$ProfileCustomization {
// Background customization with safe defaults
  String? get backgroundImageUrl;
  String? get backgroundColor;
  String get backgroundType;
  List<String> get gradientColors;
  double get gradientAngle; // Layout customization with safe defaults
  String get layout;
  bool get showCoverImage;
  bool get showProfileImage;
  String get profileImageShape;
  double get profileImageSize; // Content sections with safe defaults
  bool get showBio;
  bool get showStats;
  bool get showPosts;
  bool get showAboutSection; // Special effects with safe defaults
  bool get enableParticles;
  bool get enableAnimatedBackground;
  bool get enableCustomCursor;
  String? get customCursorUrl; // Custom CSS
  String? get customCSS; // Music player with safe defaults
  bool get enableMusicPlayer;
  String? get musicUrl;
  bool get autoPlayMusic;
  double get musicVolume; // Profile card styling with safe defaults
  double get cardBorderRadius;
  double get cardElevation;
  String? get cardBackgroundColor;
  double get cardOpacity; // Custom widgets with safe defaults
  List<CustomWidget> get customWidgets;

  /// Create a copy of ProfileCustomization
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ProfileCustomizationCopyWith<ProfileCustomization> get copyWith =>
      _$ProfileCustomizationCopyWithImpl<ProfileCustomization>(
          this as ProfileCustomization, _$identity);

  /// Serializes this ProfileCustomization to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ProfileCustomization &&
            (identical(other.backgroundImageUrl, backgroundImageUrl) ||
                other.backgroundImageUrl == backgroundImageUrl) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.backgroundType, backgroundType) ||
                other.backgroundType == backgroundType) &&
            const DeepCollectionEquality()
                .equals(other.gradientColors, gradientColors) &&
            (identical(other.gradientAngle, gradientAngle) ||
                other.gradientAngle == gradientAngle) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            (identical(other.showCoverImage, showCoverImage) ||
                other.showCoverImage == showCoverImage) &&
            (identical(other.showProfileImage, showProfileImage) ||
                other.showProfileImage == showProfileImage) &&
            (identical(other.profileImageShape, profileImageShape) ||
                other.profileImageShape == profileImageShape) &&
            (identical(other.profileImageSize, profileImageSize) ||
                other.profileImageSize == profileImageSize) &&
            (identical(other.showBio, showBio) || other.showBio == showBio) &&
            (identical(other.showStats, showStats) ||
                other.showStats == showStats) &&
            (identical(other.showPosts, showPosts) ||
                other.showPosts == showPosts) &&
            (identical(other.showAboutSection, showAboutSection) ||
                other.showAboutSection == showAboutSection) &&
            (identical(other.enableParticles, enableParticles) ||
                other.enableParticles == enableParticles) &&
            (identical(
                    other.enableAnimatedBackground, enableAnimatedBackground) ||
                other.enableAnimatedBackground == enableAnimatedBackground) &&
            (identical(other.enableCustomCursor, enableCustomCursor) ||
                other.enableCustomCursor == enableCustomCursor) &&
            (identical(other.customCursorUrl, customCursorUrl) ||
                other.customCursorUrl == customCursorUrl) &&
            (identical(other.customCSS, customCSS) ||
                other.customCSS == customCSS) &&
            (identical(other.enableMusicPlayer, enableMusicPlayer) ||
                other.enableMusicPlayer == enableMusicPlayer) &&
            (identical(other.musicUrl, musicUrl) ||
                other.musicUrl == musicUrl) &&
            (identical(other.autoPlayMusic, autoPlayMusic) ||
                other.autoPlayMusic == autoPlayMusic) &&
            (identical(other.musicVolume, musicVolume) ||
                other.musicVolume == musicVolume) &&
            (identical(other.cardBorderRadius, cardBorderRadius) ||
                other.cardBorderRadius == cardBorderRadius) &&
            (identical(other.cardElevation, cardElevation) ||
                other.cardElevation == cardElevation) &&
            (identical(other.cardBackgroundColor, cardBackgroundColor) ||
                other.cardBackgroundColor == cardBackgroundColor) &&
            (identical(other.cardOpacity, cardOpacity) ||
                other.cardOpacity == cardOpacity) &&
            const DeepCollectionEquality()
                .equals(other.customWidgets, customWidgets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        backgroundImageUrl,
        backgroundColor,
        backgroundType,
        const DeepCollectionEquality().hash(gradientColors),
        gradientAngle,
        layout,
        showCoverImage,
        showProfileImage,
        profileImageShape,
        profileImageSize,
        showBio,
        showStats,
        showPosts,
        showAboutSection,
        enableParticles,
        enableAnimatedBackground,
        enableCustomCursor,
        customCursorUrl,
        customCSS,
        enableMusicPlayer,
        musicUrl,
        autoPlayMusic,
        musicVolume,
        cardBorderRadius,
        cardElevation,
        cardBackgroundColor,
        cardOpacity,
        const DeepCollectionEquality().hash(customWidgets)
      ]);

  @override
  String toString() {
    return 'ProfileCustomization(backgroundImageUrl: $backgroundImageUrl, backgroundColor: $backgroundColor, backgroundType: $backgroundType, gradientColors: $gradientColors, gradientAngle: $gradientAngle, layout: $layout, showCoverImage: $showCoverImage, showProfileImage: $showProfileImage, profileImageShape: $profileImageShape, profileImageSize: $profileImageSize, showBio: $showBio, showStats: $showStats, showPosts: $showPosts, showAboutSection: $showAboutSection, enableParticles: $enableParticles, enableAnimatedBackground: $enableAnimatedBackground, enableCustomCursor: $enableCustomCursor, customCursorUrl: $customCursorUrl, customCSS: $customCSS, enableMusicPlayer: $enableMusicPlayer, musicUrl: $musicUrl, autoPlayMusic: $autoPlayMusic, musicVolume: $musicVolume, cardBorderRadius: $cardBorderRadius, cardElevation: $cardElevation, cardBackgroundColor: $cardBackgroundColor, cardOpacity: $cardOpacity, customWidgets: $customWidgets)';
  }
}

/// @nodoc
abstract mixin class $ProfileCustomizationCopyWith<$Res> {
  factory $ProfileCustomizationCopyWith(ProfileCustomization value,
          $Res Function(ProfileCustomization) _then) =
      _$ProfileCustomizationCopyWithImpl;
  @useResult
  $Res call(
      {String? backgroundImageUrl,
      String? backgroundColor,
      String backgroundType,
      List<String> gradientColors,
      double gradientAngle,
      String layout,
      bool showCoverImage,
      bool showProfileImage,
      String profileImageShape,
      double profileImageSize,
      bool showBio,
      bool showStats,
      bool showPosts,
      bool showAboutSection,
      bool enableParticles,
      bool enableAnimatedBackground,
      bool enableCustomCursor,
      String? customCursorUrl,
      String? customCSS,
      bool enableMusicPlayer,
      String? musicUrl,
      bool autoPlayMusic,
      double musicVolume,
      double cardBorderRadius,
      double cardElevation,
      String? cardBackgroundColor,
      double cardOpacity,
      List<CustomWidget> customWidgets});
}

/// @nodoc
class _$ProfileCustomizationCopyWithImpl<$Res>
    implements $ProfileCustomizationCopyWith<$Res> {
  _$ProfileCustomizationCopyWithImpl(this._self, this._then);

  final ProfileCustomization _self;
  final $Res Function(ProfileCustomization) _then;

  /// Create a copy of ProfileCustomization
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? backgroundImageUrl = freezed,
    Object? backgroundColor = freezed,
    Object? backgroundType = null,
    Object? gradientColors = null,
    Object? gradientAngle = null,
    Object? layout = null,
    Object? showCoverImage = null,
    Object? showProfileImage = null,
    Object? profileImageShape = null,
    Object? profileImageSize = null,
    Object? showBio = null,
    Object? showStats = null,
    Object? showPosts = null,
    Object? showAboutSection = null,
    Object? enableParticles = null,
    Object? enableAnimatedBackground = null,
    Object? enableCustomCursor = null,
    Object? customCursorUrl = freezed,
    Object? customCSS = freezed,
    Object? enableMusicPlayer = null,
    Object? musicUrl = freezed,
    Object? autoPlayMusic = null,
    Object? musicVolume = null,
    Object? cardBorderRadius = null,
    Object? cardElevation = null,
    Object? cardBackgroundColor = freezed,
    Object? cardOpacity = null,
    Object? customWidgets = null,
  }) {
    return _then(_self.copyWith(
      backgroundImageUrl: freezed == backgroundImageUrl
          ? _self.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundType: null == backgroundType
          ? _self.backgroundType
          : backgroundType // ignore: cast_nullable_to_non_nullable
              as String,
      gradientColors: null == gradientColors
          ? _self.gradientColors
          : gradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      gradientAngle: null == gradientAngle
          ? _self.gradientAngle
          : gradientAngle // ignore: cast_nullable_to_non_nullable
              as double,
      layout: null == layout
          ? _self.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as String,
      showCoverImage: null == showCoverImage
          ? _self.showCoverImage
          : showCoverImage // ignore: cast_nullable_to_non_nullable
              as bool,
      showProfileImage: null == showProfileImage
          ? _self.showProfileImage
          : showProfileImage // ignore: cast_nullable_to_non_nullable
              as bool,
      profileImageShape: null == profileImageShape
          ? _self.profileImageShape
          : profileImageShape // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageSize: null == profileImageSize
          ? _self.profileImageSize
          : profileImageSize // ignore: cast_nullable_to_non_nullable
              as double,
      showBio: null == showBio
          ? _self.showBio
          : showBio // ignore: cast_nullable_to_non_nullable
              as bool,
      showStats: null == showStats
          ? _self.showStats
          : showStats // ignore: cast_nullable_to_non_nullable
              as bool,
      showPosts: null == showPosts
          ? _self.showPosts
          : showPosts // ignore: cast_nullable_to_non_nullable
              as bool,
      showAboutSection: null == showAboutSection
          ? _self.showAboutSection
          : showAboutSection // ignore: cast_nullable_to_non_nullable
              as bool,
      enableParticles: null == enableParticles
          ? _self.enableParticles
          : enableParticles // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnimatedBackground: null == enableAnimatedBackground
          ? _self.enableAnimatedBackground
          : enableAnimatedBackground // ignore: cast_nullable_to_non_nullable
              as bool,
      enableCustomCursor: null == enableCustomCursor
          ? _self.enableCustomCursor
          : enableCustomCursor // ignore: cast_nullable_to_non_nullable
              as bool,
      customCursorUrl: freezed == customCursorUrl
          ? _self.customCursorUrl
          : customCursorUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      customCSS: freezed == customCSS
          ? _self.customCSS
          : customCSS // ignore: cast_nullable_to_non_nullable
              as String?,
      enableMusicPlayer: null == enableMusicPlayer
          ? _self.enableMusicPlayer
          : enableMusicPlayer // ignore: cast_nullable_to_non_nullable
              as bool,
      musicUrl: freezed == musicUrl
          ? _self.musicUrl
          : musicUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      autoPlayMusic: null == autoPlayMusic
          ? _self.autoPlayMusic
          : autoPlayMusic // ignore: cast_nullable_to_non_nullable
              as bool,
      musicVolume: null == musicVolume
          ? _self.musicVolume
          : musicVolume // ignore: cast_nullable_to_non_nullable
              as double,
      cardBorderRadius: null == cardBorderRadius
          ? _self.cardBorderRadius
          : cardBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      cardElevation: null == cardElevation
          ? _self.cardElevation
          : cardElevation // ignore: cast_nullable_to_non_nullable
              as double,
      cardBackgroundColor: freezed == cardBackgroundColor
          ? _self.cardBackgroundColor
          : cardBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      cardOpacity: null == cardOpacity
          ? _self.cardOpacity
          : cardOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      customWidgets: null == customWidgets
          ? _self.customWidgets
          : customWidgets // ignore: cast_nullable_to_non_nullable
              as List<CustomWidget>,
    ));
  }
}

/// Adds pattern-matching-related methods to [ProfileCustomization].
extension ProfileCustomizationPatterns on ProfileCustomization {
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
    TResult Function(_ProfileCustomization value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileCustomization() when $default != null:
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
    TResult Function(_ProfileCustomization value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileCustomization():
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
    TResult? Function(_ProfileCustomization value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileCustomization() when $default != null:
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
            String? backgroundImageUrl,
            String? backgroundColor,
            String backgroundType,
            List<String> gradientColors,
            double gradientAngle,
            String layout,
            bool showCoverImage,
            bool showProfileImage,
            String profileImageShape,
            double profileImageSize,
            bool showBio,
            bool showStats,
            bool showPosts,
            bool showAboutSection,
            bool enableParticles,
            bool enableAnimatedBackground,
            bool enableCustomCursor,
            String? customCursorUrl,
            String? customCSS,
            bool enableMusicPlayer,
            String? musicUrl,
            bool autoPlayMusic,
            double musicVolume,
            double cardBorderRadius,
            double cardElevation,
            String? cardBackgroundColor,
            double cardOpacity,
            List<CustomWidget> customWidgets)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ProfileCustomization() when $default != null:
        return $default(
            _that.backgroundImageUrl,
            _that.backgroundColor,
            _that.backgroundType,
            _that.gradientColors,
            _that.gradientAngle,
            _that.layout,
            _that.showCoverImage,
            _that.showProfileImage,
            _that.profileImageShape,
            _that.profileImageSize,
            _that.showBio,
            _that.showStats,
            _that.showPosts,
            _that.showAboutSection,
            _that.enableParticles,
            _that.enableAnimatedBackground,
            _that.enableCustomCursor,
            _that.customCursorUrl,
            _that.customCSS,
            _that.enableMusicPlayer,
            _that.musicUrl,
            _that.autoPlayMusic,
            _that.musicVolume,
            _that.cardBorderRadius,
            _that.cardElevation,
            _that.cardBackgroundColor,
            _that.cardOpacity,
            _that.customWidgets);
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
            String? backgroundImageUrl,
            String? backgroundColor,
            String backgroundType,
            List<String> gradientColors,
            double gradientAngle,
            String layout,
            bool showCoverImage,
            bool showProfileImage,
            String profileImageShape,
            double profileImageSize,
            bool showBio,
            bool showStats,
            bool showPosts,
            bool showAboutSection,
            bool enableParticles,
            bool enableAnimatedBackground,
            bool enableCustomCursor,
            String? customCursorUrl,
            String? customCSS,
            bool enableMusicPlayer,
            String? musicUrl,
            bool autoPlayMusic,
            double musicVolume,
            double cardBorderRadius,
            double cardElevation,
            String? cardBackgroundColor,
            double cardOpacity,
            List<CustomWidget> customWidgets)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileCustomization():
        return $default(
            _that.backgroundImageUrl,
            _that.backgroundColor,
            _that.backgroundType,
            _that.gradientColors,
            _that.gradientAngle,
            _that.layout,
            _that.showCoverImage,
            _that.showProfileImage,
            _that.profileImageShape,
            _that.profileImageSize,
            _that.showBio,
            _that.showStats,
            _that.showPosts,
            _that.showAboutSection,
            _that.enableParticles,
            _that.enableAnimatedBackground,
            _that.enableCustomCursor,
            _that.customCursorUrl,
            _that.customCSS,
            _that.enableMusicPlayer,
            _that.musicUrl,
            _that.autoPlayMusic,
            _that.musicVolume,
            _that.cardBorderRadius,
            _that.cardElevation,
            _that.cardBackgroundColor,
            _that.cardOpacity,
            _that.customWidgets);
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
            String? backgroundImageUrl,
            String? backgroundColor,
            String backgroundType,
            List<String> gradientColors,
            double gradientAngle,
            String layout,
            bool showCoverImage,
            bool showProfileImage,
            String profileImageShape,
            double profileImageSize,
            bool showBio,
            bool showStats,
            bool showPosts,
            bool showAboutSection,
            bool enableParticles,
            bool enableAnimatedBackground,
            bool enableCustomCursor,
            String? customCursorUrl,
            String? customCSS,
            bool enableMusicPlayer,
            String? musicUrl,
            bool autoPlayMusic,
            double musicVolume,
            double cardBorderRadius,
            double cardElevation,
            String? cardBackgroundColor,
            double cardOpacity,
            List<CustomWidget> customWidgets)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ProfileCustomization() when $default != null:
        return $default(
            _that.backgroundImageUrl,
            _that.backgroundColor,
            _that.backgroundType,
            _that.gradientColors,
            _that.gradientAngle,
            _that.layout,
            _that.showCoverImage,
            _that.showProfileImage,
            _that.profileImageShape,
            _that.profileImageSize,
            _that.showBio,
            _that.showStats,
            _that.showPosts,
            _that.showAboutSection,
            _that.enableParticles,
            _that.enableAnimatedBackground,
            _that.enableCustomCursor,
            _that.customCursorUrl,
            _that.customCSS,
            _that.enableMusicPlayer,
            _that.musicUrl,
            _that.autoPlayMusic,
            _that.musicVolume,
            _that.cardBorderRadius,
            _that.cardElevation,
            _that.cardBackgroundColor,
            _that.cardOpacity,
            _that.customWidgets);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ProfileCustomization implements ProfileCustomization {
  const _ProfileCustomization(
      {this.backgroundImageUrl,
      this.backgroundColor,
      this.backgroundType = 'solid',
      final List<String> gradientColors = const [],
      this.gradientAngle = 0.0,
      this.layout = 'classic',
      this.showCoverImage = true,
      this.showProfileImage = true,
      this.profileImageShape = 'circle',
      this.profileImageSize = 80.0,
      this.showBio = true,
      this.showStats = true,
      this.showPosts = true,
      this.showAboutSection = true,
      this.enableParticles = false,
      this.enableAnimatedBackground = false,
      this.enableCustomCursor = false,
      this.customCursorUrl,
      this.customCSS,
      this.enableMusicPlayer = false,
      this.musicUrl,
      this.autoPlayMusic = false,
      this.musicVolume = 0.5,
      this.cardBorderRadius = 16.0,
      this.cardElevation = 2.0,
      this.cardBackgroundColor,
      this.cardOpacity = 0.95,
      final List<CustomWidget> customWidgets = const []})
      : _gradientColors = gradientColors,
        _customWidgets = customWidgets;
  factory _ProfileCustomization.fromJson(Map<String, dynamic> json) =>
      _$ProfileCustomizationFromJson(json);

// Background customization with safe defaults
  @override
  final String? backgroundImageUrl;
  @override
  final String? backgroundColor;
  @override
  @JsonKey()
  final String backgroundType;
  final List<String> _gradientColors;
  @override
  @JsonKey()
  List<String> get gradientColors {
    if (_gradientColors is EqualUnmodifiableListView) return _gradientColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradientColors);
  }

  @override
  @JsonKey()
  final double gradientAngle;
// Layout customization with safe defaults
  @override
  @JsonKey()
  final String layout;
  @override
  @JsonKey()
  final bool showCoverImage;
  @override
  @JsonKey()
  final bool showProfileImage;
  @override
  @JsonKey()
  final String profileImageShape;
  @override
  @JsonKey()
  final double profileImageSize;
// Content sections with safe defaults
  @override
  @JsonKey()
  final bool showBio;
  @override
  @JsonKey()
  final bool showStats;
  @override
  @JsonKey()
  final bool showPosts;
  @override
  @JsonKey()
  final bool showAboutSection;
// Special effects with safe defaults
  @override
  @JsonKey()
  final bool enableParticles;
  @override
  @JsonKey()
  final bool enableAnimatedBackground;
  @override
  @JsonKey()
  final bool enableCustomCursor;
  @override
  final String? customCursorUrl;
// Custom CSS
  @override
  final String? customCSS;
// Music player with safe defaults
  @override
  @JsonKey()
  final bool enableMusicPlayer;
  @override
  final String? musicUrl;
  @override
  @JsonKey()
  final bool autoPlayMusic;
  @override
  @JsonKey()
  final double musicVolume;
// Profile card styling with safe defaults
  @override
  @JsonKey()
  final double cardBorderRadius;
  @override
  @JsonKey()
  final double cardElevation;
  @override
  final String? cardBackgroundColor;
  @override
  @JsonKey()
  final double cardOpacity;
// Custom widgets with safe defaults
  final List<CustomWidget> _customWidgets;
// Custom widgets with safe defaults
  @override
  @JsonKey()
  List<CustomWidget> get customWidgets {
    if (_customWidgets is EqualUnmodifiableListView) return _customWidgets;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_customWidgets);
  }

  /// Create a copy of ProfileCustomization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ProfileCustomizationCopyWith<_ProfileCustomization> get copyWith =>
      __$ProfileCustomizationCopyWithImpl<_ProfileCustomization>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ProfileCustomizationToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ProfileCustomization &&
            (identical(other.backgroundImageUrl, backgroundImageUrl) ||
                other.backgroundImageUrl == backgroundImageUrl) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.backgroundType, backgroundType) ||
                other.backgroundType == backgroundType) &&
            const DeepCollectionEquality()
                .equals(other._gradientColors, _gradientColors) &&
            (identical(other.gradientAngle, gradientAngle) ||
                other.gradientAngle == gradientAngle) &&
            (identical(other.layout, layout) || other.layout == layout) &&
            (identical(other.showCoverImage, showCoverImage) ||
                other.showCoverImage == showCoverImage) &&
            (identical(other.showProfileImage, showProfileImage) ||
                other.showProfileImage == showProfileImage) &&
            (identical(other.profileImageShape, profileImageShape) ||
                other.profileImageShape == profileImageShape) &&
            (identical(other.profileImageSize, profileImageSize) ||
                other.profileImageSize == profileImageSize) &&
            (identical(other.showBio, showBio) || other.showBio == showBio) &&
            (identical(other.showStats, showStats) ||
                other.showStats == showStats) &&
            (identical(other.showPosts, showPosts) ||
                other.showPosts == showPosts) &&
            (identical(other.showAboutSection, showAboutSection) ||
                other.showAboutSection == showAboutSection) &&
            (identical(other.enableParticles, enableParticles) ||
                other.enableParticles == enableParticles) &&
            (identical(
                    other.enableAnimatedBackground, enableAnimatedBackground) ||
                other.enableAnimatedBackground == enableAnimatedBackground) &&
            (identical(other.enableCustomCursor, enableCustomCursor) ||
                other.enableCustomCursor == enableCustomCursor) &&
            (identical(other.customCursorUrl, customCursorUrl) ||
                other.customCursorUrl == customCursorUrl) &&
            (identical(other.customCSS, customCSS) ||
                other.customCSS == customCSS) &&
            (identical(other.enableMusicPlayer, enableMusicPlayer) ||
                other.enableMusicPlayer == enableMusicPlayer) &&
            (identical(other.musicUrl, musicUrl) ||
                other.musicUrl == musicUrl) &&
            (identical(other.autoPlayMusic, autoPlayMusic) ||
                other.autoPlayMusic == autoPlayMusic) &&
            (identical(other.musicVolume, musicVolume) ||
                other.musicVolume == musicVolume) &&
            (identical(other.cardBorderRadius, cardBorderRadius) ||
                other.cardBorderRadius == cardBorderRadius) &&
            (identical(other.cardElevation, cardElevation) ||
                other.cardElevation == cardElevation) &&
            (identical(other.cardBackgroundColor, cardBackgroundColor) ||
                other.cardBackgroundColor == cardBackgroundColor) &&
            (identical(other.cardOpacity, cardOpacity) ||
                other.cardOpacity == cardOpacity) &&
            const DeepCollectionEquality()
                .equals(other._customWidgets, _customWidgets));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        backgroundImageUrl,
        backgroundColor,
        backgroundType,
        const DeepCollectionEquality().hash(_gradientColors),
        gradientAngle,
        layout,
        showCoverImage,
        showProfileImage,
        profileImageShape,
        profileImageSize,
        showBio,
        showStats,
        showPosts,
        showAboutSection,
        enableParticles,
        enableAnimatedBackground,
        enableCustomCursor,
        customCursorUrl,
        customCSS,
        enableMusicPlayer,
        musicUrl,
        autoPlayMusic,
        musicVolume,
        cardBorderRadius,
        cardElevation,
        cardBackgroundColor,
        cardOpacity,
        const DeepCollectionEquality().hash(_customWidgets)
      ]);

  @override
  String toString() {
    return 'ProfileCustomization(backgroundImageUrl: $backgroundImageUrl, backgroundColor: $backgroundColor, backgroundType: $backgroundType, gradientColors: $gradientColors, gradientAngle: $gradientAngle, layout: $layout, showCoverImage: $showCoverImage, showProfileImage: $showProfileImage, profileImageShape: $profileImageShape, profileImageSize: $profileImageSize, showBio: $showBio, showStats: $showStats, showPosts: $showPosts, showAboutSection: $showAboutSection, enableParticles: $enableParticles, enableAnimatedBackground: $enableAnimatedBackground, enableCustomCursor: $enableCustomCursor, customCursorUrl: $customCursorUrl, customCSS: $customCSS, enableMusicPlayer: $enableMusicPlayer, musicUrl: $musicUrl, autoPlayMusic: $autoPlayMusic, musicVolume: $musicVolume, cardBorderRadius: $cardBorderRadius, cardElevation: $cardElevation, cardBackgroundColor: $cardBackgroundColor, cardOpacity: $cardOpacity, customWidgets: $customWidgets)';
  }
}

/// @nodoc
abstract mixin class _$ProfileCustomizationCopyWith<$Res>
    implements $ProfileCustomizationCopyWith<$Res> {
  factory _$ProfileCustomizationCopyWith(_ProfileCustomization value,
          $Res Function(_ProfileCustomization) _then) =
      __$ProfileCustomizationCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String? backgroundImageUrl,
      String? backgroundColor,
      String backgroundType,
      List<String> gradientColors,
      double gradientAngle,
      String layout,
      bool showCoverImage,
      bool showProfileImage,
      String profileImageShape,
      double profileImageSize,
      bool showBio,
      bool showStats,
      bool showPosts,
      bool showAboutSection,
      bool enableParticles,
      bool enableAnimatedBackground,
      bool enableCustomCursor,
      String? customCursorUrl,
      String? customCSS,
      bool enableMusicPlayer,
      String? musicUrl,
      bool autoPlayMusic,
      double musicVolume,
      double cardBorderRadius,
      double cardElevation,
      String? cardBackgroundColor,
      double cardOpacity,
      List<CustomWidget> customWidgets});
}

/// @nodoc
class __$ProfileCustomizationCopyWithImpl<$Res>
    implements _$ProfileCustomizationCopyWith<$Res> {
  __$ProfileCustomizationCopyWithImpl(this._self, this._then);

  final _ProfileCustomization _self;
  final $Res Function(_ProfileCustomization) _then;

  /// Create a copy of ProfileCustomization
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? backgroundImageUrl = freezed,
    Object? backgroundColor = freezed,
    Object? backgroundType = null,
    Object? gradientColors = null,
    Object? gradientAngle = null,
    Object? layout = null,
    Object? showCoverImage = null,
    Object? showProfileImage = null,
    Object? profileImageShape = null,
    Object? profileImageSize = null,
    Object? showBio = null,
    Object? showStats = null,
    Object? showPosts = null,
    Object? showAboutSection = null,
    Object? enableParticles = null,
    Object? enableAnimatedBackground = null,
    Object? enableCustomCursor = null,
    Object? customCursorUrl = freezed,
    Object? customCSS = freezed,
    Object? enableMusicPlayer = null,
    Object? musicUrl = freezed,
    Object? autoPlayMusic = null,
    Object? musicVolume = null,
    Object? cardBorderRadius = null,
    Object? cardElevation = null,
    Object? cardBackgroundColor = freezed,
    Object? cardOpacity = null,
    Object? customWidgets = null,
  }) {
    return _then(_ProfileCustomization(
      backgroundImageUrl: freezed == backgroundImageUrl
          ? _self.backgroundImageUrl
          : backgroundImageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundColor: freezed == backgroundColor
          ? _self.backgroundColor
          : backgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      backgroundType: null == backgroundType
          ? _self.backgroundType
          : backgroundType // ignore: cast_nullable_to_non_nullable
              as String,
      gradientColors: null == gradientColors
          ? _self._gradientColors
          : gradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      gradientAngle: null == gradientAngle
          ? _self.gradientAngle
          : gradientAngle // ignore: cast_nullable_to_non_nullable
              as double,
      layout: null == layout
          ? _self.layout
          : layout // ignore: cast_nullable_to_non_nullable
              as String,
      showCoverImage: null == showCoverImage
          ? _self.showCoverImage
          : showCoverImage // ignore: cast_nullable_to_non_nullable
              as bool,
      showProfileImage: null == showProfileImage
          ? _self.showProfileImage
          : showProfileImage // ignore: cast_nullable_to_non_nullable
              as bool,
      profileImageShape: null == profileImageShape
          ? _self.profileImageShape
          : profileImageShape // ignore: cast_nullable_to_non_nullable
              as String,
      profileImageSize: null == profileImageSize
          ? _self.profileImageSize
          : profileImageSize // ignore: cast_nullable_to_non_nullable
              as double,
      showBio: null == showBio
          ? _self.showBio
          : showBio // ignore: cast_nullable_to_non_nullable
              as bool,
      showStats: null == showStats
          ? _self.showStats
          : showStats // ignore: cast_nullable_to_non_nullable
              as bool,
      showPosts: null == showPosts
          ? _self.showPosts
          : showPosts // ignore: cast_nullable_to_non_nullable
              as bool,
      showAboutSection: null == showAboutSection
          ? _self.showAboutSection
          : showAboutSection // ignore: cast_nullable_to_non_nullable
              as bool,
      enableParticles: null == enableParticles
          ? _self.enableParticles
          : enableParticles // ignore: cast_nullable_to_non_nullable
              as bool,
      enableAnimatedBackground: null == enableAnimatedBackground
          ? _self.enableAnimatedBackground
          : enableAnimatedBackground // ignore: cast_nullable_to_non_nullable
              as bool,
      enableCustomCursor: null == enableCustomCursor
          ? _self.enableCustomCursor
          : enableCustomCursor // ignore: cast_nullable_to_non_nullable
              as bool,
      customCursorUrl: freezed == customCursorUrl
          ? _self.customCursorUrl
          : customCursorUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      customCSS: freezed == customCSS
          ? _self.customCSS
          : customCSS // ignore: cast_nullable_to_non_nullable
              as String?,
      enableMusicPlayer: null == enableMusicPlayer
          ? _self.enableMusicPlayer
          : enableMusicPlayer // ignore: cast_nullable_to_non_nullable
              as bool,
      musicUrl: freezed == musicUrl
          ? _self.musicUrl
          : musicUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      autoPlayMusic: null == autoPlayMusic
          ? _self.autoPlayMusic
          : autoPlayMusic // ignore: cast_nullable_to_non_nullable
              as bool,
      musicVolume: null == musicVolume
          ? _self.musicVolume
          : musicVolume // ignore: cast_nullable_to_non_nullable
              as double,
      cardBorderRadius: null == cardBorderRadius
          ? _self.cardBorderRadius
          : cardBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      cardElevation: null == cardElevation
          ? _self.cardElevation
          : cardElevation // ignore: cast_nullable_to_non_nullable
              as double,
      cardBackgroundColor: freezed == cardBackgroundColor
          ? _self.cardBackgroundColor
          : cardBackgroundColor // ignore: cast_nullable_to_non_nullable
              as String?,
      cardOpacity: null == cardOpacity
          ? _self.cardOpacity
          : cardOpacity // ignore: cast_nullable_to_non_nullable
              as double,
      customWidgets: null == customWidgets
          ? _self._customWidgets
          : customWidgets // ignore: cast_nullable_to_non_nullable
              as List<CustomWidget>,
    ));
  }
}

/// @nodoc
mixin _$ComponentStyles {
// Button styling with safe defaults
  ButtonStyle get primaryButton;
  ButtonStyle get secondaryButton;
  double get buttonBorderRadius; // Card styling with safe defaults
  double get cardBorderRadius;
  double get cardElevation;
  bool get cardOutline;
  String get cardOutlineColor; // Input field styling with safe defaults
  InputFieldStyle get inputField; // Navigation bar styling with safe defaults
  NavigationStyle get navigation; // Dialog styling with safe defaults
  double get dialogBorderRadius;
  bool get dialogBlurBackground;
  double get dialogBlurIntensity;

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ComponentStylesCopyWith<ComponentStyles> get copyWith =>
      _$ComponentStylesCopyWithImpl<ComponentStyles>(
          this as ComponentStyles, _$identity);

  /// Serializes this ComponentStyles to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ComponentStyles &&
            (identical(other.primaryButton, primaryButton) ||
                other.primaryButton == primaryButton) &&
            (identical(other.secondaryButton, secondaryButton) ||
                other.secondaryButton == secondaryButton) &&
            (identical(other.buttonBorderRadius, buttonBorderRadius) ||
                other.buttonBorderRadius == buttonBorderRadius) &&
            (identical(other.cardBorderRadius, cardBorderRadius) ||
                other.cardBorderRadius == cardBorderRadius) &&
            (identical(other.cardElevation, cardElevation) ||
                other.cardElevation == cardElevation) &&
            (identical(other.cardOutline, cardOutline) ||
                other.cardOutline == cardOutline) &&
            (identical(other.cardOutlineColor, cardOutlineColor) ||
                other.cardOutlineColor == cardOutlineColor) &&
            (identical(other.inputField, inputField) ||
                other.inputField == inputField) &&
            (identical(other.navigation, navigation) ||
                other.navigation == navigation) &&
            (identical(other.dialogBorderRadius, dialogBorderRadius) ||
                other.dialogBorderRadius == dialogBorderRadius) &&
            (identical(other.dialogBlurBackground, dialogBlurBackground) ||
                other.dialogBlurBackground == dialogBlurBackground) &&
            (identical(other.dialogBlurIntensity, dialogBlurIntensity) ||
                other.dialogBlurIntensity == dialogBlurIntensity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryButton,
      secondaryButton,
      buttonBorderRadius,
      cardBorderRadius,
      cardElevation,
      cardOutline,
      cardOutlineColor,
      inputField,
      navigation,
      dialogBorderRadius,
      dialogBlurBackground,
      dialogBlurIntensity);

  @override
  String toString() {
    return 'ComponentStyles(primaryButton: $primaryButton, secondaryButton: $secondaryButton, buttonBorderRadius: $buttonBorderRadius, cardBorderRadius: $cardBorderRadius, cardElevation: $cardElevation, cardOutline: $cardOutline, cardOutlineColor: $cardOutlineColor, inputField: $inputField, navigation: $navigation, dialogBorderRadius: $dialogBorderRadius, dialogBlurBackground: $dialogBlurBackground, dialogBlurIntensity: $dialogBlurIntensity)';
  }
}

/// @nodoc
abstract mixin class $ComponentStylesCopyWith<$Res> {
  factory $ComponentStylesCopyWith(
          ComponentStyles value, $Res Function(ComponentStyles) _then) =
      _$ComponentStylesCopyWithImpl;
  @useResult
  $Res call(
      {ButtonStyle primaryButton,
      ButtonStyle secondaryButton,
      double buttonBorderRadius,
      double cardBorderRadius,
      double cardElevation,
      bool cardOutline,
      String cardOutlineColor,
      InputFieldStyle inputField,
      NavigationStyle navigation,
      double dialogBorderRadius,
      bool dialogBlurBackground,
      double dialogBlurIntensity});

  $ButtonStyleCopyWith<$Res> get primaryButton;
  $ButtonStyleCopyWith<$Res> get secondaryButton;
  $InputFieldStyleCopyWith<$Res> get inputField;
  $NavigationStyleCopyWith<$Res> get navigation;
}

/// @nodoc
class _$ComponentStylesCopyWithImpl<$Res>
    implements $ComponentStylesCopyWith<$Res> {
  _$ComponentStylesCopyWithImpl(this._self, this._then);

  final ComponentStyles _self;
  final $Res Function(ComponentStyles) _then;

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryButton = null,
    Object? secondaryButton = null,
    Object? buttonBorderRadius = null,
    Object? cardBorderRadius = null,
    Object? cardElevation = null,
    Object? cardOutline = null,
    Object? cardOutlineColor = null,
    Object? inputField = null,
    Object? navigation = null,
    Object? dialogBorderRadius = null,
    Object? dialogBlurBackground = null,
    Object? dialogBlurIntensity = null,
  }) {
    return _then(_self.copyWith(
      primaryButton: null == primaryButton
          ? _self.primaryButton
          : primaryButton // ignore: cast_nullable_to_non_nullable
              as ButtonStyle,
      secondaryButton: null == secondaryButton
          ? _self.secondaryButton
          : secondaryButton // ignore: cast_nullable_to_non_nullable
              as ButtonStyle,
      buttonBorderRadius: null == buttonBorderRadius
          ? _self.buttonBorderRadius
          : buttonBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      cardBorderRadius: null == cardBorderRadius
          ? _self.cardBorderRadius
          : cardBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      cardElevation: null == cardElevation
          ? _self.cardElevation
          : cardElevation // ignore: cast_nullable_to_non_nullable
              as double,
      cardOutline: null == cardOutline
          ? _self.cardOutline
          : cardOutline // ignore: cast_nullable_to_non_nullable
              as bool,
      cardOutlineColor: null == cardOutlineColor
          ? _self.cardOutlineColor
          : cardOutlineColor // ignore: cast_nullable_to_non_nullable
              as String,
      inputField: null == inputField
          ? _self.inputField
          : inputField // ignore: cast_nullable_to_non_nullable
              as InputFieldStyle,
      navigation: null == navigation
          ? _self.navigation
          : navigation // ignore: cast_nullable_to_non_nullable
              as NavigationStyle,
      dialogBorderRadius: null == dialogBorderRadius
          ? _self.dialogBorderRadius
          : dialogBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      dialogBlurBackground: null == dialogBlurBackground
          ? _self.dialogBlurBackground
          : dialogBlurBackground // ignore: cast_nullable_to_non_nullable
              as bool,
      dialogBlurIntensity: null == dialogBlurIntensity
          ? _self.dialogBlurIntensity
          : dialogBlurIntensity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ButtonStyleCopyWith<$Res> get primaryButton {
    return $ButtonStyleCopyWith<$Res>(_self.primaryButton, (value) {
      return _then(_self.copyWith(primaryButton: value));
    });
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ButtonStyleCopyWith<$Res> get secondaryButton {
    return $ButtonStyleCopyWith<$Res>(_self.secondaryButton, (value) {
      return _then(_self.copyWith(secondaryButton: value));
    });
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InputFieldStyleCopyWith<$Res> get inputField {
    return $InputFieldStyleCopyWith<$Res>(_self.inputField, (value) {
      return _then(_self.copyWith(inputField: value));
    });
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NavigationStyleCopyWith<$Res> get navigation {
    return $NavigationStyleCopyWith<$Res>(_self.navigation, (value) {
      return _then(_self.copyWith(navigation: value));
    });
  }
}

/// Adds pattern-matching-related methods to [ComponentStyles].
extension ComponentStylesPatterns on ComponentStyles {
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
    TResult Function(_ComponentStyles value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ComponentStyles() when $default != null:
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
    TResult Function(_ComponentStyles value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ComponentStyles():
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
    TResult? Function(_ComponentStyles value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ComponentStyles() when $default != null:
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
            ButtonStyle primaryButton,
            ButtonStyle secondaryButton,
            double buttonBorderRadius,
            double cardBorderRadius,
            double cardElevation,
            bool cardOutline,
            String cardOutlineColor,
            InputFieldStyle inputField,
            NavigationStyle navigation,
            double dialogBorderRadius,
            bool dialogBlurBackground,
            double dialogBlurIntensity)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ComponentStyles() when $default != null:
        return $default(
            _that.primaryButton,
            _that.secondaryButton,
            _that.buttonBorderRadius,
            _that.cardBorderRadius,
            _that.cardElevation,
            _that.cardOutline,
            _that.cardOutlineColor,
            _that.inputField,
            _that.navigation,
            _that.dialogBorderRadius,
            _that.dialogBlurBackground,
            _that.dialogBlurIntensity);
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
            ButtonStyle primaryButton,
            ButtonStyle secondaryButton,
            double buttonBorderRadius,
            double cardBorderRadius,
            double cardElevation,
            bool cardOutline,
            String cardOutlineColor,
            InputFieldStyle inputField,
            NavigationStyle navigation,
            double dialogBorderRadius,
            bool dialogBlurBackground,
            double dialogBlurIntensity)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ComponentStyles():
        return $default(
            _that.primaryButton,
            _that.secondaryButton,
            _that.buttonBorderRadius,
            _that.cardBorderRadius,
            _that.cardElevation,
            _that.cardOutline,
            _that.cardOutlineColor,
            _that.inputField,
            _that.navigation,
            _that.dialogBorderRadius,
            _that.dialogBlurBackground,
            _that.dialogBlurIntensity);
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
            ButtonStyle primaryButton,
            ButtonStyle secondaryButton,
            double buttonBorderRadius,
            double cardBorderRadius,
            double cardElevation,
            bool cardOutline,
            String cardOutlineColor,
            InputFieldStyle inputField,
            NavigationStyle navigation,
            double dialogBorderRadius,
            bool dialogBlurBackground,
            double dialogBlurIntensity)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ComponentStyles() when $default != null:
        return $default(
            _that.primaryButton,
            _that.secondaryButton,
            _that.buttonBorderRadius,
            _that.cardBorderRadius,
            _that.cardElevation,
            _that.cardOutline,
            _that.cardOutlineColor,
            _that.inputField,
            _that.navigation,
            _that.dialogBorderRadius,
            _that.dialogBlurBackground,
            _that.dialogBlurIntensity);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ComponentStyles implements ComponentStyles {
  const _ComponentStyles(
      {this.primaryButton = const ButtonStyle(),
      this.secondaryButton = const ButtonStyle(),
      this.buttonBorderRadius = 15.0,
      this.cardBorderRadius = 16.0,
      this.cardElevation = 2.0,
      this.cardOutline = false,
      this.cardOutlineColor = '#E0E0E0',
      this.inputField = const InputFieldStyle(),
      this.navigation = const NavigationStyle(),
      this.dialogBorderRadius = 24.0,
      this.dialogBlurBackground = false,
      this.dialogBlurIntensity = 10.0});
  factory _ComponentStyles.fromJson(Map<String, dynamic> json) =>
      _$ComponentStylesFromJson(json);

// Button styling with safe defaults
  @override
  @JsonKey()
  final ButtonStyle primaryButton;
  @override
  @JsonKey()
  final ButtonStyle secondaryButton;
  @override
  @JsonKey()
  final double buttonBorderRadius;
// Card styling with safe defaults
  @override
  @JsonKey()
  final double cardBorderRadius;
  @override
  @JsonKey()
  final double cardElevation;
  @override
  @JsonKey()
  final bool cardOutline;
  @override
  @JsonKey()
  final String cardOutlineColor;
// Input field styling with safe defaults
  @override
  @JsonKey()
  final InputFieldStyle inputField;
// Navigation bar styling with safe defaults
  @override
  @JsonKey()
  final NavigationStyle navigation;
// Dialog styling with safe defaults
  @override
  @JsonKey()
  final double dialogBorderRadius;
  @override
  @JsonKey()
  final bool dialogBlurBackground;
  @override
  @JsonKey()
  final double dialogBlurIntensity;

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ComponentStylesCopyWith<_ComponentStyles> get copyWith =>
      __$ComponentStylesCopyWithImpl<_ComponentStyles>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ComponentStylesToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ComponentStyles &&
            (identical(other.primaryButton, primaryButton) ||
                other.primaryButton == primaryButton) &&
            (identical(other.secondaryButton, secondaryButton) ||
                other.secondaryButton == secondaryButton) &&
            (identical(other.buttonBorderRadius, buttonBorderRadius) ||
                other.buttonBorderRadius == buttonBorderRadius) &&
            (identical(other.cardBorderRadius, cardBorderRadius) ||
                other.cardBorderRadius == cardBorderRadius) &&
            (identical(other.cardElevation, cardElevation) ||
                other.cardElevation == cardElevation) &&
            (identical(other.cardOutline, cardOutline) ||
                other.cardOutline == cardOutline) &&
            (identical(other.cardOutlineColor, cardOutlineColor) ||
                other.cardOutlineColor == cardOutlineColor) &&
            (identical(other.inputField, inputField) ||
                other.inputField == inputField) &&
            (identical(other.navigation, navigation) ||
                other.navigation == navigation) &&
            (identical(other.dialogBorderRadius, dialogBorderRadius) ||
                other.dialogBorderRadius == dialogBorderRadius) &&
            (identical(other.dialogBlurBackground, dialogBlurBackground) ||
                other.dialogBlurBackground == dialogBlurBackground) &&
            (identical(other.dialogBlurIntensity, dialogBlurIntensity) ||
                other.dialogBlurIntensity == dialogBlurIntensity));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryButton,
      secondaryButton,
      buttonBorderRadius,
      cardBorderRadius,
      cardElevation,
      cardOutline,
      cardOutlineColor,
      inputField,
      navigation,
      dialogBorderRadius,
      dialogBlurBackground,
      dialogBlurIntensity);

  @override
  String toString() {
    return 'ComponentStyles(primaryButton: $primaryButton, secondaryButton: $secondaryButton, buttonBorderRadius: $buttonBorderRadius, cardBorderRadius: $cardBorderRadius, cardElevation: $cardElevation, cardOutline: $cardOutline, cardOutlineColor: $cardOutlineColor, inputField: $inputField, navigation: $navigation, dialogBorderRadius: $dialogBorderRadius, dialogBlurBackground: $dialogBlurBackground, dialogBlurIntensity: $dialogBlurIntensity)';
  }
}

/// @nodoc
abstract mixin class _$ComponentStylesCopyWith<$Res>
    implements $ComponentStylesCopyWith<$Res> {
  factory _$ComponentStylesCopyWith(
          _ComponentStyles value, $Res Function(_ComponentStyles) _then) =
      __$ComponentStylesCopyWithImpl;
  @override
  @useResult
  $Res call(
      {ButtonStyle primaryButton,
      ButtonStyle secondaryButton,
      double buttonBorderRadius,
      double cardBorderRadius,
      double cardElevation,
      bool cardOutline,
      String cardOutlineColor,
      InputFieldStyle inputField,
      NavigationStyle navigation,
      double dialogBorderRadius,
      bool dialogBlurBackground,
      double dialogBlurIntensity});

  @override
  $ButtonStyleCopyWith<$Res> get primaryButton;
  @override
  $ButtonStyleCopyWith<$Res> get secondaryButton;
  @override
  $InputFieldStyleCopyWith<$Res> get inputField;
  @override
  $NavigationStyleCopyWith<$Res> get navigation;
}

/// @nodoc
class __$ComponentStylesCopyWithImpl<$Res>
    implements _$ComponentStylesCopyWith<$Res> {
  __$ComponentStylesCopyWithImpl(this._self, this._then);

  final _ComponentStyles _self;
  final $Res Function(_ComponentStyles) _then;

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? primaryButton = null,
    Object? secondaryButton = null,
    Object? buttonBorderRadius = null,
    Object? cardBorderRadius = null,
    Object? cardElevation = null,
    Object? cardOutline = null,
    Object? cardOutlineColor = null,
    Object? inputField = null,
    Object? navigation = null,
    Object? dialogBorderRadius = null,
    Object? dialogBlurBackground = null,
    Object? dialogBlurIntensity = null,
  }) {
    return _then(_ComponentStyles(
      primaryButton: null == primaryButton
          ? _self.primaryButton
          : primaryButton // ignore: cast_nullable_to_non_nullable
              as ButtonStyle,
      secondaryButton: null == secondaryButton
          ? _self.secondaryButton
          : secondaryButton // ignore: cast_nullable_to_non_nullable
              as ButtonStyle,
      buttonBorderRadius: null == buttonBorderRadius
          ? _self.buttonBorderRadius
          : buttonBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      cardBorderRadius: null == cardBorderRadius
          ? _self.cardBorderRadius
          : cardBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      cardElevation: null == cardElevation
          ? _self.cardElevation
          : cardElevation // ignore: cast_nullable_to_non_nullable
              as double,
      cardOutline: null == cardOutline
          ? _self.cardOutline
          : cardOutline // ignore: cast_nullable_to_non_nullable
              as bool,
      cardOutlineColor: null == cardOutlineColor
          ? _self.cardOutlineColor
          : cardOutlineColor // ignore: cast_nullable_to_non_nullable
              as String,
      inputField: null == inputField
          ? _self.inputField
          : inputField // ignore: cast_nullable_to_non_nullable
              as InputFieldStyle,
      navigation: null == navigation
          ? _self.navigation
          : navigation // ignore: cast_nullable_to_non_nullable
              as NavigationStyle,
      dialogBorderRadius: null == dialogBorderRadius
          ? _self.dialogBorderRadius
          : dialogBorderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      dialogBlurBackground: null == dialogBlurBackground
          ? _self.dialogBlurBackground
          : dialogBlurBackground // ignore: cast_nullable_to_non_nullable
              as bool,
      dialogBlurIntensity: null == dialogBlurIntensity
          ? _self.dialogBlurIntensity
          : dialogBlurIntensity // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ButtonStyleCopyWith<$Res> get primaryButton {
    return $ButtonStyleCopyWith<$Res>(_self.primaryButton, (value) {
      return _then(_self.copyWith(primaryButton: value));
    });
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ButtonStyleCopyWith<$Res> get secondaryButton {
    return $ButtonStyleCopyWith<$Res>(_self.secondaryButton, (value) {
      return _then(_self.copyWith(secondaryButton: value));
    });
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $InputFieldStyleCopyWith<$Res> get inputField {
    return $InputFieldStyleCopyWith<$Res>(_self.inputField, (value) {
      return _then(_self.copyWith(inputField: value));
    });
  }

  /// Create a copy of ComponentStyles
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $NavigationStyleCopyWith<$Res> get navigation {
    return $NavigationStyleCopyWith<$Res>(_self.navigation, (value) {
      return _then(_self.copyWith(navigation: value));
    });
  }
}

/// @nodoc
mixin _$ButtonStyle {
  double get borderRadius;
  double get horizontalPadding;
  double get verticalPadding;
  double get elevation;
  bool get enableGradient;
  List<String> get gradientColors;
  String get shape;
  bool get enableRipple;
  String? get rippleColor;
  String get fontWeight;
  double get fontSize;
  bool get uppercase;
  double get letterSpacing;

  /// Create a copy of ButtonStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $ButtonStyleCopyWith<ButtonStyle> get copyWith =>
      _$ButtonStyleCopyWithImpl<ButtonStyle>(this as ButtonStyle, _$identity);

  /// Serializes this ButtonStyle to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is ButtonStyle &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.horizontalPadding, horizontalPadding) ||
                other.horizontalPadding == horizontalPadding) &&
            (identical(other.verticalPadding, verticalPadding) ||
                other.verticalPadding == verticalPadding) &&
            (identical(other.elevation, elevation) ||
                other.elevation == elevation) &&
            (identical(other.enableGradient, enableGradient) ||
                other.enableGradient == enableGradient) &&
            const DeepCollectionEquality()
                .equals(other.gradientColors, gradientColors) &&
            (identical(other.shape, shape) || other.shape == shape) &&
            (identical(other.enableRipple, enableRipple) ||
                other.enableRipple == enableRipple) &&
            (identical(other.rippleColor, rippleColor) ||
                other.rippleColor == rippleColor) &&
            (identical(other.fontWeight, fontWeight) ||
                other.fontWeight == fontWeight) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.uppercase, uppercase) ||
                other.uppercase == uppercase) &&
            (identical(other.letterSpacing, letterSpacing) ||
                other.letterSpacing == letterSpacing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      borderRadius,
      horizontalPadding,
      verticalPadding,
      elevation,
      enableGradient,
      const DeepCollectionEquality().hash(gradientColors),
      shape,
      enableRipple,
      rippleColor,
      fontWeight,
      fontSize,
      uppercase,
      letterSpacing);

  @override
  String toString() {
    return 'ButtonStyle(borderRadius: $borderRadius, horizontalPadding: $horizontalPadding, verticalPadding: $verticalPadding, elevation: $elevation, enableGradient: $enableGradient, gradientColors: $gradientColors, shape: $shape, enableRipple: $enableRipple, rippleColor: $rippleColor, fontWeight: $fontWeight, fontSize: $fontSize, uppercase: $uppercase, letterSpacing: $letterSpacing)';
  }
}

/// @nodoc
abstract mixin class $ButtonStyleCopyWith<$Res> {
  factory $ButtonStyleCopyWith(
          ButtonStyle value, $Res Function(ButtonStyle) _then) =
      _$ButtonStyleCopyWithImpl;
  @useResult
  $Res call(
      {double borderRadius,
      double horizontalPadding,
      double verticalPadding,
      double elevation,
      bool enableGradient,
      List<String> gradientColors,
      String shape,
      bool enableRipple,
      String? rippleColor,
      String fontWeight,
      double fontSize,
      bool uppercase,
      double letterSpacing});
}

/// @nodoc
class _$ButtonStyleCopyWithImpl<$Res> implements $ButtonStyleCopyWith<$Res> {
  _$ButtonStyleCopyWithImpl(this._self, this._then);

  final ButtonStyle _self;
  final $Res Function(ButtonStyle) _then;

  /// Create a copy of ButtonStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? borderRadius = null,
    Object? horizontalPadding = null,
    Object? verticalPadding = null,
    Object? elevation = null,
    Object? enableGradient = null,
    Object? gradientColors = null,
    Object? shape = null,
    Object? enableRipple = null,
    Object? rippleColor = freezed,
    Object? fontWeight = null,
    Object? fontSize = null,
    Object? uppercase = null,
    Object? letterSpacing = null,
  }) {
    return _then(_self.copyWith(
      borderRadius: null == borderRadius
          ? _self.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      horizontalPadding: null == horizontalPadding
          ? _self.horizontalPadding
          : horizontalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      verticalPadding: null == verticalPadding
          ? _self.verticalPadding
          : verticalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      elevation: null == elevation
          ? _self.elevation
          : elevation // ignore: cast_nullable_to_non_nullable
              as double,
      enableGradient: null == enableGradient
          ? _self.enableGradient
          : enableGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      gradientColors: null == gradientColors
          ? _self.gradientColors
          : gradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shape: null == shape
          ? _self.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as String,
      enableRipple: null == enableRipple
          ? _self.enableRipple
          : enableRipple // ignore: cast_nullable_to_non_nullable
              as bool,
      rippleColor: freezed == rippleColor
          ? _self.rippleColor
          : rippleColor // ignore: cast_nullable_to_non_nullable
              as String?,
      fontWeight: null == fontWeight
          ? _self.fontWeight
          : fontWeight // ignore: cast_nullable_to_non_nullable
              as String,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      uppercase: null == uppercase
          ? _self.uppercase
          : uppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      letterSpacing: null == letterSpacing
          ? _self.letterSpacing
          : letterSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [ButtonStyle].
extension ButtonStylePatterns on ButtonStyle {
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
    TResult Function(_ButtonStyle value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ButtonStyle() when $default != null:
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
    TResult Function(_ButtonStyle value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ButtonStyle():
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
    TResult? Function(_ButtonStyle value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ButtonStyle() when $default != null:
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
            double borderRadius,
            double horizontalPadding,
            double verticalPadding,
            double elevation,
            bool enableGradient,
            List<String> gradientColors,
            String shape,
            bool enableRipple,
            String? rippleColor,
            String fontWeight,
            double fontSize,
            bool uppercase,
            double letterSpacing)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _ButtonStyle() when $default != null:
        return $default(
            _that.borderRadius,
            _that.horizontalPadding,
            _that.verticalPadding,
            _that.elevation,
            _that.enableGradient,
            _that.gradientColors,
            _that.shape,
            _that.enableRipple,
            _that.rippleColor,
            _that.fontWeight,
            _that.fontSize,
            _that.uppercase,
            _that.letterSpacing);
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
            double borderRadius,
            double horizontalPadding,
            double verticalPadding,
            double elevation,
            bool enableGradient,
            List<String> gradientColors,
            String shape,
            bool enableRipple,
            String? rippleColor,
            String fontWeight,
            double fontSize,
            bool uppercase,
            double letterSpacing)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ButtonStyle():
        return $default(
            _that.borderRadius,
            _that.horizontalPadding,
            _that.verticalPadding,
            _that.elevation,
            _that.enableGradient,
            _that.gradientColors,
            _that.shape,
            _that.enableRipple,
            _that.rippleColor,
            _that.fontWeight,
            _that.fontSize,
            _that.uppercase,
            _that.letterSpacing);
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
            double borderRadius,
            double horizontalPadding,
            double verticalPadding,
            double elevation,
            bool enableGradient,
            List<String> gradientColors,
            String shape,
            bool enableRipple,
            String? rippleColor,
            String fontWeight,
            double fontSize,
            bool uppercase,
            double letterSpacing)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _ButtonStyle() when $default != null:
        return $default(
            _that.borderRadius,
            _that.horizontalPadding,
            _that.verticalPadding,
            _that.elevation,
            _that.enableGradient,
            _that.gradientColors,
            _that.shape,
            _that.enableRipple,
            _that.rippleColor,
            _that.fontWeight,
            _that.fontSize,
            _that.uppercase,
            _that.letterSpacing);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _ButtonStyle implements ButtonStyle {
  const _ButtonStyle(
      {this.borderRadius = 8.0,
      this.horizontalPadding = 16.0,
      this.verticalPadding = 8.0,
      this.elevation = 1.0,
      this.enableGradient = false,
      final List<String> gradientColors = const [],
      this.shape = 'rounded',
      this.enableRipple = false,
      this.rippleColor,
      this.fontWeight = 'w500',
      this.fontSize = 14.0,
      this.uppercase = false,
      this.letterSpacing = 1.0})
      : _gradientColors = gradientColors;
  factory _ButtonStyle.fromJson(Map<String, dynamic> json) =>
      _$ButtonStyleFromJson(json);

  @override
  @JsonKey()
  final double borderRadius;
  @override
  @JsonKey()
  final double horizontalPadding;
  @override
  @JsonKey()
  final double verticalPadding;
  @override
  @JsonKey()
  final double elevation;
  @override
  @JsonKey()
  final bool enableGradient;
  final List<String> _gradientColors;
  @override
  @JsonKey()
  List<String> get gradientColors {
    if (_gradientColors is EqualUnmodifiableListView) return _gradientColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradientColors);
  }

  @override
  @JsonKey()
  final String shape;
  @override
  @JsonKey()
  final bool enableRipple;
  @override
  final String? rippleColor;
  @override
  @JsonKey()
  final String fontWeight;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final bool uppercase;
  @override
  @JsonKey()
  final double letterSpacing;

  /// Create a copy of ButtonStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$ButtonStyleCopyWith<_ButtonStyle> get copyWith =>
      __$ButtonStyleCopyWithImpl<_ButtonStyle>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$ButtonStyleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _ButtonStyle &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.horizontalPadding, horizontalPadding) ||
                other.horizontalPadding == horizontalPadding) &&
            (identical(other.verticalPadding, verticalPadding) ||
                other.verticalPadding == verticalPadding) &&
            (identical(other.elevation, elevation) ||
                other.elevation == elevation) &&
            (identical(other.enableGradient, enableGradient) ||
                other.enableGradient == enableGradient) &&
            const DeepCollectionEquality()
                .equals(other._gradientColors, _gradientColors) &&
            (identical(other.shape, shape) || other.shape == shape) &&
            (identical(other.enableRipple, enableRipple) ||
                other.enableRipple == enableRipple) &&
            (identical(other.rippleColor, rippleColor) ||
                other.rippleColor == rippleColor) &&
            (identical(other.fontWeight, fontWeight) ||
                other.fontWeight == fontWeight) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.uppercase, uppercase) ||
                other.uppercase == uppercase) &&
            (identical(other.letterSpacing, letterSpacing) ||
                other.letterSpacing == letterSpacing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      borderRadius,
      horizontalPadding,
      verticalPadding,
      elevation,
      enableGradient,
      const DeepCollectionEquality().hash(_gradientColors),
      shape,
      enableRipple,
      rippleColor,
      fontWeight,
      fontSize,
      uppercase,
      letterSpacing);

  @override
  String toString() {
    return 'ButtonStyle(borderRadius: $borderRadius, horizontalPadding: $horizontalPadding, verticalPadding: $verticalPadding, elevation: $elevation, enableGradient: $enableGradient, gradientColors: $gradientColors, shape: $shape, enableRipple: $enableRipple, rippleColor: $rippleColor, fontWeight: $fontWeight, fontSize: $fontSize, uppercase: $uppercase, letterSpacing: $letterSpacing)';
  }
}

/// @nodoc
abstract mixin class _$ButtonStyleCopyWith<$Res>
    implements $ButtonStyleCopyWith<$Res> {
  factory _$ButtonStyleCopyWith(
          _ButtonStyle value, $Res Function(_ButtonStyle) _then) =
      __$ButtonStyleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double borderRadius,
      double horizontalPadding,
      double verticalPadding,
      double elevation,
      bool enableGradient,
      List<String> gradientColors,
      String shape,
      bool enableRipple,
      String? rippleColor,
      String fontWeight,
      double fontSize,
      bool uppercase,
      double letterSpacing});
}

/// @nodoc
class __$ButtonStyleCopyWithImpl<$Res> implements _$ButtonStyleCopyWith<$Res> {
  __$ButtonStyleCopyWithImpl(this._self, this._then);

  final _ButtonStyle _self;
  final $Res Function(_ButtonStyle) _then;

  /// Create a copy of ButtonStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? borderRadius = null,
    Object? horizontalPadding = null,
    Object? verticalPadding = null,
    Object? elevation = null,
    Object? enableGradient = null,
    Object? gradientColors = null,
    Object? shape = null,
    Object? enableRipple = null,
    Object? rippleColor = freezed,
    Object? fontWeight = null,
    Object? fontSize = null,
    Object? uppercase = null,
    Object? letterSpacing = null,
  }) {
    return _then(_ButtonStyle(
      borderRadius: null == borderRadius
          ? _self.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      horizontalPadding: null == horizontalPadding
          ? _self.horizontalPadding
          : horizontalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      verticalPadding: null == verticalPadding
          ? _self.verticalPadding
          : verticalPadding // ignore: cast_nullable_to_non_nullable
              as double,
      elevation: null == elevation
          ? _self.elevation
          : elevation // ignore: cast_nullable_to_non_nullable
              as double,
      enableGradient: null == enableGradient
          ? _self.enableGradient
          : enableGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      gradientColors: null == gradientColors
          ? _self._gradientColors
          : gradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      shape: null == shape
          ? _self.shape
          : shape // ignore: cast_nullable_to_non_nullable
              as String,
      enableRipple: null == enableRipple
          ? _self.enableRipple
          : enableRipple // ignore: cast_nullable_to_non_nullable
              as bool,
      rippleColor: freezed == rippleColor
          ? _self.rippleColor
          : rippleColor // ignore: cast_nullable_to_non_nullable
              as String?,
      fontWeight: null == fontWeight
          ? _self.fontWeight
          : fontWeight // ignore: cast_nullable_to_non_nullable
              as String,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      uppercase: null == uppercase
          ? _self.uppercase
          : uppercase // ignore: cast_nullable_to_non_nullable
              as bool,
      letterSpacing: null == letterSpacing
          ? _self.letterSpacing
          : letterSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$InputFieldStyle {
  double get borderRadius;
  String get borderType;
  double get borderWidth;
  bool get filled;
  String? get fillColor;
  double get contentPadding;
  double get fontSize;
  bool get enableFloatingLabel;

  /// Create a copy of InputFieldStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $InputFieldStyleCopyWith<InputFieldStyle> get copyWith =>
      _$InputFieldStyleCopyWithImpl<InputFieldStyle>(
          this as InputFieldStyle, _$identity);

  /// Serializes this InputFieldStyle to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is InputFieldStyle &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.borderType, borderType) ||
                other.borderType == borderType) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.filled, filled) || other.filled == filled) &&
            (identical(other.fillColor, fillColor) ||
                other.fillColor == fillColor) &&
            (identical(other.contentPadding, contentPadding) ||
                other.contentPadding == contentPadding) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.enableFloatingLabel, enableFloatingLabel) ||
                other.enableFloatingLabel == enableFloatingLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      borderRadius,
      borderType,
      borderWidth,
      filled,
      fillColor,
      contentPadding,
      fontSize,
      enableFloatingLabel);

  @override
  String toString() {
    return 'InputFieldStyle(borderRadius: $borderRadius, borderType: $borderType, borderWidth: $borderWidth, filled: $filled, fillColor: $fillColor, contentPadding: $contentPadding, fontSize: $fontSize, enableFloatingLabel: $enableFloatingLabel)';
  }
}

/// @nodoc
abstract mixin class $InputFieldStyleCopyWith<$Res> {
  factory $InputFieldStyleCopyWith(
          InputFieldStyle value, $Res Function(InputFieldStyle) _then) =
      _$InputFieldStyleCopyWithImpl;
  @useResult
  $Res call(
      {double borderRadius,
      String borderType,
      double borderWidth,
      bool filled,
      String? fillColor,
      double contentPadding,
      double fontSize,
      bool enableFloatingLabel});
}

/// @nodoc
class _$InputFieldStyleCopyWithImpl<$Res>
    implements $InputFieldStyleCopyWith<$Res> {
  _$InputFieldStyleCopyWithImpl(this._self, this._then);

  final InputFieldStyle _self;
  final $Res Function(InputFieldStyle) _then;

  /// Create a copy of InputFieldStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? borderRadius = null,
    Object? borderType = null,
    Object? borderWidth = null,
    Object? filled = null,
    Object? fillColor = freezed,
    Object? contentPadding = null,
    Object? fontSize = null,
    Object? enableFloatingLabel = null,
  }) {
    return _then(_self.copyWith(
      borderRadius: null == borderRadius
          ? _self.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      borderType: null == borderType
          ? _self.borderType
          : borderType // ignore: cast_nullable_to_non_nullable
              as String,
      borderWidth: null == borderWidth
          ? _self.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      filled: null == filled
          ? _self.filled
          : filled // ignore: cast_nullable_to_non_nullable
              as bool,
      fillColor: freezed == fillColor
          ? _self.fillColor
          : fillColor // ignore: cast_nullable_to_non_nullable
              as String?,
      contentPadding: null == contentPadding
          ? _self.contentPadding
          : contentPadding // ignore: cast_nullable_to_non_nullable
              as double,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableFloatingLabel: null == enableFloatingLabel
          ? _self.enableFloatingLabel
          : enableFloatingLabel // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [InputFieldStyle].
extension InputFieldStylePatterns on InputFieldStyle {
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
    TResult Function(_InputFieldStyle value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InputFieldStyle() when $default != null:
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
    TResult Function(_InputFieldStyle value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InputFieldStyle():
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
    TResult? Function(_InputFieldStyle value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InputFieldStyle() when $default != null:
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
            double borderRadius,
            String borderType,
            double borderWidth,
            bool filled,
            String? fillColor,
            double contentPadding,
            double fontSize,
            bool enableFloatingLabel)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _InputFieldStyle() when $default != null:
        return $default(
            _that.borderRadius,
            _that.borderType,
            _that.borderWidth,
            _that.filled,
            _that.fillColor,
            _that.contentPadding,
            _that.fontSize,
            _that.enableFloatingLabel);
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
            double borderRadius,
            String borderType,
            double borderWidth,
            bool filled,
            String? fillColor,
            double contentPadding,
            double fontSize,
            bool enableFloatingLabel)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InputFieldStyle():
        return $default(
            _that.borderRadius,
            _that.borderType,
            _that.borderWidth,
            _that.filled,
            _that.fillColor,
            _that.contentPadding,
            _that.fontSize,
            _that.enableFloatingLabel);
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
            double borderRadius,
            String borderType,
            double borderWidth,
            bool filled,
            String? fillColor,
            double contentPadding,
            double fontSize,
            bool enableFloatingLabel)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _InputFieldStyle() when $default != null:
        return $default(
            _that.borderRadius,
            _that.borderType,
            _that.borderWidth,
            _that.filled,
            _that.fillColor,
            _that.contentPadding,
            _that.fontSize,
            _that.enableFloatingLabel);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _InputFieldStyle implements InputFieldStyle {
  const _InputFieldStyle(
      {this.borderRadius = 8.0,
      this.borderType = 'outline',
      this.borderWidth = 1.0,
      this.filled = false,
      this.fillColor,
      this.contentPadding = 16.0,
      this.fontSize = 14.0,
      this.enableFloatingLabel = false});
  factory _InputFieldStyle.fromJson(Map<String, dynamic> json) =>
      _$InputFieldStyleFromJson(json);

  @override
  @JsonKey()
  final double borderRadius;
  @override
  @JsonKey()
  final String borderType;
  @override
  @JsonKey()
  final double borderWidth;
  @override
  @JsonKey()
  final bool filled;
  @override
  final String? fillColor;
  @override
  @JsonKey()
  final double contentPadding;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final bool enableFloatingLabel;

  /// Create a copy of InputFieldStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$InputFieldStyleCopyWith<_InputFieldStyle> get copyWith =>
      __$InputFieldStyleCopyWithImpl<_InputFieldStyle>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$InputFieldStyleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _InputFieldStyle &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.borderType, borderType) ||
                other.borderType == borderType) &&
            (identical(other.borderWidth, borderWidth) ||
                other.borderWidth == borderWidth) &&
            (identical(other.filled, filled) || other.filled == filled) &&
            (identical(other.fillColor, fillColor) ||
                other.fillColor == fillColor) &&
            (identical(other.contentPadding, contentPadding) ||
                other.contentPadding == contentPadding) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.enableFloatingLabel, enableFloatingLabel) ||
                other.enableFloatingLabel == enableFloatingLabel));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      borderRadius,
      borderType,
      borderWidth,
      filled,
      fillColor,
      contentPadding,
      fontSize,
      enableFloatingLabel);

  @override
  String toString() {
    return 'InputFieldStyle(borderRadius: $borderRadius, borderType: $borderType, borderWidth: $borderWidth, filled: $filled, fillColor: $fillColor, contentPadding: $contentPadding, fontSize: $fontSize, enableFloatingLabel: $enableFloatingLabel)';
  }
}

/// @nodoc
abstract mixin class _$InputFieldStyleCopyWith<$Res>
    implements $InputFieldStyleCopyWith<$Res> {
  factory _$InputFieldStyleCopyWith(
          _InputFieldStyle value, $Res Function(_InputFieldStyle) _then) =
      __$InputFieldStyleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {double borderRadius,
      String borderType,
      double borderWidth,
      bool filled,
      String? fillColor,
      double contentPadding,
      double fontSize,
      bool enableFloatingLabel});
}

/// @nodoc
class __$InputFieldStyleCopyWithImpl<$Res>
    implements _$InputFieldStyleCopyWith<$Res> {
  __$InputFieldStyleCopyWithImpl(this._self, this._then);

  final _InputFieldStyle _self;
  final $Res Function(_InputFieldStyle) _then;

  /// Create a copy of InputFieldStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? borderRadius = null,
    Object? borderType = null,
    Object? borderWidth = null,
    Object? filled = null,
    Object? fillColor = freezed,
    Object? contentPadding = null,
    Object? fontSize = null,
    Object? enableFloatingLabel = null,
  }) {
    return _then(_InputFieldStyle(
      borderRadius: null == borderRadius
          ? _self.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      borderType: null == borderType
          ? _self.borderType
          : borderType // ignore: cast_nullable_to_non_nullable
              as String,
      borderWidth: null == borderWidth
          ? _self.borderWidth
          : borderWidth // ignore: cast_nullable_to_non_nullable
              as double,
      filled: null == filled
          ? _self.filled
          : filled // ignore: cast_nullable_to_non_nullable
              as bool,
      fillColor: freezed == fillColor
          ? _self.fillColor
          : fillColor // ignore: cast_nullable_to_non_nullable
              as String?,
      contentPadding: null == contentPadding
          ? _self.contentPadding
          : contentPadding // ignore: cast_nullable_to_non_nullable
              as double,
      fontSize: null == fontSize
          ? _self.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableFloatingLabel: null == enableFloatingLabel
          ? _self.enableFloatingLabel
          : enableFloatingLabel // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$NavigationStyle {
  String get type;
  bool get floating;
  double get borderRadius;
  double get margin;
  double get elevation;
  bool get enableGradient;
  List<String> get gradientColors;
  double get opacity;
  bool get showLabels;
  double get iconSize;
  bool get enableActiveIndicator;

  /// Create a copy of NavigationStyle
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $NavigationStyleCopyWith<NavigationStyle> get copyWith =>
      _$NavigationStyleCopyWithImpl<NavigationStyle>(
          this as NavigationStyle, _$identity);

  /// Serializes this NavigationStyle to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is NavigationStyle &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.floating, floating) ||
                other.floating == floating) &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.margin, margin) || other.margin == margin) &&
            (identical(other.elevation, elevation) ||
                other.elevation == elevation) &&
            (identical(other.enableGradient, enableGradient) ||
                other.enableGradient == enableGradient) &&
            const DeepCollectionEquality()
                .equals(other.gradientColors, gradientColors) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.showLabels, showLabels) ||
                other.showLabels == showLabels) &&
            (identical(other.iconSize, iconSize) ||
                other.iconSize == iconSize) &&
            (identical(other.enableActiveIndicator, enableActiveIndicator) ||
                other.enableActiveIndicator == enableActiveIndicator));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      floating,
      borderRadius,
      margin,
      elevation,
      enableGradient,
      const DeepCollectionEquality().hash(gradientColors),
      opacity,
      showLabels,
      iconSize,
      enableActiveIndicator);

  @override
  String toString() {
    return 'NavigationStyle(type: $type, floating: $floating, borderRadius: $borderRadius, margin: $margin, elevation: $elevation, enableGradient: $enableGradient, gradientColors: $gradientColors, opacity: $opacity, showLabels: $showLabels, iconSize: $iconSize, enableActiveIndicator: $enableActiveIndicator)';
  }
}

/// @nodoc
abstract mixin class $NavigationStyleCopyWith<$Res> {
  factory $NavigationStyleCopyWith(
          NavigationStyle value, $Res Function(NavigationStyle) _then) =
      _$NavigationStyleCopyWithImpl;
  @useResult
  $Res call(
      {String type,
      bool floating,
      double borderRadius,
      double margin,
      double elevation,
      bool enableGradient,
      List<String> gradientColors,
      double opacity,
      bool showLabels,
      double iconSize,
      bool enableActiveIndicator});
}

/// @nodoc
class _$NavigationStyleCopyWithImpl<$Res>
    implements $NavigationStyleCopyWith<$Res> {
  _$NavigationStyleCopyWithImpl(this._self, this._then);

  final NavigationStyle _self;
  final $Res Function(NavigationStyle) _then;

  /// Create a copy of NavigationStyle
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? floating = null,
    Object? borderRadius = null,
    Object? margin = null,
    Object? elevation = null,
    Object? enableGradient = null,
    Object? gradientColors = null,
    Object? opacity = null,
    Object? showLabels = null,
    Object? iconSize = null,
    Object? enableActiveIndicator = null,
  }) {
    return _then(_self.copyWith(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      floating: null == floating
          ? _self.floating
          : floating // ignore: cast_nullable_to_non_nullable
              as bool,
      borderRadius: null == borderRadius
          ? _self.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      margin: null == margin
          ? _self.margin
          : margin // ignore: cast_nullable_to_non_nullable
              as double,
      elevation: null == elevation
          ? _self.elevation
          : elevation // ignore: cast_nullable_to_non_nullable
              as double,
      enableGradient: null == enableGradient
          ? _self.enableGradient
          : enableGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      gradientColors: null == gradientColors
          ? _self.gradientColors
          : gradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      opacity: null == opacity
          ? _self.opacity
          : opacity // ignore: cast_nullable_to_non_nullable
              as double,
      showLabels: null == showLabels
          ? _self.showLabels
          : showLabels // ignore: cast_nullable_to_non_nullable
              as bool,
      iconSize: null == iconSize
          ? _self.iconSize
          : iconSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableActiveIndicator: null == enableActiveIndicator
          ? _self.enableActiveIndicator
          : enableActiveIndicator // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [NavigationStyle].
extension NavigationStylePatterns on NavigationStyle {
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
    TResult Function(_NavigationStyle value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NavigationStyle() when $default != null:
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
    TResult Function(_NavigationStyle value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NavigationStyle():
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
    TResult? Function(_NavigationStyle value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NavigationStyle() when $default != null:
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
            String type,
            bool floating,
            double borderRadius,
            double margin,
            double elevation,
            bool enableGradient,
            List<String> gradientColors,
            double opacity,
            bool showLabels,
            double iconSize,
            bool enableActiveIndicator)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _NavigationStyle() when $default != null:
        return $default(
            _that.type,
            _that.floating,
            _that.borderRadius,
            _that.margin,
            _that.elevation,
            _that.enableGradient,
            _that.gradientColors,
            _that.opacity,
            _that.showLabels,
            _that.iconSize,
            _that.enableActiveIndicator);
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
            String type,
            bool floating,
            double borderRadius,
            double margin,
            double elevation,
            bool enableGradient,
            List<String> gradientColors,
            double opacity,
            bool showLabels,
            double iconSize,
            bool enableActiveIndicator)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NavigationStyle():
        return $default(
            _that.type,
            _that.floating,
            _that.borderRadius,
            _that.margin,
            _that.elevation,
            _that.enableGradient,
            _that.gradientColors,
            _that.opacity,
            _that.showLabels,
            _that.iconSize,
            _that.enableActiveIndicator);
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
            String type,
            bool floating,
            double borderRadius,
            double margin,
            double elevation,
            bool enableGradient,
            List<String> gradientColors,
            double opacity,
            bool showLabels,
            double iconSize,
            bool enableActiveIndicator)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _NavigationStyle() when $default != null:
        return $default(
            _that.type,
            _that.floating,
            _that.borderRadius,
            _that.margin,
            _that.elevation,
            _that.enableGradient,
            _that.gradientColors,
            _that.opacity,
            _that.showLabels,
            _that.iconSize,
            _that.enableActiveIndicator);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _NavigationStyle implements NavigationStyle {
  const _NavigationStyle(
      {this.type = 'bottom',
      this.floating = false,
      this.borderRadius = 30.0,
      this.margin = 8.0,
      this.elevation = 4.0,
      this.enableGradient = false,
      final List<String> gradientColors = const [],
      this.opacity = 0.9,
      this.showLabels = false,
      this.iconSize = 24.0,
      this.enableActiveIndicator = false})
      : _gradientColors = gradientColors;
  factory _NavigationStyle.fromJson(Map<String, dynamic> json) =>
      _$NavigationStyleFromJson(json);

  @override
  @JsonKey()
  final String type;
  @override
  @JsonKey()
  final bool floating;
  @override
  @JsonKey()
  final double borderRadius;
  @override
  @JsonKey()
  final double margin;
  @override
  @JsonKey()
  final double elevation;
  @override
  @JsonKey()
  final bool enableGradient;
  final List<String> _gradientColors;
  @override
  @JsonKey()
  List<String> get gradientColors {
    if (_gradientColors is EqualUnmodifiableListView) return _gradientColors;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gradientColors);
  }

  @override
  @JsonKey()
  final double opacity;
  @override
  @JsonKey()
  final bool showLabels;
  @override
  @JsonKey()
  final double iconSize;
  @override
  @JsonKey()
  final bool enableActiveIndicator;

  /// Create a copy of NavigationStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$NavigationStyleCopyWith<_NavigationStyle> get copyWith =>
      __$NavigationStyleCopyWithImpl<_NavigationStyle>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$NavigationStyleToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _NavigationStyle &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.floating, floating) ||
                other.floating == floating) &&
            (identical(other.borderRadius, borderRadius) ||
                other.borderRadius == borderRadius) &&
            (identical(other.margin, margin) || other.margin == margin) &&
            (identical(other.elevation, elevation) ||
                other.elevation == elevation) &&
            (identical(other.enableGradient, enableGradient) ||
                other.enableGradient == enableGradient) &&
            const DeepCollectionEquality()
                .equals(other._gradientColors, _gradientColors) &&
            (identical(other.opacity, opacity) || other.opacity == opacity) &&
            (identical(other.showLabels, showLabels) ||
                other.showLabels == showLabels) &&
            (identical(other.iconSize, iconSize) ||
                other.iconSize == iconSize) &&
            (identical(other.enableActiveIndicator, enableActiveIndicator) ||
                other.enableActiveIndicator == enableActiveIndicator));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      type,
      floating,
      borderRadius,
      margin,
      elevation,
      enableGradient,
      const DeepCollectionEquality().hash(_gradientColors),
      opacity,
      showLabels,
      iconSize,
      enableActiveIndicator);

  @override
  String toString() {
    return 'NavigationStyle(type: $type, floating: $floating, borderRadius: $borderRadius, margin: $margin, elevation: $elevation, enableGradient: $enableGradient, gradientColors: $gradientColors, opacity: $opacity, showLabels: $showLabels, iconSize: $iconSize, enableActiveIndicator: $enableActiveIndicator)';
  }
}

/// @nodoc
abstract mixin class _$NavigationStyleCopyWith<$Res>
    implements $NavigationStyleCopyWith<$Res> {
  factory _$NavigationStyleCopyWith(
          _NavigationStyle value, $Res Function(_NavigationStyle) _then) =
      __$NavigationStyleCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String type,
      bool floating,
      double borderRadius,
      double margin,
      double elevation,
      bool enableGradient,
      List<String> gradientColors,
      double opacity,
      bool showLabels,
      double iconSize,
      bool enableActiveIndicator});
}

/// @nodoc
class __$NavigationStyleCopyWithImpl<$Res>
    implements _$NavigationStyleCopyWith<$Res> {
  __$NavigationStyleCopyWithImpl(this._self, this._then);

  final _NavigationStyle _self;
  final $Res Function(_NavigationStyle) _then;

  /// Create a copy of NavigationStyle
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? type = null,
    Object? floating = null,
    Object? borderRadius = null,
    Object? margin = null,
    Object? elevation = null,
    Object? enableGradient = null,
    Object? gradientColors = null,
    Object? opacity = null,
    Object? showLabels = null,
    Object? iconSize = null,
    Object? enableActiveIndicator = null,
  }) {
    return _then(_NavigationStyle(
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      floating: null == floating
          ? _self.floating
          : floating // ignore: cast_nullable_to_non_nullable
              as bool,
      borderRadius: null == borderRadius
          ? _self.borderRadius
          : borderRadius // ignore: cast_nullable_to_non_nullable
              as double,
      margin: null == margin
          ? _self.margin
          : margin // ignore: cast_nullable_to_non_nullable
              as double,
      elevation: null == elevation
          ? _self.elevation
          : elevation // ignore: cast_nullable_to_non_nullable
              as double,
      enableGradient: null == enableGradient
          ? _self.enableGradient
          : enableGradient // ignore: cast_nullable_to_non_nullable
              as bool,
      gradientColors: null == gradientColors
          ? _self._gradientColors
          : gradientColors // ignore: cast_nullable_to_non_nullable
              as List<String>,
      opacity: null == opacity
          ? _self.opacity
          : opacity // ignore: cast_nullable_to_non_nullable
              as double,
      showLabels: null == showLabels
          ? _self.showLabels
          : showLabels // ignore: cast_nullable_to_non_nullable
              as bool,
      iconSize: null == iconSize
          ? _self.iconSize
          : iconSize // ignore: cast_nullable_to_non_nullable
              as double,
      enableActiveIndicator: null == enableActiveIndicator
          ? _self.enableActiveIndicator
          : enableActiveIndicator // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
mixin _$LayoutPreferences {
  String get density;
  double get defaultSpacing;
  double get defaultPadding;
  bool get useCompactPosts;
  bool get useListLayout;
  int get gridColumns;
  bool get centerContent;
  double get maxContentWidth;
  bool get showFloatingButtons;
  String get floatingButtonPosition;

  /// Create a copy of LayoutPreferences
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $LayoutPreferencesCopyWith<LayoutPreferences> get copyWith =>
      _$LayoutPreferencesCopyWithImpl<LayoutPreferences>(
          this as LayoutPreferences, _$identity);

  /// Serializes this LayoutPreferences to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is LayoutPreferences &&
            (identical(other.density, density) || other.density == density) &&
            (identical(other.defaultSpacing, defaultSpacing) ||
                other.defaultSpacing == defaultSpacing) &&
            (identical(other.defaultPadding, defaultPadding) ||
                other.defaultPadding == defaultPadding) &&
            (identical(other.useCompactPosts, useCompactPosts) ||
                other.useCompactPosts == useCompactPosts) &&
            (identical(other.useListLayout, useListLayout) ||
                other.useListLayout == useListLayout) &&
            (identical(other.gridColumns, gridColumns) ||
                other.gridColumns == gridColumns) &&
            (identical(other.centerContent, centerContent) ||
                other.centerContent == centerContent) &&
            (identical(other.maxContentWidth, maxContentWidth) ||
                other.maxContentWidth == maxContentWidth) &&
            (identical(other.showFloatingButtons, showFloatingButtons) ||
                other.showFloatingButtons == showFloatingButtons) &&
            (identical(other.floatingButtonPosition, floatingButtonPosition) ||
                other.floatingButtonPosition == floatingButtonPosition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      density,
      defaultSpacing,
      defaultPadding,
      useCompactPosts,
      useListLayout,
      gridColumns,
      centerContent,
      maxContentWidth,
      showFloatingButtons,
      floatingButtonPosition);

  @override
  String toString() {
    return 'LayoutPreferences(density: $density, defaultSpacing: $defaultSpacing, defaultPadding: $defaultPadding, useCompactPosts: $useCompactPosts, useListLayout: $useListLayout, gridColumns: $gridColumns, centerContent: $centerContent, maxContentWidth: $maxContentWidth, showFloatingButtons: $showFloatingButtons, floatingButtonPosition: $floatingButtonPosition)';
  }
}

/// @nodoc
abstract mixin class $LayoutPreferencesCopyWith<$Res> {
  factory $LayoutPreferencesCopyWith(
          LayoutPreferences value, $Res Function(LayoutPreferences) _then) =
      _$LayoutPreferencesCopyWithImpl;
  @useResult
  $Res call(
      {String density,
      double defaultSpacing,
      double defaultPadding,
      bool useCompactPosts,
      bool useListLayout,
      int gridColumns,
      bool centerContent,
      double maxContentWidth,
      bool showFloatingButtons,
      String floatingButtonPosition});
}

/// @nodoc
class _$LayoutPreferencesCopyWithImpl<$Res>
    implements $LayoutPreferencesCopyWith<$Res> {
  _$LayoutPreferencesCopyWithImpl(this._self, this._then);

  final LayoutPreferences _self;
  final $Res Function(LayoutPreferences) _then;

  /// Create a copy of LayoutPreferences
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? density = null,
    Object? defaultSpacing = null,
    Object? defaultPadding = null,
    Object? useCompactPosts = null,
    Object? useListLayout = null,
    Object? gridColumns = null,
    Object? centerContent = null,
    Object? maxContentWidth = null,
    Object? showFloatingButtons = null,
    Object? floatingButtonPosition = null,
  }) {
    return _then(_self.copyWith(
      density: null == density
          ? _self.density
          : density // ignore: cast_nullable_to_non_nullable
              as String,
      defaultSpacing: null == defaultSpacing
          ? _self.defaultSpacing
          : defaultSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      defaultPadding: null == defaultPadding
          ? _self.defaultPadding
          : defaultPadding // ignore: cast_nullable_to_non_nullable
              as double,
      useCompactPosts: null == useCompactPosts
          ? _self.useCompactPosts
          : useCompactPosts // ignore: cast_nullable_to_non_nullable
              as bool,
      useListLayout: null == useListLayout
          ? _self.useListLayout
          : useListLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      gridColumns: null == gridColumns
          ? _self.gridColumns
          : gridColumns // ignore: cast_nullable_to_non_nullable
              as int,
      centerContent: null == centerContent
          ? _self.centerContent
          : centerContent // ignore: cast_nullable_to_non_nullable
              as bool,
      maxContentWidth: null == maxContentWidth
          ? _self.maxContentWidth
          : maxContentWidth // ignore: cast_nullable_to_non_nullable
              as double,
      showFloatingButtons: null == showFloatingButtons
          ? _self.showFloatingButtons
          : showFloatingButtons // ignore: cast_nullable_to_non_nullable
              as bool,
      floatingButtonPosition: null == floatingButtonPosition
          ? _self.floatingButtonPosition
          : floatingButtonPosition // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [LayoutPreferences].
extension LayoutPreferencesPatterns on LayoutPreferences {
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
    TResult Function(_LayoutPreferences value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LayoutPreferences() when $default != null:
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
    TResult Function(_LayoutPreferences value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutPreferences():
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
    TResult? Function(_LayoutPreferences value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutPreferences() when $default != null:
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
            String density,
            double defaultSpacing,
            double defaultPadding,
            bool useCompactPosts,
            bool useListLayout,
            int gridColumns,
            bool centerContent,
            double maxContentWidth,
            bool showFloatingButtons,
            String floatingButtonPosition)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _LayoutPreferences() when $default != null:
        return $default(
            _that.density,
            _that.defaultSpacing,
            _that.defaultPadding,
            _that.useCompactPosts,
            _that.useListLayout,
            _that.gridColumns,
            _that.centerContent,
            _that.maxContentWidth,
            _that.showFloatingButtons,
            _that.floatingButtonPosition);
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
            String density,
            double defaultSpacing,
            double defaultPadding,
            bool useCompactPosts,
            bool useListLayout,
            int gridColumns,
            bool centerContent,
            double maxContentWidth,
            bool showFloatingButtons,
            String floatingButtonPosition)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutPreferences():
        return $default(
            _that.density,
            _that.defaultSpacing,
            _that.defaultPadding,
            _that.useCompactPosts,
            _that.useListLayout,
            _that.gridColumns,
            _that.centerContent,
            _that.maxContentWidth,
            _that.showFloatingButtons,
            _that.floatingButtonPosition);
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
            String density,
            double defaultSpacing,
            double defaultPadding,
            bool useCompactPosts,
            bool useListLayout,
            int gridColumns,
            bool centerContent,
            double maxContentWidth,
            bool showFloatingButtons,
            String floatingButtonPosition)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _LayoutPreferences() when $default != null:
        return $default(
            _that.density,
            _that.defaultSpacing,
            _that.defaultPadding,
            _that.useCompactPosts,
            _that.useListLayout,
            _that.gridColumns,
            _that.centerContent,
            _that.maxContentWidth,
            _that.showFloatingButtons,
            _that.floatingButtonPosition);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _LayoutPreferences implements LayoutPreferences {
  const _LayoutPreferences(
      {this.density = 'comfortable',
      this.defaultSpacing = 8.0,
      this.defaultPadding = 16.0,
      this.useCompactPosts = false,
      this.useListLayout = false,
      this.gridColumns = 2,
      this.centerContent = false,
      this.maxContentWidth = 1200.0,
      this.showFloatingButtons = true,
      this.floatingButtonPosition = 'bottomRight'});
  factory _LayoutPreferences.fromJson(Map<String, dynamic> json) =>
      _$LayoutPreferencesFromJson(json);

  @override
  @JsonKey()
  final String density;
  @override
  @JsonKey()
  final double defaultSpacing;
  @override
  @JsonKey()
  final double defaultPadding;
  @override
  @JsonKey()
  final bool useCompactPosts;
  @override
  @JsonKey()
  final bool useListLayout;
  @override
  @JsonKey()
  final int gridColumns;
  @override
  @JsonKey()
  final bool centerContent;
  @override
  @JsonKey()
  final double maxContentWidth;
  @override
  @JsonKey()
  final bool showFloatingButtons;
  @override
  @JsonKey()
  final String floatingButtonPosition;

  /// Create a copy of LayoutPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$LayoutPreferencesCopyWith<_LayoutPreferences> get copyWith =>
      __$LayoutPreferencesCopyWithImpl<_LayoutPreferences>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$LayoutPreferencesToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _LayoutPreferences &&
            (identical(other.density, density) || other.density == density) &&
            (identical(other.defaultSpacing, defaultSpacing) ||
                other.defaultSpacing == defaultSpacing) &&
            (identical(other.defaultPadding, defaultPadding) ||
                other.defaultPadding == defaultPadding) &&
            (identical(other.useCompactPosts, useCompactPosts) ||
                other.useCompactPosts == useCompactPosts) &&
            (identical(other.useListLayout, useListLayout) ||
                other.useListLayout == useListLayout) &&
            (identical(other.gridColumns, gridColumns) ||
                other.gridColumns == gridColumns) &&
            (identical(other.centerContent, centerContent) ||
                other.centerContent == centerContent) &&
            (identical(other.maxContentWidth, maxContentWidth) ||
                other.maxContentWidth == maxContentWidth) &&
            (identical(other.showFloatingButtons, showFloatingButtons) ||
                other.showFloatingButtons == showFloatingButtons) &&
            (identical(other.floatingButtonPosition, floatingButtonPosition) ||
                other.floatingButtonPosition == floatingButtonPosition));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      density,
      defaultSpacing,
      defaultPadding,
      useCompactPosts,
      useListLayout,
      gridColumns,
      centerContent,
      maxContentWidth,
      showFloatingButtons,
      floatingButtonPosition);

  @override
  String toString() {
    return 'LayoutPreferences(density: $density, defaultSpacing: $defaultSpacing, defaultPadding: $defaultPadding, useCompactPosts: $useCompactPosts, useListLayout: $useListLayout, gridColumns: $gridColumns, centerContent: $centerContent, maxContentWidth: $maxContentWidth, showFloatingButtons: $showFloatingButtons, floatingButtonPosition: $floatingButtonPosition)';
  }
}

/// @nodoc
abstract mixin class _$LayoutPreferencesCopyWith<$Res>
    implements $LayoutPreferencesCopyWith<$Res> {
  factory _$LayoutPreferencesCopyWith(
          _LayoutPreferences value, $Res Function(_LayoutPreferences) _then) =
      __$LayoutPreferencesCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String density,
      double defaultSpacing,
      double defaultPadding,
      bool useCompactPosts,
      bool useListLayout,
      int gridColumns,
      bool centerContent,
      double maxContentWidth,
      bool showFloatingButtons,
      String floatingButtonPosition});
}

/// @nodoc
class __$LayoutPreferencesCopyWithImpl<$Res>
    implements _$LayoutPreferencesCopyWith<$Res> {
  __$LayoutPreferencesCopyWithImpl(this._self, this._then);

  final _LayoutPreferences _self;
  final $Res Function(_LayoutPreferences) _then;

  /// Create a copy of LayoutPreferences
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? density = null,
    Object? defaultSpacing = null,
    Object? defaultPadding = null,
    Object? useCompactPosts = null,
    Object? useListLayout = null,
    Object? gridColumns = null,
    Object? centerContent = null,
    Object? maxContentWidth = null,
    Object? showFloatingButtons = null,
    Object? floatingButtonPosition = null,
  }) {
    return _then(_LayoutPreferences(
      density: null == density
          ? _self.density
          : density // ignore: cast_nullable_to_non_nullable
              as String,
      defaultSpacing: null == defaultSpacing
          ? _self.defaultSpacing
          : defaultSpacing // ignore: cast_nullable_to_non_nullable
              as double,
      defaultPadding: null == defaultPadding
          ? _self.defaultPadding
          : defaultPadding // ignore: cast_nullable_to_non_nullable
              as double,
      useCompactPosts: null == useCompactPosts
          ? _self.useCompactPosts
          : useCompactPosts // ignore: cast_nullable_to_non_nullable
              as bool,
      useListLayout: null == useListLayout
          ? _self.useListLayout
          : useListLayout // ignore: cast_nullable_to_non_nullable
              as bool,
      gridColumns: null == gridColumns
          ? _self.gridColumns
          : gridColumns // ignore: cast_nullable_to_non_nullable
              as int,
      centerContent: null == centerContent
          ? _self.centerContent
          : centerContent // ignore: cast_nullable_to_non_nullable
              as bool,
      maxContentWidth: null == maxContentWidth
          ? _self.maxContentWidth
          : maxContentWidth // ignore: cast_nullable_to_non_nullable
              as double,
      showFloatingButtons: null == showFloatingButtons
          ? _self.showFloatingButtons
          : showFloatingButtons // ignore: cast_nullable_to_non_nullable
              as bool,
      floatingButtonPosition: null == floatingButtonPosition
          ? _self.floatingButtonPosition
          : floatingButtonPosition // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$AnimationSettings {
  bool get enableAnimations;
  String get speed;
  bool get enablePageTransitions;
  String get pageTransitionType;
  bool get enableHoverEffects;
  bool get enableScrollAnimations;
  bool get enableParallaxEffects;
  bool get enableLoadingAnimations;
  String get defaultCurve;

  /// Create a copy of AnimationSettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $AnimationSettingsCopyWith<AnimationSettings> get copyWith =>
      _$AnimationSettingsCopyWithImpl<AnimationSettings>(
          this as AnimationSettings, _$identity);

  /// Serializes this AnimationSettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AnimationSettings &&
            (identical(other.enableAnimations, enableAnimations) ||
                other.enableAnimations == enableAnimations) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.enablePageTransitions, enablePageTransitions) ||
                other.enablePageTransitions == enablePageTransitions) &&
            (identical(other.pageTransitionType, pageTransitionType) ||
                other.pageTransitionType == pageTransitionType) &&
            (identical(other.enableHoverEffects, enableHoverEffects) ||
                other.enableHoverEffects == enableHoverEffects) &&
            (identical(other.enableScrollAnimations, enableScrollAnimations) ||
                other.enableScrollAnimations == enableScrollAnimations) &&
            (identical(other.enableParallaxEffects, enableParallaxEffects) ||
                other.enableParallaxEffects == enableParallaxEffects) &&
            (identical(
                    other.enableLoadingAnimations, enableLoadingAnimations) ||
                other.enableLoadingAnimations == enableLoadingAnimations) &&
            (identical(other.defaultCurve, defaultCurve) ||
                other.defaultCurve == defaultCurve));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enableAnimations,
      speed,
      enablePageTransitions,
      pageTransitionType,
      enableHoverEffects,
      enableScrollAnimations,
      enableParallaxEffects,
      enableLoadingAnimations,
      defaultCurve);

  @override
  String toString() {
    return 'AnimationSettings(enableAnimations: $enableAnimations, speed: $speed, enablePageTransitions: $enablePageTransitions, pageTransitionType: $pageTransitionType, enableHoverEffects: $enableHoverEffects, enableScrollAnimations: $enableScrollAnimations, enableParallaxEffects: $enableParallaxEffects, enableLoadingAnimations: $enableLoadingAnimations, defaultCurve: $defaultCurve)';
  }
}

/// @nodoc
abstract mixin class $AnimationSettingsCopyWith<$Res> {
  factory $AnimationSettingsCopyWith(
          AnimationSettings value, $Res Function(AnimationSettings) _then) =
      _$AnimationSettingsCopyWithImpl;
  @useResult
  $Res call(
      {bool enableAnimations,
      String speed,
      bool enablePageTransitions,
      String pageTransitionType,
      bool enableHoverEffects,
      bool enableScrollAnimations,
      bool enableParallaxEffects,
      bool enableLoadingAnimations,
      String defaultCurve});
}

/// @nodoc
class _$AnimationSettingsCopyWithImpl<$Res>
    implements $AnimationSettingsCopyWith<$Res> {
  _$AnimationSettingsCopyWithImpl(this._self, this._then);

  final AnimationSettings _self;
  final $Res Function(AnimationSettings) _then;

  /// Create a copy of AnimationSettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? enableAnimations = null,
    Object? speed = null,
    Object? enablePageTransitions = null,
    Object? pageTransitionType = null,
    Object? enableHoverEffects = null,
    Object? enableScrollAnimations = null,
    Object? enableParallaxEffects = null,
    Object? enableLoadingAnimations = null,
    Object? defaultCurve = null,
  }) {
    return _then(_self.copyWith(
      enableAnimations: null == enableAnimations
          ? _self.enableAnimations
          : enableAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      speed: null == speed
          ? _self.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as String,
      enablePageTransitions: null == enablePageTransitions
          ? _self.enablePageTransitions
          : enablePageTransitions // ignore: cast_nullable_to_non_nullable
              as bool,
      pageTransitionType: null == pageTransitionType
          ? _self.pageTransitionType
          : pageTransitionType // ignore: cast_nullable_to_non_nullable
              as String,
      enableHoverEffects: null == enableHoverEffects
          ? _self.enableHoverEffects
          : enableHoverEffects // ignore: cast_nullable_to_non_nullable
              as bool,
      enableScrollAnimations: null == enableScrollAnimations
          ? _self.enableScrollAnimations
          : enableScrollAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      enableParallaxEffects: null == enableParallaxEffects
          ? _self.enableParallaxEffects
          : enableParallaxEffects // ignore: cast_nullable_to_non_nullable
              as bool,
      enableLoadingAnimations: null == enableLoadingAnimations
          ? _self.enableLoadingAnimations
          : enableLoadingAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultCurve: null == defaultCurve
          ? _self.defaultCurve
          : defaultCurve // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// Adds pattern-matching-related methods to [AnimationSettings].
extension AnimationSettingsPatterns on AnimationSettings {
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
    TResult Function(_AnimationSettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnimationSettings() when $default != null:
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
    TResult Function(_AnimationSettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnimationSettings():
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
    TResult? Function(_AnimationSettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnimationSettings() when $default != null:
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
            bool enableAnimations,
            String speed,
            bool enablePageTransitions,
            String pageTransitionType,
            bool enableHoverEffects,
            bool enableScrollAnimations,
            bool enableParallaxEffects,
            bool enableLoadingAnimations,
            String defaultCurve)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _AnimationSettings() when $default != null:
        return $default(
            _that.enableAnimations,
            _that.speed,
            _that.enablePageTransitions,
            _that.pageTransitionType,
            _that.enableHoverEffects,
            _that.enableScrollAnimations,
            _that.enableParallaxEffects,
            _that.enableLoadingAnimations,
            _that.defaultCurve);
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
            bool enableAnimations,
            String speed,
            bool enablePageTransitions,
            String pageTransitionType,
            bool enableHoverEffects,
            bool enableScrollAnimations,
            bool enableParallaxEffects,
            bool enableLoadingAnimations,
            String defaultCurve)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnimationSettings():
        return $default(
            _that.enableAnimations,
            _that.speed,
            _that.enablePageTransitions,
            _that.pageTransitionType,
            _that.enableHoverEffects,
            _that.enableScrollAnimations,
            _that.enableParallaxEffects,
            _that.enableLoadingAnimations,
            _that.defaultCurve);
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
            bool enableAnimations,
            String speed,
            bool enablePageTransitions,
            String pageTransitionType,
            bool enableHoverEffects,
            bool enableScrollAnimations,
            bool enableParallaxEffects,
            bool enableLoadingAnimations,
            String defaultCurve)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _AnimationSettings() when $default != null:
        return $default(
            _that.enableAnimations,
            _that.speed,
            _that.enablePageTransitions,
            _that.pageTransitionType,
            _that.enableHoverEffects,
            _that.enableScrollAnimations,
            _that.enableParallaxEffects,
            _that.enableLoadingAnimations,
            _that.defaultCurve);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _AnimationSettings implements AnimationSettings {
  const _AnimationSettings(
      {this.enableAnimations = true,
      this.speed = 'normal',
      this.enablePageTransitions = true,
      this.pageTransitionType = 'fade',
      this.enableHoverEffects = true,
      this.enableScrollAnimations = true,
      this.enableParallaxEffects = false,
      this.enableLoadingAnimations = true,
      this.defaultCurve = 'easeInOut'});
  factory _AnimationSettings.fromJson(Map<String, dynamic> json) =>
      _$AnimationSettingsFromJson(json);

  @override
  @JsonKey()
  final bool enableAnimations;
  @override
  @JsonKey()
  final String speed;
  @override
  @JsonKey()
  final bool enablePageTransitions;
  @override
  @JsonKey()
  final String pageTransitionType;
  @override
  @JsonKey()
  final bool enableHoverEffects;
  @override
  @JsonKey()
  final bool enableScrollAnimations;
  @override
  @JsonKey()
  final bool enableParallaxEffects;
  @override
  @JsonKey()
  final bool enableLoadingAnimations;
  @override
  @JsonKey()
  final String defaultCurve;

  /// Create a copy of AnimationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$AnimationSettingsCopyWith<_AnimationSettings> get copyWith =>
      __$AnimationSettingsCopyWithImpl<_AnimationSettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$AnimationSettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _AnimationSettings &&
            (identical(other.enableAnimations, enableAnimations) ||
                other.enableAnimations == enableAnimations) &&
            (identical(other.speed, speed) || other.speed == speed) &&
            (identical(other.enablePageTransitions, enablePageTransitions) ||
                other.enablePageTransitions == enablePageTransitions) &&
            (identical(other.pageTransitionType, pageTransitionType) ||
                other.pageTransitionType == pageTransitionType) &&
            (identical(other.enableHoverEffects, enableHoverEffects) ||
                other.enableHoverEffects == enableHoverEffects) &&
            (identical(other.enableScrollAnimations, enableScrollAnimations) ||
                other.enableScrollAnimations == enableScrollAnimations) &&
            (identical(other.enableParallaxEffects, enableParallaxEffects) ||
                other.enableParallaxEffects == enableParallaxEffects) &&
            (identical(
                    other.enableLoadingAnimations, enableLoadingAnimations) ||
                other.enableLoadingAnimations == enableLoadingAnimations) &&
            (identical(other.defaultCurve, defaultCurve) ||
                other.defaultCurve == defaultCurve));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      enableAnimations,
      speed,
      enablePageTransitions,
      pageTransitionType,
      enableHoverEffects,
      enableScrollAnimations,
      enableParallaxEffects,
      enableLoadingAnimations,
      defaultCurve);

  @override
  String toString() {
    return 'AnimationSettings(enableAnimations: $enableAnimations, speed: $speed, enablePageTransitions: $enablePageTransitions, pageTransitionType: $pageTransitionType, enableHoverEffects: $enableHoverEffects, enableScrollAnimations: $enableScrollAnimations, enableParallaxEffects: $enableParallaxEffects, enableLoadingAnimations: $enableLoadingAnimations, defaultCurve: $defaultCurve)';
  }
}

/// @nodoc
abstract mixin class _$AnimationSettingsCopyWith<$Res>
    implements $AnimationSettingsCopyWith<$Res> {
  factory _$AnimationSettingsCopyWith(
          _AnimationSettings value, $Res Function(_AnimationSettings) _then) =
      __$AnimationSettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {bool enableAnimations,
      String speed,
      bool enablePageTransitions,
      String pageTransitionType,
      bool enableHoverEffects,
      bool enableScrollAnimations,
      bool enableParallaxEffects,
      bool enableLoadingAnimations,
      String defaultCurve});
}

/// @nodoc
class __$AnimationSettingsCopyWithImpl<$Res>
    implements _$AnimationSettingsCopyWith<$Res> {
  __$AnimationSettingsCopyWithImpl(this._self, this._then);

  final _AnimationSettings _self;
  final $Res Function(_AnimationSettings) _then;

  /// Create a copy of AnimationSettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? enableAnimations = null,
    Object? speed = null,
    Object? enablePageTransitions = null,
    Object? pageTransitionType = null,
    Object? enableHoverEffects = null,
    Object? enableScrollAnimations = null,
    Object? enableParallaxEffects = null,
    Object? enableLoadingAnimations = null,
    Object? defaultCurve = null,
  }) {
    return _then(_AnimationSettings(
      enableAnimations: null == enableAnimations
          ? _self.enableAnimations
          : enableAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      speed: null == speed
          ? _self.speed
          : speed // ignore: cast_nullable_to_non_nullable
              as String,
      enablePageTransitions: null == enablePageTransitions
          ? _self.enablePageTransitions
          : enablePageTransitions // ignore: cast_nullable_to_non_nullable
              as bool,
      pageTransitionType: null == pageTransitionType
          ? _self.pageTransitionType
          : pageTransitionType // ignore: cast_nullable_to_non_nullable
              as String,
      enableHoverEffects: null == enableHoverEffects
          ? _self.enableHoverEffects
          : enableHoverEffects // ignore: cast_nullable_to_non_nullable
              as bool,
      enableScrollAnimations: null == enableScrollAnimations
          ? _self.enableScrollAnimations
          : enableScrollAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      enableParallaxEffects: null == enableParallaxEffects
          ? _self.enableParallaxEffects
          : enableParallaxEffects // ignore: cast_nullable_to_non_nullable
              as bool,
      enableLoadingAnimations: null == enableLoadingAnimations
          ? _self.enableLoadingAnimations
          : enableLoadingAnimations // ignore: cast_nullable_to_non_nullable
              as bool,
      defaultCurve: null == defaultCurve
          ? _self.defaultCurve
          : defaultCurve // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
mixin _$TypographySettings {
  String get primaryFont;
  String get secondaryFont;
  double get fontScaleFactor;
  bool get useCustomFonts;
  Map<String, String> get customFontUrls;
  String get renderingStyle;
  double get lineHeightMultiplier;
  double get letterSpacing;

  /// Create a copy of TypographySettings
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $TypographySettingsCopyWith<TypographySettings> get copyWith =>
      _$TypographySettingsCopyWithImpl<TypographySettings>(
          this as TypographySettings, _$identity);

  /// Serializes this TypographySettings to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is TypographySettings &&
            (identical(other.primaryFont, primaryFont) ||
                other.primaryFont == primaryFont) &&
            (identical(other.secondaryFont, secondaryFont) ||
                other.secondaryFont == secondaryFont) &&
            (identical(other.fontScaleFactor, fontScaleFactor) ||
                other.fontScaleFactor == fontScaleFactor) &&
            (identical(other.useCustomFonts, useCustomFonts) ||
                other.useCustomFonts == useCustomFonts) &&
            const DeepCollectionEquality()
                .equals(other.customFontUrls, customFontUrls) &&
            (identical(other.renderingStyle, renderingStyle) ||
                other.renderingStyle == renderingStyle) &&
            (identical(other.lineHeightMultiplier, lineHeightMultiplier) ||
                other.lineHeightMultiplier == lineHeightMultiplier) &&
            (identical(other.letterSpacing, letterSpacing) ||
                other.letterSpacing == letterSpacing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryFont,
      secondaryFont,
      fontScaleFactor,
      useCustomFonts,
      const DeepCollectionEquality().hash(customFontUrls),
      renderingStyle,
      lineHeightMultiplier,
      letterSpacing);

  @override
  String toString() {
    return 'TypographySettings(primaryFont: $primaryFont, secondaryFont: $secondaryFont, fontScaleFactor: $fontScaleFactor, useCustomFonts: $useCustomFonts, customFontUrls: $customFontUrls, renderingStyle: $renderingStyle, lineHeightMultiplier: $lineHeightMultiplier, letterSpacing: $letterSpacing)';
  }
}

/// @nodoc
abstract mixin class $TypographySettingsCopyWith<$Res> {
  factory $TypographySettingsCopyWith(
          TypographySettings value, $Res Function(TypographySettings) _then) =
      _$TypographySettingsCopyWithImpl;
  @useResult
  $Res call(
      {String primaryFont,
      String secondaryFont,
      double fontScaleFactor,
      bool useCustomFonts,
      Map<String, String> customFontUrls,
      String renderingStyle,
      double lineHeightMultiplier,
      double letterSpacing});
}

/// @nodoc
class _$TypographySettingsCopyWithImpl<$Res>
    implements $TypographySettingsCopyWith<$Res> {
  _$TypographySettingsCopyWithImpl(this._self, this._then);

  final TypographySettings _self;
  final $Res Function(TypographySettings) _then;

  /// Create a copy of TypographySettings
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? primaryFont = null,
    Object? secondaryFont = null,
    Object? fontScaleFactor = null,
    Object? useCustomFonts = null,
    Object? customFontUrls = null,
    Object? renderingStyle = null,
    Object? lineHeightMultiplier = null,
    Object? letterSpacing = null,
  }) {
    return _then(_self.copyWith(
      primaryFont: null == primaryFont
          ? _self.primaryFont
          : primaryFont // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryFont: null == secondaryFont
          ? _self.secondaryFont
          : secondaryFont // ignore: cast_nullable_to_non_nullable
              as String,
      fontScaleFactor: null == fontScaleFactor
          ? _self.fontScaleFactor
          : fontScaleFactor // ignore: cast_nullable_to_non_nullable
              as double,
      useCustomFonts: null == useCustomFonts
          ? _self.useCustomFonts
          : useCustomFonts // ignore: cast_nullable_to_non_nullable
              as bool,
      customFontUrls: null == customFontUrls
          ? _self.customFontUrls
          : customFontUrls // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      renderingStyle: null == renderingStyle
          ? _self.renderingStyle
          : renderingStyle // ignore: cast_nullable_to_non_nullable
              as String,
      lineHeightMultiplier: null == lineHeightMultiplier
          ? _self.lineHeightMultiplier
          : lineHeightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      letterSpacing: null == letterSpacing
          ? _self.letterSpacing
          : letterSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// Adds pattern-matching-related methods to [TypographySettings].
extension TypographySettingsPatterns on TypographySettings {
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
    TResult Function(_TypographySettings value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TypographySettings() when $default != null:
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
    TResult Function(_TypographySettings value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypographySettings():
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
    TResult? Function(_TypographySettings value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypographySettings() when $default != null:
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
            String primaryFont,
            String secondaryFont,
            double fontScaleFactor,
            bool useCustomFonts,
            Map<String, String> customFontUrls,
            String renderingStyle,
            double lineHeightMultiplier,
            double letterSpacing)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _TypographySettings() when $default != null:
        return $default(
            _that.primaryFont,
            _that.secondaryFont,
            _that.fontScaleFactor,
            _that.useCustomFonts,
            _that.customFontUrls,
            _that.renderingStyle,
            _that.lineHeightMultiplier,
            _that.letterSpacing);
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
            String primaryFont,
            String secondaryFont,
            double fontScaleFactor,
            bool useCustomFonts,
            Map<String, String> customFontUrls,
            String renderingStyle,
            double lineHeightMultiplier,
            double letterSpacing)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypographySettings():
        return $default(
            _that.primaryFont,
            _that.secondaryFont,
            _that.fontScaleFactor,
            _that.useCustomFonts,
            _that.customFontUrls,
            _that.renderingStyle,
            _that.lineHeightMultiplier,
            _that.letterSpacing);
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
            String primaryFont,
            String secondaryFont,
            double fontScaleFactor,
            bool useCustomFonts,
            Map<String, String> customFontUrls,
            String renderingStyle,
            double lineHeightMultiplier,
            double letterSpacing)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _TypographySettings() when $default != null:
        return $default(
            _that.primaryFont,
            _that.secondaryFont,
            _that.fontScaleFactor,
            _that.useCustomFonts,
            _that.customFontUrls,
            _that.renderingStyle,
            _that.lineHeightMultiplier,
            _that.letterSpacing);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _TypographySettings implements TypographySettings {
  const _TypographySettings(
      {this.primaryFont = 'Roboto',
      this.secondaryFont = 'Roboto',
      this.fontScaleFactor = 1.0,
      this.useCustomFonts = false,
      final Map<String, String> customFontUrls = const {},
      this.renderingStyle = 'optimal',
      this.lineHeightMultiplier = 1.5,
      this.letterSpacing = 0.0})
      : _customFontUrls = customFontUrls;
  factory _TypographySettings.fromJson(Map<String, dynamic> json) =>
      _$TypographySettingsFromJson(json);

  @override
  @JsonKey()
  final String primaryFont;
  @override
  @JsonKey()
  final String secondaryFont;
  @override
  @JsonKey()
  final double fontScaleFactor;
  @override
  @JsonKey()
  final bool useCustomFonts;
  final Map<String, String> _customFontUrls;
  @override
  @JsonKey()
  Map<String, String> get customFontUrls {
    if (_customFontUrls is EqualUnmodifiableMapView) return _customFontUrls;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_customFontUrls);
  }

  @override
  @JsonKey()
  final String renderingStyle;
  @override
  @JsonKey()
  final double lineHeightMultiplier;
  @override
  @JsonKey()
  final double letterSpacing;

  /// Create a copy of TypographySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$TypographySettingsCopyWith<_TypographySettings> get copyWith =>
      __$TypographySettingsCopyWithImpl<_TypographySettings>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$TypographySettingsToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _TypographySettings &&
            (identical(other.primaryFont, primaryFont) ||
                other.primaryFont == primaryFont) &&
            (identical(other.secondaryFont, secondaryFont) ||
                other.secondaryFont == secondaryFont) &&
            (identical(other.fontScaleFactor, fontScaleFactor) ||
                other.fontScaleFactor == fontScaleFactor) &&
            (identical(other.useCustomFonts, useCustomFonts) ||
                other.useCustomFonts == useCustomFonts) &&
            const DeepCollectionEquality()
                .equals(other._customFontUrls, _customFontUrls) &&
            (identical(other.renderingStyle, renderingStyle) ||
                other.renderingStyle == renderingStyle) &&
            (identical(other.lineHeightMultiplier, lineHeightMultiplier) ||
                other.lineHeightMultiplier == lineHeightMultiplier) &&
            (identical(other.letterSpacing, letterSpacing) ||
                other.letterSpacing == letterSpacing));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      primaryFont,
      secondaryFont,
      fontScaleFactor,
      useCustomFonts,
      const DeepCollectionEquality().hash(_customFontUrls),
      renderingStyle,
      lineHeightMultiplier,
      letterSpacing);

  @override
  String toString() {
    return 'TypographySettings(primaryFont: $primaryFont, secondaryFont: $secondaryFont, fontScaleFactor: $fontScaleFactor, useCustomFonts: $useCustomFonts, customFontUrls: $customFontUrls, renderingStyle: $renderingStyle, lineHeightMultiplier: $lineHeightMultiplier, letterSpacing: $letterSpacing)';
  }
}

/// @nodoc
abstract mixin class _$TypographySettingsCopyWith<$Res>
    implements $TypographySettingsCopyWith<$Res> {
  factory _$TypographySettingsCopyWith(
          _TypographySettings value, $Res Function(_TypographySettings) _then) =
      __$TypographySettingsCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String primaryFont,
      String secondaryFont,
      double fontScaleFactor,
      bool useCustomFonts,
      Map<String, String> customFontUrls,
      String renderingStyle,
      double lineHeightMultiplier,
      double letterSpacing});
}

/// @nodoc
class __$TypographySettingsCopyWithImpl<$Res>
    implements _$TypographySettingsCopyWith<$Res> {
  __$TypographySettingsCopyWithImpl(this._self, this._then);

  final _TypographySettings _self;
  final $Res Function(_TypographySettings) _then;

  /// Create a copy of TypographySettings
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? primaryFont = null,
    Object? secondaryFont = null,
    Object? fontScaleFactor = null,
    Object? useCustomFonts = null,
    Object? customFontUrls = null,
    Object? renderingStyle = null,
    Object? lineHeightMultiplier = null,
    Object? letterSpacing = null,
  }) {
    return _then(_TypographySettings(
      primaryFont: null == primaryFont
          ? _self.primaryFont
          : primaryFont // ignore: cast_nullable_to_non_nullable
              as String,
      secondaryFont: null == secondaryFont
          ? _self.secondaryFont
          : secondaryFont // ignore: cast_nullable_to_non_nullable
              as String,
      fontScaleFactor: null == fontScaleFactor
          ? _self.fontScaleFactor
          : fontScaleFactor // ignore: cast_nullable_to_non_nullable
              as double,
      useCustomFonts: null == useCustomFonts
          ? _self.useCustomFonts
          : useCustomFonts // ignore: cast_nullable_to_non_nullable
              as bool,
      customFontUrls: null == customFontUrls
          ? _self._customFontUrls
          : customFontUrls // ignore: cast_nullable_to_non_nullable
              as Map<String, String>,
      renderingStyle: null == renderingStyle
          ? _self.renderingStyle
          : renderingStyle // ignore: cast_nullable_to_non_nullable
              as String,
      lineHeightMultiplier: null == lineHeightMultiplier
          ? _self.lineHeightMultiplier
          : lineHeightMultiplier // ignore: cast_nullable_to_non_nullable
              as double,
      letterSpacing: null == letterSpacing
          ? _self.letterSpacing
          : letterSpacing // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc
mixin _$CustomWidget {
  String get id;
  String get type;
  Map<String, dynamic> get properties;
  int get order;
  bool get visible;

  /// Create a copy of CustomWidget
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  $CustomWidgetCopyWith<CustomWidget> get copyWith =>
      _$CustomWidgetCopyWithImpl<CustomWidget>(
          this as CustomWidget, _$identity);

  /// Serializes this CustomWidget to a JSON map.
  Map<String, dynamic> toJson();

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is CustomWidget &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other.properties, properties) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.visible, visible) || other.visible == visible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type,
      const DeepCollectionEquality().hash(properties), order, visible);

  @override
  String toString() {
    return 'CustomWidget(id: $id, type: $type, properties: $properties, order: $order, visible: $visible)';
  }
}

/// @nodoc
abstract mixin class $CustomWidgetCopyWith<$Res> {
  factory $CustomWidgetCopyWith(
          CustomWidget value, $Res Function(CustomWidget) _then) =
      _$CustomWidgetCopyWithImpl;
  @useResult
  $Res call(
      {String id,
      String type,
      Map<String, dynamic> properties,
      int order,
      bool visible});
}

/// @nodoc
class _$CustomWidgetCopyWithImpl<$Res> implements $CustomWidgetCopyWith<$Res> {
  _$CustomWidgetCopyWithImpl(this._self, this._then);

  final CustomWidget _self;
  final $Res Function(CustomWidget) _then;

  /// Create a copy of CustomWidget
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? properties = null,
    Object? order = null,
    Object? visible = null,
  }) {
    return _then(_self.copyWith(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _self.properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// Adds pattern-matching-related methods to [CustomWidget].
extension CustomWidgetPatterns on CustomWidget {
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
    TResult Function(_CustomWidget value)? $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CustomWidget() when $default != null:
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
    TResult Function(_CustomWidget value) $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomWidget():
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
    TResult? Function(_CustomWidget value)? $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomWidget() when $default != null:
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
    TResult Function(String id, String type, Map<String, dynamic> properties,
            int order, bool visible)?
        $default, {
    required TResult orElse(),
  }) {
    final _that = this;
    switch (_that) {
      case _CustomWidget() when $default != null:
        return $default(
            _that.id, _that.type, _that.properties, _that.order, _that.visible);
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
    TResult Function(String id, String type, Map<String, dynamic> properties,
            int order, bool visible)
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomWidget():
        return $default(
            _that.id, _that.type, _that.properties, _that.order, _that.visible);
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
    TResult? Function(String id, String type, Map<String, dynamic> properties,
            int order, bool visible)?
        $default,
  ) {
    final _that = this;
    switch (_that) {
      case _CustomWidget() when $default != null:
        return $default(
            _that.id, _that.type, _that.properties, _that.order, _that.visible);
      case _:
        return null;
    }
  }
}

/// @nodoc
@JsonSerializable()
class _CustomWidget implements CustomWidget {
  const _CustomWidget(
      {required this.id,
      required this.type,
      required final Map<String, dynamic> properties,
      required this.order,
      this.visible = true})
      : _properties = properties;
  factory _CustomWidget.fromJson(Map<String, dynamic> json) =>
      _$CustomWidgetFromJson(json);

  @override
  final String id;
  @override
  final String type;
  final Map<String, dynamic> _properties;
  @override
  Map<String, dynamic> get properties {
    if (_properties is EqualUnmodifiableMapView) return _properties;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_properties);
  }

  @override
  final int order;
  @override
  @JsonKey()
  final bool visible;

  /// Create a copy of CustomWidget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  @pragma('vm:prefer-inline')
  _$CustomWidgetCopyWith<_CustomWidget> get copyWith =>
      __$CustomWidgetCopyWithImpl<_CustomWidget>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$CustomWidgetToJson(
      this,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _CustomWidget &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._properties, _properties) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.visible, visible) || other.visible == visible));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, id, type,
      const DeepCollectionEquality().hash(_properties), order, visible);

  @override
  String toString() {
    return 'CustomWidget(id: $id, type: $type, properties: $properties, order: $order, visible: $visible)';
  }
}

/// @nodoc
abstract mixin class _$CustomWidgetCopyWith<$Res>
    implements $CustomWidgetCopyWith<$Res> {
  factory _$CustomWidgetCopyWith(
          _CustomWidget value, $Res Function(_CustomWidget) _then) =
      __$CustomWidgetCopyWithImpl;
  @override
  @useResult
  $Res call(
      {String id,
      String type,
      Map<String, dynamic> properties,
      int order,
      bool visible});
}

/// @nodoc
class __$CustomWidgetCopyWithImpl<$Res>
    implements _$CustomWidgetCopyWith<$Res> {
  __$CustomWidgetCopyWithImpl(this._self, this._then);

  final _CustomWidget _self;
  final $Res Function(_CustomWidget) _then;

  /// Create a copy of CustomWidget
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? properties = null,
    Object? order = null,
    Object? visible = null,
  }) {
    return _then(_CustomWidget(
      id: null == id
          ? _self.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _self.type
          : type // ignore: cast_nullable_to_non_nullable
              as String,
      properties: null == properties
          ? _self._properties
          : properties // ignore: cast_nullable_to_non_nullable
              as Map<String, dynamic>,
      order: null == order
          ? _self.order
          : order // ignore: cast_nullable_to_non_nullable
              as int,
      visible: null == visible
          ? _self.visible
          : visible // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

// dart format on
