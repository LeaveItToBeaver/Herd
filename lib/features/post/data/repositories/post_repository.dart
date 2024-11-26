import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post_model.dart';

class PostRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  // Collection references
  CollectionReference<Map<String, dynamic>> get _posts => _firestore.collection('posts');
  CollectionReference<Map<String, dynamic>> get _comments => _firestore.collection('comments');
  CollectionReference<Map<String, dynamic>> get _likes => _firestore.collection('likes');
  CollectionReference<Map<String, dynamic>> get _dislikes => _firestore.collection('dislikes');
  CollectionReference<Map<String, dynamic>> get _feeds => _firestore.collection('feeds');


  /// Creating a post ///
  // Create post
  Future<void> createPost(PostModel post) async {
    final docRef = await _posts.add(post.toMap());
    await docRef.update({'id': docRef.id});

    // Add post to followers' feeds if it's a user post
    if (post.herdId == null) {
      final followersSnapshot = await _firestore
          .collection('followers')
          .doc(post.authorId)
          .collection('userFollowers')
          .get();

      for (final follower in followersSnapshot.docs) {
        await _feeds
            .doc(follower.id)
            .collection('userFeed')
            .doc(docRef.id)
            .set(post.toMap());
      }
    }
  }

  Future<String?> uploadImage(File imageFile, {
    required String postId,
    required String userId,
    File? file, // Optional
    String? type, // Optional
  }) async {
    if (file == null || type == null) {
      return null; // No file to upload
    }

    try {
      final ref = _storage.ref().child('users/$userId/posts/$postId/$type.jpg');
      final uploadTask = ref.putFile(file);

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception("Failed to upload image: $e");
    }
  }


  String generatePostId() => _firestore.collection('posts').doc().id;


  /// Get Posts for Feeds ///
  // Get user feed with pagination
  Future<List<PostModel>> getUserFeed({
    required String userId,
    String? lastPostId,
    int limit = 10,
  }) async {
    var query = _feeds
        .doc(userId)
        .collection('userFeed')
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastPostId != null) {
      final lastPostDoc = await query.firestore.doc(lastPostId).get();
      if (lastPostDoc.exists) {
        query = query.startAfterDocument(lastPostDoc);
      }
    }

    final postsSnap = await query.get();
    return postsSnap.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList();
  }

  Future<List<PostModel>> getPostsWithAuthorDetails() async {
    final postsSnap = await _posts.orderBy('createdAt', descending: true).get();
    final posts = <PostModel>[];

    for (final doc in postsSnap.docs) {
      final post = PostModel.fromMap(doc.id, doc.data());

      // Fetch author details
      final authorDoc = await _firestore.collection('users').doc(post.authorId).get();
      final authorData = authorDoc.data();

      if (authorData != null) {
        posts.add(PostModel(
          id: post.id,
          authorId: post.authorId,
          username: authorData['username'] ?? 'Unknown',
          profileImageURL: authorData['profileImageURL'],
          title: post.title,
          content: post.content,
          imageUrl: post.imageUrl,
          likeCount: post.likeCount,
          dislikeCount: post.dislikeCount,
          commentCount: post.commentCount,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
        ));
      }
    }

    return posts;
  }

  //Get posts within a herd
  Stream<List<PostModel>> getHerdPosts(String herdId) {
    return _posts
        .where('herdId', isEqualTo: herdId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList());
  }

  // Get post by ID
  Future<PostModel?> getPostById(String postId) async {
    final doc = await _posts.doc(postId).get();
    return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
  }

  // Stream specific post
  Stream<PostModel?> streamPost(String postId) {
    return _posts.doc(postId).snapshots().map((doc) {
      return doc.exists ? PostModel.fromMap(doc.id, doc.data()!) : null;
    });
  }


  /// Post Deletion ///
  Future<void> deletePost(String postId) async {
    await _posts.doc(postId).delete();

    // Delete associated documents (comments, likes, dislikes, feeds)
    await _deleteSubCollection(_comments.doc(postId).collection('postComments'));
    await _deleteSubCollection(_likes.doc(postId).collection('postLikes'));
    await _deleteSubCollection(_dislikes.doc(postId).collection('postDislikes'));

    // Remove post from all feeds
    final feedsSnapshot = await _feeds.get();
    for (final feed in feedsSnapshot.docs) {
      await feed.reference.collection('userFeed').doc(postId).delete();
    }
  }

  // Utility: Delete all documents in a subcollection
  Future<void> _deleteSubCollection(CollectionReference<Map<String, dynamic>> collection) async {
    final snapshot = await collection.get();
    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Get user posts
  Stream<List<PostModel>> getUserPosts(String userId) {
    return _posts
        .where('authorId', isEqualTo: userId)
        .where('herdId', isNull: true) // Exclude herd posts
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PostModel.fromMap(doc.id, doc.data())).toList());
  }
}
