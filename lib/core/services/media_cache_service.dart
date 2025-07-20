import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/utils/get_signed_url.dart';
import 'package:herdapp/features/content/post/data/models/post_media_model.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for caching and retrieving media files
/// Used to prevent repeated loading of the same media assets
class MediaCacheService {
  static final MediaCacheService _instance = MediaCacheService._internal();
  factory MediaCacheService() => _instance;

  // Private constructor
  MediaCacheService._internal();

  // Cache directories
  Directory? _cacheDir;
  Directory? _imageDir;
  Directory? _videoDir;
  Directory? _thumbnailDir;

  // Cache for metadata - to avoid disk reads
  final Map<String, PostMediaModel> _mediaMetadataCache = {};

  // Flag to track initialization
  bool _initialized = false;

  // Cache settings
  int maxCacheSize = 200 * 1024 * 1024; // 200MB default
  int maxEntries = 500; // Maximum cache entries

  /// Initialize the cache service by creating necessary directories
  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    try {
      // Get appropriate cache directory
      _cacheDir = await getTemporaryDirectory();
      final cachePath = _cacheDir!.path;

      // Create subdirectories for different media types
      _imageDir = Directory('$cachePath/media_cache/images');
      _videoDir = Directory('$cachePath/media_cache/videos');
      _thumbnailDir = Directory('$cachePath/media_cache/thumbnails');

      await _imageDir!.create(recursive: true);
      await _videoDir!.create(recursive: true);
      await _thumbnailDir!.create(recursive: true);

      // Load cache metadata from shared preferences
      await _loadCacheMetadata();

      // Perform immediate cleanup to free any resources
      await _cleanupCacheIfNeeded(forceCleanup: true);

      _initialized = true;
      debugPrint('MediaCacheService initialized');
    } catch (e) {
      debugPrint('Error initializing MediaCacheService: $e');
    }
  }

  String generateCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  Future<File?> getFileFromCache(String url,
      {String mediaType = 'image'}) async {
    // Use the gsu() utility to get the base URL for consistent caching
    final baseUrl = gsu(url);
    final path = await getCachedMediaPath(baseUrl, mediaType: mediaType);
    if (path != null) {
      final file = File(path);
      // Check existence again to be safe
      if (await file.exists()) {
        return file;
      }
    }
    return null;
  }

  /// Get the appropriate cache directory based on media type
  Directory _getDirectoryForMediaType(String mediaType) {
    if (mediaType == 'video') {
      return _videoDir!;
    } else if (mediaType == 'thumbnail') {
      return _thumbnailDir!;
    } else {
      return _imageDir!;
    }
  }

  /// Helper method to ensure media is cached, returns cached path or caches it
  Future<String?> _ensureMediaCached(String url,
      {String mediaType = 'image'}) async {
    final cachedPath = await getCachedMediaPath(url, mediaType: mediaType);
    if (cachedPath != null) {
      return cachedPath;
    }
    return await cacheMediaFromUrl(url, mediaType: mediaType);
  }

  // 1. Add to MediaCacheService class
  Future<void> prefetchBatchedMediaItems(
      List<PostMediaModel> mediaItems) async {
    if (kIsWeb) return;
    if (mediaItems.isEmpty) return;

    try {
      // Limit to max 3 concurrent prefetch operations
      final int maxConcurrent = 3;
      final int totalItems = mediaItems.length;

      // Process in small batches to avoid overwhelming the system
      for (int i = 0; i < totalItems; i += maxConcurrent) {
        final int end =
            (i + maxConcurrent < totalItems) ? i + maxConcurrent : totalItems;
        final batch = mediaItems.sublist(i, end);

        // Process thumbnails first (they're smaller)
        final thumbnailFutures = <Future>[];
        for (final media in batch) {
          if (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty) {
            thumbnailFutures.add(_ensureMediaCached(
              media.thumbnailUrl!,
              mediaType: 'thumbnail',
            ));
          }
        }

        // Wait for all thumbnails in this batch to complete
        await Future.wait(thumbnailFutures);

        // Then process full resolution media
        final mediaFutures = <Future>[];
        for (final media in batch) {
          if (media.url.isNotEmpty) {
            final isCached = await getCachedMediaPath(
                  media.url,
                  mediaType: media.mediaType,
                ) !=
                null;

            if (!isCached) {
              mediaFutures.add(_ensureMediaCached(
                media.url,
                mediaType: media.mediaType,
              ));
            }
          }
        }

        // Wait for full media in this batch to complete
        await Future.wait(mediaFutures);

        // Small delay between batches to allow system to process buffers
        await Future.delayed(const Duration(milliseconds: 100));
      }

      // After all processing, clear Flutter's image cache to prevent buffer issues
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();
    } catch (e) {
      debugPrint('Error during batch prefetch: $e');
    }
  }

  ImageProvider getImageProvider(String url) {
    // IMPORTANT: Use gsu() to strip tokens from the URL for the cache key
    final baseUrl = gsu(url);
    final cacheKey = generateCacheKey(baseUrl);

    // Check if the file exists SYNCHRONOUSLY
    // This is less ideal than async, but necessary for ImageProvider.
    // The performance impact should be negligible for checking a file path.
    final directory = _getDirectoryForMediaType('image');
    final filePath =
        '${directory.path}/$cacheKey${_getExtensionFromUrl(baseUrl)}';
    final file = File(filePath);

    if (file.existsSync()) {
      // Update last access time asynchronously without waiting
      _updateLastAccessed(cacheKey);
      return FileImage(file);
    } else {
      // If not in our file cache, use CachedNetworkImageProvider.
      // It will handle fetching and its own caching.
      // We pass the *original URL* to fetch from, but it will be cached
      // internally using its own keying mechanism.
      return CachedNetworkImageProvider(url,
          // You can specify the cache key for CachedNetworkImageProvider as well
          cacheKey: cacheKey);
    }
  }

