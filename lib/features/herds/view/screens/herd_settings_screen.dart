import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/moderation/data/models/moderation_action_model.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../data/models/herd_model.dart';
import '../providers/herd_providers.dart';
import '../../../moderation/view/screens/moderation_dashboard_screen.dart';
import '../../../moderation/view/screens/member_management_screen.dart';
import '../../../moderation/view/screens/moderation_log_screen.dart';

class HerdSettingsScreen extends ConsumerWidget {
  final HerdModel herd;

  const HerdSettingsScreen({super.key, required this.herd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final herdAsync = ref.watch(herdProvider(herd.id));
    final currentUser = ref.watch(authProvider);

    return herdAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Herd Settings')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (herd) {
        if (herd == null || currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Herd not found')),
          );
        }

        final isOwner = herd.isCreator(currentUser.uid);
        final isModerator = herd.isModerator(currentUser.uid);

        if (!isOwner && !isModerator) {
          return Scaffold(
            appBar: AppBar(title: const Text('Herd Info')),
            body: _buildMemberView(context, herd),
          );
        }

        return DefaultTabController(
          length: isOwner ? 4 : 3,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Herd Settings'),
              bottom: TabBar(
                isScrollable: true,
                tabs: [
                  if (isOwner)
                    const Tab(text: 'General', icon: Icon(Icons.settings)),
                  const Tab(text: 'Moderation', icon: Icon(Icons.shield)),
                  const Tab(text: 'Members', icon: Icon(Icons.people)),
                  const Tab(text: 'Activity', icon: Icon(Icons.history)),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                if (isOwner) _buildGeneralTab(context, ref, herd),
                _buildModerationTab(context, ref, herd, isOwner),
                _buildMembersTab(context, ref, herd, isOwner),
                _buildActivityTab(context, ref, herd),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMemberView(BuildContext context, HerdModel herd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: herd.profileImageURL != null
                            ? NetworkImage(herd.profileImageURL!)
                            : null,
                        child: herd.profileImageURL == null
                            ? const Icon(Icons.group, size: 40)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              herd.name,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                            Text(
                              '${herd.memberCount} members',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(herd.description),
                  if (herd.rules.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Rules',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(herd.rules),
                  ],
                  if (herd.faq.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'FAQ',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(herd.faq),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGeneralTab(BuildContext context, WidgetRef ref, HerdModel herd) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Herd Details'),
              subtitle: const Text('Name, description, images, etc.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.pushNamed('editHerd', extra: herd),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Settings'),
              subtitle: Text(herd.isPrivate ? 'Private Herd' : 'Public Herd'),
              trailing: Switch(
                value: herd.isPrivate,
                onChanged: (value) {
                  // TODO: Implement privacy toggle
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.interests),
              title: const Text('Herd Interests'),
              subtitle: Text(herd.interests.join(', ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to interests editor
              },
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: Colors.red.shade50,
            child: ListTile(
              leading: Icon(Icons.delete_forever, color: Colors.red.shade700),
              title: Text(
                'Delete Herd',
                style: TextStyle(color: Colors.red.shade700),
              ),
              subtitle: const Text('This action cannot be undone'),
              onTap: () => _showDeleteConfirmation(context, ref, herd),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationTab(
      BuildContext context, WidgetRef ref, HerdModel herd, bool isOwner) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (herd.reportedPosts.isNotEmpty)
            Card(
              color: Colors.orange.shade50,
              child: ListTile(
                leading: Badge(
                  label: Text('${herd.reportedPosts.length}'),
                  child: Icon(Icons.flag, color: Colors.orange.shade700),
                ),
                title: const Text('Reported Content'),
                subtitle:
                    Text('${herd.reportedPosts.length} items need review'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ModerationDashboardScreen(herdId: herd.id),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.push_pin),
              title: const Text('Pinned Posts'),
              subtitle: Text('${herd.pinnedPosts.length}/5 posts pinned'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to pinned posts manager
              },
            ),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Banned Users'),
              subtitle: Text('${herd.bannedUserIds.length} users banned'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to banned users list
              },
            ),
          ),
          if (isOwner) ...[
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.admin_panel_settings),
                title: const Text('Moderators'),
                subtitle: Text('${herd.moderatorIds.length} moderators'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Navigate to moderator management
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMembersTab(
      BuildContext context, WidgetRef ref, HerdModel herd, bool isOwner) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                      context, 'Total', herd.memberCount.toString()),
                  _buildStatColumn(
                      context, 'Active', '0'), // TODO: Track active members
                  _buildStatColumn(
                      context, 'New', '0'), // TODO: Track new members
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.people),
            label: const Text('Manage Members'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MemberManagementScreen(herdId: herd.id),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ref.watch(herdMembersWithInfoProvider(herd.id)).when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, st) =>
                    Center(child: Text('Error loading members: $err')),
                data: (membersInfo) {
                  if (membersInfo.isEmpty) {
                    return const Center(child: Text('No members yet'));
                  }

                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: membersInfo.length,
                    itemBuilder: (context, idx) {
                      final member = membersInfo[idx];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundImage: member.displayProfileImage != null
                              ? NetworkImage(member.displayProfileImage!)
                              : null,
                          child: member.displayProfileImage == null
                              ? Text(member.displayUsername
                                  .substring(0, 1)
                                  .toUpperCase())
                              : null,
                        ),
                        title: Text(member.displayUsername),
                        subtitle: member.isModerator
                            ? const Text('Moderator')
                            : (member.displayBio?.isNotEmpty == true
                                ? Text(member.displayBio!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis)
                                : null),
                        trailing: member.isVerified
                            ? const Icon(Icons.verified,
                                color: Colors.blue, size: 16)
                            : null,
                        onTap: () => context.pushNamed(
                          'altProfile',
                          pathParameters: {'id': member.userId},
                        ),
                      );
                    },
                  );
                },
              ),
        ),
      ],
    );
  }

  Widget _buildActivityTab(
      BuildContext context, WidgetRef ref, HerdModel herd) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            child: ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Moderation Log'),
              subtitle: Text('${herd.moderationLog.length} actions'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ModerationLogScreen(herdId: herd.id),
                  ),
                );
              },
            ),
          ),
        ),
        Expanded(
          child: herd.moderationLog.isEmpty
              ? const Center(child: Text('No moderation activity'))
              : ListView.builder(
                  itemCount: herd.moderationLog.length.clamp(0, 10),
                  itemBuilder: (context, index) {
                    final action = herd.moderationLog[index];
                    return ListTile(
                      leading: Icon(
                        action.actionType.icon,
                        color: action.actionType.color,
                      ),
                      title: Text(action.actionType.displayName),
                      subtitle: Text(
                        '${_formatDate(action.timestamp)} by ${action.performedBy}',
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  void _showMemberOptions(
    BuildContext context,
    WidgetRef ref,
    HerdModel herd,
    String memberId,
    bool isMod,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMod)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text('Make Moderator'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement make moderator
              },
            ),
          if (isMod)
            ListTile(
              leading: const Icon(Icons.remove_moderator),
              title: const Text('Remove Moderator'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement remove moderator
              },
            ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Ban User', style: TextStyle(color: Colors.red)),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement ban user
            },
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, WidgetRef ref, HerdModel herd) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Herd?'),
        content: Text(
          'Are you sure you want to delete "${herd.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement herd deletion
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
