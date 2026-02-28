import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

import 'local_cache_service.dart';

/// Service responsible for caching and retrieving post/feed data.
///
/// Previously used File I/O + SharedPreferences (mobile-only). Now backed by
/// [LocalCacheService] (Hive), which works on both mobile and web.
class DataCacheService {
  static final DataCacheService _instance = DataCacheService._internal();
  factory DataCacheService() => _instance;
  DataCacheService._internal();

  // In-memory cache — avoids repeated Hive reads within the same session
  final Map<String, PostModel> _postCache = {};
  final Map<String, List<String>> _feedCache = {};

  bool _initialized = false;

  // Configurable limits (updated by CacheManager from SharedPreferences)
  int maxCacheEntries = 500;
  Duration maxCacheAge = const Duration(days: 7);

  // ─────────────────────────────────────────────────────────────────────────
  // Initialization
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      await LocalCacheService.initialize();
      await _loadCacheMetadata();
      await _cleanupCacheIfNeeded();
      _initialized = true;
      debugPrint('DataCacheService initialized');
    } catch (e) {
      debugPrint('Error initializing DataCacheService: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cache key generation
  // ─────────────────────────────────────────────────────────────────────────

  String _generatePostKey(String postId, bool isAlt) =>
      'post_${isAlt ? 'alt' : 'public'}_$postId';

  String _generateFeedKey(String userId,
      {bool isAlt = false, String? herdId}) {
    final type = herdId != null ? 'herd' : (isAlt ? 'alt' : 'public');
    final herdSuffix = herdId != null ? '_$herdId' : '';
    return 'feed_${type}_$userId$herdSuffix';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Write operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> cachePost(PostModel post) async {
    if (!_initialized) await initialize();
    try {
      final key = _generatePostKey(post.id, post.isAlt);
      _postCache[key] = post;

      final encodableMap =
          _convertTimestampsForEncoding(post.toMap()) as Map<String, dynamic>;
      await LocalCacheService().putPost(key, jsonEncode(encodableMap));

      _logCacheOperation('stored', post.id);
    } catch (e) {
      _logCacheOperation('write error', post.id, success: false);
      debugPrint('Error caching post: $e');
    }
  }

  Future<void> cacheFeed(
    List<PostModel> posts,
    String userId, {
    bool isAlt = false,
    String? herdId,
  }) async {
    if (!_initialized) await initialize();
    try {
      for (final post in posts) {
        await cachePost(post);
      }

      final feedKey = _generateFeedKey(userId, isAlt: isAlt, herdId: herdId);
      final postIds = posts.map((p) => p.id).toList();

      _feedCache[feedKey] = postIds;
      await LocalCacheService().putFeed(feedKey, jsonEncode(postIds));

      debugPrint('Cached feed for user $userId with ${posts.length} posts');
    } catch (e) {
      debugPrint('Error caching feed: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Read operations
  // ─────────────────────────────────────────────────────────────────────────

  Future<PostModel?> getPost(String postId, {bool isAlt = false}) async {
    if (!_initialized) await initialize();
    try {
      final key = _generatePostKey(postId, isAlt);

      if (_postCache.containsKey(key)) {
        _logCacheOperation('hit', postId);
        return _postCache[key];
      }

      final jsonData = LocalCacheService().getPostJson(key);
      if (jsonData != null) {
        try {
          final decoded = jsonDecode(jsonData);
          final withTimestamps = _convertTimestampsAfterDecoding(decoded);
          if (withTimestamps is Map<String, dynamic>) {
            final post = PostModel.fromMap(postId, withTimestamps);
            _postCache[key] = post;
            _logCacheOperation('loaded from disk', postId);
            return post;
          }
        } catch (e) {
          _logCacheOperation('read error', postId, success: false);
          debugPrint('Error reading cached post $postId: $e');
          await LocalCacheService().deletePost(key);
        }
      } else {
        _logCacheOperation('not found', postId, success: false);
      }
      return null;
    } catch (e) {
      debugPrint('Error getting cached post: $e');
      return null;
    }
  }

  Future<List<PostModel>> getFeed(
    String userId, {
    bool isAlt = false,
    String? herdId,
  }) async {
    if (!_initialized) await initialize();
    try {
      final feedKey = _generateFeedKey(userId, isAlt: isAlt, herdId: herdId);

      List<String>? postIds = _feedCache[feedKey];

      if (postIds == null) {
        final jsonData = LocalCacheService().getFeedJson(feedKey);
        if (jsonData != null) {
          postIds = List<String>.from(jsonDecode(jsonData) as List);
          _feedCache[feedKey] = postIds;
        }
      }

      if (postIds == null || postIds.isEmpty) return [];

      final posts = <PostModel>[];
      for (final postId in postIds) {
        final post = await getPost(postId, isAlt: isAlt);
        if (post != null) posts.add(post);
      }
      return posts;
    } catch (e) {
      debugPrint('Error getting cached feed: $e');
      return [];
    }
  }

  Future<bool> hasPost(String postId, {bool isAlt = false}) async {
    if (!_initialized) await initialize();
    final key = _generatePostKey(postId, isAlt);
    if (_postCache.containsKey(key)) return true;
    return LocalCacheService().getPostJson(key) != null;
  }

  Future<bool> hasFeed(
    String userId, {
    bool isAlt = false,
    String? herdId,
  }) async {
    if (!_initialized) await initialize();
    final key = _generateFeedKey(userId, isAlt: isAlt, herdId: herdId);
    if (_feedCache.containsKey(key)) return true;
    return LocalCacheService().getFeedJson(key) != null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Startup loading
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadCacheMetadata() async {
    try {
      final cache = LocalCacheService();

      // Load all posts into the in-memory map
      for (final cacheKey in cache.allPostCacheKeys) {
        final jsonData = cache.getPostJson(cacheKey);
        if (jsonData == null) continue;
        try {
          final decoded = jsonDecode(jsonData);
          final withTimestamps = _convertTimestampsAfterDecoding(decoded);
          if (withTimestamps is! Map<String, dynamic>) continue;

          // Derive postId from the key format:
          // 'post_alt_<id>' or 'post_public_<id>'
          String? postId;
          if (cacheKey.startsWith('post_alt_')) {
            postId = cacheKey.substring('post_alt_'.length);
          } else if (cacheKey.startsWith('post_public_')) {
            postId = cacheKey.substring('post_public_'.length);
          }

          if (postId != null) {
            final post = PostModel.fromMap(postId, withTimestamps);
            _postCache[cacheKey] = post;
          }
        } catch (e) {
          debugPrint('Invalid post cache entry $cacheKey, removing: $e');
          await cache.deletePost(cacheKey);
        }
      }

      // Load all feed ID lists into the in-memory map
      for (final feedKey in cache.allFeedCacheKeys) {
        final jsonData = cache.getFeedJson(feedKey);
        if (jsonData == null) continue;
        try {
          final postIds = List<String>.from(jsonDecode(jsonData) as List);
          _feedCache[feedKey] = postIds;
        } catch (e) {
          debugPrint('Invalid feed cache entry $feedKey, removing: $e');
          await cache.deleteFeed(feedKey);
        }
      }

      debugPrint('DataCacheService: loaded ${_postCache.length} posts and '
          '${_feedCache.length} feeds into memory');
    } catch (e) {
      debugPrint('Error loading cache metadata: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _cleanupCacheIfNeeded() async {
    try {
      final cache = LocalCacheService();
      final now = DateTime.now();

      // Remove age-expired posts
      final postKeys = cache.allPostCacheKeys.toList();
      int removed = 0;
      for (final key in postKeys) {
        final ts = cache.getPostTimestamp(key);
        if (ts != null && now.difference(ts) > maxCacheAge) {
          await _deletePost(key);
          removed++;
        }
      }

      // Enforce max entry count — delete the oldest entries beyond the limit
      final remaining = cache.allPostCacheKeys.toList();
      final halfMax = maxCacheEntries ~/ 2;
      if (remaining.length > halfMax) {
        remaining.sort((a, b) {
          final tsA =
              cache.getPostTimestamp(a)?.millisecondsSinceEpoch ?? 0;
          final tsB =
              cache.getPostTimestamp(b)?.millisecondsSinceEpoch ?? 0;
          return tsA.compareTo(tsB);
        });
        for (final key in remaining.take(remaining.length - halfMax)) {
          await _deletePost(key);
          removed++;
        }
      }

      if (removed > 0) {
        debugPrint('DataCacheService cleanup: removed $removed entries');
      }
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  Future<void> _deletePost(String key) async {
    _postCache.remove(key);
    await LocalCacheService().deletePost(key);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Clear everything
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> clearCache() async {
    if (!_initialized) await initialize();
    _postCache.clear();
    _feedCache.clear();
    await LocalCacheService().clearAll();
    debugPrint('DataCacheService: cache cleared');
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Stats
  // ─────────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> getCacheStats() async {
    if (!_initialized) await initialize();
    final cache = LocalCacheService();
    return {
      'postCount': cache.postCount,
      'feedCount': cache.feedCount,
      'totalCount': cache.postCount + cache.feedCount,
      'inMemoryPostCacheSize': _postCache.length,
      'inMemoryFeedCacheSize': _feedCache.length,
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Timestamp serialization helpers
  // ─────────────────────────────────────────────────────────────────────────

  dynamic _convertTimestampsForEncoding(dynamic item) {
    if (item is Map<String, dynamic>) {
      return item
          .map((k, v) => MapEntry(k, _convertTimestampsForEncoding(v)));
    } else if (item is List) {
      return item.map(_convertTimestampsForEncoding).toList();
    } else if (item is Timestamp) {
      return {'_isTimestamp': true, 'value': item.millisecondsSinceEpoch};
    } else if (item is FieldValue) {
      return {'_isFieldValue': true, 'type': item.runtimeType.toString()};
    }
    return item;
  }

  dynamic _convertTimestampsAfterDecoding(dynamic item) {
    if (item is Map<String, dynamic>) {
      if (item['_isTimestamp'] == true && item.containsKey('value')) {
        return Timestamp.fromMillisecondsSinceEpoch(item['value'] as int);
      }
      return item
          .map((k, v) => MapEntry(k, _convertTimestampsAfterDecoding(v)));
    } else if (item is List) {
      return item.map(_convertTimestampsAfterDecoding).toList();
    }
    return item;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Logging
  // ─────────────────────────────────────────────────────────────────────────

  void _logCacheOperation(String operation, String postId,
      {bool success = true}) {
    final status = success ? '✅' : '❌';
    debugPrint('$status Cache $operation: $postId');
  }
}
