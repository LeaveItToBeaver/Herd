import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/user_block_repository.dart';
import '../../data/models/user_block_model.dart';
import '../../../auth/view/providers/auth_provider.dart';

part 'user_block_providers.g.dart';

// User Block Repository Provider
@riverpod
UserBlockRepository userBlockRepository(Ref ref) {
  return UserBlockRepository(FirebaseFirestore.instance);
}

// Stream blocked users for the current user
@riverpod
Stream<List<UserBlockModel>> blockedUsers(Ref ref) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Stream.value([]);
  }

  return repository.streamBlockedUsers(currentUserId: currentUser!.uid);
}

// Stream blocked users with a limit
@riverpod
Stream<List<UserBlockModel>> blockedUsersWithLimit(Ref ref, int limit) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Stream.value([]);
  }

  return repository.streamBlockedUsers(
    currentUserId: currentUser!.uid,
    limit: limit,
  );
}

// Check if a specific user is blocked
@riverpod
Future<bool> isUserBlocked(Ref ref, String targetUserId) async {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return false;
  }

  return repository.isUserBlocked(
    currentUserId: currentUser!.uid,
    targetUserId: targetUserId,
  );
}

// Get a specific blocked user's details
@riverpod
Future<UserBlockModel?> blockedUserDetails(
    Ref ref, String blockedUserId) async {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return null;
  }

  return repository.getBlockedUser(
    currentUserId: currentUser!.uid,
    blockedUserId: blockedUserId,
  );
}

// Get count of blocked users
@riverpod
Future<int> blockedUsersCount(Ref ref) async {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return 0;
  }

  return repository.getBlockedUsersCount(currentUserId: currentUser!.uid);
}

// Check if two users can interact (bi-directional blocking check)
// Returns true if users CAN interact, false if blocked
@riverpod
Future<bool> canUsersInteract(Ref ref, String targetUserId) async {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null || targetUserId.isEmpty) {
    return false;
  }

  final currentUserId = currentUser!.uid;

  // Don't block self-interaction
  if (currentUserId == targetUserId) {
    return true;
  }

  try {
    // Check if current user blocked target user
    final currentBlocksTarget = await repository.isUserBlocked(
      currentUserId: currentUserId,
      targetUserId: targetUserId,
    );

    // Check if target user blocked current user
    final targetBlocksCurrent = await repository.isUserBlocked(
      currentUserId: targetUserId,
      targetUserId: currentUserId,
    );

    // Users can interact if neither blocks the other
    return !currentBlocksTarget && !targetBlocksCurrent;
  } catch (e) {
    // SECURITY: Default to blocking interaction if there's an error (fail closed)
    return false;
  }
}

// State notifier for managing block user operations
@riverpod
class BlockUserState extends _$BlockUserState {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  /// Block a user
  Future<void> blockUser({
    required String blockedUserId,
    String? username,
    String? firstName,
    String? lastName,
    bool reported = false,
    bool isAlt = false,
    String? notes,
  }) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.blockUser(
        currentUserId: currentUser!.uid,
        blockedUserId: blockedUserId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        reported: reported,
        isAlt: isAlt,
        notes: notes,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Unblock a user
  Future<void> unblockUser(String blockedUserId) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.unblockUser(
        currentUserId: currentUser!.uid,
        blockedUserId: blockedUserId,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update notes for a blocked user
  Future<void> updateBlockNotes({
    required String blockedUserId,
    String? notes,
  }) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.updateBlockNotes(
        currentUserId: currentUser!.uid,
        blockedUserId: blockedUserId,
        notes: notes,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update reported status for a blocked user
  Future<void> updateBlockReportedStatus({
    required String blockedUserId,
    required bool reported,
  }) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.updateBlockReportedStatus(
        currentUserId: currentUser!.uid,
        blockedUserId: blockedUserId,
        reported: reported,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update alt status for a blocked user
  Future<void> updateBlockAltStatus({
    required String blockedUserId,
    required bool isAlt,
  }) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.updateBlockAltStatus(
        currentUserId: currentUser!.uid,
        blockedUserId: blockedUserId,
        isAlt: isAlt,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Block multiple users at once
  Future<void> blockMultipleUsers(List<UserBlockModel> blockedUsers) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.blockMultipleUsers(
        currentUserId: currentUser!.uid,
        blockedUsers: blockedUsers,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Unblock multiple users at once
  Future<void> unblockMultipleUsers(List<String> blockedUserIds) async {
    final currentUser = ref.read(authProvider);
    if (currentUser?.uid == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      final repository = ref.read(userBlockRepositoryProvider);
      await repository.unblockMultipleUsers(
        currentUserId: currentUser!.uid,
        blockedUserIds: blockedUserIds,
      );
      if (!ref.mounted) return;
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      if (!ref.mounted) return;
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
