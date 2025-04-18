import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ExceptionLoggerService {
  final FirebaseFunctions _functions;

  ExceptionLoggerService({FirebaseFunctions? functions})
      : _functions = functions ?? FirebaseFunctions.instance;

  Future<void> logException({
    required String errorMessage,
    required String stackTrace,
    String? errorCode,
    Map<String, dynamic>? errorDetails,
    String? userId,
    String? route,
    String? action,
  }) async {
    try {
      // Collect app information
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();

      Map<String, dynamic> deviceData = {};

      // Get platform-specific device info
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData = {
          'platform': 'Android',
          'device': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
          'osVersion': androidInfo.version.release,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData = {
          'platform': 'iOS',
          'device': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
        };
      }

      // Call the cloud function
      await _functions.httpsCallable('logException').call({
        'errorMessage': errorMessage,
        'stackTrace': stackTrace,
        'errorCode': errorCode,
        'errorDetails': errorDetails,
        'userId': userId ?? FirebaseAuth.instance.currentUser?.uid,
        'route': route,
        'action': action,
        'appInfo': {
          'appVersion': packageInfo.version,
          'buildNumber': packageInfo.buildNumber,
          'deviceInfo': deviceData,
          'environment': kDebugMode ? 'development' : 'production',
        }
      });
    } catch (e) {
      // Silent failure - we don't want errors in the error logger
      // to cause more errors in the app
      debugPrint('Failed to log exception: $e');
    }
  }
}
