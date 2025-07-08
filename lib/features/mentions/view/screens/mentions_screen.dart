import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/mentions/models/mention_model.dart';
import 'package:herdapp/features/user/view/widgets/user_profile_image.dart';

class MentionsScreen extends ConsumerStatefulWidget {
  const MentionsScreen({super.key});

  @override
  ConsumerState<MentionsScreen> createState() => _MentionsScreenState();
}

class _MentionsScreenState extends ConsumerState<MentionsScreen> {
  final MentionRepository _mentionRepository = MentionRepository();
  bool _includeRead = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view mentions')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mentions'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'toggle_read':
                  setState(() {
                    _includeRead = !_includeRead;
                  });
                  break;
                case 'mark_all_read':
                  _markAllAsRead(currentUser.uid);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle_read',
                child: Text(_includeRead ? 'Hide read' : 'Show all'),
              ),
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Text('Mark all as read'),
              ),
            ],
          ),
        ],
      ),
      body: StreamBuilder<List<MentionModel>>(
        stream: _mentionRepository.getUserMentions(
          currentUser.uid,
          includeRead: _includeRead,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final mentions = snapshot.data ?? [];

          if (mentions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alternate_email,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _includeRead ? 'No mentions yet' : 'No unread mentions',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (!_includeRead) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _includeRead = true;
                        });
                      },
                      child: const Text('Show all mentions'),
                    ),
                  ],
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: mentions.length,
            itemBuilder: (context, index) {
              final mention = mentions[index];
              return _MentionTile(
                mention: mention,
                onTap: () => _navigateToContent(mention),
                onMarkRead: () => _markAsRead(currentUser.uid, mention.id),
              );
            },
          );
        },
      ),
    );
  }

  void _navigateToContent(MentionModel mention) {
    // Mark as read when tapped
    _markAsRead(ref.read(authProvider)!.uid, mention.id);

    // Navigate to the post
    context.pushNamed(
      'post',
      pathParameters: {'id': mention.postId},
      queryParameters: {
        'isAlt': mention.isAlt.toString(),
        if (mention.commentId != null) 'highlightComment': mention.commentId!,
      },
    );
  }

  Future<void> _markAsRead(String userId, String mentionId) async {
    try {
      await _mentionRepository.markMentionAsRead(userId, mentionId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error marking as read: $e')),
        );
      }
    }
  }

  Future<void> _markAllAsRead(String userId) async {
    try {
      await _mentionRepository.markAllMentionsAsRead(userId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All mentions marked as read')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}

class _MentionTile extends StatelessWidget {
  final MentionModel mention;
  final VoidCallback onTap;
  final VoidCallback onMarkRead;

  const _MentionTile({
    required this.mention,
    required this.onTap,
    required this.onMarkRead,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUnread = !mention.isRead;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: isUnread ? 2 : 1,
      color: isUnread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Author avatar
              UserProfileImage(
                radius: 20,
                profileImageUrl: null, // You'd need to fetch this or store it
              ),
              const SizedBox(width: 12),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: mention.authorUsername,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: mention.mentionType == 'comment'
                                ? ' mentioned you in a comment'
                                : ' mentioned you in a post',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Preview
                    if (mention.postTitle != null) ...[
                      Text(
                        mention.postTitle!,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                    ],

                    Text(
                      mention.contentPreview,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Footer
                    Row(
                      children: [
                        // Timestamp
                        Text(
                          _formatTimestamp(mention.timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),

                        if (mention.herdName != null) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.group,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            mention.herdName!,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],

                        if (mention.isAlt) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.lock,
                            size: 12,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Alt',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Unread indicator
              if (isUnread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.primary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
