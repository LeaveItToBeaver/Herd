// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_customization_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UICustomizationModel _$UICustomizationModelFromJson(
        Map<String, dynamic> json) =>
    _UICustomizationModel(
      userId: json['userId'] as String,
      lastUpdated: const TimestampOrStringDateTimeConverter()
          .fromJson(json['lastUpdated']),
      appTheme: json['appTheme'] == null
          ? const AppThemeSettings()
          : AppThemeSettings.fromJson(json['appTheme'] as Map<String, dynamic>),
      profileCustomization: json['profileCustomization'] == null
          ? const ProfileCustomization()
          : ProfileCustomization.fromJson(
              json['profileCustomization'] as Map<String, dynamic>),
      componentStyles: json['componentStyles'] == null
          ? const ComponentStyles()
          : ComponentStyles.fromJson(
              json['componentStyles'] as Map<String, dynamic>),
      layoutPreferences: json['layoutPreferences'] == null
          ? const LayoutPreferences()
          : LayoutPreferences.fromJson(
              json['layoutPreferences'] as Map<String, dynamic>),
      animationSettings: json['animationSettings'] == null
          ? const AnimationSettings()
          : AnimationSettings.fromJson(
              json['animationSettings'] as Map<String, dynamic>),
      typography: json['typography'] == null
          ? const TypographySettings()
          : TypographySettings.fromJson(
              json['typography'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UICustomizationModelToJson(
        _UICustomizationModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'lastUpdated': const TimestampOrStringDateTimeConverter()
          .toJson(instance.lastUpdated),
      'appTheme': instance.appTheme.toJson(),
      'profileCustomization': instance.profileCustomization.toJson(),
      'componentStyles': instance.componentStyles.toJson(),
      'layoutPreferences': instance.layoutPreferences.toJson(),
      'animationSettings': instance.animationSettings.toJson(),
      'typography': instance.typography.toJson(),
    };

_AppThemeSettings _$AppThemeSettingsFromJson(Map<String, dynamic> json) =>
    _AppThemeSettings(
      primaryColor: json['primaryColor'] as String? ?? '#3D5AFE',
      secondaryColor: json['secondaryColor'] as String? ?? '#00C853',
      backgroundColor: json['backgroundColor'] as String? ?? '#FFFFFF',
      surfaceColor: json['surfaceColor'] as String? ?? '#F5F5F5',
      textColor: json['textColor'] as String? ?? '#212121',
      secondaryTextColor: json['secondaryTextColor'] as String? ?? '#757575',
      errorColor: json['errorColor'] as String? ?? '#D32F2F',
      warningColor: json['warningColor'] as String? ?? '#FF9800',
      successColor: json['successColor'] as String? ?? '#4CAF50',
      onPrimaryColor: json['onPrimaryColor'] as String? ?? '#FFFFFF',
      onSecondaryColor: json['onSecondaryColor'] as String? ?? '#000000',
      onBackgroundColor: json['onBackgroundColor'] as String? ?? '#000000',
      onErrorColor: json['onErrorColor'] as String? ?? '#FFFFFF',
      onSurfaceColor: json['onSurfaceColor'] as String? ?? '#212121',
      primaryContainerColor:
          json['primaryContainerColor'] as String? ?? '#E8EAF6',
      onPrimaryContainerColor:
          json['onPrimaryContainerColor'] as String? ?? '#1A237E',
      secondaryContainerColor:
          json['secondaryContainerColor'] as String? ?? '#E8F5E9',
      onSecondaryContainerColor:
          json['onSecondaryContainerColor'] as String? ?? '#1B5E20',
      tertiaryContainerColor:
          json['tertiaryContainerColor'] as String? ?? '#FFECB3',
      onTertiaryContainerColor:
          json['onTertiaryContainerColor'] as String? ?? '#FF6F00',
      tertiaryColor: json['tertiaryColor'] as String? ?? '#FFAB00',
      outlineColor: json['outlineColor'] as String? ?? '#BDBDBD',
      shadowColor: json['shadowColor'] as String? ?? '#000000',
      surfaceVariantColor: json['surfaceVariantColor'] as String? ?? '#E0E0E0',
      onSurfaceVariantColor:
          json['onSurfaceVariantColor'] as String? ?? '#424242',
      disabledColor: json['disabledColor'] as String? ?? '#BDBDBD',
      hintColor: json['hintColor'] as String? ?? '#9E9E9E',
      themeMode: json['themeMode'] as String? ?? 'system',
      useMaterial3: json['useMaterial3'] as bool? ?? true,
      enableGlassmorphism: json['enableGlassmorphism'] as bool? ?? false,
      enableGradients: json['enableGradients'] as bool? ?? false,
      enableShadows: json['enableShadows'] as bool? ?? true,
      shadowIntensity: (json['shadowIntensity'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$AppThemeSettingsToJson(_AppThemeSettings instance) =>
    <String, dynamic>{
      'primaryColor': instance.primaryColor,
      'secondaryColor': instance.secondaryColor,
      'backgroundColor': instance.backgroundColor,
      'surfaceColor': instance.surfaceColor,
      'textColor': instance.textColor,
      'secondaryTextColor': instance.secondaryTextColor,
      'errorColor': instance.errorColor,
      'warningColor': instance.warningColor,
      'successColor': instance.successColor,
      'onPrimaryColor': instance.onPrimaryColor,
      'onSecondaryColor': instance.onSecondaryColor,
      'onBackgroundColor': instance.onBackgroundColor,
      'onErrorColor': instance.onErrorColor,
      'onSurfaceColor': instance.onSurfaceColor,
      'primaryContainerColor': instance.primaryContainerColor,
      'onPrimaryContainerColor': instance.onPrimaryContainerColor,
      'secondaryContainerColor': instance.secondaryContainerColor,
      'onSecondaryContainerColor': instance.onSecondaryContainerColor,
      'tertiaryContainerColor': instance.tertiaryContainerColor,
      'onTertiaryContainerColor': instance.onTertiaryContainerColor,
      'tertiaryColor': instance.tertiaryColor,
      'outlineColor': instance.outlineColor,
      'shadowColor': instance.shadowColor,
      'surfaceVariantColor': instance.surfaceVariantColor,
      'onSurfaceVariantColor': instance.onSurfaceVariantColor,
      'disabledColor': instance.disabledColor,
      'hintColor': instance.hintColor,
      'themeMode': instance.themeMode,
      'useMaterial3': instance.useMaterial3,
      'enableGlassmorphism': instance.enableGlassmorphism,
      'enableGradients': instance.enableGradients,
      'enableShadows': instance.enableShadows,
      'shadowIntensity': instance.shadowIntensity,
    };

_ProfileCustomization _$ProfileCustomizationFromJson(
        Map<String, dynamic> json) =>
    _ProfileCustomization(
      backgroundImageUrl: json['backgroundImageUrl'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      backgroundType: json['backgroundType'] as String? ?? 'solid',
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      gradientAngle: (json['gradientAngle'] as num?)?.toDouble() ?? 0.0,
      layout: json['layout'] as String? ?? 'classic',
      showCoverImage: json['showCoverImage'] as bool? ?? true,
      showProfileImage: json['showProfileImage'] as bool? ?? true,
      profileImageShape: json['profileImageShape'] as String? ?? 'circle',
      profileImageSize: (json['profileImageSize'] as num?)?.toDouble() ?? 80.0,
      showBio: json['showBio'] as bool? ?? true,
      showStats: json['showStats'] as bool? ?? true,
      showPosts: json['showPosts'] as bool? ?? true,
      showAboutSection: json['showAboutSection'] as bool? ?? true,
      enableParticles: json['enableParticles'] as bool? ?? false,
      enableAnimatedBackground:
          json['enableAnimatedBackground'] as bool? ?? false,
      enableCustomCursor: json['enableCustomCursor'] as bool? ?? false,
      customCursorUrl: json['customCursorUrl'] as String?,
      customCSS: json['customCSS'] as String?,
      enableMusicPlayer: json['enableMusicPlayer'] as bool? ?? false,
      musicUrl: json['musicUrl'] as String?,
      autoPlayMusic: json['autoPlayMusic'] as bool? ?? false,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
      cardBorderRadius: (json['cardBorderRadius'] as num?)?.toDouble() ?? 16.0,
      cardElevation: (json['cardElevation'] as num?)?.toDouble() ?? 2.0,
      cardBackgroundColor: json['cardBackgroundColor'] as String?,
      cardOpacity: (json['cardOpacity'] as num?)?.toDouble() ?? 0.95,
      customWidgets: (json['customWidgets'] as List<dynamic>?)
              ?.map((e) => CustomWidget.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ProfileCustomizationToJson(
        _ProfileCustomization instance) =>
    <String, dynamic>{
      'backgroundImageUrl': instance.backgroundImageUrl,
      'backgroundColor': instance.backgroundColor,
      'backgroundType': instance.backgroundType,
      'gradientColors': instance.gradientColors,
      'gradientAngle': instance.gradientAngle,
      'layout': instance.layout,
      'showCoverImage': instance.showCoverImage,
      'showProfileImage': instance.showProfileImage,
      'profileImageShape': instance.profileImageShape,
      'profileImageSize': instance.profileImageSize,
      'showBio': instance.showBio,
      'showStats': instance.showStats,
      'showPosts': instance.showPosts,
      'showAboutSection': instance.showAboutSection,
      'enableParticles': instance.enableParticles,
      'enableAnimatedBackground': instance.enableAnimatedBackground,
      'enableCustomCursor': instance.enableCustomCursor,
      'customCursorUrl': instance.customCursorUrl,
      'customCSS': instance.customCSS,
      'enableMusicPlayer': instance.enableMusicPlayer,
      'musicUrl': instance.musicUrl,
      'autoPlayMusic': instance.autoPlayMusic,
      'musicVolume': instance.musicVolume,
      'cardBorderRadius': instance.cardBorderRadius,
      'cardElevation': instance.cardElevation,
      'cardBackgroundColor': instance.cardBackgroundColor,
      'cardOpacity': instance.cardOpacity,
      'customWidgets': instance.customWidgets.map((e) => e.toJson()).toList(),
    };

_ComponentStyles _$ComponentStylesFromJson(Map<String, dynamic> json) =>
    _ComponentStyles(
      primaryButton: json['primaryButton'] == null
          ? const ButtonStyle()
          : ButtonStyle.fromJson(json['primaryButton'] as Map<String, dynamic>),
      secondaryButton: json['secondaryButton'] == null
          ? const ButtonStyle()
          : ButtonStyle.fromJson(
              json['secondaryButton'] as Map<String, dynamic>),
      cardBorderRadius: (json['cardBorderRadius'] as num?)?.toDouble() ?? 16.0,
      cardElevation: (json['cardElevation'] as num?)?.toDouble() ?? 2.0,
      cardOutline: json['cardOutline'] as bool? ?? false,
      cardOutlineColor: json['cardOutlineColor'] as String? ?? '#E0E0E0',
      inputField: json['inputField'] == null
          ? const InputFieldStyle()
          : InputFieldStyle.fromJson(
              json['inputField'] as Map<String, dynamic>),
      navigation: json['navigation'] == null
          ? const NavigationStyle()
          : NavigationStyle.fromJson(
              json['navigation'] as Map<String, dynamic>),
      dialogBorderRadius:
          (json['dialogBorderRadius'] as num?)?.toDouble() ?? 24.0,
      dialogBlurBackground: json['dialogBlurBackground'] as bool? ?? false,
      dialogBlurIntensity:
          (json['dialogBlurIntensity'] as num?)?.toDouble() ?? 10.0,
    );

Map<String, dynamic> _$ComponentStylesToJson(_ComponentStyles instance) =>
    <String, dynamic>{
      'primaryButton': instance.primaryButton.toJson(),
      'secondaryButton': instance.secondaryButton.toJson(),
      'cardBorderRadius': instance.cardBorderRadius,
      'cardElevation': instance.cardElevation,
      'cardOutline': instance.cardOutline,
      'cardOutlineColor': instance.cardOutlineColor,
      'inputField': instance.inputField.toJson(),
      'navigation': instance.navigation.toJson(),
      'dialogBorderRadius': instance.dialogBorderRadius,
      'dialogBlurBackground': instance.dialogBlurBackground,
      'dialogBlurIntensity': instance.dialogBlurIntensity,
    };

_ButtonStyle _$ButtonStyleFromJson(Map<String, dynamic> json) => _ButtonStyle(
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      horizontalPadding:
          (json['horizontalPadding'] as num?)?.toDouble() ?? 16.0,
      verticalPadding: (json['verticalPadding'] as num?)?.toDouble() ?? 8.0,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 1.0,
      enableGradient: json['enableGradient'] as bool? ?? false,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      shape: json['shape'] as String? ?? 'rounded',
      enableRipple: json['enableRipple'] as bool? ?? false,
      rippleColor: json['rippleColor'] as String?,
      fontWeight: json['fontWeight'] as String? ?? 'w500',
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      uppercase: json['uppercase'] as bool? ?? false,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 1.0,
    );

Map<String, dynamic> _$ButtonStyleToJson(_ButtonStyle instance) =>
    <String, dynamic>{
      'borderRadius': instance.borderRadius,
      'horizontalPadding': instance.horizontalPadding,
      'verticalPadding': instance.verticalPadding,
      'elevation': instance.elevation,
      'enableGradient': instance.enableGradient,
      'gradientColors': instance.gradientColors,
      'shape': instance.shape,
      'enableRipple': instance.enableRipple,
      'rippleColor': instance.rippleColor,
      'fontWeight': instance.fontWeight,
      'fontSize': instance.fontSize,
      'uppercase': instance.uppercase,
      'letterSpacing': instance.letterSpacing,
    };

_InputFieldStyle _$InputFieldStyleFromJson(Map<String, dynamic> json) =>
    _InputFieldStyle(
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 8.0,
      borderType: json['borderType'] as String? ?? 'outline',
      borderWidth: (json['borderWidth'] as num?)?.toDouble() ?? 1.0,
      filled: json['filled'] as bool? ?? false,
      fillColor: json['fillColor'] as String?,
      contentPadding: (json['contentPadding'] as num?)?.toDouble() ?? 16.0,
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 14.0,
      enableFloatingLabel: json['enableFloatingLabel'] as bool? ?? false,
    );

Map<String, dynamic> _$InputFieldStyleToJson(_InputFieldStyle instance) =>
    <String, dynamic>{
      'borderRadius': instance.borderRadius,
      'borderType': instance.borderType,
      'borderWidth': instance.borderWidth,
      'filled': instance.filled,
      'fillColor': instance.fillColor,
      'contentPadding': instance.contentPadding,
      'fontSize': instance.fontSize,
      'enableFloatingLabel': instance.enableFloatingLabel,
    };

_NavigationStyle _$NavigationStyleFromJson(Map<String, dynamic> json) =>
    _NavigationStyle(
      type: json['type'] as String? ?? 'bottom',
      floating: json['floating'] as bool? ?? false,
      borderRadius: (json['borderRadius'] as num?)?.toDouble() ?? 30.0,
      margin: (json['margin'] as num?)?.toDouble() ?? 8.0,
      elevation: (json['elevation'] as num?)?.toDouble() ?? 4.0,
      enableGradient: json['enableGradient'] as bool? ?? false,
      gradientColors: (json['gradientColors'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      opacity: (json['opacity'] as num?)?.toDouble() ?? 0.9,
      showLabels: json['showLabels'] as bool? ?? false,
      iconSize: (json['iconSize'] as num?)?.toDouble() ?? 24.0,
      enableActiveIndicator: json['enableActiveIndicator'] as bool? ?? false,
    );

Map<String, dynamic> _$NavigationStyleToJson(_NavigationStyle instance) =>
    <String, dynamic>{
      'type': instance.type,
      'floating': instance.floating,
      'borderRadius': instance.borderRadius,
      'margin': instance.margin,
      'elevation': instance.elevation,
      'enableGradient': instance.enableGradient,
      'gradientColors': instance.gradientColors,
      'opacity': instance.opacity,
      'showLabels': instance.showLabels,
      'iconSize': instance.iconSize,
      'enableActiveIndicator': instance.enableActiveIndicator,
    };

_LayoutPreferences _$LayoutPreferencesFromJson(Map<String, dynamic> json) =>
    _LayoutPreferences(
      density: json['density'] as String? ?? 'comfortable',
      defaultSpacing: (json['defaultSpacing'] as num?)?.toDouble() ?? 8.0,
      defaultPadding: (json['defaultPadding'] as num?)?.toDouble() ?? 16.0,
      useCompactPosts: json['useCompactPosts'] as bool? ?? false,
      useListLayout: json['useListLayout'] as bool? ?? false,
      gridColumns: (json['gridColumns'] as num?)?.toInt() ?? 2,
      centerContent: json['centerContent'] as bool? ?? false,
      maxContentWidth: (json['maxContentWidth'] as num?)?.toDouble() ?? 1200.0,
      showFloatingButtons: json['showFloatingButtons'] as bool? ?? true,
      floatingButtonPosition:
          json['floatingButtonPosition'] as String? ?? 'bottomRight',
    );

Map<String, dynamic> _$LayoutPreferencesToJson(_LayoutPreferences instance) =>
    <String, dynamic>{
      'density': instance.density,
      'defaultSpacing': instance.defaultSpacing,
      'defaultPadding': instance.defaultPadding,
      'useCompactPosts': instance.useCompactPosts,
      'useListLayout': instance.useListLayout,
      'gridColumns': instance.gridColumns,
      'centerContent': instance.centerContent,
      'maxContentWidth': instance.maxContentWidth,
      'showFloatingButtons': instance.showFloatingButtons,
      'floatingButtonPosition': instance.floatingButtonPosition,
    };

_AnimationSettings _$AnimationSettingsFromJson(Map<String, dynamic> json) =>
    _AnimationSettings(
      enableAnimations: json['enableAnimations'] as bool? ?? true,
      speed: json['speed'] as String? ?? 'normal',
      enablePageTransitions: json['enablePageTransitions'] as bool? ?? true,
      pageTransitionType: json['pageTransitionType'] as String? ?? 'fade',
      enableHoverEffects: json['enableHoverEffects'] as bool? ?? true,
      enableScrollAnimations: json['enableScrollAnimations'] as bool? ?? true,
      enableParallaxEffects: json['enableParallaxEffects'] as bool? ?? false,
      enableLoadingAnimations: json['enableLoadingAnimations'] as bool? ?? true,
      defaultCurve: json['defaultCurve'] as String? ?? 'easeInOut',
    );

Map<String, dynamic> _$AnimationSettingsToJson(_AnimationSettings instance) =>
    <String, dynamic>{
      'enableAnimations': instance.enableAnimations,
      'speed': instance.speed,
      'enablePageTransitions': instance.enablePageTransitions,
      'pageTransitionType': instance.pageTransitionType,
      'enableHoverEffects': instance.enableHoverEffects,
      'enableScrollAnimations': instance.enableScrollAnimations,
      'enableParallaxEffects': instance.enableParallaxEffects,
      'enableLoadingAnimations': instance.enableLoadingAnimations,
      'defaultCurve': instance.defaultCurve,
    };

_TypographySettings _$TypographySettingsFromJson(Map<String, dynamic> json) =>
    _TypographySettings(
      primaryFont: json['primaryFont'] as String? ?? 'Roboto',
      secondaryFont: json['secondaryFont'] as String? ?? 'Roboto',
      fontScaleFactor: (json['fontScaleFactor'] as num?)?.toDouble() ?? 1.0,
      useCustomFonts: json['useCustomFonts'] as bool? ?? false,
      customFontUrls: (json['customFontUrls'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(k, e as String),
          ) ??
          const {},
      renderingStyle: json['renderingStyle'] as String? ?? 'optimal',
      lineHeightMultiplier:
          (json['lineHeightMultiplier'] as num?)?.toDouble() ?? 1.5,
      letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$TypographySettingsToJson(_TypographySettings instance) =>
    <String, dynamic>{
      'primaryFont': instance.primaryFont,
      'secondaryFont': instance.secondaryFont,
      'fontScaleFactor': instance.fontScaleFactor,
      'useCustomFonts': instance.useCustomFonts,
      'customFontUrls': instance.customFontUrls,
      'renderingStyle': instance.renderingStyle,
      'lineHeightMultiplier': instance.lineHeightMultiplier,
      'letterSpacing': instance.letterSpacing,
    };

_CustomWidget _$CustomWidgetFromJson(Map<String, dynamic> json) =>
    _CustomWidget(
      id: json['id'] as String,
      type: json['type'] as String,
      properties: json['properties'] as Map<String, dynamic>,
      order: (json['order'] as num).toInt(),
      visible: json['visible'] as bool? ?? true,
    );

Map<String, dynamic> _$CustomWidgetToJson(_CustomWidget instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'properties': instance.properties,
      'order': instance.order,
      'visible': instance.visible,
    };
