import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        // Use addPostFrameCallback to navigate after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            if (user != null) {
              context.go('/profile/${user.uid}');
            } else {
              context.go('/login');
            }
          }
        });
        // Show loading while redirecting
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, stack) => Scaffold(
        body: Center(
          child: Text('Error: $err'),
        ),
      ),
    );
  }
}
