import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper class to handle Android Keystore corruption issues
///
/// Android Keystore can become corrupted due to various reasons:
/// - Device updates
/// - Factory resets
/// - Security policy changes
/// - Hardware issues
///
/// This helper provides utilities to detect and recover from such issues.
class KeystoreRecoveryHelper {
  static const String _lastSuccessfulAuthKey = 'last_successful_auth_timestamp';
  static const String _keystoreCorruptionDetectedKey =
      'keystore_corruption_detected';
  static const String _authSessionRestoredKey = 'auth_session_restored';

  /// Mark that a successful authentication occurred
  static Future<void> markSuccessfulAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
          _lastSuccessfulAuthKey, DateTime.now().millisecondsSinceEpoch);
      await prefs.setBool(_authSessionRestoredKey, true);
      await prefs.remove(
          _keystoreCorruptionDetectedKey); // Clear any previous corruption flag
      debugPrint('✅ Marked successful auth and session restoration');
    } catch (e) {
      debugPrint('⚠️ Failed to mark successful auth: $e');
    }
  }

  /// Mark that auth session was restored from persistence
  static Future<void> markSessionRestored() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_authSessionRestoredKey, true);
      debugPrint('✅ Marked auth session as restored');
    } catch (e) {
      debugPrint('⚠️ Failed to mark session restored: $e');
    }
  }

  /// Check if we should expect an auth session to be restored
  static Future<bool> shouldExpectAuthSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAuth = prefs.getInt(_lastSuccessfulAuthKey);
      final wasRestored = prefs.getBool(_authSessionRestoredKey) ?? false;

      if (lastAuth == null) return false;

      // If we had a successful auth recently and session was restored, expect it
      final lastAuthTime = DateTime.fromMillisecondsSinceEpoch(lastAuth);
      final timeSinceAuth = DateTime.now().difference(lastAuthTime);

      // If last auth was within 30 days and session was previously restored
      return timeSinceAuth.inDays <= 30 && wasRestored;
    } catch (e) {
      debugPrint('⚠️ Failed to check auth session expectation: $e');
      return false;
    }
  }

  /// Detect if keystore corruption might have occurred
  static Future<bool> detectKeystoreCorruption() async {
    try {
      final shouldExpectAuth = await shouldExpectAuthSession();

      if (shouldExpectAuth) {
        debugPrint(
            '🔍 Expected auth session but none found - possible keystore corruption');
        await _markKeystoreCorruption();
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('⚠️ Failed to detect keystore corruption: $e');
      return false;
    }
  }

  /// Mark that keystore corruption was detected
  static Future<void> _markKeystoreCorruption() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keystoreCorruptionDetectedKey, true);
      await prefs.setBool(_authSessionRestoredKey, false);
      debugPrint('🚨 Marked keystore corruption detected');
    } catch (e) {
      debugPrint('⚠️ Failed to mark keystore corruption: $e');
    }
  }

  /// Check if keystore corruption was previously detected
  static Future<bool> wasKeystoreCorruptionDetected() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keystoreCorruptionDetectedKey) ?? false;
    } catch (e) {
      debugPrint('⚠️ Failed to check keystore corruption status: $e');
      return false;
    }
  }

  /// Clear all stored auth state (useful for recovery)
  static Future<void> clearAuthState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_lastSuccessfulAuthKey);
      await prefs.remove(_keystoreCorruptionDetectedKey);
      await prefs.remove(_authSessionRestoredKey);
      debugPrint('🧹 Cleared all stored auth state');
    } catch (e) {
      debugPrint('⚠️ Failed to clear auth state: $e');
    }
  }

  /// Get a user-friendly message about keystore corruption
  static String getKeystoreCorruptionMessage() {
    return '''
Your device's secure storage has been reset, which affects saved login sessions.

This can happen after:
• Device updates
• Security setting changes  
• Factory resets

You'll need to log in again, but your account and data are safe.
''';
  }

  /// Log keystore corruption details for debugging
  static Future<void> logKeystoreCorruptionDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastAuth = prefs.getInt(_lastSuccessfulAuthKey);
      final wasRestored = prefs.getBool(_authSessionRestoredKey) ?? false;
      final corruptionDetected =
          prefs.getBool(_keystoreCorruptionDetectedKey) ?? false;

      debugPrint('🔍 Keystore Corruption Analysis:');
      debugPrint(
          '  - Last successful auth: ${lastAuth != null ? DateTime.fromMillisecondsSinceEpoch(lastAuth) : 'Never'}');
      debugPrint('  - Session was restored: $wasRestored');
      debugPrint('  - Corruption detected: $corruptionDetected');

      if (lastAuth != null) {
        final timeSinceAuth = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(lastAuth));
        debugPrint('  - Time since last auth: ${timeSinceAuth.inDays} days');
      }
    } catch (e) {
      debugPrint('⚠️ Failed to log keystore corruption details: $e');
    }
  }
}
