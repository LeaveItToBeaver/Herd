# Phase 4: Post Locking

## Status: 🔲 Not Started

## Goal

Implement a post locking system that:
1. Allows mods to lock posts (prevent ALL new comments)
2. Shows clear lock indicator to users
3. Provides unlock capability
4. Logs all lock/unlock actions
5. Works efficiently at scale

---

## Prerequisites

- [x] Phase 1 completed (Roles & Permissions)
- [ ] `HerdPermission.lockPost` permission working
- [ ] Post model accessible

---

## Architecture Decisions

### 1. Lock Storage

**Decision**: Add lock fields directly to post document.

```typescript
// In post document
{
  // ... existing fields ...
  isLocked: boolean,
  lockedAt: Timestamp?,
  lockedBy: string?,
  lockReason: string?,
}
```

**Rationale**:
- Single read to check lock status (already fetching post)
- No additional collection needed
- Easy to query "all locked posts in herd"

### 2. Cost Analysis

| Operation | Reads | Writes |
|-----------|-------|--------|
| Check if post locked | 0 (already have post) | 0 |
| Lock post | 1 (verify exists) | 2 (post + mod log) |
| Load locked posts list | 1 (query) | 0 |
| Create comment (lock check) | 0 (use cached post) | 0 |

---

## Implementation Plan

### Step 1: Update Post Model

**File**: `lib/features/content/post/data/models/post_model.dart` (ADD FIELDS)

Add these fields to your existing PostModel:

```dart
// Add to PostModel factory constructor
@Default(false) bool isLocked,
DateTime? lockedAt,
String? lockedBy,
String? lockReason,
```

Add to `fromMap()`:
```dart
isLocked: map['isLocked'] ?? false,
lockedAt: _parseDateTime(map['lockedAt']),
lockedBy: map['lockedBy'],
lockReason: map['lockReason'],
```

Add to `toMap()`:
```dart
'isLocked': isLocked,
'lockedAt': lockedAt != null ? Timestamp.fromDate(lockedAt!) : null,
'lockedBy': lockedBy,
'lockReason': lockReason,
```

Add helper method:
```dart
/// Check if comments are allowed on this post
bool get canComment => !isLocked && !isRemoved;
```

### Step 2: Add Lock Methods to Moderation Repository

**File**: `lib/features/community/moderation/data/repositories/moderation_repository.dart` (ADD)

```dart
/// Lock a post (prevent new comments)
Future<void> lockPost({
  required String herdId,
  required String postId,
  required String lockedBy,
  String? reason,
}) async {
  final batch = _firestore.batch();
  final now = DateTime.now();

  // 1. Update post document
  final postRef = _firestore
      .collection('herdPosts')
      .doc(herdId)
      .collection('posts')
      .doc(postId);

  batch.update(postRef, {
    'isLocked': true,
    'lockedAt': Timestamp.fromDate(now),
    'lockedBy': lockedBy,
    'lockReason': reason,
  });

  // 2. Log moderation action
  final actionId = _firestore.collection('dummy').doc().id;
  batch.set(
    _firestore
        .collection('moderationLogs')
        .doc(herdId)
        .collection('actions')
        .doc(actionId),
    ModerationAction(
      actionId: actionId,
      performedBy: lockedBy,
      timestamp: now,
      actionType: ModActionType.lockPost,
      targetId: postId,
      targetType: ModTargetType.post,
      reason: reason,
      metadata: {'herdId': herdId},
    ).toMap(),
  );

  await batch.commit();
}

/// Unlock a post (allow comments again)
Future<void> unlockPost({
  required String herdId,
  required String postId,
  required String unlockedBy,
  String? reason,
}) async {
  final batch = _firestore.batch();
  final now = DateTime.now();

  // 1. Update post document
  final postRef = _firestore
      .collection('herdPosts')
      .doc(herdId)
      .collection('posts')
      .doc(postId);

  batch.update(postRef, {
    'isLocked': false,
    'lockedAt': null,
    'lockedBy': null,
    'lockReason': null,
  });

  // 2. Log moderation action
  final actionId = _firestore.collection('dummy').doc().id;
  batch.set(
    _firestore
        .collection('moderationLogs')
        .doc(herdId)
        .collection('actions')
        .doc(actionId),
    ModerationAction(
      actionId: actionId,
      performedBy: unlockedBy,
      timestamp: now,
      actionType: ModActionType.unlockPost,
      targetId: postId,
      targetType: ModTargetType.post,
      reason: reason,
      metadata: {'herdId': herdId},
    ).toMap(),
  );

  await batch.commit();
}

/// Get all locked posts in a herd
Future<List<String>> getLockedPostIds(String herdId) async {
  final snapshot = await _firestore
      .collection('herdPosts')
      .doc(herdId)
      .collection('posts')
      .where('isLocked', isEqualTo: true)
      .get();

  return snapshot.docs.map((doc) => doc.id).toList();
}
```

