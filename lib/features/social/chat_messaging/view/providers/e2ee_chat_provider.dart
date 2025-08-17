import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';

/// Automatically initializes E2EE identity keys when user is authenticated
final e2eeInitProvider = FutureProvider<void>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth == null) return;

  try {
    final crypto = ref.read(chatCryptoServiceProvider);
    await crypto.ensureIdentityKeyPublished(
        FirebaseFirestore.instance, auth.uid);
  } catch (e) {
    // Silently handle errors to prevent blocking the UI
    // This allows the app to function normally even if E2EE setup fails
  }
});

/// Provider that can be consumed in the app to ensure E2EE is initialized

final e2eeStatusProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authProvider);
  if (user == null) return false;

  try {
    // Only initialize E2EE when actually needed (e.g., when opening a chat)
    // Don't auto-publish keys on app startup
    return true;
  } catch (e) {
    debugPrint('E2EE initialization deferred: $e');
    return false;
  }
});

final initializeE2eeProvider =
    FutureProvider.family<void, String>((ref, userId) async {
  final crypto = ref.read(chatCryptoServiceProvider);

  try {
    // Use FirebaseFirestore.instance directly, like your other providers
    await crypto.ensureIdentityKeyPublished(FirebaseFirestore.instance, userId);
  } catch (e) {
    debugPrint('Failed to initialize E2EE for user $userId: $e');
    // Don't throw - just log the error
  }
});
