# Feed State Persistence & Memory Optimization Plan (v2)

**Status:** ✅ APPROVED - Ready for execution (Phase 1)

**Issue:** Feed state (sort type, posts) resets when switching between screens, causing jarring reloads and inconsistent UI state.

**Goal:** Preserve feed state across navigation, only reload on explicit refresh, sort change, or staleness threshold.

**Memory Concern:** Power users who scroll through hundreds of posts shouldn't drain battery or slow down the device.

---

## Decision: Two-Phase Approach

Given your valid concern about memory usage, I recommend a **two-phase approach**:

| Phase | Focus | Complexity | Memory Impact |
|-------|-------|------------|---------------|
| **Phase 1** | Fix state persistence + add memory cap | Low | Limited to ~50-75 posts max |
| **Phase 2** | Full windowed virtualization | High | Only visible posts in memory |

**Recommendation:** Start with Phase 1. It solves 90% of the problem with 20% of the effort. Phase 2 can be added later if memory remains a concern after real-world testing.

---

## Phase 1: State Persistence with Memory Cap

### Strategy
1. Add `keepAlive: true` to prevent provider disposal
2. Add staleness tracking (`lastFetchedAt`)
3. **Cap in-memory posts to ~50-75** (configurable)
4. Older posts automatically go to disk cache (already working!)
5. When user scrolls back, reload from cache (some loading shimmer is acceptable)

### Why This Works
- Your `DataCacheService` already caches every post to disk
- When `loadMorePosts()` is called, it caches results via `cacheManager.cacheFeed()`
- If we limit state to 50-75 posts, memory stays under ~200-400 KB
- User scrolling back triggers normal pagination which hits disk cache first

---

## Phase 1 Implementation

### Task 1.1: Add `keepAlive: true` to Feed State Notifiers

**Files to modify:**
- `lib/features/social/feed/alt_feed/view/providers/alt_feed_provider.dart`
- `lib/features/social/feed/public_feed/view/providers/public_feed_provider.dart`

**Changes:**

```dart
// alt_feed_provider.dart - Line 27
// BEFORE:
@riverpod
class AltFeedStateNotifier extends _$AltFeedStateNotifier {

// AFTER:
@Riverpod(keepAlive: true)
class AltFeedStateNotifier extends _$AltFeedStateNotifier {
```

```dart
// public_feed_provider.dart - Line 27  
// BEFORE:
@riverpod
class PublicFeedStateNotifier extends _$PublicFeedStateNotifier {

// AFTER:
@Riverpod(keepAlive: true)
class PublicFeedStateNotifier extends _$PublicFeedStateNotifier {
```

---

### Task 1.2: Add Staleness Tracking & Memory Cap to Feed States

**Files to modify:**
- `lib/features/social/feed/alt_feed/view/providers/state/alt_feed_states.dart`
- `lib/features/social/feed/public_feed/view/providers/state/public_feed_state.dart`

**Changes - Add new fields:**

```dart
// alt_feed_states.dart
@freezed
abstract class AltFeedState with _$AltFeedState {
  const factory AltFeedState({
    required List<PostModel> posts,
    @Default(false) bool isLoading,
    @Default(true) bool hasMorePosts,
    Object? error,
    @Default(false) bool isRefreshing,
    PostModel? lastPost,
    @Default(false) bool fromCache,
    @Default(FeedSortType.hot) FeedSortType sortType,
    DateTime? lastCreatedAt,
    DateTime? lastFetchedAt,           // <-- NEW: Track when we last fetched
    @Default(0) int totalPostsLoaded,  // <-- NEW: Track total posts ever loaded (for pagination)
  }) = _AltFeedState;

  factory AltFeedState.initial() => const AltFeedState(
        posts: [],
        isLoading: false,
        hasMorePosts: true,
        error: null,
        isRefreshing: false,
        lastPost: null,
        fromCache: false,
        sortType: FeedSortType.hot,
        lastCreatedAt: null,
        lastFetchedAt: null,
        totalPostsLoaded: 0,
      );
}
```

Apply identical changes to `public_feed_state.dart`.

---

### Task 1.3: Add Memory Management to Controllers

**Files to modify:**
- `lib/features/social/feed/alt_feed/controllers/alt_feed_controller.dart`
- `lib/features/social/feed/public_feed/controllers/public_feed_controller.dart`

