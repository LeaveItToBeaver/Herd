# Phase 1: Roles & Permissions System

## Status: 🔲 Not Started

## Goal

Create a robust, scalable role-based access control (RBAC) system that:
1. Defines clear hierarchy: **Member → Moderator → Admin → Owner**
2. Maps roles to granular permissions
3. Enforces permissions both client-side (UX) and server-side (security)
4. Scales to thousands of herds without per-herd configuration overhead

## Why This Matters

Every other moderation feature depends on answering: "Can this user do this action?"
Without a proper permission system, we'd have scattered `if (isOwner || isModerator)` checks everywhere.

---

## Prerequisites

- [ ] Familiarity with the existing `HerdModel` (`lib/features/community/herds/data/models/herd_model.dart`)
- [ ] Understanding of Riverpod 3 codegen patterns (see `riverpod-migration-guide.md`)
- [ ] Access to Firestore console for security rules updates

---

## Architecture Decisions

### 1. Role Storage Strategy

**Decision**: Store role at the **herd membership level**, not user level.

```
/herds/{herdId}/members/{userId}
  - role: "member" | "moderator" | "admin" | "owner"
  - joinedAt: Timestamp
  - restrictions: Map<String, bool>  // Phase 5
```

**Rationale**:
- A user can be Owner of Herd A, Moderator of Herd B, and Member of Herd C
- Avoids complex cross-collection queries
- Single read to get user's role in a herd

### 2. Permission Inheritance

```
Owner    → All permissions
Admin    → All permissions EXCEPT: delete herd, transfer ownership
Moderator → Content moderation, user warnings, view reports
Member   → Post, comment, report content
```

### 3. Cost Analysis

| Operation | Reads | Writes |
|-----------|-------|--------|
| Check user permission | 1 | 0 |
| Promote user to mod | 2 | 2 |
| View herd with role | 1 | 0 |

---

## Implementation Plan

### Step 1: Create Role & Permission Enums

**File**: `lib/features/community/moderation/data/models/herd_role.dart`

```dart
/// Herd role hierarchy (lowest to highest privilege)
enum HerdRole {
  member(0),
  moderator(1),
  admin(2),
  owner(3);

  final int level;
  const HerdRole(this.level);

  /// Check if this role has at least the privilege of [other]
  bool hasAtLeast(HerdRole other) => level >= other.level;
  
  /// Check if this role outranks [other]
  bool outranks(HerdRole other) => level > other.level;
}

/// Granular permissions for herd actions
enum HerdPermission {
  // Content permissions
  createPost,
  editOwnPost,
  deleteOwnPost,
  editAnyPost,
  deleteAnyPost,
  pinPost,
  lockPost,
  
  // Comment permissions
  createComment,
  editOwnComment,
  deleteOwnComment,
  deleteAnyComment,
  
  // User management
  viewMembers,
  warnUser,
  muteUser,
  kickUser,
  banUser,
  unbanUser,
  
  // Role management
  promoteToMod,
  demoteFromMod,
  promoteToAdmin,
  demoteFromAdmin,
  transferOwnership,
  
  // Moderation tools
  viewReports,
  resolveReports,
  escalateReports,
  viewModerationLog,
  viewAnalytics,
  
  // Herd management
  editHerdInfo,
  editHerdSettings,
  deleteHerd,
}
```

### Step 2: Create Permission Mapping

**File**: `lib/features/community/moderation/data/models/permission_matrix.dart`

```dart
/// Maps roles to their allowed permissions
class PermissionMatrix {
  static const Map<HerdRole, Set<HerdPermission>> _matrix = {
    HerdRole.member: {
      HerdPermission.createPost,
      HerdPermission.editOwnPost,
      HerdPermission.deleteOwnPost,
      HerdPermission.createComment,
      HerdPermission.editOwnComment,
      HerdPermission.deleteOwnComment,
      HerdPermission.viewMembers,
    },
    HerdRole.moderator: {
      // Inherits all member permissions +
      HerdPermission.deleteAnyPost,
      HerdPermission.deleteAnyComment,
      HerdPermission.pinPost,
      HerdPermission.lockPost,
      HerdPermission.warnUser,
      HerdPermission.muteUser,
      HerdPermission.kickUser,
      HerdPermission.viewReports,
      HerdPermission.resolveReports,
      HerdPermission.viewModerationLog,
    },
    HerdRole.admin: {
      // Inherits all moderator permissions +
      HerdPermission.editAnyPost,
      HerdPermission.banUser,
      HerdPermission.unbanUser,
      HerdPermission.promoteToMod,
      HerdPermission.demoteFromMod,
      HerdPermission.escalateReports,
      HerdPermission.viewAnalytics,
      HerdPermission.editHerdInfo,
      HerdPermission.editHerdSettings,
    },
    HerdRole.owner: {
      // All permissions
      ...HerdPermission.values,
    },
  };

  /// Check if a role has a specific permission
  static bool hasPermission(HerdRole role, HerdPermission permission) {
    // Aggregate permissions with inheritance
    final permissions = <HerdPermission>{};
    for (final r in HerdRole.values) {
      if (role.hasAtLeast(r)) {
        permissions.addAll(_matrix[r] ?? {});
      }
    }
    return permissions.contains(permission);
  }
  
  /// Get all permissions for a role (including inherited)
  static Set<HerdPermission> getPermissions(HerdRole role) {
    final permissions = <HerdPermission>{};
    for (final r in HerdRole.values) {
      if (role.hasAtLeast(r)) {
        permissions.addAll(_matrix[r] ?? {});
      }
    }
    return permissions;
  }
}
```

