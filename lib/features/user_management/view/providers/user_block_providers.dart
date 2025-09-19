import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/user_block_repository.dart';
import '../../data/models/user_block_model.dart';
import '../../../user/auth/view/providers/auth_provider.dart';

// User Block Repository Provider
final userBlockRepositoryProvider = Provider<UserBlockRepository>((ref) {
  return UserBlockRepository(FirebaseFirestore.instance);
});

// Stream blocked users for the current user
final blockedUsersProvider = StreamProvider<List<UserBlockModel>>((ref) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Stream.value([]);
  }

  return repository.streamBlockedUsers(currentUserId: currentUser!.uid);
});

// Stream blocked users with a limit
final blockedUsersWithLimitProvider =
    StreamProvider.family<List<UserBlockModel>, int>((ref, limit) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Stream.value([]);
  }

  return repository.streamBlockedUsers(
    currentUserId: currentUser!.uid,
    limit: limit,
  );
});

// Check if a specific user is blocked
final isUserBlockedProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Future.value(false);
  }

  return repository.isUserBlocked(
    currentUserId: currentUser!.uid,
    targetUserId: targetUserId,
  );
});

// Get a specific blocked user's details
final blockedUserDetailsProvider =
    FutureProvider.family<UserBlockModel?, String>((ref, blockedUserId) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Future.value(null);
  }

  return repository.getBlockedUser(
    currentUserId: currentUser!.uid,
    blockedUserId: blockedUserId,
  );
});

// Get count of blocked users
final blockedUsersCountProvider = FutureProvider<int>((ref) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);

  if (currentUser?.uid == null) {
    return Future.value(0);
  }

  return repository.getBlockedUsersCount(currentUserId: currentUser!.uid);
});

// Check if two users can interact (bi-directional blocking check)
// Returns true if users CAN interact, false if blocked
final canUsersInteractProvider =
    FutureProvider.family<bool, String>((ref, targetUserId) async {
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
});

// State provider for block user operation
final blockUserStateProvider =
    StateNotifierProvider<BlockUserNotifier, AsyncValue<void>>((ref) {
  final repository = ref.watch(userBlockRepositoryProvider);
  final currentUser = ref.watch(authProvider);
  return BlockUserNotifier(repository, currentUser?.uid);
});

// State notifier for managing block user operations
class BlockUserNotifier extends StateNotifier<AsyncValue<void>> {
  final UserBlockRepository _repository;
  final String? _currentUserId;

  BlockUserNotifier(this._repository, this._currentUserId)
      : super(const AsyncValue.data(null));

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
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.blockUser(
        currentUserId: _currentUserId,
        blockedUserId: blockedUserId,
        username: username,
        firstName: firstName,
        lastName: lastName,
        reported: reported,
        isAlt: isAlt,
        notes: notes,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Unblock a user
  Future<void> unblockUser(String blockedUserId) async {
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.unblockUser(
        currentUserId: _currentUserId,
        blockedUserId: blockedUserId,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update notes for a blocked user
  Future<void> updateBlockNotes({
    required String blockedUserId,
    String? notes,
  }) async {
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.updateBlockNotes(
        currentUserId: _currentUserId,
        blockedUserId: blockedUserId,
        notes: notes,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update reported status for a blocked user
  Future<void> updateBlockReportedStatus({
    required String blockedUserId,
    required bool reported,
  }) async {
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.updateBlockReportedStatus(
        currentUserId: _currentUserId,
        blockedUserId: blockedUserId,
        reported: reported,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Update alt status for a blocked user
  Future<void> updateBlockAltStatus({
    required String blockedUserId,
    required bool isAlt,
  }) async {
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.updateBlockAltStatus(
        currentUserId: _currentUserId,
        blockedUserId: blockedUserId,
        isAlt: isAlt,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Block multiple users at once
  Future<void> blockMultipleUsers(List<UserBlockModel> blockedUsers) async {
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.blockMultipleUsers(
        currentUserId: _currentUserId,
        blockedUsers: blockedUsers,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  /// Unblock multiple users at once
  Future<void> unblockMultipleUsers(List<String> blockedUserIds) async {
    if (_currentUserId == null) {
      state =
          const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();

    try {
      await _repository.unblockMultipleUsers(
        currentUserId: _currentUserId,
        blockedUserIds: blockedUserIds,
      );
      state = const AsyncValue.data(null);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}
