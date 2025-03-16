import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';

import '../../../../core/utils/hot_algorithm.dart';

/// Base repository for feed functionality
class FeedRepository {
  final FirebaseFirestore firestore;

  /// Constructor that takes a Firestore instance
  FeedRepository(this.firestore);

  /// Get a reference to the posts collection
  CollectionReference<Map<String, dynamic>> get posts =>
      firestore.collection('posts');

  /// Get a reference to the public feeds collection
  CollectionReference<Map<String, dynamic>> get publicFeeds =>
      firestore.collection('feeds');

  /// Get a reference to the private feeds collection
  CollectionReference<Map<String, dynamic>> get privateFeeds =>
      firestore.collection('privateFeeds');

  /// Calculate the net votes for a post
  int calculateNetVotes(PostModel post) {
    return post.likeCount - post.dislikeCount;
  }

  /// Sort a list of posts using the hot algorithm
  List<PostModel> applySortingAlgorithm(List<PostModel> posts, {double decayFactor = 1.0}) {
    return HotAlgorithm.sortByHotScore(
        posts,
            (post) => calculateNetVotes(post),
            (post) => post.createdAt ?? DateTime.now(),
        decayFactor: decayFactor
    );
  }

  /// Helper method to log any feed-related errors
  void logError(String operation, Object error, StackTrace? stackTrace) {
    if (kDebugMode) {
      print('Feed Repository Error during $operation: $error');
      if (stackTrace != null) {
        print(stackTrace);
      }
    }
  }
}