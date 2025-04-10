// lib/features/drafts/view/providers/draft_providers.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/drafts/data/models/draft_post_model.dart';
import 'package:herdapp/features/drafts/data/repositories/draft_repository.dart';
import 'package:herdapp/features/post/view/providers/post_provider.dart';

// Repository provider
final draftRepositoryProvider = Provider<DraftRepository>((ref) {
  return DraftRepository(FirebaseFirestore.instance);
});

// User drafts provider - stream of all drafts for current user
final userDraftsProvider = StreamProvider<List<DraftPostModel>>((ref) {
  final user = ref.watch(authProvider);
  final repository = ref.watch(draftRepositoryProvider);

  if (user == null) {
    return Stream.value([]);
  }

  return repository.streamUserDrafts(user.uid);
});

// Single draft provider
final draftProvider =
    FutureProvider.family<DraftPostModel?, String>((ref, draftId) async {
  final user = ref.watch(authProvider);
  final repository = ref.watch(draftRepositoryProvider);

  if (user == null) {
    return null;
  }

  return repository.getDraft(user.uid, draftId);
});

// Draft controller for CRUD operations
class DraftController extends StateNotifier<AsyncValue<void>> {
  final DraftRepository _repository;
  final Ref _ref;

  DraftController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  // Save a draft
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
        createdAt:
            draftId == null ? DateTime.now() : null, // Only set for new drafts
      );

      final savedDraftId = await _repository.saveDraft(draft);

      state = const AsyncValue.data(null);
      return savedDraftId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Delete a draft
  Future<void> deleteDraft(String userId, String draftId) async {
    try {
      state = const AsyncValue.loading();

      await _repository.deleteDraft(userId, draftId);

      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }

  // Convert draft to post
  Future<String> publishDraft(String userId, String draftId) async {
    try {
      state = const AsyncValue.loading();

      // Get the draft
      final draft = await _repository.getDraft(userId, draftId);
      if (draft == null) {
        throw Exception('Draft not found');
      }

      // Create a post from the draft
      final postController = _ref.read(postControllerProvider.notifier);
      final postId = await postController.createPost(
        userId: draft.authorId,
        title: draft.title ?? '',
        content: draft.content,
        isAlt: draft.isAlt,
        herdId: draft.herdId ?? '',
        herdName: draft.herdName ?? '',
      );

      // Delete the draft
      await _repository.deleteDraft(userId, draftId);

      state = const AsyncValue.data(null);
      return postId;
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

// Draft controller provider
final draftControllerProvider =
    StateNotifierProvider<DraftController, AsyncValue<void>>((ref) {
  final repository = ref.watch(draftRepositoryProvider);
  return DraftController(repository, ref);
});

// Number of drafts provider
final draftCountProvider = StreamProvider<int>((ref) {
  final user = ref.watch(authProvider);
  final repository = ref.watch(draftRepositoryProvider);

  if (user == null) {
    return Stream.value(0);
  }

  return repository.streamUserDrafts(user.uid).map((drafts) => drafts.length);
});
