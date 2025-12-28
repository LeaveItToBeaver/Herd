# Phase 6: Content Removal & Restoration

## Status: 🔲 Not Started

## Goal

Implement a complete content removal system that:
1. Removes posts from public feeds (soft delete)
2. Removes comments from threads
3. Allows restoration of removed content
4. Filters removed content from queries
5. Supports bulk removal operations
6. Maintains audit trail

---

## Prerequisites

- [x] Phase 1 completed (Roles & Permissions)
- [ ] Understand current post/comment storage structure
- [ ] Review existing `removePost()` in moderation_repository.dart

---

## Current State Analysis

The existing codebase has:
- `removePost()` method exists but implementation needs verification
- No `removeComment()` implementation
- No `restorePost()` or `restoreComment()` implementations
- No bulk removal capabilities

---

## Architecture Decisions

### 1. Soft Delete Strategy

**Decision**: Use soft delete with `isRemoved` flag + removal metadata.

```typescript
// Post document
{
  // ... existing fields ...
  
  // Removal fields
  isRemoved: boolean,           // false by default
  removedAt: Timestamp?,
  removedBy: string?,
  removalReason: string?,
  removalType: 'mod' | 'author' | 'automated',
  
  // For restoration
  canRestore: boolean,          // true for mod removals
  restoredAt: Timestamp?,
  restoredBy: string?,
}
```

**Rationale**:
- Preserves content for appeals
- Maintains evidence for legal/audit
- Allows restoration without data loss
- No complex data migration

### 2. Query Filtering Strategy

**Option A**: Filter in query (chosen)
```dart
.where('isRemoved', isEqualTo: false)
```

**Option B**: Separate collection
```dart
// Would require moving documents - expensive
```

**Decision**: Option A - filter in query. Add compound index for common queries.

### 3. Cost Analysis

| Operation | Reads | Writes |
|-----------|-------|--------|
| Remove single post | 1 | 2 (post + log) |
| Restore single post | 1 | 2 (post + log) |
| Remove comment | 1 | 2 (comment + log) |
| Bulk remove (10 items) | 10 | 20 |
| Feed with filter | Same (index handles filter) | 0 |

---

## Implementation Plan

### Step 1: Extend Post Model

**File**: Update existing post model or create removal extension

```dart
// lib/features/community/posts/data/models/post_removal_data.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_removal_data.freezed.dart';

enum RemovalType {
  moderator,   // Removed by mod/admin
  author,      // Self-deleted by author
  automated,   // Removed by automated system (spam filter, etc.)
  appeal,      // Removed during appeal process
}

@freezed
abstract class PostRemovalData with _$PostRemovalData {
  const PostRemovalData._();

  const factory PostRemovalData({
    @Default(false) bool isRemoved,
    DateTime? removedAt,
    String? removedBy,
    String? removalReason,
    @Default(RemovalType.moderator) RemovalType removalType,
    @Default(true) bool canRestore,
    DateTime? restoredAt,
    String? restoredBy,
  }) = _PostRemovalData;

  factory PostRemovalData.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PostRemovalData();
    
    return PostRemovalData(
      isRemoved: map['isRemoved'] ?? false,
      removedAt: (map['removedAt'] as Timestamp?)?.toDate(),
      removedBy: map['removedBy'],
      removalReason: map['removalReason'],
      removalType: RemovalType.values.firstWhere(
        (e) => e.name == map['removalType'],
        orElse: () => RemovalType.moderator,
      ),
      canRestore: map['canRestore'] ?? true,
      restoredAt: (map['restoredAt'] as Timestamp?)?.toDate(),
      restoredBy: map['restoredBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isRemoved': isRemoved,
      'removedAt': removedAt != null ? Timestamp.fromDate(removedAt!) : null,
      'removedBy': removedBy,
      'removalReason': removalReason,
      'removalType': removalType.name,
      'canRestore': canRestore,
      'restoredAt': restoredAt != null ? Timestamp.fromDate(restoredAt!) : null,
      'restoredBy': restoredBy,
    };
  }
}
```

### Step 2: Content Removal Repository

