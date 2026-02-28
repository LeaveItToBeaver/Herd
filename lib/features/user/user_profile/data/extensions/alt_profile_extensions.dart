import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:herdapp/features/user/user_profile/data/models/user_model.dart';

/// Extensions for alt-profile helpers (completeness, account creation,
/// linking, and privacy toggles).
extension AltProfileExtensions on UserModel {
  /// Whether the alt profile has the minimum required fields.
  bool get isAltProfileComplete {
    if (altUsername == null || altUsername!.isEmpty) return false;
    if (altProfileImageURL == null) return false;
    return true;
  }

  /// Whether the alt user is active.
  bool get isActiveAltUser => altIsActive && altAccountStatus == 'active';

  /// Create an alt account by stamping an alt UID + timestamps.
  UserModel createAltAccount(String altId) {
    return copyWith(
      altUserUID: altId,
      altCreatedAt: DateTime.now(),
      altUpdatedAt: DateTime.now(),
    );
  }

  /// Toggle privacy on either the public or alt profile.
  UserModel togglePrivacy({bool? forAltAccount = false}) {
    if (forAltAccount == true) {
      return copyWith(altIsPrivateAccount: !altIsPrivateAccount);
    }
    return copyWith(isPrivateAccount: !isPrivateAccount);
  }

  /// Link a public account and its alt account in Firestore.
  static Future<void> linkAccounts(
      String publicUserId, String altUserId) async {
    final batch = FirebaseFirestore.instance.batch();

    final publicRef =
        FirebaseFirestore.instance.collection('users').doc(publicUserId);
    final altRef =
        FirebaseFirestore.instance.collection('users').doc(altUserId);

    batch.update(publicRef, {'altUserUID': altUserId});
    batch.update(altRef, {'altUserUID': publicUserId});

    await batch.commit();
  }
}
