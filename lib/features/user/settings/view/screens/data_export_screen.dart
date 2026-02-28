import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/user/settings/view/providers/data_export_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DataExportScreen extends ConsumerStatefulWidget {
  const DataExportScreen({super.key});

  @override
  ConsumerState<DataExportScreen> createState() => _DataExportScreenState();
}

class _DataExportScreenState extends ConsumerState<DataExportScreen> {
  bool _isRequesting = false;
  bool _isResetting = false;
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Data Export')),
        body: const Center(child: Text('Please log in to access data export.')),
      );
    }

    final statusAsync = ref.watch(dataExportStatusProvider(currentUser.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Export'),
      ),
      body: statusAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _buildErrorState(theme, currentUser.id, error),
        data: (status) => _buildContent(theme, currentUser.id, status),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, String userId, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'Failed to load export status',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(dataExportStatusProvider(userId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
      ThemeData theme, String userId, Map<String, dynamic> status) {
    final hasRequest = status['hasRequest'] == true;
    final exportStatus = status['status'] as String?;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(dataExportStatusProvider(userId));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info card
            _buildInfoCard(theme),

            const SizedBox(height: 24),

            // Status section
            if (!hasRequest || exportStatus == null)
              _buildNoExportState(theme, userId)
            else if (exportStatus == 'pending' || exportStatus == 'processing')
              _buildProcessingState(theme, userId, status)
            else if (exportStatus == 'completed')
              _buildCompletedState(theme, userId, status)
            else if (exportStatus == 'failed')
              _buildFailedState(theme, userId, status)
            else
              _buildNoExportState(theme, userId),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'About Data Exports',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'You can request a copy of all your personal data. This includes your profile, posts, comments, connections, saved posts, herd memberships, and more.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Exports are available for download for 30 days after they are generated.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoExportState(ThemeData theme, String userId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.download_rounded, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Request Your Data',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Your data export includes:',
            ),
            const SizedBox(height: 8),
            _buildDataListItem('Public and alt profile information'),
            _buildDataListItem('Posts and comments'),
            _buildDataListItem('Connections and follows'),
            _buildDataListItem('Saved posts'),
            _buildDataListItem('Herd memberships'),
            _buildDataListItem('Notification history'),
            _buildDataListItem('Other account activity'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isRequesting ? null : () => _requestExport(userId),
                icon: _isRequesting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_download),
                label: Text(
                    _isRequesting ? 'Requesting...' : 'Request Data Export'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessingState(
      ThemeData theme, String userId, Map<String, dynamic> status) {
    final requestedAt = status['requestedAt'] as String?;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Export In Progress',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Your data export is being prepared. This may take a few minutes depending on the amount of data.',
            ),
            if (requestedAt != null) ...[
              const SizedBox(height: 12),
              Text(
                'Requested: ${_formatDate(requestedAt)}',
                style: theme.textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'You will receive a notification when your data is ready to download.',
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        ref.invalidate(dataExportStatusProvider(userId)),
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Check Status'),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _isResetting ? null : () => _resetExport(userId),
                  child: Text(
                    _isResetting ? 'Resetting...' : 'Reset Request',
                    style: TextStyle(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedState(
      ThemeData theme, String userId, Map<String, dynamic> status) {
    final downloadUrl = status['downloadUrl'] as String?;
    final fileSizeBytes = status['fileSizeBytes'] as int?;
    final expiresAt = status['expiresAt'] as String?;
    final isExpired = status['isExpired'] == true;
    final downloaded = status['downloaded'] == true;
    final completedAt = status['completedAt'] as String?;

    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isExpired ? Icons.timer_off : Icons.check_circle,
                      color: isExpired ? Colors.orange : Colors.green,
                      size: 28,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        isExpired
                            ? 'Export Expired'
                            : 'Export Ready for Download',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (isExpired) ...[
                  const Text(
                    'This data export has expired and is no longer available for download. You can request a new export below.',
                  ),
                ] else ...[
                  const Text(
                    'Your data export is ready! Tap the button below to download your data as a JSON file.',
                  ),
                ],
                const SizedBox(height: 16),

                // Export details
                _buildDetailRow(
                  theme,
                  icon: Icons.calendar_today,
                  label: 'Completed',
                  value: completedAt != null ? _formatDate(completedAt) : 'N/A',
                ),
                if (fileSizeBytes != null)
                  _buildDetailRow(
                    theme,
                    icon: Icons.storage,
                    label: 'File Size',
                    value: _formatFileSize(fileSizeBytes),
                  ),
                if (expiresAt != null && !isExpired)
                  _buildDetailRow(
                    theme,
                    icon: Icons.timer,
                    label: 'Expires',
                    value: _formatDate(expiresAt, isFutureDate: true),
                  ),
                if (downloaded)
                  _buildDetailRow(
                    theme,
                    icon: Icons.download_done,
                    label: 'Status',
                    value: 'Previously downloaded',
                  ),
                const SizedBox(height: 20),

                if (!isExpired && downloadUrl != null) ...[
                  // Download button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isDownloading
                          ? null
                          : () => _downloadExport(downloadUrl, userId),
                      icon: _isDownloading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.download),
                      label:
                          Text(_isDownloading ? 'Opening...' : 'Download Data'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The download link is valid for 1 hour. Refresh this page if it expires.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ] else if (!isExpired && downloadUrl == null) ...[
                  // Download URL not available — prompt refresh
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          ref.invalidate(dataExportStatusProvider(userId)),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Load Download Link'),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The download link could not be generated. Tap above to try again.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Request new export button
        if (isExpired)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isRequesting ? null : () => _requestExport(userId),
              icon: _isRequesting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh),
              label:
                  Text(_isRequesting ? 'Requesting...' : 'Request New Export'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          )
        else
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => ref.invalidate(dataExportStatusProvider(userId)),
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Status'),
            ),
          ),
      ],
    );
  }

  Widget _buildFailedState(
      ThemeData theme, String userId, Map<String, dynamic> status) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: theme.colorScheme.error, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Export Failed',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong while preparing your data export. Please try again.',
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isResetting ? null : () => _resetAndRequest(userId),
                icon: _isResetting
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isResetting ? 'Retrying...' : 'Reset & Try Again'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildDataListItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    ThemeData theme, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  // --- Actions ---

  Future<void> _requestExport(String userId) async {
    setState(() => _isRequesting = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.requestDataExport(userId);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data export requested successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(dataExportStatusProvider(userId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to request export'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Future<void> _downloadExport(String url, String userId) async {
    setState(() => _isDownloading = true);

    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);

        // Mark as downloaded by refreshing status
        // The cloud function tracks this via signed URL access
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Download started in your browser.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open download link. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening download: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isDownloading = false);
    }
  }

  Future<void> _resetExport(String userId) async {
    setState(() => _isResetting = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      final result = await userRepository.resetDataExportRequest(userId);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Export request has been reset.'),
            backgroundColor: Colors.green,
          ),
        );
        ref.invalidate(dataExportStatusProvider(userId));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to reset request'),
            backgroundColor: Colors.orange,
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
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  Future<void> _resetAndRequest(String userId) async {
    setState(() => _isResetting = true);

    try {
      final userRepository = ref.read(userRepositoryProvider);
      await userRepository.resetDataExportRequest(userId);

      if (!mounted) return;

      // Now request a new export
      final result = await userRepository.requestDataExport(userId);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('New data export requested!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to request export'),
            backgroundColor: Colors.orange,
          ),
        );
      }

      ref.invalidate(dataExportStatusProvider(userId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isResetting = false);
    }
  }

  // --- Formatters ---

  String _formatDate(String isoDate, {bool isFutureDate = false}) {
    try {
      final date = DateTime.parse(isoDate);
      final now = DateTime.now();

      if (isFutureDate || date.isAfter(now)) {
        // Future date — show "in X days/hours"
        final diff = date.difference(now);
        if (diff.inDays > 1) return 'in ${diff.inDays} days';
        if (diff.inDays == 1) return 'tomorrow';
        if (diff.inHours >= 1) return 'in ${diff.inHours}h';
        if (diff.inMinutes >= 1) return 'in ${diff.inMinutes}m';
        return 'soon';
      }

      // Past date — show "X ago"
      final diff = now.difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inHours < 1) return '${diff.inMinutes}m ago';
      if (diff.inDays < 1) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
