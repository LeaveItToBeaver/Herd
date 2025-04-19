import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/exception_logger_provider.dart';
import '../../../../core/services/exception_logging_service.dart';

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;
  final ExceptionLoggerService _logger;

  AuthNotifier(this._auth, this._logger) : super(_auth.currentUser) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e, stack) {
      await _logger.logException(
        errorMessage: e.message ?? 'Auth error',
        stackTrace: stack.toString(),
        errorCode: e.code,
        action: 'signIn',
        route: 'LoginScreen',
        errorDetails: {'email': email},
      );
      rethrow; // rethrow the FirebaseAuthException itself
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
    await _auth.signOut();
    state = null;
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
  return AuthNotifier(FirebaseAuth.instance, exceptionLogger);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.authStateChanges();
});
