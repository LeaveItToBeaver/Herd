import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:herdapp/features/rich_text_editing/models/user_mention_embed.dart';
import 'package:herdapp/features/mentions/view/widgets/mention_embed_widget.dart';

class MentionEmbedBuilder extends EmbedBuilder {
  @override
  String get key => UserMentionEmbed.mentionType;

  @override
  Widget build(
    BuildContext context,
    EmbedContext embedContext,
  ) {
    final mentionData =
        MentionData.fromJson(jsonDecode(embedContext.node.value.data));

    return MentionEmbedWidget(
      mention: mentionData,
      readOnly: false,
      onTap: embedContext.readOnly
          ? () {
              // Navigate to user profile when tapped in read-only mode
              // You can inject navigation logic here
            }
          : null,
    );
  }
}
