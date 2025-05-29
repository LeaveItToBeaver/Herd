import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/post/data/models/post_model.dart';
import 'package:herdapp/features/post/view/providers/pinned_post_provider.dart';
import 'package:herdapp/features/user/utils/async_user_value_extension.dart';
import 'package:herdapp/features/user/view/providers/current_user_provider.dart';

class PostMenuWidget extends ConsumerWidget {
  final PostModel post;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onReport;
  final Function({required bool isAlt}) onPinToProfile;
  final Function({required bool isAlt}) onUnpinFromProfile;
  final VoidCallback onPinToHerd;
  final VoidCallback onUnpinFromHerd;

  const PostMenuWidget({
    super.key,
    required this.post,
    required this.onEdit,
    required this.onDelete,
    required this.onSave,
    required this.onReport,
    required this.onPinToProfile,
    required this.onUnpinFromProfile,
    required this.onPinToHerd,
    required this.onUnpinFromHerd,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final userId = user.userId;
    final isCurrentUserAuthor = userId == post.authorId;

    // Watch the pin status providers outside of itemBuilder
    AsyncValue<bool>? pinnedToHerdStatus;
    AsyncValue<bool>? pinnedToProfileStatus;

    if (isCurrentUserAuthor && userId != null) {
      if (post.herdId != null && post.herdId!.isNotEmpty) {
        pinnedToHerdStatus = ref.watch(isPostPinnedToHerdProvider((
          herdId: post.herdId!,
          postId: post.id,
        )));
      } else {
        pinnedToProfileStatus = ref.watch(isPostPinnedToProfileProvider((
          userId: userId,
          postId: post.id,
          isAlt: post.isAlt,
        )));
      }
    }

    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 20, color: Colors.grey.shade700),
      offset: const Offset(0, 36),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        switch (value) {
          case 'report':
            onReport();
            break;
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
          case 'save':
            onSave();
            break;
          case 'pin_profile':
            onPinToProfile(isAlt: false);
            break;
          case 'pin_alt_profile':
            onPinToProfile(isAlt: true);
            break;
          case 'pin_herd':
            onPinToHerd();
            break;
          case 'unpin_profile':
            onUnpinFromProfile(isAlt: false);
            break;
          case 'unpin_alt_profile':
            onUnpinFromProfile(isAlt: true);
            break;
          case 'unpin_herd':
            onUnpinFromHerd();
            break;
        }
      },
      itemBuilder: (context) {
        List<PopupMenuItem<String>> items = [];

        // Author options
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

          // Add pin/unpin options based on the watched providers
          if (pinnedToHerdStatus != null) {
            pinnedToHerdStatus.when(
              data: (isPinned) {
                if (isPinned) {
                  items.add(
                    const PopupMenuItem(
                      value: 'unpin_herd',
                      child: Row(
                        children: [
                          Icon(Icons.push_pin_outlined,
                              size: 20, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Unpin from herd'),
                        ],
                      ),
                    ),
                  );
                } else {
                  items.add(
                    const PopupMenuItem(
                      value: 'pin_herd',
                      child: Row(
                        children: [
                          Icon(Icons.push_pin, size: 20),
                          SizedBox(width: 8),
                          Text('Pin to herd'),
                        ],
                      ),
                    ),
                  );
                }
              },
              loading: () {
                // Optionally add a loading indicator or just skip
              },
              error: (_, __) {
                // Handle error or just skip
              },
            );
          } else if (pinnedToProfileStatus != null) {
            pinnedToProfileStatus.when(
              data: (isPinned) {
                if (isPinned) {
                  if (post.isAlt) {
                    items.add(
                      const PopupMenuItem(
                        value: 'unpin_alt_profile',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_outlined,
                                size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Unpin from alt profile'),
                          ],
                        ),
                      ),
                    );
                  } else {
                    items.add(
                      const PopupMenuItem(
                        value: 'unpin_profile',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin_outlined,
                                size: 20, color: Colors.orange),
                            SizedBox(width: 8),
                            Text('Unpin from profile'),
                          ],
                        ),
                      ),
                    );
                  }
                } else {
                  if (post.isAlt) {
                    items.add(
                      const PopupMenuItem(
                        value: 'pin_alt_profile',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin, size: 20),
                            SizedBox(width: 8),
                            Text('Pin to alt profile'),
                          ],
                        ),
                      ),
                    );
                  } else {
                    items.add(
                      const PopupMenuItem(
                        value: 'pin_profile',
                        child: Row(
                          children: [
                            Icon(Icons.push_pin, size: 20),
                            SizedBox(width: 8),
                            Text('Pin to profile'),
                          ],
                        ),
                      ),
                    );
                  }
                }
              },
              loading: () {
                // Optionally add a loading indicator or just skip
              },
              error: (_, __) {
                // Handle error or just skip
              },
            );
          }
        }

        // Non-author options
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
      },
    );
  }
}
