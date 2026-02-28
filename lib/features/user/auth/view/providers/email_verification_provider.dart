import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'email_verification_provider.g.dart';

@riverpod
Future<bool> emailVerification(Ref ref) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    // Reload user to get the most recent data
    await user.reload();

    if (!ref.mounted) return false;
    return user.emailVerified;
  } catch (e) {
    return false;
  }
}
