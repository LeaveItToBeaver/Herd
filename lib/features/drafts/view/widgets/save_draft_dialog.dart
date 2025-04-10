import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

import '../providers/draft_provider.dart';

class SaveDraftDialog extends ConsumerWidget {
  final String title;
  final String content;
  final bool isAlt;
  final String? herdId;
  final String? herdName;

  const SaveDraftDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.isAlt,
    this.herdId,
    this.herdName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Save Draft?'),
      content: const Text(
          'Would you like to save this post as a draft before exiting?'),
      actions: [
        TextButton(
          onPressed: () {
            // Just close the dialog and let the navigation happen
            Navigator.of(context).pop(true);
          },
          child: const Text('Discard'),
        ),
        TextButton(
          onPressed: () {
            // Just close the dialog without navigation
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            // Save as draft
            final user = ref.read(authProvider);
            if (user == null) {
              Navigator.of(context).pop(true);
              return;
            }

            try {
              await ref.read(draftControllerProvider.notifier).saveDraft(
                    authorId: user.uid,
                    title: title,
                    content: content,
                    isAlt: isAlt,
                    herdId: herdId,
                    herdName: herdName,
                  );

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Draft saved successfully'),
                  ),
                );
                Navigator.of(context).pop(true);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving draft: $e'),
                  ),
                );
                Navigator.of(context).pop(false);
              }
            }
          },
          child: const Text('Save Draft'),
        ),
      ],
    );
  }
}
