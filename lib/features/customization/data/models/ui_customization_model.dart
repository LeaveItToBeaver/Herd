import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/customization/data/converters/ui_customization_converters.dart';

part 'ui_customization_model.freezed.dart';
part 'ui_customization_model.g.dart';

@freezed
abstract class UICustomizationModel with _$UICustomizationModel {
  const UICustomizationModel._();

  const factory UICustomizationModel({
    required String userId,
    @TimestampOrStringDateTimeConverter() required DateTime lastUpdated,

    // Global App Theme Settings
    @Default(AppThemeSettings()) AppThemeSettings appTheme,

    // Profile Page Customization
    @Default(ProfileCustomization()) ProfileCustomization profileCustomization,

    // Component Styles
    @Default(ComponentStyles()) ComponentStyles componentStyles,

    // Layout Preferences
    @Default(LayoutPreferences()) LayoutPreferences layoutPreferences,

    // Animation Settings
    @Default(AnimationSettings()) AnimationSettings animationSettings,

    // Typography Settings
    @Default(TypographySettings()) TypographySettings typography,
  }) = _UICustomizationModel;

  factory UICustomizationModel.fromJson(Map<String, dynamic> json) =>
      _$UICustomizationModelFromJson(json);

  // Default customization for new users with safe defaults
  factory UICustomizationModel.defaultForUser(String userId) {
    return UICustomizationModel(
      userId: userId,
      lastUpdated: DateTime.now(),
      appTheme: const AppThemeSettings(),
      profileCustomization: const ProfileCustomization(),
      componentStyles: const ComponentStyles(),
      layoutPreferences: const LayoutPreferences(),
      animationSettings: const AnimationSettings(),
      typography: const TypographySettings(),
    );
  }

  // Create a safe TextStyle for consistent interpolation
  TextStyle createSafeTextStyle({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    String? fontFamily,
  }) {
    return TextStyle(
      inherit: true, // Always use inherit: true for consistency
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      fontFamily: fontFamily ?? typography.primaryFont,
    );
  }

  // Get a base TextStyle for the app
  TextStyle getBaseTextStyle() {
    return createSafeTextStyle(
      fontSize: 14.0 * typography.fontScaleFactor,
      color: appTheme.getTextColor(),
      letterSpacing: typography.letterSpacing,
      height: typography.lineHeightMultiplier,
      fontFamily: typography.primaryFont,
    );
  }
}

@freezed
abstract class AppThemeSettings with _$AppThemeSettings {
  const AppThemeSettings._();

  const factory AppThemeSettings({
    // Core colors (stored as hex strings) with safe defaults
    @Default('#3D5AFE') String primaryColor,
    @Default('#00C853') String secondaryColor,
    @Default('#FFFFFF') String backgroundColor,
    @Default('#F5F5F5') String surfaceColor,
    @Default('#212121') String textColor,
    @Default('#757575') String secondaryTextColor,
    @Default('#D32F2F') String errorColor,
    @Default('#FF9800') String warningColor,
    @Default('#4CAF50') String successColor,

    // "On" Colors with safe defaults
    @Default('#FFFFFF') String onPrimaryColor,
    @Default('#000000') String onSecondaryColor,
    @Default('#000000') String onBackgroundColor,
    @Default('#FFFFFF') String onErrorColor,
    @Default('#212121') String onSurfaceColor,

    // Container Colors with safe defaults
    @Default('#E8EAF6') String primaryContainerColor,
    @Default('#1A237E') String onPrimaryContainerColor,
    @Default('#E8F5E9') String secondaryContainerColor,
    @Default('#1B5E20') String onSecondaryContainerColor,
    @Default('#FFECB3') String tertiaryContainerColor,
    @Default('#FF6F00') String onTertiaryContainerColor,

    // Tertiary Color
    @Default('#FFAB00') String tertiaryColor,

    // Utility Colors with safe defaults
    @Default('#BDBDBD') String outlineColor,
    @Default('#000000') String shadowColor,
    @Default('#E0E0E0') String surfaceVariantColor,
    @Default('#424242') String onSurfaceVariantColor,
    @Default('#BDBDBD') String disabledColor,
    @Default('#9E9E9E') String hintColor,

    // Theme mode as string with safe default
    @Default('system') String themeMode,
    @Default(true) bool useMaterial3,

    // Special effects with safe defaults
    @Default(false) bool enableGlassmorphism,
    @Default(false) bool enableGradients,
    @Default(true) bool enableShadows, // Changed default to true
    @Default(1.0) double shadowIntensity,
  }) = _AppThemeSettings;

  factory AppThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$AppThemeSettingsFromJson(json);

