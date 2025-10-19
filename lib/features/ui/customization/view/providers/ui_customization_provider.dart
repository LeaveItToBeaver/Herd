import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/data/repositories/ui_customization_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'ui_customization_provider.g.dart';

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// Stream provider for real-time UI customization updates
@riverpod
Stream<UICustomizationModel?> uiCustomizationStream(Ref ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) return Stream.value(null);

  final repository = ref.watch(uiCustomizationRepositoryProvider);
  return repository.streamUserCustomization(auth.uid);
}

// State notifier for managing UI customization
@riverpod
class UICustomization extends _$UICustomization {
  @override
  Future<UICustomizationModel?> build() async {
    final auth = ref.watch(authProvider);
    if (auth == null) return null;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      final customization = await repository.getUserCustomization(auth.uid);
      return customization;
    } catch (e) {
      // Log error but return null instead of throwing
      debugPrint('Error loading UI customization: $e');
      return null;
    }
  }

  // Update app theme
  Future<void> updateAppTheme(AppThemeSettings theme) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.updateCustomization(auth.uid, {
        'appTheme': theme.toJson(),
      });

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating app theme: $e');
    }
  }

  // Update profile customization
  Future<void> updateProfileCustomization(
      ProfileCustomization customization) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.updateCustomization(auth.uid, {
        'profileCustomization': customization.toJson(),
      });

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating profile customization: $e');
    }
  }

  // Update component styles
  Future<void> updateComponentStyles(ComponentStyles styles) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.updateCustomization(auth.uid, {
        'componentStyles': styles.toJson(),
      });

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating component styles: $e');
    }
  }

  // Update layout preferences
  Future<void> updateLayoutPreferences(LayoutPreferences preferences) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.updateCustomization(auth.uid, {
        'layoutPreferences': preferences.toJson(),
      });

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating layout preferences: $e');
    }
  }

  // Update typography settings
  Future<void> updateTypography(TypographySettings typography) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.updateCustomization(auth.uid, {
        'typography': typography.toJson(),
      });

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating typography: $e');
    }
  }

  // Update animation settings
  Future<void> updateAnimationSettings(AnimationSettings animations) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.updateCustomization(auth.uid, {
        'animationSettings': animations.toJson(),
      });

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error updating animation settings: $e');
    }
  }

  // Apply preset theme
  Future<void> applyPreset(String presetId) async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.applyPresetTheme(auth.uid, presetId);

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error applying preset: $e');
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    final auth = ref.read(authProvider);
    if (auth == null) return;

    final repository = ref.read(uiCustomizationRepositoryProvider);
    try {
      await repository.resetToDefault(auth.uid);

      if (!ref.mounted) return;
      // Refresh state
      ref.invalidateSelf();
    } catch (e) {
      debugPrint('Error resetting to defaults: $e');
    }
  }

  // Quick color update (for real-time color picker)
  void updateColorInstant(String colorKey, Color color) async {
    final current = await future;
    if (current == null) return;

    // Create a copy with the updated color
    final hexColor =
        '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final updatedTheme = current.appTheme.copyWith(
      primaryColor:
          colorKey == 'primary' ? hexColor : current.appTheme.primaryColor,
      secondaryColor:
          colorKey == 'secondary' ? hexColor : current.appTheme.secondaryColor,
      backgroundColor: colorKey == 'background'
          ? hexColor
          : current.appTheme.backgroundColor,
      surfaceColor:
          colorKey == 'surface' ? hexColor : current.appTheme.surfaceColor,
      textColor: colorKey == 'text' ? hexColor : current.appTheme.textColor,
    );

    state = AsyncValue.data(current.copyWith(appTheme: updatedTheme));
  }

  // Commit color changes to Firebase
  Future<void> commitColorChanges() async {
    final current = await future;
    if (current == null) return;

    await updateAppTheme(current.appTheme);
  }
}

