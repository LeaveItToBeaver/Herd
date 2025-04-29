import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

part 'create_post_state.freezed.dart';

@freezed
abstract class CreatePostState with _$CreatePostState {
  const factory CreatePostState({
    required UserModel? user,
    required PostModel? post,
    String? herdId,
    String? herdName,
    @Default(false) bool isImage,
    @Default(false) bool isLoading,
    @Default(false) bool isNSFW,
    String? errorMessage,
  }) = _CreatePostState;

  factory CreatePostState.initial() => const CreatePostState(
        user: null,
        post: null,
      );
}
