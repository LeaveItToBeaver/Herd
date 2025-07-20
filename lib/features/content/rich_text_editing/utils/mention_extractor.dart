import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:herdapp/features/content/rich_text_editing/models/user_mention_embed.dart';

class MentionExtractor {
  static List<String> extractMentionIds(Document document) {
    final mentions = <String>{};

    for (final operation in document.toDelta().toList()) {
      if (operation.key == Operation.insertKey && operation.data is Map) {
        // Cast operation.data to a Map after the type check, assigning to a new local variable.
        final Map<String, dynamic> opData =
            operation.data as Map<String, dynamic>;
        final embedValue = opData[UserMentionEmbed
            .mentionType]; // Use the new local variable 'opData'

        if (embedValue is String) {
          try {
            final Map<String, dynamic> decodedJson = jsonDecode(embedValue);
            final mentionData = MentionData.fromJson(decodedJson);
            mentions.add(mentionData.userId);
          } catch (e) {
            debugPrint('Error decoding or parsing mention data string: $e');
          }
        } else if (embedValue is Map<String, dynamic>) {
          try {
            final mentionData = MentionData.fromJson(embedValue);
            mentions.add(mentionData.userId);
          } catch (e) {
            debugPrint('Error parsing mention data map: $e');
          }
        }
      }
    }
    return mentions.toList();
  }

  static List<MentionData> extractMentions(Document document) {
    final mentions = <MentionData>[];
    final seenUserIds = <String>{};

    for (final operation in document.toDelta().toList()) {
      if (operation.key == Operation.insertKey && operation.data is Map) {
        // Cast operation.data to a Map after the type check, assigning to a new local variable.
        final Map<String, dynamic> opData =
            operation.data as Map<String, dynamic>;
        final embedValue = opData[UserMentionEmbed
            .mentionType]; // Use the new local variable 'opData'

        if (embedValue is String) {
          try {
            final Map<String, dynamic> decodedJson = jsonDecode(embedValue);
            final mentionData = MentionData.fromJson(decodedJson);
            if (seenUserIds.add(mentionData.userId)) {
              mentions.add(mentionData);
            }
          } catch (e) {
            debugPrint(
                'Error decoding or parsing mention data string for MentionData: $e');
          }
        } else if (embedValue is Map<String, dynamic>) {
          try {
            final mentionData = MentionData.fromJson(embedValue);
            if (seenUserIds.add(mentionData.userId)) {
              mentions.add(mentionData);
            }
          } catch (e) {
            debugPrint('Error parsing mention data map for MentionData: $e');
          }
        }
      }
    }
    return mentions;
  }
}
