import 'dart:async';
//import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/core/themes/app_colors.dart';
import 'package:herdapp/core/utils/router.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'features/ui/customization/view/providers/ui_customization_provider.dart';
import 'features/social/chat_messaging/view/providers/e2ee_auto_init_provider.dart';
import 'package:herdapp/core/services/app_check_service.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/bootstrap/app_bootstraps.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'firebase_options.dart';
import 'features/user/auth/view/providers/auth_provider.dart';

/// Background message handler - MUST be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint('🔔 Background message received: ${message.messageId}');
  debugPrint('📱 Message data: ${message.data}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized');

    // This should automatically run the correct code for mobile or web.
    await setupPlatformSpecificFirebase();

    // You can still have kIsWeb checks for things that don't need separate files.
    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      debugPrint('Background message handler registered');

      unawaited(MobileAds.instance.initialize());
      debugPrint('🚀 Mobile ads initialization started');

      unawaited(CacheManager.bootstrapCache());
      debugPrint('🚀 Cache bootstrap started');
    }

    debugPrint('Main initialization complete');
  } catch (e, stackTrace) {
    debugPrint('Error in main initialization: $e');
    debugPrint(stackTrace.toString());
  }

  runApp(
    const ProviderScope(
      child: BootstrapWrapper(
        child: AuthGate(
          child: MyApp(),
        ),
      ),
    ),
  );
}

// Future<void> _setupFirebaseAppCheck() async {
//   // CHANGED: This entire function's logic is mobile-only due to `dart:io`.
//   // The call to this function is already wrapped in `if (!kIsWeb)`.
//   // No changes are needed inside, but it's important to know why it's wrapped.
//   try {
//     final bool isiOSSimulator = Platform.isIOS &&
//         Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');
//     final appleProvider =
//         isiOSSimulator ? AppleProvider.debug : AppleProvider.appAttest;
//     await FirebaseAppCheck.instance.activate(
//       androidProvider: AndroidProvider.debug,
//       appleProvider: appleProvider,
//     );
//     final messaging = FirebaseMessaging.instance;
//     final settings = await messaging.requestPermission(
//       alert: true,
//       announcement: false,
//       badge: true,
//       carPlay: false,
//       criticalAlert: false,
//       provisional: false,
//       sound: true,
//     );
//     debugPrint(
//         '🔔 Firebase Messaging permission status: ${settings.authorizationStatus}');
//   } catch (e) {
//     debugPrint('Firebase App Check setup error: $e');
//     // Continue without App Check in case of errors
//   }
// }

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    final customTheme = ref.watch(currentThemeProvider);
    final customizationAsync = ref.watch(uiCustomizationProvider);

    // Initialize E2EE keys when user is authenticated
    ref.watch(e2eeAutoInitProvider);

    final authReady = ref.watch(authReadyProvider);
    final user = ref.watch(authProvider);
    debugPrint('Building MyApp: authReady=$authReady user=${user?.uid}');

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
            primarySwatch: AppTheme.primarySwatch,
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.primary,
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

/// Gate that waits for the first Firebase Auth event before showing the router.
class AuthGate extends ConsumerWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(authReadyProvider);
    final user = ref.watch(authProvider);
    if (!ready) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator()),
        ),
        debugShowCheckedModeBanner: false,
      );
    }
    debugPrint('🔓 Auth ready. Current user: ${user?.uid ?? 'null'}');
    return child; // Router will redirect to /login if user null
  }
}
