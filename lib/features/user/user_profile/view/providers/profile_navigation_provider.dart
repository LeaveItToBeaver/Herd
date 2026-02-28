import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/view/providers/auth_provider.dart';

part 'profile_navigation_provider.g.dart';

// Provider to help with profile navigation
@riverpod
ProfileNavigation profileNavigation(Ref ref) => ProfileNavigation(ref);

class ProfileNavigation {
  final Ref ref;

  ProfileNavigation(this.ref);

  void navigateToProfile(BuildContext context, String userId) {
    final currentUserId = ref.read(authProvider)?.uid;
    if (userId == currentUserId) {
      // Navigate to current user profile
      context.goNamed('profile');
    } else {
      // Navigate to other user profile
      context.goNamed(
        'userProfile',
        pathParameters: {'userId': userId},
      );
    }
  }
}