  // Safe color conversion with fallbacks
  Color getPrimaryColor() => _hexToColorSafe(primaryColor, const Color(0xFF3D5AFE));
  Color getSecondaryColor() => _hexToColorSafe(secondaryColor, const Color(0xFF00C853));
  Color getBackgroundColor() => _hexToColorSafe(backgroundColor, const Color(0xFFFFFFFF));
  Color getSurfaceColor() => _hexToColorSafe(surfaceColor, const Color(0xFFF5F5F5));
  Color getTextColor() => _hexToColorSafe(textColor, const Color(0xFF212121));
  Color getSecondaryTextColor() => _hexToColorSafe(secondaryTextColor, const Color(0xFF757575));
  Color getErrorColor() => _hexToColorSafe(errorColor, const Color(0xFFD32F2F));
  Color getWarningColor() => _hexToColorSafe(warningColor, const Color(0xFFFF9800));
  Color getSuccessColor() => _hexToColorSafe(successColor, const Color(0xFF4CAF50));

  // New safe getter methods
  Color getOnPrimaryColor() => _hexToColorSafe(onPrimaryColor, const Color(0xFFFFFFFF));
  Color getOnSecondaryColor() => _hexToColorSafe(onSecondaryColor, const Color(0xFF000000));
  Color getOnBackgroundColor() => _hexToColorSafe(onBackgroundColor, const Color(0xFF000000));
  Color getOnErrorColor() => _hexToColorSafe(onErrorColor, const Color(0xFFFFFFFF));
  Color getOnSurfaceColor() => _hexToColorSafe(onSurfaceColor, const Color(0xFF212121));

  Color getPrimaryContainerColor() => _hexToColorSafe(primaryContainerColor, const Color(0xFFE8EAF6));
  Color getOnPrimaryContainerColor() => _hexToColorSafe(onPrimaryContainerColor, const Color(0xFF1A237E));
  Color getSecondaryContainerColor() => _hexToColorSafe(secondaryContainerColor, const Color(0xFFE8F5E9));
  Color getOnSecondaryContainerColor() => _hexToColorSafe(onSecondaryContainerColor, const Color(0xFF1B5E20));
  Color getTertiaryContainerColor() => _hexToColorSafe(tertiaryContainerColor, const Color(0xFFFFECB3));
  Color getOnTertiaryContainerColor() => _hexToColorSafe(onTertiaryContainerColor, const Color(0xFFFF6F00));

  Color getTertiaryColor() => _hexToColorSafe(tertiaryColor, const Color(0xFFFFAB00));

  Color getOutlineColor() => _hexToColorSafe(outlineColor, const Color(0xFFBDBDBD));
  Color getShadowColor() => _hexToColorSafe(shadowColor, const Color(0xFF000000));
  Color getSurfaceVariantColor() => _hexToColorSafe(surfaceVariantColor, const Color(0xFFE0E0E0));
  Color getOnSurfaceVariantColor() => _hexToColorSafe(onSurfaceVariantColor, const Color(0xFF424242));
  Color getDisabledColor() => _hexToColorSafe(disabledColor, const Color(0xFFBDBDBD));
  Color getHintColor() => _hexToColorSafe(hintColor, const Color(0xFF9E9E9E));

