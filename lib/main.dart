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

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.backgroundMessageHandler(message);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Start initializing mobile ads in the background
  unawaited(MobileAds.instance.initialize());

  await Firebase.initializeApp();

  // Detect iOS Simulator via environment var
  final bool isiOSSimulator = Platform.isIOS &&
      Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');

  final appleProvider = isiOSSimulator
      ? AppleProvider.debug // simulator → debug
      : AppleProvider.appAttest; // real device → App Attest

  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: appleProvider,
  );

  // Register background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // await FirebaseAppCheck.instance.activate(
  //   // Use provider for Android
  //   androidProvider: AndroidProvider.debug,
  //   // Use provider for iOS/macOS
  //   appleProvider: AppleProvider.debug,
  // );

  // This will pre-warm the cache system
  unawaited(CacheManager.bootstrapCache());

  runApp(
    const ProviderScope(
      child: BootstrapWrapper(
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(goRouterProvider);

    return MaterialApp.router(
      routerConfig: goRouter,
      // builder: (BuildContext context, Widget? child) {
      //   return AppScaffold(child: child!);
      // },
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate, // Add this line
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
      title: 'Herd app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
