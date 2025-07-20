import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final emailVerificationProvider = FutureProvider.autoDispose<bool>((ref) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Reload user to get the most recent data
    await user.reload();
    return user.emailVerified;
  } catch (e) {
    return false;
  }
});
