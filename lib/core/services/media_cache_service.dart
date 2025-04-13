// lib/core/services/media_cache_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_media_model.dart';
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
    if (_initialized) return;

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

      // Cleanup old cache entries
      _cleanupCacheIfNeeded();

      _initialized = true;
      debugPrint('MediaCacheService initialized');
    } catch (e) {
      debugPrint('Error initializing MediaCacheService: $e');
    }
  }

  /// Generate a unique but deterministic cache key for a URL
  String _generateCacheKey(String url) {
    return md5.convert(utf8.encode(url)).toString();
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

  /// Check if a media item is cached and return the local file path if it is
  Future<String?> getCachedMediaPath(String url,
      {String mediaType = 'image'}) async {
    if (!_initialized) await initialize();

    try {
      final cacheKey = _generateCacheKey(url);
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
      final cacheKey = _generateCacheKey(url);
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

  /// Cache complete PostMediaModel information
  Future<void> cachePostMedia(PostMediaModel media) async {
    if (!_initialized) await initialize();

    try {
      final cacheKey = _generateCacheKey(media.url);

      // Cache the main media file
      if (media.url.isNotEmpty) {
        await cacheMediaFromUrl(media.url, mediaType: media.mediaType);
      }

      // Cache the thumbnail if available
      if (media.thumbnailUrl != null && media.thumbnailUrl!.isNotEmpty) {
        await cacheMediaFromUrl(media.thumbnailUrl!, mediaType: 'thumbnail');
      }

      // Save the full media model to metadata cache
      _mediaMetadataCache[cacheKey] = media;

      // Persist metadata
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'media_metadata_$cacheKey', jsonEncode(media.toMap()));
    } catch (e) {
      debugPrint('Error caching post media: $e');
    }
  }

  /// Retrieve a cached PostMediaModel by URL
  Future<PostMediaModel?> getCachedPostMedia(String url) async {
    if (!_initialized) await initialize();

    try {
      final cacheKey = _generateCacheKey(url);

      // Check memory cache first
      if (_mediaMetadataCache.containsKey(cacheKey)) {
        _updateLastAccessed(cacheKey);
        return _mediaMetadataCache[cacheKey];
      }

      // Check disk cache
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString('media_metadata_$cacheKey');

      if (jsonData != null) {
        final mediaMap = jsonDecode(jsonData) as Map<String, dynamic>;
        final media = PostMediaModel.fromMap(mediaMap);

        // Update memory cache
        _mediaMetadataCache[cacheKey] = media;
        _updateLastAccessed(cacheKey);

        return media;
      }

      return null;
    } catch (e) {
      debugPrint('Error retrieving cached post media: $e');
      return null;
    }
  }

  /// Load cache metadata from shared preferences
  Future<void> _loadCacheMetadata() async {
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
  Future<void> _cleanupCacheIfNeeded() async {
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

      if (totalSize > maxCacheSize || accessList.length > maxEntries) {
        debugPrint(
            'Cache cleanup needed: Size=${totalSize ~/ 1024}KB, Entries=${accessList.length}');

        // Clean up based on LRU (least recently used)
        while ((totalSize > maxCacheSize * 0.8 ||
                accessList.length > maxEntries * 0.8) &&
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

      debugPrint('Media cache cleared');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  /// Get the current cache size in bytes
  Future<int> getCacheSize() async {
    try {
      if (!_initialized) await initialize();

      int totalSize = 0;
      final imageFiles = await _imageDir!.list().toList();
      final videoFiles = await _videoDir!.list().toList();
      final thumbnailFiles = await _thumbnailDir!.list().toList();

      for (final entity in [...imageFiles, ...videoFiles, ...thumbnailFiles]) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }

      return totalSize;
    } catch (e) {
      debugPrint('Error getting cache size: $e');
      return 0;
    }
  }

  /// Get cache statistics
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      if (!_initialized) await initialize();

      int imageCount = 0;
      int videoCount = 0;
      int thumbnailCount = 0;
      int totalSize = 0;

      if (await _imageDir!.exists()) {
        final imageFiles = await _imageDir!.list().toList();
        imageCount = imageFiles.where((e) => e is File).length;
        for (final entity in imageFiles) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      if (await _videoDir!.exists()) {
        final videoFiles = await _videoDir!.list().toList();
        videoCount = videoFiles.where((e) => e is File).length;
        for (final entity in videoFiles) {
          if (entity is File) {
            totalSize += await entity.length();
          }
        }
      }

      if (await _thumbnailDir!.exists()) {
        final thumbnailFiles = await _thumbnailDir!.list().toList();
        thumbnailCount = thumbnailFiles.where((e) => e is File).length;
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

  /// Cache provider for this service
  static final mediaCacheServiceProvider = Provider<MediaCacheService>((ref) {
    return MediaCacheService();
  });
}