### Step 3: Add Lock Controller Methods

**File**: `lib/features/community/moderation/view/providers/moderation_providers.dart` (ADD)

```dart
/// Lock a post
Future<void> lockPost({
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
    await repository.lockPost(
      herdId: herdId,
      postId: postId,
      lockedBy: currentUser.uid,
      reason: reason,
    );

    if (!ref.mounted) return;

    // Invalidate post provider to refresh UI
    ref.invalidate(postProvider(postId));
    ref.invalidate(herdPostsProvider(herdId));

    state = const AsyncValue.data(null);
  } catch (e, stack) {
    if (!ref.mounted) return;
    state = AsyncValue.error(e, stack);
  }
}

/// Unlock a post
Future<void> unlockPost({
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
    await repository.unlockPost(
      herdId: herdId,
      postId: postId,
      unlockedBy: currentUser.uid,
      reason: reason,
    );

    if (!ref.mounted) return;

    ref.invalidate(postProvider(postId));
    ref.invalidate(herdPostsProvider(herdId));

    state = const AsyncValue.data(null);
  } catch (e, stack) {
    if (!ref.mounted) return;
    state = AsyncValue.error(e, stack);
  }
}
```

### Step 4: Create Lock Post Dialog

**File**: `lib/features/community/moderation/view/widgets/lock_post_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/moderation_providers.dart';

class LockPostDialog extends ConsumerStatefulWidget {
  final String herdId;
  final String postId;
  final bool isCurrentlyLocked;

  const LockPostDialog({
    super.key,
    required this.herdId,
    required this.postId,
    required this.isCurrentlyLocked,
  });

  @override
  ConsumerState<LockPostDialog> createState() => _LockPostDialogState();
}

class _LockPostDialogState extends ConsumerState<LockPostDialog> {
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final modState = ref.watch(moderationControllerProvider);
    final isLocking = !widget.isCurrentlyLocked;

    return AlertDialog(
      title: Text(isLocking ? 'Lock Post' : 'Unlock Post'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isLocking
                ? 'Locking this post will prevent anyone from adding new comments.'
                : 'Unlocking this post will allow users to comment again.',
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: InputDecoration(
              labelText: 'Reason (optional)',
              hintText: isLocking
                  ? 'Why is this post being locked?'
                  : 'Why is this post being unlocked?',
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: modState.isLoading ? null : _handleAction,
          style: ElevatedButton.styleFrom(
            backgroundColor: isLocking ? Colors.orange : Colors.green,
          ),
          child: modState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(isLocking ? 'Lock' : 'Unlock'),
        ),
      ],
    );
  }

  Future<void> _handleAction() async {
    final controller = ref.read(moderationControllerProvider.notifier);
    final reason = _reasonController.text.isEmpty ? null : _reasonController.text;

    if (widget.isCurrentlyLocked) {
      await controller.unlockPost(
        herdId: widget.herdId,
        postId: widget.postId,
        reason: reason,
      );
    } else {
      await controller.lockPost(
        herdId: widget.herdId,
        postId: widget.postId,
        reason: reason,
      );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.isCurrentlyLocked ? 'Post unlocked' : 'Post locked',
          ),
        ),
      );
    }
  }
}
```

### Step 5: Lock Indicator Widget

**File**: `lib/features/community/moderation/view/widgets/post_lock_indicator.dart`

