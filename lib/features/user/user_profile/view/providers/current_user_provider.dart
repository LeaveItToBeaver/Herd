import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:herdapp/features/social/notifications/data/repositories/notification_repository.dart';
import 'package:herdapp/features/social/chat_messaging/data/cache/message_cache_service.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/chat_provider.dart';

class CurrentUserController extends StateNotifier<AsyncValue<UserModel?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Ref _ref;
  String? _lastUserId; // Track last user ID to detect user changes

  CurrentUserController(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user == null) {
        _lastUserId = null;
        state = const AsyncValue.data(null);
      } else {
        fetchCurrentUser();
      }
    });
  }

  Future<void> fetchCurrentUser() async {
    state = const AsyncValue.loading();
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _lastUserId = null;
        state = const AsyncValue.data(null);
        return;
      }

      // Check if this is a different user than before
      final currentUserId = firebaseUser.uid;
      if (_lastUserId != null && _lastUserId != currentUserId) {
        debugPrint(
            'User changed from $_lastUserId to $currentUserId - clearing caches');
        await _clearCachesForUserChange(_lastUserId!, currentUserId);
      }
      _lastUserId = currentUserId;

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final userModel = UserModel.fromMap(doc.id, doc.data()!);
        state = AsyncValue.data(userModel);

        // Initialize FCM token for this user
        _initializeFCMForUser(firebaseUser.uid);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// Clear caches when switching between users
  Future<void> _clearCachesForUserChange(
      String oldUserId, String newUserId) async {
    try {
      // Clear message caches
      final messageCache = _ref.read(messageCacheServiceProvider);
      await messageCache.clearUserCache(oldUserId);

      // Reset chat providers
      _ref.invalidate(chatStateProvider);
      _ref.invalidate(chatPaginationProvider);

      // Note: We don't invalidate family providers like messagesProvider, currentChatProvider
      // and messageInputProvider because they are chat-specific and will be cleaned up
      // when the cache is cleared. They will refresh with new data when needed.

      debugPrint('Caches cleared for user switch: $oldUserId → $newUserId');
    } catch (e) {
      debugPrint('Error clearing caches during user switch: $e');
    }
  }

  /// Initialize FCM token when user is loaded
  Future<void> _initializeFCMForUser(String userId) async {
    try {
      final notificationRepo = _ref.read(notificationRepositoryProvider);

      final fcmToken = await notificationRepo.getUserFCMToken();

      // Initialize FCM service
      await notificationRepo.initializeFCM();

      // Update FCM token for this user
      await notificationRepo.updateFCMToken(fcmToken);

      debugPrint('FCM token initialized for user: $userId');
    } catch (e) {
      debugPrint('Error initializing FCM for user $userId: $e');
    }
  }
}

// Update provider to pass ref
final currentUserProvider =
    StateNotifierProvider<CurrentUserController, AsyncValue<UserModel?>>((ref) {
  return CurrentUserController(ref);
});
