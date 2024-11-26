import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

// Provider to fetch user data by ID
final userProvider = FutureProvider.family<UserModel, String>((ref, authorId) async {
  final doc = await FirebaseFirestore.instance.collection('users').doc(authorId).get();
  if (doc.exists) {
    return UserModel.fromMap(doc.id, doc.data()!);
  } else {
    throw Exception('User not found');
  }
});
