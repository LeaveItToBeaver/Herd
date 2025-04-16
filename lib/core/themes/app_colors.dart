import 'package:flutter/material.dart';

class AppTheme {
  // Primary brand colors
  static const Color primary = Color(0xFF3D5AFE); // Indigo accent
  static const Color primaryDark = Color(0xFF0031CA); // Darker shade
  static const Color primaryLight = Color(0xFF8187FF); // Lighter shade

  // Secondary colors
  static const Color secondary = Color(0xFF00C853); // Green accent
  static const Color secondaryDark = Color(0xFF009624); // Darker shade
  static const Color secondaryLight = Color(0xFF5EFC82); // Lighter shade

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
}
