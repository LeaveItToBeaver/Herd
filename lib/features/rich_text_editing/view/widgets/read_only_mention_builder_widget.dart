import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/rich_text_editing/models/user_mention_embed.dart';

class ReadOnlyMentionEmbedBuilder extends quill.EmbedBuilder {
  final BuildContext navigatorContext;

  ReadOnlyMentionEmbedBuilder(this.navigatorContext);

  @override
  String get key => UserMentionEmbed.mentionType;

  @override
  Widget build(
    BuildContext context,
    quill.EmbedContext embedContext,
  ) {
    try {
      final mentionData =
          MentionData.fromJson(jsonDecode(embedContext.node.value.data));

      return InkWell(
        onTap: () {
          // Navigate to user profile when mention is tapped
          navigatorContext.pushNamed(
            'publicProfile', // or determine based on context
            pathParameters: {'id': mentionData.userId},
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '@${mentionData.username}',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      );
    } catch (e) {
      // Fallback for malformed mention data
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        child: Text(
          '@[user]',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
      );
    }
  }
}
