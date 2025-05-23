import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';
import 'package:meta/meta.dart';

class NotificationService {
  final FirebaseMessaging _messaging;
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _localNotifications;

  // Channel ID for Android notifications
  static const _androidChannelId = 'high_importance_channel';
  static const _androidChannelName = 'High Importance Notifications';
  static const _androidChannelDescription =
      'This channel is used for important notifications.';

  NotificationService({
    required NotificationRepository repository,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
  })  : _repository = repository,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin();

  // Initialize notification service
  Future<void> initialize({
    required String userId,
    required Function(NotificationModel) onNotificationTap,
  }) async {
    // Step 1: Request permissions
    await _requestPermissions();

    // Step 2: Set up Android channel
    await _setupAndroidChannel();

    // Step 3: Initialize local notifications
    await _initializeLocalNotifications(onNotificationTap);

    // Step 4: Handle FCM token
    await _handleFCMToken(userId);

    // Step 5: Set up various notification handlers
    _setupNotificationHandlers(onNotificationTap);
  }

  // Step 1: Request permissions
  Future<void> _requestPermissions() async {
    // Request Firebase permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint(
        'User notification permission status: ${settings.authorizationStatus}');

    // Request local notification permissions on iOS
    await _localNotifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Step 2: Set up Android channel
  Future<void> _setupAndroidChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _androidChannelId,
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  // Step 3: Initialize local notifications
  Future<void> _initializeLocalNotifications(
    Function(NotificationModel) onNotificationTap,
  ) async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationResponse(response, onNotificationTap);
      },
    );
  }

  // Step 4: Handle FCM token
  Future<void> _handleFCMToken(String userId) async {
    // Get the current token
    String? token = await _messaging.getToken();

    if (token != null) {
      debugPrint('FCM Token: $token');
      await _repository.setFCMToken(userId, token);
    }

    // Listen for token refreshes
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
      _repository.setFCMToken(userId, newToken);
    });
  }

  // Step 5: Set up notification handlers
  void _setupNotificationHandlers(
    Function(NotificationModel) onNotificationTap,
  ) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _handleForegroundMessage(message);
    });

    // Handle when app is opened from a notification when in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleBackgroundNotificationOpen(message, onNotificationTap);
    });

    // Check for initial message (app opened from terminated state via notification)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        _handleBackgroundNotificationOpen(message, onNotificationTap);
      }
    });
  }

  // Handle foreground messages by showing a local notification
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;
    final notificationData = message.data;

    debugPrint('Handling foreground message: ${message.messageId}');
    debugPrint('Message data: ${message.data}');

    // If notification payload is present, display the notification
    if (notification != null) {
      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            'High Importance Notifications',
            channelDescription:
                'This channel is used for important notifications.',
            icon: android?.smallIcon ?? 'ic_notification',
            // Other android specific settings
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: json.encode({
          'notificationId': message.data['notificationId'] ?? '',
          'type': message.data['type'] ?? '',
          'senderId': message.data['senderId'] ?? '',
          'postId': message.data['postId'] ?? '',
          'commentId': message.data['commentId'] ?? '',
          // Additional payload data
          ...notificationData,
        }),
      );
    }
  }

  void _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      await _localNotifications.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannelId,
            _androidChannelName,
            channelDescription: _androidChannelDescription,
            icon: '@mipmap/ic_launcher',
            importance: Importance.high,
            playSound: true,
            priority: Priority.high,
            enableVibration: true,
            fullScreenIntent: false,
            category: AndroidNotificationCategory.social,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            badgeNumber: null,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error showing local notification: $e');
    }
  }

  // Handle notification response (tap)
  void _handleNotificationResponse(
    NotificationResponse response,
    Function(NotificationModel) onNotificationTap,
  ) async {
    if (response.payload != null) {
      try {
        final payloadData =
            json.decode(response.payload!) as Map<String, dynamic>;
        final notificationId = payloadData['notificationId'];

        if (notificationId != null && notificationId.isNotEmpty) {
          // Fetch the notification from Firestore
          final notificationDoc =
              await _repository.getNotificationDocument(notificationId);

          if (notificationDoc.exists) {
            final notificationModel =
                NotificationModel.fromFirestore(notificationDoc);

            // Mark as read
            await _repository.markAsRead(notificationId);

            // Call the callback
            onNotificationTap(notificationModel);
          }
        }
      } catch (e) {
        debugPrint('Error handling notification tap: $e');
      }
    }
  }

  // Handle notification open from background/terminated state
  void _handleBackgroundNotificationOpen(
    RemoteMessage message,
    Function(NotificationModel) onNotificationTap,
  ) async {
    final notificationId = message.data['notificationId'];

    if (notificationId != null && notificationId.isNotEmpty) {
      try {
        // Fetch the notification from Firestore
        final notificationDoc =
            await _repository.getNotificationDocument(notificationId);

        if (notificationDoc.exists) {
          final notificationModel =
              NotificationModel.fromFirestore(notificationDoc);

          // Mark as read
          await _repository.markAsRead(notificationId);

          // Call the callback
          onNotificationTap(notificationModel);
        }
      } catch (e) {
        debugPrint('Error handling background notification open: $e');
      }
    }
  }

  // Subscribe to topics (useful for broadcast notifications)
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  // Handle background messages - this must be a top-level function
  static Future<void> backgroundMessageHandler(RemoteMessage message) async {
    // Keep background message handling minimal as it runs outside Flutter context
    debugPrint('Handling background message: ${message.messageId}');
  }

  // Clear all notifications with try-catch
  Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      debugPrint('All notifications cleared');
    } catch (e) {
      debugPrint('Error clearing notifications: $e');
    }
  }

  // Get derived notifications (iOS only)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _localNotifications.pendingNotificationRequests();
    } catch (e) {
      debugPrint('❌ Error getting pending notifications: $e');
      return [];
    }
  }
}

// Provider for the service
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final repository = ref.watch(notificationRepositoryProvider);
  return NotificationService(repository: repository);
});
