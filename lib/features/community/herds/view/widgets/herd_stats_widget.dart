// lib/features/herds/view/widgets/herd_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:herdapp/features/community/herds/data/models/herd_model.dart';

class HerdStats extends StatelessWidget {
  final HerdModel herd;
  final bool isCreatorOrMod;
  final VoidCallback? onEditPressed;

  const HerdStats({
    super.key,
    required this.herd,
    required this.isCreatorOrMod,
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Herd Stats',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (isCreatorOrMod)
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: onEditPressed,
                    tooltip: 'Edit Herd',
                  ),
              ],
            ),
            const Divider(),
            _buildStatRow(context, 'Members', '${herd.memberCount}'),
            _buildStatRow(context, 'Posts', '${herd.postCount}'),
            _buildStatRow(context, 'Created', _formatDate(herd.createdAt)),
            _buildStatRow(
                context, 'Privacy', herd.isPrivate ? 'Private' : 'Public'),
            if (herd.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'About',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(herd.description),
            ],
            if (isCreatorOrMod &&
                (herd.rules.isNotEmpty || herd.faq.isNotEmpty)) ...[
              const SizedBox(height: 16),
              Text(
                'Herd Management',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (herd.rules.isNotEmpty)
                _buildManagementItem(context, 'Rules',
                    'Community guidelines and rules', Icons.rule),
              if (herd.faq.isNotEmpty)
                _buildManagementItem(context, 'FAQ',
                    'Frequently asked questions', Icons.question_answer),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildManagementItem(
      BuildContext context, String title, String subtitle, IconData icon) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Navigate to specific management view
        },
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}
