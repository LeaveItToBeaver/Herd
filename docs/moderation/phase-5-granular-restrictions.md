# Phase 5: Granular User Restrictions

## Status: 🔲 Not Started

## Goal

Implement a flexible restriction system that allows moderators to:
1. Block users from specific actions (post, comment, message)
2. Apply rate limits (X posts per hour)
3. Apply time-bound restrictions (restricted for 24 hours)
4. Stack restrictions (can comment but not post)
5. Enforce restrictions efficiently

---

## Prerequisites

- [x] Phase 1 completed (Roles & Permissions)
- [x] Phase 2 completed (Strike System) - may auto-apply restrictions
- [ ] Understand herd member document structure

---

## Architecture Decisions

### 1. Restriction Storage

**Decision**: Store restrictions on the **herd member document**.

```typescript
// /herds/{herdId}/members/{userId}
{
  role: 'member',
  joinedAt: Timestamp,
  
  // NEW: Restrictions map
  restrictions: {
    canPost: boolean,         // Default: true
    canComment: boolean,      // Default: true
    canReact: boolean,        // Default: true
    canMessage: boolean,      // Default: true
    canMessageMods: boolean,  // Default: true
    canReport: boolean,       // Default: true
    
    // Rate limiting
    postCooldownMinutes: number?,    // e.g., 60 = 1 post per hour
    commentCooldownMinutes: number?, // e.g., 5 = 1 comment per 5 min
    
    // Time-bound
    restrictedUntil: Timestamp?,     // When restrictions expire
    
    // Visibility
    shadowBanned: boolean,           // Posts visible only to author
  },
  
  // Last activity timestamps (for rate limiting)
  lastPostAt: Timestamp?,
  lastCommentAt: Timestamp?,
  
  // Restriction metadata
  restrictedBy: string?,
  restrictedAt: Timestamp?,
  restrictionReason: string?,
}
```

**Rationale**:
- Single document read gives all restriction info
- Already fetching member data for role checks
- Restrictions are herd-specific

### 2. Default Restrictions

New members get unrestricted access:
```dart
const defaultRestrictions = {
  'canPost': true,
  'canComment': true,
  'canReact': true,
  'canMessage': true,
  'canMessageMods': true,
  'canReport': true,
  'shadowBanned': false,
};
```

### 3. Cost Analysis

| Operation | Reads | Writes |
|-----------|-------|--------|
| Check restrictions | 0 (cached member doc) | 0 |
| Apply restriction | 1 | 2 (member + log) |
| Check rate limit | 0 (cached member doc) | 0 |
| Update last activity | 0 | 1 (batched with action) |

---

## Implementation Plan

### Step 1: Create Restrictions Model

