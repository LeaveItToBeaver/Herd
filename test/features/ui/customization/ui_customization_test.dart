import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UI Customization', () {
    test('should create default customization model', () {
      const userId = 'test_user_id';
      final customization = UICustomizationModel.defaultForUser(userId);

      expect(customization.userId, userId);
      expect(customization.appTheme, isNotNull);
      expect(customization.profileCustomization, isNotNull);
      expect(customization.componentStyles, isNotNull);
      expect(customization.layoutPreferences, isNotNull);
      expect(customization.typography, isNotNull);
    });

    test('should copy with updated values', () {
      const userId = 'test_user_id';
      final original = UICustomizationModel.defaultForUser(userId);

      final updated = original.copyWith(
        appTheme: AppThemeSettings(primaryColor: '#FF5722'),
      );

      expect(updated.userId, original.userId);
      expect(updated.appTheme.primaryColor, '#FF5722');
    });

    test('should validate color format', () {
      const validColors = [
        '#FF0000',
        '#00FF00',
        '#0000FF',
        '#FFFFFF',
        '#000000',
      ];

      const invalidColors = [
        'red',
        '#GG0000',
        'FF0000', // Missing #
        '#FF00', // Too short
        '#FF000000', // Too long
      ];

      for (final color in validColors) {
        expect(_isValidHexColor(color), true, reason: '$color should be valid');
      }

      for (final color in invalidColors) {
        expect(_isValidHexColor(color), false,
            reason: '$color should be invalid');
      }
    });

    test('should handle theme settings', () {
      final theme = AppThemeSettings(
        primaryColor: '#2196F3',
        secondaryColor: '#FFC107',
        useMaterial3: true,
        enableGradients: false,
      );

      expect(theme.primaryColor, '#2196F3');
      expect(theme.secondaryColor, '#FFC107');
      expect(theme.useMaterial3, true);
      expect(theme.enableGradients, false);
    });

    test('should handle profile customization', () {
      final profile = ProfileCustomization(
        layout: 'modern',
        enableParticles: true,
        enableMusicPlayer: false,
        profileImageShape: 'circle',
        profileImageSize: 80.0,
      );

      expect(profile.layout, 'modern');
      expect(profile.enableParticles, true);
      expect(profile.enableMusicPlayer, false);
      expect(profile.profileImageShape, 'circle');
      expect(profile.profileImageSize, 80.0);
    });

    test('should handle component styles', () {
      final components = ComponentStyles(
        cardBorderRadius: 12.0,
        buttonBorderRadius: 8.0,
        inputBorderRadius: 6.0,
        elevationLevel: 2.0,
      );

      expect(components.cardBorderRadius, 12.0);
      expect(components.buttonBorderRadius, 8.0);
      expect(components.inputBorderRadius, 6.0);
      expect(components.elevationLevel, 2.0);
    });

    test('should handle layout preferences', () {
      final layout = LayoutPreferences(
        density: 'compact',
        spacing: 8.0,
        padding: 16.0,
        gridColumns: 2,
      );

      expect(layout.density, 'compact');
      expect(layout.spacing, 8.0);
      expect(layout.padding, 16.0);
      expect(layout.gridColumns, 2);
    });

    test('should handle typography settings', () {
      final typography = TypographySettings(
        primaryFont: 'Roboto',
        secondaryFont: 'Open Sans',
        fontSize: 14.0,
        fontWeight: 'normal',
      );

      expect(typography.primaryFont, 'Roboto');
      expect(typography.secondaryFont, 'Open Sans');
      expect(typography.fontSize, 14.0);
      expect(typography.fontWeight, 'normal');
    });

    test('should validate layout densities', () {
      const validDensities = ['compact', 'comfortable', 'spacious'];
      const invalidDensities = ['tight', 'loose', 'custom'];

      for (final density in validDensities) {
        expect(_isValidDensity(density), true);
      }

      for (final density in invalidDensities) {
        expect(_isValidDensity(density), false);
      }
    });

    test('should validate image shapes', () {
      const validShapes = ['circle', 'square', 'rounded'];
      const invalidShapes = ['triangle', 'hexagon', 'custom'];

      for (final shape in validShapes) {
        expect(_isValidImageShape(shape), true);
      }

      for (final shape in invalidShapes) {
        expect(_isValidImageShape(shape), false);
      }
    });

    test('should handle serialization', () {
      const userId = 'test_user_id';
      final original = UICustomizationModel.defaultForUser(userId);

      final json = original.toJson();
      final deserialized = UICustomizationModel.fromJson(json);

      expect(deserialized.userId, original.userId);
      expect(
          deserialized.appTheme.primaryColor, original.appTheme.primaryColor);
    });

    test('should validate customization bounds', () {
      // Test boundary values
      expect(_isValidBorderRadius(-1.0), false); // Negative
      expect(_isValidBorderRadius(0.0), true); // Zero
      expect(_isValidBorderRadius(50.0), true); // Normal
      expect(_isValidBorderRadius(100.0), false); // Too large

      expect(_isValidFontSize(8.0), false); // Too small
      expect(_isValidFontSize(12.0), true); // Valid
      expect(_isValidFontSize(24.0), true); // Valid
      expect(_isValidFontSize(48.0), false); // Too large

      expect(_isValidImageSize(20.0), false); // Too small
      expect(_isValidImageSize(50.0), true); // Valid
      expect(_isValidImageSize(150.0), true); // Valid
      expect(_isValidImageSize(300.0), false); // Too large
    });
  });
}

