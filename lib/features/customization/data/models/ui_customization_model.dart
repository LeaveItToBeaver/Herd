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

  // Default customization for new users
  factory UICustomizationModel.defaultForUser(String userId) {
    return UICustomizationModel(
      userId: userId,
      lastUpdated: DateTime.now(),
    );
  }
}

@freezed
abstract class AppThemeSettings with _$AppThemeSettings {
  const AppThemeSettings._();

  const factory AppThemeSettings({
    // Core colors (stored as hex strings)
    @Default('#3D5AFE') String primaryColor,
    @Default('#00C853') String secondaryColor,
    @Default('#FFFFFF') String backgroundColor,
    @Default('#F5F5F5')
    String surfaceColor, // Often used for card backgrounds, dialogs etc.
    @Default('#212121')
    String textColor, // Main text color, often on surface/background
    @Default('#757575')
    String
        secondaryTextColor, // Less prominent text, or text on different surfaces
    @Default('#D32F2F') String errorColor,
    @Default('#FF9800') String warningColor,
    @Default('#4CAF50') String successColor,

    // New "On" Colors (for text/icons on top of the above colors)
    @Default('#FFFFFF') String onPrimaryColor,
    @Default('#000000') String onSecondaryColor,
    @Default('#000000') String onBackgroundColor, // If backgroundColor is light
    @Default('#FFFFFF') String onErrorColor,
    // textColor can serve as onSurfaceColor, but if you need distinct:
    @Default('#212121')
    String onSurfaceColor, // Explicit text/icon color for surfaceColor elements

    // New Container Colors (for elements requiring a fill color related to primary/secondary/tertiary)
    @Default('#E8EAF6')
    String primaryContainerColor, // Lighter/softer version of primary
    @Default('#1A237E')
    String onPrimaryContainerColor, // Text/icon for primaryContainerColor
    @Default('#E8F5E9')
    String secondaryContainerColor, // Lighter/softer version of secondary
    @Default('#1B5E20')
    String onSecondaryContainerColor, // Text/icon for secondaryContainerColor
    @Default('#FFECB3')
    String
        tertiaryContainerColor, // Lighter/softer version of a tertiary/accent color
    @Default('#FF6F00')
    String onTertiaryContainerColor, // Text/icon for tertiaryContainerColor

    // New Accent/Tertiary Color
    @Default('#FFAB00')
    String tertiaryColor, // An accent color distinct from primary/secondary

    // New Utility Colors
    @Default('#BDBDBD') String outlineColor, // For borders, dividers
    @Default('#000000')
    String shadowColor, // Base color for shadows (opacity applied separately)
    @Default('#E0E0E0')
    String surfaceVariantColor, // Another variation of surface color
    @Default('#424242')
    String onSurfaceVariantColor, // Text/icon for surfaceVariantColor
    @Default('#BDBDBD') String disabledColor, // For disabled elements/text
    @Default('#9E9E9E') String hintColor, // For hint text in input fields

    // Theme mode as string
    @Default('system') String themeMode, // 'light', 'dark', 'system'
    @Default(true) bool useMaterial3,

    // Special effects
    @Default(false) bool enableGlassmorphism,
    @Default(false) bool enableGradients,
    @Default(false) bool enableShadows,
    @Default(1.0) double shadowIntensity,
  }) = _AppThemeSettings;

  factory AppThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$AppThemeSettingsFromJson(json);

  // Convert hex color to Color object - Existing Getters
  Color getPrimaryColor() => _hexToColor(primaryColor);
  Color getSecondaryColor() => _hexToColor(secondaryColor);
  Color getBackgroundColor() => _hexToColor(backgroundColor);
  Color getSurfaceColor() => _hexToColor(surfaceColor);
  Color getTextColor() =>
      _hexToColor(textColor); // This is your main text color
  Color getSecondaryTextColor() => _hexToColor(secondaryTextColor);
  Color getErrorColor() => _hexToColor(errorColor);
  Color getWarningColor() => _hexToColor(warningColor);
  Color getSuccessColor() => _hexToColor(successColor);

  // New Getter Methods
  Color getOnPrimaryColor() => _hexToColor(onPrimaryColor);
  Color getOnSecondaryColor() => _hexToColor(onSecondaryColor);
  Color getOnBackgroundColor() => _hexToColor(onBackgroundColor);
  Color getOnErrorColor() => _hexToColor(onErrorColor);
  Color getOnSurfaceColor() =>
      _hexToColor(onSurfaceColor); // Getter for the new explicit onSurfaceColor

  Color getPrimaryContainerColor() => _hexToColor(primaryContainerColor);
  Color getOnPrimaryContainerColor() => _hexToColor(onPrimaryContainerColor);
  Color getSecondaryContainerColor() => _hexToColor(secondaryContainerColor);
  Color getOnSecondaryContainerColor() =>
      _hexToColor(onSecondaryContainerColor);
  Color getTertiaryContainerColor() => _hexToColor(tertiaryContainerColor);
  Color getOnTertiaryContainerColor() => _hexToColor(onTertiaryContainerColor);

  Color getTertiaryColor() => _hexToColor(tertiaryColor);

  Color getOutlineColor() => _hexToColor(outlineColor);
  Color getShadowColor() => _hexToColor(shadowColor);
  Color getSurfaceVariantColor() => _hexToColor(surfaceVariantColor);
  Color getOnSurfaceVariantColor() => _hexToColor(onSurfaceVariantColor);
  Color getDisabledColor() => _hexToColor(disabledColor);
  Color getHintColor() => _hexToColor(hintColor);

