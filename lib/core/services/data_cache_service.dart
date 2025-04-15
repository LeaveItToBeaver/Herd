// lib/core/services/data_cache_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for caching and retrieving post/feed data
/// Complements MediaCacheService which handles media files
class DataCacheService {
  static final DataCacheService _instance = DataCacheService._internal();
  factory DataCacheService() => _instance;

  // Private constructor
  DataCacheService._internal();

  // Cache directory for JSON data
  Directory? _cacheDir;
  Directory? _postDir;
  Directory? _feedDir;

  // In-memory cache
  final Map<String, PostModel> _postCache = {};
  final Map<String, List<String>> _feedCache = {}; // List of post IDs in feed

  // Flag to track initialization
  bool _initialized = false;

  // Cache settings (will be updated from CacheManager)
  int maxCacheEntries = 500;
  Duration maxCacheAge = const Duration(days: 7);

  /// Initialize the cache service
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      // Get appropriate cache directory
      _cacheDir = await getApplicationDocumentsDirectory();
      final cachePath = _cacheDir!.path;

      // Create subdirectories for different data types
      _postDir = Directory('$cachePath/data_cache/posts');
      _feedDir = Directory('$cachePath/data_cache/feeds');

      await _postDir!.create(recursive: true);
      await _feedDir!.create(recursive: true);

      // Load cache metadata from shared preferences
      await _loadCacheMetadata();

      // Cleanup old cache entries
      await _cleanupCacheIfNeeded();

