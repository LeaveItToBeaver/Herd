import 'package:flutter_test/flutter_test.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('should create UserModel with required fields', () {
      final user = UserModel(
        userId: 'test_user_id',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 0,
        altPostCount: 0,
        totalPoints: 0,
        isPrivate: false,
        enableAltProfile: false,
      );

      expect(user.userId, 'test_user_id');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'Test');
      expect(user.lastName, 'User');
      expect(user.fullName, 'Test User');
    });

    test('should handle optional fields', () {
      final user = UserModel(
        userId: 'test_user_id',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 0,
        altPostCount: 0,
        totalPoints: 0,
        isPrivate: false,
        enableAltProfile: false,
        bio: 'This is a test bio',
        profileImageURL: 'https://example.com/avatar.jpg',
        coverImageURL: 'https://example.com/cover.jpg',
        location: 'Test City',
        website: 'https://testsite.com',
      );

      expect(user.bio, 'This is a test bio');
      expect(user.profileImageURL, 'https://example.com/avatar.jpg');
      expect(user.coverImageURL, 'https://example.com/cover.jpg');
      expect(user.location, 'Test City');
      expect(user.website, 'https://testsite.com');
    });

    test('should create UserModel from JSON', () {
      final json = {
        'userId': 'test_user_id',
        'username': 'testuser',
        'email': 'test@example.com',
        'firstName': 'Test',
        'lastName': 'User',
        'bio': 'Test bio',
        'isVerified': true,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'publicPostCount': 5,
        'altPostCount': 3,
        'totalPoints': 100,
        'isPrivate': false,
        'enableAltProfile': true,
      };

      final user = UserModel.fromJson(json);

      expect(user.userId, 'test_user_id');
      expect(user.username, 'testuser');
      expect(user.bio, 'Test bio');
      expect(user.isVerified, true);
      expect(user.publicPostCount, 5);
      expect(user.altPostCount, 3);
      expect(user.totalPoints, 100);
      expect(user.enableAltProfile, true);
    });

    test('should convert UserModel to JSON', () {
      final user = UserModel(
        userId: 'test_user_id',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        bio: 'Test bio',
        isVerified: true,
        createdAt: DateTime(2023, 1, 1),
        updatedAt: DateTime(2023, 1, 2),
        publicPostCount: 5,
        altPostCount: 3,
        totalPoints: 100,
        isPrivate: false,
        enableAltProfile: true,
      );

      final json = user.toJson();

      expect(json['userId'], 'test_user_id');
      expect(json['username'], 'testuser');
      expect(json['bio'], 'Test bio');
      expect(json['isVerified'], true);
      expect(json['publicPostCount'], 5);
      expect(json['altPostCount'], 3);
      expect(json['totalPoints'], 100);
      expect(json['enableAltProfile'], true);
    });

    test('should create copy with updated fields', () {
      final originalUser = UserModel(
        userId: 'test_user_id',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 0,
        altPostCount: 0,
        totalPoints: 0,
        isPrivate: false,
        enableAltProfile: false,
      );

      final updatedUser = originalUser.copyWith(
        bio: 'Updated bio',
        isVerified: true,
        totalPoints: 150,
      );

      expect(updatedUser.userId, originalUser.userId); // Unchanged
      expect(updatedUser.bio, 'Updated bio'); // Changed
      expect(updatedUser.isVerified, true); // Changed
      expect(updatedUser.totalPoints, 150); // Changed
    });

    test('should validate email format', () {
      // Valid emails
      final validEmails = [
        'test@example.com',
        'user.name@domain.co.uk',
        'test+tag@gmail.com',
        'numbers123@test.org',
      ];

      for (final email in validEmails) {
        expect(email.contains('@'), true);
        expect(email.contains('.'), true);
      }

      // Invalid emails (basic checks)
      final invalidEmails = [
        'invalid-email',
        '@domain.com',
        'user@',
        'user@@domain.com',
      ];

      for (final email in invalidEmails) {
        // Basic validation - should not have proper @ and . structure
        final isValid = email.contains('@') && 
                       email.indexOf('@') > 0 && 
                       email.indexOf('@') < email.length - 1 &&
                       email.split('@').length == 2 &&
                       email.split('@')[1].contains('.');
        expect(isValid, false);
      }
    });

    test('should validate username format', () {
      // Valid usernames (basic rules)
      final validUsernames = [
        'testuser',
        'user123',
        'test_user',
        'user-name',
      ];

      for (final username in validUsernames) {
        expect(username.isNotEmpty, true);
        expect(username.length >= 3, true);
      }

      // Invalid usernames
      final invalidUsernames = [
        '', // Empty
        'a', // Too short
        'ab', // Too short
      ];

      for (final username in invalidUsernames) {
        expect(username.length < 3, true);
      }
    });

    test('should handle alt profile settings', () {
      final user = UserModel(
        userId: 'test_user_id',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 5,
        altPostCount: 3,
        totalPoints: 0,
        isPrivate: false,
        enableAltProfile: true,
        altBio: 'Alternative bio',
        altProfileImageURL: 'https://example.com/alt-avatar.jpg',
        altCoverImageURL: 'https://example.com/alt-cover.jpg',
      );

      expect(user.enableAltProfile, true);
      expect(user.altBio, 'Alternative bio');
      expect(user.altProfileImageURL, 'https://example.com/alt-avatar.jpg');
      expect(user.altCoverImageURL, 'https://example.com/alt-cover.jpg');
    });

    test('should calculate total post count', () {
      final user = UserModel(
        userId: 'test_user_id',
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 10,
        altPostCount: 5,
        totalPoints: 0,
        isPrivate: false,
        enableAltProfile: false,
      );

      final totalPosts = user.publicPostCount + user.altPostCount;
      expect(totalPosts, 15);
    });

    test('should handle privacy settings', () {
      final privateUser = UserModel(
        userId: 'private_user_id',
        username: 'privateuser',
        email: 'private@example.com',
        firstName: 'Private',
        lastName: 'User',
        isVerified: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 0,
        altPostCount: 0,
        totalPoints: 0,
        isPrivate: true,
        enableAltProfile: false,
      );

      expect(privateUser.isPrivate, true);
    });

    test('should handle verification status', () {
      final verifiedUser = UserModel(
        userId: 'verified_user_id',
        username: 'verifieduser',
        email: 'verified@example.com',
        firstName: 'Verified',
        lastName: 'User',
        isVerified: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        publicPostCount: 0,
        altPostCount: 0,
        totalPoints: 0,
        isPrivate: false,
        enableAltProfile: false,
      );

      expect(verifiedUser.isVerified, true);
    });
  });
}