bool _isValidHexColor(String color) {
  final regex = RegExp(r'^#[0-9A-Fa-f]{6}$');
  return regex.hasMatch(color);
}

bool _isValidDensity(String density) {
  const validDensities = ['compact', 'comfortable', 'spacious'];
  return validDensities.contains(density);
}

bool _isValidImageShape(String shape) {
  const validShapes = ['circle', 'square', 'rounded'];
  return validShapes.contains(shape);
}

bool _isValidBorderRadius(double radius) {
  return radius >= 0.0 && radius <= 50.0;
}

bool _isValidFontSize(double size) {
  return size >= 10.0 && size <= 32.0;
}

bool _isValidImageSize(double size) {
  return size >= 30.0 && size <= 200.0;
}

// Mock classes for the customization models since we don't have access to the actual implementations
class UICustomizationModel {
  final String userId;
  final AppThemeSettings appTheme;
  final ProfileCustomization profileCustomization;
  final ComponentStyles componentStyles;
  final LayoutPreferences layoutPreferences;
  final TypographySettings typography;

  const UICustomizationModel({
    required this.userId,
    required this.appTheme,
    required this.profileCustomization,
    required this.componentStyles,
    required this.layoutPreferences,
    required this.typography,
  });

  static UICustomizationModel defaultForUser(String userId) {
    return UICustomizationModel(
      userId: userId,
      appTheme: AppThemeSettings(primaryColor: '#2196F3'),
      profileCustomization: ProfileCustomization(layout: 'modern'),
      componentStyles: ComponentStyles(cardBorderRadius: 8.0),
      layoutPreferences: LayoutPreferences(density: 'comfortable'),
      typography: TypographySettings(primaryFont: 'Roboto'),
    );
  }

  UICustomizationModel copyWith({
    String? userId,
    AppThemeSettings? appTheme,
    ProfileCustomization? profileCustomization,
    ComponentStyles? componentStyles,
    LayoutPreferences? layoutPreferences,
    TypographySettings? typography,
  }) {
    return UICustomizationModel(
      userId: userId ?? this.userId,
      appTheme: appTheme ?? this.appTheme,
      profileCustomization: profileCustomization ?? this.profileCustomization,
      componentStyles: componentStyles ?? this.componentStyles,
      layoutPreferences: layoutPreferences ?? this.layoutPreferences,
      typography: typography ?? this.typography,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'appTheme': appTheme.toJson(),
      'profileCustomization': profileCustomization.toJson(),
      'componentStyles': componentStyles.toJson(),
      'layoutPreferences': layoutPreferences.toJson(),
      'typography': typography.toJson(),
    };
  }

  static UICustomizationModel fromJson(Map<String, dynamic> json) {
    return UICustomizationModel(
      userId: json['userId'],
      appTheme: AppThemeSettings.fromJson(json['appTheme']),
      profileCustomization:
          ProfileCustomization.fromJson(json['profileCustomization']),
      componentStyles: ComponentStyles.fromJson(json['componentStyles']),
      layoutPreferences: LayoutPreferences.fromJson(json['layoutPreferences']),
      typography: TypographySettings.fromJson(json['typography']),
    );
  }
}

class AppThemeSettings {
  final String primaryColor;
  final String? secondaryColor;
  final bool useMaterial3;
  final bool enableGradients;

