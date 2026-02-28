# Phase 7: Analytics & Insights

## Status: 🔲 Not Started

## Goal

Implement a comprehensive analytics system that:
1. Tracks post views and engagement
2. Monitors page/screen analytics
3. Identifies trending content and keywords
4. Provides moderators with community health metrics
5. All with minimal Firestore cost impact

---

## Prerequisites

- [x] Basic post and herd structure
- [ ] Understand current engagement tracking
- [ ] Firebase Analytics for app-level events (optional integration)

---

## Architecture Decisions

### 1. Post View Tracking Strategy

**Challenge**: Tracking every view as a document write = expensive

**Solution**: Batch and aggregate

```
1. Client-side debouncing (no repeat views within 5 min)
2. Write to per-user daily view buffer document
3. Cloud Function aggregates to post document hourly
```

### 2. Data Storage Structure

```typescript
// Per-user view buffer (reduces writes significantly)
// /analytics/views/daily/{date}/users/{userId}
{
  viewedPosts: {
    [postId]: Timestamp,  // First view time
  }
}

// Post engagement document
// /herdPosts/{herdId}/posts/{postId}
{
  // ... existing post fields ...
  
  // View counts (aggregated)
  viewCount: number,
  uniqueViewers: number,
  
  // Engagement breakdown
  engagement: {
    reactionCount: number,
    commentCount: number,
    shareCount: number,
  },
  
  // Trending score (calculated)
  trendingScore: number,
  trendingUpdatedAt: Timestamp,
}

// Herd-level analytics (aggregated daily)
// /herds/{herdId}/analytics/daily/{date}
{
  totalViews: number,
  uniqueVisitors: number,
  newMembers: number,
  postsCreated: number,
  commentsCreated: number,
  topPosts: [
    { postId, viewCount, engagementScore },
    // ... top 10
  ],
  // Hourly breakdown for charts
  hourlyViews: { '0': 5, '1': 3, ... '23': 12 },
}

// Keyword/trending topics (aggregated)
// /herds/{herdId}/analytics/trending
{
  keywords: [
    { word: 'flutter', count: 45, trend: 'up' },
    { word: 'firebase', count: 32, trend: 'stable' },
    // ... top 20
  ],
  updatedAt: Timestamp,
}
```

### 3. Cost Analysis

| Operation | Traditional | Optimized |
|-----------|-------------|-----------|
| 1000 post views | 1000 writes | ~50 writes (batched) |
| Daily analytics | 1000+ reads | 1 read (aggregated) |
| Trending calculation | Full scan | Incremental |

---

## Implementation Plan

### Step 1: View Tracking Service

**File**: `lib/features/analytics/data/services/view_tracking_service.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewTrackingService {
  final FirebaseFirestore _firestore;
  static const _viewCooldownMinutes = 5;
  
  // In-memory cache of recent views
  final Map<String, DateTime> _recentViews = {};

  ViewTrackingService(this._firestore);

  /// Track a post view with debouncing
  Future<void> trackPostView({
    required String userId,
    required String herdId,
    required String postId,
  }) async {
    // Check in-memory cache first
    final cacheKey = '$userId:$postId';
    final lastView = _recentViews[cacheKey];
    
    if (lastView != null &&
        DateTime.now().difference(lastView).inMinutes < _viewCooldownMinutes) {
      return; // Skip - viewed too recently
    }

    // Update in-memory cache
    _recentViews[cacheKey] = DateTime.now();

    // Clean old cache entries (keep memory usage low)
    _cleanCache();

    // Write to daily buffer document
    final today = _getDateString(DateTime.now());
    final bufferRef = _firestore
        .collection('analytics')
        .doc('views')
        .collection('daily')
        .doc(today)
        .collection('users')
        .doc(userId);

    await bufferRef.set({
      'viewedPosts.$postId': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  void _cleanCache() {
    final cutoff = DateTime.now().subtract(
      const Duration(minutes: _viewCooldownMinutes * 2),
    );
    _recentViews.removeWhere((_, time) => time.isBefore(cutoff));
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Track screen/page view
  Future<void> trackScreenView({
    required String userId,
    required String screenName,
    Map<String, dynamic>? params,
  }) async {
    // For screen tracking, we use Firebase Analytics
    // This is a lightweight wrapper
    await _firestore
        .collection('analytics')
        .doc('screens')
        .collection('views')
        .add({
      'userId': userId,
      'screenName': screenName,
      'params': params,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
```

### Step 2: Analytics Aggregation Cloud Function

**File**: `functions/analytics_functions.js`

