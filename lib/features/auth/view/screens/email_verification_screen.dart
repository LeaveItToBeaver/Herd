import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../widgets/app_logo.dart';

class EmailVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailVerificationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState
    extends ConsumerState<EmailVerificationScreen> {
  bool _isResendingEmail = false;
  bool _isVerified = false;
  late Timer _timer;
  int _timeLeft = 60; // Countdown for resend email option

  @override
  void initState() {
    super.initState();
    _startVerificationCheck();
    _startResendTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Start checking if the email has been verified
  void _startVerificationCheck() {
    _timer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => _checkEmailVerified(),
    );
  }

  // Start countdown timer for resend button
  void _startResendTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_timeLeft > 0) {
          setState(() {
            _timeLeft--;
          });
        } else {
          timer.cancel();
        }
      },
    );
  }

  // Check if user's email has been verified
  Future<void> _checkEmailVerified() async {
    try {
      // Reload user data
      await FirebaseAuth.instance.currentUser?.reload();

      // Check if email is verified
      final user = FirebaseAuth.instance.currentUser;

      if (user?.emailVerified ?? false) {
        _timer.cancel();
        setState(() {
          _isVerified = true;
        });

        // Navigate to profile after a short delay to show success state
        if (mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            context.go('/profile');
          });
        }
      }
    } catch (e) {
      print('Error checking email verification: $e');
    }
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    setState(() {
      _isResendingEmail = true;
    });

    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Reset the timer
      setState(() {
        _timeLeft = 60;
        _isResendingEmail = false;
      });

      // Start the countdown again
      _startResendTimer();
    } catch (e) {
      setState(() {
        _isResendingEmail = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend email: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Sign out and go to login
              FirebaseAuth.instance.signOut();
              context.go('/login');
            },
            child: const Text('Skip'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App logo or custom icon
                const AppLogo(size: 60),
                const SizedBox(height: 32),

                // Verification status icon
                Icon(
                  _isVerified ? Icons.check_circle : Icons.mark_email_unread,
                  size: 80,
                  color: _isVerified ? Colors.green : theme.colorScheme.primary,
                ),
                const SizedBox(height: 24),

                // Title text
                Text(
                  _isVerified ? 'Email Verified!' : 'Verify Your Email',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description text
                Text(
                  _isVerified
                      ? 'Your email has been verified successfully. You will be redirected to your profile shortly.'
                      : 'We\'ve sent a verification email to:\n${widget.email}\n\nPlease check your inbox and click the verification link to complete your registration.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Animated progress indicator
                if (!_isVerified)
                  Column(
                    children: [
                      CircularProgressIndicator(
                        value: null, // Continuous animation
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Waiting for verification...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 32),

                // Resend button
                if (!_isVerified)
                  _timeLeft > 0
                      ? Text(
                          'Resend email in $_timeLeft seconds',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        )
                      : TextButton.icon(
                          onPressed: _isResendingEmail
                              ? null
                              : _resendVerificationEmail,
                          icon: _isResendingEmail
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.refresh),
                          label: Text(_isResendingEmail
                              ? 'Sending...'
                              : 'Resend Verification Email'),
                        ),

                const SizedBox(height: 16),

                // Go back to login
                if (!_isVerified)
                  OutlinedButton(
                    onPressed: () {
                      FirebaseAuth.instance.signOut();
                      context.go('/login');
                    },
                    child: const Text('Back to Login'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
