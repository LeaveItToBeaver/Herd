# Launch TODO (Markdown, actionable)

## P0 – Blockers before TestFlight/Play Beta

- [ ]  **Add Firebase Storage Security Rules** (`/storage.rules`) and reference in `firebase.json`
    - Public post media: world-read OK; write only by author/mod/admin.
    - E2EE chat media: store under `/private/{chatId}/{messageId}/{filename}`; read limited to chat participants; deny list to anyone else.
    - Deny any unknown buckets/paths by default.
- [ ]  **Tighten Firestore herd rules (remove debug looseness)**
    - Reinstate whitelist of mutable fields for admins; preserve immutables (`creatorId`, `createdAt`, `id`); deny broad updates.
    - Add server-validated writes (via CF) for sensitive counters if needed.
- [ ]  **Account Deletion (self-serve)**
    - UI: Settings → Account → Delete → 2-step confirm + reauth.
    - CF callable:
        1. Verify requester, tombstone user doc, enqueue deletion job.
        2. Delete/GC user’s public posts (or tombstone author to “Deleted” and strip PII), comments, votes, follows, notifications, keys, feeds.
        3. Revoke FCM tokens; purge Storage-owned paths.
    - Show completion/“we’ll email you” if asynchronous.
- [ ]  **Data Export (DSAR)**
    - UI: Settings → Privacy → Export my data.
    - CF job: compile JSON (profile, posts, comments, votes, herds created, settings), zip, signed URL with expiry; email link.
- [ ]  **Block/Mute end-to-end**
    - UI: user profile → Block/Mute.
    - Enforce in queries: exclude blocked users’ content from feeds/search/notifications; prevent DM initiation.
    - Firestore rules aren’t great for list-based cross-doc checks → do enforcement in the app + CF; log attempts server-side.

## P1 – Trust & Safety parity

- [ ]  **Report comments & profiles**
    - Add report affordances on comment widget and user profile overflow.
    - Extend repository to create `ReportModel` with `targetType = comment/user`.
- [ ]  **Appeals UX**
    - User: “View action → Appeal” screen with status.
    - Moderator/Admin: Appeals inbox + SLA timer; write `resolution` + notify.
- [ ]  **DM safety controls**
    - Settings: “Who can message me?” (Everyone / Followers / No one).
    - Enforce in CF callable for creating/chat messages; return structured errors.
- [ ]  **Rate-limits** (Cloud Functions & client)
    - Per-user/IP/device caps: posts/min, comments/min, DMs/min, votes/min for fresh accounts.
    - Exponential backoff + soft locks; surface friendly errors.
- [ ]  **Seed-post transparency toggle** (if you proceed with bots)
    - Tag content with `[Seed Post]`; per-user setting “Hide seed posts.”
    - Log % of users who hide to decide taper-off threshold.

## P1 – Admin / Ops

- [ ]  **Global Admin role & console**
    - Use Firebase Custom Claims: `{admin: true}`.
    - Web console (Flutter Web route): cross-herd reports queue, global search by user/post, hotkeys, bulk actions, audit view.
    - Actions: warn, restrict, shadow-ban, suspend, delete user (tombstone), content remove.
- [ ]  **Audit trail & email templates**
    - Every mod/admin action writes a non-mutable record (`modActions/{id}`).
    - User comms templates: warning, action taken, appeal result.

## P2 – Privacy & Legal polish

- [ ]  **In-app legal surfacing**
    - Link Terms/Privacy/Guidelines from Sign-up and Settings.
    - Store acceptance booleans on user doc (`acceptedLegal = true`, with timestamp/version).
- [ ]  **Transparency pages & safety docs**
    - Community Guidelines markdown; reporting instructions; law-enforcement guidelines (what metadata exists; emergency contact).
- [ ]  **Accessibility guardrails**
    - Alt-text prompt on image upload; captions/subtitles on video (optional assist); color-contrast checks in theme picker.

## P2 – Metrics & Observability

