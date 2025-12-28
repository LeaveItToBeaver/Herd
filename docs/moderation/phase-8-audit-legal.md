# Phase 8: Audit Logging & Legal Compliance

## Status: 🔲 Not Started

## Goal

Implement a comprehensive audit system that:
1. Logs ALL moderation actions with full context
2. Captures device fingerprints and IP addresses
3. Preserves evidence for legal requests
4. Supports data export for law enforcement
5. Maintains chain of custody for removed content

---

## Prerequisites

- [x] All previous phases completed
- [ ] Legal review of data retention requirements
- [ ] Privacy policy updated for data collection

---

## Legal Context

This phase addresses:
- **Evidence preservation** for potential legal proceedings
- **User data requests** (GDPR, CCPA compliance)
- **Law enforcement requests** for user data
- **Content takedown documentation**
- **Moderator accountability**

---

## Architecture Decisions

### 1. Audit Log Structure

**Decision**: Immutable, append-only collection with comprehensive metadata.

```typescript
// /auditLogs/{herdId}/entries/{entryId}
{
  entryId: string,
  timestamp: Timestamp,
  
  // Actor information
  actor: {
    userId: string,
    username: string,
    role: 'member' | 'moderator' | 'admin' | 'owner' | 'system',
    ipAddress: string?,           // Hashed or partial
    userAgent: string?,
    deviceFingerprint: string?,   // Hashed
    sessionId: string?,
  },
  
  // Action details
  action: {
    type: 'moderation' | 'content' | 'user' | 'settings' | 'access',
    subtype: string,              // e.g., 'removePost', 'banUser'
    description: string,
  },
  
  // Target information
  target: {
    type: 'user' | 'post' | 'comment' | 'herd' | 'setting',
    id: string,
    snapshot: object?,            // State at time of action
  },
  
  // Evidence preservation
  evidence: {
    contentSnapshot: string?,     // Original content if removed
    mediaUrls: string[]?,         // Preserved media URLs
    relatedReports: string[]?,    // Report IDs that triggered action
  },
  
  // Metadata
  metadata: {
    herdId: string,
    reason: string?,
    automated: boolean,
    reversible: boolean,
    reversed: boolean,
    reversedBy: string?,
    reversedAt: Timestamp?,
  },
}
```

### 2. Device Fingerprint Collection

**Decision**: Collect sufficient data for accountability without excessive privacy invasion.

```typescript
// Fingerprint data (stored hashed)
{
  // Browser fingerprint components
  screenResolution: string,
  timezone: string,
  language: string,
  platform: string,
  
  // Mobile-specific
  deviceModel: string?,      // e.g., "Pixel 7"
  osVersion: string?,
  appVersion: string,
  
  // Computed hash for matching
  fingerprintHash: string,
}
```

### 3. IP Address Handling

**Options**:
- A) Store full IP → Maximum evidence, privacy concerns
- B) Store partial IP (first 3 octets) → Partial evidence, better privacy
- C) Store hashed IP → Can match but not reverse
- D) Store nothing → No evidence

**Decision**: Option B for general logging, Option A for serious violations (stored encrypted).

### 4. Data Retention

| Data Type | Retention Period |
|-----------|------------------|
| General audit logs | 1 year |
| Content removal logs | 3 years |
| User ban logs | 5 years |
| Legal hold items | Indefinite |

---

## Implementation Plan

### Step 1: Device Info Service

**File**: `lib/features/analytics/data/services/device_info_service.dart`

