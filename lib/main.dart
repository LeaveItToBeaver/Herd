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
import 'package:herdapp/features/notifications/utils/notification_service.dart';
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,

        // Notification-friendly theme colors
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),

        // App bar theme for notification icons
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),

        // Badge theme for notification badges
        badgeTheme: const BadgeThemeData(
          backgroundColor: Colors.red,
          textColor: Colors.white,
        ),
      ),

      // Dark theme (optional)
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
        badgeTheme: const BadgeThemeData(
          backgroundColor: Colors.red,
          textColor: Colors.white,
        ),
      ),

      // System theme mode
      themeMode: ThemeMode.system,

      // Remove debug banner in release mode
      debugShowCheckedModeBanner: false,
    );
  }
}
