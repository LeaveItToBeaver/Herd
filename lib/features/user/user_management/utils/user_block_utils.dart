import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../view/providers/user_block_providers.dart';

/// Utility class for user blocking operations and UI helpers
class UserBlockUtils {
  /// Shows a confirmation dialog to block a user
  static Future<void> showBlockUserDialog(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String displayName,
    String? username,
    String? firstName,
    String? lastName,
    bool showReportOption = true,
    bool showAltOption = true,
    bool showNotesOption = true,
  }) async {
    bool reported = false;
    bool isAlt = false;
    final notesController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('Block $displayName'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Are you sure you want to block $displayName?'),
                if (showReportOption || showAltOption) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Additional options:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
                if (showReportOption)
                  CheckboxListTile(
                    title: const Text('Also report this user'),
                    value: reported,
                    onChanged: (value) =>
                        setState(() => reported = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                if (showAltOption)
                  CheckboxListTile(
                    title: const Text('Mark as alternative account'),
                    value: isAlt,
                    onChanged: (value) =>
                        setState(() => isAlt = value ?? false),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),
                if (showNotesOption) ...[
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes (optional)',
                      hintText: 'Add notes about why you blocked this user...',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Block User'),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      await ref.read(blockUserStateProvider.notifier).blockUser(
            blockedUserId: userId,
            username: username,
            firstName: firstName,
            lastName: lastName,
            reported: reported,
            isAlt: isAlt,
            notes: notesController.text.trim().isEmpty
                ? null
                : notesController.text.trim(),
          );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName has been blocked'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Undo',
              textColor: Colors.white,
              onPressed: () {
                ref.read(blockUserStateProvider.notifier).unblockUser(userId);
              },
            ),
          ),
        );
      }
    }
  }

  /// Shows a confirmation dialog to unblock a user
  static Future<void> showUnblockUserDialog(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String displayName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unblock User'),
        content: Text('Are you sure you want to unblock $displayName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Unblock'),
          ),
        ],
      ),
    );

    if (result == true) {
      await ref.read(blockUserStateProvider.notifier).unblockUser(userId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$displayName has been unblocked'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  /// Shows a bottom sheet with user blocking options
  static Future<void> showBlockUserBottomSheet(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String displayName,
    String? username,
    String? firstName,
    String? lastName,
  }) async {
    await showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.block, color: Colors.red),
              title: const Text('Block User'),
              subtitle: Text('Block $displayName from contacting you'),
              onTap: () {
                Navigator.of(context).pop();
                showBlockUserDialog(
                  context,
                  ref,
                  userId: userId,
                  displayName: displayName,
                  username: username,
                  firstName: firstName,
                  lastName: lastName,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.report, color: Colors.orange),
              title: const Text('Block & Report'),
              subtitle: Text('Block and report $displayName'),
              onTap: () {
                Navigator.of(context).pop();
                showBlockUserDialog(
                  context,
                  ref,
                  userId: userId,
                  displayName: displayName,
                  username: username,
                  firstName: firstName,
                  lastName: lastName,
                  showReportOption: false, // Pre-set to reported
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Creates a simple block button widget
  static Widget buildBlockButton(
    BuildContext context,
    WidgetRef ref, {
    required String userId,
    required String displayName,
    String? username,
    String? firstName,
    String? lastName,
    bool isIconButton = false,
    IconData icon = Icons.block,
    String text = 'Block',
    Color? color,
  }) {
    final blockState = ref.watch(blockUserStateProvider);
    final isBlocked = ref.watch(isUserBlockedProvider(userId));

    return isBlocked.when(
      loading: () => isIconButton
          ? const Icon(Icons.hourglass_empty, color: Colors.grey)
          : const ElevatedButton(
              onPressed: null,
              child: Text('Loading...'),
            ),
      error: (_, __) => isIconButton
          ? const Icon(Icons.error, color: Colors.red)
          : ElevatedButton(
              onPressed: null,
              child: Text('Error'),
            ),
      data: (blocked) {
        if (blocked) {
          // User is already blocked, show unblock option
          return isIconButton
              ? IconButton(
                  onPressed: blockState.isLoading
                      ? null
                      : () => showUnblockUserDialog(
                            context,
                            ref,
                            userId: userId,
                            displayName: displayName,
                          ),
                  icon: Icon(
                    Icons.person_add,
                    color: Colors.green,
                  ),
                  tooltip: 'Unblock',
                )
              : ElevatedButton.icon(
                  onPressed: blockState.isLoading
                      ? null
                      : () => showUnblockUserDialog(
                            context,
                            ref,
                            userId: userId,
                            displayName: displayName,
                          ),
                  icon: Icon(Icons.person_add),
                  label: Text('Unblock'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                );
        } else {
          // User is not blocked, show block option
          return isIconButton
              ? IconButton(
                  onPressed: blockState.isLoading
                      ? null
                      : () => showBlockUserDialog(
                            context,
                            ref,
                            userId: userId,
                            displayName: displayName,
                            username: username,
                            firstName: firstName,
                            lastName: lastName,
                          ),
                  icon: Icon(
                    icon,
                    color: color ?? Colors.red,
                  ),
                  tooltip: text,
                )
              : ElevatedButton.icon(
                  onPressed: blockState.isLoading
                      ? null
                      : () => showBlockUserDialog(
                            context,
                            ref,
                            userId: userId,
                            displayName: displayName,
                            username: username,
                            firstName: firstName,
                            lastName: lastName,
                          ),
                  icon: Icon(icon),
                  label: Text(text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color ?? Colors.red,
                    foregroundColor: Colors.white,
                  ),
                );
        }
      },
    );
  }

  /// Helper method to check if content should be filtered based on blocked users
  static Future<bool> shouldFilterContent(
    WidgetRef ref,
    String authorUserId,
  ) async {
    try {
      final isBlocked =
          await ref.read(isUserBlockedProvider(authorUserId).future);
      return isBlocked;
    } catch (e) {
      // If there's an error checking, don't filter (fail open)
      return false;
    }
  }

  /// Helper method to get blocked user IDs for bulk filtering
  static Future<Set<String>> getBlockedUserIds(WidgetRef ref) async {
    try {
      final blockedUsers = await ref.read(blockedUsersProvider.future);
      return blockedUsers.map((user) => user.userId).toSet();
    } catch (e) {
      // If there's an error, return empty set (fail open)
      return <String>{};
    }
  }
}