**File**: `lib/features/community/moderation/data/repositories/content_removal_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/moderation_action_model.dart';

class ContentRemovalRepository {
  final FirebaseFirestore _firestore;

  ContentRemovalRepository(this._firestore);

  // ============ POST REMOVAL ============

  /// Remove a post from public visibility
  Future<void> removePost({
    required String herdId,
    required String postId,
    required String removedBy,
    required String reason,
    RemovalType type = RemovalType.moderator,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final postRef = _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId);

    // Soft delete the post
    batch.update(postRef, {
      'isRemoved': true,
      'removedAt': FieldValue.serverTimestamp(),
      'removedBy': removedBy,
      'removalReason': reason,
      'removalType': type.name,
      'canRestore': type == RemovalType.moderator,
    });

    // Log moderation action
    final actionId = _firestore.collection('dummy').doc().id;
    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: removedBy,
        timestamp: now,
        actionType: ModActionType.removePost,
        targetId: postId,
        targetType: ModTargetType.post,
        reason: reason,
        metadata: {
          'herdId': herdId,
          'removalType': type.name,
        },
      ).toMap(),
    );

    // Decrement herd post count
    batch.update(
      _firestore.collection('herds').doc(herdId),
      {'postCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  /// Restore a previously removed post
  Future<void> restorePost({
    required String herdId,
    required String postId,
    required String restoredBy,
    String? reason,
  }) async {
    // First verify post can be restored
    final postDoc = await _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .get();

    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final canRestore = postDoc.data()?['canRestore'] ?? true;
    if (!canRestore) {
      throw Exception('This post cannot be restored');
    }

    final batch = _firestore.batch();
    final now = DateTime.now();

    final postRef = _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId);

    // Restore the post
    batch.update(postRef, {
      'isRemoved': false,
      'restoredAt': FieldValue.serverTimestamp(),
      'restoredBy': restoredBy,
    });

    // Log moderation action
    final actionId = _firestore.collection('dummy').doc().id;
    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: restoredBy,
        timestamp: now,
        actionType: ModActionType.restorePost,
        targetId: postId,
        targetType: ModTargetType.post,
        reason: reason ?? 'Post restored',
        metadata: {'herdId': herdId},
      ).toMap(),
    );

    // Increment herd post count
    batch.update(
      _firestore.collection('herds').doc(herdId),
      {'postCount': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  // ============ COMMENT REMOVAL ============

  /// Remove a comment from public visibility
  Future<void> removeComment({
    required String herdId,
    required String postId,
    required String commentId,
    required String removedBy,
    required String reason,
    RemovalType type = RemovalType.moderator,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final commentRef = _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    // Soft delete the comment
    batch.update(commentRef, {
      'isRemoved': true,
      'removedAt': FieldValue.serverTimestamp(),
      'removedBy': removedBy,
      'removalReason': reason,
      'removalType': type.name,
      'canRestore': type == RemovalType.moderator,
    });

    // Log moderation action
    final actionId = _firestore.collection('dummy').doc().id;
    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: removedBy,
        timestamp: now,
        actionType: ModActionType.removeComment,
        targetId: commentId,
        targetType: ModTargetType.comment,
        reason: reason,
        metadata: {
          'herdId': herdId,
          'postId': postId,
          'removalType': type.name,
        },
      ).toMap(),
    );

    // Decrement post comment count
    batch.update(
      _firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId),
      {'commentCount': FieldValue.increment(-1)},
    );

    await batch.commit();
  }

  /// Restore a previously removed comment
  Future<void> restoreComment({
    required String herdId,
    required String postId,
    required String commentId,
    required String restoredBy,
    String? reason,
  }) async {
    // First verify comment can be restored
    final commentDoc = await _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .get();

    if (!commentDoc.exists) {
      throw Exception('Comment not found');
    }

    final canRestore = commentDoc.data()?['canRestore'] ?? true;
    if (!canRestore) {
      throw Exception('This comment cannot be restored');
    }

    final batch = _firestore.batch();
    final now = DateTime.now();

    final commentRef = _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .doc(commentId);

    batch.update(commentRef, {
      'isRemoved': false,
      'restoredAt': FieldValue.serverTimestamp(),
      'restoredBy': restoredBy,
    });

    // Log moderation action
    final actionId = _firestore.collection('dummy').doc().id;
    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: restoredBy,
        timestamp: now,
        actionType: ModActionType.restoreComment,
        targetId: commentId,
        targetType: ModTargetType.comment,
        reason: reason ?? 'Comment restored',
        metadata: {
          'herdId': herdId,
          'postId': postId,
        },
      ).toMap(),
    );

    // Increment post comment count
    batch.update(
      _firestore
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(postId),
      {'commentCount': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  // ============ BULK OPERATIONS ============

  /// Remove multiple posts at once
  Future<BulkRemovalResult> bulkRemovePosts({
    required String herdId,
    required List<String> postIds,
    required String removedBy,
    required String reason,
  }) async {
    final results = BulkRemovalResult();

    // Process in batches of 500 (Firestore limit)
    for (var i = 0; i < postIds.length; i += 100) {
      final batch = _firestore.batch();
      final batchPostIds = postIds.skip(i).take(100).toList();

      for (final postId in batchPostIds) {
        try {
          final postRef = _firestore
              .collection('herdPosts')
              .doc(herdId)
              .collection('posts')
              .doc(postId);

          batch.update(postRef, {
            'isRemoved': true,
            'removedAt': FieldValue.serverTimestamp(),
            'removedBy': removedBy,
            'removalReason': reason,
            'removalType': RemovalType.moderator.name,
            'canRestore': true,
          });

          results.succeeded.add(postId);
        } catch (e) {
          results.failed[postId] = e.toString();
        }
      }

      await batch.commit();
    }

    // Log bulk action
    await _firestore
        .collection('moderationLogs')
        .doc(herdId)
        .collection('actions')
        .add({
      'actionId': _firestore.collection('dummy').doc().id,
      'performedBy': removedBy,
      'timestamp': FieldValue.serverTimestamp(),
      'actionType': 'bulkRemovePosts',
      'reason': reason,
      'metadata': {
        'postCount': results.succeeded.length,
        'failedCount': results.failed.length,
      },
    });

    return results;
  }

  // ============ QUERIES ============

  /// Get removed posts for review
  Future<List<Map<String, dynamic>>> getRemovedPosts(
    String herdId, {
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .where('isRemoved', isEqualTo: true)
        .orderBy('removedAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => {'postId': doc.id, ...doc.data()}).toList();
  }

  /// Get removed comments on a post
  Future<List<Map<String, dynamic>>> getRemovedComments(
    String herdId,
    String postId, {
    int limit = 20,
  }) async {
    final snapshot = await _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .collection('comments')
        .where('isRemoved', isEqualTo: true)
        .orderBy('removedAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => {'commentId': doc.id, ...doc.data()}).toList();
  }
}

class BulkRemovalResult {
  final List<String> succeeded = [];
  final Map<String, String> failed = {};

  bool get hasFailures => failed.isNotEmpty;
  int get successCount => succeeded.length;
  int get failureCount => failed.length;
}

enum RemovalType {
  moderator,
  author,
  automated,
  appeal,
}
```

