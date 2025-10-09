import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';

class BatchActionSheet extends ConsumerWidget {
  final List<String> selectedUserIds;
  final String herdId;
  final VoidCallback onComplete;

  const BatchActionSheet({
    super.key,
    required this.selectedUserIds,
    required this.herdId,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('${selectedUserIds.length} members selected'),
            subtitle:
                const Text('Choose an action to apply to all selected members'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.deepOrange),
            title: const Text('Suspend All'),
            onTap: () {
              Navigator.pop(context);
              _showBatchSuspendDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Ban All'),
            onTap: () {
              Navigator.pop(context);
              _showBatchBanDialog(context, ref);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove, color: Colors.red),
            title: const Text('Remove All from Herd'),
            onTap: () {
              Navigator.pop(context);
              _showBatchRemoveDialog(context, ref);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.cancel, color: Colors.grey),
            title: const Text('Cancel'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showBatchSuspendDialog(BuildContext context, WidgetRef ref) {
    DateTime suspendUntil = DateTime.now().add(const Duration(days: 1));
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Suspend ${selectedUserIds.length} Members'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select suspension end date and time:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('End Date'),
                  subtitle: Text(
                      '${suspendUntil.day}/${suspendUntil.month}/${suspendUntil.year}'),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: suspendUntil,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        suspendUntil = DateTime(
                          date.year,
                          date.month,
                          date.day,
                          suspendUntil.hour,
                          suspendUntil.minute,
                        );
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.access_time),
                  title: const Text('End Time'),
                  subtitle: Text(
                    '${suspendUntil.hour.toString().padLeft(2, '0')} : ${suspendUntil.minute.toString().padLeft(2, '0')}',
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(suspendUntil),
                    );
                    if (time != null) {
                      setDialogState(() {
                        suspendUntil = DateTime(
                          suspendUntil.year,
                          suspendUntil.month,
                          suspendUntil.day,
                          time.hour,
                          time.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: reasonController,
                  decoration: const InputDecoration(
                    labelText: 'Reason (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
              onPressed: () async {
                // Capture dependencies before popping the sheet/dialog
                final moderationRepo = ref.read(moderationRepositoryProvider);
                final currentUserId = ref.read(authProvider)?.uid;
                Navigator.pop(context);
                await _performBatchSuspendWithDeps(
                  context,
                  moderationRepo,
                  currentUserId,
                  suspendUntil,
                  reasonController.text.trim(),
                );
                onComplete();
              },
              child: const Text('Suspend All'),
            ),
          ],
        ),
      ),
    );
  }

  void _showBatchBanDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ban ${selectedUserIds.length} Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'This will permanently ban ${selectedUserIds.length} users from this herd.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              // Capture notifier before popping to avoid using ref after dispose
              final moderationController =
                  ref.read(moderationControllerProvider.notifier);
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              await _performBatchBanWithNotifier(
                context,
                moderationController,
                reason,
              );
              onComplete();
            },
            child: const Text('Ban All'),
          ),
        ],
      ),
    );
  }

  void _showBatchRemoveDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${selectedUserIds.length} Members'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
                'This will remove ${selectedUserIds.length} users from this herd. They can rejoin if they want.'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () async {
              // Capture repo and uid before popping to avoid using ref after dispose
              final moderationRepo = ref.read(moderationRepositoryProvider);
              final currentUserId = ref.read(authProvider)?.uid;
              final reason = reasonController.text.trim();
              Navigator.pop(context);
              await _performBatchRemoveWithDeps(
                context,
                moderationRepo,
                currentUserId,
                reason,
              );
              onComplete();
            },
            child: const Text('Remove All'),
          ),
        ],
      ),
    );
  }

  Future<void> _performBatchSuspendWithDeps(
    BuildContext context,
    ModerationRepository moderationRepo,
    String? currentUserId,
    DateTime suspendUntil,
    String reason,
  ) async {
    if (currentUserId == null) return;

    int successful = 0;
    int failed = 0;

    for (final userId in selectedUserIds) {
      try {
        await moderationRepo.suspendUserFromHerd(
          herdId: herdId,
          userId: userId,
          moderatorId: currentUserId,
          suspendedUntil: suspendUntil,
          reason: reason.isEmpty ? null : reason,
        );
        successful++;
      } catch (e) {
        failed++;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Suspended $successful users${failed > 0 ? ', $failed failed' : ''}',
          ),
        ),
      );
    }
  }

  Future<void> _performBatchBanWithNotifier(
    BuildContext context,
    ModerationController moderationController,
    String reason,
  ) async {
    int successful = 0;
    int failed = 0;

    for (final userId in selectedUserIds) {
      try {
        await moderationController.banUser(
          herdId: herdId,
          userId: userId,
          reason: reason.isEmpty ? null : reason,
        );
        successful++;
      } catch (e) {
        failed++;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Banned $successful users${failed > 0 ? ', $failed failed' : ''}',
          ),
        ),
      );
    }
  }

  Future<void> _performBatchRemoveWithDeps(
    BuildContext context,
    ModerationRepository moderationRepo,
    String? currentUserId,
    String reason,
  ) async {
    if (currentUserId == null) return;

    int successful = 0;
    int failed = 0;

    for (final userId in selectedUserIds) {
      try {
        await moderationRepo.removeMemberFromHerd(
          herdId: herdId,
          userId: userId,
          moderatorId: currentUserId,
          reason: reason.isEmpty ? null : reason,
        );
        successful++;
      } catch (e) {
        failed++;
      }
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Removed $successful users${failed > 0 ? ', $failed failed' : ''}',
          ),
        ),
      );
    }
  }
}