```dart
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get device fingerprint data
  Future<DeviceFingerprint> getFingerprint() async {
    if (kIsWeb) {
      return _getWebFingerprint();
    } else if (defaultTargetPlatform == TargetPlatform.android) {
      return _getAndroidFingerprint();
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return _getIosFingerprint();
    }
    return DeviceFingerprint.unknown();
  }

  Future<DeviceFingerprint> _getWebFingerprint() async {
    final webInfo = await _deviceInfo.webBrowserInfo;
    
    return DeviceFingerprint(
      platform: 'web',
      browserName: webInfo.browserName.name,
      userAgent: webInfo.userAgent,
      language: webInfo.language,
      vendor: webInfo.vendor,
      hardwareConcurrency: webInfo.hardwareConcurrency?.toString(),
    );
  }

  Future<DeviceFingerprint> _getAndroidFingerprint() async {
    final androidInfo = await _deviceInfo.androidInfo;
    
    return DeviceFingerprint(
      platform: 'android',
      deviceModel: androidInfo.model,
      manufacturer: androidInfo.manufacturer,
      osVersion: 'Android ${androidInfo.version.release}',
      sdkInt: androidInfo.version.sdkInt.toString(),
      fingerprint: androidInfo.fingerprint,
    );
  }

  Future<DeviceFingerprint> _getIosFingerprint() async {
    final iosInfo = await _deviceInfo.iosInfo;
    
    return DeviceFingerprint(
      platform: 'ios',
      deviceModel: iosInfo.model,
      osVersion: 'iOS ${iosInfo.systemVersion}',
      name: iosInfo.name,
      identifierForVendor: iosInfo.identifierForVendor,
    );
  }
}

class DeviceFingerprint {
  final String platform;
  final String? deviceModel;
  final String? manufacturer;
  final String? osVersion;
  final String? browserName;
  final String? userAgent;
  final String? language;
  final String? vendor;
  final String? hardwareConcurrency;
  final String? sdkInt;
  final String? fingerprint;
  final String? name;
  final String? identifierForVendor;

  DeviceFingerprint({
    required this.platform,
    this.deviceModel,
    this.manufacturer,
    this.osVersion,
    this.browserName,
    this.userAgent,
    this.language,
    this.vendor,
    this.hardwareConcurrency,
    this.sdkInt,
    this.fingerprint,
    this.name,
    this.identifierForVendor,
  });

  factory DeviceFingerprint.unknown() {
    return DeviceFingerprint(platform: 'unknown');
  }

  /// Generate a hash for matching without exposing details
  String get hash {
    final components = [
      platform,
      deviceModel,
      manufacturer,
      osVersion,
      browserName,
      userAgent,
      language,
    ].where((e) => e != null).join('|');
    
    return sha256.convert(utf8.encode(components)).toString().substring(0, 32);
  }

  Map<String, dynamic> toMap() {
    return {
      'platform': platform,
      'deviceModel': deviceModel,
      'manufacturer': manufacturer,
      'osVersion': osVersion,
      'browserName': browserName,
      'language': language,
      'fingerprintHash': hash,
    };
  }

  /// Sanitized version for general logging (no PII)
  Map<String, dynamic> toSanitizedMap() {
    return {
      'platform': platform,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'fingerprintHash': hash,
    };
  }
}
```

### Step 2: Audit Log Model

