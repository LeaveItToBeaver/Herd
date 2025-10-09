import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/exception_logger_provider.dart';
import '../../../../../core/services/exception_logging_service.dart';
import '../../../../../core/utils/keystore_recovery_helper.dart';
import '../../../../social/chat_messaging/data/cache/message_cache_service.dart';
import '../../../../social/chat_messaging/view/providers/chat_provider.dart';
import '../../../../social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import '../../../../social/floating_buttons/providers/chat_animation_provider.dart';
import '../../../../../core/bootstrap/app_bootstraps.dart';

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;
  final ExceptionLoggerService _logger;
  final Ref _ref;
  StreamSubscription<User?>? _authStateSubscription;
  bool _initialEventReceived = false;
  DateTime? _firstEventTime;

  bool get isInitialEventReceived => _initialEventReceived;

  AuthNotifier(this._auth, this._logger, this._ref) : super(_auth.currentUser) {
    debugPrint('🔐 AuthNotifier constructed. Initial currentUser: '
        '${_auth.currentUser?.uid ?? 'null'}');

    // Check Firebase Auth persistence settings and keystore health
    _checkAuthPersistence();

    _authStateSubscription = _auth.authStateChanges().listen((user) {
      if (mounted) {
        if (!_initialEventReceived) {
          _initialEventReceived = true;
          _firstEventTime = DateTime.now();
          debugPrint(
              '🔐 First auth event received. user=${user?.uid ?? 'null'}');
          debugPrint(
              '🔐 Auth persistence check - emailVerified: ${user?.emailVerified}');

          // Mark readiness flag so UI can proceed
          _ref.read(_authReadyFlagProvider.notifier).state = true;

          // Handle keystore recovery logic
          _handleAuthStateRestoration(user);
        }
        if (state?.uid != user?.uid) {
          debugPrint(
              'Auth state change: ${state?.uid ?? 'null'} -> ${user?.uid ?? 'null'}');
          if (user != null) {
            debugPrint(
                'User details - email: ${user.email}, verified: ${user.emailVerified}');
          }
        }
        state = user;
      }
    }, onError: (err, stack) {
      debugPrint('Auth stream error: $err');
      // Still mark as ready even if there's an error - don't block the UI
      if (!_initialEventReceived) {
        _initialEventReceived = true;
        _ref.read(_authReadyFlagProvider.notifier).state = true;
      }
    });
  }

  /// Handle auth state restoration and keystore corruption detection
  Future<void> _handleAuthStateRestoration(User? user) async {
    try {
      if (user != null) {
        // User was restored from persistence - mark this success
        await KeystoreRecoveryHelper.markSessionRestored();
        debugPrint('Auth session restored successfully');
      } else {
        // No user restored - check if we should have expected one
        final shouldExpectAuth =
            await KeystoreRecoveryHelper.shouldExpectAuthSession();
        if (shouldExpectAuth) {
          final isCorrupted =
              await KeystoreRecoveryHelper.detectKeystoreCorruption();
          if (isCorrupted) {
            debugPrint(
                '🚨 Keystore corruption detected - user will need to log in again');
            await KeystoreRecoveryHelper.logKeystoreCorruptionDetails();
          }
        }
      }
    } catch (e) {
      debugPrint('Error in auth state restoration handling: $e');
    }
  }

  Future<void> _checkAuthPersistence() async {
    try {
      // On mobile platforms, Firebase Auth persistence is enabled by default
      // setPersistence() is only for web platforms
      if (kIsWeb) {
        await _auth.setPersistence(Persistence.LOCAL);
        debugPrint('Firebase Auth web persistence set to LOCAL');
      } else {
        // On mobile, check if we have a current user from persistence
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          debugPrint(
              'Firebase Auth mobile persistence working - user: ${currentUser.uid}');
        } else {
          debugPrint('ℹ️ Firebase Auth mobile persistence - no stored user');

          // Check if this might be due to keystore corruption
          // Look for telltale signs in recent logs
          debugPrint('🔍 Checking for potential keystore corruption issues...');

          // Try to detect if we should have a user but persistence failed
          // This is a heuristic - in a real app you might store a flag in SharedPreferences
          // indicating that a user was previously logged in
          _checkForKeystoreIssues();
        }
      }
    } catch (e) {
      debugPrint('Could not configure auth persistence: $e');
      // Check if this error is keystore-related
      if (e.toString().toLowerCase().contains('keystore') ||
          e.toString().toLowerCase().contains('keysetmanager')) {
        debugPrint('🔧 Detected keystore-related auth persistence issue');
        _handleKeystoreAuthIssue();
      }
    }
  }

  void _checkForKeystoreIssues() async {
    // Use the keystore recovery helper to detect corruption
    try {
      final isCorrupted =
          await KeystoreRecoveryHelper.detectKeystoreCorruption();
      if (isCorrupted) {
        debugPrint('� Keystore corruption detected during auth check');
        await KeystoreRecoveryHelper.logKeystoreCorruptionDetails();
      } else {
        debugPrint(
            '� No stored Firebase Auth user found, no keystore corruption detected');
      }
    } catch (e) {
      debugPrint('Error checking for keystore issues: $e');
    }
  }

  void _handleKeystoreAuthIssue() {
    debugPrint('🔧 Handling keystore-related auth issue');
    debugPrint(
        'Firebase Auth persistence may be affected by keystore corruption');
    debugPrint('💡 User will need to log in again');

    // In a production app, you might want to:
    // 1. Clear any corrupted auth tokens
    // 2. Show a user-friendly message about needing to log in again
    // 3. Optionally try to reset the keystore if possible
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      debugPrint('🔐 Attempting sign in for: $email');
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      debugPrint('Sign in successful for user: ${userCredential.user?.uid}');

      // Mark successful authentication for keystore recovery tracking
      await KeystoreRecoveryHelper.markSuccessfulAuth();

      // After successful sign in, check if persistence is working
      Future.delayed(const Duration(milliseconds: 500), () {
        final currentUser = _auth.currentUser;
        if (currentUser != null) {
          debugPrint(
              'Post-login persistence check: user ${currentUser.uid} is persisted');
        } else {
          debugPrint(
              'Post-login persistence check: user not persisted (keystore issue)');
        }
      });

      return userCredential;
    } on FirebaseAuthException catch (e, stack) {
      // For debugging - debugPrint the actual error code
      debugPrint("Firebase Auth Error Code: ${e.code}");
      debugPrint("Firebase Auth Error Message: ${e.message}");

      // Try to log the exception but safely
      try {
        _logger.logException(
          errorMessage: e.message ?? 'Auth error',
          stackTrace: stack.toString(),
          errorCode: e.code,
          action: 'signIn',
          route: 'LoginScreen',
          errorDetails: {'email': email},
        ).catchError((loggingError) {
          debugPrint('Error logging exception: $loggingError');
          return null;
        });
      } catch (loggingError) {
        debugPrint('Error logging exception: $loggingError');
      }

      // Always rethrow the original auth exception
      rethrow;
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = userCredential.user;
      return userCredential;
    } on FirebaseAuthException catch (e, stack) {
      // Log the specific Firebase Auth exception
      await _logger.logException(
          errorMessage: e.message ?? 'Unknown authentication error',
          stackTrace: stack.toString(),
          errorCode: e.code,
          action: 'signUp',
          route: 'LoginScreen',
          errorDetails: {'email': email});
      throw e.message ?? 'An error occurred';
    } catch (e, stack) {
      // Log generic exceptions
      await _logger.logException(
          errorMessage: e.toString(),
          stackTrace: stack.toString(),
          action: 'signUp',
          route: 'LoginScreen');
      throw 'An error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('Starting logout process...');

      // 1. Clear chat message caches
      final messageCache = _ref.read(messageCacheServiceProvider);
      await messageCache.clearAllCaches();

      // 2. Reset chat providers state
      _ref.invalidate(chatStateProvider);
      _ref.invalidate(chatPaginationProvider);

      // 3. Reset chat bubbles and animation state
      _ref.invalidate(chatBubblesEnabledProvider);
      _ref.invalidate(chatClosingAnimationProvider);
      _ref.invalidate(herdClosingAnimationProvider);
      _ref.invalidate(bubbleAnimationCallbackProvider);
      _ref.invalidate(explosionRevealProvider);

      // 4. Clean up notifications
      final bootstrap = _ref.read(AppBootstrap.appBootstrapProvider);
      bootstrap.resetNotifications();

      // 5. Sign out from Firebase Auth
      await _auth.signOut();
      state = null;

      debugPrint('Logout completed successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      // Still try to sign out even if cleanup fails
      await _auth.signOut();
      state = null;
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e, stack) {
      // Log the specific Firebase Auth exception
      await _logger.logException(
          errorMessage: e.message ?? 'Unknown authentication error',
          stackTrace: stack.toString(),
          errorCode: e.code,
          action: 'resetPassword',
          route: 'LoginScreen',
          errorDetails: {'email': email});
      throw e.message ?? 'An error occurred';
    } catch (e, stack) {
      // Log generic exceptions
      await _logger.logException(
          errorMessage: e.toString(),
          stackTrace: stack.toString(),
          action: 'resetPassword',
          route: 'LoginScreen');
      throw 'An error occurred';
    }
  }

  Future<bool> isEmailVerified() async {
    try {
      _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      return false;
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  final exceptionLogger = ref.watch(exceptionLoggerProvider);
  return AuthNotifier(FirebaseAuth.instance, exceptionLogger, ref);
});
// Internal readiness flag provider (state updated once first auth event arrives)
final _authReadyFlagProvider = StateProvider<bool>((_) => false);

/// Public provider exposing readiness
final authReadyProvider =
    Provider<bool>((ref) => ref.watch(_authReadyFlagProvider));

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.authStateChanges();
});
