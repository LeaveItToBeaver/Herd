import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:flutter/foundation.dart';

/// Provider that automatically initializes E2EE keys when a user is authenticated
final e2eeAutoInitProvider = FutureProvider<void>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return;

  try {
    final keyManager = ref.read(e2eeKeyManagerProvider);

    // Check if already initialized
    final isInitialized = await keyManager.isKeyInitialized();

    if (!isInitialized) {
      debugPrint('Auto-initializing E2EE keys for authenticated user');
      await keyManager.initializeUserKeys(auth.uid);
      debugPrint('E2EE keys auto-initialized successfully');
    } else {
      debugPrint('E2EE keys already initialized for user');
    }
  } catch (e) {
    debugPrint('E2EE auto-initialization failed: $e');
    // Don't throw - allow app to continue without E2EE
  }
});

/// Provider for getting E2EE key sync status
final e2eeKeyStatusProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, userId) async {
  final keyManager = ref.read(e2eeKeyManagerProvider);
  return await keyManager.getSyncStatus(userId);
});

/// Provider for manually resetting E2EE keys
final e2eeKeyResetProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final keyManager = ref.read(e2eeKeyManagerProvider);
  await keyManager.resetAndReinitializeKeys(userId);
});
