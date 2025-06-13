import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ui_customization_model.dart';

final uiCustomizationRepositoryProvider =
    Provider<UICustomizationRepository>((ref) {
  return UICustomizationRepository(FirebaseFirestore.instance);
});

class UICustomizationRepository {
  final FirebaseFirestore _firestore;
  static const String _collection = 'customUI';
  static const String _cacheKey = 'ui_customization_cache';
  static const Duration _cacheExpiration = Duration(hours: 24);

  UICustomizationRepository(this._firestore);

  // Get user's UI customization with caching
  Future<UICustomizationModel> getUserCustomization(String userId) async {
    try {
      // First, try to get from local cache
      final cached = await _getFromCache(userId);
      if (cached != null) {
        debugPrint('🎨 Loaded UI customization from cache');
        return cached;
      }

      // If not in cache, get from Firestore
      final doc = await _firestore.collection(_collection).doc(userId).get();

      if (!doc.exists || doc.data() == null) {
        // Create default customization for new users
        final defaultCustomization =
            UICustomizationModel.defaultForUser(userId);
        await saveUserCustomization(defaultCustomization);
        return defaultCustomization;
      }

      final customization = UICustomizationModel.fromJson(doc.data()!);

      // Cache the result
      await _saveToCache(customization);
      debugPrint('🎨 Loaded UI customization from Firestore');

      return customization;
    } catch (e) {
      debugPrint('❌ Error loading UI customization: $e');
      // Return default on error
      return UICustomizationModel.defaultForUser(userId);
    }
  }

  // Save user's UI customization
  Future<void> saveUserCustomization(UICustomizationModel customization) async {
    try {
      final data = {
        ...customization.toJson(),
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(_collection)
          .doc(customization.userId)
          .set(data);

      // Update cache
      await _saveToCache(customization);
      debugPrint('✅ UI customization saved');
    } catch (e) {
      debugPrint('❌ Error saving UI customization: $e');
      rethrow;
    }
  }

  // Update specific customization fields - FIXED to use set with merge
  Future<void> updateCustomization(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      updates['lastUpdated'] = FieldValue.serverTimestamp();
      updates['userId'] = userId; // Ensure userId is always included

      // Use set with merge instead of update to handle non-existent documents
      await _firestore.collection(_collection).doc(userId).set(
            updates,
            SetOptions(merge: true),
          );

      // Clear cache to force reload
      await _clearCache(userId);
      debugPrint('✅ UI customization updated');
    } catch (e) {
      debugPrint('❌ Error updating UI customization: $e');
      rethrow;
    }
  }

  // Stream user's UI customization for real-time updates
  Stream<UICustomizationModel> streamUserCustomization(String userId) {
    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return UICustomizationModel.defaultForUser(userId);
      }

      final customization = UICustomizationModel.fromJson(doc.data()!);

      // Update cache whenever we get new data
      _saveToCache(customization).catchError((e) {
        debugPrint('⚠️ Failed to cache customization: $e');
      });

