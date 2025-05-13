import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/notifications/data/models/notification_model.dart';
import 'package:herdapp/features/notifications/data/models/notification_settings_model.dart';
import 'package:herdapp/features/notifications/view/providers/notification_provider.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  bool _isLoading = false;

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
      body: settingsAsync == null
          ? const Center(child: CircularProgressIndicator())
          : _buildSettingsList(settingsAsync),
    );
  }

  Widget _buildSettingsList(NotificationSettingsModel settings) {
    return ListView(
      children: [
        // Global notification settings
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
          onChanged: _isLoading
              ? null
              : (value) => _toggleSetting(
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
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'followNotifications',
                      value,
                    ),
          ),

          SwitchListTile(
            title: const Text('New Posts'),
            subtitle: const Text('When people you follow post new content'),
            value: settings.postNotifications,
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'postNotifications',
                      value,
                    ),
          ),

          SwitchListTile(
            title: const Text('Likes'),
            subtitle: const Text('When someone likes your post'),
            value: settings.likeNotifications,
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'likeNotifications',
                      value,
                    ),
          ),

          SwitchListTile(
            title: const Text('Comments'),
            subtitle: const Text('When someone comments on your post'),
            value: settings.commentNotifications,
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'commentNotifications',
                      value,
                    ),
          ),

          SwitchListTile(
            title: const Text('Replies'),
            subtitle: const Text('When someone replies to your comment'),
            value: settings.replyNotifications,
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'replyNotifications',
                      value,
                    ),
          ),

          SwitchListTile(
            title: const Text('Connection Requests'),
            subtitle: const Text('Connection requests and acceptances'),
            value: settings.connectionNotifications,
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'connectionNotifications',
                      value,
                    ),
          ),

          SwitchListTile(
            title: const Text('Milestones'),
            subtitle: const Text('When your posts reach certain thresholds'),
            value: settings.milestoneNotifications,
            onChanged: _isLoading
                ? null
                : (value) => _toggleSetting(
                      'milestoneNotifications',
                      value,
                    ),
          ),

          const Divider(),

          // Temporary mute section
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
                  ? 'Muted until ${_formatDateTime(settings.mutedUntil!)}'
                  : 'Temporary Mute',
            ),
            subtitle: const Text('Pause notifications for a specific time'),
            trailing: settings.isMuted
                ? ElevatedButton(
                    onPressed: _isLoading ? null : () => _setMuteUntil(null),
                    child: const Text('Unmute'),
                  )
                : const Icon(Icons.arrow_forward_ios, size: 16),
            onTap:
                settings.isMuted || _isLoading ? null : () => _showMuteDialog(),
          ),
        ],
      ],
    );
  }

  Future<void> _toggleSetting(String settingName, bool value) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final settingsNotifier =
          ref.read(notificationSettingsProvider(currentUser.uid).notifier);

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
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _setMuteUntil(DateTime? dateTime) async {
    final currentUser = ref.read(authProvider);
    if (currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(notificationSettingsProvider(currentUser.uid).notifier)
          .setMuteUntil(dateTime);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMuteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mute Notifications'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMuteOption('1 hour', Duration(hours: 1)),
            _buildMuteOption('2 hours', Duration(hours: 2)),
            _buildMuteOption('8 hours', Duration(hours: 8)),
            _buildMuteOption('24 hours', Duration(hours: 24)),
            _buildMuteOption('Until tomorrow', _untilTomorrow()),
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

  Widget _buildMuteOption(String label, Duration duration) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        _setMuteUntil(DateTime.now().add(duration));
      },
    );
  }

  Duration _untilTomorrow() {
    final now = DateTime.now();
    final tomorrow =
        DateTime(now.year, now.month, now.day + 1, 8, 0); // 8:00 AM tomorrow
    return tomorrow.difference(now);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = dateTime.difference(now);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h from now';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m from now';
    } else {
      return '${difference.inMinutes}m from now';
    }
  }
}
