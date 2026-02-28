import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:firebase_auth/firebase_auth.dart';

part 'firebase_auth_provider.g.dart';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) {
  return FirebaseAuth.instance;
}

@riverpod
Stream<User?> authState(Ref ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
}
