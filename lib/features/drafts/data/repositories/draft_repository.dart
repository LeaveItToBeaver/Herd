// lib/features/drafts/data/repositories/draft_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/draft_post_model.dart';

class DraftRepository {
  final FirebaseFirestore _firestore;

  DraftRepository(this._firestore);

  // Collection reference
  CollectionReference<Map<String, dynamic>> userDrafts(String userId) =>
      _firestore.collection('drafts').doc(userId).collection('draftPosts');

  // CRUD Operations

  /// Save a new draft or update existing draft
  Future<String> saveDraft(DraftPostModel draft) async {
    try {
      // If the draft has an ID, update it
      // Otherwise, create a new draft with a generated ID
      final String draftId = draft.id.isEmpty
          ? _firestore.collection('drafts').doc().id
          : draft.id;

      final draftWithId = draft.copyWith(
        id: draftId,
        updatedAt: DateTime.now(),
      );

      await userDrafts(draft.authorId).doc(draftId).set(draftWithId.toMap());

      debugPrint('Draft saved with ID: $draftId');
      return draftId;
    } catch (e, stackTrace) {
      debugPrint('Error saving draft: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Get a single draft by ID
  Future<DraftPostModel?> getDraft(String userId, String draftId) async {
    try {
      final docSnap = await userDrafts(userId).doc(draftId).get();

      if (!docSnap.exists) {
        return null;
      }

      return DraftPostModel.fromMap(docSnap.id, docSnap.data()!);
    } catch (e) {
      debugPrint('Error getting draft: $e');
      rethrow;
    }
  }

  /// Get all drafts for a user
  Future<List<DraftPostModel>> getUserDrafts(String userId) async {
    try {
      final querySnap =
          await userDrafts(userId).orderBy('updatedAt', descending: true).get();

      return querySnap.docs
          .map((doc) => DraftPostModel.fromMap(doc.id, doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Error getting user drafts: $e');
      rethrow;
    }
  }

  /// Stream all drafts for a user in real-time
  Stream<List<DraftPostModel>> streamUserDrafts(String userId) {
    return userDrafts(userId)
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DraftPostModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Delete a draft
  Future<void> deleteDraft(String userId, String draftId) async {
    try {
      await userDrafts(userId).doc(draftId).delete();
      debugPrint('Draft $draftId deleted successfully');
    } catch (e) {
      debugPrint('Error deleting draft: $e');
      rethrow;
    }
  }

  /// Convert a draft to a post and delete the draft
  Future<String> convertDraftToPost(String userId, String draftId) async {
    try {
      // This method should be implemented to convert a draft to a real post
      // This would involve creating a post in the posts collection
      // and then deleting the draft
      // Return the new post ID

      // For now, just return a placeholder
      return draftId;
    } catch (e) {
      debugPrint('Error converting draft to post: $e');
      rethrow;
    }
  }
}
