import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_model.dart';
import '../models/notification_settings_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseMessaging _messaging;

  NotificationRepository({
    FirebaseFirestore? firestore,
    FirebaseMessaging? messaging,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _messaging = messaging ?? FirebaseMessaging.instance;

  // Collection references
  CollectionReference<Map<String, dynamic>> get _notifications =>
      _firestore.collection('notifications');

  CollectionReference<Map<String, dynamic>> get _settings =>
      _firestore.collection('notificationSettings');

  // Create a new notification
  Future<NotificationModel> createNotification({
    required String recipientId,
    required String senderId,
    required NotificationType type,
    String? title,
    String? body,
    String? postId,
    String? commentId,
    String? senderName,
    String? senderUsername,
    String? senderProfileImage,
    String? senderAltProfileImage,
    bool isAlt = false,
    int? count,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create notification
      final newDoc = _notifications.doc();

      final notification = NotificationModel(
        id: newDoc.id,
        recipientId: recipientId,
        senderId: senderId,
        type: type,
        timestamp: DateTime.now(),
        isRead: false,
        title: title,
        body: body,
        postId: postId,
        commentId: commentId,
        senderName: senderName,
        senderUsername: senderUsername,
        senderProfileImage: senderProfileImage,
        senderAltProfileImage: senderAltProfileImage,
        isAlt: isAlt,
        count: count,
        data: data ?? {},
      );

      await newDoc.set(notification.toFirestore());
      return notification;
    } catch (e) {
      debugPrint('Error creating notification: $e');
      rethrow;
    }
  }

  // Get notifications for a user with pagination
  Future<List<NotificationModel>> getNotifications({
    required String userId,
    NotificationType? filterType,
    int limit = 20,
    DocumentSnapshot? startAfter,
    bool onlyUnread = false,
  }) async {
    try {
      Query<Map<String, dynamic>> query = _notifications
          .where('recipientId', isEqualTo: userId)
          .orderBy('timestamp', descending: true);

      // Apply filter if provided
      if (filterType != null) {
        query = query.where('type',
            isEqualTo: filterType.toString().split('.').last);
      }

      // Filter by read status if needed
      if (onlyUnread) {
        query = query.where('isRead', isEqualTo: false);
      }

      // Apply pagination
      query = query.limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();
    } catch (e) {
      debugPrint('Error getting notifications: $e');
      rethrow;
    }
  }

  // Mark a notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notifications.doc(notificationId).update({'isRead': true});
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Mark all notifications as read for a user
  Future<void> markAllAsRead(String userId) async {
    try {
      // Get all unread notifications for this user
      final querySnapshot = await _notifications
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      // Create a batch to update them all at once
      final batch = _firestore.batch();
      for (var doc in querySnapshot.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Error marking all notifications as read: $e');
      rethrow;
    }
  }

  // Delete a notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notifications.doc(notificationId).delete();
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      rethrow;
    }
  }

  // Get unread count for a user
  Future<int?> getUnreadCount(String userId) async {
    try {
      final querySnapshot = await _notifications
          .where('recipientId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .count()
          .get();

      return querySnapshot.count;
    } catch (e) {
      debugPrint('Error getting unread count: $e');
      rethrow;
    }
  }

  // Stream of notifications for real-time updates
  Stream<List<NotificationModel>> streamNotifications(String userId) {
    return _notifications
        .where('recipientId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100) // Reasonable limit for real-time
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return NotificationModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Get or create notification settings
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

  // Update notification settings
  Future<void> updateSettings(NotificationSettingsModel settings) async {
    try {
      await _settings.doc(settings.userId).update(settings.toFirestore());
    } catch (e) {
      debugPrint('Error updating notification settings: $e');
      rethrow;
    }
  }

  // Set FCM token for push notifications
  Future<void> setFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    } catch (e) {
      debugPrint('Error setting FCM token: $e');
      rethrow;
    }
  }

  // Get FCM token for a user
  Future<String?> getFCMToken(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        return userData['fcmToken'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      rethrow;
    }
  }

  // Request notification permissions
  Future<bool> requestNotificationPermissions() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      debugPrint('Error requesting notification permissions: $e');
      return false;
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getNotificationDocument(
      String notificationId) async {
    return await _notifications.doc(notificationId).get();
  }
}

// Provider for the repository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});
