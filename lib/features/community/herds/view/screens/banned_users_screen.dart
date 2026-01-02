import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../user/auth/view/providers/auth_provider.dart';
import '../providers/herd_providers.dart';
import '../../../moderation/view/providers/role_providers.dart';
// ignore: unused_import
import '../../data/models/banned_user_info.dart';

class BannedUsersScreen extends ConsumerWidget {
  final String herdId;

  const BannedUsersScreen({super.key, required this.herdId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final herdAsync = ref.watch(herdProvider(herdId));
    final currentUser = ref.watch(authProvider);
    final canModerateAsync = ref.watch(canModerateProvider(herdId));

    return herdAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Banned Users')),
        body: Center(child: Text('Error: $error')),
      ),
      data: (herd) {
        if (herd == null || currentUser == null) {
          return const Scaffold(
            body: Center(child: Text('Herd not found')),
          );
        }

        return canModerateAsync.when(
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (_, __) => const Scaffold(
            body: Center(child: Text('Error loading permissions')),
          ),
          data: (canModerate) {
            if (!canModerate) {
              return Scaffold(
                appBar: AppBar(title: const Text('Banned Users')),
                body: const Center(
                  child: Text('Only moderators can view banned users'),
                ),
              );
            }

            // Get isOwner status
            final isOwnerAsync = ref.watch(isOwnerProvider(herdId));
            return isOwnerAsync.when(
              loading: () => const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Scaffold(
                body: Center(child: Text('Error loading permissions')),
              ),
              data: (isOwner) {
                // Tip: heavy debug calls removed from build to avoid repeated queries

                return Scaffold(
                  appBar: AppBar(
                    title: const Text('Banned Users'),
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
                                const Icon(Icons.block,
                                    color: Colors.red, size: 32),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Banned Users',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge,
                                      ),
                                      Text(
                                        '${herd.bannedUserIds.length} users banned',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
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
                        child: _buildBannedUsersList(context, ref, herd, isOwner),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBannedUsersList(
      BuildContext context, WidgetRef ref, herd, bool isOwner) {
    return ref.watch(bannedUsersProvider(herdId)).when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) {
            // Handle permission errors gracefully
            if (err.toString().contains('permission-denied')) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Access Denied'),
                    SizedBox(height: 8),
                    Text(
                      'You do not have permission to view banned users for this herd',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }
            return Center(child: Text('Error loading banned users: $err'));
          },
          data: (bannedUsers) {
            if (bannedUsers.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.block, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('No banned users'),
                    SizedBox(height: 8),
                    Text(
                      'Users who are banned from this herd will appear here',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              itemCount: bannedUsers.length,
              itemBuilder: (context, index) {
                final bannedUser = bannedUsers[index];

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: bannedUser.profileImageURL != null
                          ? NetworkImage(bannedUser.profileImageURL!)
                          : null,
                      child: bannedUser.profileImageURL == null
                          ? Text(
                              bannedUser.username.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    title: Row(
                      children: [
                        Text(bannedUser.username),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'BANNED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (bannedUser.isVerified)
                          const Padding(
                            padding: EdgeInsets.only(left: 8),
                            child: Icon(Icons.verified,
                                color: Colors.blue, size: 16),
                          ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (bannedUser.bio?.isNotEmpty == true)
                          Text(
                            bannedUser.bio!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        Text(
                          'Banned on ${_formatDate(bannedUser.bannedAt)}',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                        if (bannedUser.bannedBy != null)
                          Text(
                            'Banned by: ${bannedUser.bannedByUsername ?? bannedUser.bannedBy}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'unban') {
                          _showUnbanDialog(context, ref, herd, bannedUser);
                        } else if (value == 'view') {
                          context.pushNamed(
                            'altProfile',
                            pathParameters: {'id': bannedUser.userId},
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
                        // User can unban if they're owner or moderator
                        // Since we're already in a screen that requires canModerate, this is always true
                        const PopupMenuItem(
                          value: 'unban',
                          child: Row(
                            children: [
                              Icon(Icons.undo, color: Colors.green),
                              SizedBox(width: 8),
                                Text('Unban User',
                                    style: TextStyle(color: Colors.green)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    onTap: () => context.pushNamed(
                      'altProfile',
                      pathParameters: {'id': bannedUser.userId},
                    ),
                  ),
                );
              },
            );
          },
        );
  }

  void _showUnbanDialog(BuildContext context, WidgetRef ref, herd, bannedUser) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unban User'),
        content: Text(
            'Are you sure you want to unban ${bannedUser.username}? They will be able to rejoin the herd.'),
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
                  await herdRepository.unbanUser(
                      herdId, bannedUser.userId, currentUser.uid);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('${bannedUser.username} has been unbanned'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to unban user: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: const Text('Unban'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