**File**: `lib/features/community/moderation/data/models/user_restrictions.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_restrictions.freezed.dart';

/// Types of restrictions that can be applied
enum RestrictionType {
  canPost('Posting'),
  canComment('Commenting'),
  canReact('Reacting'),
  canMessage('Messaging'),
  canMessageMods('Messaging Moderators'),
  canReport('Reporting'),
  shadowBanned('Shadow Ban');

  final String displayName;
  const RestrictionType(this.displayName);
}

@freezed
abstract class UserRestrictions with _$UserRestrictions {
  const UserRestrictions._();

  const factory UserRestrictions({
    @Default(true) bool canPost,
    @Default(true) bool canComment,
    @Default(true) bool canReact,
    @Default(true) bool canMessage,
    @Default(true) bool canMessageMods,
    @Default(true) bool canReport,
    @Default(false) bool shadowBanned,
    
    // Rate limiting (in minutes)
    int? postCooldownMinutes,
    int? commentCooldownMinutes,
    
    // Time-bound restrictions
    DateTime? restrictedUntil,
    
    // Metadata
    String? restrictedBy,
    DateTime? restrictedAt,
    String? restrictionReason,
  }) = _UserRestrictions;

  factory UserRestrictions.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const UserRestrictions();
    
    return UserRestrictions(
      canPost: map['canPost'] ?? true,
      canComment: map['canComment'] ?? true,
      canReact: map['canReact'] ?? true,
      canMessage: map['canMessage'] ?? true,
      canMessageMods: map['canMessageMods'] ?? true,
      canReport: map['canReport'] ?? true,
      shadowBanned: map['shadowBanned'] ?? false,
      postCooldownMinutes: map['postCooldownMinutes'],
      commentCooldownMinutes: map['commentCooldownMinutes'],
      restrictedUntil: (map['restrictedUntil'] as Timestamp?)?.toDate(),
      restrictedBy: map['restrictedBy'],
      restrictedAt: (map['restrictedAt'] as Timestamp?)?.toDate(),
      restrictionReason: map['restrictionReason'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canPost': canPost,
      'canComment': canComment,
      'canReact': canReact,
      'canMessage': canMessage,
      'canMessageMods': canMessageMods,
      'canReport': canReport,
      'shadowBanned': shadowBanned,
      'postCooldownMinutes': postCooldownMinutes,
      'commentCooldownMinutes': commentCooldownMinutes,
      'restrictedUntil': restrictedUntil != null 
          ? Timestamp.fromDate(restrictedUntil!) 
          : null,
      'restrictedBy': restrictedBy,
      'restrictedAt': restrictedAt != null 
          ? Timestamp.fromDate(restrictedAt!) 
          : null,
      'restrictionReason': restrictionReason,
    };
  }

  /// Check if restrictions have expired
  bool get areRestrictionsExpired {
    if (restrictedUntil == null) return false;
    return DateTime.now().isAfter(restrictedUntil!);
  }

  /// Check if ALL restrictions are cleared
  bool get isFullyUnrestricted {
    return canPost && 
           canComment && 
           canReact && 
           canMessage && 
           canMessageMods && 
           canReport && 
           !shadowBanned &&
           postCooldownMinutes == null &&
           commentCooldownMinutes == null;
  }

  /// Get list of active restrictions
  List<String> get activeRestrictions {
    final restrictions = <String>[];
    if (!canPost) restrictions.add('Cannot post');
    if (!canComment) restrictions.add('Cannot comment');
    if (!canReact) restrictions.add('Cannot react');
    if (!canMessage) restrictions.add('Cannot message');
    if (!canMessageMods) restrictions.add('Cannot message mods');
    if (!canReport) restrictions.add('Cannot report');
    if (shadowBanned) restrictions.add('Shadow banned');
    if (postCooldownMinutes != null) {
      restrictions.add('Post cooldown: ${postCooldownMinutes}min');
    }
    if (commentCooldownMinutes != null) {
      restrictions.add('Comment cooldown: ${commentCooldownMinutes}min');
    }
    return restrictions;
  }
}
```

### Step 2: Create Restriction Repository

