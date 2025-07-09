import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';

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
    @Default([]) List<PostMediaModel> mediaItems,
    String? mediaURL,
    String? mediaType,
    @Default('') String? mediaThumbnailURL,
    @Default([]) List<String> tags,
    @Default(false) bool isNSFW,
    @Default([]) List<String> mentions,
    @Default(0) int likeCount,
    @Default(0) int dislikeCount,
    @Default(0) int commentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? pinnedAt, // When the post was pinned
    double? hotScore,

    // Sorting-related fields
    double?
        trendingScore, // Score for trending posts (hot score for recent posts)
    double? topScore, // Score for top posts (like count within time period)

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
    @Default(false) bool isRichText,

    // Pinning fields
    @Default(false) bool isPinnedToProfile, // Pinned to user's profile
    @Default(false) bool isPinnedToAltProfile, // Pinned to user's alt profile
    @Default(false) bool isPinnedToHerd, // Pinned to herd
  }) = _PostModel;

  // Factory constructor to convert from Firestore snapshot
  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    List<PostMediaModel> mediaItems = [];

    //debugPrint("mediaItems from Firestore: ${map['mediaItems']}");

    if (map['mediaItems'] != null) {
      try {
        final rawItems = map['mediaItems'] as List;
        //debugPrint("Raw mediaItems type: ${rawItems.runtimeType}");

        // Convert the list items using map() instead of a for loop
        mediaItems = rawItems
            .whereType<Map>() // Filter out non-Map items
            .map((item) {
              // Convert each item to Map<String, dynamic>
              final mediaMap = item is Map<String, dynamic>
                  ? item
                  : Map<String, dynamic>.fromEntries(item.entries
                      .map((e) => MapEntry(e.key.toString(), e.value)));

              // Create PostMediaModel from the map
              return PostMediaModel(
                id: mediaMap['id']?.toString() ?? '0',
                url: mediaMap['url']?.toString() ?? '',
                thumbnailUrl: mediaMap['thumbnailUrl']?.toString(),
                mediaType: mediaMap['mediaType']?.toString() ?? 'image',
              );
            })
            .where((model) => model.url.isNotEmpty) // Filter out empty URLs
            .toList();

        //debugPrint("Successfully processed ${mediaItems.length} media items");
      } catch (e) {
        debugPrint("Error parsing mediaItems list: $e");
      }
    } else if (map['mediaURL'] != null && map['mediaURL'].isNotEmpty) {
      // For backward compatibility - create a media item from the old fields
      mediaItems = [
        PostMediaModel(
          id: '0',
          url: map['mediaURL'],
          thumbnailUrl: map['mediaThumbnailURL'],
          mediaType: map['mediaType'] ?? 'image',
        )
      ];
      //debugPrint("Using legacy mediaURL: ${map['mediaURL']}");
    }

    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      authorName: map['authorName'],
      authorUsername: map['authorUsername'],
      authorProfileImageURL: map['authorProfileImageURL'],
      title: map['title'],
      content: map['content'] ?? '',
      mediaItems: mediaItems,
      mediaURL: map['mediaURL'],
      mediaType: map['mediaType'],
      tags: List<String>.from(map['tags'] ?? []),
      isNSFW: map['isNSFW'] ?? false,
      mentions: List<String>.from(map['mentions'] ?? []),
      likeCount: map['likeCount'] ?? 0,
      dislikeCount: map['dislikeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      pinnedAt: _parseDateTime(map['pinnedAt']),
      hotScore: (map['hotScore'] is int)
          ? (map['hotScore'] as int).toDouble()
          : (map['hotScore'] as num?)?.toDouble(),
      trendingScore: (map['trendingScore'] is int)
          ? (map['trendingScore'] as int).toDouble()
          : (map['trendingScore'] as num?)?.toDouble(),
      topScore: (map['topScore'] is int)
          ? (map['topScore'] as int).toDouble()
          : (map['topScore'] as num?)?.toDouble(),
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
      isRichText: map['isRichText'] ?? false,
      isPinnedToProfile: map['isPinnedToProfile'] ?? false,
      isPinnedToAltProfile: map['isPinnedToAltProfile'] ?? false,
      isPinnedToHerd: map['isPinnedToHerd'] ?? false,
    );
  }

  // Create a new empty post for the current user
  factory PostModel.empty() {
    return const PostModel(id: '', authorId: '', title: '', content: '');
  }

  // Helper for parsing DateTime values from Firestore
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.tryParse(value);
    } else if (value is int) {
      // Handle milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    } else if (value is Map) {
      // Handle Cloud Functions timestamp format
      if (value.containsKey('_isTimestamp') && value.containsKey('value')) {
        final timestampValue = value['value'];
        if (timestampValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(timestampValue);
        }
      }
      // Handle Firestore timestamp object that got serialized to JSON
      if (value.containsKey('_seconds') && value.containsKey('_nanoseconds')) {
        final seconds = value['_seconds'] as int;
        final nanoseconds = value['_nanoseconds'] as int;
        return DateTime.fromMillisecondsSinceEpoch(
          (seconds * 1000) + (nanoseconds ~/ 1000000),
        );
      }
    }

    debugPrint('Unhandled timestamp format: $value (${value.runtimeType})');
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
      'mediaItems': mediaItems.map((item) => item.toMap()).toList(),
      'mediaURL': mediaURL,
      'mediaType': mediaType,
      'tags': tags,
      'isNSFW': isNSFW,
      'mentions': mentions,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
      'pinnedAt': pinnedAt != null ? Timestamp.fromDate(pinnedAt!) : null,
      'hotScore': hotScore,
      'trendingScore': trendingScore,
      'topScore': topScore,
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
      'feedType':
          feedType ?? (isAlt ? 'alt' : (herdId != null ? 'herd' : 'public')),
      'isBookmarked': isBookmarked,
      'isRichText': isRichText,
      'isPinnedToProfile': isPinnedToProfile,
      'isPinnedToAltProfile': isPinnedToAltProfile,
      'isPinnedToHerd': isPinnedToHerd,
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

  // Check if post is pinned anywhere
  bool get isPinned =>
      isPinnedToProfile || isPinnedToAltProfile || isPinnedToHerd;

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

  // Helper methods for sorting

  /// Get the net votes (likes - dislikes) for ranking
  int get netVotes => likeCount - dislikeCount;

  /// Check if post is trending (recent with good engagement)
  bool get isTrending {
    if (createdAt == null) return false;
    final daysSinceCreation = DateTime.now().difference(createdAt!).inDays;
    return daysSinceCreation <= 2 && (hotScore ?? 0) > 0;
  }

  /// Check if post is recent (within last 24 hours)
  bool get isRecent {
    if (createdAt == null) return false;
    final hoursSinceCreation = DateTime.now().difference(createdAt!).inHours;
    return hoursSinceCreation <= 24;
  }

  /// Get sort value based on FeedSortType
  double getSortValue(String sortType) {
    switch (sortType) {
      case 'latest':
        return createdAt?.millisecondsSinceEpoch.toDouble() ?? 0.0;
      case 'hot':
        return hotScore ?? 0.0;
      case 'trending':
        return trendingScore ?? hotScore ?? 0.0;
      case 'top':
        return topScore ?? likeCount.toDouble();
      default:
        return hotScore ?? 0.0;
    }
  }
}
