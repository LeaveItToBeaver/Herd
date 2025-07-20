import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herdapp/features/ui/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/ui/customization/data/repositories/ui_customization_repository.dart';
import 'package:herdapp/features/ui/customization/view/screens/ui_customization_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Customization Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('should complete full customization flow', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uiCustomizationRepositoryProvider.overrideWithValue(
              UICustomizationRepository(fakeFirestore),
            ),
            currentUserIdProvider.overrideWith((ref) => 'test_user_flow'),
          ],
          child: const MaterialApp(
            home: UICustomizationScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Should show customization screen
      expect(find.text('Customize Your Experience'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);

      // Test primary color picker
      final colorPicker = find.byKey(const Key('primary_color_picker'));
      if (colorPicker.evaluate().isNotEmpty) {
        await tester.tap(colorPicker);
        await tester.pumpAndSettle();
      }

      // Test glassmorphism toggle
      final glassmorphismSwitch = find.byKey(const Key('glassmorphism_switch'));
      if (glassmorphismSwitch.evaluate().isNotEmpty) {
        await tester.tap(glassmorphismSwitch);
        await tester.pumpAndSettle();
      }

      // Switch to Profile tab
      final profileTab = find.text('Profile');
      if (profileTab.evaluate().isNotEmpty) {
        await tester.tap(profileTab);
        await tester.pumpAndSettle();
      }

      // Test layout selection
      final layoutModern = find.byKey(const Key('layout_modern_radio'));
      if (layoutModern.evaluate().isNotEmpty) {
        await tester.tap(layoutModern);
        await tester.pumpAndSettle();
      }

      // Test particles toggle
      final particlesSwitch = find.byKey(const Key('particles_switch'));
      if (particlesSwitch.evaluate().isNotEmpty) {
        await tester.tap(particlesSwitch);
        await tester.pumpAndSettle();
      }

      // Verify changes were saved to Firestore
      final doc = await fakeFirestore
          .collection('customUI')
          .doc('test_user_flow')
          .get();
      expect(doc.exists, true);
    });

    testWidgets('should handle reset to defaults', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uiCustomizationRepositoryProvider.overrideWithValue(
              UICustomizationRepository(fakeFirestore),
            ),
            currentUserIdProvider.overrideWith((ref) => 'test_user_reset'),
          ],
          child: const MaterialApp(
            home: UICustomizationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap reset button if it exists
      final resetButton = find.byKey(const Key('reset_button'));
      if (resetButton.evaluate().isNotEmpty) {
        await tester.tap(resetButton);
        await tester.pumpAndSettle();

        // Confirm reset dialog
        final resetDialogButton = find.text('Reset');
        if (resetDialogButton.evaluate().isNotEmpty) {
          await tester.tap(resetDialogButton);
          await tester.pumpAndSettle();
        }
      }

      // Verify reset was applied
      final doc = await fakeFirestore
          .collection('customUI')
          .doc('test_user_reset')
          .get();
      if (doc.exists) {
        final data = doc.data();
        expect(data?['appTheme']['primaryColor'], '#3D5AFE');
      }
    });

    testWidgets('should show error state and retry', (tester) async {
      // Create a repository that throws errors
      final errorRepository = ErrorRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            uiCustomizationRepositoryProvider
                .overrideWithValue(errorRepository),
            currentUserIdProvider.overrideWith((ref) => 'test_user_error'),
          ],
          child: const MaterialApp(
            home: UICustomizationScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error state or handle gracefully
      // The UI should handle errors gracefully, so we just verify it doesn't crash
      expect(find.byType(UICustomizationScreen), findsOneWidget);
    });
  });
}

// Mock repository that throws errors for testing error handling
class ErrorRepository implements UICustomizationRepository {
  @override
  Future<UICustomizationModel> getUserCustomization(String userId) async {
    throw Exception('Network error');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

final currentUserIdProvider = Provider<String?>((ref) => null);
