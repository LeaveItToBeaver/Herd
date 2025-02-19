import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

import '../../../auth/view/providers/auth_provider.dart';

// Stream provider for real-time user updates
final userStreamProvider = StreamProvider.family<UserModel?, String>((ref, userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  });
});

// Future provider for one-time user fetches
final userProvider = FutureProvider.family<UserModel?, String>((ref, userId) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .get();

  if (!doc.exists) return null;
  return UserModel.fromMap(doc.id, doc.data()!);
});

// Current user stream provider
final currentUserStreamProvider = StreamProvider<UserModel?>((ref) {
  final auth = ref.watch(authProvider);
  if (auth == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(auth.uid)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  });
});