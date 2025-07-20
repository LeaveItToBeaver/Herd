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
  Timer? _verificationPoll;
  int _timeLeft = 60;
  Timer? _resendCountdown;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    // First, send an email verification if needed
    _sendInitialVerificationIfNeeded();

    // Poll for email verification status
    _startVerificationPolling();

    // Start the resend countdown
    _startResendCountdown();
  }

  Future<void> _sendInitialVerificationIfNeeded() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        debugPrint('Initial verification email sent to ${user.email}');
      }
    } catch (e) {
      debugPrint('Error sending initial verification email: $e');
    }
  }

  void _startVerificationPolling() {
    debugPrint('Starting verification polling');
    _verificationPoll = Timer.periodic(
      const Duration(seconds: 3),
      (_) async {
        debugPrint('Checking verification status...');
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            debugPrint('User is null during verification check');
            return;
          }

          // Force reload user data to get fresh emailVerified status
          await user.reload();

          // Get the user again after reload
          final refreshedUser = FirebaseAuth.instance.currentUser;

          debugPrint(
              'Current verification status: ${refreshedUser?.emailVerified}');

          if (refreshedUser?.emailVerified == true) {
            debugPrint('Email verified successfully!');
            _verificationPoll?.cancel();

            if (_isMounted) {
              setState(() {
                _isVerified = true;
              });

              // Navigate after a short delay
              Future.delayed(const Duration(seconds: 2), () {
                if (_isMounted && mounted) {
                  debugPrint('Navigating to profile after verification');
                  context.go('/'); // Let router redirects handle navigation
                }
              });
            }
          }
        } catch (e) {
          debugPrint('Error during verification check: $e');
        }
      },
    );
  }

  void _startResendCountdown() {
    _timeLeft = 60;
    _resendCountdown?.cancel();
    _resendCountdown = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 0) {
        timer.cancel();
      } else if (_isMounted) {
        setState(() => _timeLeft--);
      }
    });
  }

  @override
  void dispose() {
    debugPrint('Disposing EmailVerificationScreen');
    _isMounted = false;
    _verificationPoll?.cancel();
    _resendCountdown?.cancel();
    super.dispose();
  }

  // Resend verification email
  Future<void> _resendVerificationEmail() async {
    if (_isMounted) {
      setState(() {
        _isResendingEmail = true;
      });
    }

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
        debugPrint('Verification email resent successfully');

        if (_isMounted && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification email resent successfully'),
              backgroundColor: Colors.green,
            ),
          );

          // Reset the timer
          setState(() {
            _timeLeft = 60;
            _isResendingEmail = false;
          });

          // Start the countdown again
          _startResendCountdown();
        }
      } else {
        debugPrint('Cannot resend: user is null');
        if (_isMounted && mounted) {
          setState(() {
            _isResendingEmail = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: User not signed in'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error resending verification email: $e');

      if (_isMounted && mounted) {
        setState(() {
          _isResendingEmail = false;
        });

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
                      ? 'Your email has been verified successfully. You will be redirected shortly.'
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
