import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final String username;
  final String bio;

  const ProfileInfo({
    super.key,
    required this.username,
    required this.bio,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          username,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            bio,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ],
    );
  }
}
