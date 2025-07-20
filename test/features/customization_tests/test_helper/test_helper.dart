import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';

class CustomizationTestHelpers {
  static UICustomizationModel createTestCustomization({
    String userId = 'test_user',
    String primaryColor = '#FF0000',
    String layout = 'modern',
    bool enableParticles = true,
    double cardRadius = 20.0,
    String density = 'compact',
    String font = 'Inter',
  }) {
    return UICustomizationModel.defaultForUser(userId).copyWith(
      appTheme: AppThemeSettings(primaryColor: primaryColor),
      profileCustomization: ProfileCustomization(
        layout: layout,
        enableParticles: enableParticles,
      ),
      componentStyles: ComponentStyles(cardBorderRadius: cardRadius),
      layoutPreferences: LayoutPreferences(density: density),
      typography: TypographySettings(primaryFont: font),
    );
  }

  static AppThemeSettings createTestTheme({
    String primaryColor = '#FF0000',
    String secondaryColor = '#00FF00',
    bool useMaterial3 = true,
    bool enableGradients = false,
  }) {
    return AppThemeSettings(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
      useMaterial3: useMaterial3,
      enableGradients: enableGradients,
    );
  }

  static ProfileCustomization createTestProfile({
    String layout = 'modern',
    bool enableParticles = false,
    bool enableMusicPlayer = false,
    String profileImageShape = 'circle',
    double profileImageSize = 80.0,
  }) {
    return ProfileCustomization(
      layout: layout,
      enableParticles: enableParticles,
      enableMusicPlayer: enableMusicPlayer,
      profileImageShape: profileImageShape,
      profileImageSize: profileImageSize,
    );
  }
}
