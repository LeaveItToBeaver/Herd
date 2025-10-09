import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';

enum HeaderDisplayMode {
  compact, // For feed list
  full, // For post screen
  pinned, // For ultra-compact pinned posts
}

class PostAuthorHeader extends ConsumerWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;
  final VoidCallback? onProfileTap;
  final bool showMenu;

  const PostAuthorHeader({
    super.key,
    required this.post,
    this.displayMode = HeaderDisplayMode.compact,
    this.onProfileTap,
    this.showMenu = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Wrap entire header in RepaintBoundary
    return RepaintBoundary(
      child: post.herdId != null && post.herdId!.isNotEmpty
          ? _HerdHeader(
              post: post,
              displayMode: displayMode,
              onProfileTap: onProfileTap,
              showMenu: showMenu,
            )
          : _UserHeader(
              post: post,
              displayMode: displayMode,
              onProfileTap: onProfileTap,
              showMenu: showMenu,
            ),
    );
  }
}

class _UserHeader extends ConsumerWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;
  final VoidCallback? onProfileTap;
  final bool showMenu;

  const _UserHeader({
    required this.post,
    required this.displayMode,
    this.onProfileTap,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = displayMode == HeaderDisplayMode.compact;

    // Only watch the specific user data we need
    final userAsync = ref.watch(
      userProvider(post.authorId).select((value) => value),
    );

    return Padding(
      padding: EdgeInsets.all(
        displayMode == HeaderDisplayMode.pinned 
          ? 4 
          : (isCompact ? 8 : 12)
      ),
      child: userAsync.when(
        loading: () => _buildLoadingState(isCompact),
        error: (_, __) => _buildErrorState(isCompact),
        data: (user) {
          if (user == null) {
            return _buildErrorState(isCompact);
          }

          final profileImageUrl = post.isAlt
              ? (user.altProfileImageURL ?? user.profileImageURL)
              : user.profileImageURL;

          final displayName = post.isAlt
              ? user.username
              : '${user.firstName} ${user.lastName}'.trim();

          return Row(
            children: [
              // Profile image
              GestureDetector(
                onTap:
                    onProfileTap ?? () => _navigateToProfile(context, user.id),
                child: CircleAvatar(
                  radius: isCompact ? 16 : 25,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                  child: profileImageUrl == null || profileImageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade400,
                          size: isCompact ? 16 : 20,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 12),

              // User info
              Expanded(
                child: GestureDetector(
                  onTap: onProfileTap ??
                      () => _navigateToProfile(context, user.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isCompact ? 13 : 15,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (post.isAlt) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.lock, size: 12),
                          ],
                        ],
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: TextStyle(
                          fontSize: isCompact ? 11 : 12,
                          fontWeight:
                              isCompact ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Menu
              if (showMenu)
                RepaintBoundary(
                  child: PostMenu(
                    post: post,
                    displayMode: displayMode,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isCompact) {
    return Row(
      children: [
        CircleAvatar(
          radius: isCompact ? 16 : 25,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 80,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildErrorState(bool isCompact) {
    return Row(
      children: [
        CircleAvatar(
          radius: isCompact ? 16 : 25,
          backgroundColor: Colors.grey.shade300,
          child: const Icon(Icons.person_off, size: 16),
        ),
        const SizedBox(width: 12),
        const Text('User not found'),
      ],
    );
  }

  void _navigateToProfile(BuildContext context, String userId) {
    context.pushNamed(
      post.isAlt ? 'altProfile' : 'publicProfile',
      pathParameters: {'id': userId},
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}

class _HerdHeader extends ConsumerWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;
  final VoidCallback? onProfileTap;
  final bool showMenu;

  const _HerdHeader({
    required this.post,
    required this.displayMode,
    this.onProfileTap,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompact = displayMode == HeaderDisplayMode.compact;
    final herdId = post.herdId!;

    // Use select to minimize rebuilds
    final herdAsync = ref.watch(
      herdProvider(herdId).select((value) => value),
    );
    final userAsync = ref.watch(
      userProvider(post.authorId).select((value) => value),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Herd info
        Padding(
          padding: EdgeInsets.all(
            displayMode == HeaderDisplayMode.pinned 
              ? 4 
              : (isCompact ? 8 : 12)
          ),
          child: herdAsync.when(
            loading: () => _buildLoadingState(isCompact),
            error: (_, __) => const Text('Unknown herd'),
            data: (herd) {
              if (herd == null) return const Text('Unknown herd');

              return GestureDetector(
                onTap: () =>
                    context.pushNamed('herd', pathParameters: {'id': herdId}),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: isCompact ? 16 : 20,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      backgroundImage: herd.profileImageURL != null
                          ? NetworkImage(herd.profileImageURL!)
                          : null,
                      child: herd.profileImageURL == null
                          ? const Icon(Icons.groups, size: 20)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        herd.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: isCompact ? 14 : 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (showMenu)
                      RepaintBoundary(
                        child: PostMenu(
                          post: post,
                          displayMode: displayMode,
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),

        // Author info
        Padding(
          padding: EdgeInsets.only(
            left: displayMode == HeaderDisplayMode.pinned 
              ? 8 
              : (isCompact ? 16 : 20),
            bottom: displayMode == HeaderDisplayMode.pinned 
              ? 4 
              : (isCompact ? 8 : 12),
          ),
          child: userAsync.when(
            loading: () => _buildAuthorLoadingState(),
            error: (_, __) =>
                const Text('Unknown user', style: TextStyle(fontSize: 12)),
            data: (user) {
              final displayName = user != null
                  ? (post.isAlt
                      ? user.username
                      : '${user.firstName} ${user.lastName}'.trim())
                  : 'Anonymous';

              return GestureDetector(
                onTap: user != null
                    ? (onProfileTap ??
                        () => _navigateToProfile(context, user.id))
                    : null,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Posted by $displayName',
                      style: TextStyle(fontSize: isCompact ? 11 : 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '• ${_formatTimestamp(post.createdAt)}',
                      style: TextStyle(fontSize: isCompact ? 11 : 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState(bool isCompact) {
    return Row(
      children: [
        CircleAvatar(
          radius: isCompact ? 16 : 20,
          backgroundColor: Colors.grey.shade300,
        ),
        const SizedBox(width: 12),
        Container(
          width: 150,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthorLoadingState() {
    return Container(
      width: 100,
      height: 12,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, String userId) {
    context.pushNamed(
      post.isAlt ? 'altProfile' : 'publicProfile',
      pathParameters: {'id': userId},
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return '';
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}
