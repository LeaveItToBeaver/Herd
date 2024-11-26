// lib/features/auth/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthNotifier extends StateNotifier<User?> {
  final FirebaseAuth _auth;

  AuthNotifier(this._auth) : super(_auth.currentUser) {
    _auth.authStateChanges().listen((user) {
      state = user;
    });
  }

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signIn(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = userCredential.user;
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred';
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
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An error occurred';
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, User?>((ref) {
  return AuthNotifier(FirebaseAuth.instance);
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  final authNotifier = ref.watch(authProvider.notifier);
  return authNotifier.authStateChanges();
});