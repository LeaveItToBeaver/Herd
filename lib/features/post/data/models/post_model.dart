class PostModel {
  final String id;
  final String authorId;
  final String username;
  final String? herdId;
  final String? firstName;
  final String? lastName;
  final String? profileImageURL;
  final String? title;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final int dislikeCount;
  final int commentCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PostModel({
    required this.id,
    required this.authorId,
    required this.username,
    this.herdId,
    this.firstName,
    this.lastName,
    this.profileImageURL,
    this.title,
    required this.content,
    this.imageUrl,
    this.likeCount = 0,
    this.dislikeCount = 0,
    this.commentCount = 0,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorId': authorId,
      'username': username,
      'herdId': herdId,
      'firstName': firstName,
      'lastName': lastName,
      'profileImageURL': profileImageURL,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'commentCount': commentCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory PostModel.fromMap(String id, Map<String, dynamic> map) {
    return PostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      username: map['username'] ?? '',
      herdId: map['herdId'], // Parse herd ID
      firstName: map['firstName'],
      lastName: map['lastName'],
      profileImageURL: map['profileImageURL'],
      title: map['title'],
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'],
      likeCount: map['likeCount']?.toInt() ?? 0,
      dislikeCount: map['dislikeCount']?.toInt() ?? 0,
      commentCount: map['commentCount']?.toInt() ?? 0,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }
}