      _initialized = true;
      debugPrint('DataCacheService initialized');
    } catch (e) {
      debugPrint('Error initializing DataCacheService: $e');
    }
  }

  /// Generate a unique cache key for a post or feed
  String _generatePostKey(String postId, bool isAlt) {
    return 'post_${isAlt ? 'alt' : 'public'}_$postId';
  }

  String _generateFeedKey(String userId, {bool isAlt = false, String? herdId}) {
    final prefix = 'feed';
    final type = herdId != null ? 'herd' : (isAlt ? 'alt' : 'public');
    final herdSuffix = herdId != null ? '_$herdId' : '';
    return '${prefix}_${type}_${userId}$herdSuffix';
  }

  /// Cache a post
  Future<void> cachePost(PostModel post) async {
    if (!_initialized) await initialize();

    try {
      final key = _generatePostKey(post.id, post.isAlt);

      // Save to in-memory cache
      _postCache[key] = post;

      // Save to disk - Sanitize the map before encoding
      final Map<String, dynamic> sanitizedMap =
          _sanitizeFieldValues(post.toMap());
      final jsonData = jsonEncode(sanitizedMap);
      final file = File('${_postDir!.path}/$key.json');
      await file.writeAsBytes(utf8.encode(jsonData));

      // Update metadata
      await _savePostMetadata(key, post.id, post.isAlt);

      debugPrint('✅ Cached post ${post.id}');
    } catch (e) {
      debugPrint('❌ Error caching post: $e');
    }
  }

  /// Sanitize Firestore FieldValue objects from a map for JSON serialization
  Map<String, dynamic> _sanitizeFieldValues(Map<String, dynamic> map) {
    final result = <String, dynamic>{};

    for (final entry in map.entries) {
      if (entry.value is Map<String, dynamic>) {
        // Recursively handle nested maps
        result[entry.key] = _sanitizeFieldValues(entry.value);
      } else if (entry.value.toString().contains('FieldValue')) {
        // Convert FieldValue to current timestamp
        if (entry.key == 'createdAt' || entry.key == 'updatedAt') {
          result[entry.key] = DateTime.now().millisecondsSinceEpoch;
        } else {
          // For other FieldValues like increment/decrement, use a default
          result[entry.key] = 0;
        }
      } else if (entry.value is List) {
        // Handle lists (including lists of maps)
        final list = entry.value as List;
        final sanitizedList = <dynamic>[];

        for (final item in list) {
          if (item is Map<String, dynamic>) {
            sanitizedList.add(_sanitizeFieldValues(item));
          } else if (item.toString().contains('FieldValue')) {
            // Skip or use default for FieldValue in lists
            sanitizedList.add(null);
          } else {
            sanitizedList.add(item);
          }
        }

        result[entry.key] = sanitizedList;
      } else {
        // Direct assignment for regular values
        result[entry.key] = entry.value;
      }
    }

    return result;
  }

  /// Cache a feed (list of posts)]
  Future<void> cacheFeed(List<PostModel> posts, String userId,
      {bool isAlt = false, String? herdId}) async {
    if (!_initialized) await initialize();

    try {
      // Cache each post individually first
      for (final post in posts) {
        await cachePost(post);
      }

      // Generate feed key
      final feedKey = _generateFeedKey(userId, isAlt: isAlt, herdId: herdId);

      // Extract post IDs
      final postIds = posts.map((post) => post.id).toList();

      // Save to in-memory cache
      _feedCache[feedKey] = postIds;

      // Save to disk
      final jsonData = jsonEncode(postIds);
      final file = File('${_feedDir!.path}/$feedKey.json');
      await file.writeAsBytes(utf8.encode(jsonData));

      // Update metadata
      await _saveFeedMetadata(feedKey, userId, isAlt, herdId);

      debugPrint('✅ Cached feed for user $userId with ${posts.length} posts');
    } catch (e) {
      debugPrint('❌ Error caching feed: $e');
    }
  }

  /// Get a post from cache
  Future<PostModel?> getPost(String postId, {bool isAlt = false}) async {
    if (!_initialized) await initialize();

    try {
      final key = _generatePostKey(postId, isAlt);

      // Check memory cache first
      if (_postCache.containsKey(key)) {
        await _updateLastAccessed(key, isPost: true);
        return _postCache[key];
      }

      // Check disk cache
      final file = File('${_postDir!.path}/$key.json');
      if (await file.exists()) {
        final jsonData = await file.readAsString();
        final Map<String, dynamic> map = jsonDecode(jsonData);
        final post = PostModel.fromMap(postId, map);

        // Update memory cache
        _postCache[key] = post;

        // Update last accessed
        await _updateLastAccessed(key, isPost: true);

        return post;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting cached post: $e');
      return null;
    }
  }

  /// Get a feed from cache
  Future<List<PostModel>> getFeed(String userId,
      {bool isAlt = false, String? herdId}) async {
    if (!_initialized) await initialize();

    try {
      final feedKey = _generateFeedKey(userId, isAlt: isAlt, herdId: herdId);

      // Get post IDs from cache
      List<String>? postIds;

      // Check memory cache first
      if (_feedCache.containsKey(feedKey)) {
        postIds = _feedCache[feedKey];
      } else {
        // Check disk cache
        final file = File('${_feedDir!.path}/$feedKey.json');
        if (await file.exists()) {
          final jsonData = await file.readAsString();
          postIds = List<String>.from(jsonDecode(jsonData));

          // Update memory cache
          _feedCache[feedKey] = postIds;
        }
      }

      if (postIds == null || postIds.isEmpty) {
        return [];
      }

      // Update last accessed
      await _updateLastAccessed(feedKey, isPost: false);

      // Fetch each post
      final posts = <PostModel>[];
      for (final postId in postIds) {
        final post = await getPost(postId, isAlt: isAlt);
        if (post != null) {
          posts.add(post);
        }
      }

      return posts;
    } catch (e) {
      debugPrint('Error getting cached feed: $e');
      return [];
    }
  }

  /// Check if a post exists in cache
  Future<bool> hasPost(String postId, {bool isAlt = false}) async {
    if (!_initialized) await initialize();

    final key = _generatePostKey(postId, isAlt);

    // Check memory cache first
    if (_postCache.containsKey(key)) {
      return true;
    }

    // Check disk cache
    final file = File('${_postDir!.path}/$key.json');
    return await file.exists();
  }

  /// Check if a feed exists in cache
  Future<bool> hasFeed(String userId,
      {bool isAlt = false, String? herdId}) async {
    if (!_initialized) await initialize();

    final key = _generateFeedKey(userId, isAlt: isAlt, herdId: herdId);

    // Check memory cache first
    if (_feedCache.containsKey(key)) {
      return true;
    }

    // Check disk cache
    final file = File('${_feedDir!.path}/$key.json');
    return await file.exists();
  }

  /// Save post metadata
  Future<void> _savePostMetadata(String key, String postId, bool isAlt) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create metadata
      final metadata = {
        'key': key,
        'postId': postId,
        'isAlt': isAlt,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'lastAccessed': DateTime.now().millisecondsSinceEpoch,
      };

      // Save to shared preferences
      await prefs.setString('data_cache_post_$key', jsonEncode(metadata));

      // Add to LRU list
      final postAccessList =
          prefs.getStringList('data_cache_post_access_list') ?? [];
      if (postAccessList.contains(key)) {
        postAccessList.remove(key);
      }
      postAccessList.add(key); // Add to end (most recently used)
      await prefs.setStringList('data_cache_post_access_list', postAccessList);
    } catch (e) {
      debugPrint('Error saving post metadata: $e');
    }
  }

  /// Save feed metadata
  Future<void> _saveFeedMetadata(
      String key, String userId, bool isAlt, String? herdId) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create metadata
      final metadata = {
        'key': key,
        'userId': userId,
        'isAlt': isAlt,
        'herdId': herdId,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'lastAccessed': DateTime.now().millisecondsSinceEpoch,
      };

      // Save to shared preferences
      await prefs.setString('data_cache_feed_$key', jsonEncode(metadata));

      // Add to LRU list
      final feedAccessList =
          prefs.getStringList('data_cache_feed_access_list') ?? [];
      if (feedAccessList.contains(key)) {
        feedAccessList.remove(key);
      }
      feedAccessList.add(key); // Add to end (most recently used)
      await prefs.setStringList('data_cache_feed_access_list', feedAccessList);
    } catch (e) {
      debugPrint('Error saving feed metadata: $e');
    }
  }

  /// Update last accessed time
  Future<void> _updateLastAccessed(String key, {required bool isPost}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metadataKey =
          isPost ? 'data_cache_post_$key' : 'data_cache_feed_$key';
      final accessListKey = isPost
          ? 'data_cache_post_access_list'
          : 'data_cache_feed_access_list';

      // Get existing metadata
      final jsonData = prefs.getString(metadataKey);
      if (jsonData != null) {
        try {
          final metadata = jsonDecode(jsonData) as Map<String, dynamic>;

          // Update last accessed time
          metadata['lastAccessed'] = DateTime.now().millisecondsSinceEpoch;

          // Save updated metadata
          await prefs.setString(metadataKey, jsonEncode(metadata));

          // Update access list for LRU
          try {
            final accessList = prefs.getStringList(accessListKey) ?? [];
            if (accessList.contains(key)) {
              accessList.remove(key);
            }
            accessList.add(key); // Add to end (most recently used)
            await prefs.setStringList(accessListKey, accessList);
          } catch (e) {
            // If there's an error with access list, reset it
            debugPrint('Error updating access list: $e');
            await prefs.remove(accessListKey);
            await prefs.setStringList(accessListKey, [key]);
          }
        } catch (e) {
          debugPrint('Error updating metadata: $e');
        }
      }
    } catch (e) {
      debugPrint('Error updating last accessed time: $e');
    }
  }

  /// Load cache metadata from shared preferences
  Future<void> _loadCacheMetadata() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Reset problematic access lists if needed
      bool resetPostAccessList = false;
      bool resetFeedAccessList = false;

      try {
        final postAccessList =
            prefs.getStringList('data_cache_post_access_list');
        debugPrint('Found ${postAccessList?.length ?? 0} posts in access list');
      } catch (e) {
        debugPrint('⚠️ Error reading post access list: $e');
        resetPostAccessList = true;
      }

      try {
        final feedAccessList =
            prefs.getStringList('data_cache_feed_access_list');
        debugPrint('Found ${feedAccessList?.length ?? 0} feeds in access list');
      } catch (e) {
        debugPrint('⚠️ Error reading feed access list: $e');
        resetFeedAccessList = true;
      }

      // Reset problematic access lists
      if (resetPostAccessList) {
        await prefs.remove('data_cache_post_access_list');
        await prefs.setStringList('data_cache_post_access_list', []);
        debugPrint('✅ Reset post access list');
      }

      if (resetFeedAccessList) {
        await prefs.remove('data_cache_feed_access_list');
        await prefs.setStringList('data_cache_feed_access_list', []);
        debugPrint('✅ Reset feed access list');
      }

      // Load post metadata with better error handling
      final allKeys = prefs.getKeys();
      final postKeys =
          allKeys.where((key) => key.startsWith('data_cache_post_')).toList();

      for (final key in postKeys) {
        if (key == 'data_cache_post_access_list')
          continue; // Skip the access list key

        try {
          final jsonData = prefs.getString(key);
          if (jsonData != null) {
            try {
              final metadata = jsonDecode(jsonData) as Map<String, dynamic>;
              final cacheKey = metadata['key'] as String;
              final postId = metadata['postId'] as String;
              final isAlt = metadata['isAlt'] as bool;

              // Try to load from disk
              final file = File('${_postDir!.path}/$cacheKey.json');
              if (await file.exists()) {
                final jsonData = await file.readAsString();
                final Map<String, dynamic> map = jsonDecode(jsonData);
                try {
                  final post = PostModel.fromMap(postId, map);
                  // Add to memory cache
                  _postCache[cacheKey] = post;
                } catch (e) {
                  debugPrint('Invalid post data for $postId: $e');
                  // Delete invalid cache files
                  await file.delete();
                  await prefs.remove(key);
                }
              }
            } catch (e) {
              // Skip invalid entries
              debugPrint('Invalid post metadata entry: $e');
              await prefs.remove(key);
            }
          }
        } catch (e) {
          debugPrint('Error processing post metadata key $key: $e');
          await prefs.remove(key);
        }
      }

      // Load feed metadata with better error handling
      final feedKeys =
          allKeys.where((key) => key.startsWith('data_cache_feed_')).toList();

      for (final key in feedKeys) {
        if (key == 'data_cache_feed_access_list')
          continue; // Skip the access list key

        try {
          final jsonData = prefs.getString(key);
          if (jsonData != null) {
            try {
              final metadata = jsonDecode(jsonData) as Map<String, dynamic>;
              final cacheKey = metadata['key'] as String;

              // Try to load from disk
              final file = File('${_feedDir!.path}/$cacheKey.json');
              if (await file.exists()) {
                final jsonData = await file.readAsString();
                try {
                  final postIds = List<String>.from(jsonDecode(jsonData));
                  // Add to memory cache
                  _feedCache[cacheKey] = postIds;
                } catch (e) {
                  debugPrint('Invalid feed data for $cacheKey: $e');
                  // Delete invalid cache files
                  await file.delete();
                  await prefs.remove(key);
                }
              }
            } catch (e) {
              // Skip invalid entries
              debugPrint('Invalid feed metadata entry: $e');
              await prefs.remove(key);
            }
          }
        } catch (e) {
          debugPrint('Error processing feed metadata key $key: $e');
          await prefs.remove(key);
        }
      }

      debugPrint(
          'Loaded ${_postCache.length} posts and ${_feedCache.length} feeds into memory cache');
    } catch (e) {
      debugPrint('Error loading cache metadata: $e');
    }
  }

  /// Clean up old cache entries
  Future<void> _cleanupCacheIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();

      // Clean up old posts
      final postAccessList =
          prefs.getStringList('data_cache_post_access_list') ?? [];
      final expiredPostKeys = <String>[];

      for (final key in postAccessList) {
        final metadataKey = 'data_cache_post_$key';
        final jsonData = prefs.getString(metadataKey);

        if (jsonData != null) {
          final metadata = jsonDecode(jsonData) as Map<String, dynamic>;
          final cachedAt = metadata['cachedAt'] as int;
          final cachedDate = DateTime.fromMillisecondsSinceEpoch(cachedAt);

          if (now.difference(cachedDate) > maxCacheAge) {
            expiredPostKeys.add(key);
          }
        }
      }

      // Clean up old feeds
      final feedAccessList =
          prefs.getStringList('data_cache_feed_access_list') ?? [];
      final expiredFeedKeys = <String>[];

      for (final key in feedAccessList) {
        final metadataKey = 'data_cache_feed_$key';
        final jsonData = prefs.getString(metadataKey);

        if (jsonData != null) {
          final metadata = jsonDecode(jsonData) as Map<String, dynamic>;
          final cachedAt = metadata['cachedAt'] as int;
          final cachedDate = DateTime.fromMillisecondsSinceEpoch(cachedAt);

          if (now.difference(cachedDate) > maxCacheAge) {
            expiredFeedKeys.add(key);
          }
        }
      }

      // Delete expired entries
      for (final key in expiredPostKeys) {
        await _deletePost(key);
        postAccessList.remove(key);
      }

      for (final key in expiredFeedKeys) {
        await _deleteFeed(key);
        feedAccessList.remove(key);
      }

      // Enforce maximum entries
      if (postAccessList.length > maxCacheEntries / 2) {
        final keysToRemove = postAccessList.sublist(
            0, postAccessList.length - maxCacheEntries ~/ 2);
        for (final key in keysToRemove) {
          await _deletePost(key);
          postAccessList.remove(key);
        }
      }

      if (feedAccessList.length > maxCacheEntries / 2) {
        final keysToRemove = feedAccessList.sublist(
            0, feedAccessList.length - maxCacheEntries ~/ 2);
        for (final key in keysToRemove) {
          await _deleteFeed(key);
          feedAccessList.remove(key);
        }
      }

      // Save updated access lists
      await prefs.setStringList('data_cache_post_access_list', postAccessList);
      await prefs.setStringList('data_cache_feed_access_list', feedAccessList);

      debugPrint(
          'Cache cleanup complete: ${expiredPostKeys.length} posts and ${expiredFeedKeys.length} feeds expired');
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  /// Delete a post from cache
  Future<void> _deletePost(String key) async {
    try {
      // Remove from memory cache
      _postCache.remove(key);

      // Remove from disk
      final file = File('${_postDir!.path}/$key.json');
      if (await file.exists()) {
        await file.delete();
      }

      // Remove metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('data_cache_post_$key');
    } catch (e) {
      debugPrint('Error deleting post from cache: $e');
    }
  }

  /// Delete a feed from cache
  Future<void> _deleteFeed(String key) async {
    try {
      // Remove from memory cache
      _feedCache.remove(key);

      // Remove from disk
      final file = File('${_feedDir!.path}/$key.json');
      if (await file.exists()) {
        await file.delete();
      }

      // Remove metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('data_cache_feed_$key');
    } catch (e) {
      debugPrint('Error deleting feed from cache: $e');
    }
  }

  /// Clear all cached data
  Future<void> clearCache() async {
    try {
      if (!_initialized) await initialize();

      // Clear memory caches
      _postCache.clear();
      _feedCache.clear();

      // Clear disk caches
      if (await _postDir!.exists()) {
        await _postDir!.delete(recursive: true);
        await _postDir!.create(recursive: true);
      }

      if (await _feedDir!.exists()) {
        await _feedDir!.delete(recursive: true);
        await _feedDir!.create(recursive: true);
      }

      // Clear metadata
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();

      for (final key in allKeys) {
        if (key.startsWith('data_cache_post_') ||
            key.startsWith('data_cache_feed_')) {
          await prefs.remove(key);
        }
      }

      await prefs.remove('data_cache_post_access_list');
      await prefs.remove('data_cache_feed_access_list');

      debugPrint('Data cache cleared');
    } catch (e) {
      debugPrint('Error clearing data cache: $e');
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (!_initialized) await initialize();

      int postCount = 0;
      int feedCount = 0;
      List<String> postFiles = [];
      List<String> feedFiles = [];

      try {
        if (await _postDir!.exists()) {
          final postEntities = await _postDir!.list().toList();
          postFiles =
              postEntities.whereType<File>().map((e) => e.path).toList();
          postCount = postFiles.length;
        }
      } catch (e) {
        debugPrint('Error counting post files: $e');
      }

      try {
        if (await _feedDir!.exists()) {
          final feedEntities = await _feedDir!.list().toList();
          feedFiles =
              feedEntities.whereType<File>().map((e) => e.path).toList();
          feedCount = feedFiles.length;
        }
      } catch (e) {
        debugPrint('Error counting feed files: $e');
      }

      return {
        'postCount': postCount,
        'feedCount': feedCount,
        'totalCount': postCount + feedCount,
        'inMemoryPostCacheSize': _postCache.length,
        'inMemoryFeedCacheSize': _feedCache.length,
        'postFiles': postFiles,
        'feedFiles': feedFiles,
      };
    } catch (e) {
      debugPrint('Error getting data cache stats: $e');
      return {
        'error': e.toString(),
        'postCount': 0,
        'feedCount': 0,
        'totalCount': 0,
        'inMemoryPostCacheSize': _postCache.length,
        'inMemoryFeedCacheSize': _feedCache.length,
      };
    }
  }
}
