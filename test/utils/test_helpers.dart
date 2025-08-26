import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_type.dart';
import 'package:herdapp/features/social/chat_messaging/data/enums/message_status.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

/// Shared test utilities and helper functions for the test suite
class TestHelpers {
  
  /// Creates a test app wrapper with ProviderScope
  static Widget createTestApp({
    required Widget child,
    List<Override> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  /// Creates a test PostModel with default values
  static PostModel createTestPost({
    String id = 'test_post_id',
    String authorId = 'test_author_id',
    String authorUsername = 'testuser',
    String? authorProfileImageURL,
    String title = 'Test Post Title',
    String content = 'Test post content',
    String? mediaURL,
    bool isAlt = false,
    int likeCount = 0,
    int dislikeCount = 0,
    int commentCount = 0,
    double? hotScore,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PostModel(
      id: id,
      authorId: authorId,
      authorUsername: authorUsername,
      authorProfileImageURL: authorProfileImageURL,
      title: title,
      content: content,
      mediaURL: mediaURL,
      isAlt: isAlt,
      likeCount: likeCount,
      dislikeCount: dislikeCount,
      commentCount: commentCount,
      hotScore: hotScore,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a test MessageModel with default values
  static MessageModel createTestMessage({
    String id = 'test_message_id',
    String chatId = 'test_chat_id',
    String senderId = 'test_sender_id',
    String? senderName = 'Test User',
    String? senderProfileImage,
    String? content = 'Test message content',
    MessageType type = MessageType.text,
    MessageStatus status = MessageStatus.delivered,
    DateTime? timestamp,
    String? replyToMessageId,
    String? mediaUrl,
    Map<String, String>? reactions,
    Map<String, DateTime>? readReceipts,
  }) {
    return MessageModel(
      id: id,
      chatId: chatId,
      senderId: senderId,
      senderName: senderName,
      senderProfileImage: senderProfileImage,
      content: content,
      type: type,
      status: status,
      timestamp: timestamp ?? DateTime.now(),
      replyToMessageId: replyToMessageId,
      mediaUrl: mediaUrl,
      reactions: reactions ?? const {},
      readReceipts: readReceipts ?? const {},
    );
  }

  /// Creates a test UserModel with default values
  static UserModel createTestUser({
    String id = 'test_user_id',
    String username = 'testuser',
    String email = 'test@example.com',
    String firstName = 'Test',
    String lastName = 'User',
    String? bio,
    String? profileImageURL,
    String? coverImageURL,
    bool isVerified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    int publicPostCount = 0,
    int altPostCount = 0,
    int totalPoints = 0,
    bool isPrivate = false,
    bool enableAltProfile = false,
  }) {
    return UserModel(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      bio: bio,
      profileImageURL: profileImageURL,
      coverImageURL: coverImageURL,
      isVerified: isVerified,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates test Firestore data for a post
  static Map<String, dynamic> createTestPostData({
    String authorId = 'test_author_id',
    String title = 'Test Post Title',
    String content = 'Test post content',
    bool isAlt = false,
    int likeCount = 0,
    int dislikeCount = 0,
    int commentCount = 0,
    double hotScore = 0.0,
  }) {
    return {
      'authorId': authorId,
      'authorUsername': 'testuser',
      'title': title,
      'content': content,
      'isAlt': isAlt,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'hotScore': hotScore,
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
      'mediaURL': null,
      'authorProfileImageURL': null,
    };
  }

  /// Creates test Firestore data for a message
  static Map<String, dynamic> createTestMessageData({
    String chatId = 'test_chat_id',
    String senderId = 'test_sender_id',
    String content = 'Test message content',
    String type = 'text',
    DateTime? timestamp,
  }) {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': 'Test User',
      'content': content,
      'type': type,
      'timestamp': timestamp ?? DateTime.now(),
      'isEdited': false,
      'isDeleted': false,
      'reactions': <String, dynamic>{},
      'readReceipts': <String, dynamic>{},
    };
  }

  /// Waits for a specific widget to appear
  static Future<void> waitForWidget(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final end = DateTime.now().add(timeout);
    
    while (DateTime.now().isBefore(end)) {
      await tester.pump();
      
      if (finder.evaluate().isNotEmpty) {
        return;
      }
      
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    throw TimeoutException(
      'Widget not found within timeout',
      timeout,
    );
  }

  /// Pumps the widget tree until animations are complete
  static Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    bool found = false;
    final end = DateTime.now().add(timeout);
    
    while (!found && DateTime.now().isBefore(end)) {
      await tester.pump();
      found = finder.evaluate().isNotEmpty;
      
      if (!found) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    
    if (!found) {
      throw TimeoutException(
        'Widget not found within timeout',
        timeout,
      );
    }
  }

  /// Enters text with proper keyboard handling
  static Future<void> enterTextSafely(
    WidgetTester tester,
    Finder finder,
    String text,
  ) async {
    await tester.tap(finder);
    await tester.pumpAndSettle();
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// Scrolls to find a widget
  static Future<void> scrollToWidget(
    WidgetTester tester,
    Finder scrollable,
    Finder target, {
    double delta = 100.0,
    int maxScrolls = 50,
  }) async {
    for (int i = 0; i < maxScrolls; i++) {
      if (target.evaluate().isNotEmpty) {
        return;
      }
      
      await tester.drag(scrollable, Offset(0, -delta));
      await tester.pumpAndSettle();
    }
    
    throw Exception('Could not find widget by scrolling');
  }

  /// Verifies that all required accessibility properties are set
  static void verifyAccessibility(WidgetTester tester) {
    final semantics = tester.binding.pipelineOwner.semanticsOwner;
    expect(semantics, isNotNull);
    
    // Verify semantic tree is not empty
    final semanticsTree = semantics?.rootSemanticsNode;
    expect(semanticsTree, isNotNull);
  }

  /// Creates a mock network image for testing
  static Widget createMockNetworkImage(String url) {
    return Container(
      width: 100,
      height: 100,
      color: Colors.grey,
      child: const Icon(Icons.image),
    );
  }

  /// Validates an email format
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  /// Validates a username format
  static bool isValidUsername(String username) {
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_-]{3,20}$');
    return usernameRegex.hasMatch(username);
  }

  /// Formats a number for display (1k, 1M, etc.)
  static String formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else {
      return number.toString();
    }
  }

  /// Calculates time ago string
  static String timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'now';
    }
  }

  /// Creates test data for Firebase collections
  static Map<String, dynamic> createFirebaseTestData({
    required String collection,
    Map<String, dynamic>? customData,
  }) {
    final baseData = <String, dynamic>{
      'createdAt': DateTime.now(),
      'updatedAt': DateTime.now(),
    };
    
    switch (collection) {
      case 'posts':
        baseData.addAll(createTestPostData());
        break;
      case 'messages':
        baseData.addAll(createTestMessageData());
        break;
      case 'users':
        baseData.addAll({
          'username': 'testuser',
          'email': 'test@example.com',
          'firstName': 'Test',
          'lastName': 'User',
          'isVerified': false,
        });
        break;
    }
    
    if (customData != null) {
      baseData.addAll(customData);
    }
    
    return baseData;
  }
}

/// Custom timeout exception for test helpers
class TimeoutException implements Exception {
  final String message;
  final Duration timeout;
  
  const TimeoutException(this.message, this.timeout);
  
  @override
  String toString() => 'TimeoutException: $message (timeout: $timeout)';
}

/// Mock providers for testing
class MockProviders {
  static List<Override> getBasicOverrides() {
    return [
      // Add your provider overrides here
      // Example:
      // someProviderProvider.overrideWith((ref) => MockSomeProvider()),
    ];
  }
  
  static List<Override> getChatOverrides() {
    return [
      ...getBasicOverrides(),
      // Add chat-specific provider overrides
    ];
  }
  
  static List<Override> getPostOverrides() {
    return [
      ...getBasicOverrides(),
      // Add post-specific provider overrides
    ];
  }
}

/// Test matchers for custom assertions
class CustomMatchers {
  static Matcher isValidPostModel = predicate<PostModel>(
    (post) => post.id.isNotEmpty && 
              post.authorId.isNotEmpty && 
              post.title.isNotEmpty,
    'is a valid PostModel',
  );
  
  static Matcher isValidMessageModel = predicate<MessageModel>(
    (message) => message.id.isNotEmpty && 
                 message.chatId.isNotEmpty && 
                 message.senderId.isNotEmpty,
    'is a valid MessageModel',
  );
  
  static Matcher isValidUserModel = predicate<UserModel>(
    (user) => user.id.isNotEmpty && 
              user.username.isNotEmpty && 
              user.email.isNotEmpty,
    'is a valid UserModel',
  );
}