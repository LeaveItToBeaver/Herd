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
    // Validate input
    if (userId.isEmpty) {
      throw ArgumentError('UserId cannot be empty');
    }

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

      final data = doc.data()!;
      // Ensure all required fields have default values
      final sanitizedData = _sanitizeCustomizationData(data, userId);

      final customization = UICustomizationModel.fromJson(sanitizedData);

      // Cache the result
      await _saveToCache(customization);
      debugPrint('🎨 Loaded UI customization from Firestore');

      return customization;
    } catch (e, stackTrace) {
      debugPrint('❌ Error loading UI customization: $e');
      debugPrint('Stack trace: $stackTrace');
      // Return default on error instead of throwing
      return UICustomizationModel.defaultForUser(userId);
    }
  }

  // Sanitize customization data to ensure all fields have proper values
  Map<String, dynamic> _sanitizeCustomizationData(
      Map<String, dynamic> data, String userId) {
    final sanitized = Map<String, dynamic>.from(data);

    // Ensure userId is set
    sanitized['userId'] = userId;

    // Ensure lastUpdated is set
    if (!sanitized.containsKey('lastUpdated') ||
        sanitized['lastUpdated'] == null) {
      sanitized['lastUpdated'] = DateTime.now().toIso8601String();
    }

    // Ensure appTheme exists with default values
    if (!sanitized.containsKey('appTheme') || sanitized['appTheme'] == null) {
      sanitized['appTheme'] = const AppThemeSettings().toJson();
    } else {
      // Merge with defaults to ensure all fields are present
      final defaultTheme = const AppThemeSettings().toJson();
      final userTheme = sanitized['appTheme'] as Map<String, dynamic>;
      sanitized['appTheme'] = {...defaultTheme, ...userTheme};
    }

    // Ensure profileCustomization exists
    if (!sanitized.containsKey('profileCustomization') ||
        sanitized['profileCustomization'] == null) {
      sanitized['profileCustomization'] = const ProfileCustomization().toJson();
    }

    // Ensure componentStyles exists
    if (!sanitized.containsKey('componentStyles') ||
        sanitized['componentStyles'] == null) {
      sanitized['componentStyles'] = const ComponentStyles().toJson();
    }

    // Ensure layoutPreferences exists
    if (!sanitized.containsKey('layoutPreferences') ||
        sanitized['layoutPreferences'] == null) {
      sanitized['layoutPreferences'] = const LayoutPreferences().toJson();
    }

    // Ensure animationSettings exists
    if (!sanitized.containsKey('animationSettings') ||
        sanitized['animationSettings'] == null) {
      sanitized['animationSettings'] = const AnimationSettings().toJson();
    }

    // Ensure typography exists
    if (!sanitized.containsKey('typography') ||
        sanitized['typography'] == null) {
      sanitized['typography'] = const TypographySettings().toJson();
    }

    return sanitized;
  }

  // Save user's UI customization
  Future<void> saveUserCustomization(UICustomizationModel customization) async {
    try {
      if (customization.userId.isEmpty) {
        throw ArgumentError('UserId cannot be empty');
      }

      final data = customization.toJson();
      data['lastUpdated'] = FieldValue.serverTimestamp();

      await _firestore
          .collection(_collection)
          .doc(customization.userId)
          .set(data, SetOptions(merge: true));

      // Update cache
      await _saveToCache(customization);
      debugPrint('✅ UI customization saved');
    } catch (e, stackTrace) {
      debugPrint('❌ Error saving UI customization: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Update specific customization fields
  Future<void> updateCustomization(
    String userId,
    Map<String, dynamic> updates,
  ) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('UserId cannot be empty');
      }

      if (updates.isEmpty) {
        debugPrint('⚠️ No updates provided');
        return;
      }

      // Sanitize updates to remove null values
      final sanitizedUpdates = <String, dynamic>{};
      for (final entry in updates.entries) {
        if (entry.value != null) {
          sanitizedUpdates[entry.key] = entry.value;
        }
      }

      if (sanitizedUpdates.isEmpty) {
        debugPrint('⚠️ All updates were null, skipping');
        return;
      }

      sanitizedUpdates['lastUpdated'] = FieldValue.serverTimestamp();
      sanitizedUpdates['userId'] = userId;

      await _firestore.collection(_collection).doc(userId).set(
            sanitizedUpdates,
            SetOptions(merge: true),
          );

      // Clear cache to force reload
      await _clearCache(userId);
      debugPrint('✅ UI customization updated');
    } catch (e, stackTrace) {
      debugPrint('❌ Error updating UI customization: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Stream user's UI customization for real-time updates
  Stream<UICustomizationModel> streamUserCustomization(String userId) {
    if (userId.isEmpty) {
      return Stream.value(UICustomizationModel.defaultForUser(userId));
    }

    return _firestore
        .collection(_collection)
        .doc(userId)
        .snapshots()
        .map((doc) {
      try {
        if (!doc.exists || doc.data() == null) {
          return UICustomizationModel.defaultForUser(userId);
        }

        final data = doc.data()!;
        final sanitizedData = _sanitizeCustomizationData(data, userId);
        final customization = UICustomizationModel.fromJson(sanitizedData);

        // Update cache whenever we get new data
        _saveToCache(customization).catchError((e) {
          debugPrint('⚠️ Failed to cache customization: $e');
        });

        return customization;
      } catch (e, stackTrace) {
        debugPrint('❌ Error in stream customization: $e');
        debugPrint('Stack trace: $stackTrace');
        return UICustomizationModel.defaultForUser(userId);
      }
    }).handleError((error, stackTrace) {
      debugPrint('❌ Stream error: $error');
      debugPrint('Stack trace: $stackTrace');
    });
  }

  // Reset to default customization
  Future<void> resetToDefault(String userId) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('UserId cannot be empty');
      }

      final defaultCustomization = UICustomizationModel.defaultForUser(userId);
      await saveUserCustomization(defaultCustomization);
      debugPrint('✅ UI customization reset to default');
    } catch (e, stackTrace) {
      debugPrint('❌ Error resetting UI customization: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Apply a preset theme
  Future<void> applyPresetTheme(String userId, String presetId) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('UserId cannot be empty');
      }

      if (presetId.isEmpty) {
        throw ArgumentError('PresetId cannot be empty');
      }

      final preset = _getPresetTheme(presetId);
      if (preset == null) {
        throw Exception('Preset theme not found: $presetId');
      }

      await updateCustomization(userId, {
        'appTheme': preset.toJson(),
      });

      debugPrint('✅ Preset theme applied: $presetId');
    } catch (e, stackTrace) {
      debugPrint('❌ Error applying preset theme: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Export customization as JSON
  Future<String> exportCustomization(String userId) async {
    try {
      final customization = await getUserCustomization(userId);
      return jsonEncode(customization.toJson());
    } catch (e, stackTrace) {
      debugPrint('❌ Error exporting customization: $e');
      debugPrint('Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Import customization from JSON
  Future<void> importCustomization(String userId, String jsonData) async {
    try {
      if (userId.isEmpty) {
        throw ArgumentError('UserId cannot be empty');
      }

      if (jsonData.isEmpty) {
        throw ArgumentError('JSON data cannot be empty');
      }

      final data = jsonDecode(jsonData) as Map<String, dynamic>;
      data['userId'] = userId; // Ensure correct user ID

      final sanitizedData = _sanitizeCustomizationData(data, userId);
      final customization = UICustomizationModel.fromJson(sanitizedData);
      await saveUserCustomization(customization);

      debugPrint('✅ Customization imported successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ Error importing customization: $e');
      debugPrint('Stack trace: $stackTrace');
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

      final data = cachedData['data'] as Map<String, dynamic>;
      final sanitizedData = _sanitizeCustomizationData(data, userId);
      return UICustomizationModel.fromJson(sanitizedData);
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
    // ... (keeping the existing default theme settings)
    primaryColor: '#6200EE',
    secondaryColor: '#03DAC6',
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
    primaryContainerColor: '#EADDFF',
    onPrimaryContainerColor: '#21005D',
    secondaryContainerColor: '#CCF7F1',
    onSecondaryContainerColor: '#00201D',
    tertiaryColor: '#7D5260',
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
  );

  // Preset themes (keeping existing presets)
  AppThemeSettings? _getPresetTheme(String presetId) {
    final presets = <String, AppThemeSettings>{
      'dark': const AppThemeSettings(
        primaryColor: '#BB86FC',
        secondaryColor: '#03DAC6',
        backgroundColor: '#121212',
        surfaceColor: '#1E1E1E',
        textColor: '#E0E0E0',
        secondaryTextColor: '#9E9E9E',
        themeMode: 'dark',
        onPrimaryColor: '#000000',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#FFFFFF',
        onErrorColor: '#000000',
        onSurfaceColor: '#FFFFFF',
        primaryContainerColor: '#3700B3',
        onPrimaryContainerColor: '#FFFFFF',
        secondaryContainerColor: '#018786',
        onSecondaryContainerColor: '#000000',
        tertiaryColor: '#CF6679',
        onTertiaryContainerColor: '#FFFFFF',
        tertiaryContainerColor: '#B00020',
        outlineColor: '#424242',
        shadowColor: '#000000',
        surfaceVariantColor: '#303030',
        onSurfaceVariantColor: '#BDBDBD',
        disabledColor: '#555555',
        hintColor: '#888888',
      ),
      'neon': const AppThemeSettings(
        primaryColor: '#FF006E',
        secondaryColor: '#FFBE0B',
        backgroundColor: '#0A0A0A',
        surfaceColor: '#1A1A1A',
        textColor: '#FFFFFF',
        enableGradients: true,
        enableGlassmorphism: true,
        enableShadows: true,
        shadowIntensity: 2.0,
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#FFFFFF',
        onErrorColor: '#000000',
        onSurfaceColor: '#FFFFFF',
        primaryContainerColor: '#4D0022',
        onPrimaryContainerColor: '#FFB3D1',
        secondaryContainerColor: '#4D3800',
        onSecondaryContainerColor: '#FFEAAD',
        tertiaryColor: '#00FFF0',
        onTertiaryContainerColor: '#000000',
        tertiaryContainerColor: '#004D4A',
        outlineColor: '#555555',
        shadowColor: '#000000',
        surfaceVariantColor: '#2C2C2C',
        onSurfaceVariantColor: '#AAAAAA',
        disabledColor: '#404040',
        hintColor: '#808080',
        themeMode: 'dark',
      ),
      'pastel': const AppThemeSettings(
        primaryColor: '#FFB3D9',
        secondaryColor: '#B3E5FF',
        backgroundColor: '#FFF5F5',
        surfaceColor: '#FFFFFF',
        textColor: '#4A4A4A',
        secondaryTextColor: '#7A7A7A',
        onPrimaryColor: '#000000',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#4A4A4A',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#4A4A4A',
        primaryContainerColor: '#FFD9EB',
        onPrimaryContainerColor: '#6B274D',
        secondaryContainerColor: '#D9F2FF',
        onSecondaryContainerColor: '#27576B',
        tertiaryColor: '#FFFACD',
        onTertiaryContainerColor: '#5D542E',
        tertiaryContainerColor: '#FFFDE7',
        outlineColor: '#D1C4E9',
        shadowColor: '#B0BEC5',
        surfaceVariantColor: '#FCE4EC',
        onSurfaceVariantColor: '#616161',
        disabledColor: '#E0E0E0',
        hintColor: '#BDBDBD',
        themeMode: 'light',
      ),
      'retro': const AppThemeSettings(
        primaryColor: '#FF6B6B',
        secondaryColor: '#4ECDC4',
        backgroundColor: '#F7FFF7',
        surfaceColor: '#FFE66D',
        textColor: '#2A2A2A',
        enableShadows: true,
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#000000',
        onBackgroundColor: '#2A2A2A',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#000000',
        primaryContainerColor: '#FFCDD2',
        onPrimaryContainerColor: '#B71C1C',
        secondaryContainerColor: '#B2DFDB',
        onSecondaryContainerColor: '#004D40',
        tertiaryColor: '#FF9800',
        onTertiaryContainerColor: '#000000',
        tertiaryContainerColor: '#FFE0B2',
        outlineColor: '#795548',
        shadowColor: '#000000',
        surfaceVariantColor: '#FFF9C4',
        onSurfaceVariantColor: '#4E342E',
        disabledColor: '#D7CCC8',
        hintColor: '#A1887F',
        themeMode: 'light',
      ),
      'minimal': const AppThemeSettings(
        primaryColor: '#000000',
        secondaryColor: '#666666',
        backgroundColor: '#FFFFFF',
        surfaceColor: '#F5F5F5',
        textColor: '#000000',
        secondaryTextColor: '#666666',
        enableShadows: false,
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#FFFFFF',
        onBackgroundColor: '#000000',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#000000',
        primaryContainerColor: '#E0E0E0',
        onPrimaryContainerColor: '#000000',
        secondaryContainerColor: '#BDBDBD',
        onSecondaryContainerColor: '#000000',
        tertiaryColor: '#9E9E9E',
        onTertiaryContainerColor: '#000000',
        tertiaryContainerColor: '#EEEEEE',
        outlineColor: '#BDBDBD',
        shadowColor: '#000000',
        surfaceVariantColor: '#EEEEEE',
        onSurfaceVariantColor: '#333333',
        disabledColor: '#E0E0E0',
        hintColor: '#9E9E9E',
        themeMode: 'light',
      ),
      'ocean': const AppThemeSettings(
        primaryColor: '#006BA6',
        secondaryColor: '#0496FF',
        backgroundColor: '#E8F4F8',
        surfaceColor: '#FFFFFF',
        textColor: '#0A2540',
        enableGradients: true,
        onPrimaryColor: '#FFFFFF',
        onSecondaryColor: '#FFFFFF',
        onBackgroundColor: '#0A2540',
        onErrorColor: '#FFFFFF',
        onSurfaceColor: '#0A2540',
        primaryContainerColor: '#B3E5FC',
        onPrimaryContainerColor: '#01476A',
        secondaryContainerColor: '#81D4FA',
        onSecondaryContainerColor: '#013A63',
        tertiaryColor: '#FFCC80',
        onTertiaryContainerColor: '#5D4037',
        tertiaryContainerColor: '#FFE0B2',
        outlineColor: '#ADD8E6',
        shadowColor: '#000000',
        surfaceVariantColor: '#E1F5FE',
        onSurfaceVariantColor: '#0277BD',
        disabledColor: '#CFD8DC',
        hintColor: '#90A4AE',
        themeMode: 'light',
      ),
      'rainyForest': const AppThemeSettings(
        primaryColor: '#3B5D55',
        secondaryColor: '#6A7A83',
        backgroundColor: '#263238',
        surfaceColor: '#37474F',
        textColor: '#ECEFF1',
        secondaryTextColor: '#B0BEC5',
        errorColor: '#EF9A9A',
        warningColor: '#FFCC80',
        successColor: '#A5D6A7',
        themeMode: 'dark',
        useMaterial3: true,
        enableShadows: true,
        shadowIntensity: 0.8,
        onPrimaryColor: '#E0F2F1',
        onSecondaryColor: '#FFFFFF',
        onBackgroundColor: '#ECEFF1',
        onErrorColor: '#000000',
        onSurfaceColor: '#ECEFF1',
        primaryContainerColor: '#2E4B45',
        onPrimaryContainerColor: '#A7C7C1',
        secondaryContainerColor: '#4E5A60',
        onSecondaryContainerColor: '#B8C2C8',
        tertiaryColor: '#8B4513',
        onTertiaryContainerColor: '#EFEBE9',
        tertiaryContainerColor: '#6D4C41',
        outlineColor: '#546E7A',
        shadowColor: '#000000',
        surfaceVariantColor: '#455A64',
        onSurfaceVariantColor: '#CFD8DC',
        disabledColor: '#607D8B',
        hintColor: '#90A4AE',
        enableGradients: false,
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
