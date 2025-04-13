// lib/core/services/cache_manager.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A manager class that handles high-level caching operations and settings
class CacheManager {
  static final CacheManager _instance = CacheManager._internal();
  factory CacheManager() => _instance;

  CacheManager._internal();

  final MediaCacheService _mediaCache = MediaCacheService();

  // Cache settings
  int maxCacheSizeMB = 200; // Default 200MB
  int maxCacheEntries = 500; // Default 500 entries
  Duration maxCacheAge = const Duration(days: 7); // Default 7 days
  bool _isPrefetching = false;

  // Load settings from shared preferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      maxCacheSizeMB = prefs.getInt('cache_max_size_mb') ?? 200;
      maxCacheEntries = prefs.getInt('cache_max_entries') ?? 500;
      final maxAgeDays = prefs.getInt('cache_max_age_days') ?? 7;
      maxCacheAge = Duration(days: maxAgeDays);

      // Update MediaCacheService with these settings
      _mediaCache.maxCacheSize = maxCacheSizeMB * 1024 * 1024;
      _mediaCache.maxEntries = maxCacheEntries;
    } catch (e) {
      debugPrint('Error loading cache settings: $e');
    }
  }

  // Save settings to shared preferences
  Future<void> saveSettings({
    int? maxSizeMB,
    int? maxEntries,
    int? maxAgeDays,
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

      // Update MediaCacheService with these settings
      _mediaCache.maxCacheSize = maxCacheSizeMB * 1024 * 1024;
      _mediaCache.maxEntries = maxCacheEntries;
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
      // Prioritize thumbnails first for faster initial loading
      for (final media in mediaItems) {
        if (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty) {
          await _mediaCache.getCachedMediaPath(
                media.thumbnailUrl!,
                mediaType: 'thumbnail',
              ) ??
              await _mediaCache.cacheMediaFromUrl(
                media.thumbnailUrl!,
                mediaType: 'thumbnail',
              );
        }
      }

      // Then cache the full resolution media
      for (final media in mediaItems) {
        if (media.url.isNotEmpty) {
          final isCached = await _mediaCache.getCachedMediaPath(
                media.url,
                mediaType: media.mediaType,
              ) !=
              null;

          if (!isCached) {
            await _mediaCache.cacheMediaFromUrl(media.url,
                mediaType: media.mediaType);
          }
        }
      }
    } catch (e) {
      debugPrint('Error during prefetch: $e');
    } finally {
      _isPrefetching = false;
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    await _mediaCache.clearCache();
  }

  // Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    return await _mediaCache.getCacheStats();
  }

  // Create a provider for the cache manager
  static final cacheManagerProvider = Provider<CacheManager>((ref) {
    return CacheManager();
  });
}
