import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';
import '../providers/herd_providers.dart';
import '../../data/models/herd_member_info.dart';

class ModeratorManagementScreen extends ConsumerWidget {
  final String herdId;

  const ModeratorManagementScreen({super.key, required this.herdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final herdAsync = ref.watch(herdProvider(herdId));
    final currentUser = ref.watch(authProvider);

    return herdAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Moderator Management')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (herd) {
        if (herd == null || currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Herd not found')),
          );
        }

        final isOwner = herd.isCreator(currentUser.uid);

        if (!isOwner) {
          return Scaffold(
            appBar: AppBar(title: const Text('Moderator Management')),
            body: const Center(
              child: Text('Only the herd owner can manage moderators'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Moderator Management'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddModeratorDialog(context, ref, herd),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.admin_panel_settings,
                            color: Colors.blue, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Moderators',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Text(
                                '${herd.moderatorIds.length} moderators',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildModeratorsList(context, ref, herd),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModeratorsList(BuildContext context, WidgetRef ref, herd) {
    return ref.watch(herdMembersWithInfoProvider(herdId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) =>
              Center(child: Text('Error loading members: $err')),
          data: (membersInfo) {
            // Filter only moderators
            final moderators = membersInfo
                .where((member) =>
                    herd.moderatorIds.contains(member.userId) ||
                    herd.isCreator(member.userId))
                .toList();

            if (moderators.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.admin_panel_settings,
                        size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No moderators found'),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: moderators.length,
              itemBuilder: (context, index) {
                final moderator = moderators[index];
                final isCreator = herd.isCreator(moderator.userId);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: moderator.displayProfileImage != null
                          ? NetworkImage(moderator.displayProfileImage!)
                          : null,
                      child: moderator.displayProfileImage == null
                          ? Text(moderator.displayUsername
                              .substring(0, 1)
                              .toUpperCase())
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(moderator.displayUsername),
                        const SizedBox(width: 8),
                        if (isCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'OWNER',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (!isCreator)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'MOD',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        if (moderator.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.verified,
                                color: Colors.blue, size: 16),
                          ),
                      ],
                    ),
                    subtitle: moderator.displayBio?.isNotEmpty == true
                        ? Text(
                            moderator.displayBio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Text('${moderator.displayUserPoints} points'),
                    trailing: !isCreator
                        ? PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'remove') {
                                _showRemoveModeratorDialog(
                                    context, ref, herd, moderator);
                              } else if (value == 'view') {
                                context.pushNamed(
                                  'altProfile',
                                  pathParameters: {'id': moderator.userId},
                                );
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'view',
                                child: Row(
                                  children: [
                                    Icon(Icons.person),
                                    SizedBox(width: 8),
                                    Text('View Profile'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'remove',
                                child: Row(
                                  children: [
                                    Icon(Icons.remove_moderator,
                                        color: Colors.red),
                                    SizedBox(width: 8),
                                    Text('Remove Moderator',
                                        style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : null,
                    onTap: () => context.pushNamed(
                      'altProfile',
                      pathParameters: {'id': moderator.userId},
                    ),
                  ),
                );
              },
            );
          },
        );
  }

  void _showAddModeratorDialog(BuildContext context, WidgetRef ref, herd) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Moderator'),
        content: const Text(
            'To add a moderator, go to the Members tab, find the user, and select "Make Moderator" from their options menu.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showRemoveModeratorDialog(
      BuildContext context, WidgetRef ref, herd, HerdMemberInfo moderator) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Moderator'),
        content: Text(
            'Are you sure you want to remove ${moderator.displayUsername} as a moderator?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final currentUser = ref.read(authProvider);
                if (currentUser != null) {
                  final herdRepository = ref.read(herdRepositoryProvider);
                  await herdRepository.removeModerator(
                      herdId, moderator.userId, currentUser.uid);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            '${moderator.displayUsername} removed as moderator'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to remove moderator: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
