import 'package:firebase_auth/firebase_auth.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

UserModel userToUserModel(User firebaseUser, {String? bio, String? profileImageURL, String? coverImageURL}) {
  return UserModel.fromFirebaseUser(
    firebaseUser.uid,
    firebaseUser.email,
    firebaseUser.displayName,
    bio: bio,
    profileImageURL: profileImageURL,
    coverImageURL: coverImageURL,
  );
}