// Computed provider for current theme data
@riverpod
ThemeData currentTheme(Ref ref) {
  final customization = ref.watch(uICustomizationProvider).value;

  if (customization == null) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    );
  }

  final appTheme = customization.appTheme;
  final isDark = appTheme.getThemeMode() == ThemeMode.dark ||
      (appTheme.getThemeMode() == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  // Create consistent TextStyles that can be safely interpolated
  final baseTextStyle = TextStyle(
    inherit: true, // Ensure all TextStyles have the same inherit value
    fontFamily: customization.typography.primaryFont,
    letterSpacing: customization.typography.letterSpacing,
    height: customization.typography.lineHeightMultiplier,
    color: appTheme.getTextColor(),
  );

  return ThemeData(
    useMaterial3: appTheme.useMaterial3,
    brightness: isDark ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: appTheme.getPrimaryColor(),
      onPrimary: _getOnColor(appTheme.getPrimaryColor()),
      secondary: appTheme.getSecondaryColor(),
      onSecondary: _getOnColor(appTheme.getSecondaryColor()),
      error: appTheme.getErrorColor(),
      onError: Colors.white,
      surface: appTheme.getSurfaceColor(),
      onSurface: appTheme.getTextColor(),
      surfaceContainerHighest:
          appTheme.getSurfaceColor().withValues(alpha: 0.8),
      onSurfaceVariant: appTheme.getSecondaryTextColor(),
      outline: appTheme.getSecondaryTextColor().withValues(alpha: 0.5),
    ),
    scaffoldBackgroundColor: appTheme.getBackgroundColor(),

    // Apply component styles
    elevatedButtonTheme: _buildElevatedButtonTheme(
        customization.componentStyles.primaryButton, appTheme, baseTextStyle),
    outlinedButtonTheme: _buildOutlinedButtonTheme(
        customization.componentStyles.secondaryButton, appTheme, baseTextStyle),

    // Apply card theme
    cardTheme: CardThemeData(
      elevation: customization.componentStyles.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            customization.componentStyles.cardBorderRadius),
        side: customization.componentStyles.cardOutline
            ? BorderSide(
                color:
                    _hexToColor(customization.componentStyles.cardOutlineColor),
                width: 1,
              )
            : BorderSide.none,
      ),
    ),

    inputDecorationTheme: _buildInputDecorationTheme(
        customization.componentStyles.inputField, appTheme),

    textTheme:
        _buildTextTheme(customization.typography, appTheme, baseTextStyle),

    appBarTheme: AppBarTheme(
      backgroundColor: appTheme.getSurfaceColor(),
      foregroundColor: appTheme.getTextColor(),
      elevation: appTheme.enableShadows ? 2 : 0,
      titleTextStyle: baseTextStyle.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),

    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            customization.componentStyles.dialogBorderRadius),
      ),
    ),
  );
}

// Helper function to determine contrasting color
Color _getOnColor(Color color) {
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

// Build elevated button theme with consistent TextStyle
ElevatedButtonThemeData _buildElevatedButtonTheme(ButtonStyle buttonStyle,
    AppThemeSettings appTheme, TextStyle baseTextStyle) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: _getButtonShape(buttonStyle),
      elevation: buttonStyle.elevation,
      padding: EdgeInsets.symmetric(
        horizontal: buttonStyle.horizontalPadding,
        vertical: buttonStyle.verticalPadding,
      ),
      textStyle: baseTextStyle.copyWith(
        fontSize: buttonStyle.fontSize,
        fontWeight: _getFontWeight(buttonStyle.fontWeight),
        letterSpacing: buttonStyle.letterSpacing,
        inherit: true, // Ensure consistent inherit value
      ),
    ),
  );
}

// Build outlined button theme with consistent TextStyle
OutlinedButtonThemeData _buildOutlinedButtonTheme(ButtonStyle buttonStyle,
    AppThemeSettings appTheme, TextStyle baseTextStyle) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: _getButtonShape(buttonStyle),
      padding: EdgeInsets.symmetric(
        horizontal: buttonStyle.horizontalPadding,
        vertical: buttonStyle.verticalPadding,
      ),
      textStyle: baseTextStyle.copyWith(
        fontSize: buttonStyle.fontSize,
        fontWeight: _getFontWeight(buttonStyle.fontWeight),
        letterSpacing: buttonStyle.letterSpacing,
        inherit: true, // Ensure consistent inherit value
      ),
    ),
  );
}

