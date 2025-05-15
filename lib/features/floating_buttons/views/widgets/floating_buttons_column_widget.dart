import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/features/floating_buttons/views/providers/navigation_service_provider.dart';
import 'package:herdapp/features/notifications/view/providers/notification_provider.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../feed/providers/feed_type_provider.dart';

class FloatingButtonsColumn extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;

  const FloatingButtonsColumn({
    super.key,
    required this.showProfileBtn,
    required this.showSearchBtn,
    required this.showNotificationsBtn,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current feed type for determining profile route
    final currentFeed = ref.watch(currentFeedProvider);
    final notifications =
        ref.watch(notificationStreamProvider(ref.read(authProvider)!.uid));

    final bool bothButtonsVisible = showProfileBtn && showSearchBtn;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Profile button
        if (showProfileBtn)
          Padding(
            padding: EdgeInsets.only(bottom: bothButtonsVisible ? 8.0 : 0.0),
            child: FloatingActionButton(
              heroTag: "floatingProfileBtn",
              backgroundColor: Colors.black,
              mini: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Icon(Icons.person,
                  color: currentFeed == FeedType.alt
                      ? Colors.purpleAccent
                      : Colors.white),
              onPressed: () {
                final navService = ref.read(navigationServiceProvider);
                if (!navService.canNavigate) return;

                HapticFeedback.mediumImpact();
                final currentUser = ref.read(authProvider);
                if (currentUser?.uid != null) {
                  // Navigate to the appropriate profile based on current feed
                  if (currentFeed == FeedType.alt) {
                    context.pushNamed(
                      'altProfile',
                      pathParameters: {'id': currentUser!.uid},
                    );
                  } else {
                    context.pushNamed(
                      'publicProfile',
                      pathParameters: {'id': currentUser!.uid},
                    );
                  }
                } else {
                  context.go("/login");
                }
              },
            ),
          ),

        // Notifications button
        if (showNotificationsBtn)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: FloatingActionButton(
              heroTag: "floatingNotificationsBtn",
              backgroundColor: Colors.black,
              mini: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: notifications.hasValue
                  ? Icon(Icons.notifications, color: Colors.purpleAccent)
                  : Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.pushNamed('notifications');
              },
            ),
          ),

        // Search button
        if (showSearchBtn)
          FloatingActionButton(
            heroTag: "floatingSearchBtn",
            backgroundColor: Colors.black,
            mini: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              HapticFeedback.mediumImpact();
              context.pushNamed('search');
            },
          ),
      ],
    );
  }
}
