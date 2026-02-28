# Phase 3: Reporting Workflow

## Status: 🔲 Not Started

## Goal

Create a scalable, efficient reporting system that:
1. Allows users to report content (posts, comments, users)
2. Provides mods with a fast, low-read dashboard
3. Supports escalation and priority levels
4. Tracks report resolution and outcomes
5. Sends notifications to moderators

---

## Prerequisites

- [x] Phase 1 completed (Roles & Permissions)
- [x] Phase 2 completed (Strike System) - for issuing strikes from reports
- [ ] `HerdPermission.viewReports` and `HerdPermission.resolveReports` working

---

## Current State Analysis

### What Exists

```dart
// ReportModel (lib/features/community/moderation/data/models/report_model.dart)
- reportId, reportedBy, timestamp, targetId, targetType
- reason (enum), description, status, reviewedBy, reviewedAt, resolution
- metadata (includes herdId)

// ModerationRepository methods:
- reportContent() - creates report
- getPendingReports() - queries reports (INEFFICIENT - queries global collection)

// ModerationDashboardScreen - basic UI but incomplete
```

### Problems with Current Approach

1. **Reports stored in global `/reports/` collection** → Expensive to query per-herd
2. **No pagination** → Loads ALL pending reports
3. **No denormalization** → Must fetch post/user data separately
4. **No mod notifications** → Mods don't know when reports come in
5. **Incomplete actions** → `dismissReport()`, `escalateReport()` not implemented

---

## Architecture Decisions

### 1. Dual Storage Strategy

Store reports in TWO places (controlled denormalization):

```
# Global collection (for cross-herd admin views)
/reports/{reportId}
  - Full report data
  - Used by platform-wide admins

# Herd-specific queue (for mod dashboard - PRIMARY)
/herds/{herdId}/reportQueue/{reportId}
  - Denormalized report with embedded content preview
  - Optimized for dashboard loading
  - Deleted when resolved
```

### 2. Report Queue Document Structure

```typescript
// /herds/{herdId}/reportQueue/{reportId}
{
  reportId: string,
  
  // Report metadata
  reportedBy: string,
  reportedAt: Timestamp,
  reason: ReportReason,
  description: string?,
  priority: 'low' | 'medium' | 'high' | 'critical',
  
  // Target info (DENORMALIZED - no extra reads!)
  targetId: string,
  targetType: 'post' | 'comment' | 'user',
  targetPreview: {
    // For posts/comments:
    content: string (first 200 chars),
    authorId: string,
    authorUsername: string,
    createdAt: Timestamp,
    mediaCount: number,
    // For users:
    username: string,
    profileImageURL: string?,
    joinedAt: Timestamp,
  },
  
  // Aggregated report count
  reportCount: number,  // How many times this target was reported
  reporterIds: string[], // Who reported it (for deduplication)
  
  // Status
  status: 'pending' | 'reviewing' | 'escalated',
  assignedTo: string?,  // Mod currently reviewing
  assignedAt: Timestamp?,
}
```

### 3. Cost Analysis

| Operation | Old Approach | New Approach |
|-----------|--------------|--------------|
| Load dashboard (20 reports) | ~40+ reads | 1 read (paginated query) |
| Submit report | 1 write | 2 writes (queue + global) |
| Resolve report | 1 write | 3 writes (queue delete, global update, log) |
| Check if already reported | 1 read | 0 (included in queue doc) |

---

## Implementation Plan

### Step 1: Enhanced Report Model

**File**: `lib/features/community/moderation/data/models/report_model.dart` (UPDATE)

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_model.freezed.dart';

enum ReportTargetType { post, comment, user, message }

enum ReportReason {
  spam('Spam or self-promotion'),
  harassment('Harassment or bullying'),
  hateSpeech('Hate speech'),
  inappropriateContent('Inappropriate content'),
  misinformation('Misinformation'),
  violence('Violence or threats'),
  selfHarm('Self-harm or suicide'),
  minorSafety('Child safety concern'),
  illegalContent('Illegal content'),
  impersonation('Impersonation'),
  copyright('Copyright violation'),
  other('Other');

