import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/community/moderation/data/models/moderation_action_model.dart';
import '../../data/repositories/moderation_repository.dart';
import '../../data/models/report_model.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

part 'moderation_providers.g.dart';

// Moderation Repository Provider
@riverpod
ModerationRepository moderationRepository(Ref ref) {
  final herdRepository = ref.watch(herdRepositoryProvider);
  return ModerationRepository(FirebaseFirestore.instance, herdRepository);
}

// Stream moderation log for a herd
@riverpod
Stream<List<ModerationAction>> herdModerationLog(Ref ref, String herdId) {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.streamModerationLog(herdId);
}

// Get pending reports for a herd
@riverpod
Future<List<ReportModel>> herdPendingReports(Ref ref, String herdId) async {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.getPendingReports(herdId);
}

// Check if a user is banned from a herd
@riverpod
Future<bool> isUserBanned(Ref ref,
    {required String herdId, required String userId}) async {
  final repository = ref.watch(moderationRepositoryProvider);
  return repository.isUserBanned(herdId, userId);
}

// Moderation Actions Controller
@riverpod
class ModerationController extends _$ModerationController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<void> banUser({
    required String herdId,
    required String userId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.banUserFromHerd(
        herdId: herdId,
        userId: userId,
        moderatorId: currentUser.uid,
        reason: reason,
      );

      if (!ref.mounted) return;

      // Refresh herd data
      ref.invalidate(herdProvider(herdId));
      ref.invalidate(herdMembersProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unbanUser({
    required String herdId,
    required String userId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.unbanUserFromHerd(
        herdId: herdId,
        userId: userId,
        moderatorId: currentUser.uid,
        reason: reason,
      );

      if (!ref.mounted) return;

      ref.invalidate(herdProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> pinPost({
    required String herdId,
    required String postId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.pinPost(
        herdId: herdId,
        postId: postId,
        moderatorId: currentUser.uid,
      );

      if (!ref.mounted) return;

      ref.invalidate(herdProvider(herdId));
      ref.invalidate(herdPostsProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> unpinPost({
    required String herdId,
    required String postId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.unpinPost(
        herdId: herdId,
        postId: postId,
        moderatorId: currentUser.uid,
      );

      if (!ref.mounted) return;

      ref.invalidate(herdProvider(herdId));
      ref.invalidate(herdPostsProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removePost({
    required String herdId,
    required String postId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.removePost(
        herdId: herdId,
        postId: postId,
        moderatorId: currentUser.uid,
        reason: reason,
      );

      if (!ref.mounted) return;

      ref.invalidate(herdPostsProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addModerator({
    required String herdId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.addModerator(
        herdId: herdId,
        userId: userId,
        addedBy: currentUser.uid,
      );

      if (!ref.mounted) return;

      ref.invalidate(herdProvider(herdId));
      ref.invalidate(isHerdModeratorProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeModerator({
    required String herdId,
    required String userId,
  }) async {
    state = const AsyncValue.loading();

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.removeModerator(
        herdId: herdId,
        userId: userId,
        removedBy: currentUser.uid,
      );

      if (!ref.mounted) return;

      ref.invalidate(herdProvider(herdId));
      ref.invalidate(isHerdModeratorProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
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

    final currentUser = ref.read(authProvider);
    if (currentUser == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repository = ref.read(moderationRepositoryProvider);
      await repository.reportContent(
        reportedBy: currentUser.uid,
        targetId: targetId,
        targetType: targetType,
        reason: reason,
        description: description,
        herdId: herdId,
      );

      if (!ref.mounted) return;

      if (herdId != null) {
        ref.invalidate(herdPendingReportsProvider(herdId));
      }

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      if (!ref.mounted) return;
      state = AsyncValue.error(e, stack);
    }
  }
}
