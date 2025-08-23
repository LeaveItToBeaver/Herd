// lib/features/content/post/view/widgets/shared/post_type_indicators.dart
import 'package:flutter/material.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

class PostTypeIndicators extends StatelessWidget {
  final PostModel post;

  const PostTypeIndicators({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicators = <Widget>[];

    // Alt post indicator
    if (post.isAlt && !post.isNSFW) {
      indicators.add(_TypeIndicator(
        icon: Icons.public,
        label: 'Alt Post',
        color: theme.colorScheme.primary,
      ));
    }

    // Alt post with NSFW
    if (post.isAlt && post.isNSFW) {
      indicators.add(_TypeIndicator(
        icon: Icons.public,
        label: 'Alt Post (NSFW)',
        color: Colors.redAccent,
      ));
    }

    // NSFW indicator for non-alt posts
    if (!post.isAlt && post.isNSFW) {
      indicators.add(_TypeIndicator(
        icon: Icons.warning_amber_rounded,
        label: 'NSFW Content',
        color: Colors.red,
      ));
    }

    // Herd post indicator
    if (post.herdId != null && post.herdId!.isNotEmpty && !post.isAlt) {
      indicators.add(_TypeIndicator(
        icon: Icons.group_outlined,
        label: 'Herd Post',
        color: theme.colorScheme.secondary,
      ));
    }

    if (indicators.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: indicators,
    );
  }
}

class _TypeIndicator extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TypeIndicator({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
