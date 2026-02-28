// lib/features/drafts/view/providers/draft_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/content/drafts/data/models/draft_post_model.dart';
import 'package:herdapp/features/content/drafts/data/repositories/draft_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../create_post/create_post_controller.dart';

part 'draft_provider.g.dart';

// Draft repository
@riverpod
DraftRepository draftRepository(Ref ref) {
  return DraftRepository(FirebaseFirestore.instance);
}

@riverpod
Stream<List<DraftPostModel>> userDrafts(Ref ref) {
  final user = ref.watch(authProvider);
  final repository = ref.watch(draftRepositoryProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return repository.streamUserDrafts(user.uid);
}

@riverpod
Future<DraftPostModel?> draft(Ref ref, String draftId) async {
  final user = ref.watch(authProvider);
  final repository = ref.watch(draftRepositoryProvider);

  if (user == null) {
    return null;
  }

  return repository.getDraft(user.uid, draftId);
}

@riverpod
class DraftController extends _$DraftController {
  @override
  AsyncValue<void> build() {
    return const AsyncValue.data(null);
  }

  Future<String> saveDraft({
    required String authorId,
    String? draftId,
    String? title,
    required String content,
    bool isAlt = false,
    String? herdId,
    String? herdName,
  }) async {
    try {
      state = const AsyncValue.loading();

      final draft = DraftPostModel(
        id: draftId ?? '',
        authorId: authorId,
        title: title,
        content: content,
        isAlt: isAlt,
        herdId: herdId,
        herdName: herdName,
        updatedAt: DateTime.now(),
        createdAt: draftId == null ? DateTime.now() : null,
      );

      final repository = ref.read(draftRepositoryProvider);
      final savedDraftId = await repository.saveDraft(draft);

      if (!ref.mounted) return '';

      state = const AsyncValue.data(null);
      return savedDraftId;
    } catch (e, stackTrace) {
      if (!ref.mounted) rethrow;
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Delete a draft
  Future<void> deleteDraft(String userId, String draftId) async {
    try {
      state = const AsyncValue.loading();

      final repository = ref.read(draftRepositoryProvider);
      await repository.deleteDraft(userId, draftId);

      if (!ref.mounted) return;

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      if (!ref.mounted) rethrow;
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  Future<String> publishDraft(String userId, String draftId) async {
    try {
      state = const AsyncValue.loading();

      final repository = ref.read(draftRepositoryProvider);
      final draft = await repository.getDraft(userId, draftId);

      if (!ref.mounted) return '';

      if (draft == null) {
        throw Exception('Draft not found');
      }

      final postController = ref.read(createPostControllerProvider.notifier);
      final postId = await postController.createPost(
        userId: draft.authorId,
        title: draft.title ?? '',
        content: draft.content,
        isAlt: draft.isAlt,
        isNSFW: draft.isNSFW,
        herdId: draft.herdId ?? '',
        herdName: draft.herdName ?? '',
      );

      if (!ref.mounted) return '';

      await repository.deleteDraft(userId, draftId);

      if (!ref.mounted) return '';

      state = const AsyncValue.data(null);
      return postId;
    } catch (e, stackTrace) {
      if (!ref.mounted) rethrow;
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

@riverpod
Stream<int> draftCount(Ref ref) {
  final user = ref.watch(authProvider);
  final repository = ref.watch(draftRepositoryProvider);

  if (user == null) {
    return Stream.value(0);
  }

  return repository.streamUserDrafts(user.uid).map((drafts) => drafts.length);
}
