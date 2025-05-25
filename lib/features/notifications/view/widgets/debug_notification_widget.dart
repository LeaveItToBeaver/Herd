import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/bootstrap/app_bootstraps.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

/// Debug widget to help troubleshoot notification issues
/// Add this to your notification screen temporarily to debug
class NotificationDebugWidget extends ConsumerStatefulWidget {
  const NotificationDebugWidget({super.key});

  @override
  ConsumerState<NotificationDebugWidget> createState() =>
      _NotificationDebugWidgetState();
}

class _NotificationDebugWidgetState
    extends ConsumerState<NotificationDebugWidget> {
  Map<String, dynamic>? _testResult;
  bool _isLoading = false;

  Future<void> _runTest() async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
      _testResult = null;
    });

    try {
      final repository = ref.read(notificationRepositoryProvider);
      final result = await repository.testNotificationQuery(currentUser.uid);

      setState(() {
        _testResult = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _testResult = {
          'success': false,
          'error': e.toString(),
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _testNotifications() async {
    final bootstrap = ref.read(AppBootstrap.appBootstrapProvider);
    await bootstrap.testNotifications(ref);
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Debug',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text('User ID: ${currentUser?.uid ?? 'Not logged in'}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testNotifications,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Test Notification Query'),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult!['success'] == true
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  border: Border.all(
                    color: _testResult!['success'] == true
                        ? Colors.green
                        : Colors.red,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Result:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _testResult.toString(),
                      style: const TextStyle(
                          fontFamily: 'monospace', fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Instructions:\n'
              '1. Run the test to check if notifications exist in Firestore\n'
              '2. Check the console logs for detailed debugging info\n'
              '3. Verify that notifications have the correct recipientId\n'
              '4. Make sure the user is authenticated',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
