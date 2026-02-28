import 'dart:convert';
import 'dart:ui';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/social/notifications/data/repositories/notification_repository.dart';

class NotificationService {
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _localNotifications;

  // Channel configuration
  static const _androidChannelId = 'high_importance_channel';
  static const _androidChannelName = 'High Importance Notifications';
  static const _androidChannelDescription =
      'This channel is used for important notifications.';

  NotificationService({
    required NotificationRepository repository,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _repository = repository,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  Future<void> testLocalNotification() async {
    debugPrint('Testing local notification...');

    try {
      const androidDetails = AndroidNotificationDetails(
        'test_channel',
        'Test Channel',
        channelDescription: 'Test notifications',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF6B35FF),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        999,
        'Test Local Notification',
        'This is a test of local notifications',
        details,
      );

      debugPrint('Local notification sent');
    } catch (e) {
      debugPrint('Error sending local notification: $e');
    }
  }

  /// Complete FCM debug test combining repository and service
  Future<Map<String, dynamic>> fullFCMDebugTest() async {
    debugPrint('Running full FCM debug test...');

    try {
      // Test 1: Repository debug
      final repoResult = await _repository.debugFCMToken();
      debugPrint('📊 Repository test result: $repoResult');

      // Test 2: Local notification
      await testLocalNotification();

      // Test 3: Check permissions
      final permissionsEnabled = await areNotificationsEnabled();
      debugPrint('Notifications enabled: $permissionsEnabled');

      return {
        'repositoryTest': repoResult,
        'localNotificationSent': true,
        'permissionsEnabled': permissionsEnabled,
        'recommendations':
            _generateDebugRecommendations(repoResult, permissionsEnabled),
      };
    } catch (e) {
      debugPrint('Full debug test failed: $e');
      return {
        'error': e.toString(),
        'recommendations': [
          'Check Firebase configuration',
          'Verify imports',
          'Check device permissions'
        ],
      };
    }
  }

  List<String> _generateDebugRecommendations(
      Map<String, dynamic> repoResult, bool permissionsEnabled) {
    final recommendations = <String>[];

    if (!permissionsEnabled) {
      recommendations.add('Enable notification permissions');
    }

    if (repoResult.containsKey('error')) {
      recommendations.add('Fix Firebase configuration: ${repoResult['error']}');
    } else if (repoResult['cloudFunctionResult']?['success'] == false) {
      final error =
          repoResult['cloudFunctionResult']?['error'] ?? 'Unknown error';
      if (error.contains('INVALID_REGISTRATION_TOKEN')) {
        recommendations
            .add('FCM token is invalid - check google-services.json');
      } else if (error.contains('SENDER_ID_MISMATCH')) {
        recommendations
            .add('Sender ID mismatch - verify Firebase project configuration');
      } else {
        recommendations.add('Cloud function error: $error');
      }
    } else if (repoResult['cloudFunctionResult']?['messageSent'] == true) {
      recommendations.add('FCM is working correctly!');
      recommendations.add('💡 If you still don\'t see notifications, check:');
      recommendations.add(' - App is in background during test');
      recommendations.add(' - Notification channel is created correctly');
      recommendations.add(' - Device notification settings');
    }

    if (recommendations.isEmpty) {
      recommendations.add('All tests passed - FCM should be working');
    }

    return recommendations;
  }

  /// Initialize the complete notification system
  Future<bool> initialize({
    required Function(NotificationModel) onNotificationTap,
    Function(Map<String, dynamic>)? onForegroundMessage,
  }) async {
    try {
      debugPrint('Initializing notification service...');

      // Step 1: Set up local notifications
      await _setupLocalNotifications(onNotificationTap);

      // Step 2: Initialize FCM and get token
      final token = await _repository.initializeFCM();
      if (token == null) {
        debugPrint('FCM initialization failed - no token received');
        return false;
      }

      // Step 3: Set up FCM message handlers
      _repository.setupFCMHandlers(
        onMessageReceived: (data) =>
            _handleForegroundMessage(data, onForegroundMessage),
        onMessageTapped: (data) => _handleMessageTap(data, onNotificationTap),
      );

      // Step 4: Test cloud function connectivity
      final testResult = await _repository.testCloudFunctionConnectivity();
      if (!testResult['success']) {
        debugPrint(
            'Cloud function connectivity test failed: ${testResult['error']}');
        return false;
      }

      debugPrint('Notification service initialized successfully');
      return true;
    } catch (e) {
      debugPrint('Error initializing notification service: $e');
      return false;
    }
  }

  /// Set up local notifications for foreground display
  Future<void> _setupLocalNotifications(
      Function(NotificationModel) onNotificationTap) async {
    // Android initialization
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // We handle permissions in FCM setup
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) =>
          _handleLocalNotificationTap(response, onNotificationTap),
    );