  // Get theme mode - Existing Method
  ThemeMode getThemeMode() {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  // Static helper method - Existing Method
  static Color _hexToColor(String hex) {
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7)
      buffer.write('ff'); // Ensure alpha if not present
    buffer.write(hex.replaceFirst('#', ''));
    if (buffer.length == 6) {
      // Prepend 'ff' if still only 6 chars (e.g. user entered #RRGGBB)
      final temp = buffer.toString();
      buffer.clear();
      buffer.write('ff');
      buffer.write(temp);
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

@freezed
abstract class ProfileCustomization with _$ProfileCustomization {
  const factory ProfileCustomization({
    // Background customization
    String? backgroundImageUrl,
    String? backgroundColor,
    @Default('solid')
    String backgroundType, // 'solid', 'gradient', 'image', 'animated'
    @Default([]) List<String> gradientColors,
    @Default(0.0) double gradientAngle,

    // Layout customization
    @Default('classic')
    String layout, // 'classic', 'modern', 'minimal', 'creative'
    @Default(true) bool showCoverImage,
    @Default(true) bool showProfileImage,
    @Default('circle')
    String profileImageShape, // 'circle', 'square', 'rounded'
    @Default(80.0) double profileImageSize,

    // Content sections
    @Default(true) bool showBio,
    @Default(true) bool showStats,
    @Default(true) bool showPosts,
    @Default(true) bool showAboutSection,

    // Special effects
    @Default(false) bool enableParticles,
    @Default(false) bool enableAnimatedBackground,
    @Default(false) bool enableCustomCursor,
    String? customCursorUrl,

    // Custom CSS (MySpace-style)
    String? customCSS,

    // Music player
    @Default(false) bool enableMusicPlayer,
    String? musicUrl,
    @Default(false) bool autoPlayMusic,
    @Default(0.5) double musicVolume,

    // Profile card styling
    @Default(16.0) double cardBorderRadius,
    @Default(2.0) double cardElevation,
    String? cardBackgroundColor,
    @Default(0.95) double cardOpacity,

    // Custom widgets
    @Default([]) List<CustomWidget> customWidgets,
  }) = _ProfileCustomization;

  factory ProfileCustomization.fromJson(Map<String, dynamic> json) =>
      _$ProfileCustomizationFromJson(json);
}

@freezed
abstract class ComponentStyles with _$ComponentStyles {
  const factory ComponentStyles({
    // Button styling
    @Default(ButtonStyle()) ButtonStyle primaryButton,
    @Default(ButtonStyle()) ButtonStyle secondaryButton,

    // Card styling
    @Default(16.0) double cardBorderRadius,
    @Default(2.0) double cardElevation,
    @Default(false) bool cardOutline,
    @Default('#E0E0E0') String cardOutlineColor,

    // Input field styling
    @Default(InputFieldStyle()) InputFieldStyle inputField,

    // Navigation bar styling
    @Default(NavigationStyle()) NavigationStyle navigation,

    // Dialog styling
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
    @Default('rounded') String shape, // 'rounded', 'pill', 'square'
    @Default(false) bool enableRipple,
    String? rippleColor,
    @Default('w500') String fontWeight, // 'w100' through 'w900'
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
    @Default('outline')
    String borderType, // 'outline', 'underline', 'none', 'filled'
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
    @Default('bottom') String type, // 'bottom', 'side', 'floating'
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
    @Default('comfortable')
    String density, // 'compact', 'comfortable', 'spacious'
    @Default(8.0) double defaultSpacing,
    @Default(16.0) double defaultPadding,
    @Default(false) bool useCompactPosts,
    @Default(false) bool useListLayout,
    @Default(2) int gridColumns,
    @Default(false) bool centerContent,
    @Default(1200.0) double maxContentWidth,
    @Default(true) bool showFloatingButtons,
    @Default('bottomRight')
    String
        floatingButtonPosition, // 'bottomRight', 'bottomLeft', 'bottomCenter'
  }) = _LayoutPreferences;

  factory LayoutPreferences.fromJson(Map<String, dynamic> json) =>
      _$LayoutPreferencesFromJson(json);
}

@freezed
abstract class AnimationSettings with _$AnimationSettings {
  const factory AnimationSettings({
    @Default(true) bool enableAnimations,
    @Default('normal') String speed, // 'slow', 'normal', 'fast', 'instant'
    @Default(true) bool enablePageTransitions,
    @Default('fade')
    String pageTransitionType, // 'fade', 'slide', 'scale', 'rotation'
    @Default(true) bool enableHoverEffects,
    @Default(true) bool enableScrollAnimations,
    @Default(false) bool enableParallaxEffects,
    @Default(true) bool enableLoadingAnimations,
    @Default('easeInOut')
    String defaultCurve, // Standard curve names as strings
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
    @Default('optimal')
    String renderingStyle, // 'optimal', 'speed', 'precision'
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

// Helper extension to convert string values to Flutter types
extension UICustomizationHelpers on UICustomizationModel {
  // Convert font weight string to FontWeight
  FontWeight getFontWeight(String weight) {
    switch (weight) {
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

  // Convert curve string to Curve
  Curve getCurve(String curveName) {
    switch (curveName) {
      case 'linear':
        return Curves.linear;
      case 'ease':
        return Curves.ease;
      case 'easeIn':
        return Curves.easeIn;
      case 'easeOut':
        return Curves.easeOut;
      case 'easeInOut':
        return Curves.easeInOut;
      case 'fastOutSlowIn':
        return Curves.fastOutSlowIn;
      case 'bounceIn':
        return Curves.bounceIn;
      case 'bounceOut':
        return Curves.bounceOut;
      case 'bounceInOut':
        return Curves.bounceInOut;
      case 'elasticIn':
        return Curves.elasticIn;
      case 'elasticOut':
        return Curves.elasticOut;
      case 'elasticInOut':
        return Curves.elasticInOut;
      default:
        return Curves.easeInOut;
    }
  }
}