  final String displayName;
  const ReportReason(this.displayName);
  
  /// Get priority level for this reason type
  ReportPriority get defaultPriority {
    switch (this) {
      case ReportReason.minorSafety:
      case ReportReason.violence:
      case ReportReason.selfHarm:
      case ReportReason.illegalContent:
        return ReportPriority.critical;
      case ReportReason.harassment:
      case ReportReason.hateSpeech:
      case ReportReason.doxxing:
        return ReportPriority.high;
      case ReportReason.inappropriateContent:
      case ReportReason.impersonation:
        return ReportPriority.medium;
      default:
        return ReportPriority.low;
    }
  }
}

enum ReportPriority {
  low(0, 'Low', Duration(days: 7)),
  medium(1, 'Medium', Duration(days: 3)),
  high(2, 'High', Duration(hours: 24)),
  critical(3, 'Critical', Duration(hours: 1));

  final int level;
  final String displayName;
  final Duration targetResponseTime;
  const ReportPriority(this.level, this.displayName, this.targetResponseTime);
}

enum ReportStatus { pending, reviewing, escalated, resolved, dismissed }

enum ReportResolution {
  noViolation('No violation found'),
  warned('User warned'),
  contentRemoved('Content removed'),
  userSuspended('User suspended'),
  userBanned('User banned'),
  escalatedToAdmin('Escalated to admin'),
  escalatedToLegal('Escalated to legal'),
  duplicate('Duplicate report');

  final String displayName;
  const ReportResolution(this.displayName);
}

@freezed
abstract class ReportModel with _$ReportModel {
  const ReportModel._();

  const factory ReportModel({
    required String reportId,
    required String reportedBy,
    required DateTime timestamp,
    required String targetId,
    required ReportTargetType targetType,
    required ReportReason reason,
    String? description,
    @Default(ReportStatus.pending) ReportStatus status,
    @Default(ReportPriority.medium) ReportPriority priority,
    String? reviewedBy,
    DateTime? reviewedAt,
    ReportResolution? resolution,
    String? resolutionNotes,
    Map<String, dynamic>? metadata,
    // Denormalized target preview
    Map<String, dynamic>? targetPreview,
    // Aggregation
    @Default(1) int reportCount,
    @Default([]) List<String> reporterIds,
  }) = _ReportModel;

