import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/view/providers/auth_provider.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/user/view/providers/user_provider.dart';
import '../bootstrap/app_bootstraps.dart';

class AuthenticationWrapper extends ConsumerStatefulWidget {
  final Widget child;

  const AuthenticationWrapper({super.key, required this.child});

  @override
  ConsumerState<AuthenticationWrapper> createState() =>
      _AuthenticationWrapperState();
}

class _AuthenticationWrapperState extends ConsumerState<AuthenticationWrapper> {
  String? _lastUserId;

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // User logged out - cleanup notifications
          _handleUserLogout();
          return const LoginScreen();
        }

        // User is authenticated, now check if user data is loaded
        final userData = ref.watch(currentUserStreamProvider);

        return userData.when(
          data: (userDataModel) {
            // User data loaded - initialize notifications if needed
            _handleUserLogin(user.uid);
            return widget.child;
          },
          loading: () => const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading user data...'),
                ],
              ),
            ),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Error loading user data',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.refresh(currentUserStreamProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking authentication...'),
            ],
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'Authentication Error',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(authStateChangesProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Handle user login - initialize notifications
  void _handleUserLogin(String userId) {
    // Only initialize if user changed or first time
    if (_lastUserId != userId) {
      _lastUserId = userId;

      // Initialize notifications for this user
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeNotificationsForUser(userId);
      });
    }
  }

  /// Handle user logout - cleanup notifications
  void _handleUserLogout() {
    if (_lastUserId != null) {
      _lastUserId = null;

      // Cleanup notifications
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cleanupNotifications();
      });
    }
  }

  /// Initialize notifications for the authenticated user
  Future<void> _initializeNotificationsForUser(String userId) async {
    try {
      final bootstrap = ref.read(AppBootstrap.appBootstrapProvider);
      await bootstrap.initializeNotifications(userId, ref);
    } catch (e) {
      debugPrint('❌ Error initializing notifications in AuthWrapper: $e');
    }
  }

  /// Cleanup notifications on logout
  Future<void> _cleanupNotifications() async {
    try {
      final bootstrap = ref.read(AppBootstrap.appBootstrapProvider);
      await bootstrap.cleanupNotifications(ref);
    } catch (e) {
      debugPrint('❌ Error cleaning up notifications in AuthWrapper: $e');
    }
  }
}
