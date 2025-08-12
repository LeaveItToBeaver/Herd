import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';

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
final e2eeStatusProvider = Provider<AsyncValue<void>>((ref) {
  return ref.watch(e2eeInitProvider);
});
