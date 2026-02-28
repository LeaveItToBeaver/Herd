# Phase 2: Strike/Warning System

## Status: 🔲 Not Started

## Goal

Create a comprehensive strike/warning system that:
1. Tracks violations against users within herds
2. Supports automatic escalation (3 strikes → suspension)
3. Allows different severity levels
4. Maintains full audit history
5. Enables users to see their strike status

---

## Prerequisites

- [x] Phase 1 completed (Roles & Permissions)
- [ ] `HerdPermission.warnUser` permission working
- [ ] Role hierarchy enforcement in place

---

## Architecture Decisions

### 1. Strike Storage Strategy

**Decision**: Store strikes as a **subcollection under the herd**, not on the user document.

```
/herds/{herdId}/strikes/{strikeId}
  - oderId: string (who got the strike)
  - issuedBy: string (moderator who issued it)
  - issuedAt: Timestamp
  - reason: StrikeReason enum
  - severity: StrikeSeverity enum (minor, moderate, severe)
  - description: string (optional details)
  - expiresAt: Timestamp (null = permanent)
  - isActive: bool
  - appealedAt: Timestamp (if appealed)
  - appealStatus: 'pending' | 'approved' | 'denied' | null
```

**Rationale**:
- Strikes are herd-specific (banned from Herd A ≠ banned from Herd B)
- Easy to query "all strikes for user X in herd Y"
- Easy to query "all active strikes in herd Y" for dashboard
- Subcollection scales independently

### 2. Denormalized Counter for Performance

Store an aggregated counter on the member document:

```
/herds/{herdId}/members/{userId}
  - activeStrikeCount: int
  - totalStrikeCount: int
  - lastStrikeAt: Timestamp
```

**Rationale**:
- Avoid counting documents on every page load
- Quick "does this user have strikes?" check
- Updated via Cloud Function or batch write

### 3. Automatic Escalation Thresholds

| Active Strikes | Action |
|----------------|--------|
| 1 | Warning notification sent |
| 2 | Posting rate-limited (1 post/hour) |
| 3 | Auto-suspended for 24 hours |
| 5 | Auto-banned |

Thresholds stored in herd settings (configurable by owner).

### 4. Cost Analysis

| Operation | Reads | Writes |
|-----------|-------|--------|
| Issue strike | 2 | 3 (strike doc, member counter, mod log) |
| View user strikes | 1 (paginated) | 0 |
| Check strike count | 0 (from cached member doc) | 0 |
| Dashboard: users with strikes | 1 (query) | 0 |

---

## Data Models

### StrikeModel