**File**: `lib/features/community/moderation/data/repositories/restriction_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_restrictions.dart';
import '../models/moderation_action_model.dart';

class RestrictionRepository {
  final FirebaseFirestore _firestore;

  RestrictionRepository(this._firestore);

  /// Apply restrictions to a user
  Future<void> applyRestrictions({
    required String herdId,
    required String userId,
    required String appliedBy,
    required UserRestrictions restrictions,
    String? reason,
    Duration? duration, // If provided, sets restrictedUntil
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final memberRef = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(userId);

    // Build restrictions map with metadata
    final restrictionData = restrictions.copyWith(
      restrictedBy: appliedBy,
      restrictedAt: now,
      restrictionReason: reason,
      restrictedUntil: duration != null ? now.add(duration) : null,
    ).toMap();

    batch.update(memberRef, {
      'restrictions': restrictionData,
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
        performedBy: appliedBy,
        timestamp: now,
        actionType: ModActionType.restrictUser,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason,
        metadata: {
          'herdId': herdId,
          'restrictions': restrictionData,
          'duration': duration?.inMinutes,
        },
      ).toMap(),
    );

    await batch.commit();
  }

  /// Remove all restrictions from a user
  Future<void> clearRestrictions({
    required String herdId,
    required String userId,
    required String clearedBy,
    String? reason,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    final memberRef = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(userId);

    batch.update(memberRef, {
      'restrictions': const UserRestrictions().toMap(),
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
        performedBy: clearedBy,
        timestamp: now,
        actionType: ModActionType.unrestrictUser,
        targetId: userId,
        targetType: ModTargetType.user,
        reason: reason ?? 'Restrictions cleared',
        metadata: {'herdId': herdId},
      ).toMap(),
    );

    await batch.commit();
  }

  /// Get a user's current restrictions
  Future<UserRestrictions> getUserRestrictions(
    String herdId,
    String userId,
  ) async {
    final memberDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(userId)
        .get();

    if (!memberDoc.exists) {
      return const UserRestrictions();
    }

    return UserRestrictions.fromMap(memberDoc.data()?['restrictions']);
  }

  /// Check if user can perform a specific action
  Future<RestrictionCheckResult> checkRestriction({
    required String herdId,
    required String userId,
    required RestrictionType type,
    DateTime? lastActivity, // For rate limiting checks
  }) async {
    final memberDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(userId)
        .get();

    if (!memberDoc.exists) {
      return RestrictionCheckResult.allowed();
    }

    final data = memberDoc.data()!;
    final restrictions = UserRestrictions.fromMap(data['restrictions']);

    // Check if time-bound restrictions have expired
    if (restrictions.restrictedUntil != null &&
        DateTime.now().isAfter(restrictions.restrictedUntil!)) {
      // Restrictions expired, allow action
      return RestrictionCheckResult.allowed();
    }

    // Check specific restriction type
    switch (type) {
      case RestrictionType.canPost:
        if (!restrictions.canPost) {
          return RestrictionCheckResult.blocked(
            'You are restricted from posting in this community',
          );
        }
        // Check rate limit
        if (restrictions.postCooldownMinutes != null) {
          final lastPostAt = (data['lastPostAt'] as Timestamp?)?.toDate();
          if (lastPostAt != null) {
            final cooldownEnd = lastPostAt.add(
              Duration(minutes: restrictions.postCooldownMinutes!),
            );
            if (DateTime.now().isBefore(cooldownEnd)) {
              final remaining = cooldownEnd.difference(DateTime.now());
              return RestrictionCheckResult.rateLimited(
                'You can post again in ${remaining.inMinutes} minutes',
                cooldownEnd,
              );
            }
          }
        }
        break;

      case RestrictionType.canComment:
        if (!restrictions.canComment) {
          return RestrictionCheckResult.blocked(
            'You are restricted from commenting in this community',
          );
        }
        // Check rate limit
        if (restrictions.commentCooldownMinutes != null) {
          final lastCommentAt = (data['lastCommentAt'] as Timestamp?)?.toDate();
          if (lastCommentAt != null) {
            final cooldownEnd = lastCommentAt.add(
              Duration(minutes: restrictions.commentCooldownMinutes!),
            );
            if (DateTime.now().isBefore(cooldownEnd)) {
              final remaining = cooldownEnd.difference(DateTime.now());
              return RestrictionCheckResult.rateLimited(
                'You can comment again in ${remaining.inMinutes} minutes',
                cooldownEnd,
              );
            }
          }
        }
        break;

      case RestrictionType.canReact:
        if (!restrictions.canReact) {
          return RestrictionCheckResult.blocked(
            'You are restricted from reacting in this community',
          );
        }
        break;

      case RestrictionType.canMessage:
        if (!restrictions.canMessage) {
          return RestrictionCheckResult.blocked(
            'You are restricted from messaging in this community',
          );
        }
        break;

      case RestrictionType.canMessageMods:
        if (!restrictions.canMessageMods) {
          return RestrictionCheckResult.blocked(
            'You are restricted from messaging moderators',
          );
        }
        break;

      case RestrictionType.canReport:
        if (!restrictions.canReport) {
          return RestrictionCheckResult.blocked(
            'You are restricted from submitting reports',
          );
        }
        break;

      case RestrictionType.shadowBanned:
        // Shadow ban doesn't block, just affects visibility
        break;
    }

    return RestrictionCheckResult.allowed(
      shadowBanned: restrictions.shadowBanned,
    );
  }

  /// Update last activity timestamp (called when posting/commenting)
  Future<void> updateLastActivity({
    required String herdId,
    required String userId,
    required RestrictionType activityType,
  }) async {
    final fieldName = switch (activityType) {
      RestrictionType.canPost => 'lastPostAt',
      RestrictionType.canComment => 'lastCommentAt',
      _ => null,
    };

    if (fieldName != null) {
      await _firestore
          .collection('herds')
          .doc(herdId)
          .collection('members')
          .doc(userId)
          .update({
        fieldName: FieldValue.serverTimestamp(),
      });
    }
  }

  /// Get all restricted users in a herd
  Future<List<Map<String, dynamic>>> getRestrictedUsers(String herdId) async {
    // Query for users with any restriction
    final snapshot = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .where('restrictions.restrictedAt', isNull: false)
        .get();

    return snapshot.docs
        .where((doc) {
          final restrictions = UserRestrictions.fromMap(
            doc.data()['restrictions'],
          );
          return !restrictions.isFullyUnrestricted;
        })
        .map((doc) => {
          'userId': doc.id,
          ...doc.data(),
        })
        .toList();
  }
}

/// Result of a restriction check
class RestrictionCheckResult {
  final bool isAllowed;
  final String? message;
  final DateTime? retryAfter;
  final bool shadowBanned;

  RestrictionCheckResult._({
    required this.isAllowed,
    this.message,
    this.retryAfter,
    this.shadowBanned = false,
  });

  factory RestrictionCheckResult.allowed({bool shadowBanned = false}) {
    return RestrictionCheckResult._(
      isAllowed: true,
      shadowBanned: shadowBanned,
    );
  }

  factory RestrictionCheckResult.blocked(String message) {
    return RestrictionCheckResult._(
      isAllowed: false,
      message: message,
    );
  }

  factory RestrictionCheckResult.rateLimited(String message, DateTime retryAfter) {
    return RestrictionCheckResult._(
      isAllowed: false,
      message: message,
      retryAfter: retryAfter,
    );
  }
}
```

