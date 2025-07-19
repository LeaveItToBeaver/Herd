import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

part 'profile_state.freezed.dart';

@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    required UserModel? user,
    required List<PostModel> posts,
    required bool isCurrentUser,
    required bool isFollowing,
    required bool isAltView,
    required bool hasAltProfile,
    @Default(false) bool isLoading,
    @Default(true) bool hasMorePosts,
    @Default('') String currentUserId,
    PostModel? lastPost,
    @Default(20) int pageSize,
  }) = _ProfileState;

  factory ProfileState.initial() => const ProfileState(
        user: null,
        posts: [],
        isCurrentUser: false,
        isFollowing: false,
        isAltView: false,
        hasAltProfile: false,
        isLoading: false,
        hasMorePosts: true,
        currentUserId: '',
        lastPost: null,
        pageSize: 20,
      );
}
