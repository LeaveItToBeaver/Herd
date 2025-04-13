// lib/core/bootstrap/app_bootstrap.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/services/cache_manager.dart';
import 'package:herdapp/core/services/media_cache_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Bootstrap class for initializing app dependencies
class AppBootstrap {
  static final AppBootstrap _instance = AppBootstrap._internal();
  factory AppBootstrap() => _instance;

  AppBootstrap._internal();

  bool _isInitialized = false;

  /// Initialize all app services and dependencies
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Starting app initialization...');

      // Initialize shared preferences
      final prefs = await SharedPreferences.getInstance();
      debugPrint('✅ Shared preferences initialized');

      // Initialize media cache
      await MediaCacheService().initialize();
      debugPrint('✅ Media cache service initialized');

      // Initialize cache manager
      final cacheManager = CacheManager();
      await cacheManager.initialize();
      debugPrint('✅ Cache manager initialized');

      // Log cache statistics
      if (kDebugMode) {
        final cacheStats = await cacheManager.getCacheStats();
        debugPrint('📊 Cache statistics:');
        debugPrint('- Total size: ${cacheStats['totalSizeFormatted']}');
        debugPrint('- Image count: ${cacheStats['imageCount']}');
        debugPrint('- Video count: ${cacheStats['videoCount']}');
        debugPrint('- Thumbnail count: ${cacheStats['thumbnailCount']}');
      }

      _isInitialized = true;
      debugPrint('✅ App initialization complete');
    } catch (e, stackTrace) {
      debugPrint('❌ Error during app initialization: $e');
      debugPrint(stackTrace.toString());

      // Continue without fatal error, services will handle initialization errors
    }
  }

  /// Create a provider for the bootstrap service
  static final appBootstrapProvider = Provider<AppBootstrap>((ref) {
    return AppBootstrap();
  });
}

/// Extension on WidgetRef to easily access bootstrap
extension BootstrapExtension on WidgetRef {
  AppBootstrap get bootstrap => read(AppBootstrap.appBootstrapProvider);
}

/// A widget that ensures the app is bootstrapped
class BootstrapWrapper extends ConsumerWidget {
  final Widget child;

  const BootstrapWrapper({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(AppBootstrap.appBootstrapProvider);

    return FutureBuilder(
      future: bootstrap.initialize(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Continue with the app regardless of initialization errors
        return child;
      },
    );
  }
}
