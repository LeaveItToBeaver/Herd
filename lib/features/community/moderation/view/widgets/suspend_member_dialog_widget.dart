import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/community/herds/data/models/herd_member_info.dart';

class SuspendMemberDialog extends ConsumerStatefulWidget {
  final HerdMemberInfo member;
  final String herdId;

  const SuspendMemberDialog({
    super.key,
    required this.member,
    required this.herdId,
  });

  @override
  ConsumerState<SuspendMemberDialog> createState() =>
      _SuspendMemberDialogState();
}

class _SuspendMemberDialogState extends ConsumerState<SuspendMemberDialog> {
  DateTime _suspendUntil = DateTime.now().add(const Duration(days: 1));
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Suspend ${widget.member.displayUsername}'),
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
                  '${_suspendUntil.day}/${_suspendUntil.month}/${_suspendUntil.year}'),
              onTap: _selectDate,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('End Time'),
              subtitle: Text(
                  '${_suspendUntil.hour.toString().padLeft(2, '0')}:${_suspendUntil.minute.toString().padLeft(2, '0')}'),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _reasonController,
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
          style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange),
          onPressed: _suspendUser,
          child: const Text('Suspend'),
        ),
      ],
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _suspendUntil,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _suspendUntil = DateTime(
          date.year,
          date.month,
          date.day,
          _suspendUntil.hour,
          _suspendUntil.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_suspendUntil),
    );

    if (time != null) {
      setState(() {
        _suspendUntil = DateTime(
          _suspendUntil.year,
          _suspendUntil.month,
          _suspendUntil.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _suspendUser() async {
    final navigator = Navigator.of(context);
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final username = widget.member.displayUsername;
    final currentUserId = ref.read(authProvider)!.uid;
    // Capture repo before awaiting to avoid using ref after dispose
    final moderationRepo = ref.read(moderationRepositoryProvider);
    final reason = _reasonController.text.trim().isEmpty
        ? null
        : _reasonController.text.trim();

    try {
      await moderationRepo.suspendUserFromHerd(
        herdId: widget.herdId,
        userId: widget.member.userId,
        moderatorId: currentUserId,
        suspendedUntil: _suspendUntil,
        reason: reason,
      );
      if (!mounted) return;
      navigator.pop();
      scaffoldMessenger.showSnackBar(
        SnackBar(
            content: Text(
                '$username has been suspended until ${_suspendUntil.day}/${_suspendUntil.month}/${_suspendUntil.year}')),
      );
    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to suspend user: $e')),
      );
    }
  }
}
