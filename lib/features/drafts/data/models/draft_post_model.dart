// lib/features/drafts/data/models/draft_post_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'draft_post_model.freezed.dart';

@freezed
abstract class DraftPostModel with _$DraftPostModel {
  const DraftPostModel._(); // Add this to allow custom methods within the class

  const factory DraftPostModel({
    required String id,
    required String authorId,
    String? title,
    required String content,
    @Default(false) bool isAlt,
    String? herdId,
    String? herdName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _DraftPostModel;

  // Factory constructor to convert from Firestore snapshot
  factory DraftPostModel.fromMap(String id, Map<String, dynamic> map) {
    return DraftPostModel(
      id: id,
      authorId: map['authorId'] ?? '',
      title: map['title'],
      content: map['content'] ?? '',
      isAlt: map['isAlt'] ?? false,
      herdId: map['herdId'],
      herdName: map['herdName'],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
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
      'title': title,
      'content': content,
      'isAlt': isAlt,
      'herdId': herdId,
      'herdName': herdName,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
