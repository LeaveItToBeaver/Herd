# Cache-First Delta Loading Strategy

## Problem
- Messages are duplicating due to race conditions between optimistic UI and real-time streams
- Complex duplicate detection causing issues
- Real-time streams causing unnecessary load

## Solution: Cache-First with Delta Loading

### Core Principles
1. **Cache is the source of truth** for UI
2. **No real-time streams** - only on-demand syncing
3. **Delta loading** - only fetch what we don't have
4. **Simple optimistic UI** - add to cache immediately

### Flow

#### Message Loading (when opening chat)
1. Load from cache immediately → show to user
2. Check server message count vs cache count
3. If different, fetch only the delta (new messages)
4. Update cache with new messages
5. Update UI with combined messages

#### Message Sending
1. Add optimistic message to cache & UI immediately
2. Send to server in background
3. When successful, replace optimistic with server message in cache
4. Update UI with final message

### Benefits
- No duplicates (cache controls what shows)
- Minimal server reads (only deltas)
- Instant loading (cache-first)
- Simple logic (no complex stream management)

### Implementation Plan
1. Add delta sync methods to MessageRepository
2. Replace MessagesNotifier stream with cache-first loading
3. Update message sending to work with cache
4. Update UI to use only cached data

## Status: Ready to implement step by step
