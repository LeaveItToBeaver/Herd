import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:herdapp/features/customization/data/models/ui_customization_model.dart';
import 'package:herdapp/features/customization/data/repositories/ui_customization_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('UICustomizationRepository', () {
    late UICustomizationRepository repository;
    late FakeFirebaseFirestore fakeFirestore;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = UICustomizationRepository(fakeFirestore);
      SharedPreferences.setMockInitialValues({});
    });

    test('should create default customization for new user', () async {
      const userId = 'new_user_123';

      final customization = await repository.getUserCustomization(userId);

      expect(customization.userId, userId);
      expect(customization.appTheme.primaryColor, '#3D5AFE');

      // Verify it was saved to Firestore
      final doc = await fakeFirestore.collection('customUI').doc(userId).get();
      expect(doc.exists, true);
    });

    test('should save and retrieve customization', () async {
      const userId = 'test_user_456';
      final customization =
          UICustomizationModel.defaultForUser(userId).copyWith(
        appTheme: const AppThemeSettings(primaryColor: '#FF0000'),
      );

      await repository.saveUserCustomization(customization);
      final retrieved = await repository.getUserCustomization(userId);

      expect(retrieved.userId, userId);
      expect(retrieved.appTheme.primaryColor, '#FF0000');
    });

    test('should update specific customization fields', () async {
      const userId = 'test_user_789';
      final original = UICustomizationModel.defaultForUser(userId);
      await repository.saveUserCustomization(original);

      await repository.updateCustomization(userId, {
        'appTheme': const AppThemeSettings(primaryColor: '#00FF00').toJson(),
      });

      final updated = await repository.getUserCustomization(userId);
      expect(updated.appTheme.primaryColor, '#00FF00');
      expect(updated.profileCustomization.layout, 'classic'); // unchanged
    });

    test('should handle empty userId gracefully', () async {
      expect(
        () => repository.getUserCustomization(''),
        throwsArgumentError,
      );
    });

    test('should sanitize data with missing fields', () async {
      const userId = 'test_user_sanitize';

      // Manually insert incomplete data
      await fakeFirestore.collection('customUI').doc(userId).set({
        'userId': userId,
        'appTheme': {'primaryColor': '#FF0000'}, // missing other theme fields
        // missing other top-level fields
      });

      final customization = await repository.getUserCustomization(userId);

      // Should have defaults for missing fields
      expect(customization.appTheme.primaryColor, '#FF0000');
      expect(customization.appTheme.useMaterial3, true); // default
      expect(customization.profileCustomization.layout, 'classic'); // default
    });

    test('should reset to default customization', () async {
      const userId = 'test_user_reset';
      final customized = UICustomizationModel.defaultForUser(userId).copyWith(
        appTheme: const AppThemeSettings(primaryColor: '#FF0000'),
      );
      await repository.saveUserCustomization(customized);

      await repository.resetToDefault(userId);

      final reset = await repository.getUserCustomization(userId);
      expect(reset.appTheme.primaryColor, '#3D5AFE'); // back to default
    });

    test('should export and import customization', () async {
      const userId = 'test_user_export';
      final original = UICustomizationModel.defaultForUser(userId).copyWith(
        appTheme: const AppThemeSettings(primaryColor: '#FF0000'),
      );
      await repository.saveUserCustomization(original);

      final exported = await repository.exportCustomization(userId);
      expect(exported, isA<String>());

      // Import to different user
      const newUserId = 'test_user_import';
      await repository.importCustomization(newUserId, exported);

      final imported = await repository.getUserCustomization(newUserId);
      expect(imported.appTheme.primaryColor, '#FF0000');
      expect(imported.userId, newUserId); // should update user ID
    });

    test('should stream customization changes', () async {
      const userId = 'test_user_stream';
      final original = UICustomizationModel.defaultForUser(userId);
      await repository.saveUserCustomization(original);

      final stream = repository.streamUserCustomization(userId);

      expect(stream, emits(isA<UICustomizationModel>()));

      // Update and expect new value
      await repository.updateCustomization(userId, {
        'appTheme': const AppThemeSettings(primaryColor: '#00FF00').toJson(),
      });

      await expectLater(
        stream.skip(1),
        emits(predicate<UICustomizationModel>(
          (model) => model.appTheme.primaryColor == '#00FF00',
        )),
      );
    });
  });
}
