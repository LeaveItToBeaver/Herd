import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data_cache_service.dart';

/// A manager class that handles high-level caching operations and settings
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;

  CacheManager._internal();

  final MediaCacheService _mediaCache = MediaCacheService();
  final DataCacheService _dataCache = DataCacheService();

  // Cache settings
  int maxCacheSizeMB = 200; // Default 200MB
  int maxCacheEntries = 500; // Default 500 entries
  Duration maxCacheAge = const Duration(days: 7); // Default 7 days
  bool _isPrefetching = false;
  bool enableDataCache = true;

  // Load settings from shared preferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      maxCacheSizeMB = prefs.getInt('cache_max_size_mb') ?? 200;
      maxCacheEntries = prefs.getInt('cache_max_entries') ?? 500;
      final maxAgeDays = prefs.getInt('cache_max_age_days') ?? 7;
      maxCacheAge = Duration(days: maxAgeDays);

      // Load data cache setting
      enableDataCache = prefs.getBool('enable_data_cache') ?? true;

      // Update services with these settings
      _mediaCache.maxCacheSize = maxCacheSizeMB * 1024 * 1024;
      _mediaCache.maxEntries = maxCacheEntries;

      // Update data cache settings
      _dataCache.maxCacheEntries = maxCacheEntries;
      _dataCache.maxCacheAge = maxCacheAge;
    } catch (e) {
      debugPrint('Error loading cache settings: $e');
    }
  }

  // Save settings to shared preferences
  Future<void> saveSettings({
    int? maxSizeMB,
    int? maxEntries,
    int? maxAgeDays,
    bool? enableData,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (maxSizeMB != null) {
        maxCacheSizeMB = maxSizeMB;
        await prefs.setInt('cache_max_size_mb', maxSizeMB);
      }

      if (maxEntries != null) {
        maxCacheEntries = maxEntries;
        await prefs.setInt('cache_max_entries', maxEntries);
      }

      if (maxAgeDays != null) {
        maxCacheAge = Duration(days: maxAgeDays);
        await prefs.setInt('cache_max_age_days', maxAgeDays);
      }

      if (enableData != null) {
        enableDataCache = enableData;
        await prefs.setBool('enable_data_cache', enableData);
      }

      // Update MediaCacheService with these settings
      _mediaCache.maxCacheSize = maxCacheSizeMB * 1024 * 1024;
      _mediaCache.maxEntries = maxCacheEntries;

      // Update data cache settings
      _dataCache.maxCacheEntries = maxCacheEntries;
      _dataCache.maxCacheAge = maxCacheAge;
    } catch (e) {
      debugPrint('Error saving cache settings: $e');
    }
  }

  // Initialize the cache manager
  Future<void> initialize() async {
    await loadSettings();
    await _mediaCache.initialize();
  }

  // Prefetch a list of media items in the background
  Future<void> prefetchMediaItems(List<PostMediaModel> mediaItems) async {
    if (_isPrefetching) return; // Prevent multiple prefetch operations

    _isPrefetching = true;
    try {
      // Use the new batched prefetch method from MediaCacheService
      await _mediaCache.prefetchBatchedMediaItems(mediaItems);
    } catch (e) {
      debugPrint('Error during prefetch: $e');
    } finally {
      _isPrefetching = false;
    }
  }

  static Future<void> bootstrapCache() async {
    try {
      debugPrint('🔍 Bootstrapping cache...');
      final cacheManager = CacheManager();
      await cacheManager.initialize();
      debugPrint('✅ Cache bootstrap complete');

      // Log cache statistics in debug mode
      if (kDebugMode) {
        try {
          final cacheStats = await cacheManager.getCacheStats();
          debugPrint('📊 Cache statistics:');
          debugPrint('- Media cache size: ${cacheStats['totalSizeFormatted']}');
          debugPrint('- Media files: ${cacheStats['totalCount'] ?? 0}');
          debugPrint('- Data cache posts: ${cacheStats['postCount'] ?? 0}');
          debugPrint('- Data cache feeds: ${cacheStats['feedCount'] ?? 0}');
        } catch (e) {
          debugPrint('⚠️ Failed to get cache stats: $e');
        }
      }
    } catch (e) {
      debugPrint('❌ Error bootstrapping cache: $e');
      // Continue despite error to prevent app startup failure
    }
  }

  void _logCacheOperation(String operation, String postId,
      {bool success = true}) {
    final status = success ? '✅' : '❌';
    debugPrint('$status Cache $operation: $postId');
  }

  Future<void> cachePost(PostModel post) async {
    if (!enableDataCache) return; // Skip if data cache is disabled
    await _dataCache.cachePost(post);
  }

  // Cache a feed
  Future<void> cacheFeed(List<PostModel> posts, String userId,
      {bool isAlt = false, String? herdId}) async {
    if (!enableDataCache) return; // Skip if data cache is disabled
    await _dataCache.cacheFeed(posts, userId, isAlt: isAlt, herdId: herdId);
  }

  // Get a post from cache
  Future<PostModel?> getPost(String postId, {bool isAlt = false}) async {
    if (!enableDataCache) return null; // Skip if data cache is disabled
    return await _dataCache.getPost(postId, isAlt: isAlt);
  }

  // Get a feed from cache
  Future<List<PostModel>> getFeed(String userId,
      {bool isAlt = false, String? herdId}) async {
    if (!enableDataCache) return []; // Skip if data cache is disabled
    return await _dataCache.getFeed(userId, isAlt: isAlt, herdId: herdId);
  }

  // Check if a post exists in cache
  Future<bool> hasPost(String postId, {bool isAlt = false}) async {
    if (!enableDataCache) return false; // Skip if data cache is disabled
    return await _dataCache.hasPost(postId, isAlt: isAlt);
  }

  // Check if a feed exists in cache
  Future<bool> hasFeed(String userId,
      {bool isAlt = false, String? herdId}) async {
    if (!enableDataCache) return false; // Skip if data cache is disabled
    return await _dataCache.hasFeed(userId, isAlt: isAlt, herdId: herdId);
  }

  // Clear cache
  Future<void> clearCache() async {
    await _mediaCache.clearCache();
    await _dataCache.clearCache(); // Also clear data cache
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    final mediaStats = await _mediaCache.getCacheStats();
    final dataStats = await _dataCache.getCacheStats();

    return {
      ...mediaStats,
      ...dataStats,
    };
  }

  // Create a provider for the cache manager
  static final cacheManagerProvider = Provider<CacheManager>((ref) {
    return CacheManager();
  });
}
