import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'comment_model.freezed.dart';
part 'comment_model.g.dart';

@freezed
class CommentModel with _$CommentModel {
  const CommentModel._(); // For custom methods

  const factory CommentModel({
    required String id,
    required String postId,
    required String authorId,
    required String content,
    required DateTime timestamp,
    String? parentId,
    required String path,
    @Default(0) int depth,
    String? authorUsername,
    String? authorProfileImage,
    @Default(false) bool isPrivatePost,
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
      authorProfileImage: data['authorProfileImage'],
      isPrivatePost: data['isPrivatePost'] ?? false,
      mediaUrl: data['mediaUrl'],
      likeCount: data['likeCount'] ?? 0,
      dislikeCount: data['dislikeCount'] ?? 0,
      replyCount: data['replyCount'] ?? 0,
      hotnessScore: data['hotnessScore']?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return toJson()..addAll({
      'timestamp': Timestamp.fromDate(timestamp),
    });
  }
}