- [ ]  **Integrate GA4 (or Segment) + Crashlytics/Sentry**
    - Track: sign-up, first post time, posts/user/week, comments/post, D1/D7 retention, WAU/MAU, feed open → interaction rate, DM adoption, herd joins.
    - Export to BigQuery; create Looker Studio dashboard for week-over-week.
- [ ]  **Safety metrics**
    - Reports per 1k posts, time-to-first-action, repeat offender %, appeal reversal %.

## P2 – E2EE completeness

- [ ]  **Attachment encryption path end-to-end**
    - Encrypt on client → upload to private Storage path → store encrypted metadata in message doc (MIME, size) → decrypt on client of participant.
    - Ensure push notifications never contain plaintext.
- [ ]  **Voluntary E2EE abuse report**
    - UX to forward selected offending messages re-encrypted to a Trust & Safety public key (never your general server keys).
- [ ]  **Device verify/rotation**
    - Design a basic safety-numbers screen; allow "reset session & keys."

---

# DETAILED TECHNICAL PLAN: User Blocking System Implementation

## Overview
Expand the existing "Block/Mute end-to-end" P0 item with comprehensive technical implementation plan. This prevents blocked users from:
- Sending messages to users who blocked them
- Having their posts/comments appear in feeds of users who blocked them  
- Seeing posts/profiles of users who blocked them
- Interacting with users who blocked them

## Current State Analysis

### Already Exists
- **UserModel**: `blockedUsers` and `altBlockedUsers` fields are present
- **Chat System**: Robust messaging infrastructure with participant management
- **Feed System**: Post filtering capabilities exist
- **Settings UI**: Placeholder blocked users dialog exists

### Missing Implementation
- No repository methods to manage blocked users
- No blocking validation in chat messaging
- No feed filtering based on blocked users
- No blocked users management UI
- No profile/interaction restrictions

## Implementation Plan

### 1. **User Repository - Blocking Methods** 
*Priority: HIGH - Foundation for all other features*

#### 1.1 Core Blocking Operations
- [ ] `blockUser(String userId, String blockedUserId, {bool isAlt = false})`
- [ ] `unblockUser(String userId, String blockedUserId, {bool isAlt = false})`
- [ ] `isUserBlocked(String userId, String otherUserId, {bool isAlt = false})`
- [ ] `getBlockedUsers(String userId, {bool isAlt = false})`

#### 1.2 Bidirectional Blocking Checks
- [ ] `areUsersBlocking(String userId1, String userId2, {bool isAlt = false})` 
  - Returns if either user blocks the other
- [ ] `canUsersInteract(String userId1, String userId2, {bool isAlt = false})`
  - Central method to check if users can interact

#### 1.3 Batch Operations
- [ ] `getMultipleBlockingStatus(String userId, List<String> userIds, {bool isAlt = false})`
  - For efficient feed filtering

### 2. **Chat Messaging System Integration**
*Priority: HIGH - Prevent unwanted communication*

#### 2.1 Message Repository Updates
- [ ] Add blocking validation to `sendMessage()` method
- [ ] Add blocking validation to `sendMediaMessage()` method  
- [ ] Add blocking validation to message decryption
- [ ] Filter blocked users from chat participant lists

#### 2.2 Chat Repository Updates  
- [ ] Add blocking validation to `getOrCreateDirectChat()`
- [ ] Filter blocked users from chat listings
- [ ] Prevent chat creation between blocked users

#### 2.3 Chat UI Updates
- [ ] Show "User blocked" state in chat attempts
- [ ] Remove blocked users from chat search/suggestions
- [ ] Add block/unblock options in chat interface

### 3. **Feed System Integration** 
*Priority: HIGH - Hide blocked users' content*

#### 3.1 Feed Repository Updates
- [ ] Add blocked user filtering to `getPublicFeed()`
- [ ] Add blocked user filtering to `getAltFeed()`  
- [ ] Add blocked user filtering to trending posts
- [ ] Batch blocking checks for performance

