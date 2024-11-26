import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/view/providers/auth_provider.dart';
import '../../data/mappers/user_to_user_model.dart';
import '../providers/profile_controller_provider.dart';

class ProfileButton extends ConsumerWidget {
  final bool isCurrentUser;
  final bool isFollowing;


  const ProfileButton({
    super.key,
    required this.isCurrentUser,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider);
    final theme = Theme.of(context);
    final firebaseUser = ref.read(authProvider); // Firebase User
    final userModel = userToUserModel(firebaseUser!);

    if (isCurrentUser && user != null) {
      return FilledButton.tonal(
        onPressed: () {
          HapticFeedback.lightImpact();
          context.pushNamed('editProfile', extra: userModel);
        },
        child: const Text('Edit Profile'),
      );
    }

    return FilledButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        ref.read(profileControllerProvider.notifier)
            .toggleFollow(isFollowing);
      },
      style: FilledButton.styleFrom(
        backgroundColor: isFollowing
            ? theme.colorScheme.error
            : theme.colorScheme.primary,
      ),
      child: Text(isFollowing ? 'Unfollow' : 'Follow'),
    );
  }
}
