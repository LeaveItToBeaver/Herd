import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

typedef Callback = void Function(MethodCall call);

// Mock Firebase App - Fix constructor
class MockFirebaseApp extends FirebaseAppPlatform {
  MockFirebaseApp({
    required String name,
    required FirebaseOptions options,
  }) : super(name, options);

  @override
  bool get isAutomaticDataCollectionEnabled => false;

  @override
  Future<void> delete() async {}

  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setAutomaticResourceManagement(bool enabled) async {}
}

// Mock Firebase Platform
class MockFirebasePlatform extends FirebasePlatform {
  static final Map<String, FirebaseAppPlatform> _appInstances = {};

  @override
  FirebaseAppPlatform app([String name = defaultFirebaseAppName]) {
    return _appInstances[name] ??
        MockFirebaseApp(
          name: name,
          options: const FirebaseOptions(
            apiKey: 'mock_api_key',
            appId: 'mock_app_id',
            messagingSenderId: 'mock_sender_id',
            projectId: 'mock_project_id',
          ),
        );
  }

  @override
  Future<FirebaseAppPlatform> initializeApp({
    String? name,
    FirebaseOptions? options,
  }) async {
    final appName = name ?? defaultFirebaseAppName;
    final app = MockFirebaseApp(
      name: appName,
      options: options ??
          const FirebaseOptions(
            apiKey: 'mock_api_key',
            appId: 'mock_app_id',
            messagingSenderId: 'mock_sender_id',
            projectId: 'mock_project_id',
          ),
    );
    _appInstances[appName] = app;
    return app;
  }

  @override
  List<FirebaseAppPlatform> get apps => _appInstances.values.toList();
}

Future<void> setupFirebaseCoreMocks() async {
  FirebasePlatform.instance = MockFirebasePlatform();
}
