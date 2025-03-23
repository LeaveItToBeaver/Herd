import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String authorId;
  final String? username;
  final String? profileImageURL;
  final String? herdId;  // If post belongs to a herd
  final String title;
  final String content;
  final String? imageUrl;       // Full resolution image
  final String? thumbnailUrl;   // Compressed image for feed
  final String? mediaType;      // 'image', 'video', 'gif', etc.
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isPrivate; // Added to distinguish private and public posts

  PostModel({
    required this.id,
    required this.authorId,
    this.username,
    this.profileImageURL,
    this.herdId,
    required this.title,
    required this.content,
    this.imageUrl,
    this.thumbnailUrl,
    this.mediaType,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    this.createdAt,
    this.updatedAt,
    this.isPrivate = false, // Default to public
  });

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      try {
        return value.toDate();
      } catch (e) {
        print('Error parsing Timestamp: $e');
        return null;
      }
    } else if (value is String) {
      return DateTime.tryParse(value);
    }

    print('Unknown date format: $value (${value.runtimeType})');
    return null;
  }

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      username: map['username'],
      profileImageURL: map['profileImageURL'],
      herdId: map['herdId'],
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      thumbnailUrl: map['thumbnailUrl'],
      mediaType: map['mediaType'],
      likeCount: map['likeCount'] ?? 0,
      dislikeCount: map['dislikeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      isPrivate: map['isPrivate'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'username': username,
      'profileImageURL': profileImageURL,
      'herdId': herdId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'thumbnailUrl': thumbnailUrl,
      'mediaType': mediaType,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'isPrivate': isPrivate,
    };
  }

  PostModel copyWith({
    String? id,
    String? authorId,
    String? username,
    String? profileImageURL,
    String? herdId,
    String? title,
    String? content,
    String? imageUrl,
    String? thumbnailUrl,
    String? mediaType,
    int? likeCount,
    int? dislikeCount,
    int? commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPrivate,
  }) {
    return PostModel(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      username: username ?? this.username,
      profileImageURL: profileImageURL ?? this.profileImageURL,
      herdId: herdId ?? this.herdId,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      mediaType: mediaType ?? this.mediaType,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPrivate: isPrivate ?? this.isPrivate,
    );
  }
}