import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/comment_model.dart';

class CommentRepository{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Collection references
  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');
  CollectionReference<Map<String, dynamic>> get _comments => _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes => _firestore.collection('likes');
  CollectionReference<Map<String, dynamic>> get _dislikes => _firestore.collection('dislikes');
  CollectionReference<Map<String, dynamic>> get _feeds => _firestore.collection('feeds');


  Future<void> createComment(CommentModel comment) async {
    await _comments
        .doc(comment.postId)
        .collection('postComments')
        .add(comment.toMap());

    await _posts.doc(comment.postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

// Stream comments
  Stream<List<CommentModel>> getPostComments(String postId) {
    return _comments
        .doc(postId)
        .collection('postComments')
        .orderBy('createdAt')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => CommentModel.fromMap(doc.id, doc.data())).toList());
  }

// Toggle Like/Dislike
  Future<void> toggleReaction({
    required String postId,
    required String userId,
    required bool isLike,
  }) async {
    final targetCollection = isLike ? _likes : _dislikes;
    final oppositeCollection = isLike ? _dislikes : _likes;

    final targetDoc = await targetCollection.doc(postId).collection(isLike ? 'postLikes' : 'postDislikes').doc(userId).get();
    final oppositeDoc = await oppositeCollection.doc(postId).collection(isLike ? 'postDislikes' : 'postLikes').doc(userId).get();

    if (targetDoc.exists) {
      // Remove reaction
      await targetDoc.reference.delete();
      await _posts.doc(postId).update({
        isLike ? 'likeCount' : 'dislikeCount': FieldValue.increment(-1),
      });
    } else {
      // Add reaction
      await targetCollection.doc(postId).collection(isLike ? 'postLikes' : 'postDislikes').doc(userId).set({
        'timestamp': FieldValue.serverTimestamp(),
      });
      await _posts.doc(postId).update({
        isLike ? 'likeCount' : 'dislikeCount': FieldValue.increment(1),
      });

      // Remove opposite reaction if exists
      if (oppositeDoc.exists) {
        await oppositeDoc.reference.delete();
        await _posts.doc(postId).update({
          isLike ? 'dislikeCount' : 'likeCount': FieldValue.increment(-1),
        });
      }
    }
  }

  // Fetch reaction state
  Future<Map<String, bool>> getPostReactions(String postId, String userId) async {
    final likeDoc = await _likes.doc(postId).collection('postLikes').doc(userId).get();
    final dislikeDoc = await _dislikes.doc(postId).collection('postDislikes').doc(userId).get();

    return {
      'isLiked': likeDoc.exists,
      'isDisliked': dislikeDoc.exists,
    };
  }

}

