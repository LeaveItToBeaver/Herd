import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/customization/data/models/ui_customization_model.dart';
import '../../data/repositories/ui_customization_repository.dart';
import '../../../auth/view/providers/auth_provider.dart';

Color _hexToColor(String hex) {
  final buffer = StringBuffer();
  if (hex.length == 6 || hex.length == 7) buffer.write('ff');
  buffer.write(hex.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

// Stream provider for real-time UI customization updates
final uiCustomizationStreamProvider =
    StreamProvider<UICustomizationModel?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) return Stream.value(null);

  final repository = ref.watch(uiCustomizationRepositoryProvider);
  return repository.streamUserCustomization(auth.uid);
});

// State notifier for managing UI customization
class UICustomizationNotifier
    extends StateNotifier<AsyncValue<UICustomizationModel?>> {
  final UICustomizationRepository _repository;
  final String? _userId;
  final Ref _ref;

  UICustomizationNotifier(this._repository, this._userId, this._ref)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _loadCustomization();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> _loadCustomization() async {
    try {
      if (_userId == null) {
        state = const AsyncValue.data(null);
        return;
      }

      final customization = await _repository.getUserCustomization(_userId);
      state = AsyncValue.data(customization);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  // Update app theme
  Future<void> updateAppTheme(AppThemeSettings theme) async {
    if (_userId == null) return;

    try {
      await _repository.updateCustomization(_userId, {
        'appTheme': theme.toJson(),
      });

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error updating app theme: $e');
    }
  }

  // Update profile customization
  Future<void> updateProfileCustomization(
      ProfileCustomization customization) async {
    if (_userId == null) return;

    try {
      await _repository.updateCustomization(_userId, {
        'profileCustomization': customization.toJson(),
      });

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error updating profile customization: $e');
    }
  }

  // Update component styles
  Future<void> updateComponentStyles(ComponentStyles styles) async {
    if (_userId == null) return;

    try {
      await _repository.updateCustomization(_userId, {
        'componentStyles': styles.toJson(),
      });

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error updating component styles: $e');
    }
  }

  // Update layout preferences
  Future<void> updateLayoutPreferences(LayoutPreferences preferences) async {
    if (_userId == null) return;

    try {
      await _repository.updateCustomization(_userId, {
        'layoutPreferences': preferences.toJson(),
      });

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error updating layout preferences: $e');
    }
  }

  // Update typography settings
  Future<void> updateTypography(TypographySettings typography) async {
    if (_userId == null) return;

    try {
      await _repository.updateCustomization(_userId, {
        'typography': typography.toJson(),
      });

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error updating typography: $e');
    }
  }

  // Update animation settings
  Future<void> updateAnimationSettings(AnimationSettings animations) async {
    if (_userId == null) return;

    try {
      await _repository.updateCustomization(_userId, {
        'animationSettings': animations.toJson(),
      });

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error updating animation settings: $e');
    }
  }

  // Apply preset theme
  Future<void> applyPreset(String presetId) async {
    if (_userId == null) return;

    try {
      await _repository.applyPresetTheme(_userId, presetId);

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error applying preset: $e');
    }
  }

  // Reset to defaults
  Future<void> resetToDefaults() async {
    if (_userId == null) return;

    try {
      await _repository.resetToDefault(_userId);

      // Refresh state
      await _loadCustomization();
    } catch (e) {
      debugPrint('Error resetting to defaults: $e');
    }
  }

  // Quick color update (for real-time color picker)
  void updateColorInstant(String colorKey, Color color) {
    final current = state.value;
    if (current == null) return;

    // Create a copy with the updated color
    final hexColor = '#${color.value.toRadixString(16).substring(2)}';
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
    final current = state.value;
    if (current == null || _userId == null) return;

    await updateAppTheme(current.appTheme);
  }
}

// Main provider for UI customization
final uiCustomizationProvider = StateNotifierProvider<UICustomizationNotifier,
    AsyncValue<UICustomizationModel?>>((ref) {
  final auth = ref.watch(authProvider);
  final repository = ref.watch(uiCustomizationRepositoryProvider);

  return UICustomizationNotifier(repository, auth?.uid, ref);
});

// Computed provider for current theme data
final currentThemeProvider = Provider<ThemeData>((ref) {
  final customization = ref.watch(uiCustomizationProvider).value;

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
      surfaceContainerHighest: appTheme.getSurfaceColor().withOpacity(0.8),
      onSurfaceVariant: appTheme.getSecondaryTextColor(),
      outline: appTheme.getSecondaryTextColor().withOpacity(0.5),
    ),
    scaffoldBackgroundColor: appTheme.getBackgroundColor(),

    // Apply component styles
    elevatedButtonTheme: _buildElevatedButtonTheme(
        customization.componentStyles.primaryButton, appTheme),
    outlinedButtonTheme: _buildOutlinedButtonTheme(
        customization.componentStyles.secondaryButton, appTheme),

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

    textTheme: _buildTextTheme(customization.typography, appTheme),

    appBarTheme: AppBarTheme(
      backgroundColor: appTheme.getSurfaceColor(),
      foregroundColor: appTheme.getTextColor(),
      elevation: appTheme.enableShadows ? 2 : 0,
    ),

    dialogTheme: DialogThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
            customization.componentStyles.dialogBorderRadius),
      ),
    ),
  );
});

