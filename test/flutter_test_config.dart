import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'mocks/firebase_mock.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Get the test file path
  final testPath = Platform.environment['FLUTTER_TEST'] ?? '';

  // Skip Firebase setup entirely for customization tests
  final isCustomizationTest = testPath.contains('customization_tests');

  if (!isCustomizationTest) {
    setUpAll(() async {
      await setupFirebaseCoreMocks();
    });
  }

  await testMain();
}