```dart
import 'package:flutter/material.dart';

class PostLockIndicator extends StatelessWidget {
  final String? lockReason;
  final DateTime? lockedAt;
  final bool showDetails;

  const PostLockIndicator({
    super.key,
    this.lockReason,
    this.lockedAt,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.lock, size: 16, color: Colors.orange),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Comments locked',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                if (showDetails && lockReason != null)
                  Text(
                    lockReason!,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

### Step 6: Enforce Lock in Comment Creation

**File**: Update your comment submission logic (wherever comments are created)

```dart
// Before creating a comment, check if post is locked
Future<void> createComment({
  required String postId,
  required String herdId,
  required String content,
}) async {
  // Fetch post to check lock status
  final postDoc = await _firestore
      .collection('herdPosts')
      .doc(herdId)
      .collection('posts')
      .doc(postId)
      .get();

  if (!postDoc.exists) {
    throw Exception('Post not found');
  }

  final isLocked = postDoc.data()?['isLocked'] ?? false;
  if (isLocked) {
    throw Exception('This post is locked. Comments are not allowed.');
  }

  // Proceed with comment creation...
}
```

### Step 7: Add Lock Option to Post Options Menu

Integrate into your post options/more menu:

```dart
// In post options popup menu or bottom sheet
if (hasPermission(HerdPermission.lockPost)) ...[
  if (post.isLocked)
    ListTile(
      leading: const Icon(Icons.lock_open, color: Colors.green),
      title: const Text('Unlock Post'),
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => LockPostDialog(
            herdId: post.herdId,
            postId: post.id,
            isCurrentlyLocked: true,
          ),
        );
      },
    )
  else
    ListTile(
      leading: const Icon(Icons.lock, color: Colors.orange),
      title: const Text('Lock Post'),
      onTap: () {
        Navigator.pop(context);
        showDialog(
          context: context,
          builder: (_) => LockPostDialog(
            herdId: post.herdId,
            postId: post.id,
            isCurrentlyLocked: false,
          ),
        );
      },
    ),
],
```

### Step 8: Firestore Security Rules

Add to `firestore.rules`:

```javascript
match /herdPosts/{herdId}/posts/{postId} {
  // Existing read rules...
  
  allow update: if request.auth != null
    // Allow moderators to lock/unlock
    && (
      // Lock/unlock operation
      request.resource.data.diff(resource.data).affectedKeys()
        .hasOnly(['isLocked', 'lockedAt', 'lockedBy', 'lockReason'])
      && isHerdModerator(herdId, request.auth.uid)
    );
}

match /herdPosts/{herdId}/posts/{postId}/comments/{commentId} {
  allow create: if request.auth != null
    // Can only create comment if post is not locked
    && get(/databases/$(database)/documents/herdPosts/$(herdId)/posts/$(postId)).data.isLocked != true;
}
```

---

## UI Integration Points

### 1. Post Detail Screen

Show lock indicator at top of post if locked:

```dart
if (post.isLocked) ...[
  PostLockIndicator(
    lockReason: post.lockReason,
    lockedAt: post.lockedAt,
    showDetails: true,
  ),
  const SizedBox(height: 16),
],
```

### 2. Comment Input Area

Disable or hide comment input when locked:

```dart
if (post.isLocked)
  const Center(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Comments are locked on this post',
        style: TextStyle(color: Colors.grey),
      ),
    ),
  )
else
  CommentInputWidget(...),
```

### 3. Post Card in Feed

Show small lock icon on locked posts:

```dart
if (post.isLocked)
  const Positioned(
    top: 8,
    right: 8,
    child: Icon(Icons.lock, size: 16, color: Colors.orange),
  ),
```

---

## Testing Checklist

- [ ] Moderator can lock a post
- [ ] Locked post shows lock indicator
- [ ] Cannot submit comment on locked post (UI disabled)
- [ ] Cannot submit comment on locked post (API rejects)
- [ ] Security rules block comment creation on locked posts
- [ ] Moderator can unlock a post
- [ ] Unlocked post allows comments again
- [ ] Lock/unlock logged to moderation log
- [ ] Lock reason displays correctly

---

## Success Criteria

1. **Lock check is free**: Already have post data, no extra read
2. **Clear UI feedback**: Users know why they can't comment
3. **Audit trail**: All lock/unlock actions logged
4. **Security enforced**: Rules prevent bypassing lock

---

## Estimated Effort

- **Development**: 3-4 hours
- **Testing**: 1-2 hours
- **Total**: ~5-6 hours