**File**: `lib/features/community/moderation/data/models/audit_log_entry.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_entry.freezed.dart';

enum AuditActionCategory {
  moderation,
  content,
  user,
  settings,
  access,
}

enum AuditTargetType {
  user,
  post,
  comment,
  herd,
  setting,
  report,
}

@freezed
abstract class AuditLogEntry with _$AuditLogEntry {
  const AuditLogEntry._();

  const factory AuditLogEntry({
    required String entryId,
    required DateTime timestamp,
    required AuditActor actor,
    required AuditAction action,
    required AuditTarget target,
    AuditEvidence? evidence,
    required AuditMetadata metadata,
  }) = _AuditLogEntry;

  factory AuditLogEntry.fromMap(Map<String, dynamic> map) {
    return AuditLogEntry(
      entryId: map['entryId'],
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      actor: AuditActor.fromMap(map['actor']),
      action: AuditAction.fromMap(map['action']),
      target: AuditTarget.fromMap(map['target']),
      evidence: map['evidence'] != null 
          ? AuditEvidence.fromMap(map['evidence']) 
          : null,
      metadata: AuditMetadata.fromMap(map['metadata']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'entryId': entryId,
      'timestamp': Timestamp.fromDate(timestamp),
      'actor': actor.toMap(),
      'action': action.toMap(),
      'target': target.toMap(),
      'evidence': evidence?.toMap(),
      'metadata': metadata.toMap(),
    };
  }
}

@freezed
abstract class AuditActor with _$AuditActor {
  const AuditActor._();

  const factory AuditActor({
    required String userId,
    String? username,
    required String role,
    String? ipAddress,
    String? userAgent,
    String? deviceFingerprint,
    String? sessionId,
  }) = _AuditActor;

  factory AuditActor.fromMap(Map<String, dynamic> map) {
    return AuditActor(
      userId: map['userId'],
      username: map['username'],
      role: map['role'],
      ipAddress: map['ipAddress'],
      userAgent: map['userAgent'],
      deviceFingerprint: map['deviceFingerprint'],
      sessionId: map['sessionId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'username': username,
      'role': role,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'deviceFingerprint': deviceFingerprint,
      'sessionId': sessionId,
    };
  }
}

@freezed
abstract class AuditAction with _$AuditAction {
  const AuditAction._();

  const factory AuditAction({
    required AuditActionCategory category,
    required String subtype,
    required String description,
  }) = _AuditAction;

  factory AuditAction.fromMap(Map<String, dynamic> map) {
    return AuditAction(
      category: AuditActionCategory.values.firstWhere(
        (e) => e.name == map['category'],
        orElse: () => AuditActionCategory.content,
      ),
      subtype: map['subtype'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'category': category.name,
      'subtype': subtype,
      'description': description,
    };
  }
}

@freezed
abstract class AuditTarget with _$AuditTarget {
  const AuditTarget._();

  const factory AuditTarget({
    required AuditTargetType type,
    required String id,
    Map<String, dynamic>? snapshot,
  }) = _AuditTarget;

  factory AuditTarget.fromMap(Map<String, dynamic> map) {
    return AuditTarget(
      type: AuditTargetType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => AuditTargetType.post,
      ),
      id: map['id'],
      snapshot: map['snapshot'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type.name,
      'id': id,
      'snapshot': snapshot,
    };
  }
}

@freezed
abstract class AuditEvidence with _$AuditEvidence {
  const AuditEvidence._();

  const factory AuditEvidence({
    String? contentSnapshot,
    List<String>? mediaUrls,
    List<String>? relatedReports,
  }) = _AuditEvidence;

  factory AuditEvidence.fromMap(Map<String, dynamic> map) {
    return AuditEvidence(
      contentSnapshot: map['contentSnapshot'],
      mediaUrls: (map['mediaUrls'] as List?)?.cast<String>(),
      relatedReports: (map['relatedReports'] as List?)?.cast<String>(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contentSnapshot': contentSnapshot,
      'mediaUrls': mediaUrls,
      'relatedReports': relatedReports,
    };
  }
}

@freezed
abstract class AuditMetadata with _$AuditMetadata {
  const AuditMetadata._();

  const factory AuditMetadata({
    required String herdId,
    String? reason,
    @Default(false) bool automated,
    @Default(true) bool reversible,
    @Default(false) bool reversed,
    String? reversedBy,
    DateTime? reversedAt,
    @Default(false) bool legalHold,
  }) = _AuditMetadata;

  factory AuditMetadata.fromMap(Map<String, dynamic> map) {
    return AuditMetadata(
      herdId: map['herdId'],
      reason: map['reason'],
      automated: map['automated'] ?? false,
      reversible: map['reversible'] ?? true,
      reversed: map['reversed'] ?? false,
      reversedBy: map['reversedBy'],
      reversedAt: (map['reversedAt'] as Timestamp?)?.toDate(),
      legalHold: map['legalHold'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'herdId': herdId,
      'reason': reason,
      'automated': automated,
      'reversible': reversible,
      'reversed': reversed,
      'reversedBy': reversedBy,
      'reversedAt': reversedAt != null ? Timestamp.fromDate(reversedAt!) : null,
      'legalHold': legalHold,
    };
  }
}
```

### Step 3: Audit Repository