### Step 3: Create HerdMember Model (Updated)

**File**: `lib/features/community/herds/data/models/herd_member.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:herdapp/features/community/moderation/data/models/herd_role.dart';

part 'herd_member.freezed.dart';

@freezed
abstract class HerdMember with _$HerdMember {
  const HerdMember._();

  const factory HerdMember({
    required String oderId,
    required String herdId,
    required DateTime joinedAt,
    @Default(HerdRole.member) HerdRole role,
    String? promotedBy,        // Who gave them their current role
    DateTime? roleChangedAt,   // When role was last changed
    @Default({}) Map<String, bool> restrictions, // For Phase 5
  }) = _HerdMember;

  factory HerdMember.fromMap(String oderId, Map<String, dynamic> map) {
    return HerdMember(
      oderId: oderId,
      herdId: map['herdId'] ?? '',
      joinedAt: (map['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      role: HerdRole.values.firstWhere(
        (r) => r.name == map['role'],
        orElse: () => HerdRole.member,
      ),
      promotedBy: map['promotedBy'],
      roleChangedAt: (map['roleChangedAt'] as Timestamp?)?.toDate(),
      restrictions: Map<String, bool>.from(map['restrictions'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'herdId': herdId,
      'joinedAt': Timestamp.fromDate(joinedAt),
      'role': role.name,
      'promotedBy': promotedBy,
      'roleChangedAt': roleChangedAt != null 
          ? Timestamp.fromDate(roleChangedAt!) 
          : null,
      'restrictions': restrictions,
    };
  }

  /// Check if this member has a specific permission
  bool hasPermission(HerdPermission permission) {
    return PermissionMatrix.hasPermission(role, permission);
  }
  
  /// Check if this member can perform an action on another member
  bool canActOn(HerdMember target) {
    return role.outranks(target.role);
  }
}
```

### Step 4: Create Role Provider

**File**: `lib/features/community/moderation/view/providers/role_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/herd_role.dart';
import '../../data/models/permission_matrix.dart';
import '../../../herds/data/models/herd_member.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';

part 'role_providers.g.dart';

/// Get the current user's membership in a herd
@riverpod
Future<HerdMember?> currentUserHerdMembership(
  Ref ref,
  String herdId,
) async {
  final user = ref.watch(authProvider);
  if (user == null) return null;

  final doc = await FirebaseFirestore.instance
      .collection('herds')
      .doc(herdId)
      .collection('members')
      .doc(user.uid)
      .get();

  if (!doc.exists) return null;
  return HerdMember.fromMap(doc.id, doc.data()!);
}

/// Get the current user's role in a herd
@riverpod
Future<HerdRole?> currentUserRole(Ref ref, String herdId) async {
  final membership = await ref.watch(
    currentUserHerdMembershipProvider(herdId).future,
  );
  return membership?.role;
}

/// Check if current user has a specific permission in a herd
@riverpod
Future<bool> hasPermission(
  Ref ref,
  String herdId,
  HerdPermission permission,
) async {
  final role = await ref.watch(currentUserRoleProvider(herdId).future);
  if (role == null) return false;
  return PermissionMatrix.hasPermission(role, permission);
}

/// Stream the current user's role (for real-time updates)
@riverpod
Stream<HerdRole?> currentUserRoleStream(Ref ref, String herdId) {
  final user = ref.watch(authProvider);
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('herds')
      .doc(herdId)
      .collection('members')
      .doc(user.uid)
      .snapshots()
      .map((doc) {
        if (!doc.exists) return null;
        final roleStr = doc.data()?['role'] as String?;
        return HerdRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => HerdRole.member,
        );
      });
}
```

