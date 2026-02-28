# Herd Moderation System - Implementation Guide

## Overview

This document serves as the master guide for implementing a comprehensive, scalable moderation system for the Herd social platform. The system is designed to handle millions of users while minimizing Firestore read/write costs.

## Architecture Principles

### 1. **Firestore Cost Optimization**
- **Denormalization over joins**: Store computed/aggregated data to avoid multi-document reads
- **Pagination everywhere**: Never load unbounded lists
- **Counters over counts**: Use `FieldValue.increment()` instead of counting documents
- **Subcollections for scale**: Use subcollections for 1:many relationships (e.g., `/herds/{herdId}/moderationLog/`)
- **Composite indexes**: Pre-create indexes for common queries
- **Cache aggressively**: Use Riverpod's caching + local persistence

### 2. **Security Model**
- **Firestore Security Rules**: All permission checks MUST be enforced server-side
- **Defense in depth**: Client-side checks are UX only, never trust them for security
- **Audit everything**: Every moderation action creates an immutable log entry

### 3. **Scalability Targets**
- Support 10,000+ herds
- Support 1M+ users
- Handle 100+ reports/day per large herd
- Dashboard loads < 50 Firestore reads
- Moderation actions < 10 writes

## Phase Overview

| Phase | Focus | Status | Est. Hours |
|-------|-------|--------|------------|
| [Phase 1](./phase-1-roles-permissions.md) | Roles & Permissions System | 🔲 Not Started | 10-12h |
| [Phase 2](./phase-2-strike-system.md) | Strike/Warning System | 🔲 Not Started | 12-15h |
| [Phase 3](./phase-3-reporting-workflow.md) | Reporting Workflow | 🔲 Not Started | 15-18h |
| [Phase 4](./phase-4-post-locking.md) | Post Locking | 🔲 Not Started | 8-10h |
| [Phase 5](./phase-5-granular-restrictions.md) | Granular User Restrictions | 🔲 Not Started | 10-12h |
| [Phase 6](./phase-6-content-removal.md) | Content Removal & Restoration | 🔲 Not Started | 15-18h |
| [Phase 7](./phase-7-analytics.md) | Analytics Infrastructure | 🔲 Not Started | 20-25h |
| [Phase 8](./phase-8-audit-legal.md) | Audit Logging & Legal Export | 🔲 Not Started | 25-30h |

**Total Estimated Effort: ~115-140 hours**

## Current Codebase Structure

```
lib/features/community/moderation/
├── data/
│   ├── models/
│   │   ├── moderation_action_model.dart    # Existing action logging model
│   │   └── report_model.dart               # Existing report model
│   └── repositories/
│       └── moderation_repository.dart      # Main repository (568 lines)
└── view/
    ├── providers/
    │   ├── moderation_providers.dart       # Riverpod providers
    │   └── pinned_post_management_providers.dart
    ├── screens/
    │   ├── member_management_screen.dart
    │   ├── moderation_dashboard_screen.dart
    │   ├── moderation_log_screen.dart
    │   └── pinned_post_management_screen.dart
    └── widgets/
        ├── batch_action_sheet_widget.dart
        ├── member_action_sheet_widget.dart
        ├── member_tile_widget.dart
        └── suspend_member_dialog_widget.dart
```

## Related Models & Files

- `lib/features/community/herds/data/models/herd_model.dart` - Has `creatorId`, `moderatorIds`
- `lib/features/user/user_profile/data/models/user_model.dart` - Has `role`, `herdAndRole`, `reportCount`, `accountStatus`
- `lib/features/content/post/data/models/post_model.dart` - Post structure
- `functions/` - Cloud Functions (Node.js)

## Firestore Collections (Current + Planned)

```
/herds/{herdId}
  - creatorId, moderatorIds[], bannedUserIds[], pinnedPosts[]
  
/herds/{herdId}/members/{userId}
  - joinedAt, isModerator, role (NEW: will add restrictions)

/moderationLogs/{herdId}/actions/{actionId}
  - Existing moderation action log

/reports/{reportId}
  - Existing reports collection

/herdSuspensions/{herdId}/suspended/{userId}
  - Existing suspension tracking

# NEW COLLECTIONS (to be added)
/herds/{herdId}/strikes/{strikeId}
  - User strikes within a herd

/herds/{herdId}/reportQueue/{reportId}
  - Denormalized report queue for faster dashboard loading

/users/{userId}/moderationHistory/{entryId}
  - Cross-herd moderation history for a user

/auditLogs/{logId}
  - Immutable audit trail for legal/compliance
```

## Tech Stack Reference

- **State Management**: Riverpod 3 with codegen (`@riverpod` annotations)
- **Backend**: Firebase (Firestore, Cloud Functions, Auth)
- **Models**: Freezed for immutable models
- **Navigation**: GoRouter
- **Pattern**: Feature-first folder structure with data/view/providers split

## Getting Started

1. Read the phase document you're implementing
2. Check "Prerequisites" section for dependencies
3. Follow the implementation order within each phase
4. Run `dart run build_runner build` after adding/modifying models
5. Test with Firebase emulators before deploying

## Contact & Ownership

- Project Owner: Jason (LeaveItToBeaver)
- Repository: `herd_riverpod`
- Branch for moderation work: `feature/moderation-system` (create from `refactor/dependancies-and-riverpod-3`)