### Step 3: Create Restriction Providers

**File**: `lib/features/community/moderation/view/providers/restriction_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/restriction_repository.dart';
import '../../data/models/user_restrictions.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

part 'restriction_providers.g.dart';

@riverpod
RestrictionRepository restrictionRepository(Ref ref) {
  return RestrictionRepository(FirebaseFirestore.instance);
}

/// Get current user's restrictions in a herd
@riverpod
Future<UserRestrictions> currentUserRestrictions(
  Ref ref,
  String herdId,
) async {
  final user = ref.watch(authProvider);
  if (user == null) return const UserRestrictions();

  final repo = ref.watch(restrictionRepositoryProvider);
  return repo.getUserRestrictions(herdId, user.uid);
}

/// Check if current user can perform an action
@riverpod
Future<RestrictionCheckResult> canPerformAction(
  Ref ref,
  String herdId,
  RestrictionType actionType,
) async {
  final user = ref.watch(authProvider);
  if (user == null) {
    return RestrictionCheckResult.blocked('Not authenticated');
  }

  final repo = ref.watch(restrictionRepositoryProvider);
  return repo.checkRestriction(
    herdId: herdId,
    userId: user.uid,
    type: actionType,
  );
}

/// Stream restricted users for management screen
@riverpod
Stream<List<Map<String, dynamic>>> restrictedUsers(
  Ref ref,
  String herdId,
) {
  return FirebaseFirestore.instance
      .collection('herds')
      .doc(herdId)
      .collection('members')
      .where('restrictions.restrictedAt', isNull: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => {'userId': doc.id, ...doc.data()})
          .toList());
}

/// Controller for restriction actions
@riverpod
class RestrictionController extends _$RestrictionController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> applyRestrictions({
    required String herdId,
    required String userId,
    required UserRestrictions restrictions,
    String? reason,
    Duration? duration,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(restrictionRepositoryProvider);
      await repo.applyRestrictions(
        herdId: herdId,
        userId: userId,
        appliedBy: user.uid,
        restrictions: restrictions,
        reason: reason,
        duration: duration,
      );

      ref.invalidate(restrictedUsersProvider(herdId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> clearRestrictions({
    required String herdId,
    required String userId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(restrictionRepositoryProvider);
      await repo.clearRestrictions(
        herdId: herdId,
        userId: userId,
        clearedBy: user.uid,
        reason: reason,
      );

      ref.invalidate(restrictedUsersProvider(herdId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### Step 4: Apply Restrictions Dialog

**File**: `lib/features/community/moderation/view/widgets/apply_restrictions_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_restrictions.dart';
import '../providers/restriction_providers.dart';