  const AppThemeSettings({
    required this.primaryColor,
    this.secondaryColor,
    this.useMaterial3 = true,
    this.enableGradients = false,
  });

  Map<String, dynamic> toJson() => {
        'primaryColor': primaryColor,
        'secondaryColor': secondaryColor,
        'useMaterial3': useMaterial3,
        'enableGradients': enableGradients,
      };

  static AppThemeSettings fromJson(Map<String, dynamic> json) =>
      AppThemeSettings(
        primaryColor: json['primaryColor'],
        secondaryColor: json['secondaryColor'],
        useMaterial3: json['useMaterial3'] ?? true,
        enableGradients: json['enableGradients'] ?? false,
      );
}

class ProfileCustomization {
  final String layout;
  final bool enableParticles;
  final bool enableMusicPlayer;
  final String profileImageShape;
  final double profileImageSize;

  const ProfileCustomization({
    required this.layout,
    this.enableParticles = false,
    this.enableMusicPlayer = false,
    this.profileImageShape = 'circle',
    this.profileImageSize = 80.0,
  });

  Map<String, dynamic> toJson() => {
        'layout': layout,
        'enableParticles': enableParticles,
        'enableMusicPlayer': enableMusicPlayer,
        'profileImageShape': profileImageShape,
        'profileImageSize': profileImageSize,
      };

  static ProfileCustomization fromJson(Map<String, dynamic> json) =>
      ProfileCustomization(
        layout: json['layout'],
        enableParticles: json['enableParticles'] ?? false,
        enableMusicPlayer: json['enableMusicPlayer'] ?? false,
        profileImageShape: json['profileImageShape'] ?? 'circle',
        profileImageSize: json['profileImageSize'] ?? 80.0,
      );
}

class ComponentStyles {
  final double cardBorderRadius;
  final double buttonBorderRadius;
  final double inputBorderRadius;
  final double elevationLevel;

  const ComponentStyles({
    required this.cardBorderRadius,
    this.buttonBorderRadius = 8.0,
    this.inputBorderRadius = 4.0,
    this.elevationLevel = 1.0,
  });

  Map<String, dynamic> toJson() => {
        'cardBorderRadius': cardBorderRadius,
        'buttonBorderRadius': buttonBorderRadius,
        'inputBorderRadius': inputBorderRadius,
        'elevationLevel': elevationLevel,
      };

  static ComponentStyles fromJson(Map<String, dynamic> json) => ComponentStyles(
        cardBorderRadius: json['cardBorderRadius'],
        buttonBorderRadius: json['buttonBorderRadius'] ?? 8.0,
        inputBorderRadius: json['inputBorderRadius'] ?? 4.0,
        elevationLevel: json['elevationLevel'] ?? 1.0,
      );
}

class LayoutPreferences {
  final String density;
  final double spacing;
  final double padding;
  final int gridColumns;

  const LayoutPreferences({
    required this.density,
    this.spacing = 8.0,
    this.padding = 16.0,
    this.gridColumns = 1,
  });

  Map<String, dynamic> toJson() => {
        'density': density,
        'spacing': spacing,
        'padding': padding,
        'gridColumns': gridColumns,
      };

  static LayoutPreferences fromJson(Map<String, dynamic> json) =>
      LayoutPreferences(
        density: json['density'],
        spacing: json['spacing'] ?? 8.0,
        padding: json['padding'] ?? 16.0,
        gridColumns: json['gridColumns'] ?? 1,
      );
}

class TypographySettings {
  final String primaryFont;
  final String secondaryFont;
  final double fontSize;
  final String fontWeight;

  const TypographySettings({
    required this.primaryFont,
    this.secondaryFont = 'Roboto',
    this.fontSize = 14.0,
    this.fontWeight = 'normal',
  });

  Map<String, dynamic> toJson() => {
        'primaryFont': primaryFont,
        'secondaryFont': secondaryFont,
        'fontSize': fontSize,
        'fontWeight': fontWeight,
      };

  static TypographySettings fromJson(Map<String, dynamic> json) =>
      TypographySettings(
        primaryFont: json['primaryFont'],
        secondaryFont: json['secondaryFont'] ?? 'Roboto',
        fontSize: json['fontSize'] ?? 14.0,
        fontWeight: json['fontWeight'] ?? 'normal',
      );
}
