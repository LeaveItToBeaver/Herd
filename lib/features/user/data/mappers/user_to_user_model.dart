import 'package:firebase_auth/firebase_auth.dart';
import 'package:herdapp/features/user/data/models/user_model.dart';

UserModel userToUserModel(User firebaseUser, {String? bio, String? profileImageURL, String? coverImageURL}) {
  return UserModel(
    id: firebaseUser.uid,
    firstName: '', // Populate from Firestore or defaults
    lastName: '',
    username: firebaseUser.displayName ?? '',
    email: firebaseUser.email ?? '',
    createdAt: null, // Optional: Populate from Firestore
    updatedAt: null,
    followers: 0, // Optional: Populate from Firestore
    following: 0, // Optional: Populate from Firestore
    bio: bio,
    profileImageURL: profileImageURL,
    coverImageURL: coverImageURL,
  );
}
