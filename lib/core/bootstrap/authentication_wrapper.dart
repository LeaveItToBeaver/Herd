import 'package:flutter/foundation.dart'; // Add this import for kDebugMode
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/social/notifications/data/models/notification_settings_model.dart';
import 'package:herdapp/features/social/notifications/data/repositories/notification_repository.dart';
import 'package:herdapp/features/social/notifications/view/providers/notification_settings_notifier.dart';
import 'package:herdapp/features/user/auth/view/providers/auth_provider.dart';
import 'package:herdapp/features/social/notifications/utils/notification_service.dart'; // Add this import
// Import intl for date formatting if not already done elsewhere globally
import 'package:intl/intl.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // _isLoading is now managed by AsyncValue, but can be kept for disabling buttons during calls.
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('Please sign in to view notification settings'),
        ),
      );
    }

    final settingsAsync =
        ref.watch(notificationSettingsProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
      ),
      // Use AsyncValue.when to handle different states
      body: settingsAsync.when(
        data: (settings) {
          if (settings == null) {
            // This case should ideally not happen if getOrCreateSettings always returns a model
            return const Center(
                child: Text('Notification settings not available.'));
          }
          return _buildSettingsList(settings, currentUser.uid);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error loading settings: $error'),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(notificationSettingsProvider(currentUser.uid)
                          .notifier)
                      .loadSettings();
                },
                child: const Text('Retry'),
              )
            ],
          ),
        ),
      ),
    );
  }

  // Pass userId to _buildSettingsList if needed for notifier calls directly from there,
  // or ensure _toggleSetting and _setMuteUntil get it.
  Widget _buildSettingsList(NotificationSettingsModel settings, String userId) {
    return ListView(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Push Notifications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('Enable Push Notifications'),
          subtitle: const Text('Receive notifications on your device'),
          value: settings.pushNotificationsEnabled,
          onChanged: _isUpdating
              ? null
              : (value) => _toggleSetting(
                    userId, // Pass userId
                    'pushNotificationsEnabled',
                    value,
                  ),
        ),
        if (settings.pushNotificationsEnabled) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Notification Types',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('New Followers'),
            subtitle: const Text('When someone starts following you'),
            value: settings.followNotifications,
            onChanged: _isUpdating
                ? null
                : (value) => _toggleSetting(
                    userId, 'followNotifications', value), // Pass userId
          ),
          SwitchListTile(
            title: const Text('New Posts'),
            subtitle: const Text('When people you follow post new content'),
            value: settings.postNotifications,
            onChanged: _isUpdating
                ? null
                : (value) => _toggleSetting(userId, 'postNotifications', value),
          ),
          SwitchListTile(
            title: const Text('Likes'),
            subtitle: const Text('When someone likes your post'),
            value: settings.likeNotifications,
            onChanged: _isUpdating
                ? null
                : (value) => _toggleSetting(userId, 'likeNotifications', value),
          ),
          SwitchListTile(
            title: const Text('Comments'),
            subtitle: const Text('When someone comments on your post'),
            value: settings.commentNotifications,
            onChanged: _isUpdating
                ? null
                : (value) =>
                    _toggleSetting(userId, 'commentNotifications', value),
          ),
          SwitchListTile(
            title: const Text('Replies'),
            subtitle: const Text('When someone replies to your comment'),
            value: settings.replyNotifications,
            onChanged: _isUpdating
                ? null
                : (value) =>
                    _toggleSetting(userId, 'replyNotifications', value),
          ),
          SwitchListTile(
            title: const Text('Connection Requests'),
            subtitle: const Text('Connection requests and acceptances'),
            value: settings.connectionNotifications,
            onChanged: _isUpdating
                ? null
                : (value) =>
                    _toggleSetting(userId, 'connectionNotifications', value),
          ),
          SwitchListTile(
            title: const Text('Milestones'),
            subtitle: const Text('When your posts reach certain thresholds'),
            value: settings.milestoneNotifications,
            onChanged: _isUpdating
                ? null
                : (value) =>
                    _toggleSetting(userId, 'milestoneNotifications', value),
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Quiet Time',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          ListTile(
            title: Text(
              settings.isMuted
                  // Use DateFormat for better formatting
                  ? 'Muted until ${DateFormat.yMd().add_jm().format(settings.mutedUntil!)}'
                  : 'Temporary Mute',
            ),
            subtitle: const Text('Pause notifications for a specific time'),
            trailing: settings.isMuted
                ? ElevatedButton(
                    onPressed:
                        _isUpdating ? null : () => _setMuteUntil(userId, null),
                    child: const Text('Unmute'),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: settings.isMuted || _isUpdating
                ? null
                : () => _showMuteDialog(userId),
          ),
        ],

        // Debug section - only show in debug mode
        if (kDebugMode) ...[
          const Divider(),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Debug Tools',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          ),
          _buildDebugSection(userId),
        ],
      ],
    );
  }

  /// Build the debug section with FCM testing tools
  Widget _buildDebugSection(String userId) {
    return Card(
      margin: const EdgeInsets.all(16),
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.bug_report, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Text(
                  'FCM Debug Tools',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.red.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'These tools help diagnose push notification issues',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Test Repository Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _testRepository(),
                icon: const Icon(Icons.cloud, size: 18),
                label: const Text('Test Repository & FCM Token'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade100,
                  foregroundColor: Colors.blue.shade800,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Test Local Notifications Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _testLocalNotification(),
                icon: const Icon(Icons.notifications, size: 18),
                label: const Text('Test Local Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade800,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Full Debug Test Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _runFullDebugTest(),
                icon: const Icon(Icons.analytics, size: 18),
                label: const Text('Full FCM Debug Test'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade100,
                  foregroundColor: Colors.orange.shade800,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Check Permissions Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : () => _checkPermissions(),
                icon: const Icon(Icons.security, size: 18),
                label: const Text('Check Permissions'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.purple.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Debug methods
  Future<void> _testRepository() async {
    try {
      final repository = ref.read(notificationRepositoryProvider);
      final result = await repository.debugFCMToken();

      if (mounted) {
        _showDebugResultDialog('Repository Test Result', result.toString());
      }
    } catch (e) {
      if (mounted) {
        _showDebugResultDialog('Repository Test Error', e.toString());
      }
    }
  }

  Future<void> _testLocalNotification() async {
    try {
      final service = ref.read(notificationServiceProvider);
      await service.showTestNotification();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Local notification sent! Check your device.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _runFullDebugTest() async {
    try {
      final service = ref.read(notificationServiceProvider);

      // Show loading dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Running comprehensive FCM test...'),
              ],
            ),
          ),
        );
      }

      final result = await service.fullFCMDebugTest();

      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showFullDebugResults(result);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showDebugResultDialog('Full Debug Test Error', e.toString());
      }
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final service = ref.read(notificationServiceProvider);
      final enabled = await service.areNotificationsEnabled();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Notifications enabled: $enabled'),
            backgroundColor: enabled ? Colors.green : Colors.red,
            action: !enabled
                ? SnackBarAction(
                    label: 'Request',
                    textColor: Colors.white,
                    onPressed: () async {
                      final granted = await service.requestPermissions();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Permission ${granted ? 'granted' : 'denied'}'),
                            backgroundColor:
                                granted ? Colors.green : Colors.red,
                          ),
                        );
                      }
                    },
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showDebugResultDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(content), // Make text selectable for copying
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

  void _showFullDebugResults(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Full FCM Debug Results'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (result['recommendations'] != null) ...[
                const Text(
                  'Recommendations:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                ...((result['recommendations'] as List<String>).map(
                  (rec) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rec.startsWith('✅')
                              ? ''
                              : rec.startsWith('❌')
                                  ? ''
                                  : rec.startsWith('💡')
                                      ? '💡 '
                                      : '• ',
                          style: TextStyle(
                            color: rec.startsWith('✅')
                                ? Colors.green
                                : rec.startsWith('❌')
                                    ? Colors.red
                                    : rec.startsWith('💡')
                                        ? Colors.blue
                                        : null,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            rec.replaceFirst(RegExp(r'^[✅❌💡]\s*'), ''),
                            style: TextStyle(
                              color: rec.startsWith('✅')
                                  ? Colors.green.shade700
                                  : rec.startsWith('❌')
                                      ? Colors.red.shade700
                                      : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
              ],
              const Text(
                'Raw Results:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SelectableText(result.toString()),
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

  Future<void> _toggleSetting(
      String userId, String settingName, bool value) async {
    // No longer need to get currentUser here as userId is passed
    setState(() {
      _isUpdating = true;
    });

    try {
      final settingsNotifier =
          ref.read(notificationSettingsProvider(userId).notifier);

      switch (settingName) {
        case 'pushNotificationsEnabled':
          await settingsNotifier.togglePushNotifications(value);
          break;
        case 'followNotifications':
          await settingsNotifier.toggleTypeNotification(
              NotificationType.follow, value);
          break;
        case 'postNotifications':
          await settingsNotifier.toggleTypeNotification(
              NotificationType.newPost, value);
          break;
        case 'likeNotifications':
          await settingsNotifier.toggleTypeNotification(
              NotificationType.postLike, value);
          break;
        case 'commentNotifications':
          await settingsNotifier.toggleTypeNotification(
              NotificationType.comment, value);
          break;
        case 'replyNotifications':
          await settingsNotifier.toggleTypeNotification(
              NotificationType.commentReply, value);
          break;
        case 'connectionNotifications':
          // If connectionNotifications covers both request and accepted
          await settingsNotifier.toggleTypeNotification(
              NotificationType.connectionRequest, value);
          break;
        case 'milestoneNotifications':
          await settingsNotifier.toggleTypeNotification(
              NotificationType.postMilestone, value);
          break;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  Future<void> _setMuteUntil(String userId, DateTime? dateTime) async {
    setState(() {
      _isUpdating = true;
    });

    try {
      await ref
          .read(notificationSettingsProvider(userId).notifier)
          .setMuteUntil(dateTime);
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  void _showMuteDialog(String userId) {
    // Pass userId
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMuteOption('1 hour', Duration(hours: 1), userId),
            _buildMuteOption('2 hours', Duration(hours: 2), userId),
            _buildMuteOption('8 hours', Duration(hours: 8), userId),
            _buildMuteOption('24 hours', Duration(hours: 24), userId),
            _buildMuteOption('Until tomorrow', _untilTomorrow(), userId),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildMuteOption(String label, Duration duration, String userId) {
    // Pass userId
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        _setMuteUntil(userId, DateTime.now().add(duration));
      },
    );
  }

  Duration _untilTomorrow() {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1, 8, 0); // 8:00 AM tomorrow
    return tomorrow.difference(now);
  }
}