```javascript
const functions = require('firebase-functions');
const admin = require('firebase-admin');

// Run every hour to aggregate view counts
exports.aggregatePostViews = functions.pubsub
  .schedule('every 1 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    const today = getDateString(new Date());
    
    // Get all user view buffers from today
    const buffersSnapshot = await db
      .collection('analytics/views/daily')
      .doc(today)
      .collection('users')
      .get();

    // Build post view counts
    const postViews = new Map(); // postId -> { count, uniqueViewers: Set }
    
    buffersSnapshot.forEach((doc) => {
      const data = doc.data();
      const viewedPosts = data.viewedPosts || {};
      
      Object.keys(viewedPosts).forEach((postId) => {
        if (!postViews.has(postId)) {
          postViews.set(postId, { count: 0, viewers: new Set() });
        }
        const entry = postViews.get(postId);
        entry.count++;
        entry.viewers.add(doc.id); // userId
      });
    });

    // Update post documents in batches
    const batch = db.batch();
    let batchCount = 0;

    for (const [postId, data] of postViews) {
      // Need to find which herd this post belongs to
      // In production, you'd have postId->herdId mapping or encode herdId in postId
      
      // For now, assume postId format includes herdId: "herdId_postId"
      const [herdId, actualPostId] = postId.includes('_') 
        ? postId.split('_') 
        : [null, postId];
      
      if (herdId) {
        const postRef = db
          .collection('herdPosts')
          .doc(herdId)
          .collection('posts')
          .doc(actualPostId);

        batch.update(postRef, {
          viewCount: admin.firestore.FieldValue.increment(data.count),
          uniqueViewers: admin.firestore.FieldValue.increment(data.viewers.size),
        });

        batchCount++;
        if (batchCount >= 500) {
          await batch.commit();
          batchCount = 0;
        }
      }
    }

    if (batchCount > 0) {
      await batch.commit();
    }

    console.log(`Aggregated views for ${postViews.size} posts`);
    return null;
  });

// Calculate trending scores daily
exports.calculateTrendingScores = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    const db = admin.firestore();
    
    // Get all herds
    const herdsSnapshot = await db.collection('herds').get();
    
    for (const herdDoc of herdsSnapshot.docs) {
      const herdId = herdDoc.id;
      
      // Get posts from last 7 days
      const weekAgo = new Date();
      weekAgo.setDate(weekAgo.getDate() - 7);
      
      const postsSnapshot = await db
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .where('createdAt', '>=', weekAgo)
        .get();

      const batch = db.batch();
      const trendingPosts = [];

      postsSnapshot.forEach((doc) => {
        const data = doc.data();
        
        // Calculate trending score
        // Formula: (views * 1) + (reactions * 3) + (comments * 5) / age_hours
        const viewCount = data.viewCount || 0;
        const reactionCount = data.engagement?.reactionCount || 0;
        const commentCount = data.engagement?.commentCount || 0;
        
        const ageHours = Math.max(1, 
          (Date.now() - data.createdAt.toDate().getTime()) / (1000 * 60 * 60)
        );
        
        const score = (viewCount + (reactionCount * 3) + (commentCount * 5)) / Math.sqrt(ageHours);
        
        batch.update(doc.ref, {
          trendingScore: score,
          trendingUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });

        trendingPosts.push({ postId: doc.id, score });
      });

      // Sort and get top 10
      trendingPosts.sort((a, b) => b.score - a.score);
      const topPosts = trendingPosts.slice(0, 10);

      // Update herd trending document
      batch.set(
        db.collection('herds').doc(herdId).collection('analytics').doc('trending'),
        {
          topPosts,
          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      await batch.commit();
    }

    return null;
  });

// Extract keywords from new posts (runs on post create)
exports.extractPostKeywords = functions.firestore
  .document('herdPosts/{herdId}/posts/{postId}')
  .onCreate(async (snap, context) => {
    const { herdId, postId } = context.params;
    const data = snap.data();
    const content = data.content || '';

    // Simple keyword extraction (in production, use ML or more sophisticated NLP)
    const keywords = extractKeywords(content);
    
    if (keywords.length > 0) {
      const db = admin.firestore();
      const keywordsRef = db
        .collection('herds')
        .doc(herdId)
        .collection('analytics')
        .doc('keywords');

      // Increment keyword counts
      const updates = {};
      keywords.forEach((word) => {
        updates[`keywords.${word}`] = admin.firestore.FieldValue.increment(1);
      });
      updates.updatedAt = admin.firestore.FieldValue.serverTimestamp();

      await keywordsRef.set(updates, { merge: true });
    }

    return null;
  });

// Helper: Extract keywords from text
function extractKeywords(text) {
  const stopWords = new Set([
    'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for',
    'of', 'with', 'by', 'from', 'is', 'are', 'was', 'were', 'be', 'been',
    'being', 'have', 'has', 'had', 'do', 'does', 'did', 'will', 'would',
    'could', 'should', 'may', 'might', 'must', 'i', 'you', 'he', 'she',
    'it', 'we', 'they', 'what', 'which', 'who', 'when', 'where', 'why', 'how',
    'this', 'that', 'these', 'those', 'just', 'very', 'so', 'too', 'also',
  ]);

  return text
    .toLowerCase()
    .replace(/[^a-z0-9\s]/g, '')
    .split(/\s+/)
    .filter((word) => word.length > 3 && !stopWords.has(word))
    .slice(0, 10); // Max 10 keywords per post
}

function getDateString(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}-${String(date.getDate()).padStart(2, '0')}`;
}
```

### Step 3: Analytics Repository

**File**: `lib/features/analytics/data/repositories/analytics_repository.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class AnalyticsRepository {
  final FirebaseFirestore _firestore;

  AnalyticsRepository(this._firestore);

  /// Get herd analytics for a date range
  Future<HerdAnalytics> getHerdAnalytics(
    String herdId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final start = startDate ?? DateTime.now().subtract(const Duration(days: 7));
    final end = endDate ?? DateTime.now();

    // Get daily analytics documents
    final dailyDocs = <Map<String, dynamic>>[];
    
    for (var date = start; date.isBefore(end); date = date.add(const Duration(days: 1))) {
      final dateStr = _getDateString(date);
      final doc = await _firestore
          .collection('herds')
          .doc(herdId)
          .collection('analytics')
          .doc('daily')
          .collection('dates')
          .doc(dateStr)
          .get();
      
      if (doc.exists) {
        dailyDocs.add({'date': dateStr, ...doc.data()!});
      }
    }

    // Get trending data
    final trendingDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('analytics')
        .doc('trending')
        .get();

    // Get keyword data
    final keywordsDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('analytics')
        .doc('keywords')
        .get();

    return HerdAnalytics(
      herdId: herdId,
      dailyData: dailyDocs,
      topPosts: (trendingDoc.data()?['topPosts'] as List?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      keywords: _parseKeywords(keywordsDoc.data()?['keywords']),
      totalViews: dailyDocs.fold(0, (sum, d) => sum + (d['totalViews'] as int? ?? 0)),
      totalMembers: dailyDocs.isNotEmpty
          ? dailyDocs.last['memberCount'] as int? ?? 0
          : 0,
    );
  }

  /// Get post analytics
  Future<PostAnalytics> getPostAnalytics(
    String herdId,
    String postId,
  ) async {
    final postDoc = await _firestore
        .collection('herdPosts')
        .doc(herdId)
        .collection('posts')
        .doc(postId)
        .get();

    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final data = postDoc.data()!;
    
    return PostAnalytics(
      postId: postId,
      viewCount: data['viewCount'] ?? 0,
      uniqueViewers: data['uniqueViewers'] ?? 0,
      reactionCount: data['engagement']?['reactionCount'] ?? 0,
      commentCount: data['commentCount'] ?? 0,
      shareCount: data['engagement']?['shareCount'] ?? 0,
      trendingScore: data['trendingScore']?.toDouble() ?? 0.0,
    );
  }

  /// Get trending posts for a herd
  Future<List<TrendingPost>> getTrendingPosts(String herdId) async {
    final trendingDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('analytics')
        .doc('trending')
        .get();

    if (!trendingDoc.exists) {
      return [];
    }

    final topPosts = trendingDoc.data()?['topPosts'] as List? ?? [];
    
    return topPosts.map((e) => TrendingPost.fromMap(e)).toList();
  }

  /// Get trending keywords for a herd
  Future<List<KeywordTrend>> getTrendingKeywords(String herdId) async {
    final keywordsDoc = await _firestore
        .collection('herds')
        .doc(herdId)
        .collection('analytics')
        .doc('keywords')
        .get();

    if (!keywordsDoc.exists) {
      return [];
    }

    return _parseKeywords(keywordsDoc.data()?['keywords']);
  }

  List<KeywordTrend> _parseKeywords(Map<String, dynamic>? keywordsMap) {
    if (keywordsMap == null) return [];
    
    final keywords = keywordsMap.entries
        .map((e) => KeywordTrend(word: e.key, count: e.value as int))
        .toList();
    
    keywords.sort((a, b) => b.count.compareTo(a.count));
    return keywords.take(20).toList();
  }

  String _getDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}

// Data classes
class HerdAnalytics {
  final String herdId;
  final List<Map<String, dynamic>> dailyData;
  final List<Map<String, dynamic>> topPosts;
  final List<KeywordTrend> keywords;
  final int totalViews;
  final int totalMembers;

  HerdAnalytics({
    required this.herdId,
    required this.dailyData,
    required this.topPosts,
    required this.keywords,
    required this.totalViews,
    required this.totalMembers,
  });

  double get engagementRate {
    if (totalViews == 0) return 0;
    final totalEngagement = dailyData.fold(0, (sum, d) {
      return sum + 
          (d['commentsCreated'] as int? ?? 0) + 
          (d['reactionsCreated'] as int? ?? 0);
    });
    return totalEngagement / totalViews * 100;
  }
}

class PostAnalytics {
  final String postId;
  final int viewCount;
  final int uniqueViewers;
  final int reactionCount;
  final int commentCount;
  final int shareCount;
  final double trendingScore;

  PostAnalytics({
    required this.postId,
    required this.viewCount,
    required this.uniqueViewers,
    required this.reactionCount,
    required this.commentCount,
    required this.shareCount,
    required this.trendingScore,
  });

  double get engagementRate {
    if (viewCount == 0) return 0;
    return (reactionCount + commentCount + shareCount) / viewCount * 100;
  }
}

class TrendingPost {
  final String postId;
  final double score;
  final int viewCount;
  final int engagementCount;

  TrendingPost({
    required this.postId,
    required this.score,
    this.viewCount = 0,
    this.engagementCount = 0,
  });

  factory TrendingPost.fromMap(Map<String, dynamic> map) {
    return TrendingPost(
      postId: map['postId'],
      score: (map['score'] ?? 0).toDouble(),
      viewCount: map['viewCount'] ?? 0,
      engagementCount: map['engagementCount'] ?? 0,
    );
  }
}

class KeywordTrend {
  final String word;
  final int count;
  final String trend; // 'up', 'down', 'stable'

  KeywordTrend({
    required this.word,
    required this.count,
    this.trend = 'stable',
  });
}
```

### Step 4: Analytics Providers

**File**: `lib/features/analytics/view/providers/analytics_providers.dart`

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/analytics_repository.dart';
import '../../data/services/view_tracking_service.dart';
import '../../../user/auth/view/providers/auth_provider.dart';

part 'analytics_providers.g.dart';

@riverpod
AnalyticsRepository analyticsRepository(Ref ref) {
  return AnalyticsRepository(FirebaseFirestore.instance);
}

@riverpod
ViewTrackingService viewTrackingService(Ref ref) {
  return ViewTrackingService(FirebaseFirestore.instance);
}

/// Herd analytics with optional date range
@riverpod
Future<HerdAnalytics> herdAnalytics(
  Ref ref,
  String herdId, {
  DateTime? startDate,
  DateTime? endDate,
}) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getHerdAnalytics(
    herdId,
    startDate: startDate,
    endDate: endDate,
  );
}

/// Post analytics
@riverpod
Future<PostAnalytics> postAnalytics(
  Ref ref,
  String herdId,
  String postId,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getPostAnalytics(herdId, postId);
}

/// Trending posts for a herd
@riverpod
Future<List<TrendingPost>> trendingPosts(
  Ref ref,
  String herdId,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getTrendingPosts(herdId);
}

/// Trending keywords for a herd
@riverpod
Future<List<KeywordTrend>> trendingKeywords(
  Ref ref,
  String herdId,
) async {
  final repo = ref.watch(analyticsRepositoryProvider);
  return repo.getTrendingKeywords(herdId);
}

/// Track post view (call when post becomes visible)
@riverpod
class PostViewTracker extends _$PostViewTracker {
  @override
  void build() {}

  Future<void> trackView(String herdId, String postId) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    final service = ref.read(viewTrackingServiceProvider);
    await service.trackPostView(
      userId: user.uid,
      herdId: herdId,
      postId: postId,
    );
  }
}
```

### Step 5: Analytics Dashboard Screen

**File**: `lib/features/analytics/view/screens/analytics_dashboard_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/analytics_providers.dart';

class AnalyticsDashboardScreen extends ConsumerWidget {
  final String herdId;

  const AnalyticsDashboardScreen({super.key, required this.herdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analytics = ref.watch(herdAnalyticsProvider(herdId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: () => _showDateRangePicker(context, ref),
          ),
        ],
      ),
      body: analytics.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (data) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(herdAnalyticsProvider(herdId));
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(data),
                const SizedBox(height: 24),
                _buildTrendingSection(context, ref),
                const SizedBox(height: 24),
                _buildKeywordsSection(ref),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards(HerdAnalytics data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _StatCard(
          title: 'Total Views',
          value: _formatNumber(data.totalViews),
          icon: Icons.visibility,
          color: Colors.blue,
        ),
        _StatCard(
          title: 'Members',
          value: _formatNumber(data.totalMembers),
          icon: Icons.people,
          color: Colors.green,
        ),
        _StatCard(
          title: 'Engagement Rate',
          value: '${data.engagementRate.toStringAsFixed(1)}%',
          icon: Icons.trending_up,
          color: Colors.orange,
        ),
        _StatCard(
          title: 'Posts (7d)',
          value: _formatNumber(
            data.dailyData.fold(0, (sum, d) => sum + (d['postsCreated'] as int? ?? 0)),
          ),
          icon: Icons.article,
          color: Colors.purple,
        ),
      ],
    );
  }

  Widget _buildTrendingSection(BuildContext context, WidgetRef ref) {
    final trending = ref.watch(trendingPostsProvider(herdId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trending Posts',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        trending.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error loading trending: $e'),
          data: (posts) {
            if (posts.isEmpty) {
              return const Text('No trending posts yet');
            }
            return Column(
              children: posts.take(5).map((post) {
                return ListTile(
                  leading: CircleAvatar(
                    child: Text('#${posts.indexOf(post) + 1}'),
                  ),
                  title: Text('Post ${post.postId.substring(0, 8)}...'),
                  subtitle: Text('Score: ${post.score.toStringAsFixed(1)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.visibility, size: 16),
                      const SizedBox(width: 4),
                      Text('${post.viewCount}'),
                    ],
                  ),
                  onTap: () {
                    // Navigate to post
                  },
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildKeywordsSection(WidgetRef ref) {
    final keywords = ref.watch(trendingKeywordsProvider(herdId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trending Keywords',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        keywords.when(
          loading: () => const CircularProgressIndicator(),
          error: (e, _) => Text('Error loading keywords: $e'),
          data: (words) {
            if (words.isEmpty) {
              return const Text('No keyword data yet');
            }
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: words.take(15).map((kw) {
                // Size chip based on count
                final fontSize = 12.0 + (kw.count / words.first.count) * 8;
                return Chip(
                  label: Text(
                    '${kw.word} (${kw.count})',
                    style: TextStyle(fontSize: fontSize),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  void _showDateRangePicker(BuildContext context, WidgetRef ref) {
    // TODO: Implement date range picker
  }

  String _formatNumber(int num) {
    if (num >= 1000000) {
      return '${(num / 1000000).toStringAsFixed(1)}M';
    }
    if (num >= 1000) {
      return '${(num / 1000).toStringAsFixed(1)}K';
    }
    return num.toString();
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 6: Integration - Track Views in Post Card

```dart
// In PostCard widget
class PostCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Track view when post becomes visible
    useEffect(() {
      ref.read(postViewTrackerProvider.notifier).trackView(herdId, postId);
      return null;
    }, [postId]);
    
    // ... rest of build
  }
}
```

---

## Cost Optimization Summary

1. **View Tracking**: Batched writes reduce 1000 views → ~50 writes
2. **Aggregation**: Cloud Functions run hourly, not per-view
3. **Dashboard**: Single document read for daily stats
4. **Keywords**: Incremental update on post create
5. **Trending**: Calculated daily, cached in document

---

## Testing Checklist

- [ ] Post views tracked with debouncing
- [ ] Views aggregated correctly by Cloud Function
- [ ] Trending score calculated correctly
- [ ] Keywords extracted from post content
- [ ] Analytics dashboard loads quickly
- [ ] Date range filtering works
- [ ] Real-time updates when data changes

---

## Success Criteria

1. Dashboard loads in < 2 seconds
2. Max 5 Firestore reads for full analytics page
3. View tracking doesn't impact post load time
4. Trending reflects actual engagement
5. Keywords surface popular topics

---

## Estimated Effort

- **View Tracking Service**: 3-4 hours
- **Cloud Functions**: 4-5 hours
- **Repository & Providers**: 3-4 hours
- **Dashboard UI**: 5-6 hours
- **Testing**: 3-4 hours
- **Total**: ~20-25 hours
