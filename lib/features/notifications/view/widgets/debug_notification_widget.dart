// Add this widget to any screen for debugging FCM
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/notifications/data/repositories/notification_repository.dart';
import 'package:herdapp/features/notifications/utils/notification_service.dart';

class FCMDebugWidget extends ConsumerWidget {
  const FCMDebugWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'FCM Debug Tools',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Test Repository
            ElevatedButton(
              onPressed: () async {
                final repository = ref.read(notificationRepositoryProvider);
                final result = await repository.debugFCMToken();

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Repository Test Result'),
                      content: SingleChildScrollView(
                        child: Text(result.toString()),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Test Repository'),
            ),

            const SizedBox(height: 8),

            // Test Local Notifications
            ElevatedButton(
              onPressed: () async {
                final service = ref.read(notificationServiceProvider);
                await service.testLocalNotification();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Local notification sent!')),
                  );
                }
              },
              child: const Text('Test Local Notification'),
            ),

            const SizedBox(height: 8),

            // Full Debug Test
            ElevatedButton(
              onPressed: () async {
                final service = ref.read(notificationServiceProvider);
                final result = await service.fullFCMDebugTest();

                if (context.mounted) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Full FCM Debug Results'),
                      content: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Results:\n${result.toString()}\n'),
                            if (result['recommendations'] != null) ...[
                              const Text('Recommendations:',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              ...((result['recommendations'] as List<String>)
                                  .map((rec) => Text('• $rec'))),
                            ],
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Full FCM Debug Test'),
            ),

            const SizedBox(height: 8),

            // Check Permissions
            ElevatedButton(
              onPressed: () async {
                final service = ref.read(notificationServiceProvider);
                final enabled = await service.areNotificationsEnabled();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Notifications enabled: $enabled'),
                      backgroundColor: enabled ? Colors.green : Colors.red,
                    ),
                  );
                }
              },
              child: const Text('Check Permissions'),
            ),
          ],
        ),
      ),
    );
  }
}
