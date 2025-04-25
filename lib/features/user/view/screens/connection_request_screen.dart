import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

import '../../data/models/alt_connection_request_model.dart';

class ConnectionRequestsScreen extends ConsumerWidget {
  const ConnectionRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final userRepository = ref.watch(userRepositoryProvider);

    if (currentUser == null) {
      return const Scaffold(
        body: Center(
          child: Text('You need to be logged in to view connection requests'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Connection Requests'),
      ),
      body: StreamBuilder<List<AltConnectionRequest>>(
        stream: userRepository.getPendingConnectionRequests(currentUser.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final requests = snapshot.data ?? [];

          if (requests.isEmpty) {
            return const Center(
              child: Text('No pending connection requests'),
            );
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return ConnectionRequestItem(
                request: request,
                onAccept: () async {
                  try {
                    await userRepository.acceptAltConnection(
                      currentUser.uid,
                      request.requesterId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connection accepted')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
                onReject: () async {
                  try {
                    await userRepository.rejectAltConnection(
                      currentUser.uid,
                      request.requesterId,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connection rejected')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}

class ConnectionRequestItem extends StatelessWidget {
  final AltConnectionRequest request;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const ConnectionRequestItem({
    super.key,
    required this.request,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info row
            Row(
              children: [
                // Profile image
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: request.requesterProfileImageURL != null &&
                          request.requesterProfileImageURL!.isNotEmpty
                      ? NetworkImage(request.requesterProfileImageURL!)
                      : null,
                  child: request.requesterProfileImageURL == null ||
                          request.requesterProfileImageURL!.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.grey[400],
                          size: 24,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.requesterUsername ?? 'Unknown user',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (request.requesterName != null)
                        Text(
                          request.requesterName!,
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        'Sent ${_formatTimestamp(request.timestamp)}',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                  child: const Text('Decline'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Accept'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime? timestamp) {
    if (timestamp == null) return 'recently';

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'just now';
    }
  }
}
