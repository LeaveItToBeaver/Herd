import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/moderation/data/models/moderation_action_model.dart';
import '../providers/moderation_providers.dart';

class ModerationLogScreen extends ConsumerWidget {
  final String herdId;

  const ModerationLogScreen({
    super.key,
    required this.herdId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moderationLogAsync = ref.watch(herdModerationLogProvider(herdId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Log'),
      ),
      body: moderationLogAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (actions) {
          if (actions.isEmpty) {
            return const Center(
              child: Text('No moderation actions yet'),
            );
          }

          return ListView.builder(
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return _buildActionTile(context, action);
            },
          );
        },
      ),
    );
  }

  Widget _buildActionTile(BuildContext context, ModerationAction action) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: action.actionType.color.withValues(alpha: 0.2),
          child: Icon(
            action.actionType.icon,
            color: action.actionType.color,
          ),
        ),
        title: Text(action.actionType.displayName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('By: ${action.performedBy}'),
            if (action.reason != null) Text('Reason: ${action.reason}'),
            Text(_formatDate(action.timestamp)),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
