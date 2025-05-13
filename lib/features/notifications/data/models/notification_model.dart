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
    required String recipientId,
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
    // Additional metadata
    @Default({}) Map<String, dynamic> data,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      recipientId: data['recipientId'] ?? '',
      senderId: data['senderId'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString().split('.').last == data['type'],
        orElse: () => NotificationType.follow,
      ),
      timestamp: (data['timestamp'] as Timestamp).toDate(),
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
      data: data['data'] ?? {},
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'recipientId': recipientId,
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
      default:
        return 'You have a new notification';
    }
  }
}
