import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String postId;
  final String authorId;
  final String content;
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.content,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'postId': postId,
      'authorId': authorId,
      'content': content,
      'createdAt': createdAt,
    };
  }

  factory CommentModel.fromMap(String id, Map<String, dynamic> map) {
    return CommentModel(
      id: id,
      postId: map['postId'] ?? '',
      authorId: map['authorId'] ?? '',
      content: map['content'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