class ApplyRestrictionsDialog extends ConsumerStatefulWidget {
  final String herdId;
  final String userId;
  final String username;
  final UserRestrictions? currentRestrictions;

  const ApplyRestrictionsDialog({
    super.key,
    required this.herdId,
    required this.userId,
    required this.username,
    this.currentRestrictions,
  });

  @override
  ConsumerState<ApplyRestrictionsDialog> createState() =>
      _ApplyRestrictionsDialogState();
}

class _ApplyRestrictionsDialogState
    extends ConsumerState<ApplyRestrictionsDialog> {
  late bool _canPost;
  late bool _canComment;
  late bool _canReact;
  late bool _canMessage;
  late bool _shadowBanned;
  int? _postCooldown;
  int? _commentCooldown;
  Duration? _duration;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final r = widget.currentRestrictions ?? const UserRestrictions();
    _canPost = r.canPost;
    _canComment = r.canComment;
    _canReact = r.canReact;
    _canMessage = r.canMessage;
    _shadowBanned = r.shadowBanned;
    _postCooldown = r.postCooldownMinutes;
    _commentCooldown = r.commentCooldownMinutes;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restrictionControllerProvider);

    return AlertDialog(
      title: Text('Restrict ${widget.username}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Permissions',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Can Post'),
              value: _canPost,
              onChanged: (v) => setState(() => _canPost = v),
            ),
            SwitchListTile(
              title: const Text('Can Comment'),
              value: _canComment,
              onChanged: (v) => setState(() => _canComment = v),
            ),
            SwitchListTile(
              title: const Text('Can React'),
              value: _canReact,
              onChanged: (v) => setState(() => _canReact = v),
            ),
            SwitchListTile(
              title: const Text('Can Message'),
              value: _canMessage,
              onChanged: (v) => setState(() => _canMessage = v),
            ),
            const Divider(),
            const Text('Special Restrictions',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SwitchListTile(
              title: const Text('Shadow Ban'),
              subtitle: const Text('Posts only visible to them'),
              value: _shadowBanned,
              onChanged: (v) => setState(() => _shadowBanned = v),
            ),
            const Divider(),
            const Text('Rate Limits',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildCooldownDropdown(
              'Post Cooldown',
              _postCooldown,
              (v) => setState(() => _postCooldown = v),
            ),
            _buildCooldownDropdown(
              'Comment Cooldown',
              _commentCooldown,
              (v) => setState(() => _commentCooldown = v),
            ),
            const Divider(),
            const Text('Duration',
                style: TextStyle(fontWeight: FontWeight.bold)),
            _buildDurationDropdown(),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
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
          onPressed: state.isLoading ? null : _applyRestrictions,
          child: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Apply'),
        ),
      ],
    );
  }

  Widget _buildCooldownDropdown(
    String label,
    int? value,
    ValueChanged<int?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: DropdownButtonFormField<int?>(
        value: value,
        decoration: InputDecoration(labelText: label),
        items: const [
          DropdownMenuItem(value: null, child: Text('None')),
          DropdownMenuItem(value: 5, child: Text('5 minutes')),
          DropdownMenuItem(value: 15, child: Text('15 minutes')),
          DropdownMenuItem(value: 30, child: Text('30 minutes')),
          DropdownMenuItem(value: 60, child: Text('1 hour')),
          DropdownMenuItem(value: 360, child: Text('6 hours')),
          DropdownMenuItem(value: 1440, child: Text('24 hours')),
        ],
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDurationDropdown() {
    return DropdownButtonFormField<Duration?>(
      value: _duration,
      decoration: const InputDecoration(labelText: 'Restriction Duration'),
      items: const [
        DropdownMenuItem(value: null, child: Text('Permanent')),
        DropdownMenuItem(
          value: Duration(hours: 1),
          child: Text('1 hour'),
        ),
        DropdownMenuItem(
          value: Duration(hours: 24),
          child: Text('24 hours'),
        ),
        DropdownMenuItem(
          value: Duration(days: 7),
          child: Text('1 week'),
        ),
        DropdownMenuItem(
          value: Duration(days: 30),
          child: Text('30 days'),
        ),
      ],
      onChanged: (v) => setState(() => _duration = v),
    );
  }

  Future<void> _applyRestrictions() async {
    final restrictions = UserRestrictions(
      canPost: _canPost,
      canComment: _canComment,
      canReact: _canReact,
      canMessage: _canMessage,
      shadowBanned: _shadowBanned,
      postCooldownMinutes: _postCooldown,
      commentCooldownMinutes: _commentCooldown,
    );

    await ref.read(restrictionControllerProvider.notifier).applyRestrictions(
          herdId: widget.herdId,
          userId: widget.userId,
          restrictions: restrictions,
          reason: _reasonController.text.isEmpty
              ? null
              : _reasonController.text,
          duration: _duration,
        );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restrictions applied to ${widget.username}')),
      );
    }
  }
}
```

### Step 5: Enforcement Integration

#### In Post Creation:

```dart
Future<void> createPost(...) async {
  final restrictionCheck = await ref.read(
    canPerformActionProvider(herdId, RestrictionType.canPost).future,
  );

  if (!restrictionCheck.isAllowed) {
    throw Exception(restrictionCheck.message);
  }

  // Create post...

  // If shadow banned, mark post as shadow banned
  if (restrictionCheck.shadowBanned) {
    // Post is created but with 'shadowBanned: true'
    // Feed queries filter out shadowBanned posts unless viewing own posts
  }

  // Update last activity for rate limiting
  await ref.read(restrictionRepositoryProvider).updateLastActivity(
    herdId: herdId,
    userId: userId,
    activityType: RestrictionType.canPost,
  );
}
```

#### In Comment Creation:

```dart
Future<void> createComment(...) async {
  final restrictionCheck = await ref.read(
    canPerformActionProvider(herdId, RestrictionType.canComment).future,
  );

  if (!restrictionCheck.isAllowed) {
    throw Exception(restrictionCheck.message);
  }

  // Create comment...

  // Update last activity
  await ref.read(restrictionRepositoryProvider).updateLastActivity(
    herdId: herdId,
    userId: userId,
    activityType: RestrictionType.canComment,
  );
}
```

### Step 6: Add to ModActionType Enum

Add to `moderation_action_model.dart`:

```dart
enum ModActionType {
  // ... existing types ...
  
