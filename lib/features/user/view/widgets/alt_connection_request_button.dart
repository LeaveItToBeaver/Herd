import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/user/data/repositories/user_repository.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

/// A button that handles alt connection actions between users
class AltConnectionButton extends ConsumerStatefulWidget {
  final String targetUserId;

  const AltConnectionButton({
    super.key,
    required this.targetUserId,
  });

  @override
  ConsumerState<AltConnectionButton> createState() =>
      _AltConnectionButtonState();
}

class _AltConnectionButtonState extends ConsumerState<AltConnectionButton> {
  bool _isLoading = false;
  bool _isConnected = false;
  bool _hasPendingRequest = false;
  bool _hasCheckedStatus = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionStatus();
  }

  Future<void> _checkConnectionStatus() async {
    final currentUser = ref.read(authProvider);
    final userRepository = ref.read(userRepositoryProvider);

    if (currentUser == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Check if already connected
      final isConnected = await userRepository.areAltlyConnected(
        currentUser.uid,
        widget.targetUserId,
      );

      // Check if there's a pending request
      final hasPendingRequest = await userRepository.hasAltConnectionRequest(
        currentUser.uid,
        widget.targetUserId,
      );

      if (mounted) {
        setState(() {
          _isConnected = isConnected;
          _hasPendingRequest = hasPendingRequest;
          _hasCheckedStatus = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking connection status: $e')),
        );
      }
    }
  }

  Future<void> _sendConnectionRequest() async {
    final currentUser = ref.read(authProvider);
    final userRepository = ref.read(userRepositoryProvider);

    if (currentUser == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      await userRepository.requestAltConnection(
        currentUser.uid,
        widget.targetUserId,
      );

      if (mounted) {
        setState(() {
          _hasPendingRequest = true;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection request sent')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending connection request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_hasCheckedStatus) {
      return const SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: null,
          child: SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_isConnected) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.check_circle),
          label: const Text('Connected'),
          onPressed: null, // Connected state is non-interactive
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
      );
    }

    if (_hasPendingRequest) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          icon: const Icon(Icons.pending),
          label: const Text('Request Pending'),
          onPressed: null, // Pending state is non-interactive
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.person_add),
        label: const Text('Connect'),
        onPressed: _isLoading ? null : _sendConnectionRequest,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
