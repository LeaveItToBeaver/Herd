import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/moderation_providers.dart';
import '../../data/models/report_model.dart';

class ModerationDashboardScreen extends ConsumerWidget {
  final String herdId;

  const ModerationDashboardScreen({
    super.key,
    required this.herdId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingReportsAsync = ref.watch(herdPendingReportsProvider(herdId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Dashboard'),
      ),
      body: pendingReportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (reports) {
          if (reports.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text(
                    'No pending reports',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All content has been reviewed',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              return _buildReportCard(context, ref, report);
            },
          );
        },
      ),
    );
  }

  Widget _buildReportCard(
      BuildContext context, WidgetRef ref, ReportModel report) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: ExpansionTile(
        leading: Icon(
          _getReportIcon(report.targetType),
          color: _getReasonColor(report.reason),
        ),
        title: Text(
          '${report.targetType.name.toUpperCase()} - ${report.reason.displayName}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Reported ${_formatDate(report.timestamp)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (report.description != null &&
                    report.description!.isNotEmpty) ...[
                  Text(
                    'Report Description:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(report.description!),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _handleDismissReport(context, ref, report),
                      child: const Text('Dismiss'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _handleTakeAction(context, ref, report),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text('Take Action'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getReportIcon(ReportTargetType type) {
    switch (type) {
      case ReportTargetType.post:
        return Icons.article;
      case ReportTargetType.comment:
        return Icons.comment;
      case ReportTargetType.user:
        return Icons.person;
    }
  }

  Color _getReasonColor(ReportReason reason) {
    switch (reason) {
      case ReportReason.spam:
        return Colors.grey;
      case ReportReason.harassment:
        return Colors.red;
      case ReportReason.inappropriate:
        return Colors.orange;
      case ReportReason.misinformation:
        return Colors.blue;
      case ReportReason.other:
        return Colors.purple;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _handleDismissReport(
      BuildContext context, WidgetRef ref, ReportModel report) {
    // TODO: Implement dismiss report
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Report dismissed')),
    );
  }

  void _handleTakeAction(
      BuildContext context, WidgetRef ref, ReportModel report) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Action',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (report.targetType == ReportTargetType.post) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Post'),
                onTap: () {
                  Navigator.pop(context);
                  _removePost(context, ref, report);
                },
              ),
              ListTile(
                leading: const Icon(Icons.warning, color: Colors.orange),
                title: const Text('Warn User'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement warn user
                },
              ),
            ],
            if (report.targetType == ReportTargetType.user) ...[
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Ban User'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Implement ban user
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _removePost(BuildContext context, WidgetRef ref, ReportModel report) {
    ref.read(moderationControllerProvider.notifier).removePost(
          herdId: herdId,
          postId: report.targetId,
          reason: 'Removed due to ${report.reason.displayName}',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post removed')),
    );
  }
}

// Extension for report reason display names
extension ReportReasonExtension on ReportReason {
  String get displayName {
    switch (this) {
      case ReportReason.spam:
        return 'Spam';
      case ReportReason.harassment:
        return 'Harassment';
      case ReportReason.inappropriate:
        return 'Inappropriate Content';
      case ReportReason.misinformation:
        return 'Misinformation';
      case ReportReason.other:
        return 'Other';
    }
  }
}
