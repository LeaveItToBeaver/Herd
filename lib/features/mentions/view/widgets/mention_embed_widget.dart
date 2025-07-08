import 'package:flutter/material.dart';
import 'package:herdapp/features/rich_text_editing/models/user_mention_embed.dart';

class MentionEmbedWidget extends StatelessWidget {
  final MentionData mention;
  final bool readOnly;
  final VoidCallback? onTap;

  const MentionEmbedWidget({
    super.key,
    required this.mention,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: readOnly ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          '@${mention.username}',
          style: TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
