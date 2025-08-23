import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/providers/exception_logger_provider.dart';
import '../../../../../core/services/exception_logging_service.dart';
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

  AuthNotifier(this._auth, this._logger, this._ref) : super(_auth.currentUser) {
    _authStateSubscription = _auth.authStateChanges().listen((user) {
      if (mounted) {
        // Only update state if the widget is still mounted
        state = user;
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
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
      debugPrint('🔄 Starting logout process...');
      
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
      
      debugPrint('✅ Logout completed successfully');
    } catch (e) {
      debugPrint('❌ Error during logout: $e');
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

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.authStateChanges();
});