### Step 5: Create Role Management Repository

**File**: `lib/features/community/moderation/data/repositories/role_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/herd_role.dart';
import '../models/moderation_action_model.dart';

class RoleRepository {
  final FirebaseFirestore _firestore;

  RoleRepository(this._firestore);

  /// Change a user's role in a herd
  /// Returns true if successful, throws on error
  Future<bool> changeUserRole({
    required String herdId,
    required String targetUserId,
    required HerdRole newRole,
    required String performedBy,
    required HerdRole performerRole,
  }) async {
    // Validate: performer must outrank target's current AND new role
    final targetDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .doc(targetUserId)
        .get();

    if (!targetDoc.exists) {
      throw Exception('User is not a member of this herd');
    }

    final currentRole = HerdRole.values.firstWhere(
      (r) => r.name == targetDoc.data()?['role'],
      orElse: () => HerdRole.member,
    );

    // Cannot promote to same or higher level as self
    if (!performerRole.outranks(newRole)) {
      throw Exception('Cannot assign a role equal to or higher than your own');
    }

    // Cannot demote someone at same or higher level
    if (!performerRole.outranks(currentRole)) {
      throw Exception('Cannot modify role of someone at or above your level');
    }

    // Special case: only owner can transfer ownership
    if (newRole == HerdRole.owner && performerRole != HerdRole.owner) {
      throw Exception('Only the owner can transfer ownership');
    }

    final batch = _firestore.batch();
    final now = DateTime.now();

    // Update member role
    batch.update(
      _firestore
          .collection('herds')
          .doc(herdId)
          .collection('members')
          .doc(targetUserId),
      {
        'role': newRole.name,
        'promotedBy': performedBy,
        'roleChangedAt': Timestamp.fromDate(now),
      },
    );

    // Log the action
    final actionId = _firestore.collection('dummy').doc().id;
    final actionType = newRole.level > currentRole.level
        ? _getPromotionActionType(newRole)
        : _getDemotionActionType(currentRole);

    batch.set(
      _firestore
          .collection('moderationLogs')
          .doc(herdId)
          .collection('actions')
          .doc(actionId),
      ModerationAction(
        actionId: actionId,
        performedBy: performedBy,
        timestamp: now,
        actionType: actionType,
        targetId: targetUserId,
        targetType: ModTargetType.user,
        metadata: {
          'herdId': herdId,
          'previousRole': currentRole.name,
          'newRole': newRole.name,
        },
      ).toMap(),
    );

    // If transferring ownership, demote current owner to admin
    if (newRole == HerdRole.owner) {
      batch.update(
        _firestore
            .collection('herds')
            .doc(herdId)
            .collection('members')
            .doc(performedBy),
        {
          'role': HerdRole.admin.name,
          'roleChangedAt': Timestamp.fromDate(now),
        },
      );

      // Update herd document
      batch.update(
        _firestore.collection('herds').doc(herdId),
        {
          'creatorId': targetUserId,
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );
    }

    // Update moderatorIds array for backward compatibility
    if (newRole == HerdRole.moderator || newRole == HerdRole.admin) {
      batch.update(
        _firestore.collection('herds').doc(herdId),
        {
          'moderatorIds': FieldValue.arrayUnion([targetUserId]),
        },
      );
    } else if (currentRole == HerdRole.moderator || currentRole == HerdRole.admin) {
      batch.update(
        _firestore.collection('herds').doc(herdId),
        {
          'moderatorIds': FieldValue.arrayRemove([targetUserId]),
        },
      );
    }

    await batch.commit();
    return true;
  }

  ModActionType _getPromotionActionType(HerdRole newRole) {
    switch (newRole) {
      case HerdRole.moderator:
        return ModActionType.addModerator;
      case HerdRole.admin:
        return ModActionType.addModerator; // TODO: Add addAdmin type
      case HerdRole.owner:
        return ModActionType.transferOwnership;
      default:
        return ModActionType.unknown;
    }
  }

  ModActionType _getDemotionActionType(HerdRole oldRole) {
    switch (oldRole) {
      case HerdRole.moderator:
      case HerdRole.admin:
        return ModActionType.removeModerator;
      default:
        return ModActionType.unknown;
    }
  }

  /// Get all members with a specific role or higher
  Future<List<String>> getMembersWithRole(
    String herdId,
    HerdRole minimumRole,
  ) async {
    final snapshot = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .get();

    return snapshot.docs
        .where((doc) {
          final role = HerdRole.values.firstWhere(
            (r) => r.name == doc.data()['role'],
            orElse: () => HerdRole.member,
          );
          return role.hasAtLeast(minimumRole);
        })
        .map((doc) => doc.id)
        .toList();
  }
}
```

