import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/drafts/data/models/draft_post_model.dart';
import 'package:intl/intl.dart';

import '../providers/draft_provider.dart';
import 'edit_draft_screen.dart';

class DraftsListScreen extends ConsumerWidget {
  const DraftsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(userDraftsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Drafts'),
      ),
      body: draftsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading drafts: $error'),
        ),
        data: (drafts) {
          if (drafts.isEmpty) {
            return const Center(
              child: Text('You have no saved drafts'),
            );
          }

          return ListView.builder(
            itemCount: drafts.length,
            itemBuilder: (context, index) {
              return _buildDraftItem(context, ref, drafts[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildDraftItem(
      BuildContext context, WidgetRef ref, DraftPostModel draft) {
    // Format the date
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final updatedAt = draft.updatedAt ?? draft.createdAt ?? DateTime.now();
    final formattedDate = dateFormat.format(updatedAt);

    // Create title text - use title if available, otherwise use truncated content
    final titleText = draft.title?.isNotEmpty == true
        ? draft.title!
        : (draft.content.length > 50
            ? '${draft.content.substring(0, 50)}...'
            : draft.content);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          titleText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              draft.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                if (draft.isAlt)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Alt Post',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                if (draft.herdName != null) ...[
                  if (draft.isAlt) const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'h/${draft.herdName}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  formattedDate,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        contentPadding: const EdgeInsets.all(16),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(context, ref, value, draft),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 18),
                  SizedBox(width: 8),
                  Text('Edit'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'publish',
              child: Row(
                children: [
                  Icon(Icons.send, size: 18),
                  SizedBox(width: 8),
                  Text('Publish'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Delete', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
        onTap: () => _navigateToEditDraft(context, draft),
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action,
      DraftPostModel draft) async {
    final user = ref.read(authProvider);
    if (user == null) return;

    switch (action) {
      case 'edit':
        _navigateToEditDraft(context, draft);
        break;
      case 'publish':
        _confirmPublishDraft(context, ref, draft);
        break;
      case 'delete':
        _confirmDeleteDraft(context, ref, draft);
        break;
    }
  }

  void _navigateToEditDraft(BuildContext context, DraftPostModel draft) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditDraftScreen(draft: draft),
      ),
    );
  }

  void _confirmPublishDraft(
      BuildContext context, WidgetRef ref, DraftPostModel draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publish Draft'),
        content: const Text(
            'Are you sure you want to publish this draft? This will post it to your feed and delete the draft.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final user = ref.read(authProvider);
              if (user == null) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Publishing post...')),
              );

              try {
                final postId = await ref
                    .read(draftControllerProvider.notifier)
                    .publishDraft(
                      user.uid,
                      draft.id,
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Post published successfully')),
                  );

                  // Navigate to the post
                  context.pushNamed(
                    'post',
                    pathParameters: {'id': postId},
                    queryParameters: {'isAlt': draft.isAlt.toString()},
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error publishing post: $e')),
                  );
                }
              }
            },
            child: const Text('Publish'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteDraft(
      BuildContext context, WidgetRef ref, DraftPostModel draft) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Draft'),
        content: const Text(
            'Are you sure you want to delete this draft? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final user = ref.read(authProvider);
              if (user == null) return;

              try {
                await ref.read(draftControllerProvider.notifier).deleteDraft(
                      user.uid,
                      draft.id,
                    );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Draft deleted successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting draft: $e')),
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
}
