import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:herdapp/core/barrels/providers.dart';

part 'e2ee_auto_init_provider.g.dart';

/// Provider that automatically initializes E2EE keys when a user is authenticated
@riverpod
Future<void> e2eeAutoInit(Ref ref) async {
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
}

/// Provider for getting E2EE key sync status
@riverpod
Future<Map<String, dynamic>> e2eeKeyStatus(Ref ref, String userId) async {
  final keyManager = ref.read(e2eeKeyManagerProvider);
  return await keyManager.getSyncStatus(userId);
}

/// Provider for manually resetting E2EE keys
@riverpod
Future<void> e2eeKeyReset(Ref ref, String userId) async {
  final keyManager = ref.read(e2eeKeyManagerProvider);
  await keyManager.resetAndReinitializeKeys(userId);
}
