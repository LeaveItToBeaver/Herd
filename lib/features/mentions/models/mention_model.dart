import 'package:cloud_firestore/cloud_firestore.dart';

class MentionModel {
  final String id;
  final String postId;
  final String? commentId; // If it's a comment mention
  final String authorId;
  final String authorUsername;
  final String authorName;
  final String mentionedUserId;
  final String contentPreview;
  final String? postTitle;
  final bool isAlt;
  final String? herdId;
  final String? herdName;
  final DateTime timestamp;
  final bool isRead;
  final String mentionType; // 'post' or 'comment'
  final String feedType;

  MentionModel({
    required this.id,
    required this.postId,
    this.commentId,
    required this.authorId,
    required this.authorUsername,
    required this.authorName,
    required this.mentionedUserId,
    required this.contentPreview,
    this.postTitle,
    required this.isAlt,
    this.herdId,
    this.herdName,
    required this.timestamp,
    required this.isRead,
    required this.mentionType,
    required this.feedType,
  });

  factory MentionModel.fromMap(String id, Map<String, dynamic> map) {
    return MentionModel(
      id: id,
      postId: map['postId'] ?? '',
      commentId: map['commentId'],
      authorId: map['authorId'] ?? '',
      authorUsername: map['authorUsername'] ?? '',
      authorName: map['authorName'] ?? '',
      mentionedUserId: map['mentionedUserId'] ?? '',
      contentPreview: map['contentPreview'] ?? map['postPreview'] ?? '',
      postTitle: map['postTitle'],
      isAlt: map['isAlt'] ?? false,
      herdId: map['herdId'],
      herdName: map['herdName'],
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: map['isRead'] ?? false,
      mentionType: map['mentionType'] ?? 'post',
      feedType: map['feedType'] ?? 'public',
    );
  }

  Map<String, dynamic> toMap() => {
        'postId': postId,
        'commentId': commentId,
        'authorId': authorId,
        'authorUsername': authorUsername,
        'authorName': authorName,
        'mentionedUserId': mentionedUserId,
        'contentPreview': contentPreview,
        'postTitle': postTitle,
        'isAlt': isAlt,
        'herdId': herdId,
        'herdName': herdName,
        'timestamp': Timestamp.fromDate(timestamp),
        'isRead': isRead,
        'mentionType': mentionType,
        'feedType': feedType,
      };
}

class MentionRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get mentions for a user
  Stream<List<MentionModel>> getUserMentions(String userId,
      {bool includeRead = false}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection('userMentions')
        .doc(userId)
        .collection('mentions');

    if (!includeRead) {
      query = query.where('isRead', isEqualTo: false);
    }

    return query
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MentionModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Get unread mention count
  Future<int> getUnreadMentionCount(String userId) async {
    final snapshot = await _firestore
        .collection('userMentions')
        .doc(userId)
        .collection('mentions')
        .where('isRead', isEqualTo: false)
        .count()
        .get();

    return snapshot.count ?? 0;
  }

  // Mark mention as read
  Future<void> markMentionAsRead(String userId, String mentionId) async {
    await _firestore
        .collection('userMentions')
        .doc(userId)
        .collection('mentions')
        .doc(mentionId)
        .update({'isRead': true});
  }

  // Mark all mentions as read
  Future<void> markAllMentionsAsRead(String userId) async {
    final batch = _firestore.batch();

    final unreadMentions = await _firestore
        .collection('userMentions')
        .doc(userId)
        .collection('mentions')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in unreadMentions.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Create mention for comment
  Future<void> createCommentMentions({
    required String postId,
    required String commentId,
    required String authorId,
    required String authorUsername,
    required String authorName,
    required String commentContent,
    required List<String> mentionedUserIds,
    required bool isAltPost,
    String? herdId,
    String? herdName,
  }) async {
    if (mentionedUserIds.isEmpty) return;

    final batch = _firestore.batch();
    final timestamp = FieldValue.serverTimestamp();

    for (final mentionedUserId in mentionedUserIds) {
      // Skip if user is mentioning themselves
      if (mentionedUserId == authorId) continue;

      // Create user-centric mention
      final userMentionRef = _firestore
          .collection('userMentions')
          .doc(mentionedUserId)
          .collection('mentions')
          .doc('${commentId}_$mentionedUserId');

      batch.set(userMentionRef, {
        'postId': postId,
        'commentId': commentId,
        'authorId': authorId,
        'authorUsername': authorUsername,
        'authorName': authorName,
        'contentPreview': _extractPreview(commentContent),
        'isAlt': isAltPost,
        'herdId': herdId,
        'herdName': herdName,
        'timestamp': timestamp,
        'isRead': false,
        'mentionType': 'comment',
        'feedType': isAltPost ? 'alt' : (herdId != null ? 'herd' : 'public'),
      });

      // Also create in mentions collection for reference
      final mentionRef = _firestore
          .collection('mentions')
          .doc(commentId)
          .collection('commentMentions')
          .doc(mentionedUserId);

      batch.set(mentionRef, {
        'postId': postId,
        'commentId': commentId,
        'authorId': authorId,
        'mentionedUserId': mentionedUserId,
        'timestamp': timestamp,
      });
    }

    await batch.commit();
  }

  // Delete mentions when post/comment is deleted
  Future<void> deleteMentions({
    required String contentId,
    required bool isComment,
  }) async {
    // Get all mentions for this content
    final mentionsQuery = isComment
        ? _firestore
            .collection('mentions')
            .doc(contentId)
            .collection('commentMentions')
        : _firestore
            .collection('mentions')
            .doc(contentId)
            .collection('postMentions');

    final mentions = await mentionsQuery.get();
    final batch = _firestore.batch();

    for (final mention in mentions.docs) {
      final mentionedUserId = mention.data()['mentionedUserId'];

      // Delete from user mentions
      final userMentionRef = _firestore
          .collection('userMentions')
          .doc(mentionedUserId)
          .collection('mentions')
          .doc(isComment ? '${contentId}_$mentionedUserId' : contentId);

      batch.delete(userMentionRef);

      // Delete from mentions collection
      batch.delete(mention.reference);
    }

    await batch.commit();
  }

  String _extractPreview(String content, {int maxLength = 100}) {
    // Remove line breaks and extra spaces
    final cleaned = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (cleaned.length <= maxLength) {
      return cleaned;
    }

    return '${cleaned.substring(0, maxLength)}...';
  }
}