**File**: `lib/features/community/moderation/data/repositories/audit_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_entry.dart';

class AuditRepository {
  final FirebaseFirestore _firestore;

  AuditRepository(this._firestore);

  /// Log an audit entry
  Future<String> logEntry(AuditLogEntry entry) async {
    final docRef = _firestore
        .collection('auditLogs')
        .doc(entry.metadata.herdId)
        .collection('entries')
        .doc(entry.entryId);

    await docRef.set(entry.toMap());
    return entry.entryId;
  }

  /// Create audit entry from components
  Future<String> createAuditLog({
    required String herdId,
    required AuditActor actor,
    required AuditActionCategory category,
    required String actionSubtype,
    required String description,
    required AuditTargetType targetType,
    required String targetId,
    Map<String, dynamic>? targetSnapshot,
    AuditEvidence? evidence,
    String? reason,
    bool automated = false,
    bool reversible = true,
  }) async {
    final entryId = _firestore.collection('dummy').doc().id;
    
    final entry = AuditLogEntry(
      entryId: entryId,
      timestamp: DateTime.now(),
      actor: actor,
      action: AuditAction(
        category: category,
        subtype: actionSubtype,
        description: description,
      ),
      target: AuditTarget(
        type: targetType,
        id: targetId,
        snapshot: targetSnapshot,
      ),
      evidence: evidence,
      metadata: AuditMetadata(
        herdId: herdId,
        reason: reason,
        automated: automated,
        reversible: reversible,
      ),
    );

    return logEntry(entry);
  }

  /// Query audit logs with filters
  Future<List<AuditLogEntry>> queryLogs({
    required String herdId,
    AuditActionCategory? category,
    String? actorId,
    String? targetId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection('auditLogs')
        .doc(herdId)
        .collection('entries')
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (category != null) {
      query = query.where('action.category', isEqualTo: category.name);
    }

    if (actorId != null) {
      query = query.where('actor.userId', isEqualTo: actorId);
    }

    if (targetId != null) {
      query = query.where('target.id', isEqualTo: targetId);
    }

    if (startDate != null) {
      query = query.where(
        'timestamp',
        isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
      );
    }

    if (endDate != null) {
      query = query.where(
        'timestamp',
        isLessThanOrEqualTo: Timestamp.fromDate(endDate),
      );
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs
        .map((doc) => AuditLogEntry.fromMap(doc.data()))
        .toList();
  }

  /// Get audit trail for a specific target
  Future<List<AuditLogEntry>> getTargetAuditTrail(
    String herdId,
    String targetId,
  ) async {
    final snapshot = await _firestore
        .collection('auditLogs')
        .doc(herdId)
        .collection('entries')
        .where('target.id', isEqualTo: targetId)
        .orderBy('timestamp', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => AuditLogEntry.fromMap(doc.data()))
        .toList();
  }

  /// Set legal hold on an entry
  Future<void> setLegalHold(
    String herdId,
    String entryId,
    bool hold,
  ) async {
    await _firestore
        .collection('auditLogs')
        .doc(herdId)
        .collection('entries')
        .doc(entryId)
        .update({'metadata.legalHold': hold});
  }

  /// Export audit logs for a date range (for legal requests)
  Future<Map<String, dynamic>> exportLogs({
    required String herdId,
    required DateTime startDate,
    required DateTime endDate,
    String? targetUserId,
    bool includeEvidence = true,
  }) async {
    var query = _firestore
        .collection('auditLogs')
        .doc(herdId)
        .collection('entries')
        .where(
          'timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        )
        .where(
          'timestamp',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        )
        .orderBy('timestamp');

    if (targetUserId != null) {
      // Need to query both actor and target
      // This requires compound index or separate queries
    }

    final snapshot = await query.get();
    
    final entries = snapshot.docs.map((doc) {
      final data = doc.data();
      if (!includeEvidence) {
        data.remove('evidence');
      }
      return data;
    }).toList();

    return {
      'exportedAt': DateTime.now().toIso8601String(),
      'herdId': herdId,
      'dateRange': {
        'start': startDate.toIso8601String(),
        'end': endDate.toIso8601String(),
      },
      'entryCount': entries.length,
      'entries': entries,
    };
  }
}
```

### Step 4: Audit Service (Facade)

