import 'dart:convert';

import 'package:flutter_quill/flutter_quill.dart';

class UserMentionEmbed extends CustomBlockEmbed {
  const UserMentionEmbed(String value) : super(mentionType, value);

  static const String mentionType = 'mention';

  static UserMentionEmbed fromDocument(Document document) =>
      UserMentionEmbed(jsonEncode(document.toDelta().toJson()));

  Document get document => Document.fromJson(jsonDecode(data));
}

class MentionData {
  final String userId;
  final String username;
  final String displayName;

  MentionData({
    required this.userId,
    required this.username,
    required this.displayName,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'displayName': displayName,
      };

  factory MentionData.fromJson(Map<String, dynamic> json) => MentionData(
        userId: json['userId'] ?? '',
        username: json['username'] ?? '',
        displayName: json['displayName'] ?? '',
      );
}