### Step 3: Content Removal Providers

**File**: `lib/features/community/moderation/view/providers/content_removal_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/content_removal_repository.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

part 'content_removal_providers.g.dart';

@riverpod
ContentRemovalRepository contentRemovalRepository(Ref ref) {
  return ContentRemovalRepository(FirebaseFirestore.instance);
}

/// Removed posts for mod review
@riverpod
Future<List<Map<String, dynamic>>> removedPosts(
  Ref ref,
  String herdId,
) async {
  final repo = ref.watch(contentRemovalRepositoryProvider);
  return repo.getRemovedPosts(herdId);
}

/// Controller for content removal actions
@riverpod
class ContentRemovalController extends _$ContentRemovalController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> removePost({
    required String herdId,
    required String postId,
    required String reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(contentRemovalRepositoryProvider);
      await repo.removePost(
        herdId: herdId,
        postId: postId,
        removedBy: user.uid,
        reason: reason,
      );

      // Invalidate relevant providers
      ref.invalidate(removedPostsProvider(herdId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> restorePost({
    required String herdId,
    required String postId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(contentRemovalRepositoryProvider);
      await repo.restorePost(
        herdId: herdId,
        postId: postId,
        restoredBy: user.uid,
        reason: reason,
      );

      ref.invalidate(removedPostsProvider(herdId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeComment({
    required String herdId,
    required String postId,
    required String commentId,
    required String reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(contentRemovalRepositoryProvider);
      await repo.removeComment(
        herdId: herdId,
        postId: postId,
        commentId: commentId,
        removedBy: user.uid,
        reason: reason,
      );

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> restoreComment({
    required String herdId,
    required String postId,
    required String commentId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(contentRemovalRepositoryProvider);
      await repo.restoreComment(
        herdId: herdId,
        postId: postId,
        commentId: commentId,
        restoredBy: user.uid,
        reason: reason,
      );

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<BulkRemovalResult> bulkRemovePosts({
    required String herdId,
    required List<String> postIds,
    required String reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      throw Exception('Not authenticated');
    }

    try {
      final repo = ref.read(contentRemovalRepositoryProvider);
      final result = await repo.bulkRemovePosts(
        herdId: herdId,
        postIds: postIds,
        removedBy: user.uid,
        reason: reason,
      );

      ref.invalidate(removedPostsProvider(herdId));
      state = const AsyncValue.data(null);
      return result;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      rethrow;
    }
  }
}
```

