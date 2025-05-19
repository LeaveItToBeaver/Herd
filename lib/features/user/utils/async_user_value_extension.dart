// Add this to a utilities file
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/user_model.dart';

extension AsyncUserValueExtension on AsyncValue<UserModel?> {
  // Unwrap the UserModel directly for optimistic updates
  UserModel? get userOrNull => whenOrNull(data: (user) => user);

  // Get user ID directly without .when() pattern
  String? get userId => whenOrNull(data: (user) => user?.id);

  // Get profile image directly without .when() pattern
  String? get safeProfileImageURL =>
      whenOrNull(data: (user) => user?.profileImageURL);

  String? get firstName => whenOrNull(data: (user) => user?.firstName);
  String? get lastName => whenOrNull(data: (user) => user?.lastName);

  String? get userName => whenOrNull(data: (user) => user?.username);

  // Get alt profile image directly without .when() pattern
  String? get safeAltProfileImageURL =>
      whenOrNull(data: (user) => user?.altProfileImageURL);

  bool? get allowNSFW => whenOrNull(data: (user) => user?.allowNSFW);

  bool? get blurNSFW => whenOrNull(data: (user) => user?.blurNSFW);

  // Apply a function if user exists (for more complex operations)
  T? mapIfUser<T>(T Function(UserModel user) fn) {
    return whenOrNull(data: (user) => user != null ? fn(user) : null);
  }

  // For boolean checks (like isCurrentUser)
  bool get exists => whenOrNull(data: (user) => user != null) ?? false;

  // For error handling
  String? get errorMessage => whenOrNull(error: (e, _) => e.toString());
}
