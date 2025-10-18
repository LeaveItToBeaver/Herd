import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/content/post/data/models/post_model.dart';
import 'package:herdapp/features/content/post/view/providers/pinned_post_provider.dart';

import '../../../../../community/herds/view/providers/herd_providers.dart';

class PostMenu extends ConsumerWidget {
  final PostModel post;
  final HeaderDisplayMode displayMode;

  const PostMenu({
    super.key,
    required this.post,
    this.displayMode = HeaderDisplayMode.compact,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    final isCurrentUserAuthor = userId == post.authorId;

    // Watch pin status providers if current user is author
    AsyncValue<bool>? pinnedToHerdStatus;
    AsyncValue<bool>? pinnedToProfileStatus;

    if (isCurrentUserAuthor && userId != null) {
      if (post.herdId != null && post.herdId!.isNotEmpty) {
        pinnedToHerdStatus = ref.watch(
          isPostPinnedToHerdProvider(post.herdId!, post.id)
              .select((value) => value),
        );
      } else {
        pinnedToProfileStatus = ref.watch(
          isPostPinnedToProfileProvider(userId, post.id, post.isAlt)
              .select((value) => value),
        );
      }
    }

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: displayMode == HeaderDisplayMode.compact ? 20 : 24,
      ),
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) => _handleMenuSelection(context, ref, value),
      itemBuilder: (context) => _buildMenuItems(
        isCurrentUserAuthor,
        pinnedToHerdStatus,
        pinnedToProfileStatus,
      ),
    );
  }

  List<PopupMenuItem<String>> _buildMenuItems(
    bool isCurrentUserAuthor,
    AsyncValue<bool>? pinnedToHerdStatus,
    AsyncValue<bool>? pinnedToProfileStatus,
  ) {
    List<PopupMenuItem<String>> items = [];

    if (isCurrentUserAuthor) {
      items.addAll([
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit, size: 20),
              SizedBox(width: 8),
              Text('Edit post'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text('Delete post', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ]);

      // Add pin/unpin options
      _addPinOptions(items, pinnedToHerdStatus, pinnedToProfileStatus);
    }

    // Common options
    items.addAll([
      const PopupMenuItem(
        value: 'save',
        child: Row(
          children: [
            Icon(Icons.bookmark_border, size: 20),
            SizedBox(width: 8),
            Text('Save post'),
          ],
        ),
      ),
      if (!isCurrentUserAuthor)
        const PopupMenuItem(
          value: 'report',
          child: Row(
            children: [
              Icon(Icons.flag_outlined, size: 20),
              SizedBox(width: 8),
              Text('Report post'),
            ],
          ),
        ),
    ]);

    return items;
  }

  void _addPinOptions(
    List<PopupMenuItem<String>> items,
    AsyncValue<bool>? pinnedToHerdStatus,
    AsyncValue<bool>? pinnedToProfileStatus,
  ) {
    if (pinnedToHerdStatus != null) {
      pinnedToHerdStatus.whenData((isPinned) {
        items.add(PopupMenuItem(
          value: isPinned ? 'unpin_herd' : 'pin_herd',
          child: Row(
            children: [
              Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(isPinned ? 'Unpin from herd' : 'Pin to herd'),
            ],
          ),
        ));
      });
    } else if (pinnedToProfileStatus != null) {
      pinnedToProfileStatus.whenData((isPinned) {
        final profileType = post.isAlt ? 'alt profile' : 'profile';
        items.add(PopupMenuItem(
          value: isPinned
              ? (post.isAlt ? 'unpin_alt_profile' : 'unpin_profile')
              : (post.isAlt ? 'pin_alt_profile' : 'pin_profile'),
          child: Row(
            children: [
              Icon(
                isPinned ? Icons.push_pin_outlined : Icons.push_pin,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                  isPinned ? 'Unpin from $profileType' : 'Pin to $profileType'),
            ],
          ),
        ));
      });
    }
  }

  void _handleMenuSelection(BuildContext context, WidgetRef ref, String value) {
    switch (value) {
      case 'edit':
        context.pushNamed(
          'editPost',
          pathParameters: {'id': post.id},
          queryParameters: {'isAlt': post.isAlt.toString()},
        );
        break;
      case 'delete':
        _showDeleteConfirmation(context, ref);
        break;
      case 'save':
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post saved')),
        );
        break;
      case 'report':
        _showReportDialog(context);
        break;
      case 'pin_profile':
      case 'pin_alt_profile':
        _pinToProfile(context, ref, isAlt: post.isAlt);
        break;
      case 'unpin_profile':
      case 'unpin_alt_profile':
        _unpinFromProfile(context, ref, isAlt: post.isAlt);
        break;
      case 'pin_herd':
        _pinToHerd(context, ref);
        break;
      case 'unpin_herd':
        _unpinFromHerd(context, ref);
        break;
    }
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Deleting post...')),
                );
              }

              try {
                await ref.read(postRepositoryProvider).deletePost(
                      post.id,
                      user.userId!,
                      isAlt: post.isAlt,
                      herdId: post.herdId,
                    );

                if (context.mounted) {
                  if (displayMode == HeaderDisplayMode.full) {
                    context.pop();
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Post deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete post: $e')),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Report Post'),
        content:
            const Text('Please select the reason for reporting this post:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Post reported')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _pinToProfile(BuildContext context, WidgetRef ref,
      {required bool isAlt}) async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    if (userId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.pinToProfile(userId, post.id, isAlt: isAlt);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAlt
                ? 'Post pinned to alt profile'
                : 'Post pinned to profile'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _unpinFromProfile(BuildContext context, WidgetRef ref,
      {required bool isAlt}) async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    if (userId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.unpinFromProfile(userId, post.id, isAlt: isAlt);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isAlt
                ? 'Post unpinned from alt profile'
                : 'Post unpinned from profile'),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _pinToHerd(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    if (userId == null || post.herdId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.pinToHerd(post.herdId!, post.id, userId);

      // Invalidate related providers
      ref.invalidate(herdProvider(post.herdId!));
      ref.invalidate(herdPinnedPostsProvider(post.herdId!));
      ref.invalidate(isPostPinnedToHerdProvider(post.herdId!, post.id));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Post pinned to herd'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _unpinFromHerd(BuildContext context, WidgetRef ref) async {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    if (userId == null || post.herdId == null) return;

    try {
      final controller = ref.read(pinnedPostsControllerProvider);
      await controller.unpinFromHerd(post.herdId!, post.id, userId);

      // Invalidate related providers
      ref.invalidate(herdProvider(post.herdId!));
      ref.invalidate(herdPinnedPostsProvider(post.herdId!));
      ref.invalidate(isPostPinnedToHerdProvider(post.herdId!, post.id));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post unpinned from herd')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unpin post: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