    // Create Android notification channel
    await _createAndroidChannel();
  }

  /// Create Android notification channel
  Future<void> _createAndroidChannel() async {
    const channel = AndroidNotificationChannel(
      _androidChannelId,
      _androidChannelName,
      description: _androidChannelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Handle foreground messages by showing local notification
  void _handleForegroundMessage(
    Map<String, dynamic> messageData,
    Function(Map<String, dynamic>)? onForegroundMessage,
  ) {
    debugPrint('Handling foreground message: ${messageData['title']}');

    // Call custom handler if provided
    onForegroundMessage?.call(messageData);

    // Show local notification
    _showLocalNotification(
      title: messageData['title'] ?? 'New Notification',
      body: messageData['body'] ?? '',
      payload: jsonEncode(messageData['data'] ?? {}),
    );
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        color: Color(0xFF6B35FF),
        category: AndroidNotificationCategory.social,
        visibility: NotificationVisibility.public,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000, // Use timestamp as ID
        title,
        body,
        details,
        payload: payload,
      );

      debugPrint('Local notification shown: $title');
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  /// Handle message tap (from FCM handler)
  void _handleMessageTap(
    Map<String, dynamic> messageData,
    Function(NotificationModel) onNotificationTap,
  ) {
    debugPrint('👆 Message tapped: ${messageData['title']}');

    final data = messageData['data'] as Map<String, dynamic>? ?? {};
    _processNotificationTap(data, onNotificationTap);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(
    NotificationResponse response,
    Function(NotificationModel) onNotificationTap,
  ) {
    debugPrint('👆 Local notification tapped');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _processNotificationTap(data, onNotificationTap);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// Process notification tap and create NotificationModel
  void _processNotificationTap(
    Map<String, dynamic> data,
    Function(NotificationModel) onNotificationTap,
  ) async {
    try {
      final notificationId = data['notificationId'] as String?;

      if (notificationId == null || notificationId.isEmpty) {
        debugPrint('No notification ID in tap data');
        return;
      }

      // Create a minimal NotificationModel from the available data
      final notification = NotificationModel(
        id: notificationId,
        recipientId: '', // Will be filled by the app if needed
        senderId: data['senderId'] ?? '',
        type: _parseNotificationType(data['type']),
        timestamp: DateTime.now(), // Placeholder
        isRead: true, // Assume read when tapped
        postId: data['postId']?.isNotEmpty == true ? data['postId'] : null,
        commentId:
            data['commentId']?.isNotEmpty == true ? data['commentId'] : null,
        isAlt: data['isAlt'] == 'true',
        path: data['path']?.isNotEmpty == true ? data['path'] : null,
      );

      debugPrint('🎯 Processing notification tap: ${notification.id}');
      onNotificationTap(notification);

      // Mark as read via cloud function (fire and forget)
      _repository.markAsRead(notificationIds: [notificationId]).catchError((e) {
        debugPrint('Failed to mark notification as read: $e');
        return <String, dynamic>{}; // Return empty map to satisfy return type
      });
    } catch (e) {
      debugPrint('Error processing notification tap: $e');
    }
  }

  /// Parse notification type from string
  NotificationType _parseNotificationType(dynamic typeData) {
    if (typeData == null) return NotificationType.follow;

    try {
      return NotificationType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            typeData.toString().toLowerCase(),
        orElse: () => NotificationType.follow,
      );
    } catch (e) {
      return NotificationType.follow;
    }
  }

  /// Clear all notifications and reset badge count
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();

      // Clear iOS app badge
      await _clearIOSBadge();

      debugPrint('All local notifications cleared');
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  /// Clear iOS app badge count
  Future<void> _clearIOSBadge() async {
    try {
      // Clear badge using flutter_local_notifications
      final iosImpl = _localNotifications.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();

      if (iosImpl != null) {
        await iosImpl.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }

      // Set badge to 0 to clear it
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    } catch (e) {
      debugPrint('Could not clear iOS badge: $e');
    }
  }

  /// Update app badge count based on unread notifications
  Future<void> updateBadgeCount(int unreadCount) async {
    try {
      // This will be handled by FCM automatically when sending notifications
      // with the proper badge count in the APNS payload
      debugPrint('Badge count should be: $unreadCount');
    } catch (e) {
      debugPrint('Error updating badge count: $e');
    }
  }

  /// Get pending notification requests (for debugging)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('Error getting pending notifications: $e');
      return [];
    }
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    try {
      // Check local notification permission
      final androidImpl =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      if (androidImpl != null) {
        final granted = await androidImpl.areNotificationsEnabled();
        return granted ?? false;
      }

      // For iOS, check FCM authorization status
      final settings =
          await FirebaseMessaging.instance.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('Error checking notification permissions: $e');
      return false;
    }
  }

  /// Request notification permissions
  Future<bool> requestPermissions() async {
    try {
      debugPrint('Requesting notification permissions...');

      // Request FCM permissions
      final settings = await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final granted =
          settings.authorizationStatus == AuthorizationStatus.authorized;
      debugPrint(granted
          ? 'Notification permissions granted'
          : 'Notification permissions denied');

      return granted;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  /// Show a test notification (for debugging)
  Future<void> showTestNotification() async {
    await _showLocalNotification(
      title: 'Test Notification',
      body: 'This is a test notification from your app.',
      payload: jsonEncode({
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      }),
    );
  }
}

// Provider for the notification service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationService(repository: repository);
});

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Background message received: ${message.messageId}');
  debugPrint('Title: ${message.notification?.title}');
  debugPrint('Body: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');

  // Keep background processing minimal
  // The app will handle the notification when opened
}
