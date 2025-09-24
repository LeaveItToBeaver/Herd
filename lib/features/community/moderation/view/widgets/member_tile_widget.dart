import 'package:flutter/material.dart';
import 'package:herdapp/features/community/herds/data/models/herd_member_info.dart';

class MemberTile extends StatelessWidget {
  final HerdMemberInfo member;
  final String herdId;
  final String currentUserId;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MemberTile({
    super.key,
    required this.member,
    required this.herdId,
    required this.currentUserId,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: member.displayProfileImage != null
              ? NetworkImage(member.displayProfileImage!)
              : null,
          child: member.displayProfileImage == null
              ? Text(member.displayUsername.substring(0, 1).toUpperCase())
              : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                member.displayUsername,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (member.isModerator)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Text(
                  'MOD',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            if (member.isVerified)
              const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.verified, color: Colors.blue, size: 16),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (member.displayBio != null) Text(member.displayBio!),
            const SizedBox(height: 4),
            Text(
              'Joined ${_formatDate(member.joinedAt)} • ${member.displayUserPoints} points',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: isMultiSelectMode
            ? Checkbox(
                value: isSelected,
                onChanged: (_) => onTap(),
              )
            : const Icon(Icons.more_vert),
        onTap: onTap,
        onLongPress: onLongPress,
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() == 1 ? '' : 's'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else {
      return 'Today';
    }
  }
}
