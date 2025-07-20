import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/community/moderation/data/models/moderation_action_model.dart';
import '../../data/repositories/moderation_repository.dart';
import '../../data/models/report_model.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

// Moderation Repository Provider
final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return ModerationRepository(FirebaseFirestore.instance, herdRepository);
});

// Stream moderation log for a herd
final herdModerationLogProvider =
    StreamProvider.family<List<ModerationAction>, String>((ref, herdId) {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.streamModerationLog(herdId);
});

// Get pending reports for a herd
final herdPendingReportsProvider =
    FutureProvider.family<List<ReportModel>, String>((ref, herdId) {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.getPendingReports(herdId);
});

// Check if a user is banned from a herd
final isUserBannedProvider =
    FutureProvider.family<bool, ({String herdId, String userId})>(
        (ref, params) {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.isUserBanned(params.herdId, params.userId);
});

// Moderation Actions Controller
class ModerationController extends StateNotifier<AsyncValue<void>> {
  final ModerationRepository _repository;
  final Ref _ref;

  ModerationController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<void> banUser({
    required String herdId,
    required String userId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.banUserFromHerd(
        herdId: herdId,
        userId: userId,
        moderatorId: currentUser.uid,
        reason: reason,
      );

      // Refresh herd data
      _ref.invalidate(herdProvider(herdId));
      _ref.invalidate(herdMembersProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unbanUser({
    required String herdId,
    required String userId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.unbanUserFromHerd(
        herdId: herdId,
        userId: userId,
        moderatorId: currentUser.uid,
        reason: reason,
      );

      _ref.invalidate(herdProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> pinPost({
    required String herdId,
    required String postId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.pinPost(
        herdId: herdId,
        postId: postId,
        moderatorId: currentUser.uid,
      );

      _ref.invalidate(herdProvider(herdId));
      _ref.invalidate(herdPostsProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unpinPost({
    required String herdId,
    required String postId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.unpinPost(
        herdId: herdId,
        postId: postId,
        moderatorId: currentUser.uid,
      );

      _ref.invalidate(herdProvider(herdId));
      _ref.invalidate(herdPostsProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removePost({
    required String herdId,
    required String postId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.removePost(
        herdId: herdId,
        postId: postId,
        moderatorId: currentUser.uid,
        reason: reason,
      );

      _ref.invalidate(herdPostsProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addModerator({
    required String herdId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.addModerator(
        herdId: herdId,
        userId: userId,
        addedBy: currentUser.uid,
      );

      _ref.invalidate(herdProvider(herdId));
      _ref.invalidate(isHerdModeratorProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeModerator({
    required String herdId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.removeModerator(
        herdId: herdId,
        userId: userId,
        removedBy: currentUser.uid,
      );

      _ref.invalidate(herdProvider(herdId));
      _ref.invalidate(isHerdModeratorProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> reportContent({
    required String targetId,
    required ReportTargetType targetType,
    required ReportReason reason,
    String? description,
    String? herdId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = _ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      await _repository.reportContent(
        reportedBy: currentUser.uid,
        targetId: targetId,
        targetType: targetType,
        reason: reason,
        description: description,
        herdId: herdId,
      );

      if (herdId != null) {
        _ref.invalidate(herdPendingReportsProvider(herdId));
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Moderation Controller Provider
final moderationControllerProvider =
    StateNotifierProvider<ModerationController, AsyncValue<void>>((ref) {
  final repository = ref.watch(moderationRepositoryProvider);
  return ModerationController(repository, ref);
});
