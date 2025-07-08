import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/notifications/view/providers/notification_provider.dart';
import 'package:herdapp/features/auth/view/providers/auth_provider.dart';

/// Notification badge that shows unread count
class NotificationBadge extends ConsumerWidget {
  final Widget child;
  final bool showDot;
  final Color? badgeColor;
  final Color? textColor;
  final double? badgeSize;

  const NotificationBadge({
    super.key,
    required this.child,
    this.showDot = false,
    this.badgeColor,
    this.textColor,
    this.badgeSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);
    final theme = Theme.of(context);

    if (currentUser == null) {
      return child;
    }

    // Watch unread count
    final unreadCountAsync =
        ref.watch(unreadNotificationCountProvider(currentUser.uid));

    return unreadCountAsync.when(
      data: (count) {
        if (count == 0) {
          return child;
        }

        return Badge(
          label: showDot
              ? null
              : Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: textColor ?? theme.colorScheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          backgroundColor: badgeColor ?? Colors.red,
          child: child,
        );
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

/// App bar notification icon with badge
class NotificationIconButton extends ConsumerWidget {
  final Color? iconColor;
  final double? iconSize;

  const NotificationIconButton({
    super.key,
    this.iconColor,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationBadge(
      child: IconButton(
        icon: Icon(
          Icons.notifications_outlined,
          color: iconColor,
          size: iconSize,
        ),
        onPressed: () {
          context.push('/notifications');
        },
        tooltip: 'Notifications',
      ),
    );
  }
}

/// Bottom navigation tab with notification badge
class NotificationTabIcon extends ConsumerWidget {
  final bool isSelected;
  final Color? selectedColor;
  final Color? unselectedColor;

  const NotificationTabIcon({
    super.key,
    this.isSelected = false,
    this.selectedColor,
    this.unselectedColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationBadge(
      showDot: true,
      child: Icon(
        isSelected ? Icons.notifications : Icons.notifications_outlined,
        color: isSelected ? selectedColor : unselectedColor,
      ),
    );
  }
}

/// Floating action button with notification badge
class NotificationFAB extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const NotificationFAB({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NotificationBadge(
      child: FloatingActionButton(
        onPressed: onPressed ?? () => context.push('/notifications'),
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        child: const Icon(Icons.notifications),
      ),
    );
  }
}

/// Real-time notification banner (shows when new notification arrives)
class NotificationBanner extends ConsumerStatefulWidget {
  final Duration displayDuration;
  final Color? backgroundColor;
  final Color? textColor;

  const NotificationBanner({
    super.key,
    this.displayDuration = const Duration(seconds: 4),
    this.backgroundColor,
    this.textColor,
  });

  @override
  ConsumerState<NotificationBanner> createState() => _NotificationBannerState();
}

class _NotificationBannerState extends ConsumerState<NotificationBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showBanner() {
    _controller.forward();
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  void _hideBanner() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authProvider);

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    // Listen to notification stream for real-time updates
    ref.listen(
      notificationStreamProvider(currentUser.uid),
      (previous, next) {
        next.whenData((notifications) {
          if (previous != null) {
            // Check if there are new unread notifications
            previous.whenData((prevNotifications) {
              final newUnreadCount =
                  notifications.where((n) => !n.isRead).length;
              final prevUnreadCount =
                  prevNotifications.where((n) => !n.isRead).length;

              if (newUnreadCount > prevUnreadCount) {
                // New notification arrived
                _showBanner();
              }
            });
          }
        });
      },
    );

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Material(
          elevation: 4,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.backgroundColor ??
                  Theme.of(context).colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: widget.textColor ?? Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You have new notifications',
                      style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _hideBanner();
                      context.push('/notifications');
                    },
                    child: Text(
                      'View',
                      style: TextStyle(
                        color: widget.textColor ?? Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _hideBanner,
                    icon: Icon(
                      Icons.close,
                      color: widget.textColor ?? Colors.white,
                      size: 18,
                    ),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Notification summary card for dashboard/home screen
class NotificationSummaryCard extends ConsumerWidget {
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const NotificationSummaryCard({
    super.key,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authProvider);

    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    final unreadCountAsync =
        ref.watch(unreadNotificationCountProvider(currentUser.uid));

    return unreadCountAsync.when(
      data: (count) {
        if (count == 0) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: margin ?? const EdgeInsets.all(16),
          child: Card(
            child: InkWell(
              onTap: () => context.push('/notifications'),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: padding ?? const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifications',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            count == 1
                                ? 'You have 1 unread notification'
                                : 'You have $count unread notifications',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7),
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
