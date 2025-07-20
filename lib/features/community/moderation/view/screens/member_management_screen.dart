import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MemberManagementScreen extends ConsumerWidget {
  final String herdId;

  const MemberManagementScreen({
    super.key,
    required this.herdId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Member Management'),
      ),
      body: const Center(
        child: Text('Member management features coming soon'),
      ),
    );
  }
}