**File**: `lib/features/community/moderation/data/services/audit_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/audit_log_entry.dart';
import '../repositories/audit_repository.dart';
import '../../../../analytics/data/services/device_info_service.dart';

/// High-level service for audit logging with automatic context capture
class AuditService {
  final AuditRepository _repository;
  final DeviceInfoService _deviceInfo;
  
  AuditService(this._repository, this._deviceInfo);

  /// Log a moderation action with full context
  Future<String> logModerationAction({
    required String herdId,
    required String actorUserId,
    required String actorUsername,
    required String actorRole,
    required String actionType,
    required String targetId,
    required AuditTargetType targetType,
    String? reason,
    Map<String, dynamic>? targetSnapshot,
    String? contentSnapshot,
    List<String>? mediaUrls,
    List<String>? relatedReports,
  }) async {
    // Capture device info
    final fingerprint = await _deviceInfo.getFingerprint();

    final actor = AuditActor(
      userId: actorUserId,
      username: actorUsername,
      role: actorRole,
      deviceFingerprint: fingerprint.hash,
      userAgent: fingerprint.userAgent,
    );

    final evidence = (contentSnapshot != null || 
                      mediaUrls != null || 
                      relatedReports != null)
        ? AuditEvidence(
            contentSnapshot: contentSnapshot,
            mediaUrls: mediaUrls,
            relatedReports: relatedReports,
          )
        : null;

    return _repository.createAuditLog(
      herdId: herdId,
      actor: actor,
      category: AuditActionCategory.moderation,
      actionSubtype: actionType,
      description: _getActionDescription(actionType, targetType),
      targetType: targetType,
      targetId: targetId,
      targetSnapshot: targetSnapshot,
      evidence: evidence,
      reason: reason,
    );
  }

  /// Log a user action (for accountability)
  Future<String> logUserAction({
    required String herdId,
    required String userId,
    required String username,
    required String actionType,
    required String targetId,
    required AuditTargetType targetType,
    String? description,
  }) async {
    final fingerprint = await _deviceInfo.getFingerprint();

    final actor = AuditActor(
      userId: userId,
      username: username,
      role: 'member',
      deviceFingerprint: fingerprint.hash,
    );

    return _repository.createAuditLog(
      herdId: herdId,
      actor: actor,
      category: AuditActionCategory.user,
      actionSubtype: actionType,
      description: description ?? _getActionDescription(actionType, targetType),
      targetType: targetType,
      targetId: targetId,
    );
  }

  String _getActionDescription(String actionType, AuditTargetType targetType) {
    final descriptions = {
      'removePost': 'Removed a post from the community',
      'restorePost': 'Restored a previously removed post',
      'removeComment': 'Removed a comment',
      'restoreComment': 'Restored a previously removed comment',
      'banUser': 'Banned a user from the community',
      'unbanUser': 'Unbanned a user',
      'suspendUser': 'Temporarily suspended a user',
      'restrictUser': 'Applied restrictions to a user',
      'unrestrictUser': 'Removed restrictions from a user',
      'lockPost': 'Locked a post from new comments',
      'unlockPost': 'Unlocked a post for comments',
      'warnUser': 'Issued a warning to a user',
      'resolveReport': 'Resolved a content report',
      'dismissReport': 'Dismissed a content report',
    };

    return descriptions[actionType] ?? 
           'Performed $actionType on ${targetType.name}';
  }
}
```

### Step 5: Audit Providers

**File**: `lib/features/community/moderation/view/providers/audit_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/audit_log_entry.dart';
import '../../data/repositories/audit_repository.dart';
import '../../data/services/audit_service.dart';
import '../../../../analytics/data/services/device_info_service.dart';

part 'audit_providers.g.dart';

@riverpod
AuditRepository auditRepository(Ref ref) {
  return AuditRepository(FirebaseFirestore.instance);
}

@riverpod
AuditService auditService(Ref ref) {
  return AuditService(
    ref.watch(auditRepositoryProvider),
    DeviceInfoService(),
  );
}

/// Query audit logs with filters
@riverpod
Future<List<AuditLogEntry>> auditLogs(
  Ref ref,
  String herdId, {
  AuditActionCategory? category,
  String? actorId,
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.queryLogs(
    herdId: herdId,
    category: category,
    actorId: actorId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Audit trail for a specific item
@riverpod
Future<List<AuditLogEntry>> targetAuditTrail(
  Ref ref,
  String herdId,
  String targetId,
) async {
  final repo = ref.watch(auditRepositoryProvider);
  return repo.getTargetAuditTrail(herdId, targetId);
}
```

### Step 6: Audit Log Viewer Screen