// Helper function to determine contrasting color
Color _getOnColor(Color color) {
  return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
}

// Build elevated button theme
ElevatedButtonThemeData _buildElevatedButtonTheme(
    ButtonStyle buttonStyle, AppThemeSettings appTheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      shape: _getButtonShape(buttonStyle),
      elevation: buttonStyle.elevation,
      padding: EdgeInsets.symmetric(
        horizontal: buttonStyle.horizontalPadding,
        vertical: buttonStyle.verticalPadding,
      ),
      textStyle: TextStyle(
        fontSize: buttonStyle.fontSize,
        fontWeight: _getFontWeight(buttonStyle.fontWeight),
        letterSpacing: buttonStyle.letterSpacing,
      ),
    ),
  );
}

// Build outlined button theme
OutlinedButtonThemeData _buildOutlinedButtonTheme(
    ButtonStyle buttonStyle, AppThemeSettings appTheme) {
  return OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      shape: _getButtonShape(buttonStyle),
      padding: EdgeInsets.symmetric(
        horizontal: buttonStyle.horizontalPadding,
        vertical: buttonStyle.verticalPadding,
      ),
      textStyle: TextStyle(
        fontSize: buttonStyle.fontSize,
        fontWeight: _getFontWeight(buttonStyle.fontWeight),
        letterSpacing: buttonStyle.letterSpacing,
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

// Build text theme
TextTheme _buildTextTheme(
    TypographySettings typography, AppThemeSettings appTheme) {
  final baseTextStyle = TextStyle(
    fontFamily: typography.primaryFont,
    letterSpacing: typography.letterSpacing,
    height: typography.lineHeightMultiplier,
    color: appTheme.getTextColor(),
  );

  return TextTheme(
    displayLarge:
        baseTextStyle.copyWith(fontSize: 96 * typography.fontScaleFactor),
    displayMedium:
        baseTextStyle.copyWith(fontSize: 60 * typography.fontScaleFactor),
    displaySmall:
        baseTextStyle.copyWith(fontSize: 48 * typography.fontScaleFactor),
    headlineMedium:
        baseTextStyle.copyWith(fontSize: 34 * typography.fontScaleFactor),
    headlineSmall:
        baseTextStyle.copyWith(fontSize: 24 * typography.fontScaleFactor),
    titleLarge:
        baseTextStyle.copyWith(fontSize: 20 * typography.fontScaleFactor),
    bodyLarge:
        baseTextStyle.copyWith(fontSize: 16 * typography.fontScaleFactor),
    bodyMedium:
        baseTextStyle.copyWith(fontSize: 14 * typography.fontScaleFactor),
    labelLarge:
        baseTextStyle.copyWith(fontSize: 14 * typography.fontScaleFactor),
  );
}