// Provider for this service
  static final mediaCacheServiceProvider = Provider<MediaCacheService>((ref) {
    return MediaCacheService();
  });

// 3. Add this method to MediaCacheService
  Future<Map<String, dynamic>> getCacheStats() async {
    if (kIsWeb) {
      return {
        'error': 'Cache stats not available on web platform',
      };
    }
    try {
      if (!_initialized) await initialize();

      int imageCount = 0;
      int videoCount = 0;
      int thumbnailCount = 0;
      int totalSize = 0;

      if (await _imageDir!.exists()) {
        final imageFiles = await _imageDir!.list().toList();
        imageCount = imageFiles.whereType<File>().length;
        for (final entity in imageFiles) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      if (await _videoDir!.exists()) {
        final videoFiles = await _videoDir!.list().toList();
        videoCount = videoFiles.whereType<File>().length;
        for (final entity in videoFiles) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      if (await _thumbnailDir!.exists()) {
        final thumbnailFiles = await _thumbnailDir!.list().toList();
        thumbnailCount = thumbnailFiles.whereType<File>().length;
        for (final entity in thumbnailFiles) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      return {
        'totalSize': totalSize,
        'totalSizeFormatted':
            '${(totalSize / (1024 * 1024)).toStringAsFixed(2)} MB',
        'imageCount': imageCount,
        'videoCount': videoCount,
        'thumbnailCount': thumbnailCount,
        'totalCount': imageCount + videoCount + thumbnailCount,
        'inMemoryCacheSize': _mediaMetadataCache.length,
      };
    } catch (e) {
      debugPrint('Error getting cache stats: $e');
      return {
        'error': e.toString(),
      };
    }
  }

  /// Check if a media item is cached and return the local file path if it is
  Future<String?> getCachedMediaPath(String url,
      {String mediaType = 'image'}) async {
    if (kIsWeb) return null; // Caching not supported on web
    if (!_initialized) await initialize();

    try {
      final cacheKey = generateCacheKey(url);
      final directory = _getDirectoryForMediaType(mediaType);
      final filePath =
          '${directory.path}/$cacheKey${_getExtensionFromUrl(url)}';

      final file = File(filePath);
      if (await file.exists()) {
        // Update last access time in cache metadata
        _updateLastAccessed(cacheKey);
        return filePath;
      }

      return null;
    } catch (e) {
      debugPrint('Error checking cached media: $e');
      return null;
    }
  }

  /// Cache a media file from a URL
  Future<String?> cacheMediaFromUrl(String url,
      {String mediaType = 'image'}) async {
    if (kIsWeb) return null; // Caching not supported on web
    if (!_initialized) await initialize();

    try {
      // Check if already cached
      final existingPath = await getCachedMediaPath(url, mediaType: mediaType);
      if (existingPath != null) {
        return existingPath;
      }

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        throw Exception('Failed to download media from $url');
      }

      // Save to cache
      final cacheKey = generateCacheKey(url);
      final directory = _getDirectoryForMediaType(mediaType);
      final filePath =
          '${directory.path}/$cacheKey${_getExtensionFromUrl(url)}';

      final file = await File(filePath).create(recursive: true);
      await file.writeAsBytes(response.bodyBytes);

      // Add to metadata cache
      await _saveCacheMetadata(cacheKey, url, mediaType, file.lengthSync());

      return filePath;
    } catch (e) {
      debugPrint('Error caching media: $e');
      return null;
    }
  }

  /// Get extension from URL
  String _getExtensionFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final lastSegment = uri.pathSegments.last;
      return path.extension(lastSegment);
    } catch (e) {
      // Default extension if unable to determine
      return '.dat';
    }
  }

  /// Load cache metadata from shared preferences
  Future<void> _loadCacheMetadata() async {
    if (kIsWeb) return; // Caching not supported on web
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get all keys related to media metadata
      final allKeys = prefs.getKeys();
      final metadataKeys =
          allKeys.where((key) => key.startsWith('media_metadata_')).toList();

      for (final key in metadataKeys) {
        final jsonData = prefs.getString(key);
        if (jsonData != null) {
          try {
            final mediaMap = jsonDecode(jsonData) as Map<String, dynamic>;
            final cacheKey = key.replaceFirst('media_metadata_', '');
            final media = PostMediaModel.fromMap(mediaMap);
            _mediaMetadataCache[cacheKey] = media;
          } catch (e) {
            // Skip invalid entries
            debugPrint('Invalid media metadata entry: $e');
          }
        }
      }

      debugPrint(
          'Loaded ${_mediaMetadataCache.length} media items into memory cache');
    } catch (e) {
      debugPrint('Error loading cache metadata: $e');
    }
  }

  /// Save cache metadata to shared preferences
  Future<void> _saveCacheMetadata(
      String cacheKey, String url, String mediaType, int fileSize) async {
    if (kIsWeb) return; // Caching not supported on web
    try {
      final prefs = await SharedPreferences.getInstance();

      // Create metadata map
      final metadata = {
        'cacheKey': cacheKey,
        'url': url,
        'mediaType': mediaType,
        'fileSize': fileSize,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'lastAccessed': DateTime.now().millisecondsSinceEpoch,
      };

      // Save to shared preferences
      await prefs.setString('media_cache_$cacheKey', jsonEncode(metadata));

      // Save access time list for LRU
      final accessList = prefs.getStringList('media_cache_access_list') ?? [];
      if (!accessList.contains(cacheKey)) {
        accessList.add(cacheKey);
        await prefs.setStringList('media_cache_access_list', accessList);
      }
    } catch (e) {
      debugPrint('Error saving cache metadata: $e');
    }
  }

  /// Update last accessed time for cache entry
  Future<void> _updateLastAccessed(String cacheKey) async {
    if (kIsWeb) return; // Caching not supported on web
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get existing metadata
      final jsonData = prefs.getString('media_cache_$cacheKey');
      if (jsonData != null) {
        final metadata = jsonDecode(jsonData) as Map<String, dynamic>;

        // Update last accessed time
        metadata['lastAccessed'] = DateTime.now().millisecondsSinceEpoch;

        // Save updated metadata
        await prefs.setString('media_cache_$cacheKey', jsonEncode(metadata));

        // Update access list for LRU
        final accessList = prefs.getStringList('media_cache_access_list') ?? [];
        if (accessList.contains(cacheKey)) {
          accessList.remove(cacheKey);
        }
        accessList.add(cacheKey); // Add to end (most recently used)
        await prefs.setStringList('media_cache_access_list', accessList);
      }
    } catch (e) {
      debugPrint('Error updating last accessed time: $e');
    }
  }

  /// Clean up old cache entries if needed
  Future<void> _cleanupCacheIfNeeded({bool forceCleanup = false}) async {
    if (kIsWeb) return; // Caching not supported on web
    try {
      // Calculate current cache size
      int totalSize = 0;
      final imageFiles = await _imageDir!.list().toList();
      final videoFiles = await _videoDir!.list().toList();
      final thumbnailFiles = await _thumbnailDir!.list().toList();

      final allFiles = [...imageFiles, ...videoFiles, ...thumbnailFiles];

      for (final entity in allFiles) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      // Check if we need to clean up based on size or count
      final prefs = await SharedPreferences.getInstance();
      final accessList = prefs.getStringList('media_cache_access_list') ?? [];

      // For forced cleanup, be more aggressive (80% of limit)
      final cleanupThreshold = forceCleanup ? 0.8 : 1.0;

      if (totalSize > maxCacheSize * cleanupThreshold ||
          accessList.length > maxEntries * cleanupThreshold) {
        debugPrint(
            'Cache cleanup needed: Size=${totalSize ~/ 1024}KB, Entries=${accessList.length}');

        // Clean up based on LRU (least recently used)
        while ((totalSize > maxCacheSize * 0.7 ||
                accessList.length > maxEntries * 0.7) &&
            accessList.isNotEmpty) {
          final lruKey = accessList.removeAt(0); // Get least recently used

          // Delete metadata
          prefs.remove('media_cache_$lruKey');
          prefs.remove('media_metadata_$lruKey');

          // Delete files
          await _deleteFilesForCacheKey(lruKey);

          // Calculate new size
          totalSize = 0;
          final updatedFiles = [
            ...await _imageDir!.list().toList(),
            ...await _videoDir!.list().toList(),
            ...await _thumbnailDir!.list().toList(),
          ];

          for (final entity in updatedFiles) {
            if (entity is File) {
              totalSize += await entity.length();
            }
          }
        }

        // Clear Flutter's image cache to free up memory
        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        // Save updated access list
        await prefs.setStringList('media_cache_access_list', accessList);

        debugPrint(
            'Cache cleanup complete: Size=${totalSize ~/ 1024}KB, Entries=${accessList.length}');
      }
    } catch (e) {
      debugPrint('Error during cache cleanup: $e');
    }
  }

  /// Delete all files associated with a cache key
  Future<void> _deleteFilesForCacheKey(String cacheKey) async {
    if (kIsWeb) return; // Caching not supported on web
    try {
      // Remove from memory cache
      _mediaMetadataCache.remove(cacheKey);

      // Check all directories for files with this cache key
      final imageFiles = await _imageDir!.list().where((entity) {
        return entity is File &&
            path.basenameWithoutExtension(entity.path) == cacheKey;
      }).toList();

      final videoFiles = await _videoDir!.list().where((entity) {
        return entity is File &&
            path.basenameWithoutExtension(entity.path) == cacheKey;
      }).toList();

      final thumbnailFiles = await _thumbnailDir!.list().where((entity) {
        return entity is File &&
            path.basenameWithoutExtension(entity.path) == cacheKey;
      }).toList();

      // Delete all found files
      for (final entity in [...imageFiles, ...videoFiles, ...thumbnailFiles]) {
        if (entity is File) {
          await entity.delete();
        }
      }
    } catch (e) {
      debugPrint('Error deleting files for cache key $cacheKey: $e');
    }
  }

  /// Clear the entire cache
  Future<void> clearCache() async {
    if (kIsWeb) return; // Caching not supported on web
    try {
      if (!_initialized) await initialize();

      // Clear memory cache
      _mediaMetadataCache.clear();

      // Delete all files
      if (await _imageDir!.exists()) {
        await _imageDir!.delete(recursive: true);
        await _imageDir!.create(recursive: true);
      }

      if (await _videoDir!.exists()) {
        await _videoDir!.delete(recursive: true);
        await _videoDir!.create(recursive: true);
      }

      if (await _thumbnailDir!.exists()) {
        await _thumbnailDir!.delete(recursive: true);
        await _thumbnailDir!.create(recursive: true);
      }

      // Clear shared preferences cache metadata
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs
          .getKeys()
          .where((key) =>
              key.startsWith('media_cache_') ||
              key.startsWith('media_metadata_'))
          .toList();

      for (final key in allKeys) {
        await prefs.remove(key);
      }

      // Clear Flutter's image cache explicitly
      PaintingBinding.instance.imageCache.clear();
      PaintingBinding.instance.imageCache.clearLiveImages();

      debugPrint('Media cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}