**Add constant and trim logic:**

```dart
// At top of AltFeedController class
class AltFeedController {
  // ... existing fields ...
  
  /// Maximum posts to keep in memory state
  /// Posts beyond this are still cached to disk and can be reloaded
  static const int maxPostsInMemory = 60;

  // ... existing constructor and methods ...
```

**Modify `loadMorePosts()` to trim old posts:**

In the section where posts are merged, add trimming logic:

```dart
// After merging posts, trim to maxPostsInMemory
final allPosts = [...state.posts, ...uniqueNewPosts];

// Trim oldest posts if we exceed memory cap
// Keep the most recent posts (end of list since we append new posts)
final trimmedPosts = allPosts.length > maxPostsInMemory
    ? allPosts.sublist(allPosts.length - maxPostsInMemory)
    : allPosts;

state = state.copyWith(
  posts: trimmedPosts,
  isLoading: false,
  hasMorePosts: gotFullPage,
  lastPost: uniqueNewPosts.isNotEmpty ? uniqueNewPosts.last : lastPost,
  // Track total loaded for potential "scroll back" feature
  totalPostsLoaded: state.totalPostsLoaded + uniqueNewPosts.length,
  lastCreatedAt: state.sortType == FeedSortType.latest && uniqueNewPosts.isNotEmpty
      ? uniqueNewPosts.last.createdAt
      : state.lastCreatedAt,
);
```

**Note:** This means if a user scrolls down 200 posts, then scrolls back up, the top posts will need to reload. This is the tradeoff - minimal memory vs. some reload shimmer.

---

### Task 1.4: Add Conditional Load Logic to Notifiers

**Files to modify:**
- `lib/features/social/feed/alt_feed/view/providers/alt_feed_provider.dart`
- `lib/features/social/feed/public_feed/view/providers/public_feed_provider.dart`

**Add staleness check:**

```dart
// In AltFeedStateNotifier class

/// Default staleness threshold (1 hour)
static const Duration _stalenessThreshold = Duration(hours: 1);

/// Check if current state has valid cached data
bool get hasValidCache {
  if (state.posts.isEmpty) return false;
  if (state.lastFetchedAt == null) return false;
  
  final age = DateTime.now().difference(state.lastFetchedAt!);
  return age < _stalenessThreshold;
}

Future<void> loadInitialPosts({
  String? overrideUserId, 
  bool forceRefresh = false,
}) async {
  // Skip load if we have valid cached data and not forcing refresh
  if (!forceRefresh && hasValidCache) {
    debugPrint('AltFeed: Using cached data (age: ${DateTime.now().difference(state.lastFetchedAt!).inMinutes}m)');
    return;
  }
  
  state = state.copyWith(isLoading: true, error: null);
  await _controller.loadInitialPosts(
      overrideUserId: overrideUserId, forceRefresh: forceRefresh);
  
  // Update lastFetchedAt after successful load
  state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
}

Future<void> changeSortType(FeedSortType newSortType) async {
  state = state.copyWith(
      sortType: newSortType, isLoading: true, error: null, posts: []);
  await _controller.changeSortType(newSortType);
  state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
}

Future<void> refreshFeed() async {
  state = state.copyWith(isRefreshing: true, error: null);
  await _controller.refreshFeed();
  state = _controller.state.copyWith(lastFetchedAt: DateTime.now());
}
```

Apply identical changes to `PublicFeedStateNotifier`.

---

### Task 1.5: Run Code Generation

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## Phase 1 File Change Summary

| File | Change Type | Description |
|------|-------------|-------------|
| `alt_feed_provider.dart` | Modify | Add `keepAlive: true`, staleness logic |
| `public_feed_provider.dart` | Modify | Add `keepAlive: true`, staleness logic |
| `alt_feed_states.dart` | Modify | Add `lastFetchedAt`, `totalPostsLoaded` |
| `public_feed_state.dart` | Modify | Add `lastFetchedAt`, `totalPostsLoaded` |
| `alt_feed_controller.dart` | Modify | Add `maxPostsInMemory` cap, trim logic |
| `public_feed_controller.dart` | Modify | Add `maxPostsInMemory` cap, trim logic |

---

## Phase 1 Behavior

