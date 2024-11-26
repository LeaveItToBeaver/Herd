import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

class CurrentUserController extends StateNotifier<UserModel?> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CurrentUserController() : super(null);

  Future<void> fetchCurrentUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
        if (doc.exists) {
          state = UserModel.fromMap(doc.id, doc.data()!);
        } else {
          throw Exception('User not found in Firestore');
        }
      }
    } catch (e) {
      state = null;
      throw Exception('Failed to fetch current user: $e');
    }
  }
}

final currentUserProvider =
StateNotifierProvider<CurrentUserController, UserModel?>((ref) {
  final controller = CurrentUserController();
  controller.fetchCurrentUser();
  return controller;
});