#### 3.2 Post Repository Updates
- [ ] Filter blocked users from post comments
- [ ] Filter blocked users from post interactions
- [ ] Add blocking checks to post search

#### 3.3 Content Filtering
- [ ] Hide posts authored by blocked users
- [ ] Hide comments from blocked users
- [ ] Filter mentions/tags from blocked users

### 4. **User Profile Integration**
*Priority: MEDIUM - Restrict profile interactions*

#### 4.1 Profile Viewing Restrictions
- [ ] Block access to profiles of blocked users
- [ ] Block access to alt profiles of blocked users
- [ ] Show "User not available" for blocked profiles

#### 4.2 Follow/Connection Restrictions  
- [ ] Prevent following blocked users
- [ ] Prevent alt connections with blocked users
- [ ] Auto-remove existing connections when blocking

### 5. **Blocked Users Management UI**
*Priority: MEDIUM - User management interface*

#### 5.1 Blocked Users List Screen
- [ ] Create `BlockedUsersListScreen` 
- [ ] Show separate sections for public/alt blocked users
- [ ] Search functionality within blocked users
- [ ] Bulk unblock operations

#### 5.2 Settings Integration
- [ ] Replace placeholder `_showBlockedList()` with real functionality
- [ ] Navigate to dedicated blocked users screen
- [ ] Show block counts in settings

#### 5.3 Block/Unblock Actions
- [ ] Add block/unblock options to user profiles
- [ ] Add block/unblock options to chat interfaces  
- [ ] Add block options to post/comment interactions
- [ ] Confirmation dialogs for blocking actions

### 6. **Search and Discovery Updates**
*Priority: LOW - Prevent discovery of blocked users*

#### 6.1 User Search Filtering
- [ ] Filter blocked users from search results
- [ ] Filter blocked users from friend suggestions
- [ ] Filter blocked users from connection requests

#### 6.2 Alt Profile Considerations
- [ ] Handle blocking between public/alt identities
- [ ] Separate blocking lists for public vs alt interactions
- [ ] Cross-identity blocking implications

### 7. **Notification System Integration** 
*Priority: LOW - Block notifications from blocked users*

#### 7.1 Notification Filtering
- [ ] Block notifications from blocked users
- [ ] Block mention notifications from blocked users
- [ ] Block connection request notifications

### 8. **Performance Optimizations**
*Priority: LOW - Optimize for scale*

#### 8.1 Caching Strategy
- [ ] Cache frequently checked blocking relationships
- [ ] Implement efficient batch blocking queries
- [ ] Cache blocked user lists locally

#### 8.2 Database Optimizations  
- [ ] Add Firestore indexes for blocking queries
- [ ] Implement server-side blocking rules
- [ ] Optimize feed queries with blocking filters

## Implementation Order

1. **Phase 1: Core Infrastructure**
   - User repository blocking methods
   - Basic blocking validation in chat messaging
   - Feed filtering for blocked users

2. **Phase 2: UI and Management** 
   - Blocked users list screen
   - Block/unblock actions in profiles and chats
   - Settings integration

3. **Phase 3: Comprehensive Coverage**
   - Profile viewing restrictions  
   - Search filtering
   - Notification filtering

4. **Phase 4: Polish and Optimization**
   - Performance optimizations
   - Caching improvements
   - Edge case handling

## Technical Considerations

### Security
- Validate all blocking operations server-side
- Prevent circumventing blocks through alt accounts
- Audit trail for blocking actions

### User Experience  
- Clear feedback when interactions are blocked
- Graceful degradation when users are blocked
- Easy block/unblock mechanisms

### Performance
- Efficient blocking queries to not slow down feeds
- Batch operations where possible
- Strategic caching of blocking relationships

### Edge Cases
- Handling mutual blocks
- Blocking/unblocking in group contexts  
- Cross-identity blocking scenarios
- Migration of existing data

## Testing Strategy

- Unit tests for all repository methods
- Integration tests for UI flows
- Performance tests for feed filtering
- Edge case testing for blocking scenarios

---