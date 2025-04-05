import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:flutter/foundation.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required UserModel? user, // Make user nullable
    required List<PostModel> posts,
    required bool isCurrentUser,
    required bool isFollowing,
    required bool isAltView,
    required bool hasAltProfile,
  }) = _ProfileState;

  factory ProfileState.initial() => const ProfileState(
    user: null, // Default value
    posts: [],
    isCurrentUser: false,
    isFollowing: false,
    isAltView: false,
    hasAltProfile: false,
  );
}