**File**: `lib/features/community/moderation/data/models/strike_model.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'strike_model.freezed.dart';

/// Reasons a strike can be issued
enum StrikeReason {
  spam('Spam or self-promotion'),
  harassment('Harassment or bullying'),
  hateech('Hate speech or discrimination'),
  misinformation('Spreading misinformation'),
  inappropriateContent('Inappropriate or NSFW content'),
  doxxing('Sharing private information'),
  impersonation('Impersonating another user'),
  scam('Scam or fraudulent activity'),
  violenceThreats('Threats or incitement of violence'),
  copyrightViolation('Copyright infringement'),
  repeatedViolations('Repeated rule violations'),
  other('Other');

  final String displayName;
  const StrikeReason(this.displayName);
}

/// Severity affects how quickly escalation happens
enum StrikeSeverity {
  minor(1, 'Minor', Duration(days: 30)),
  moderate(2, 'Moderate', Duration(days: 90)),
  severe(3, 'Severe', Duration(days: 365));

  final int weight;
  final String displayName;
  final Duration defaultExpiry;
  const StrikeSeverity(this.weight, this.displayName, this.defaultExpiry);
}

/// Appeal status for contested strikes
enum AppealStatus {
  pending,
  approved,  // Strike removed
  denied,    // Strike upheld
}

@freezed
abstract class StrikeModel with _$StrikeModel {
  const StrikeModel._();

  const factory StrikeModel({
    required String id,
    required String oderId,
    required String herdId,
    required String issuedBy,
    required DateTime issuedAt,
    required StrikeReason reason,
    @Default(StrikeSeverity.moderate) StrikeSeverity severity,
    String? description,
    String? relatedContentId,  // Post/comment that caused the strike
    String? relatedContentType, // 'post' | 'comment'
    DateTime? expiresAt,
    @Default(true) bool isActive,
    DateTime? appealedAt,
    AppealStatus? appealStatus,
    String? appealNotes,
    String? appealReviewedBy,
  }) = _StrikeModel;

  factory StrikeModel.fromMap(String id, Map<String, dynamic> map) {
    return StrikeModel(
      id: id,
      oderId: map['userId'] ?? '',
      herdId: map['herdId'] ?? '',
      issuedBy: map['issuedBy'] ?? '',
      issuedAt: (map['issuedAt'] as Timestamp).toDate(),
      reason: StrikeReason.values.firstWhere(
        (r) => r.name == map['reason'],
        orElse: () => StrikeReason.other,
      ),
      severity: StrikeSeverity.values.firstWhere(
        (s) => s.name == map['severity'],
        orElse: () => StrikeSeverity.moderate,
      ),
      description: map['description'],
      relatedContentId: map['relatedContentId'],
      relatedContentType: map['relatedContentType'],
      expiresAt: (map['expiresAt'] as Timestamp?)?.toDate(),
      isActive: map['isActive'] ?? true,
      appealedAt: (map['appealedAt'] as Timestamp?)?.toDate(),
      appealStatus: map['appealStatus'] != null
          ? AppealStatus.values.firstWhere(
              (s) => s.name == map['appealStatus'],
              orElse: () => AppealStatus.pending,
            )
          : null,
      appealNotes: map['appealNotes'],
      appealReviewedBy: map['appealReviewedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': oderId,
      'herdId': herdId,
      'issuedBy': issuedBy,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'reason': reason.name,
      'severity': severity.name,
      'description': description,
      'relatedContentId': relatedContentId,
      'relatedContentType': relatedContentType,
      'expiresAt': expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'isActive': isActive,
      'appealedAt': appealedAt != null ? Timestamp.fromDate(appealedAt!) : null,
      'appealStatus': appealStatus?.name,
      'appealNotes': appealNotes,
      'appealReviewedBy': appealReviewedBy,
    };
  }

  /// Check if this strike is currently active (not expired, not appealed)
  bool get isCurrentlyActive {
    if (!isActive) return false;
    if (appealStatus == AppealStatus.approved) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    return true;
  }

  /// Get the weighted value for escalation calculation
  int get escalationWeight => severity.weight;
}
```

### StrikeThresholds Configuration

**File**: `lib/features/community/moderation/data/models/strike_thresholds.dart`

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'strike_thresholds.freezed.dart';

/// Configurable thresholds for automatic escalation
@freezed
abstract class StrikeThresholds with _$StrikeThresholds {
  const factory StrikeThresholds({
    @Default(1) int warningThreshold,      // Send warning notification
    @Default(2) int rateLimitThreshold,    // Rate-limit posting
    @Default(3) int autoSuspendThreshold,  // Auto-suspend
    @Default(5) int autoBanThreshold,      // Auto-ban
    @Default(Duration(hours: 24)) Duration autoSuspendDuration,
    @Default(true) bool enableAutoEscalation,
  }) = _StrikeThresholds;

  factory StrikeThresholds.fromMap(Map<String, dynamic> map) {
    return StrikeThresholds(
      warningThreshold: map['warningThreshold'] ?? 1,
      rateLimitThreshold: map['rateLimitThreshold'] ?? 2,
      autoSuspendThreshold: map['autoSuspendThreshold'] ?? 3,
      autoBanThreshold: map['autoBanThreshold'] ?? 5,
      autoSuspendDuration: Duration(
        hours: map['autoSuspendHours'] ?? 24,
      ),
      enableAutoEscalation: map['enableAutoEscalation'] ?? true,
    );
  }
}
```

---

## Implementation Plan

### Step 1: Create Strike Repository

**File**: `lib/features/community/moderation/data/repositories/strike_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/strike_model.dart';
import '../models/strike_thresholds.dart';
import '../models/moderation_action_model.dart';

class StrikeRepository {
  final FirebaseFirestore _firestore;

  StrikeRepository(this._firestore);

