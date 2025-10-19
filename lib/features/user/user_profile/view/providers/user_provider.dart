import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/view/providers/auth_provider.dart';

part 'user_provider.g.dart';

// Stream provider for real-time user updates
@riverpod
Stream<UserModel?> userStream(Ref ref, String userId) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return null;
    return UserModel.fromMap(doc.id, doc.data()!);
  });
}

// Future provider for one-time user fetches
@riverpod
Future<UserModel?> user(Ref ref, String userId) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (!doc.exists) return null;
  return UserModel.fromMap(doc.id, doc.data()!);
}

// Current user stream provider
@riverpod
Stream<UserModel?> currentUserStream(Ref ref) {
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
}
