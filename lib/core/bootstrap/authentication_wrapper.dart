import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/view/providers/auth_provider.dart';
import '../../features/auth/view/screens/login_screen.dart';
import '../../features/user/view/providers/user_provider.dart';

class AuthenticationWrapper extends ConsumerWidget {
  final Widget child;

  const AuthenticationWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          // Instead of creating a new MaterialApp, just return LoginScreen
          // GoRouter will handle the navigation
          return const LoginScreen();
        }

        // User is authenticated, now check if user data is loaded
        final userData = ref.watch(currentUserStreamProvider);

        return userData.when(
          data: (_) => child, // User data loaded, show app
          loading: () => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
          error: (error, stack) => Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Error loading user data'),
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
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Authentication error: $error')),
      ),
    );
  }
}