  factory ReportModel.fromMap(Map<String, dynamic> map) {
    return ReportModel(
      reportId: map['reportId'] ?? '',
      reportedBy: map['reportedBy'] ?? '',
      timestamp: _parseDateTime(map['timestamp']) ?? DateTime.now(),
      targetId: map['targetId'] ?? '',
      targetType: ReportTargetType.values.firstWhere(
        (e) => e.name == map['targetType'],
        orElse: () => ReportTargetType.post,
      ),
      reason: ReportReason.values.firstWhere(
        (e) => e.name == map['reason'],
        orElse: () => ReportReason.other,
      ),
      description: map['description'],
      status: ReportStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => ReportStatus.pending,
      ),
      priority: ReportPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => ReportPriority.medium,
      ),
      reviewedBy: map['reviewedBy'],
      reviewedAt: _parseDateTime(map['reviewedAt']),
      resolution: map['resolution'] != null
          ? ReportResolution.values.firstWhere(
              (e) => e.name == map['resolution'],
              orElse: () => ReportResolution.noViolation,
            )
          : null,
      resolutionNotes: map['resolutionNotes'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
      targetPreview: map['targetPreview'] != null
          ? Map<String, dynamic>.from(map['targetPreview'])
          : null,
      reportCount: map['reportCount'] ?? 1,
      reporterIds: List<String>.from(map['reporterIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'reportId': reportId,
      'reportedBy': reportedBy,
      'timestamp': Timestamp.fromDate(timestamp),
      'targetId': targetId,
      'targetType': targetType.name,
      'reason': reason.name,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt != null ? Timestamp.fromDate(reviewedAt!) : null,
      'resolution': resolution?.name,
      'resolutionNotes': resolutionNotes,
      'metadata': metadata,
      'targetPreview': targetPreview,
      'reportCount': reportCount,
      'reporterIds': reporterIds,
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Check if this report is overdue based on priority
  bool get isOverdue {
    final deadline = timestamp.add(priority.targetResponseTime);
    return DateTime.now().isAfter(deadline) && 
           status != ReportStatus.resolved && 
           status != ReportStatus.dismissed;
  }
}
```

### Step 2: Report Repository (New)

**File**: `lib/features/community/moderation/data/repositories/report_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';
import '../models/moderation_action_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository(this._firestore);

  /// Submit a report for content
  /// Returns the report ID
  Future<String> submitReport({
    required String reportedBy,
    required String targetId,
    required ReportTargetType targetType,
    required ReportReason reason,
    required String herdId,
    String? description,
  }) async {
    // Check if this target already has a pending report in queue
    final existingReport = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('reportQueue')
        .where('targetId', isEqualTo: targetId)
        .where('status', whereIn: ['pending', 'reviewing'])
        .limit(1)
        .get();

    if (existingReport.docs.isNotEmpty) {
      // Add to existing report (aggregate)
      final existingDoc = existingReport.docs.first;
      final existingData = existingDoc.data();

      // Check if user already reported this
      final reporterIds = List<String>.from(existingData['reporterIds'] ?? []);
      if (reporterIds.contains(reportedBy)) {
        throw Exception('You have already reported this content');
      }

      await existingDoc.reference.update({
        'reportCount': FieldValue.increment(1),
        'reporterIds': FieldValue.arrayUnion([reportedBy]),
        // Upgrade priority if new report is more severe
        if (reason.defaultPriority.level > 
            ReportPriority.values.firstWhere(
              (p) => p.name == existingData['priority'],
              orElse: () => ReportPriority.low,
            ).level)
          'priority': reason.defaultPriority.name,
      });

      return existingDoc.id;
    }

    // Create new report
    final reportId = _firestore.collection('dummy').doc().id;
    final now = DateTime.now();

    // Fetch target preview data
    final targetPreview = await _fetchTargetPreview(targetId, targetType, herdId);

    final report = ReportModel(
      reportId: reportId,
      reportedBy: reportedBy,
      timestamp: now,
      targetId: targetId,
      targetType: targetType,
      reason: reason,
      description: description,
      priority: reason.defaultPriority,
      metadata: {'herdId': herdId},
      targetPreview: targetPreview,
      reporterIds: [reportedBy],
    );

    final batch = _firestore.batch();

    // 1. Add to herd's report queue
    batch.set(
      _firestore
          .collection('herds')
          .doc(herdId)
          .collection('reportQueue')
          .doc(reportId),
      report.toMap(),
    );

    // 2. Add to global reports collection
    batch.set(
      _firestore.collection('reports').doc(reportId),
      report.toMap(),
    );

    // 3. Update herd's pending report counter
    batch.update(
      _firestore.collection('herds').doc(herdId),
      {
        'pendingReportCount': FieldValue.increment(1),
      },
    );

    await batch.commit();
    return reportId;
  }

  /// Fetch preview data for the reported content
  Future<Map<String, dynamic>> _fetchTargetPreview(
    String targetId,
    ReportTargetType targetType,
    String herdId,
  ) async {
    switch (targetType) {
      case ReportTargetType.post:
        final postDoc = await _firestore
            .collection('herdPosts')
            .doc(herdId)
            .collection('posts')
            .doc(targetId)
            .get();
        if (!postDoc.exists) return {};
        final data = postDoc.data()!;
        return {
          'content': _truncate(data['content'] ?? '', 200),
          'authorId': data['authorId'],
          'authorUsername': data['authorUsername'],
          'createdAt': data['createdAt'],
          'mediaCount': (data['mediaItems'] as List?)?.length ?? 0,
        };

      case ReportTargetType.comment:
        // Similar logic for comments
        return {};

      case ReportTargetType.user:
        final userDoc = await _firestore
            .collection('users')
            .doc(targetId)
            .get();
        if (!userDoc.exists) return {};
        final data = userDoc.data()!;
        return {
          'username': data['username'],
          'profileImageURL': data['profileImageURL'],
          'joinedAt': data['createdAt'],
        };

      default:
        return {};
    }
  }

  String _truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Get report queue for a herd (paginated)
  Future<List<ReportModel>> getReportQueue(
    String herdId, {
    ReportStatus? status,
    ReportPriority? minPriority,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _firestore
        .collection('herds')
        .doc(herdId)
        .collection('reportQueue')
        .orderBy('priority', descending: true)
        .orderBy('timestamp', descending: false) // Oldest first within priority
        .limit(limit);

    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (minPriority != null) {
      query = query.where('priority', whereIn: 
        ReportPriority.values
            .where((p) => p.level >= minPriority.level)
            .map((p) => p.name)
            .toList(),
      );
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => ReportModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  /// Stream report queue for real-time updates
  Stream<List<ReportModel>> streamReportQueue(
    String herdId, {
    int limit = 20,
  }) {
    return _firestore
        .collection('herds')
        .doc(herdId)
        .collection('reportQueue')
        .orderBy('priority', descending: true)
        .orderBy('timestamp')
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReportModel.fromMap(doc.data()))
            .toList());
  }

  /// Claim a report (assign to current moderator)
  Future<void> claimReport(
    String herdId,
    String reportId,
    String moderatorId,
  ) async {
    await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('reportQueue')
        .doc(reportId)
        .update({
      'status': ReportStatus.reviewing.name,
      'assignedTo': moderatorId,
      'assignedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Resolve a report
  Future<void> resolveReport({
    required String herdId,
    required String reportId,
    required String resolvedBy,
    required ReportResolution resolution,
    String? notes,
  }) async {
    final batch = _firestore.batch();
    final now = DateTime.now();

    // 1. Update global report
    batch.update(
      _firestore.collection('reports').doc(reportId),
      {
        'status': ReportStatus.resolved.name,
        'reviewedBy': resolvedBy,
        'reviewedAt': Timestamp.fromDate(now),
        'resolution': resolution.name,
        'resolutionNotes': notes,
      },
    );

    // 2. Remove from queue
    batch.delete(
      _firestore
          .collection('herds')
          .doc(herdId)
          .collection('reportQueue')
          .doc(reportId),
    );

    // 3. Decrement pending counter
    batch.update(
      _firestore.collection('herds').doc(herdId),
      {
        'pendingReportCount': FieldValue.increment(-1),
      },
    );

    // 4. Log moderation action
    final actionId = _firestore.collection('dummy').doc().id;
    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: resolvedBy,
        timestamp: now,
        actionType: ModActionType.reviewReport,
        targetId: reportId,
        targetType: ModTargetType.report,
        reason: 'Resolution: ${resolution.displayName}',
        notes: notes,
        metadata: {'herdId': herdId},
      ).toMap(),
    );

    await batch.commit();
  }

  /// Dismiss a report (no action needed)
  Future<void> dismissReport({
    required String herdId,
    required String reportId,
    required String dismissedBy,
    String? reason,
  }) async {
    await resolveReport(
      herdId: herdId,
      reportId: reportId,
      resolvedBy: dismissedBy,
      resolution: ReportResolution.noViolation,
      notes: reason ?? 'Report dismissed - no violation found',
    );
  }

  /// Escalate a report to higher authority
  Future<void> escalateReport({
    required String herdId,
    required String reportId,
    required String escalatedBy,
    required ReportResolution escalationType, // escalatedToAdmin or escalatedToLegal
    String? notes,
  }) async {
    final batch = _firestore.batch();

    // Update queue entry
    batch.update(
      _firestore
          .collection('herds')
          .doc(herdId)
          .collection('reportQueue')
          .doc(reportId),
      {
        'status': ReportStatus.escalated.name,
        'priority': ReportPriority.critical.name, // Always critical when escalated
      },
    );

    // Update global report
    batch.update(
      _firestore.collection('reports').doc(reportId),
      {
        'status': ReportStatus.escalated.name,
        'priority': ReportPriority.critical.name,
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
      ModerationAction(
        actionId: actionId,
        performedBy: escalatedBy,
        timestamp: DateTime.now(),
        actionType: ModActionType.escalateReport,
        targetId: reportId,
        targetType: ModTargetType.report,
        reason: escalationType.displayName,
        notes: notes,
        metadata: {'herdId': herdId},
      ).toMap(),
    );

    await batch.commit();

    // Notify admins/owners (async)
    _notifyEscalation(herdId, reportId, escalationType);
  }

  Future<void> _notifyEscalation(
    String herdId,
    String reportId,
    ReportResolution escalationType,
  ) async {
    // Get all admins/owners in the herd
    final membersSnapshot = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .where('role', whereIn: ['admin', 'owner'])
        .get();

    for (final memberDoc in membersSnapshot.docs) {
      final userId = memberDoc.id;
      // Create notification
      await _firestore.collection('notifications').add({
        'userId': userId,
        'type': 'escalatedReport',
        'title': 'Report Escalated',
        'body': 'A report has been escalated and requires your attention',
        'data': {
          'herdId': herdId,
          'reportId': reportId,
          'escalationType': escalationType.name,
        },
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
```

### Step 3: Report Providers

**File**: `lib/features/community/moderation/view/providers/report_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/report_repository.dart';
import '../../data/models/report_model.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

part 'report_providers.g.dart';

@riverpod
ReportRepository reportRepository(Ref ref) {
  return ReportRepository(FirebaseFirestore.instance);
}

/// Stream the report queue for a herd
@riverpod
Stream<List<ReportModel>> reportQueue(Ref ref, String herdId) {
  final repo = ref.watch(reportRepositoryProvider);
  return repo.streamReportQueue(herdId);
}

/// Get pending report count (from herd document - cached)
@riverpod
Stream<int> pendingReportCount(Ref ref, String herdId) {
  return FirebaseFirestore.instance
      .collection('herds')
      .doc(herdId)
      .snapshots()
      .map((doc) => doc.data()?['pendingReportCount'] ?? 0);
}

/// Controller for report actions
@riverpod
class ReportController extends _$ReportController {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> submitReport({
    required String targetId,
    required ReportTargetType targetType,
    required ReportReason reason,
    required String herdId,
    String? description,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(reportRepositoryProvider);
      await repo.submitReport(
        reportedBy: user.uid,
        targetId: targetId,
        targetType: targetType,
        reason: reason,
        herdId: herdId,
        description: description,
      );

      ref.invalidate(reportQueueProvider(herdId));
      ref.invalidate(pendingReportCountProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> resolveReport({
    required String herdId,
    required String reportId,
    required ReportResolution resolution,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(reportRepositoryProvider);
      await repo.resolveReport(
        herdId: herdId,
        reportId: reportId,
        resolvedBy: user.uid,
        resolution: resolution,
        notes: notes,
      );

      ref.invalidate(reportQueueProvider(herdId));
      ref.invalidate(pendingReportCountProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> escalateReport({
    required String herdId,
    required String reportId,
    required ReportResolution escalationType,
    String? notes,
  }) async {
    state = const AsyncValue.loading();

    final user = ref.read(authProvider);
    if (user == null) {
      state = AsyncValue.error('Not authenticated', StackTrace.current);
      return;
    }

    try {
      final repo = ref.read(reportRepositoryProvider);
      await repo.escalateReport(
        herdId: herdId,
        reportId: reportId,
        escalatedBy: user.uid,
        escalationType: escalationType,
        notes: notes,
      );

      ref.invalidate(reportQueueProvider(herdId));

      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### Step 4: Updated Moderation Dashboard

**File**: `lib/features/community/moderation/view/screens/report_dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/report_model.dart';
import '../providers/report_providers.dart';
import '../widgets/report_card_widget.dart';

class ReportDashboardScreen extends ConsumerWidget {
  final String herdId;

  const ReportDashboardScreen({super.key, required this.herdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportQueueAsync = ref.watch(reportQueueProvider(herdId));
    final pendingCount = ref.watch(pendingReportCountProvider(herdId));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Reports'),
            const SizedBox(width: 8),
            pendingCount.when(
              data: (count) => count > 0
                  ? Badge(
                      label: Text('$count'),
                      backgroundColor: Colors.red,
                    )
                  : const SizedBox(),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: reportQueueAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No pending reports', style: TextStyle(fontSize: 18)),
                  Text('Great job keeping the community safe!'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return ReportCard(
                report: report,
                herdId: herdId,
                onResolve: () => _showResolveDialog(context, ref, report),
                onEscalate: () => _showEscalateDialog(context, ref, report),
              );
            },
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Filter bottom sheet implementation
  }

  void _showResolveDialog(BuildContext context, WidgetRef ref, ReportModel report) {
    showDialog(
      context: context,
      builder: (_) => ResolveReportDialog(
        herdId: herdId,
        report: report,
      ),
    );
  }

  void _showEscalateDialog(BuildContext context, WidgetRef ref, ReportModel report) {
    showDialog(
      context: context,
      builder: (_) => EscalateReportDialog(
        herdId: herdId,
        report: report,
      ),
    );
  }
}
```

### Step 5: Cloud Function for Report Notifications

**File**: `functions/report_handlers.js`

```javascript
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { logger } = require("firebase-functions");
const { admin, firestore } = require('./admin_init');

/**
 * Notify moderators when a new report is submitted
 */
exports.onReportCreated = onDocumentCreated(
  "herds/{herdId}/reportQueue/{reportId}",
  async (event) => {
    const report = event.data.data();
    const { herdId } = event.params;

    try {
      // Only notify for high/critical priority
      if (!['high', 'critical'].includes(report.priority)) {
        return null;
      }

      // Get all moderators and admins
      const membersSnapshot = await firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .where('role', 'in', ['moderator', 'admin', 'owner'])
        .get();

      const herdDoc = await firestore.collection('herds').doc(herdId).get();
      const herdName = herdDoc.data()?.name || 'your herd';

      const notifications = [];

      for (const memberDoc of membersSnapshot.docs) {
        const userId = memberDoc.id;
        
        // Skip the reporter
        if (userId === report.reportedBy) continue;

        // Get FCM token
        const userDoc = await firestore.collection('users').doc(userId).get();
        const fcmToken = userDoc.data()?.fcmToken;

        if (fcmToken) {
          notifications.push(
            admin.messaging().send({
              token: fcmToken,
              notification: {
                title: `${report.priority.toUpperCase()} Priority Report`,
                body: `New ${report.reason} report in ${herdName}`,
              },
              data: {
                type: 'newReport',
                herdId: herdId,
                reportId: report.reportId,
                priority: report.priority,
              },
              android: {
                priority: report.priority === 'critical' ? 'high' : 'normal',
              },
            })
          );
        }
      }

      await Promise.all(notifications);
      logger.info(`Sent ${notifications.length} report notifications for herd ${herdId}`);
      
      return null;
    } catch (error) {
      logger.error('Error sending report notifications:', error);
      throw error;
    }
  }
);
```

---

## Firestore Indexes

Add to `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "reportQueue",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "priority", "order": "DESCENDING" },
        { "fieldPath": "timestamp", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "reportQueue",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "targetId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" }
      ]
    }
  ]
}
```

---

## Testing Checklist

- [ ] User can report a post
- [ ] User can report a comment
- [ ] User can report a user
- [ ] Duplicate report aggregates (doesn't create new entry)
- [ ] Priority auto-sets based on reason
- [ ] Critical reports notify mods immediately
- [ ] Dashboard loads in < 1 second
- [ ] Dashboard shows correct priority ordering
- [ ] Report can be resolved with outcome
- [ ] Report can be escalated
- [ ] Escalation notifies admins/owners
- [ ] Resolved reports removed from queue

---

## Success Criteria

1. **Dashboard loads with 1 Firestore read** (paginated query)
2. **No additional reads needed** for report preview (denormalized)
3. **Report count accurate** via counter field
4. **Priority-based ordering** (critical first, then by age)
5. **Escalation workflow** complete with notifications

---

## Estimated Effort

- **Development**: 8-10 hours
- **Testing**: 3-4 hours
- **Cloud Functions**: 2 hours
- **Total**: ~14-16 hours
