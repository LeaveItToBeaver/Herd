import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
abstract class CommentModel with _$CommentModel {
  const CommentModel._(); // For custom methods

  // Add variables for public and private comments
  const factory CommentModel({
    required String id,
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    required DateTime timestamp,
    String? parentId,
    required String path,
    @Default(0) int depth,
    String? authorUsername,
    String? authorFirstName,
    String? authorLastName,
    String? authorProfileImage,
    String? authorAltProfileImage,
    @Default(false) bool isAuthorAlt,
    @Default(false) bool isAltPost,
    String? mediaUrl,
    @Default(0) int likeCount,
    @Default(0) int dislikeCount,
    @Default(0) int replyCount,
    double? hotnessScore,
  }) = _CommentModel;

  factory CommentModel.fromJson(Map<String, dynamic> json) =>
      _$CommentModelFromJson(json);

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CommentModel(
      id: doc.id,
      postId: data['postId'] ?? '',
      authorId: data['authorId'] ?? '',
      content: data['content'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      parentId: data['parentId'],
      path: data['path'] ?? '',
      depth: data['depth'] ?? 0,
      authorUsername: data['authorUsername'],
      authorFirstName: data['authorFirstName'],
      authorLastName: data['authorLastName'],
      authorProfileImage: data['authorProfileImage'],
      authorAltProfileImage: data['authorAltProfileImage'],
      isAuthorAlt: data['isAuthorAlt'] ?? false,
      authorName: data['authorName'] ?? '',
      isAltPost: data['isAltPost'] ?? false,
      mediaUrl: data['mediaUrl'],
      likeCount: data['likeCount'] ?? 0,
      dislikeCount: data['dislikeCount'] ?? 0,
      replyCount: data['replyCount'] ?? 0,
      hotnessScore: data['hotnessScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return toJson()
      ..addAll({
        'timestamp': Timestamp.fromDate(timestamp),
      });
  }
}
