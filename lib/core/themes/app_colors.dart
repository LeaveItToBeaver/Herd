import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand colors
  static const Color primary =
      Color.fromARGB(255, 167, 61, 254); // Indigo accent
  static const Color primaryDark =
      Color.fromARGB(255, 95, 66, 129); // Darker shade
  static const Color primaryLight =
      Color.fromARGB(255, 167, 129, 255); // Lighter shade

  // Secondary colors
  static const Color secondary = Color(0xFF00C853); // Green accent
  static const Color secondaryDark = Color(0xFF009624); // Darker shade
  static const Color secondaryLight = Color(0xFF5EFC82); // Lighter shade

  // MaterialColor swatches for theme compatibility
  static const MaterialColor primarySwatch = MaterialColor(
    0xFFA73DFE, // Primary color value
    <int, Color>{
      50: Color(0xFFF3E5FE),
      100: Color(0xFFE1BEFE),
      200: Color(0xFFCD93FE),
      300: Color(0xFFB968FE),
      400: Color(0xFFA947FE),
      500: Color(0xFFA73DFE), // Primary color
      600: Color(0xFF9F37F6),
      700: Color(0xFF952FED),
      800: Color(0xFF8B27E4),
      900: Color(0xFF7919D7),
    },
  );

  static const MaterialColor secondarySwatch = MaterialColor(
    0xFF00C853, // Secondary color value
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF00C853), // Secondary color
      600: Color(0xFF00B74A),
      700: Color(0xFF00A640),
      800: Color(0xFF009437),
      900: Color(0xFF007B27),
    },
  );

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);

  // Surface colors
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Error colors
  static const Color error = Color(0xFFD32F2F);
  static const Color errorDark = Color(0xFFB71C1C);

  // Text colors
  static const Color textPrimaryLight = Color(0xFF212121);
  static const Color textSecondaryLight = Color(0xFF757575);
  static const Color textPrimaryDark = Color(0xFFE0E0E0);
  static const Color textSecondaryDark = Color(0xFF9E9E9E);

  // Create light theme color scheme
  static ColorScheme lightColorScheme = const ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: Color(0xFFE8EAFF),
    onPrimaryContainer: Color(0xFF001458),
    secondary: secondary,
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFB9F6CA),
    onSecondaryContainer: Color(0xFF002411),
    error: error,
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: surfaceLight,
    onSurface: textPrimaryLight,
    surfaceContainerHighest: Color(0xFFE7E0EC),
    onSurfaceVariant: Color(0xFF49454F),
    outline: Color(0xFF79747E),
  );

  // Create dark theme color scheme
  static ColorScheme darkColorScheme = const ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: Color(0xFF002984),
    primaryContainer: Color(0xFF1A237E),
    onPrimaryContainer: Color(0xFFD1D7FF),
    secondary: secondaryLight,
    onSecondary: Color(0xFF005D27),
    secondaryContainer: Color(0xFF007E38),
    onSecondaryContainer: Color(0xFFADFFBE),
    error: Color(0xFFCF6679),
    onError: Color(0xFF690005),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: surfaceDark,
    onSurface: textPrimaryDark,
    surfaceContainerHighest: Color(0xFF49454F),
    onSurfaceVariant: Color(0xFFCAC4D0),
    outline: Color(0xFF938F99),
  );

  /// Creates a MaterialColor from any Color
  /// Useful for dynamic theming when you need to generate a MaterialColor swatch
  static MaterialColor createMaterialColor(Color color) {
    final int red = (color.r * 255.0).round() & 0xff;
    final int green = (color.g * 255.0).round() & 0xff;
    final int blue = (color.b * 255.0).round() & 0xff;
    final int alpha = (color.a * 255.0).round() & 0xff;

    final Map<int, Color> swatch = <int, Color>{
      50: Color.fromARGB(
          alpha,
          (red + (255 - red) * 0.9).round(),
          (green + (255 - green) * 0.9).round(),
          (blue + (255 - blue) * 0.9).round()),
      100: Color.fromARGB(
          alpha,
          (red + (255 - red) * 0.8).round(),
          (green + (255 - green) * 0.8).round(),
          (blue + (255 - blue) * 0.8).round()),
      200: Color.fromARGB(
          alpha,
          (red + (255 - red) * 0.6).round(),
          (green + (255 - green) * 0.6).round(),
          (blue + (255 - blue) * 0.6).round()),
      300: Color.fromARGB(
          alpha,
          (red + (255 - red) * 0.4).round(),
          (green + (255 - green) * 0.4).round(),
          (blue + (255 - blue) * 0.4).round()),
      400: Color.fromARGB(
          alpha,
          (red + (255 - red) * 0.2).round(),
          (green + (255 - green) * 0.2).round(),
          (blue + (255 - blue) * 0.2).round()),
      500: Color.fromARGB(alpha, red, green, blue), // Base color
      600: Color.fromARGB(alpha, (red * 0.9).round(), (green * 0.9).round(),
          (blue * 0.9).round()),
      700: Color.fromARGB(alpha, (red * 0.8).round(), (green * 0.8).round(),
          (blue * 0.8).round()),
      800: Color.fromARGB(alpha, (red * 0.7).round(), (green * 0.7).round(),
          (blue * 0.7).round()),
      900: Color.fromARGB(alpha, (red * 0.6).round(), (green * 0.6).round(),
          (blue * 0.6).round()),
    };

    return MaterialColor(color.toARGB32(), swatch);
  }
}
