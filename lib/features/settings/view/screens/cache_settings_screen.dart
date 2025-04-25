// lib/features/settings/view/screens/cache_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/cache_manager.dart';

class CacheSettingsScreen extends ConsumerStatefulWidget {
  const CacheSettingsScreen({super.key});

  @override
  ConsumerState<CacheSettingsScreen> createState() =>
      _CacheSettingsScreenState();
}

class _CacheSettingsScreenState extends ConsumerState<CacheSettingsScreen> {
  late int _maxCacheSizeMB;
  late int _maxCacheEntries;
  late int _maxCacheAgeDays;
  Map<String, dynamic>? _cacheStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings(); // Refresh stats whenever screen is revisited
  }

  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cacheManager = ref.read(CacheManager.cacheManagerProvider);

      // Ensure cache manager is initialized
      await cacheManager.initialize();

      // Load current settings
      _maxCacheSizeMB = cacheManager.maxCacheSizeMB;
      _maxCacheEntries = cacheManager.maxCacheEntries;
      _maxCacheAgeDays = cacheManager.maxCacheAge.inDays;

      // Load cache statistics
      _cacheStats = await cacheManager.getCacheStats();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading cache settings: $e')),
        );
      }
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final cacheManager = ref.read(CacheManager.cacheManagerProvider);

      await cacheManager.saveSettings(
        maxSizeMB: _maxCacheSizeMB,
        maxEntries: _maxCacheEntries,
        maxAgeDays: _maxCacheAgeDays,
      );

      // Refresh cache statistics
      _cacheStats = await cacheManager.getCacheStats();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache settings saved')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving cache settings: $e')),
        );
      }
    }
  }

  Future<void> _clearCache() async {
    final confirmClear = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
            'Are you sure you want to clear all cached media? This will free up space but may result in slower loading of previously viewed content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmClear != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cacheManager = ref.read(CacheManager.cacheManagerProvider);

      await cacheManager.clearCache();

      // Refresh cache statistics
      _cacheStats = await cacheManager.getCacheStats();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error clearing cache: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Media Cache Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSettings,
            tooltip: 'Refresh statistics',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cache Stats Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Cache Usage',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_cacheStats != null) ...[
                            _buildStatRow(
                              'Total Size',
                              _cacheStats!['totalSizeFormatted'] ?? '0 MB',
                              icon: Icons.storage,
                            ),
                            _buildStatRow(
                              'Images',
                              '${_cacheStats!['imageCount'] ?? 0} files',
                              icon: Icons.image,
                            ),
                            _buildStatRow(
                              'Videos',
                              '${_cacheStats!['videoCount'] ?? 0} files',
                              icon: Icons.video_library,
                            ),
                            _buildStatRow(
                              'Thumbnails',
                              '${_cacheStats!['thumbnailCount'] ?? 0} files',
                              icon: Icons.photo_size_select_small,
                            ),
                          ] else ...[
                            const Text('No cache statistics available'),
                          ],
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.delete_sweep),
                              label: const Text('Clear Cache'),
                              onPressed: _clearCache,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Cache Settings Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cache Settings',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Max Cache Size Slider
                          const Text(
                            'Maximum Cache Size',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _maxCacheSizeMB.toDouble(),
                                  min: 50,
                                  max: 1000,
                                  divisions: 19,
                                  label: '$_maxCacheSizeMB MB',
                                  onChanged: (value) {
                                    setState(() {
                                      _maxCacheSizeMB = value.round();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 60,
                                child: Text(
                                  '$_maxCacheSizeMB MB',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Max Cache Entries Slider
                          const Text(
                            'Maximum Number of Files',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _maxCacheEntries.toDouble(),
                                  min: 100,
                                  max: 2000,
                                  divisions: 19,
                                  label: '$_maxCacheEntries files',
                                  onChanged: (value) {
                                    setState(() {
                                      _maxCacheEntries = value.round();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  '$_maxCacheEntries',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // Max Cache Age Slider
                          const Text(
                            'Maximum Cache Age',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _maxCacheAgeDays.toDouble(),
                                  min: 1,
                                  max: 30,
                                  divisions: 29,
                                  label: '$_maxCacheAgeDays days',
                                  onChanged: (value) {
                                    setState(() {
                                      _maxCacheAgeDays = value.round();
                                    });
                                  },
                                ),
                              ),
                              SizedBox(
                                width: 70,
                                child: Text(
                                  '$_maxCacheAgeDays days',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Save button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveSettings,
                              child: const Text('Save Settings'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Information Card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Media Caching',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Caching images and videos can significantly improve app performance and reduce data usage. '
                            'However, it also consumes storage space on your device.',
                          ),
                          SizedBox(height: 8),
                          Text(
                            'The app will automatically manage the cache based on your settings, removing the oldest or least used '
                            'files when necessary to stay within the limits you set.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatRow(String label, String value, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
