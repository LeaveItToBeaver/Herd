import 'package:flutter/material.dart';
import 'package:herdapp/features/user/user_profile/view/widgets/profile_button.dart';

class ProfileStats extends StatelessWidget {
  final bool isCurrentUser;
  final bool isFollowing;
  final int? followers;
  final int? following;

  const ProfileStats({
    super.key,
    required this.isCurrentUser,
    required this.isFollowing,
    required this.followers,
    required this.following,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _Stat(
                count: followers,
                label: 'Followers',
                theme: theme,
              ),
              _Stat(
                count: following,
                label: 'Following',
                theme: theme,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ProfileButton(
            isCurrentUser: isCurrentUser,
            isFollowing: isFollowing,
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final int? count;
  final String label;
  final ThemeData theme;

  const _Stat({
    required this.count,
    required this.label,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
