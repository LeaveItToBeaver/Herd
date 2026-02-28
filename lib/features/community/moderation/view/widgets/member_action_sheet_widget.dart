import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/community/herds/data/models/herd_member_info.dart';
import 'package:herdapp/features/community/moderation/data/models/herd_role.dart';
import 'package:herdapp/features/community/moderation/data/models/permission_matrix.dart';
import 'package:herdapp/features/community/moderation/data/repositories/moderation_repository.dart';
import 'package:herdapp/features/community/moderation/view/providers/moderation_providers.dart';
import 'package:herdapp/features/community/moderation/view/providers/role_providers.dart';
import 'package:herdapp/features/community/moderation/view/widgets/suspend_member_dialog_widget.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';

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

    final roleAsync = ref.watch(currentUserRoleProvider(herdId));

    return roleAsync.when(
      loading: () => const SizedBox(
        height: 120,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => SizedBox(
        height: 120,
        child: Center(child: Text('Error loading permissions: $error')),
      ),
      data: (role) {
        if (role == null) return const SizedBox();

        final isSelf = member.userId == currentUser.uid;
        final canActOnMember = !isSelf && role.outranks(member.role);
        // Current UI only supports promoting members to moderator.
        final promotionPermission = HerdPermission.promoteToMod;
        final canPromote = canActOnMember &&
            PermissionMatrix.hasPermission(role, promotionPermission) &&
            !member.hasModeratorPrivileges;
        final canDemote = canActOnMember &&
            PermissionMatrix.hasPermission(role, HerdPermission.demoteFromMod) &&
            member.hasModeratorPrivileges;
        final canSuspend = canActOnMember &&
            PermissionMatrix.hasPermission(role, HerdPermission.muteUser);
        final canBan = canActOnMember &&
            PermissionMatrix.hasPermission(role, HerdPermission.banUser);
        final canRemove = canActOnMember &&
            PermissionMatrix.hasPermission(role, HerdPermission.kickUser);
        final canTransferOwnership = !isSelf &&
            role == HerdRole.owner &&
            PermissionMatrix.hasPermission(role, HerdPermission.transferOwnership);

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
              if (canPromote)
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings, color: Colors.blue),
                  title: const Text('Make Moderator'),
                  onTap: () {
                    final controller =
                        ref.read(moderationControllerProvider.notifier);
                    Navigator.pop(context);
                    _makeModeratorActionWithNotifier(context, controller);
                  },
                ),
              if (canDemote)
                ListTile(
                  leading:
                      const Icon(Icons.remove_moderator, color: Colors.orange),
                  title: const Text('Remove Moderator'),
                  onTap: () {
                    final controller =
                        ref.read(moderationControllerProvider.notifier);
                    Navigator.pop(context);
                    _removeModeratorWithNotifier(context, controller);
                  },
                ),
              if (canSuspend)
                ListTile(
                  leading: const Icon(Icons.schedule, color: Colors.deepOrange),
                  title: const Text('Suspend Member'),
                  onTap: () {
                    Navigator.pop(context);
                    _showSuspendDialog(context);
                  },
                ),
              if (canBan)
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
              if (canRemove)
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
              if (canTransferOwnership)
                ListTile(
                  leading: const Icon(Icons.swap_horiz, color: Colors.purple),
                  title: const Text('Transfer Ownership'),
                  subtitle: const Text('Make this user the new owner'),
                  onTap: () {
                    final controller =
                        ref.read(moderationControllerProvider.notifier);
                    Navigator.pop(context);
                    _showTransferOwnershipDialog(context, controller);
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
      },
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

  void _showTransferOwnershipDialog(
      BuildContext context, ModerationController moderationController) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer Ownership to ${member.displayUsername}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This action is irreversible. You will be demoted to Admin and lose owner privileges.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text('${member.displayUsername} will become the new owner of this herd.'),
            const SizedBox(height: 8),
            const Text(
              'As an Admin, you will retain moderation abilities but cannot:',
            ),
            const SizedBox(height: 4),
            const Text('  • Delete the herd'),
            const Text('  • Transfer ownership'),
            const Text('  • Promote users to Admin'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              final username = member.displayUsername;

              navigator.pop();

              try {
                await moderationController.transferOwnership(
                  herdId: herdId,
                  newOwnerId: member.userId,
                );

                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Ownership transferred to $username'),
                    backgroundColor: Colors.green,
                  ),
                );
              } catch (e) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Failed to transfer ownership: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Transfer Ownership'),
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