### Step 4: Removal Confirmation Dialog

**File**: `lib/features/community/moderation/view/widgets/remove_content_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_removal_providers.dart';

enum ContentType { post, comment }

class RemoveContentDialog extends ConsumerStatefulWidget {
  final String herdId;
  final String postId;
  final String? commentId;
  final ContentType contentType;
  final String? contentPreview;

  const RemoveContentDialog({
    super.key,
    required this.herdId,
    required this.postId,
    this.commentId,
    required this.contentType,
    this.contentPreview,
  });

  @override
  ConsumerState<RemoveContentDialog> createState() =>
      _RemoveContentDialogState();
}

class _RemoveContentDialogState extends ConsumerState<RemoveContentDialog> {
  final _reasonController = TextEditingController();
  String? _selectedReason;

  static const _quickReasons = [
    'Spam or advertisement',
    'Harassment or bullying',
    'Hate speech',
    'Misinformation',
    'Inappropriate content',
    'Violates community guidelines',
  ];

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(contentRemovalControllerProvider);
    final isPost = widget.contentType == ContentType.post;

    return AlertDialog(
      title: Text('Remove ${isPost ? 'Post' : 'Comment'}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.contentPreview != null) ...[
              const Text('Content Preview:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.contentPreview!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
            const Text('Reason for removal:',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _quickReasons.map((reason) {
                final isSelected = _selectedReason == reason;
                return ChoiceChip(
                  label: Text(reason),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      _selectedReason = selected ? reason : null;
                      if (selected) {
                        _reasonController.text = reason;
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Custom reason or details',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (_) => setState(() => _selectedReason = null),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange[800]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'This ${isPost ? 'post' : 'comment'} will be hidden from public view but can be restored later.',
                      style: TextStyle(color: Colors.orange[900]),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          onPressed: state.isLoading || _reasonController.text.isEmpty
              ? null
              : _removeContent,
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Remove', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _removeContent() async {
    final controller = ref.read(contentRemovalControllerProvider.notifier);

    if (widget.contentType == ContentType.post) {
      await controller.removePost(
        herdId: widget.herdId,
        postId: widget.postId,
        reason: _reasonController.text,
      );
    } else {
      await controller.removeComment(
        herdId: widget.herdId,
        postId: widget.postId,
        commentId: widget.commentId!,
        reason: _reasonController.text,
      );
    }

    if (mounted) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.contentType == ContentType.post ? 'Post' : 'Comment'} removed',
          ),
        ),
      );
    }
  }
}
```

### Step 5: Removed Content Management Screen