**File**: `lib/features/community/moderation/view/screens/audit_log_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/models/audit_log_entry.dart';
import '../providers/audit_providers.dart';

class AuditLogScreen extends ConsumerStatefulWidget {
  final String herdId;

  const AuditLogScreen({super.key, required this.herdId});

  @override
  ConsumerState<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends ConsumerState<AuditLogScreen> {
  AuditActionCategory? _categoryFilter;
  DateTimeRange? _dateRange;

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(auditLogsProvider(
      widget.herdId,
      category: _categoryFilter,
      startDate: _dateRange?.start,
      endDate: _dateRange?.end,
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audit Log'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportLogs,
          ),
        ],
      ),
      body: logs.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const Center(
              child: Text('No audit entries found'),
            );
          }

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              return _AuditLogEntryCard(entry: entries[index]);
            },
          );
        },
      ),
    );
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        currentCategory: _categoryFilter,
        currentDateRange: _dateRange,
        onApply: (category, dateRange) {
          setState(() {
            _categoryFilter = category;
            _dateRange = dateRange;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _exportLogs() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Audit Logs'),
        content: const Text(
          'This will export audit logs for the selected date range. '
          'The export will be sent to your email.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement export
              Navigator.pop(context);
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }
}

class _AuditLogEntryCard extends StatelessWidget {
  final AuditLogEntry entry;

  const _AuditLogEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy h:mm a');
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ExpansionTile(
        leading: _getActionIcon(),
        title: Text(entry.action.description),
        subtitle: Text(
          '${entry.actor.username ?? entry.actor.userId} • ${dateFormat.format(entry.timestamp)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Actor', entry.actor.username ?? entry.actor.userId),
                _buildInfoRow('Role', entry.actor.role),
                _buildInfoRow('Action', entry.action.subtype),
                _buildInfoRow('Target', '${entry.target.type.name}: ${entry.target.id}'),
                if (entry.metadata.reason != null)
                  _buildInfoRow('Reason', entry.metadata.reason!),
                if (entry.evidence?.contentSnapshot != null) ...[
                  const Divider(),
                  const Text('Evidence:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      entry.evidence!.contentSnapshot!,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
                if (entry.metadata.legalHold) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.gavel, color: Colors.red, size: 16),
                        const SizedBox(width: 8),
                        const Text(
                          'Legal Hold - Do not modify or delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _getActionIcon() {
    final iconMap = {
      AuditActionCategory.moderation: Icons.shield,
      AuditActionCategory.content: Icons.article,
      AuditActionCategory.user: Icons.person,
      AuditActionCategory.settings: Icons.settings,
      AuditActionCategory.access: Icons.lock,
    };

    return CircleAvatar(
      backgroundColor: _getCategoryColor().withOpacity(0.2),
      child: Icon(
        iconMap[entry.action.category] ?? Icons.info,
        color: _getCategoryColor(),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (entry.action.category) {
      case AuditActionCategory.moderation:
        return Colors.orange;
      case AuditActionCategory.content:
        return Colors.blue;
      case AuditActionCategory.user:
        return Colors.green;
      case AuditActionCategory.settings:
        return Colors.purple;
      case AuditActionCategory.access:
        return Colors.red;
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final AuditActionCategory? currentCategory;
  final DateTimeRange? currentDateRange;
  final Function(AuditActionCategory?, DateTimeRange?) onApply;

  const _FilterSheet({
    this.currentCategory,
    this.currentDateRange,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  AuditActionCategory? _category;
  DateTimeRange? _dateRange;

  @override
  void initState() {
    super.initState();
    _category = widget.currentCategory;
    _dateRange = widget.currentDateRange;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          DropdownButtonFormField<AuditActionCategory?>(
            value: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('All')),
              ...AuditActionCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name.toUpperCase()),
                  )),
            ],
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Date Range'),
            subtitle: Text(_dateRange != null
                ? '${DateFormat.yMd().format(_dateRange!.start)} - ${DateFormat.yMd().format(_dateRange!.end)}'
                : 'All time'),
            trailing: const Icon(Icons.date_range),
            onTap: () async {
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (range != null) {
                setState(() => _dateRange = range);
              }
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _category = null;
                      _dateRange = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => widget.onApply(_category, _dateRange),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

### Step 7: Cloud Function for Law Enforcement Export

**File**: `functions/legal_export.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Callable function to generate legal export
// Only callable by admins/owners
exports.generateLegalExport = functions.https.onCall(async (data, context) => {
  // Verify authentication
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'Must be authenticated'
    );
  }

  const { herdId, startDate, endDate, targetUserId, includeUserData } = data;

  // Verify caller is admin/owner of the herd
  const herdDoc = await admin.firestore()
    .collection('herds')
    .doc(herdId)
    .get();

  if (!herdDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Herd not found');
  }

  const herdData = herdDoc.data();
  const isOwner = herdData.creatorId === context.auth.uid;
  const isAdmin = herdData.adminIds?.includes(context.auth.uid);

  if (!isOwner && !isAdmin) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can export data'
    );
  }

  // Build the export
  const exportData = {
    metadata: {
      exportedAt: new Date().toISOString(),
      exportedBy: context.auth.uid,
      herdId,
      dateRange: { start: startDate, end: endDate },
      targetUserId: targetUserId || null,
    },
    auditLogs: [],
    userData: null,
    contentData: [],
  };

  // Get audit logs
  let auditQuery = admin.firestore()
    .collection('auditLogs')
    .doc(herdId)
    .collection('entries')
    .where('timestamp', '>=', new Date(startDate))
    .where('timestamp', '<=', new Date(endDate))
    .orderBy('timestamp');

  const auditSnapshot = await auditQuery.get();
  exportData.auditLogs = auditSnapshot.docs.map(doc => doc.data());

  // Get user data if requested
  if (includeUserData && targetUserId) {
    const userDoc = await admin.firestore()
      .collection('users')
      .doc(targetUserId)
      .get();

    if (userDoc.exists) {
      const userData = userDoc.data();
      // Remove sensitive fields
      delete userData.fcmTokens;
      delete userData.privateKeys;
      exportData.userData = userData;
    }

    // Get user's posts in this herd
    const postsSnapshot = await admin.firestore()
      .collection('herdPosts')
      .doc(herdId)
      .collection('posts')
      .where('authorId', '==', targetUserId)
      .get();

    exportData.contentData = postsSnapshot.docs.map(doc => ({
      type: 'post',
      id: doc.id,
      ...doc.data(),
    }));
  }

  // Store export for download
  const exportId = admin.firestore().collection('dummy').doc().id;
  await admin.firestore()
    .collection('legalExports')
    .doc(exportId)
    .set({
      ...exportData,
      status: 'complete',
      expiresAt: admin.firestore.Timestamp.fromDate(
        new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
      ),
    });

  return { exportId };
});

