import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Cross-platform local cache backed by Hive.
///
/// Uses IndexedDB on web, and files on mobile/desktop — no kIsWeb guards
/// needed anywhere in the app. All other cache services use this as their
/// storage backend instead of File I/O or SharedPreferences.
class LocalCacheService {
  static const String _feedBoxName = 'herd_feeds';
  static const String _metaBoxName = 'herd_meta';
  static const String _interactionBoxName = 'herd_interactions';
  static const String _trendingBoxName = 'herd_trending';

  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  static bool _initialized = false;
  static Future<void>? _initFuture;

  /// Initialize Hive and open all boxes. Safe to call multiple times —
  /// subsequent calls are no-ops.
  static Future<void> initialize() {
    _initFuture ??= _doInitialize();
    return _initFuture!;
  }

  static Future<void> _doInitialize() async {
    if (_initialized) return;
    try {
      await Hive.initFlutter();
      await Hive.openBox(_feedBoxName);
      await Hive.openBox(_metaBoxName);
      await Hive.openBox(_interactionBoxName);
      await Hive.openBox(_trendingBoxName);
      _initialized = true;
      debugPrint('LocalCacheService initialized (platform: ${kIsWeb ? 'web/IndexedDB' : 'native/file'})');
    } catch (e) {
      debugPrint('LocalCacheService init error: $e');
      rethrow;
    }
  }

  Box get _feedBox => Hive.box(_feedBoxName);
  Box get _metaBox => Hive.box(_metaBoxName);
  Box get _interactionBox => Hive.box(_interactionBoxName);
  Box get _trendingBox => Hive.box(_trendingBoxName);

  // ─────────────────────────────────────────────────────────────────────────
  // Post storage
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> putPost(String cacheKey, String jsonData) async {
    await _feedBox.put('post:$cacheKey', jsonData);
    await _metaBox.put('post_ts:$cacheKey', DateTime.now().millisecondsSinceEpoch);
  }

  String? getPostJson(String cacheKey) =>
      _feedBox.get('post:$cacheKey') as String?;

  DateTime? getPostTimestamp(String cacheKey) {
    final ms = _metaBox.get('post_ts:$cacheKey') as int?;
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> deletePost(String cacheKey) async {
    await _feedBox.delete('post:$cacheKey');
    await _metaBox.delete('post_ts:$cacheKey');
  }

  /// All stored post cache keys (without the 'post:' prefix).
  Iterable<String> get allPostCacheKeys => _feedBox.keys
      .whereType<String>()
      .where((k) => k.startsWith('post:'))
      .map((k) => k.substring(5));

  // ─────────────────────────────────────────────────────────────────────────
  // Feed storage (stores JSON-encoded List<String> of post IDs)
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> putFeed(String feedKey, String jsonData) async {
    await _feedBox.put('feed:$feedKey', jsonData);
    await _metaBox.put('feed_ts:$feedKey', DateTime.now().millisecondsSinceEpoch);
  }

  String? getFeedJson(String feedKey) =>
      _feedBox.get('feed:$feedKey') as String?;

  DateTime? getFeedTimestamp(String feedKey) {
    final ms = _metaBox.get('feed_ts:$feedKey') as int?;
    return ms != null ? DateTime.fromMillisecondsSinceEpoch(ms) : null;
  }

  Future<void> deleteFeed(String feedKey) async {
    await _feedBox.delete('feed:$feedKey');
    await _metaBox.delete('feed_ts:$feedKey');
  }

  /// All stored feed cache keys (without the 'feed:' prefix).
  Iterable<String> get allFeedCacheKeys => _feedBox.keys
      .whereType<String>()
      .where((k) => k.startsWith('feed:'))
      .map((k) => k.substring(5));

  // ─────────────────────────────────────────────────────────────────────────
  // Interaction state storage
  //
  // Caches isLiked/isDisliked/counts per postId so PostInteractionsWithPrivacy
  // can skip Firestore reads on subsequent sessions.
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveInteraction(String postId, Map<String, dynamic> data) async {
    await _interactionBox.put(postId, jsonEncode({
      ...data,
      'cachedAt': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  /// Returns cached interaction data, or null if missing or older than [maxAge].
  Map<String, dynamic>? getInteraction(
    String postId, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    final raw = _interactionBox.get(postId) as String?;
    if (raw == null) return null;
    try {
      final data = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final cachedAt = data['cachedAt'] as int?;
      if (cachedAt != null) {
        final age = DateTime.now()
            .difference(DateTime.fromMillisecondsSinceEpoch(cachedAt));
        if (age > maxAge) return null;
      }
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> deleteInteraction(String postId) async {
    await _interactionBox.delete(postId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Trending posts storage
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> saveTrending(String key, String jsonData) async {
    await _trendingBox.put(key, jsonData);
    await _metaBox.put('trending_ts:$key', DateTime.now().millisecondsSinceEpoch);
  }

  /// Returns the trending JSON, or null if missing or older than [maxAge].
  String? getTrendingJson(
    String key, {
    Duration maxAge = const Duration(minutes: 30),
  }) {
    final ms = _metaBox.get('trending_ts:$key') as int?;
    if (ms == null) return null;
    final age = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (age > maxAge) return null;
    return _trendingBox.get(key) as String?;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats and maintenance
  // ─────────────────────────────────────────────────────────────────────────

  int get postCount => allPostCacheKeys.length;
  int get feedCount => allFeedCacheKeys.length;

  Future<void> clearAll() async {
    await _feedBox.clear();
    await _metaBox.clear();
    await _interactionBox.clear();
    await _trendingBox.clear();
    debugPrint('LocalCacheService: all boxes cleared');
  }
}
