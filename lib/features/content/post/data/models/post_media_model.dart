// lib/features/post/data/models/post_media_model.dart
import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_media_model.freezed.dart';

@freezed
abstract class PostMediaModel with _$PostMediaModel {
  const PostMediaModel._();

  const factory PostMediaModel({
    required String id,
    required String url,
    String? thumbnailUrl,
    @Default('image') String mediaType,
  }) = _PostMediaModel;

  factory PostMediaModel.fromMap(Map<String, dynamic> map) {
    return PostMediaModel(
      id: map['id'] ?? '',
      url: map['url'] ?? '',
      thumbnailUrl: map['thumbnailUrl'],
      mediaType: map['mediaType'] ?? 'image',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'url': url,
      'thumbnailUrl': thumbnailUrl,
      'mediaType': mediaType,
    };
  }
}
