import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import '../models/notification_settings_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance,
        _functions = functions ?? FirebaseFunctions.instance;

  // Collection references (kept for settings and local operations)
  CollectionReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('notificationSettings');

  // ========== CLOUD FUNCTION CALLS ==========

  /// Get notifications using cloud function (replaces direct Firestore query)
  Future<Map<String, dynamic>> getNotifications({
    NotificationType? filterType,
    int limit = 20,
    String? lastNotificationId,
    bool onlyUnread = false,
    bool markAsRead = true, // Auto-mark as read by default
  }) async {
    try {
      debugPrint('🔔 ========== STARTING getNotifications ==========');
      debugPrint('🔔 Parameters received:');
      debugPrint('   - limit: $limit');
      debugPrint('   - markAsRead: $markAsRead');
      debugPrint('   - onlyUnread: $onlyUnread');
      debugPrint('   - filterType: $filterType');
      debugPrint('   - lastNotificationId: $lastNotificationId');

      // Test Firebase Functions connection
      debugPrint('🔧 Testing Firebase Functions connection...');
      debugPrint('   - Functions instance: $_functions');
      debugPrint('   - App name: ${_functions.app.name}');

      final callable = _functions.httpsCallable('getNotifications');
      debugPrint('✅ Created callable for: getNotifications');

      // Prepare call parameters
      final callParams = {
        'limit': limit,
        'lastNotificationId': lastNotificationId,
        'filterType': filterType?.toString().split('.').last,
        'onlyUnread': onlyUnread,
        'markAsRead': markAsRead,
      };

      debugPrint('📤 Calling cloud function with parameters:');
      callParams.forEach((key, value) {
        debugPrint('   - $key: $value (${value.runtimeType})');
      });

      // Make the call
      debugPrint('📞 Making cloud function call...');
      final result = await callable.call(callParams);
      debugPrint('✅ Cloud function call completed successfully');

      // Analyze the response
      debugPrint('📥 ========== ANALYZING RESPONSE ==========');
      debugPrint('   - Result type: ${result.runtimeType}');
      debugPrint('   - Result.data type: ${result.data.runtimeType}');
      debugPrint('   - Result.data: ${result.data}');

      final data = result.data as Map<String, dynamic>;
      debugPrint('📊 Response data structure:');
      data.forEach((key, value) {
        debugPrint(
            '   - $key: ${value.runtimeType} = ${value is List ? '(List with ${value.length} items)' : value.toString().substring(0, value.toString().length > 100 ? 100 : value.toString().length)}');
      });

      // Check for notifications array
      final rawNotifications = data['notifications'];
      debugPrint('🔍 ========== PROCESSING NOTIFICATIONS ==========');
      debugPrint(
          '   - Raw notifications type: ${rawNotifications.runtimeType}');

      if (rawNotifications == null) {
        debugPrint('❌ ERROR: notifications field is null!');
        return {
          'notifications': <NotificationModel>[],
          'unreadCount': data['unreadCount'] ?? 0,
          'hasMore': data['hasMore'] ?? false,
          'lastNotificationId': data['lastNotificationId'],
        };
      }

      if (rawNotifications is! List) {
        debugPrint(
            '❌ ERROR: notifications is not a List! Type: ${rawNotifications.runtimeType}');
        return {
          'notifications': <NotificationModel>[],
          'unreadCount': data['unreadCount'] ?? 0,
          'hasMore': data['hasMore'] ?? false,
          'lastNotificationId': data['lastNotificationId'],
        };
      }

      final notificationsList = rawNotifications as List<dynamic>;
      debugPrint(
          '📝 Processing ${notificationsList.length} raw notification items:');

      // Process each notification with detailed logging
      final notificationList = <NotificationModel>[];

      for (int i = 0; i < notificationsList.length; i++) {
        final rawNotification = notificationsList[i];
        debugPrint('🔄 ========== PROCESSING NOTIFICATION $i ==========');
        debugPrint('   - Raw type: ${rawNotification.runtimeType}');
        debugPrint(
            '   - Raw data: ${rawNotification.toString().substring(0, rawNotification.toString().length > 200 ? 200 : rawNotification.toString().length)}...');

        try {
          final parsed = _parseNotificationFromCloudFunction(rawNotification);
          if (parsed != null) {
            notificationList.add(parsed);
            debugPrint(
                '   ✅ Successfully parsed notification $i: ${parsed.id}');
          } else {
            debugPrint('   ❌ Failed to parse notification $i (returned null)');
          }
        } catch (parseError, stackTrace) {
          debugPrint('   ❌ Exception parsing notification $i: $parseError');
          debugPrint('   📋 Stack trace: $stackTrace');
        }
      }

      debugPrint('📊 ========== FINAL RESULTS ==========');
      debugPrint('   - Raw notifications count: ${notificationsList.length}');
      debugPrint('   - Successfully parsed count: ${notificationList.length}');
      debugPrint(
          '   - Failed to parse count: ${notificationsList.length - notificationList.length}');
      debugPrint('   - Unread count: ${data['unreadCount']}');
      debugPrint('   - Has more: ${data['hasMore']}');
      debugPrint('   - Last notification ID: ${data['lastNotificationId']}');

      if (notificationList.isNotEmpty) {
        debugPrint(
            '   - First notification: ${notificationList.first.id} (${notificationList.first.type})');
        debugPrint(
            '   - Last notification: ${notificationList.last.id} (${notificationList.last.type})');
      }

      final result_map = {
        'notifications': notificationList,
        'unreadCount': data['unreadCount'] ?? 0,
        'hasMore': data['hasMore'] ?? false,
        'lastNotificationId': data['lastNotificationId'],
      };

      debugPrint('✅ ========== RETURNING RESULT ==========');
      debugPrint('   - Result map keys: ${result_map.keys.toList()}');
      debugPrint('   - Returning ${notificationList.length} notifications');

      return result_map;
    } catch (e, stackTrace) {
      debugPrint('❌ ========== ERROR IN getNotifications ==========');
      debugPrint('   - Error type: ${e.runtimeType}');
      debugPrint('   - Error message: $e');
      debugPrint('   - Stack trace: $stackTrace');

      // Log additional context for specific error types
      if (e.toString().contains('PERMISSION_DENIED')) {
        debugPrint(
            '🔐 PERMISSION ERROR: Check Firebase rules and authentication');
      } else if (e.toString().contains('UNAUTHENTICATED')) {
        debugPrint('🔒 AUTH ERROR: User might not be properly authenticated');
      } else if (e.toString().contains('INTERNAL')) {
        debugPrint('🔧 INTERNAL ERROR: Check cloud function logs');
      } else if (e.toString().contains('NOT_FOUND')) {
        debugPrint('🔍 NOT FOUND: Cloud function might not be deployed');
      }

      rethrow;
    }
  }

  /// Get unread count using cloud function
  Future<int> getUnreadCount() async {
    try {
      debugPrint('🔔 Getting unread count via cloud function');

      final callable = _functions.httpsCallable('getUnreadNotificationCount');
      final result = await callable.call();

      final count = result.data['unreadCount'] ?? 0;
      debugPrint('✅ Unread count: $count');

      return count;
    } catch (e) {
      debugPrint('❌ Error getting unread count from cloud function: $e');
      rethrow;
    }
  }

  /// Mark notifications as read using cloud function
  Future<Map<String, dynamic>> markAsRead(
      {List<String>? notificationIds}) async {
    try {
      debugPrint('🔔 Marking notifications as read via cloud function');

      final callable = _functions.httpsCallable('markNotificationsAsRead');
      final result = await callable.call({
        if (notificationIds != null) 'notificationIds': notificationIds,
      });

      final data = result.data as Map<String, dynamic>;
      debugPrint('✅ Marked ${data['count']} notifications as read');

      return data;
    } catch (e) {
      debugPrint('❌ Error marking notifications as read: $e');
      rethrow;
    }
  }

  /// Update FCM token using cloud function
  Future<void> updateFCMToken(String token) async {
    try {
      debugPrint('🔔 Updating FCM token via cloud function');

      final callable = _functions.httpsCallable('updateFCMToken');
      await callable.call({'fcmToken': token});

      debugPrint('✅ FCM token updated successfully');
    } catch (e) {
      debugPrint('❌ Error updating FCM token: $e');
      rethrow;
    }
  }

  /// Debug FCM token and test push notification
  Future<Map<String, dynamic>> debugFCMToken() async {
    try {
      debugPrint('🧪 Testing FCM token...');

      // First check if we can get the token locally
      final token = await _messaging.getToken();
      debugPrint('📱 Current FCM token: ${token?.substring(0, 20)}...');

      // Check notification permissions
      final settings = await _messaging.getNotificationSettings();
      debugPrint('🔐 Notification permission: ${settings.authorizationStatus}');

      // Call the debug cloud function
      final callable = _functions.httpsCallable('debugFCMToken');
      final result = await callable.call();

      final data = result.data as Map<String, dynamic>;
      debugPrint('☁️ Cloud function result: $data');

      return {
        'localToken': token,
        'hasLocalToken': token != null,
        'permissionStatus': settings.authorizationStatus.name,
        'cloudFunctionResult': data,
      };
    } catch (e) {
      debugPrint('❌ Error in FCM debug: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  // ========== HELPER METHODS ==========

  /// Parse notification data from cloud function response
  NotificationModel? _parseNotificationFromCloudFunction(dynamic data) {
    try {
      // Handle different data types that can come from cloud functions
      Map<String, dynamic> notificationData;

      if (data is Map<String, dynamic>) {
        notificationData = data;
      } else if (data is Map<Object?, Object?>) {
        // Convert Map<Object?, Object?> to Map<String, dynamic>
        notificationData = <String, dynamic>{};
        data.forEach((key, value) {
          final stringKey = key?.toString() ?? '';
          notificationData[stringKey] = value;
        });
      } else if (data is Map) {
        // Handle any other Map type
        notificationData = Map<String, dynamic>.from(data);
      } else {
        debugPrint('❌ Unexpected data type: ${data.runtimeType}');
        return null;
      }

      debugPrint('📝 Parsing notification data: ${notificationData.keys}');

      return NotificationModel(
        id: notificationData['id']?.toString() ?? '',
        recipientId: notificationData['recipientId']?.toString() ?? '',
        senderId: notificationData['senderId']?.toString() ?? '',
        type: _parseNotificationType(notificationData['type']),
        timestamp: _parseTimestamp(notificationData['timestamp']),
        isRead: _parseBool(notificationData['isRead']),
        title: notificationData['title']?.toString(),
        body: notificationData['body']?.toString(),
        postId: notificationData['postId']?.toString(),
        commentId: notificationData['commentId']?.toString(),
        senderName: notificationData['senderName']?.toString(),
        senderUsername: notificationData['senderUsername']?.toString(),
        senderProfileImage: notificationData['senderProfileImage']?.toString(),
        senderAltProfileImage:
            notificationData['senderAltProfileImage']?.toString(),
        isAlt: _parseBool(notificationData['isAlt']),
        count: _parseInt(notificationData['count']),
        path: notificationData['path']?.toString(),
        data: _parseDataMap(notificationData['data']),
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error parsing notification from cloud function: $e');
      debugPrint('Stack trace: $stackTrace');
      debugPrint('Data type: ${data.runtimeType}');
      debugPrint('Data: $data');
      return null;
    }
  }

  /// Helper method to safely parse boolean values
  bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return false;
  }

  /// Helper method to safely parse integer values
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) return value.toInt();
    return null;
  }

  /// Helper method to safely parse data map
  Map<String, dynamic> _parseDataMap(dynamic value) {
    if (value == null) return {};
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }

  /// Parse notification type safely
  NotificationType _parseNotificationType(dynamic typeData) {
    if (typeData == null) return NotificationType.follow;

    String typeString = typeData.toString();
    try {
      return NotificationType.values.firstWhere(
        (e) =>
            e.toString().split('.').last.toLowerCase() ==
            typeString.toLowerCase(),
        orElse: () => NotificationType.follow,
      );
    } catch (e) {
      debugPrint('Error parsing notification type: $typeString');
      return NotificationType.follow;
    }
  }

  /// Parse timestamp safely
  DateTime _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return DateTime.now();

    try {
      if (timestampData is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampData);
      } else if (timestampData is Timestamp) {
        return timestampData.toDate();
      } else if (timestampData is DateTime) {
        return timestampData;
      } else if (timestampData is String) {
        return DateTime.parse(timestampData);
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $timestampData, error: $e');
    }

    return DateTime.now();
  }

  // ========== LOCAL OPERATIONS (Settings, FCM Setup) ==========

  /// Get or create notification settings (local Firestore operation)
  Future<NotificationSettingsModel> getOrCreateSettings(String userId) async {
    try {
      final docRef = _settings.doc(userId);
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        return NotificationSettingsModel.fromFirestore(docSnapshot);
      } else {
        // Create default settings
        final defaultSettings = NotificationSettingsModel(userId: userId);
        await docRef.set(defaultSettings.toFirestore());
        return defaultSettings;
      }
    } catch (e) {
      debugPrint('Error getting notification settings: $e');
      rethrow;
    }
  }

  /// Update notification settings (local Firestore operation)
  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      await _settings.doc(settings.userId).update(settings.toFirestore());
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }

  /// Initialize FCM and get token
  Future<String?> initializeFCM() async {
    try {
      debugPrint('🚀 ===== FCM INITIALIZATION START =====');

      // Request permissions
      debugPrint('🔐 Requesting FCM permissions...');
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      debugPrint('🔐 Permission result: ${settings.authorizationStatus}');
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        debugPrint('⚠️ Notification permissions not granted');
        return null;
      }

      // Get FCM token
      debugPrint('📱 Getting FCM token...');
      final token = await _messaging.getToken();
      debugPrint('📱 FCM Token obtained: ${token?.substring(0, 20)}...');

      if (token != null) {
        // Update token via cloud function
        debugPrint('☁️ Updating FCM token via cloud function...');
        try {
          await updateFCMToken(token);
          debugPrint('✅ FCM token updated successfully during initialization');
        } catch (updateError) {
          debugPrint(
              '❌ ERROR updating FCM token during initialization: $updateError');
          // Don't return null here - continue with initialization even if update fails
        }

        // Listen for token refresh
        debugPrint('👂 Setting up token refresh listener...');
        _messaging.onTokenRefresh.listen((newToken) {
          debugPrint('🔄 FCM Token refreshed: ${newToken.substring(0, 20)}...');
          updateFCMToken(newToken).catchError((error) {
            debugPrint('❌ Error updating refreshed FCM token: $error');
          });
        });

        debugPrint('✅ ===== FCM INITIALIZATION COMPLETE =====');
      } else {
        debugPrint('❌ ===== FCM INITIALIZATION FAILED - NO TOKEN =====');
      }

      return token;
    } catch (e) {
      debugPrint('❌ ===== FCM INITIALIZATION ERROR =====');
      debugPrint('❌ Error initializing FCM: $e');
      return null;
    }
  }

  /// Set up FCM message handlers
  void setupFCMHandlers({
    required Function(Map<String, dynamic>) onMessageReceived,
    required Function(Map<String, dynamic>) onMessageTapped,
  }) {
    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
          '📱 Foreground message received: ${message.notification?.title}');

      final data = {
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
      };

      onMessageReceived(data);
    });

    // Handle message taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
          '📱 Message tapped (background): ${message.notification?.title}');

      final data = {
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
      };

      onMessageTapped(data);
    });

    // Handle initial message (app opened from terminated state)
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        debugPrint('📱 Initial message: ${message.notification?.title}');

        final data = {
          'title': message.notification?.title ?? '',
          'body': message.notification?.body ?? '',
          'data': message.data,
        };

        onMessageTapped(data);
      }
    });
  }

  // ========== DEBUG METHODS ==========
  Future<Map<String, dynamic>> debugTokenUpdate() async {
    try {
      debugPrint('🔧 Debugging FCM token update...');

      // Get current token
      final token = await _messaging.getToken();
      debugPrint('📱 Current FCM token: ${token?.substring(0, 20)}...');

      if (token == null) {
        debugPrint('⚠️ No FCM token found');
        return {'error': 'No FCM token found'};
      }

      // Check notification permissions
      final settings = await _messaging.getNotificationSettings();
      debugPrint('🔐 Notification permission: ${settings.authorizationStatus}');

      try {
        await updateFCMToken(token);
        debugPrint('✅ FCM token updated successfully');
      } catch (e) {
        debugPrint('❌ Error checking notification settings: $e');
        return {'error': 'Failed to update FCM token: $e'};
      }

      await Future.delayed(const Duration(seconds: 2));

      debugPrint('Checking if the token was saved successfully...');
      final debugResult = await debugFCMToken();

      return {
        'localToken': token,
        'hasLocalToken': token != null,
        'permissionStatus': settings.authorizationStatus.name,
        'cloudFunctionResult': debugResult,
      };
    } catch (e) {
      debugPrint('❌ Error in debugTokenUpdate: $e');
      return {'error': e.toString()};
    }
  }

  // ========== LEGACY METHODS (for backward compatibility) ==========

  /// Delete a notification (local operation for admin/cleanup)
  Future<void> deleteNotification(String notificationId) async {
    try {
      final callable = _functions.httpsCallable('deleteNotifications');
      await callable.call({
        'notificationIds': [notificationId]
      });
      debugPrint('✅ Notification deleted: $notificationId');
    } catch (e) {
      debugPrint('❌ Error deleting notification: $e');
      rethrow;
    }
  }

  /// Stream of notifications for real-time updates (local operation)
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    debugPrint('🔄 Starting notification stream for user: $userId');

    return _firestore
        .collection('notifications')
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50) // Reasonable limit for real-time updates
        .snapshots()
        .map((snapshot) {
      debugPrint('📱 Stream update: ${snapshot.docs.length} notifications');

      final notifications = <NotificationModel>[];
      for (final doc in snapshot.docs) {
        try {
          notifications.add(NotificationModel.fromFirestore(doc));
        } catch (e) {
          debugPrint('❌ Error parsing streamed notification ${doc.id}: $e');
        }
      }

      return notifications;
    }).handleError((error) {
      debugPrint('❌ Error in notification stream: $error');
    });
  }

  /// Test method to verify cloud function connectivity
  Future<Map<String, dynamic>> testCloudFunctionConnectivity() async {
    try {
      debugPrint('🧪 Testing cloud function connectivity...');

      final result = await getUnreadCount();

      return {
        'success': true,
        'message': 'Cloud functions are working',
        'unreadCount': result,
      };
    } catch (e) {
      debugPrint('❌ Cloud function test failed: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}

// Provider for the repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});