  // User restrictions
  restrictUser,
  unrestrictUser,
}
```

---

## Security Rules

```javascript
// Only mods can update restrictions
match /herds/{herdId}/members/{memberId} {
  allow update: if request.auth != null
    && isHerdModerator(herdId, request.auth.uid)
    && (
      request.resource.data.diff(resource.data).affectedKeys()
        .hasOnly(['restrictions', 'lastPostAt', 'lastCommentAt'])
    );
}

// Enforce posting restrictions
match /herdPosts/{herdId}/posts/{postId} {
  allow create: if request.auth != null
    && get(/databases/$(database)/documents/herds/$(herdId)/members/$(request.auth.uid)).data.restrictions.canPost != false;
}
```

---

## Testing Checklist

- [ ] Can apply single restriction (e.g., no posting)
- [ ] Can apply multiple restrictions
- [ ] Can apply rate limit
- [ ] Rate limit enforced correctly
- [ ] Time-bound restrictions expire
- [ ] Shadow ban hides posts from others
- [ ] Shadow ban shows posts to author
- [ ] Can clear all restrictions
- [ ] Restrictions logged to mod log
- [ ] Restricted users list shows correctly

---

## Estimated Effort

- **Development**: 6-8 hours
- **Testing**: 3-4 hours
- **Total**: ~10-12 hours
