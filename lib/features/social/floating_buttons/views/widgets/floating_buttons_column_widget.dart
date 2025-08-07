import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';

class FloatingButtonsColumn extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;
  final bool showChatToggle;

  const FloatingButtonsColumn({
    super.key,
    required this.showProfileBtn,
    required this.showSearchBtn,
    required this.showNotificationsBtn,
    this.showChatToggle = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current feed type for determining profile route
    final currentFeed = ref.watch(currentFeedProvider);
    final notifications =
        ref.watch(notificationStreamProvider(ref.read(authProvider)!.uid));
    final isChatEnabled = ref.watch(chatBubblesEnabledProvider);
    final isChatOverlayOpen = ref.watch(chatOverlayOpenProvider);
    final chatTriggeredByBubble = ref.watch(chatTriggeredByBubbleProvider);

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
              elevation: 0,
              mini: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Icon(Icons.person,
                  color: currentFeed == FeedType.alt
                      ? Theme.of(context).colorScheme.primary
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
              elevation: 0,
              mini: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: notifications.hasValue
                  ? Icon(Icons.notifications,
                      color: Theme.of(context).colorScheme.primary)
                  : Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                context.pushNamed('notifications');
              },
            ),
          ),

        // Search button
        if (showSearchBtn)
          Padding(
            padding: EdgeInsets.only(bottom: showChatToggle ? 8.0 : 0.0),
            child: FloatingActionButton(
              heroTag: "floatingSearchBtn",
              backgroundColor: Colors.black,
              elevation: 0,
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
          ),

        // Chat Toggle button or Chat Close button
        if (showChatToggle)
          FloatingActionButton(
            heroTag: "floatingChatToggleBtn",
            backgroundColor: Colors.black,
            elevation: 0,
            mini: false,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
            child: Icon(
              isChatOverlayOpen
                  ? Icons.close // Close icon when chat overlay is open
                  : (isChatEnabled
                      ? Icons.chat_bubble
                      : Icons
                          .chat_bubble_outline), // Toggle icon when overlay is closed
              color: isChatOverlayOpen || isChatEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();
              if (isChatOverlayOpen) {
                // Trigger proper close animation using the same mechanism as drag-to-close
                if (chatTriggeredByBubble != null) {
                  ref.read(chatClosingAnimationProvider.notifier).state =
                      chatTriggeredByBubble;
                } else {
                  // Fallback: close directly if no bubble ID
                  ref.read(chatOverlayOpenProvider.notifier).state = false;
                }
              } else {
                // Toggle chat bubbles enabled/disabled
                ref.read(chatBubblesEnabledProvider.notifier).state =
                    !isChatEnabled;
              }
            },
          ),
      ],
    );
  }
}