  // Safe theme mode getter
  ThemeMode getThemeMode() {
    switch (themeMode.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  // Safe hex to color conversion with fallback
  static Color _hexToColorSafe(String hex, Color fallback) {
    try {
      if (hex.isEmpty) return fallback;
      
      final buffer = StringBuffer();
      if (hex.length == 6 || hex.length == 7) {
        buffer.write('ff'); // Ensure alpha if not present
      }
      buffer.write(hex.replaceFirst('#', ''));
      
      if (buffer.length == 6) {
        // Prepend 'ff' if still only 6 chars
        final temp = buffer.toString();
        buffer.clear();
        buffer.write('ff');
        buffer.write(temp);
      }
      
      if (buffer.length != 8) return fallback;
      
      final colorValue = int.tryParse(buffer.toString(), radix: 16);
      if (colorValue == null) return fallback;
      
      return Color(colorValue);
    } catch (e) {
      return fallback;
    }
  }
}

@freezed
abstract class ProfileCustomization with _$ProfileCustomization {
  const factory ProfileCustomization({
    // Background customization with safe defaults
    String? backgroundImageUrl,
    String? backgroundColor,
    @Default('solid') String backgroundType,
    @Default([]) List<String> gradientColors,
    @Default(0.0) double gradientAngle,

    // Layout customization with safe defaults
    @Default('classic') String layout,
    @Default(true) bool showCoverImage,
    @Default(true) bool showProfileImage,
    @Default('circle') String profileImageShape,
    @Default(80.0) double profileImageSize,

    // Content sections with safe defaults
    @Default(true) bool showBio,
    @Default(true) bool showStats,
    @Default(true) bool showPosts,
    @Default(true) bool showAboutSection,

    // Special effects with safe defaults
    @Default(false) bool enableParticles,
    @Default(false) bool enableAnimatedBackground,
    @Default(false) bool enableCustomCursor,
    String? customCursorUrl,

    // Custom CSS
    String? customCSS,

    // Music player with safe defaults
    @Default(false) bool enableMusicPlayer,
    String? musicUrl,
    @Default(false) bool autoPlayMusic,
    @Default(0.5) double musicVolume,

    // Profile card styling with safe defaults
    @Default(16.0) double cardBorderRadius,
    @Default(2.0) double cardElevation,
    String? cardBackgroundColor,
    @Default(0.95) double cardOpacity,

    // Custom widgets with safe defaults
    @Default([]) List<CustomWidget> customWidgets,
  }) = _ProfileCustomization;

  factory ProfileCustomization.fromJson(Map<String, dynamic> json) =>
      _$ProfileCustomizationFromJson(json);
}

@freezed
abstract class ComponentStyles with _$ComponentStyles {
  const factory ComponentStyles({
    // Button styling with safe defaults
    @Default(ButtonStyle()) ButtonStyle primaryButton,
    @Default(ButtonStyle()) ButtonStyle secondaryButton,

    // Card styling with safe defaults
    @Default(16.0) double cardBorderRadius,
    @Default(2.0) double cardElevation,
    @Default(false) bool cardOutline,
    @Default('#E0E0E0') String cardOutlineColor,

    // Input field styling with safe defaults
    @Default(InputFieldStyle()) InputFieldStyle inputField,

    // Navigation bar styling with safe defaults
    @Default(NavigationStyle()) NavigationStyle navigation,

    // Dialog styling with safe defaults
    @Default(24.0) double dialogBorderRadius,
    @Default(false) bool dialogBlurBackground,
    @Default(10.0) double dialogBlurIntensity,
  }) = _ComponentStyles;

  factory ComponentStyles.fromJson(Map<String, dynamic> json) =>
      _$ComponentStylesFromJson(json);
}

@freezed
abstract class ButtonStyle with _$ButtonStyle {
  const factory ButtonStyle({
    @Default(8.0) double borderRadius,
    @Default(16.0) double horizontalPadding,
    @Default(8.0) double verticalPadding,
    @Default(1.0) double elevation,
    @Default(false) bool enableGradient,
    @Default([]) List<String> gradientColors,
    @Default('rounded') String shape,
    @Default(false) bool enableRipple,
    String? rippleColor,
    @Default('w500') String fontWeight,
    @Default(14.0) double fontSize,
    @Default(false) bool uppercase,
    @Default(1.0) double letterSpacing,
  }) = _ButtonStyle;

  factory ButtonStyle.fromJson(Map<String, dynamic> json) =>
      _$ButtonStyleFromJson(json);
}

@freezed
abstract class InputFieldStyle with _$InputFieldStyle {
  const factory InputFieldStyle({
    @Default(8.0) double borderRadius,
    @Default('outline') String borderType,
    @Default(1.0) double borderWidth,
    @Default(false) bool filled,
    String? fillColor,
    @Default(16.0) double contentPadding,
    @Default(14.0) double fontSize,
    @Default(false) bool enableFloatingLabel,
  }) = _InputFieldStyle;

  factory InputFieldStyle.fromJson(Map<String, dynamic> json) =>
      _$InputFieldStyleFromJson(json);
}

@freezed
abstract class NavigationStyle with _$NavigationStyle {
  const factory NavigationStyle({
    @Default('bottom') String type,
    @Default(false) bool floating,
    @Default(30.0) double borderRadius,
    @Default(8.0) double margin,
    @Default(4.0) double elevation,
    @Default(false) bool enableGradient,
    @Default([]) List<String> gradientColors,
    @Default(0.9) double opacity,
    @Default(false) bool showLabels,
    @Default(24.0) double iconSize,
    @Default(false) bool enableActiveIndicator,
  }) = _NavigationStyle;

  factory NavigationStyle.fromJson(Map<String, dynamic> json) =>
      _$NavigationStyleFromJson(json);
}

@freezed
abstract class LayoutPreferences with _$LayoutPreferences {
  const factory LayoutPreferences({
    @Default('comfortable') String density,
    @Default(8.0) double defaultSpacing,
    @Default(16.0) double defaultPadding,
    @Default(false) bool useCompactPosts,
    @Default(false) bool useListLayout,
    @Default(2) int gridColumns,
    @Default(false) bool centerContent,
    @Default(1200.0) double maxContentWidth,
    @Default(true) bool showFloatingButtons,
    @Default('bottomRight') String floatingButtonPosition,
  }) = _LayoutPreferences;

  factory LayoutPreferences.fromJson(Map<String, dynamic> json) =>
      _$LayoutPreferencesFromJson(json);
}

@freezed
abstract class AnimationSettings with _$AnimationSettings {
  const factory AnimationSettings({
    @Default(true) bool enableAnimations,
    @Default('normal') String speed,
    @Default(true) bool enablePageTransitions,
    @Default('fade') String pageTransitionType,
    @Default(true) bool enableHoverEffects,
    @Default(true) bool enableScrollAnimations,
    @Default(false) bool enableParallaxEffects,
    @Default(true) bool enableLoadingAnimations,
    @Default('easeInOut') String defaultCurve,
  }) = _AnimationSettings;

  factory AnimationSettings.fromJson(Map<String, dynamic> json) =>
      _$AnimationSettingsFromJson(json);
}

@freezed
abstract class TypographySettings with _$TypographySettings {
  const factory TypographySettings({
    @Default('Roboto') String primaryFont,
    @Default('Roboto') String secondaryFont,
    @Default(1.0) double fontScaleFactor,
    @Default(false) bool useCustomFonts,
    @Default({}) Map<String, String> customFontUrls,
    @Default('optimal') String renderingStyle,
    @Default(1.5) double lineHeightMultiplier,
    @Default(0.0) double letterSpacing,
  }) = _TypographySettings;

  factory TypographySettings.fromJson(Map<String, dynamic> json) =>
      _$TypographySettingsFromJson(json);
}

@freezed
abstract class CustomWidget with _$CustomWidget {
  const factory CustomWidget({
    required String id,
    required String type,
    required Map<String, dynamic> properties,
    required int order,
    @Default(true) bool visible,
  }) = _CustomWidget;

  factory CustomWidget.fromJson(Map<String, dynamic> json) =>
      _$CustomWidgetFromJson(json);
}

// Helper extension with safe conversions
extension UICustomizationHelpers on UICustomizationModel {
  // Convert font weight string to FontWeight safely
  FontWeight getFontWeight(String weight) {
    switch (weight.toLowerCase()) {
      case 'w100':
        return FontWeight.w100;
      case 'w200':
        return FontWeight.w200;
      case 'w300':
        return FontWeight.w300;
      case 'w400':
        return FontWeight.w400;
      case 'w500':
        return FontWeight.w500;
      case 'w600':
        return FontWeight.w600;
      case 'w700':
        return FontWeight.w700;
      case 'w800':
        return FontWeight.w800;
      case 'w900':
        return FontWeight.w900;
      default:
        return FontWeight.w400;
    }
  }

  // Convert curve string to Curve safely
  Curve getCurve(String curveName) {
    switch (curveName.toLowerCase()) {
      case 'linear':
        return Curves.linear;
      case 'ease':
        return Curves.ease;
      case 'easein':
        return Curves.easeIn;
      case 'easeout':
        return Curves.easeOut;
      case 'easeinout':
        return Curves.easeInOut;
      case 'fastoutslowin':
        return Curves.fastOutSlowIn;
      case 'bouncein':
        return Curves.bounceIn;
      case 'bounceout':
        return Curves.bounceOut;
      case 'bounceinout':
        return Curves.bounceInOut;
      case 'elasticin':
        return Curves.elasticIn;
      case 'elasticout':
        return Curves.elasticOut;
      case 'elasticinout':
        return Curves.elasticInOut;
      default:
        return Curves.easeInOut;
    }
  }

  // Get animation duration based on speed setting
  Duration getAnimationDuration() {
    switch (animationSettings.speed.toLowerCase()) {
      case 'slow':
        return const Duration(milliseconds: 500);
      case 'normal':
        return const Duration(milliseconds: 300);
      case 'fast':
        return const Duration(milliseconds: 150);
      case 'instant':
        return const Duration(milliseconds: 0);
      default:
        return const Duration(milliseconds: 300);
    }
  }

  // Validate the customization data
  bool isValid() {
    try {
      // Check if userId is valid
      if (userId.isEmpty) return false;
      
      // Check if required colors are valid
      appTheme.getPrimaryColor();
      appTheme.getSecondaryColor();
      appTheme.getBackgroundColor();
      
      // Check if font scale is reasonable
      if (typography.fontScaleFactor < 0.5 || typography.fontScaleFactor > 3.0) {
        return false;
      }
      
      // Check if animation settings are reasonable
      if (animationSettings.enableAnimations && 
          !['slow', 'normal', 'fast', 'instant'].contains(animationSettings.speed)) {
        return false;
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }
}