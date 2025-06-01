import 'dart:async';
import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/core/utils/router.dart';
import 'package:herdapp/features/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/customization/view/providers/ui_customization_provider.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/bootstrap/app_bootstraps.dart';

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if not already done
  await Firebase.initializeApp();

  // Handle the background message
  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('📱 Message data: ${message.data}');

  // You can add custom background processing here if needed
  // For example, updating local storage, analytics, etc.

  // Note: Don't show UI or navigate in background handler
  // Just log and potentially store data for when app opens
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp();
    debugPrint('✅ Firebase initialized');

    // Register background message handler EARLY
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    debugPrint('✅ Background message handler registered');

    // Start initializing mobile ads in the background (non-blocking)
    unawaited(MobileAds.instance.initialize());
    debugPrint('🚀 Mobile ads initialization started');

    // Set up Firebase App Check
    await _setupFirebaseAppCheck();
    debugPrint('✅ Firebase App Check configured');

    // Pre-warm the cache system (non-blocking)
    unawaited(CacheManager.bootstrapCache());
    debugPrint('🚀 Cache bootstrap started');

    debugPrint('✅ Main initialization complete');
  } catch (e, stackTrace) {
    debugPrint('❌ Error in main initialization: $e');
    debugPrint(stackTrace.toString());
    // Continue anyway - don't let initialization failures crash the app
  }

  runApp(
    const ProviderScope(
      child: BootstrapWrapper(
        child: MyApp(),
      ),
    ),
  );
}

/// Set up Firebase App Check with proper configuration
Future<void> _setupFirebaseAppCheck() async {
  try {
    // Detect iOS Simulator via environment var
    final bool isiOSSimulator = Platform.isIOS &&
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');

    final appleProvider = isiOSSimulator
        ? AppleProvider.debug // simulator → debug
        : AppleProvider.appAttest; // real device → App Attest

    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider
          .debug, // Change to AndroidProvider.playIntegrity for production
      appleProvider: appleProvider,
    );

    final messaging = FirebaseMessaging.instance;

    final settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint(
        '🔔 Firebase Messaging permission status: ${settings.authorizationStatus}');
  } catch (e) {
    debugPrint('⚠️ Firebase App Check setup error: $e');
    // Continue without App Check in case of errors
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    final customTheme = ref.watch(currentThemeProvider);
    final customizationAsync = ref.watch(uiCustomizationProvider);

    // Get theme mode from customization or default to system
    final themeMode = customizationAsync.maybeWhen(
      data: (customization) =>
          customization?.appTheme.getThemeMode() ?? ThemeMode.system,
      orElse: () => ThemeMode.system,
    );

    return MaterialApp.router(
      routerConfig: goRouter,
      title: 'Herd App',

      // Localization support
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('fr'), // French
        Locale('de'), // German
        Locale('it'), // Italian
        Locale('ru'), // Russian
        Locale('ja'), // Japanese
        Locale('ko'), // Korean
        Locale('pl'), // Polish
        Locale('sv'), // Swedish
        Locale('es'), // Spanish
      ],

      // Theme configuration
      theme: customTheme,

      // Dark theme (optional)
      darkTheme: customizationAsync.maybeWhen(
            data: (customization) {
              if (customization != null) {
                // Build dark theme from customization
                return _buildDarkTheme(customization);
              }
              return null;
            },
            orElse: () => null,
          ) ??
          ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
          ),

      // Theme mode from customization
      themeMode: themeMode,

      // Remove debug banner in release mode
      debugShowCheckedModeBanner: false,
    );
  }

  // Build dark theme from customization
  ThemeData _buildDarkTheme(UICustomizationModel customization) {
    final appTheme = customization.appTheme;

    return ThemeData(
      useMaterial3: appTheme.useMaterial3,
      brightness: Brightness.dark,
      colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: appTheme.getPrimaryColor(),
        onPrimary: _getOnColor(appTheme.getPrimaryColor()),
        secondary: appTheme.getSecondaryColor(),
        onSecondary: _getOnColor(appTheme.getSecondaryColor()),
        error: appTheme.getErrorColor(),
        onError: Colors.white,
        surface: _darken(appTheme.getSurfaceColor(), 0.2),
        onSurface: Colors.white,
        surfaceContainerHighest: _darken(appTheme.getSurfaceColor(), 0.1),
        onSurfaceVariant: Colors.white70,
        outline: Colors.white38,
      ),
      scaffoldBackgroundColor: _darken(appTheme.getBackgroundColor(), 0.3),
    );
  }

  Color _getOnColor(Color color) {
    return color.computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }
}