**File**: `lib/features/community/moderation/view/screens/removed_content_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/content_removal_providers.dart';

class RemovedContentScreen extends ConsumerWidget {
  final String herdId;

  const RemovedContentScreen({super.key, required this.herdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final removedPosts = ref.watch(removedPostsProvider(herdId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Removed Content'),
      ),
      body: removedPosts.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (posts) {
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No removed content'),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return _RemovedPostCard(
                herdId: herdId,
                post: post,
              );
            },
          );
        },
      ),
    );
  }
}

class _RemovedPostCard extends ConsumerWidget {
  final String herdId;
  final Map<String, dynamic> post;

  const _RemovedPostCard({
    required this.herdId,
    required this.post,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postId = post['postId'] as String;
    final content = post['content'] as String? ?? '';
    final reason = post['removalReason'] as String? ?? 'No reason provided';
    final canRestore = post['canRestore'] as bool? ?? true;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post content preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                content.length > 200
                    ? '${content.substring(0, 200)}...'
                    : content,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 12),
            // Removal info
            Row(
              children: [
                const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    'Removed: $reason',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (canRestore)
                  TextButton.icon(
                    onPressed: () => _showRestoreDialog(context, ref, postId),
                    icon: const Icon(Icons.restore),
                    label: const Text('Restore'),
                  ),
                TextButton.icon(
                  onPressed: () => _showPermanentDeleteDialog(context),
                  icon: const Icon(Icons.delete_forever, color: Colors.red),
                  label: const Text(
                    'Delete Permanently',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Post'),
        content: const Text(
          'This will make the post visible again. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref
                  .read(contentRemovalControllerProvider.notifier)
                  .restorePost(herdId: herdId, postId: postId);
              if (context.mounted) {
                Navigator.pop(context);
              }
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showPermanentDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permanent Deletion'),
        content: const Text(
          'Permanent deletion is not yet implemented. '
          'For legal and audit purposes, removed content is retained.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

### Step 6: Update ModActionType Enum

Add to `moderation_action_model.dart`:

```dart
enum ModActionType {
  // ... existing types ...
  
  // Content removal
  removePost,
  restorePost,
  removeComment,
  restoreComment,
}
```

### Step 7: Update Feed Queries

Modify all feed queries to filter removed content:

```dart
// Example in post repository
Future<List<Post>> getHerdPosts(String herdId, {int limit = 20}) async {
  final snapshot = await _firestore
      .collection('herdPosts')
      .doc(herdId)
      .collection('posts')
      .where('isRemoved', isEqualTo: false)  // ADD THIS
      .orderBy('createdAt', descending: true)
      .limit(limit)
      .get();

  return snapshot.docs.map((doc) => Post.fromDoc(doc)).toList();
}
```

---

## Firestore Indexes Required

```json
{
  "indexes": [
    {
      "collectionGroup": "posts",
      "fields": [
        { "fieldPath": "isRemoved", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "posts",
      "fields": [
        { "fieldPath": "isRemoved", "order": "ASCENDING" },
        { "fieldPath": "removedAt", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## Security Rules

```javascript
match /herdPosts/{herdId}/posts/{postId} {
  // Only mods can update isRemoved field
  allow update: if request.auth != null
    && (
      // Author can update their own post (but not isRemoved)
      (resource.data.authorId == request.auth.uid 
       && !request.resource.data.diff(resource.data).affectedKeys().hasAny(['isRemoved']))
      ||
      // Mods can update isRemoved
      isHerdModerator(herdId, request.auth.uid)
    );
}
```

---

## Integration Points

### 1. Post Menu Options

Add "Remove Post" option to post overflow menu for moderators:

```dart
if (isModerator) {
  PopupMenuItem(
    value: 'remove',
    child: ListTile(
      leading: Icon(Icons.delete_outline, color: Colors.red),
      title: Text('Remove Post'),
    ),
  ),
}
```

### 2. Comment Actions

Add removal option to comment long-press or swipe actions.

### 3. Mod Dashboard

Add "Removed Content" tab to moderation dashboard.

---

## Testing Checklist

- [ ] Can remove a post (soft delete)
- [ ] Removed post hidden from feed
- [ ] Removed post visible in mod queue
- [ ] Can restore a removed post
- [ ] Restored post reappears in feed
- [ ] Post count updates on remove/restore
- [ ] Can remove a comment
- [ ] Comment count updates on remove
- [ ] Can restore a removed comment
- [ ] Bulk removal works correctly
- [ ] Removal logged to mod log
- [ ] Restoration logged to mod log
- [ ] Security rules prevent non-mods from removing

---

## Success Criteria

1. Removed content immediately hidden from public
2. All removals logged with reason
3. Restoration possible for mod removals
4. Zero orphaned documents
5. Post/comment counts accurate

---

## Estimated Effort

- **Development**: 8-10 hours
- **Testing**: 4-5 hours
- **Feed query updates**: 2-3 hours
- **Total**: ~15-18 hours
