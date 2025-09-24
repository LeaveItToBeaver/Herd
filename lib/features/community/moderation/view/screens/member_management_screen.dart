import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../herds/data/models/herd_member_info.dart';
import '../../../herds/view/providers/herd_providers.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';
import '../providers/moderation_providers.dart';
import '../../data/repositories/moderation_repository.dart';

class MemberManagementScreen extends ConsumerStatefulWidget {
  final String herdId;

  const MemberManagementScreen({
    super.key,
    required this.herdId,
  });

  @override
  ConsumerState<MemberManagementScreen> createState() =>
      _MemberManagementScreenState();
}

class _MemberManagementScreenState
    extends ConsumerState<MemberManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _selectedMembers = {};
  bool _isMultiSelectMode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSelectAll(List<HerdMemberInfo> filteredMembers) {
    setState(() {
      if (_selectedMembers.length == filteredMembers.length) {
        _selectedMembers.clear();
      } else {
        _selectedMembers.clear();
        _selectedMembers.addAll(filteredMembers.map((m) => m.userId));
      }
    });
  }

  void _exitMultiSelect() {
    setState(() {
      _selectedMembers.clear();
      _isMultiSelectMode = false;
    });
  }

  List<HerdMemberInfo> _filterMembers(List<HerdMemberInfo> members) {
    if (_searchQuery.isEmpty) return members;

    final query = _searchQuery.toLowerCase();
    return members.where((member) {
      return member.displayUsername.toLowerCase().contains(query) ||
          (member.bio?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    final isModerator = ref.watch(isHerdModeratorProvider(widget.herdId));
    final membersAsync = ref.watch(herdMembersWithInfoProvider(widget.herdId));

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to access member management')),
      );
    }

    return isModerator.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
      data: (isModeratorResult) {
        if (!isModeratorResult) {
          return const Scaffold(
            body: Center(
              child: Text('You do not have permission to manage members'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: _isMultiSelectMode
                ? Text('${_selectedMembers.length} selected')
                : const Text('Manage Members'),
            actions: _isMultiSelectMode
                ? [
                    IconButton(
                      icon: const Icon(Icons.select_all),
                      onPressed: () => membersAsync.whenData((members) {
                        final filtered = _filterMembers(members);
                        _toggleSelectAll(filtered);
                      }),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: _exitMultiSelect,
                    ),
                  ]
                : null,
          ),
          body: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search members...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              // Members List
              Expanded(
                child: membersAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => Center(
                    child: Text('Error loading members: $error'),
                  ),
                  data: (members) {
                    final filteredMembers = _filterMembers(members);

                    if (filteredMembers.isEmpty) {
                      return Center(
                        child: Text(
                          _searchQuery.isEmpty
                              ? 'No members found'
                              : 'No members match your search',
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: filteredMembers.length,
                      itemBuilder: (context, index) {
                        final member = filteredMembers[index];
                        final isSelected =
                            _selectedMembers.contains(member.userId);

                        return MemberTile(
                          member: member,
                          herdId: widget.herdId,
                          currentUserId: currentUser.uid,
                          isSelected: isSelected,
                          isMultiSelectMode: _isMultiSelectMode,
                          onTap: () {
                            if (_isMultiSelectMode) {
                              setState(() {
                                if (isSelected) {
                                  _selectedMembers.remove(member.userId);
                                  if (_selectedMembers.isEmpty) {
                                    _isMultiSelectMode = false;
                                  }
                                } else {
                                  _selectedMembers.add(member.userId);
                                }
                              });
                            } else {
                              _showMemberActions(context, member);
                            }
                          },
                          onLongPress: () {
                            if (!_isMultiSelectMode) {
                              setState(() {
                                _isMultiSelectMode = true;
                                _selectedMembers.add(member.userId);
                              });
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          floatingActionButton:
              _isMultiSelectMode && _selectedMembers.isNotEmpty
                  ? FloatingActionButton.extended(
                      onPressed: () => _showBatchActions(context),
                      icon: const Icon(Icons.more_horiz),
                      label: const Text('Batch Actions'),
                    )
                  : null,
        );
      },
    );
  }

  void _showMemberActions(BuildContext context, HerdMemberInfo member) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MemberActionSheet(
        member: member,
        herdId: widget.herdId,
      ),
    );
  }

  void _showBatchActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BatchActionSheet(
        selectedUserIds: _selectedMembers.toList(),
        herdId: widget.herdId,
        onComplete: _exitMultiSelect,
      ),
    );
  }
}

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

class MemberActionSheet extends ConsumerWidget {
  final HerdMemberInfo member;
  final String herdId;

  const MemberActionSheet({
    super.key,
    required this.member,
    required this.herdId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: member.displayProfileImage != null
                  ? NetworkImage(member.displayProfileImage!)
                  : null,
              child: member.displayProfileImage == null
                  ? Text(member.displayUsername.substring(0, 1).toUpperCase())
                  : null,
            ),
            title: Text(member.displayUsername),
            subtitle: Text('Member since ${_formatDate(member.joinedAt)}'),
          ),
          const Divider(),
          if (!member.isModerator)
            ListTile(
              leading:
                  const Icon(Icons.admin_panel_settings, color: Colors.blue),
              title: const Text('Make Moderator'),
              onTap: () {
                final controller =
                    ref.read(moderationControllerProvider.notifier);
                Navigator.pop(context);
                _makeModeratorActionWithNotifier(context, controller);
              },
            ),
          if (member.isModerator)
            ListTile(
              leading: const Icon(Icons.remove_moderator, color: Colors.orange),
              title: const Text('Remove Moderator'),
              onTap: () {
                final controller =
                    ref.read(moderationControllerProvider.notifier);
                Navigator.pop(context);
                _removeModeratorWithNotifier(context, controller);
              },
            ),
          ListTile(
            leading: const Icon(Icons.schedule, color: Colors.deepOrange),
            title: const Text('Suspend Member'),
            onTap: () {
              Navigator.pop(context);
              _showSuspendDialog(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Ban Member'),
            onTap: () {
              final controller =
                  ref.read(moderationControllerProvider.notifier);
              Navigator.pop(context);
              _showBanDialogWithNotifier(context, controller);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person_remove, color: Colors.red),
            title: const Text('Remove from Herd'),
            onTap: () {
              final repo = ref.read(moderationRepositoryProvider);
              final uid = ref.read(authProvider)?.uid;
              Navigator.pop(context);
              if (uid != null) {
                _showRemoveDialogWithDeps(context, repo, uid);
              }
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

  void _makeModeratorActionWithNotifier(
      BuildContext context, ModerationController controller) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final username = member.displayUsername;

    try {
      await controller.addModerator(
        herdId: herdId,
        userId: member.userId,
      );

      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('$username is now a moderator')),
      );
    } catch (e) {
      scaffoldMessenger.showSnackBar(
        SnackBar(content: Text('Failed to make moderator: $e')),
      );
    }
  }

  void _removeModeratorWithNotifier(
      BuildContext context, ModerationController controller) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final username = member.displayUsername;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Moderator'),
        content: Text('Remove $username as a moderator?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await controller.removeModerator(
          herdId: herdId,
          userId: member.userId,
        );

        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('$username is no longer a moderator')),
        );
      } catch (e) {
        scaffoldMessenger.showSnackBar(
          SnackBar(content: Text('Failed to remove moderator: $e')),
        );
      }
    }
  }

  void _showSuspendDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SuspendMemberDialog(
        member: member,
        herdId: herdId,
      ),
    );
  }

  void _showBanDialogWithNotifier(
      BuildContext context, ModerationController moderationController) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ban ${member.displayUsername}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This will permanently ban the user from this herd.'),
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
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final username = member.displayUsername;
              final reason = reasonController.text.trim().isEmpty
                  ? null
                  : reasonController.text.trim();

              navigator.pop();

              try {
                await moderationController.banUser(
                  herdId: herdId,
                  userId: member.userId,
                  reason: reason,
                );

                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('$username has been banned')),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Failed to ban user: $e')),
                );
              }
            },
            child: const Text('Ban User'),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialogWithDeps(BuildContext context,
      ModerationRepository moderationRepo, String currentUserId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Remove ${member.displayUsername}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'This will remove the user from this herd. They can rejoin if they want.'),
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
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final username = member.displayUsername;
              final uid = currentUserId;
              final reason = reasonController.text.trim().isEmpty
                  ? null
                  : reasonController.text.trim();

              navigator.pop();

              try {
                await moderationRepo.removeMemberFromHerd(
                  herdId: herdId,
                  userId: member.userId,
                  moderatorId: uid,
                  reason: reason,
                );

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                      content:
                          Text('$username has been removed from the herd')),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(content: Text('Failed to remove user: $e')),
                );
              }
            },
            child: const Text('Remove User'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.day}/${date.month}/${date.year}';
  }
}

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
