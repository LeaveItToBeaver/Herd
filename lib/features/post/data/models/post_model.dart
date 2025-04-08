import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'post_model.freezed.dart';

@freezed
abstract class PostModel with _$PostModel {
  const PostModel._(); // Add this to allow custom methods within the class

  const factory PostModel({
    required String id,
    required String authorId,
    String? authorName,
    String? authorUsername,
    String? authorProfileImageURL,
    String? title,
    required String content,
    String? mediaURL,
    String? mediaType,
    @Default('') String? mediaThumbnailURL,
    @Default([]) List<String> hashtags,
    @Default([]) List<String> mentions,
    @Default(0) int likeCount,
    @Default(0) int dislikeCount,
    @Default(0) int commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? hotScore,


    // Herd-related fields
    String? herdId,
    String? herdName,
    String? herdProfileImageURL,
    @Default(false) bool isPrivateHerd,
    @Default(false) bool isHerdMember,
    @Default(false) bool isHerdModerator,
    @Default(false) bool isHerdBanned,
    @Default(false) bool isHerdBlocked,

    @Default(false) bool isAlt,
    String? feedType, // 'public', 'alt', or 'herd'
    @Default(false) bool isLiked,
    @Default(false) bool isDisliked,
    @Default(false) bool isBookmarked,
  }) = _PostModel;


  // Factory constructor to convert from Firestore snapshot
  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'],
      authorUsername: map['authorUsername'],
      authorProfileImageURL: map['authorProfileImageURL'],
      title: map['title'],
      content: map['content'] ?? '',
      mediaURL: map['mediaURL'],
      mediaType: map['mediaType'],
      hashtags: List<String>.from(map['hashtags'] ?? []),
      mentions: List<String>.from(map['mentions'] ?? []),
      likeCount: map['likeCount'] ?? 0,
      dislikeCount: map['dislikeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      hotScore: map['hotScore']?.toDouble(),
      herdId: map['herdId'],
      herdName: map['herdName'],
      herdProfileImageURL: map['herdProfileImageURL'],
      isPrivateHerd: map['isPrivateHerd'] ?? false,
      isHerdMember: map['isHerdMember'] ?? false,
      isHerdModerator: map['isHerdModerator'] ?? false,
      isHerdBanned: map['isHerdBanned'] ?? false,
      isHerdBlocked: map['isHerdBlocked'] ?? false,
      isAlt: map['isAlt'] ?? false,
      feedType: map['feedType'],
      isLiked: map['isLiked'] ?? false,
      isDisliked: map['isDisliked'] ?? false,
      isBookmarked: map['isBookmarked'] ?? false,
    );
  }

  // Create a new empty post for the current user
  factory PostModel.empty() {
    return const PostModel(
      id: '',
      authorId: '',
      title: '',
      content: ''
    );
  }

  // Helper for parsing DateTime values from Firestore
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }

  // Convert to Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorUsername': authorUsername,
      'authorProfileImageURL': authorProfileImageURL,
      'title': title,
      'content': content,
      'mediaURL': mediaURL,
      'mediaType': mediaType,
      'hashtags': hashtags,
      'mentions': mentions,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : FieldValue.serverTimestamp(),
      'hotScore': hotScore,
      'herdId': herdId,
      'herdName': herdName,
      'herdProfileImageURL': herdProfileImageURL,
      'isPrivateHerd': isPrivateHerd,
      'isHerdMember': isHerdMember,
      'isHerdModerator': isHerdModerator,
      'isHerdBanned': isHerdBanned,
      'isHerdBlocked': isHerdBlocked,
      'isAlt': isAlt,
      'isLiked': isLiked,
      'isDisliked': isDisliked,
      'feedType': feedType ?? (isAlt ? 'alt' : (herdId != null ? 'herd' : 'public')),
    };
  }

  // Get the age of the post as a readable string
  String get age {
    if (createdAt == null) return '';

    final now = DateTime.now();
    final difference = now.difference(createdAt!);

    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else {
      return '${(difference.inDays / 30).floor()}mo';
    }
  }

  // Check if user is the post author
  bool isAuthor(String userId) {
    return authorId == userId;
  }

  // Toggle like status
  PostModel toggleLike(String userId) {
    if (isLiked) {
      return copyWith(
        isLiked: false,
        likeCount: likeCount - 1,
      );
    } else {
      return copyWith(
        isLiked: true,
        likeCount: likeCount + 1,
        isDisliked: isDisliked ? false : isDisliked,
        dislikeCount: isDisliked ? dislikeCount - 1 : dislikeCount,
      );
    }
  }

  // Toggle dislike status
  PostModel toggleDislike(String userId) {
    if (isDisliked) {
      return copyWith(
        isDisliked: false,
        dislikeCount: dislikeCount - 1,
      );
    } else {
      return copyWith(
        isDisliked: true,
        dislikeCount: dislikeCount + 1,
        isLiked: isLiked ? false : isLiked,
        likeCount: isLiked ? likeCount - 1 : likeCount,
      );
    }
  }

  // Get post type as readable string
  String get postType {
    if (herdId != null && herdId!.isNotEmpty) {
      return 'Herd';
    } else if (isAlt) {
      return 'Alt';
    } else {
      return 'Public';
    }
  }
}