      return customization;
    });
  }

  // Reset to default customization
  Future<void> resetToDefault(String userId) async {
    try {
      final defaultCustomization = UICustomizationModel.defaultForUser(userId);
      await saveUserCustomization(defaultCustomization);
      debugPrint('✅ UI customization reset to default');
    } catch (e) {
      debugPrint('❌ Error resetting UI customization: $e');
      rethrow;
    }
  }

  // Apply a preset theme
  Future<void> applyPresetTheme(String userId, String presetId) async {
    try {
      final preset = _getPresetTheme(presetId);
      if (preset == null) {
        throw Exception('Preset theme not found: $presetId');
      }

      await updateCustomization(userId, {
        'appTheme': preset.toJson(),
      });

      debugPrint('✅ Preset theme applied: $presetId');
    } catch (e) {
      debugPrint('❌ Error applying preset theme: $e');
      rethrow;
    }
  }

  // Export customization as JSON
  Future<String> exportCustomization(String userId) async {
    try {
      final customization = await getUserCustomization(userId);
      return jsonEncode(customization.toJson());
    } catch (e) {
      debugPrint('❌ Error exporting customization: $e');
      rethrow;
    }
  }

  // Import customization from JSON
  Future<void> importCustomization(String userId, String jsonData) async {
    try {
      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      data['userId'] = userId; // Ensure correct user ID

      final customization = UICustomizationModel.fromJson(data);
      await saveUserCustomization(customization);

      debugPrint('✅ Customization imported successfully');
    } catch (e) {
      debugPrint('❌ Error importing customization: $e');
      rethrow;
    }
  }

  // Cache management
  Future<UICustomizationModel?> _getFromCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_cacheKey}_$userId';
      final cachedJson = prefs.getString(key);

      if (cachedJson == null) return null;

      final cachedData = jsonDecode(cachedJson) as Map<String, dynamic>;
      final cacheTime = DateTime.parse(cachedData['cacheTime'] as String);

      // Check if cache is expired
      if (DateTime.now().difference(cacheTime) > _cacheExpiration) {
        await prefs.remove(key);
        return null;
      }

      return UICustomizationModel.fromJson(
          cachedData['data'] as Map<String, dynamic>);
    } catch (e) {
      debugPrint('⚠️ Cache read error: $e');
      return null;
    }
  }

  Future<void> _saveToCache(UICustomizationModel customization) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_cacheKey}_${customization.userId}';

      final cacheData = {
        'data': customization.toJson(),
        'cacheTime': DateTime.now().toIso8601String(),
      };

      await prefs.setString(key, jsonEncode(cacheData));
    } catch (e) {
      debugPrint('⚠️ Cache write error: $e');
    }
  }

  Future<void> _clearCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '${_cacheKey}_$userId';
      await prefs.remove(key);
    } catch (e) {
      debugPrint('⚠️ Cache clear error: $e');
    }
  }

  static const AppThemeSettings appDefaultThemeSettings = AppThemeSettings(
    // --- Define the app's true default colors and settings here ---
    primaryColor: '#6200EE', // Material Purple
    secondaryColor: '#03DAC6', // Material Teal
    backgroundColor: '#FFFFFF',
    surfaceColor: '#FFFFFF',
    textColor: '#000000',
    secondaryTextColor: '#757575',
    errorColor: '#B00020',
    warningColor: '#FFC107',
    successColor: '#4CAF50',

    onPrimaryColor: '#FFFFFF',
    onSecondaryColor: '#000000',
    onBackgroundColor: '#000000',
    onErrorColor: '#FFFFFF',
    onSurfaceColor: '#000000',

    primaryContainerColor: '#EADDFF', // Light purple
    onPrimaryContainerColor: '#21005D',
    secondaryContainerColor: '#CCF7F1', // Light teal
    onSecondaryContainerColor: '#00201D',
    tertiaryColor: '#7D5260', // M3 Tertiary
    onTertiaryContainerColor: '#FFFFFF',
    tertiaryContainerColor: '#FFD8E4',

    outlineColor: '#79747E',
    shadowColor: '#000000',
    surfaceVariantColor: '#E7E0EC',
    onSurfaceVariantColor: '#49454F',
    disabledColor: '#BDBDBD',
    hintColor: '#9E9E9E',

    themeMode: 'system',
    useMaterial3: true,
    enableGlassmorphism: false,
    enableGradients: false,
    enableShadows: true,
    shadowIntensity: 1.0,
    // Ensure ALL fields from AppThemeSettings are covered
    // We might need to add more fields in the future
  );

  // Preset themes
  AppThemeSettings? _getPresetTheme(String presetId) {
    final presets = <String, AppThemeSettings>{
      'dark': const AppThemeSettings(
        // Existing
        primaryColor: '#BB86FC',
        secondaryColor: '#03DAC6',
        backgroundColor: '#121212',
        surfaceColor: '#1E1E1E',
        textColor: '#E0E0E0', // Main text on surface/background
        secondaryTextColor: '#9E9E9E', // Subdued text
        themeMode: 'dark',
        // New
        onPrimaryColor: '#000000',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#FFFFFF',
        onErrorColor: '#000000', // Text on default error color
        onSurfaceColor: '#FFFFFF', // Explicit text on surfaceColor
        primaryContainerColor: '#3700B3',
        onPrimaryContainerColor: '#FFFFFF',
        secondaryContainerColor: '#018786',
        onSecondaryContainerColor: '#000000',
        tertiaryColor: '#CF6679', // Material dark theme error-like accent
        onTertiaryContainerColor: '#FFFFFF',
        tertiaryContainerColor: '#B00020',
        outlineColor: '#424242',
        shadowColor: '#000000',
        surfaceVariantColor: '#303030', // Darker surface variant
        onSurfaceVariantColor: '#BDBDBD', // Text for surfaceVariantColor
        disabledColor: '#555555',
        hintColor: '#888888',
      ),
      'neon': const AppThemeSettings(
        // Existing
        primaryColor: '#FF006E', // Neon Pink
        secondaryColor: '#FFBE0B', // Neon Yellow
        backgroundColor: '#0A0A0A',
        surfaceColor: '#1A1A1A',
        textColor: '#FFFFFF',
        enableGradients: true,
        enableGlassmorphism: true,
        enableShadows: true,
        shadowIntensity: 2.0,
        // New
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#FFFFFF',
        onErrorColor: '#000000',
        onSurfaceColor: '#FFFFFF',
        primaryContainerColor: '#4D0022', // Darker neon pink base
        onPrimaryContainerColor: '#FFB3D1', // Light pink text
        secondaryContainerColor: '#4D3800', // Darker neon yellow base
        onSecondaryContainerColor: '#FFEAAD', // Light yellow text
        tertiaryColor: '#00FFF0', // Neon Cyan/Aqua
        onTertiaryContainerColor: '#000000',
        tertiaryContainerColor: '#004D4A', // Dark cyan base
        outlineColor: '#555555',
        shadowColor: '#000000',
        surfaceVariantColor: '#2C2C2C',
        onSurfaceVariantColor: '#AAAAAA',
        disabledColor: '#404040',
        hintColor: '#808080',
        themeMode: 'dark', // Neon themes usually are dark
      ),
      'pastel': const AppThemeSettings(
        // Existing
        primaryColor: '#FFB3D9', // Pastel Pink
        secondaryColor: '#B3E5FF', // Pastel Blue
        backgroundColor: '#FFF5F5', // Very light pinkish white
        surfaceColor: '#FFFFFF',
        textColor: '#4A4A4A', // Dark gray for text
        secondaryTextColor: '#7A7A7A',
        // New
        onPrimaryColor: '#000000',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#4A4A4A',
        onErrorColor:
            '#FFFFFF', // Text on default error color (which is dark red)
        onSurfaceColor: '#4A4A4A', // Text on white surface
        primaryContainerColor: '#FFD9EB', // Very light pink
        onPrimaryContainerColor: '#6B274D', // Darker pink for contrast
        secondaryContainerColor: '#D9F2FF', // Very light blue
        onSecondaryContainerColor: '#27576B', // Darker blue for contrast
        tertiaryColor: '#FFFACD', // Pastel Yellow (Lemon Chiffon)
        onTertiaryContainerColor: '#5D542E', // Darker yellow for contrast
        tertiaryContainerColor: '#FFFDE7', // Even lighter yellow
        outlineColor: '#D1C4E9', // Pastel Lavender for outlines
        shadowColor: '#B0BEC5', // Soft gray shadow
        surfaceVariantColor:
            '#FCE4EC', // Another light pastel (e.g., light pink variant)
        onSurfaceVariantColor: '#616161', // Darker gray text on variant
        disabledColor: '#E0E0E0', // Light gray
        hintColor: '#BDBDBD', // Medium light gray
        themeMode: 'light',
      ),
      'retro': const AppThemeSettings(
        // Existing
        primaryColor: '#FF6B6B', // Coral Red
        secondaryColor: '#4ECDC4', // Teal
        backgroundColor: '#F7FFF7', // Off-white with a hint of green
        surfaceColor: '#FFE66D', // Mustard Yellow
        textColor: '#2A2A2A', // Dark, almost black
        enableShadows: true,
        // New
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#2A2A2A',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#000000', // Black text on mustard yellow
        primaryContainerColor: '#FFCDD2', // Light Coral
        onPrimaryContainerColor: '#B71C1C', // Dark Red
        secondaryContainerColor: '#B2DFDB', // Light Teal
        onSecondaryContainerColor: '#004D40', // Dark Teal
        tertiaryColor: '#FF9800', // Retro Orange
        onTertiaryContainerColor: '#000000',
        tertiaryContainerColor: '#FFE0B2', // Light Orange
        outlineColor: '#795548', // Brownish for outlines
        shadowColor: '#000000',
        surfaceVariantColor: '#FFF9C4', // Lighter Yellow/Cream
        onSurfaceVariantColor: '#4E342E', // Dark Brown text
        disabledColor: '#D7CCC8', // Muted brown/gray
        hintColor: '#A1887F', // Muted brown
        themeMode: 'light',
      ),
      'minimal': const AppThemeSettings(
        // Existing
        primaryColor: '#000000', // Black
        secondaryColor: '#666666', // Dark Gray
        backgroundColor: '#FFFFFF', // White
        surfaceColor: '#F5F5F5', // Light Gray
        textColor: '#000000', // Black text
        secondaryTextColor: '#666666', // Dark Gray text
        enableShadows: false,
        // New
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#FFFFFF',
        onBackgroundColor: '#000000',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#000000', // Black text on light gray surface
        primaryContainerColor: '#E0E0E0', // Very light gray, almost white
        onPrimaryContainerColor: '#000000',
        secondaryContainerColor: '#BDBDBD', // Medium Gray
        onSecondaryContainerColor: '#000000',
        tertiaryColor: '#9E9E9E', // Another Gray
        onTertiaryContainerColor: '#000000',
        tertiaryContainerColor: '#EEEEEE', // Very light gray
        outlineColor: '#BDBDBD', // Gray for outlines
        shadowColor: '#000000', // Though shadows are disabled by default here
        surfaceVariantColor: '#EEEEEE', // Slightly different light gray
        onSurfaceVariantColor: '#333333', // Darker gray text
        disabledColor: '#E0E0E0',
        hintColor: '#9E9E9E',
        themeMode: 'light',
      ),
      'ocean': const AppThemeSettings(
        // Existing
        primaryColor: '#006BA6', // Deep Ocean Blue
        secondaryColor: '#0496FF', // Bright Sky Blue
        backgroundColor: '#E8F4F8', // Very Light Blue (like sea foam)
        surfaceColor: '#FFFFFF', // White (like wave crests)
        textColor: '#0A2540', // Dark Navy (deep water text)
        enableGradients: true,
        // New
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#FFFFFF',
        onBackgroundColor: '#0A2540',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#0A2540', // Dark navy text on white surface
        primaryContainerColor: '#B3E5FC', // Light Sky Blue (lighter primary)
        onPrimaryContainerColor: '#01476A', // Darker blue text
        secondaryContainerColor: '#81D4FA', // Brighter Light Blue
        onSecondaryContainerColor: '#013A63', // Darker blue text
        tertiaryColor: '#FFCC80', // Sandy Beige/Light Orange (beach)
        onTertiaryContainerColor: '#5D4037', // Brownish text
        tertiaryContainerColor: '#FFE0B2', // Lighter sandy color
        outlineColor: '#ADD8E6', // Light Blue for outlines
        shadowColor: '#000000',
        surfaceVariantColor: '#E1F5FE', // Very light sky blue, almost white
        onSurfaceVariantColor: '#0277BD', // Medium blue text
        disabledColor: '#CFD8DC', // Bluish gray
        hintColor: '#90A4AE', // Muted blue-gray
        themeMode: 'light',
      ),
      'rainyForest': const AppThemeSettings(
        primaryColor: '#3B5D55', // Desaturated Forest Green
        secondaryColor: '#6A7A83', // Misty Gray-Blue
        backgroundColor: '#263238', // Blue Grey Dark
        surfaceColor: '#37474F', // Slightly lighter Blue Grey (damp stone)
        textColor: '#ECEFF1', // Light Blue Grey (general text)
        secondaryTextColor: '#B0BEC5', // Muted Light Blue Grey (subdued text)
        errorColor: '#EF9A9A', // Muted Red, suitable for dark themes
        warningColor: '#FFCC80', // Muted Orange/Amber
        successColor: '#A5D6A7', // Muted Green
        themeMode: 'dark',
        useMaterial3: true,
        enableShadows: true,
        shadowIntensity: 0.8,
        onPrimaryColor: '#E0F2F1', // Very light cyan/green
        onSecondaryColor: '#FFFFFF',
        onBackgroundColor: '#ECEFF1', // Light text on dark background
        onErrorColor: '#000000', // Black text on muted red
        onSurfaceColor: '#ECEFF1', // Light text on surfaceColor
        primaryContainerColor: '#2E4B45', // Darker, desaturated version
        onPrimaryContainerColor: '#A7C7C1', // Muted light green text
        secondaryContainerColor: '#4E5A60', // Darker version of secondary
        onSecondaryContainerColor: '#B8C2C8', // Muted light grey-blue text
        tertiaryColor: '#8B4513', // Saddle Brown (wet bark/earth)
        onTertiaryContainerColor: '#EFEBE9', // Text on tertiaryContainerColor
        tertiaryContainerColor: '#6D4C41', // Text on tertiaryColor
        outlineColor: '#546E7A', // Blue Grey for outlines
        shadowColor: '#000000',
        surfaceVariantColor: '#455A64', // Another Blue Grey variant
        onSurfaceVariantColor: '#CFD8DC', // Light Blue Grey text
        disabledColor: '#607D8B', // Muted Blue Grey
        hintColor: '#90A4AE', // Lighter Muted Blue Grey
        enableGradients: false, // Optional: true for misty effect
      ),
    };

    return presets[presetId];
  }

  // Get available preset themes
  Map<String, String> getAvailablePresets() {
    return {
      'dark': 'Dark Mode',
      'neon': 'Neon Lights',
      'pastel': 'Pastel',
      'retro': 'Retro',
      'minimal': 'Minimalist',
      'ocean': 'Ocean Blue',
      'rainyForest': 'Rainy Forest',
    };
  }
}
