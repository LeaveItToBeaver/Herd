import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

enum NotificationType {
  follow,
  newPost,
  postLike,
  comment,
  commentReply,
  connectionRequest,
  connectionAccepted,
  postMilestone // For reaching a threshold of likes/comments
}

@freezed
abstract class NotificationModel with _$NotificationModel {
  const NotificationModel._(); // For custom methods

  const factory NotificationModel({
    required String id,
    String?
        recipientId, // Made optional since it's now implicit in the document path
    required String senderId, // User who triggered the notification
    required NotificationType type,
    required DateTime timestamp,
    @Default(false) bool isRead,
    String? title,
    String? body,
    // Fields for specific notification types
    String? postId,
    String? commentId,
    String? senderName,
    String? senderUsername,
    String? senderProfileImage,
    String? senderAltProfileImage,
    @Default(false) bool isAlt, // If from alt profile
    int? count, // For metrics (e.g., "5 likes on your post")
    // Navigation path for the notification
    String? path,
    // Additional metadata
    @Default({}) Map<String, dynamic> data,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;

      // Debug print to see what data we're getting
      debugPrint('Notification data from Firestore: $data');

      return NotificationModel(
        id: doc.id,
        senderId: data['senderId'] ?? '',
        type: _parseNotificationType(data['type']),
        timestamp: _parseTimestamp(data['timestamp']),
        isRead: data['isRead'] ?? false,
        title: data['title'],
        body: data['body'],
        postId: data['postId'],
        commentId: data['commentId'],
        senderName: data['senderName'],
        senderUsername: data['senderUsername'],
        senderProfileImage: data['senderProfileImage'],
        senderAltProfileImage: data['senderAltProfileImage'],
        isAlt: data['isAlt'] ?? false,
        count: data['count'],
        path: data['path'] ?? _generatePath(data),
        data: data['data'] ?? {},
      );
    } catch (e) {
      debugPrint('Error parsing notification from Firestore: $e');
      debugPrint('Document ID: ${doc.id}');
      debugPrint('Document data: ${doc.data()}');
      rethrow;
    }
  }

  // Helper method to parse notification type safely
  static NotificationType _parseNotificationType(dynamic typeData) {
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

  // Helper method to parse timestamp safely
  static DateTime _parseTimestamp(dynamic timestampData) {
    if (timestampData == null) return DateTime.now();

    try {
      if (timestampData is Timestamp) {
        return timestampData.toDate();
      } else if (timestampData is DateTime) {
        return timestampData;
      } else if (timestampData is String) {
        return DateTime.parse(timestampData);
      } else if (timestampData is int) {
        return DateTime.fromMillisecondsSinceEpoch(timestampData);
      }
    } catch (e) {
      debugPrint('Error parsing timestamp: $timestampData, error: $e');
    }

    return DateTime.now();
  }

  // Generate path if not provided
  static String? _generatePath(Map<String, dynamic> data) {
    final type = _parseNotificationType(data['type']);
    final senderId = data['senderId'];
    final postId = data['postId'];
    final commentId = data['commentId'];
    final isAlt = data['isAlt'] ?? false;

    switch (type) {
      case NotificationType.follow:
        // Use publicProfile as default for follow notifications
        return senderId != null ? '/publicProfile/$senderId' : null;

      case NotificationType.newPost:
      case NotificationType.postLike:
      case NotificationType.postMilestone:
        return postId != null ? '/post/$postId?isAlt=$isAlt' : null;

      case NotificationType.comment:
        return postId != null
            ? '/post/$postId?isAlt=$isAlt&showComments=true'
            : null;

      case NotificationType.commentReply:
        return postId != null && commentId != null
            ? '/commentThread'
            : null; // Use the route without query params, pass data via extra

      case NotificationType.connectionRequest:
        return '/connection-requests'; // Match your router's path

      case NotificationType.connectionAccepted:
        // Connection accepted usually means alt profile interaction
        return senderId != null ? '/altProfile/$senderId' : null;
    }
  }

  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'type': type.toString().split('.').last,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'title': title,
      'body': body,
      'postId': postId,
      'commentId': commentId,
      'senderName': senderName,
      'senderUsername': senderUsername,
      'senderProfileImage': senderProfileImage,
      'senderAltProfileImage': senderAltProfileImage,
      'isAlt': isAlt,
      'count': count,
      'path': path ??
          _generatePath({
            'type': type.toString().split('.').last,
            'senderId': senderId,
            'postId': postId,
            'commentId': commentId,
            'isAlt': isAlt,
          }),
      'data': data,
    };
  }

  // Helper method to get a display message for this notification
  String getDisplayMessage() {
    switch (type) {
      case NotificationType.follow:
        return '$senderName started following you';
      case NotificationType.newPost:
        return '$senderName created a new post';
      case NotificationType.postLike:
        return '$senderName liked your post';
      case NotificationType.comment:
        return '$senderName commented on your post';
      case NotificationType.commentReply:
        return '$senderName replied to your comment';
      case NotificationType.connectionRequest:
        return '$senderName sent you a connection request';
      case NotificationType.connectionAccepted:
        return '$senderName accepted your connection request';
      case NotificationType.postMilestone:
        return 'Your post reached $count likes';
    }
  }

  // Get the navigation path for this notification
  String? getNavigationPath() {
    return path ??
        _generatePath({
          'type': type.toString().split('.').last,
          'senderId': senderId,
          'postId': postId,
          'commentId': commentId,
          'isAlt': isAlt,
        });
  }
}