  /// Issue a strike to a user
  Future<StrikeModel> issueStrike({
    required String herdId,
    required String oderId,
    required String issuedBy,
    required StrikeReason reason,
    required StrikeSeverity severity,
    String? description,
    String? relatedContentId,
    String? relatedContentType,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();
    final strikeId = _firestore.collection('dummy').doc().id;

    // Calculate expiry based on severity
    final expiresAt = now.add(severity.defaultExpiry);

    final strike = StrikeModel(
      id: strikeId,
      oderId: oderId,
      herdId: herdId,
      issuedBy: issuedBy,
      issuedAt: now,
      reason: reason,
      severity: severity,
      description: description,
      relatedContentId: relatedContentId,
      relatedContentType: relatedContentType,
      expiresAt: expiresAt,
    );

    // 1. Create strike document
    final strikeRef = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('strikes')
        .doc(strikeId);
    batch.set(strikeRef, strike.toMap());

    // 2. Update member's strike counters
    final memberRef = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(oderId);
    batch.update(memberRef, {
      'activeStrikeCount': FieldValue.increment(1),
      'totalStrikeCount': FieldValue.increment(1),
      'lastStrikeAt': Timestamp.fromDate(now),
    });

    // 3. Log moderation action
    final actionId = _firestore.collection('dummy').doc().id;
    final actionRef = _firestore
        .collection('moderationLogs')
        .doc(herdId)
        .collection('actions')
        .doc(actionId);
    batch.set(actionRef, ModerationAction(
      actionId: actionId,
      performedBy: issuedBy,
      timestamp: now,
      actionType: ModActionType.warnUser,
      targetId: oderId,
      targetType: ModTargetType.user,
      reason: '${reason.displayName}: ${description ?? "No details"}',
      metadata: {
        'strikeId': strikeId,
        'severity': severity.name,
        'relatedContentId': relatedContentId,
      },
    ).toMap());

    await batch.commit();

    // 4. Check for auto-escalation (async, don't block)
    _checkAutoEscalation(herdId, oderId);

    return strike;
  }

  /// Check and apply automatic escalation based on strike count
  Future<void> _checkAutoEscalation(String herdId, String oderId) async {
    // Get herd thresholds
    final herdDoc = await _firestore.collection('herds').doc(herdId).get();
    final thresholds = StrikeThresholds.fromMap(
      herdDoc.data()?['strikeThresholds'] ?? {},
    );

    if (!thresholds.enableAutoEscalation) return;

    // Get current active strike count
    final memberDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(oderId)
        .get();

    final activeStrikes = memberDoc.data()?['activeStrikeCount'] ?? 0;

    if (activeStrikes >= thresholds.autoBanThreshold) {
      // Auto-ban
      await _autoBan(herdId, oderId);
    } else if (activeStrikes >= thresholds.autoSuspendThreshold) {
      // Auto-suspend
      await _autoSuspend(herdId, oderId, thresholds.autoSuspendDuration);
    } else if (activeStrikes >= thresholds.rateLimitThreshold) {
      // Apply rate limit
      await _applyRateLimit(herdId, oderId);
    }
    // Warning notification is handled by Cloud Function
  }

  Future<void> _autoBan(String herdId, String oderId) async {
    await _firestore.collection('herds').doc(herdId).update({
      'bannedUserIds': FieldValue.arrayUnion([oderId]),
    });
    // Additional ban logic...
  }

  Future<void> _autoSuspend(String herdId, String oderId, Duration duration) async {
    await _firestore
        .collection('herdSuspensions')
        .doc(herdId)
        .collection('suspended')
        .doc(oderId)
        .set({
      'suspendedAt': FieldValue.serverTimestamp(),
      'suspendedUntil': Timestamp.fromDate(DateTime.now().add(duration)),
      'suspendedBy': 'SYSTEM_AUTO',
      'reason': 'Automatic suspension due to strike threshold',
      'isActive': true,
    });
  }

  Future<void> _applyRateLimit(String herdId, String oderId) async {
    await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(oderId)
        .update({
      'restrictions': {
        'postRateLimited': true,
        'postCooldownMinutes': 60,
      },
    });
  }

  /// Get active strikes for a user in a herd
  Future<List<StrikeModel>> getUserStrikes(
    String herdId,
    String oderId, {
    bool activeOnly = true,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('strikes')
        .where('userId', isEqualTo: oderId)
        .orderBy('issuedAt', descending: true)
        .limit(limit);

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => StrikeModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Get all users with active strikes (for dashboard)
  Future<List<Map<String, dynamic>>> getUsersWithStrikes(
    String herdId, {
    int minStrikes = 1,
    int limit = 50,
  }) async {
    final snapshot = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .where('activeStrikeCount', isGreaterThanOrEqualTo: minStrikes)
        .orderBy('activeStrikeCount', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => {
      'userId': doc.id,
      ...doc.data(),
    }).toList();
  }

  /// Remove/expire a strike
  Future<void> removeStrike(
    String herdId,
    String strikeId,
    String removedBy, {
    String? reason,
  }) async {
    final strikeRef = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('strikes')
        .doc(strikeId);

    final strikeDoc = await strikeRef.get();
    if (!strikeDoc.exists) throw Exception('Strike not found');

    final strike = StrikeModel.fromMap(strikeId, strikeDoc.data()!);
    if (!strike.isActive) throw Exception('Strike is already inactive');

    final batch = _firestore.batch();

    // Deactivate strike
    batch.update(strikeRef, {
      'isActive': false,
    });

    // Decrement counter
    batch.update(
      _firestore
          .collection('herds')
          .doc(herdId)
          .collection('members')
          .doc(strike.oderId),
      {
        'activeStrikeCount': FieldValue.increment(-1),
      },
    );

    // Log action
    final actionId = _firestore.collection('dummy').doc().id;
    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      {
        'actionId': actionId,
        'performedBy': removedBy,
        'timestamp': FieldValue.serverTimestamp(),
        'actionType': 'removeStrike',
        'targetId': strike.oderId,
        'targetType': 'user',
        'reason': reason,
        'metadata': {'strikeId': strikeId},
      },
    );

    await batch.commit();
  }

  /// Process a strike appeal
  Future<void> processAppeal(
    String herdId,
    String strikeId,
    String reviewedBy,
    bool approved, {
    String? notes,
  }) async {
    final batch = _firestore.batch();
    final strikeRef = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('strikes')
        .doc(strikeId);

    batch.update(strikeRef, {
      'appealStatus': approved ? 'approved' : 'denied',
      'appealReviewedBy': reviewedBy,
      'appealNotes': notes,
      if (approved) 'isActive': false,
    });

    if (approved) {
      final strikeDoc = await strikeRef.get();
      final strike = StrikeModel.fromMap(strikeId, strikeDoc.data()!);

      batch.update(
        _firestore
            .collection('herds')
            .doc(herdId)
            .collection('members')
            .doc(strike.oderId),
        {
          'activeStrikeCount': FieldValue.increment(-1),
        },
      );
    }

    await batch.commit();
  }
}
```

### Step 2: Create Strike Providers

**File**: `lib/features/community/moderation/view/providers/strike_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/strike_repository.dart';
import '../../data/models/strike_model.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

part 'strike_providers.g.dart';

@riverpod
StrikeRepository strikeRepository(Ref ref) {
  return StrikeRepository(FirebaseFirestore.instance);
}

/// Stream active strikes for a user in a herd
@riverpod
Stream<List<StrikeModel>> userStrikes(
  Ref ref,
  String herdId,
  String oderId,
) {
  return FirebaseFirestore.instance
      .collection('herds')
      .doc(herdId)
      .collection('strikes')
      .where('userId', isEqualTo: oderId)
      .where('isActive', isEqualTo: true)
      .orderBy('issuedAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => StrikeModel.fromMap(doc.id, doc.data()))
          .toList());
}

/// Get strike count for current user in a herd (for UI warnings)
@riverpod
Future<int> currentUserStrikeCount(Ref ref, String herdId) async {
  final user = ref.watch(authProvider);
  if (user == null) return 0;

  final memberDoc = await FirebaseFirestore.instance
      .collection('herds')
      .doc(herdId)
      .collection('members')
      .doc(user.uid)
      .get();

  return memberDoc.data()?['activeStrikeCount'] ?? 0;
}

/// Users with strikes (for mod dashboard)
@riverpod
Future<List<Map<String, dynamic>>> usersWithStrikes(
  Ref ref,
  String herdId,
) async {
  final repo = ref.watch(strikeRepositoryProvider);
  return repo.getUsersWithStrikes(herdId);
}

/// Controller for strike actions
@riverpod
class StrikeController extends _$StrikeController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> issueStrike({
    required String herdId,
    required String oderId,
    required StrikeReason reason,
    required StrikeSeverity severity,
    String? description,
    String? relatedContentId,
    String? relatedContentType,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(strikeRepositoryProvider);
      await repo.issueStrike(
        herdId: herdId,
        oderId: oderId,
        issuedBy: user.uid,
        reason: reason,
        severity: severity,
        description: description,
        relatedContentId: relatedContentId,
        relatedContentType: relatedContentType,
      );

      // Invalidate related providers
      ref.invalidate(userStrikesProvider(herdId, oderId));
      ref.invalidate(usersWithStrikesProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeStrike({
    required String herdId,
    required String strikeId,
    String? reason,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(strikeRepositoryProvider);
      await repo.removeStrike(herdId, strikeId, user.uid, reason: reason);

      ref.invalidate(usersWithStrikesProvider(herdId));
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### Step 3: Create Strike Dialog Widget

**File**: `lib/features/community/moderation/view/widgets/issue_strike_dialog.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/strike_model.dart';
import '../providers/strike_providers.dart';

class IssueStrikeDialog extends ConsumerStatefulWidget {
  final String herdId;
  final String oderId;
  final String username;
  final String? relatedContentId;
  final String? relatedContentType;

  const IssueStrikeDialog({
    super.key,
    required this.herdId,
    required this.oderId,
    required this.username,
    this.relatedContentId,
    this.relatedContentType,
  });

  @override
  ConsumerState<IssueStrikeDialog> createState() => _IssueStrikeDialogState();
}

class _IssueStrikeDialogState extends ConsumerState<IssueStrikeDialog> {
  StrikeReason _selectedReason = StrikeReason.other;
  StrikeSeverity _selectedSeverity = StrikeSeverity.moderate;
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strikeState = ref.watch(strikeControllerProvider);

    return AlertDialog(
      title: Text('Issue Strike to ${widget.username}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Reason:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<StrikeReason>(
              value: _selectedReason,
              items: StrikeReason.values.map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedReason = value);
              },
            ),
            const SizedBox(height: 16),
            const Text('Severity:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<StrikeSeverity>(
              segments: StrikeSeverity.values.map((severity) {
                return ButtonSegment(
                  value: severity,
                  label: Text(severity.displayName),
                );
              }).toList(),
              selected: {_selectedSeverity},
              onSelectionChanged: (selected) {
                setState(() => _selectedSeverity = selected.first);
              },
            ),
            const SizedBox(height: 8),
            Text(
              'Expires in ${_selectedSeverity.defaultExpiry.inDays} days',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Additional Details (optional)',
                hintText: 'Describe the violation...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
          onPressed: strikeState.isLoading ? null : _issueStrike,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: strikeState.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Issue Strike'),
        ),
      ],
    );
  }

  Future<void> _issueStrike() async {
    await ref.read(strikeControllerProvider.notifier).issueStrike(
      herdId: widget.herdId,
      oderId: widget.oderId,
      reason: _selectedReason,
      severity: _selectedSeverity,
      description: _descriptionController.text.isEmpty
          ? null
          : _descriptionController.text,
      relatedContentId: widget.relatedContentId,
      relatedContentType: widget.relatedContentType,
    );

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Strike issued to ${widget.username}')),
      );
    }
  }
}
```

### Step 4: Cloud Function for Strike Notifications

**File**: `functions/strike_handlers.js`

```javascript
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');

/**
 * Send notification when a strike is issued
 */
exports.onStrikeCreated = onDocumentCreated(
  "herds/{herdId}/strikes/{strikeId}",
  async (event) => {
    const strikeData = event.data.data();
    const { herdId, strikeId } = event.params;

    try {
      // Get user's FCM token
      const userDoc = await firestore
        .collection('users')
        .doc(strikeData.userId)
        .get();

      const fcmToken = userDoc.data()?.fcmToken;
      if (!fcmToken) {
        logger.info(`No FCM token for user ${strikeData.userId}`);
        return null;
      }

      // Get herd name
      const herdDoc = await firestore.collection('herds').doc(herdId).get();
      const herdName = herdDoc.data()?.name || 'a herd';

      // Send notification
      await admin.messaging().send({
        token: fcmToken,
        notification: {
          title: 'You received a strike',
          body: `You received a ${strikeData.severity} strike in ${herdName} for: ${strikeData.reason}`,
        },
        data: {
          type: 'strike',
          herdId: herdId,
          strikeId: strikeId,
        },
      });

      logger.info(`Strike notification sent to ${strikeData.userId}`);
      return null;
    } catch (error) {
      logger.error('Error sending strike notification:', error);
      throw error;
    }
  }
);

/**
 * Expire old strikes daily (scheduled function)
 */
exports.expireStrikes = require("firebase-functions/v2/scheduler")
  .onSchedule("every 24 hours", async () => {
    const now = admin.firestore.Timestamp.now();

    // Query all active strikes that have expired
    const expiredStrikes = await firestore
      .collectionGroup('strikes')
      .where('isActive', '==', true)
      .where('expiresAt', '<=', now)
      .get();

    const batch = firestore.batch();
    let count = 0;

    for (const doc of expiredStrikes.docs) {
      batch.update(doc.ref, { isActive: false });

      // Decrement user's strike count
      const strikeData = doc.data();
      const memberRef = firestore
        .collection('herds')
        .doc(strikeData.herdId)
        .collection('members')
        .doc(strikeData.userId);

      batch.update(memberRef, {
        activeStrikeCount: admin.firestore.FieldValue.increment(-1),
      });

      count++;
    }

    if (count > 0) {
      await batch.commit();
      logger.info(`Expired ${count} strikes`);
    }

    return null;
  });
```

---

## Firestore Indexes Required

Add to `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "strikes",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userId", "order": "ASCENDING" },
        { "fieldPath": "isActive", "order": "ASCENDING" },
        { "fieldPath": "issuedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "strikes",
      "queryScope": "COLLECTION_GROUP",
      "fields": [
        { "fieldPath": "isActive", "order": "ASCENDING" },
        { "fieldPath": "expiresAt", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "members",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "activeStrikeCount", "order": "DESCENDING" }
      ]
    }
  ]
}
```

---

## Integration Points

### Update Member Action Sheet

Add strike option to `lib/features/community/moderation/view/widgets/member_action_sheet_widget.dart`:

```dart
ListTile(
  leading: const Icon(Icons.warning_amber, color: Colors.orange),
  title: const Text('Issue Strike'),
  onTap: () {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (_) => IssueStrikeDialog(
        herdId: herdId,
        oderId: member.userId,
        username: member.displayUsername,
      ),
    );
  },
),
```

### Add Strike Count Badge to Member Tile

```dart
if (member.activeStrikeCount > 0)
  Badge(
    label: Text('${member.activeStrikeCount}'),
    backgroundColor: Colors.orange,
    child: const Icon(Icons.warning),
  ),
```

---

## Testing Checklist

- [ ] Moderator can issue strike to member
- [ ] Admin can issue strike to moderator
- [ ] Owner can issue strike to admin
- [ ] Cannot strike someone at same or higher level
- [ ] Strike counter increments correctly
- [ ] Strike notification is received
- [ ] Auto-suspend triggers at 3 strikes
- [ ] Auto-ban triggers at 5 strikes
- [ ] Expired strikes are automatically deactivated
- [ ] Strike can be manually removed
- [ ] Appeal flow works correctly

---

## Success Criteria

1. **Audit trail**: Every strike is logged in moderation log
2. **Scalable**: Uses counters instead of counting documents
3. **Configurable**: Thresholds can be adjusted per-herd
4. **Fair**: Appeals process exists
5. **Automated**: Escalation happens without manual intervention

---

## Estimated Effort

- **Development**: 6-8 hours
- **Testing**: 3-4 hours
- **Cloud Functions**: 2 hours
- **Total**: ~12-14 hours