// Get button shape based on style
OutlinedBorder _getButtonShape(ButtonStyle buttonStyle) {
  switch (buttonStyle.shape) {
    case 'rounded':
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
      );
    case 'pill':
      return const StadiumBorder();
    case 'square':
      return const RoundedRectangleBorder();
    default:
      return RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(buttonStyle.borderRadius),
      );
  }
}

// Get font weight from string
FontWeight _getFontWeight(String weight) {
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

// Build input decoration theme
InputDecorationTheme _buildInputDecorationTheme(
    InputFieldStyle inputStyle, AppThemeSettings appTheme) {
  return InputDecorationTheme(
    filled: inputStyle.filled,
    fillColor: inputStyle.fillColor != null
        ? _hexToColor(inputStyle.fillColor!)
        : null,
    contentPadding: EdgeInsets.all(inputStyle.contentPadding),
    border: _getInputBorder(inputStyle),
    enabledBorder: _getInputBorder(inputStyle),
    focusedBorder: _getInputBorder(inputStyle, focused: true),
    floatingLabelBehavior: inputStyle.enableFloatingLabel
        ? FloatingLabelBehavior.auto
        : FloatingLabelBehavior.never,
  );
}

// Get input border based on style
InputBorder _getInputBorder(InputFieldStyle inputStyle,
    {bool focused = false}) {
  switch (inputStyle.borderType) {
    case 'outline':
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputStyle.borderRadius),
        borderSide: BorderSide(
          width: inputStyle.borderWidth * (focused ? 2 : 1),
        ),
      );
    case 'underline':
      return UnderlineInputBorder(
        borderSide: BorderSide(
          width: inputStyle.borderWidth * (focused ? 2 : 1),
        ),
      );
    case 'none':
      return InputBorder.none;
    case 'filled':
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputStyle.borderRadius),
        borderSide: BorderSide.none,
      );
    default:
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputStyle.borderRadius),
      );
  }
}

// Build text theme with consistent inherit values
TextTheme _buildTextTheme(TypographySettings typography,
    AppThemeSettings appTheme, TextStyle baseTextStyle) {
  final consistentBaseStyle = baseTextStyle.copyWith(inherit: true);

  final textTheme = TextTheme(
    displayLarge: baseTextStyle.copyWith(
      fontSize: 96 * typography.fontScaleFactor,
      inherit: true,
    ),
    displayMedium: baseTextStyle.copyWith(
      fontSize: 60 * typography.fontScaleFactor,
      inherit: true,
    ),
    displaySmall: baseTextStyle.copyWith(
      fontSize: 48 * typography.fontScaleFactor,
      inherit: true,
    ),
    headlineMedium: baseTextStyle.copyWith(
      fontSize: 34 * typography.fontScaleFactor,
      inherit: true,
    ),
    headlineSmall: baseTextStyle.copyWith(
      fontSize: 24 * typography.fontScaleFactor,
      inherit: true,
    ),
    titleLarge: baseTextStyle.copyWith(
      fontSize: 20 * typography.fontScaleFactor,
      inherit: true,
    ),
    bodyLarge: baseTextStyle.copyWith(
      fontSize: 16 * typography.fontScaleFactor,
      inherit: true,
    ),
    bodyMedium: baseTextStyle.copyWith(
      fontSize: 14 * typography.fontScaleFactor,
      inherit: true,
    ),
    labelLarge: baseTextStyle.copyWith(
      fontSize: 14 * typography.fontScaleFactor,
      inherit: true,
    ),
  );

  return textTheme.apply(
    displayColor: appTheme.getTextColor(),
    bodyColor: appTheme.getTextColor(),
  );
}