### Step 6: Update Firestore Security Rules

**File**: `firestore.rules` (add to existing)

```javascript
// Helper function to get user's role in a herd
function getUserRole(herdId, userId) {
  return get(/databases/$(database)/documents/herds/$(herdId)/members/$(userId)).data.role;
}

function hasRole(herdId, userId, allowedRoles) {
  return getUserRole(herdId, userId) in allowedRoles;
}

function isHerdModerator(herdId, userId) {
  return hasRole(herdId, userId, ['moderator', 'admin', 'owner']);
}

function isHerdAdmin(herdId, userId) {
  return hasRole(herdId, userId, ['admin', 'owner']);
}

function isHerdOwner(herdId, userId) {
  return hasRole(herdId, userId, ['owner']);
}

// Example rule for member role changes
match /herds/{herdId}/members/{memberId} {
  allow read: if request.auth != null;
  
  allow update: if request.auth != null
    && isHerdAdmin(herdId, request.auth.uid)
    // Can only modify role if you outrank the target
    && (
      !('role' in request.resource.data) 
      || roleLevel(request.resource.data.role) < roleLevel(getUserRole(herdId, request.auth.uid))
    );
}

// Role level helper (higher = more privilege)
function roleLevel(role) {
  return role == 'owner' ? 3 :
         role == 'admin' ? 2 :
         role == 'moderator' ? 1 : 0;
}
```

### Step 7: Migration Script

**File**: `scripts/migrate_roles.dart` (run once)

```dart
/// Migrates existing herd members to the new role system
/// - creatorId → owner role
/// - moderatorIds[] → moderator role
/// - everyone else → member role
Future<void> migrateExistingHerds() async {
  final firestore = FirebaseFirestore.instance;
  final herds = await firestore.collection('herds').get();

  for (final herdDoc in herds.docs) {
    final herdId = herdDoc.id;
    final data = herdDoc.data();
    final creatorId = data['creatorId'] as String?;
    final moderatorIds = List<String>.from(data['moderatorIds'] ?? []);

    final members = await firestore
        .collection('herds')
        .doc(herdId)
        .collection('members')
        .get();

    final batch = firestore.batch();

    for (final memberDoc in members.docs) {
      final memberId = memberDoc.id;
      String role;

      if (memberId == creatorId) {
        role = 'owner';
      } else if (moderatorIds.contains(memberId)) {
        role = 'moderator';
      } else {
        role = 'member';
      }

      batch.update(memberDoc.reference, {'role': role});
    }

    await batch.commit();
    print('Migrated herd $herdId');
  }
}
```

---

## Integration Points

### Files to Update

1. **`lib/features/community/herds/view/providers/herd_providers.dart`**
   - Replace `isHerdModeratorProvider` with new permission-based providers

2. **`lib/features/community/moderation/view/screens/member_management_screen.dart`**
   - Use `hasPermissionProvider` instead of hardcoded checks

3. **`lib/features/community/moderation/view/widgets/member_action_sheet_widget.dart`**
   - Show/hide actions based on permissions

4. **`lib/features/community/herds/data/models/herd_model.dart`**
   - Deprecate `isModerator()` method (keep for backward compatibility)

---

## Testing Checklist

- [ ] Owner can promote member → mod → admin
- [ ] Admin can promote member → mod (but not → admin)
- [ ] Moderator cannot promote anyone
- [ ] Owner can transfer ownership (becomes admin after transfer)
- [ ] Cannot demote someone at same or higher level
- [ ] Permission checks work in UI
- [ ] Security rules block unauthorized role changes
- [ ] Migration script handles existing data

---

## Success Criteria

1. **Single source of truth**: Role is stored in `/herds/{herdId}/members/{userId}.role`
2. **Permissions are centralized**: All permission checks go through `PermissionMatrix`
3. **Backward compatible**: Old `moderatorIds` array is kept in sync
4. **Cost efficient**: Role check = 1 Firestore read (cached by Riverpod)
5. **Secure**: Security rules enforce hierarchy

---

## Next Phase Dependency

Phase 2 (Strike System) requires:
- ✅ `HerdPermission.warnUser` permission
- ✅ Role hierarchy for "who can strike whom"
- ✅ `hasPermission` provider

---

## Estimated Effort

- **Development**: 4-6 hours
- **Testing**: 2-3 hours
- **Migration**: 1 hour (existing herds)
- **Total**: ~8-10 hours
