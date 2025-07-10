import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/drafts/data/models/draft_post_model.dart';
import 'package:herdapp/features/drafts/view/providers/draft_provider.dart';
import 'package:herdapp/features/drafts/view/screens/edit_draft_screen.dart';
import 'package:intl/intl.dart';

class DraftsTabView extends ConsumerWidget {
  const DraftsTabView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draftsAsync = ref.watch(userDraftsProvider);

    return draftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading drafts',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      data: (drafts) {
        if (drafts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.drafts_outlined,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                Text(
                  'No drafts yet',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your saved drafts will appear here',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.push('/createPost'),
                  icon: const Icon(Icons.add),
                  label: const Text('Create Post'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: drafts.length,
          itemBuilder: (context, index) {
            return _buildDraftCard(context, ref, drafts[index]);
          },
        );
      },
    );
  }

  Widget _buildDraftCard(
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _navigateToEditDraft(context, draft),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with title and edit button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titleText,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, size: 20),
                    onPressed: () => _navigateToEditDraft(context, draft),
                    tooltip: 'Edit draft',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Content preview
              Text(
                draft.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),

              // Tags and metadata
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  if (draft.isAlt)
                    Chip(
                      label: const Text('Alt Post'),
                      backgroundColor: Colors.blue.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                  if (draft.herdName != null)
                    Chip(
                      label: Text('h/${draft.herdName}'),
                      backgroundColor: Colors.green.withValues(alpha: 0.1),
                      labelStyle: const TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),

              // Date and actions
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  PopupMenuButton<String>(
                    onSelected: (value) =>
                        _handleMenuAction(context, ref, value, draft),
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
                    child: const Icon(Icons.more_vert, size: 20),
                  ),
                ],
              ),
            ],
          ),
        ),
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