// Scheduled cleanup of old exports
exports.cleanupOldExports = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();

    const expiredExports = await admin.firestore()
      .collection('legalExports')
      .where('expiresAt', '<', now)
      .get();

    const batch = admin.firestore().batch();
    expiredExports.forEach(doc => {
      batch.delete(doc.ref);
    });

    await batch.commit();
    console.log(`Cleaned up ${expiredExports.size} expired exports`);
  });
```

---

## Integration with Existing Moderation Actions

Every moderation action should call the audit service:

```dart
// Example: In removePost method
Future<void> removePost(...) async {
  // ... existing removal logic ...

  // Log audit entry
  await ref.read(auditServiceProvider).logModerationAction(
    herdId: herdId,
    actorUserId: currentUser.uid,
    actorUsername: currentUser.displayName,
    actorRole: 'moderator',
    actionType: 'removePost',
    targetId: postId,
    targetType: AuditTargetType.post,
    reason: reason,
    targetSnapshot: postData, // Original post data
    contentSnapshot: postContent,
    mediaUrls: postMediaUrls,
    relatedReports: [reportId],
  );
}
```

---

## Security Rules

```javascript
// Audit logs are read-only for mods, write via Cloud Functions
match /auditLogs/{herdId}/entries/{entryId} {
  allow read: if request.auth != null
    && isHerdModerator(herdId, request.auth.uid);
  allow write: if false; // Only via Cloud Functions or server
}

// Legal exports only accessible by creator
match /legalExports/{exportId} {
  allow read: if request.auth != null
    && resource.data.metadata.exportedBy == request.auth.uid;
  allow write: if false;
}
```

---

## Testing Checklist

- [ ] Audit entries created for all moderation actions
- [ ] Device fingerprint captured correctly
- [ ] IP address handling respects privacy settings
- [ ] Audit log viewer displays entries correctly
- [ ] Filters work (category, date range, actor)
- [ ] Content snapshots preserved on removal
- [ ] Legal export generates complete package
- [ ] Legal hold prevents deletion
- [ ] Old exports cleaned up automatically

---

## Compliance Considerations

1. **GDPR**: Right to access - users can request their data
2. **CCPA**: Similar data access rights for California
3. **Content moderation transparency**: Logs show why content was removed
4. **Law enforcement**: Proper procedures for data requests

---

## Success Criteria

1. 100% of moderation actions logged
2. Chain of custody maintained for removed content
3. Legal exports generate within 60 seconds
4. Audit log queries return in < 2 seconds
5. Evidence preserved for minimum retention period

---

## Estimated Effort

- **Device Info Service**: 2-3 hours
- **Audit Models & Repository**: 4-5 hours
- **Audit Service**: 3-4 hours
- **Providers & UI**: 5-6 hours
- **Cloud Functions**: 3-4 hours
- **Integration with existing code**: 4-5 hours
- **Testing**: 3-4 hours
- **Total**: ~25-30 hours
