import 'dart:io';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> setupPlatformSpecificFirebase() async {
  try {
    final bool isiOSSimulator = Platform.isIOS &&
        Platform.environment.containsKey('SIMULATOR_DEVICE_NAME');

    final appleProvider =
        isiOSSimulator ? AppleProvider.debug : AppleProvider.appAttest;

    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: appleProvider,
    );
    debugPrint('Firebase App Check configured for mobile');

    final messaging = FirebaseMessaging.instance;
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
  } catch (e) {
    debugPrint('Firebase App Check setup error: $e');
  }
}
