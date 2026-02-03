import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'cache_settings_screen.dart';
import 'package:herdapp/core/widgets/markdown_dialog.dart';
import 'package:herdapp/features/user/user_management/view/screens/blocked_users_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final bool _isLoading = false;
  String _appVersion = '';
  Timer? _debounceTimer;
  final bool _isUpdatingPreference = false;

  // User preferences
  final bool _allowNSFWContent = false;
  final bool _blurNSFWContent = true;
  final bool _showHerdsInAltFeed = true;
  final bool _isOver18 = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = '${packageInfo.version} (${packageInfo.buildNumber})';
    });
  }

  // Future<void> _debouncedSavePreference(String key, dynamic value) async {
  //   // Cancel any previous timer
  //   _debounceTimer?.cancel();
  //   // Don't start a new timer if we're already updating
  //   if (_isUpdatingPreference) return;
  //   // Start a new timer
  //   _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
  //     if (mounted) {
  //       setState(() => _isUpdatingPreference = true);
  //       try {
  //         await _savePreference(key, value);
  //       } finally {
  //         if (mounted) {
  //           setState(() => _isUpdatingPreference = false);
  //         }
  //       }
  //     }
  //   });
  // }

  // Future<void> _loadUserPreferences() async {
  //   final currentUser = ref.read(authProvider);
  //   if (currentUser == null) return;
  //   setState(() => _isLoading = true);
  //   try {
  //     final userModel = await ref.read(userProvider(currentUser.uid).future);
  //     if (userModel != null) {
  //       // Load preferences from user model
  //       setState(() {
  //         _allowNSFWContent =
  //             userModel.preferences['allowNSFWContent'] ?? false;
  //         _blurNSFWContent = userModel.preferences['blurNSFWContent'] ?? true;
  //         _showHerdsInAltFeed =
  //             userModel.preferences['showHerdsInAltFeed'] ?? true;
  //         _isOver18 = userModel.preferences['isOver18'] ?? false;
  //       });
  //     }
  //   } catch (e) {
  //     // Handle error
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _savePreference(String key, dynamic value) async {
  //   final currentUser = ref.read(authProvider);
  //   if (currentUser == null) return;
  //   setState(() => _isLoading = true);
  //   try {
  //     final userRepository = ref.read(userRepositoryProvider);
  //     final userModel = await ref.read(userProvider(currentUser.uid).future);
  //     if (userModel != null) {
  //       // Update the preferences map
  //       final updatedPreferences = {...userModel.preferences};
  //       updatedPreferences[key] = value;
  //       // Save to user model
  //       await userRepository.updateUser(currentUser.uid, {
  //         'preferences': updatedPreferences,
  //       });
  //       // Show success message
  //       if (mounted) {
  //         ScaffoldMessenger.of(context).showSnackBar(
  //           const SnackBar(content: Text('Preference saved')),
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     // Show error message
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error saving preference: $e')),
  //       );
  //     }
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  // Future<void> _updateUserModelNSFWSettings(bool allowNSFW) async {
  //   final currentUser = ref.read(authProvider);
  //   if (currentUser == null) return;
  //   try {
  //     // Get user repository from provider
  //     final userRepository = ref.read(userRepositoryProvider);
  //     // Update user model with the new NSFW settings
  //     await userRepository.updateUser(currentUser.uid, {
  //       'allowNSFW': allowNSFW,
  //       // We're updating the user's preference to allow NSFW content,
  //       // not marking the user profile itself as NSFW
  //     });
  //     if (mounted) {
  //       // Update was successful
  //       debugPrint('User NSFW settings updated: allowNSFW=$allowNSFW');
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text('Error updating NSFW settings: $e')),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(currentUserSettingsProvider);
    final settingsNotifier = ref.watch(currentUserSettingsProvider.notifier);
    final theme = Theme.of(context);

    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading settings: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(currentUserSettingsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (settingsState) => Scaffold(
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Account Section
                    _buildExpandableSection(
                      title:
                          'Account${_isUpdatingPreference ? ' (Saving...)' : ''}',
                      isInitiallyExpanded: false,
                      children: [
                        Consumer(
                          builder: (context, ref, _) {
                            final userId = ref.read(authProvider)?.uid;
                            if (userId == null) return const SizedBox.shrink();

                            final userAsync = ref.watch(userProvider(userId));

                            return ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Account Settings'),
                              subtitle:
                                  const Text('Manage your account details'),
                              trailing: userAsync.isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2))
                                  : const Icon(Icons.chevron_right),
                              onTap: userAsync.hasValue &&
                                      userAsync.value != null
                                  ? () => context.push('/editProfile', extra: {
                                        'user': userAsync.value,
                                        'isPublic': true,
                                      })
                                  : null,
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.palette),
                          title: const Text('Customize Appearance'),
                          subtitle:
                              const Text('Personalize your app experience'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            context.push('/customization');
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.visibility),
                          title: const Text('Privacy'),
                          subtitle: const Text(
                              'Control your account privacy settings'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showPrivacySettings(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.security),
                          title: const Text('Security'),
                          subtitle: const Text('Manage account security'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showSecuritySettings(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.block),
                          title: const Text('Blocked Users & Herds'),
                          subtitle: const Text('Manage your block list'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showBlockedList(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Content Section
                    _buildExpandableSection(
                      title:
                          'Content${_isUpdatingPreference ? ' (Saving...)' : ''}',
                      isInitiallyExpanded: false,
                      children: [
                        SwitchListTile(
                          title: const Text('Allow NSFW Content'),
                          subtitle: Text(
                            settingsState.isOver18
                                ? 'Show content marked as NSFW'
                                : 'You must be 18+ to enable this setting',
                          ),
                          value: settingsState.allowNSFWContent,
                          secondary: settingsState
                                  .isFieldUpdating('allowNSFWContent')
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.explicit),
                          onChanged: settingsState.isOver18
                              ? (value) =>
                                  settingsNotifier.updateAllowNSFWContent(value)
                              : null,
                        ),
                        if (!settingsState.isOver18)
                          CheckboxListTile(
                            title:
                                const Text('I confirm that I am 18 or older'),
                            value: settingsState.isOver18,
                            onChanged: (value) {
                              if (value ?? false) {
                                _showAgeVerificationDialog();
                              }
                            },
                          ),
                        SwitchListTile(
                          title: const Text('Blur NSFW Content'),
                          subtitle: const Text(
                              'Blur images and videos marked as NSFW'),
                          value: settingsState.blurNSFWContent,
                          secondary: settingsState
                                  .isFieldUpdating('blurNSFWContent')
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.blur_on),
                          onChanged: (value) =>
                              settingsNotifier.updateBlurNSFWContent(value),
                        ),
                        SwitchListTile(
                          title: const Text('Show Herds in Alt Feed'),
                          subtitle: const Text(
                              'Allow herd posts to appear in your alt feed'),
                          value: settingsState.showHerdsInAltFeed,
                          secondary: settingsState
                                  .isFieldUpdating('showHerdsInAltFeed')
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.group),
                          onChanged: (value) =>
                              settingsNotifier.updateShowHerdsInAltFeed(value),
                        ),
                        ListTile(
                          leading: const Icon(Icons.tune),
                          title: const Text('Feed Preferences'),
                          subtitle:
                              const Text('Customize your feed experience'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showFeedPreferences(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Data Section
                    _buildExpandableSection(
                      title: 'Data',
                      isInitiallyExpanded: false,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.storage),
                          title: const Text('Cache Settings'),
                          subtitle: const Text('Manage app data storage'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CacheSettingsScreen(),
                            ),
                          ),
                        ),
                        ListTile(
                          leading: const Icon(Icons.download),
                          title: const Text('Download Your Data'),
                          subtitle: const Text(
                              'Request a copy of your personal data'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showDataDownloadInfo(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Support Section
                    _buildExpandableSection(
                      title: 'Support',
                      isInitiallyExpanded: false,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('About'),
                          subtitle: Text('Version $_appVersion'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showAboutDialog(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.help),
                          title: const Text('Help & Support'),
                          subtitle: const Text('Get assistance with the app'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showSupportOptions(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.description),
                          title: const Text('Terms of Service'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showTermsOfService(context),
                        ),
                        ListTile(
                          leading: const Icon(Icons.privacy_tip),
                          title: const Text('Privacy Policy'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showPrivacyPolicy(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Logout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Log Out'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () => _showLogoutConfirmation(context),
                      ),
                    ),

                    const SizedBox(height: 32),

                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (context) => const AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 16),
                                      Text('Recalculating post counts...'),
                                    ],
                                  ),
                                ),
                              );

                              final postRepo = ref.read(postRepositoryProvider);
                              final result =
                                  await postRepo.recalculateAllUsersInBatches();

                              if (!context.mounted) return;
                              Navigator.of(context)
                                  .pop(); // Close loading dialog

                              if (result['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'])),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error: ${result['error']}')),
                                );
                              }
                            } catch (e) {
                              Navigator.of(context)
                                  .pop(); // Close loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: const Text('Fix All Post Counts (Batch)'),
                        ),
                        ElevatedButton(
                          // 24 * 2 = 48 Herd posts 10 alt posts
                          onPressed: () async {
                            try {
                              final postRepo = ref.read(postRepositoryProvider);
                              final currentUser = ref.read(currentUserProvider);
                              final userId = currentUser.value?.id;

                              if (userId == null) return;

                              final result = await postRepo
                                  .recalculateUserPostCounts(userId);

                              if (!context.mounted) return;

                              if (result['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(result['message'])),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                          child: const Text('Fix My Post Counts'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required List<Widget> children,
    bool isInitiallyExpanded = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            inherit: true,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        initiallyExpanded: isInitiallyExpanded,
        children: [
          ...children,
        ],
      ),
    );
  }

  // Placeholder dialogs and navigation functions
  Future<void> _showAgeVerificationDialog() async {
    final settings = ref.read(currentUserSettingsProvider.notifier);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Age Verification'),
        content: const Text(
          'By confirming, you certify that you are 18 years of age or older. '
          'Some content displayed may contain mature themes not suitable for minors.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              settings.updateIsOver18(true);
            },
            child: const Text('I Confirm'),
          ),
        ],
      ),
    );
  }

  void _showPrivacySettings(BuildContext context) {
    // Show privacy settings dialog or navigate to privacy settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Settings'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This is a placeholder for privacy settings.'),
              SizedBox(height: 16),
              Text('Here you\'ll be able to:'),
              SizedBox(height: 8),
              Text('• Control your public profile visibility'),
              Text('• Manage your alt profile privacy'),
              Text('• Adjust who can follow/connect with you'),
              Text('• Set content visibility options'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSecuritySettings(BuildContext context) {
    // Show security settings dialog or navigate to security settings
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Security Settings'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This is a placeholder for security settings.'),
              SizedBox(height: 16),
              Text('Here you\'ll be able to:'),
              SizedBox(height: 8),
              Text('• Change your password'),
              Text('• Enable two-factor authentication'),
              Text('• View account activity'),
              Text('• Manage connected devices'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBlockedList(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const BlockedUsersScreen(),
      ),
    );
  }

  void _showFeedPreferences(BuildContext context) {
    // Show feed preferences dialog or navigate to feed preferences screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Feed Preferences'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('This is a placeholder for feed preferences.'),
              SizedBox(height: 16),
              Text('Here you\'ll be able to:'),
              SizedBox(height: 8),
              Text('• Set default sort order'),
              Text('• Hide specific types of content'),
              Text('• Adjust content recommendations'),
              Text('• Manage interactions with posts'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDataDownloadInfo(BuildContext context) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request your data')),
      );
      return;
    }

    // Check if there's already a pending request
    final userRepository = ref.read(userRepositoryProvider);
    final hasPending =
        await userRepository.hasPendingDataExport(currentUser.id);

    if (!context.mounted) return;

    if (hasPending) {
      // Show status dialog for pending request
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Data Export In Progress'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Your data export is being processed.',
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'You will receive a notification when your data is ready.',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'If your request seems stuck (more than 10 minutes), you can reset it and try again.',
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _resetDataExportRequest(context, currentUser.id);
              },
              child: const Text('Reset Request'),
            ),
          ],
        ),
      );
      return;
    }

    // Show data download request dialog
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Download Your Data'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You can request a copy of all the data associated with your account. This includes:',
            ),
            SizedBox(height: 16),
            Text('• Your public and alt profile information'),
            Text('• Your posts and comments'),
            Text('• Your connections and follows'),
            Text('• Your saved posts'),
            Text('• Your herd memberships'),
            Text('• Your notifications history'),
            Text('• Other account activity'),
            SizedBox(height: 16),
            Text(
              'Once your data is ready, you will receive a notification. Our support team will then send your data to your registered email address in JSON format.',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                inherit: true,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'This process may take up to 48 hours.',
              style: TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await _submitDataExportRequest(context, currentUser.id);
            },
            child: const Text('Request Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitDataExportRequest(
      BuildContext context, String userId) async {
    // Show loading indicator with more descriptive text since export happens synchronously
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Processing your data export...'),
            SizedBox(height: 8),
            Text(
              'This may take a minute depending on the amount of data.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.requestDataExport(userId);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success'] == true) {
        // Show success dialog with more details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            icon: const Icon(Icons.check_circle, color: Colors.green, size: 48),
            title: const Text('Data Export Complete!'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your data has been successfully exported.',
                ),
                SizedBox(height: 12),
                Text(
                  'You will receive a notification with instructions on how to download your data. Our support team will send your data to your registered email address.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to submit request'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetDataExportRequest(
      BuildContext context, String userId) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Resetting request...'),
          ],
        ),
      ),
    );

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.resetDataExportRequest(userId);

      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Request reset'),
          backgroundColor:
              result['success'] == true ? Colors.green : Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );

      // If reset was successful, show the data download dialog again
      if (result['success'] == true && context.mounted) {
        _showDataDownloadInfo(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAboutDialog(BuildContext context) {
    // Show about dialog with app information
    showAboutDialog(
      context: context,
      applicationName: 'Herd',
      applicationVersion: _appVersion,
      applicationIcon: const FlutterLogo(size: 48),
      applicationLegalese: '© 2025 Herd App. All rights reserved.',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Herd is a social platform with a unique dual-identity system. Connect openly with friends and family through your public profile, and interact anonymously with the world through your alt profile.',
        ),
      ],
    );
  }

  void _showSupportOptions(BuildContext context) {
    // Show support options dialog or navigate to support screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Help & Support'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.help_outline),
              title: Text('FAQs'),
              subtitle: Text('Find answers to common questions'),
            ),
            ListTile(
              leading: Icon(Icons.mail_outline),
              title: Text('Contact Support'),
              subtitle: Text('Email us at support@herdapp.com'),
            ),
            ListTile(
              leading: Icon(Icons.feedback_outlined),
              title: Text('Send Feedback'),
              subtitle: Text('Help us improve the app'),
            ),
            ListTile(
              leading: Icon(Icons.bug_report_outlined),
              title: Text('Report a Bug'),
              subtitle: Text('Let us know if something isn\'t working'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    // Show terms of service dialog using markdown content
    showMarkdownDialog(
      context,
      title: 'Terms of Service',
      assetPath: 'assets/legal/terms.md',
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    // Show privacy policy dialog using markdown content
    showMarkdownDialog(
      context,
      title: 'Privacy Policy',
      assetPath: 'assets/legal/privacy.md',
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    // Show logout confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Perform logout
              ref.read(authProvider.notifier).signOut();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
