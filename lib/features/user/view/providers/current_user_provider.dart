import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

class CurrentUserController extends StateNotifier<AsyncValue<UserModel?>> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CurrentUserController() : super(const AsyncValue.loading()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      if (user == null) {
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
        state = const AsyncValue.data(null);
        return;
      }

      final doc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        state = AsyncValue.data(UserModel.fromMap(doc.id, doc.data()!));
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

// Update provider
final currentUserProvider =
    StateNotifierProvider<CurrentUserController, AsyncValue<UserModel?>>((ref) {
  return CurrentUserController();
});