| Scenario | Behavior |
|----------|----------|
| Switch feeds and back | ✅ No reload, state preserved (posts + sort type) |
| Change sort type | ✅ Reloads with new sort |
| Pull to refresh | ✅ Reloads fresh data |
| App idle < 1 hour | ✅ No reload on return |
| App idle > 1 hour | ✅ Reloads (stale) |
| Scroll through 200 posts | ✅ Only last 60 in memory, rest on disk |
| Scroll back up after 200 posts | ⚠️ Older posts reload from cache (shimmer visible) |

---

## Phase 2: Full Windowed Virtualization (Future)

If Phase 1's "reload shimmer when scrolling back" is unacceptable, Phase 2 would implement:

### Concept
- Store only **post IDs** in state, not full `PostModel` objects
- Fetch posts on-demand from disk cache when they enter viewport
- Use Flutter's `ListView.builder` index to determine which posts to fetch

### Implementation Sketch

```dart
// State holds IDs only
@freezed
class AltFeedState {
  const factory AltFeedState({
    required List<String> postIds,        // Just IDs, not full models
    required Map<String, PostModel> visiblePosts,  // Currently visible window
    // ... other fields
  }) = _AltFeedState;
}

// Provider fetches posts when scrolling
class AltFeedStateNotifier {
  Future<PostModel?> getPostAtIndex(int index) async {
    final postId = state.postIds[index];
    
    // Check in-memory window first
    if (state.visiblePosts.containsKey(postId)) {
      return state.visiblePosts[postId];
    }
    
    // Fetch from disk cache
    final post = await cacheManager.getPost(postId, isAlt: true);
    
    // Add to visible window, trim window if needed
    _updateVisibleWindow(postId, post);
    
    return post;
  }
}

// Widget uses indexed builder
ListView.builder(
  itemCount: state.postIds.length,
  itemBuilder: (context, index) {
    return FutureBuilder<PostModel?>(
      future: ref.read(altFeedStateProvider.notifier).getPostAtIndex(index),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return PostShimmer();
        return PostWidget(post: snapshot.data!);
      },
    );
  },
);
```

### Why Defer Phase 2
- Significantly more complex
- Requires UI changes (FutureBuilder per item)
- Phase 1 solves most real-world scenarios
- Can add later if metrics show memory issues

---

## Testing Checklist (Phase 1)

- [ ] Switch from public → alt → public: sort type and posts preserved
- [ ] Switch from alt → public → alt: sort type and posts preserved
- [ ] Change sort type: posts reload with correct sort
- [ ] Pull to refresh: posts reload
- [ ] Background app < 1 hour, resume: no reload
- [ ] Background app > 1 hour, resume: reloads fresh data
- [ ] Cold start app: loads initial posts
- [ ] Scroll through 100+ posts: memory stays bounded
- [ ] Scroll back up after 100+ posts: older posts reload (acceptable shimmer)

---

## Risks & Mitigations (Phase 1)

| Risk | Impact | Mitigation |
|------|--------|------------|
| Scroll-back shimmer | Low-Medium | Acceptable UX tradeoff; posts load fast from disk |
| Memory cap too low (60) | Low | Easily configurable; test and adjust |
| Auth change doesn't reset | High | Providers watch `authProvider`, auto-rebuild |
| Stale data shown | Low | 1 hour threshold is reasonable; pull-to-refresh always works |

---

## Execution Order (Phase 1)

1. ✅ Task 1.2: Add `lastFetchedAt` + `totalPostsLoaded` to state classes
2. ✅ Task 1.1: Add `keepAlive: true` to notifiers
3. ✅ Task 1.3: Add `maxPostsInMemory` cap to controllers
4. ✅ Task 1.4: Add conditional load logic to notifiers
5. ✅ Task 1.5: Run code generation
6. ✅ Test all scenarios from checklist
7. 📊 Monitor memory usage in real-world testing
8. 🔮 Decide if Phase 2 is needed based on metrics

---

## Summary

**Phase 1 gives you:**
- ✅ State persistence across navigation (no more sort type reset)
- ✅ No unnecessary reloads when switching screens
- ✅ Memory bounded to ~60 posts (~300-400 KB)
- ✅ Leverages your existing disk cache
- ⚠️ Scroll-back after 60+ posts shows brief loading

**Is this acceptable?** The scroll-back loading is the main tradeoff. If that's okay, Phase 1 is the way to go. If you absolutely need seamless scroll-back, we'd need Phase 2's complexity.
