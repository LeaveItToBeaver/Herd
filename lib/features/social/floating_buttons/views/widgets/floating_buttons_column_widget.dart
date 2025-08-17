import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/overlay_providers.dart';

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
    //final isChatOverlayOpen = ref.watch(chatOverlayOpenProvider);
    final chatTriggeredByBubble = ref.watch(chatTriggeredByBubbleProvider);

    final activeOverlay = ref.watch(activeOverlayTypeProvider);
    final isOverlayOpen = activeOverlay != null;

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
              isOverlayOpen ? Icons.close : Icons.chat_bubble_outline,
              color: isOverlayOpen || isChatEnabled
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white,
            ),
            onPressed: () {
              HapticFeedback.mediumImpact();

              final activeOverlay = ref.read(activeOverlayTypeProvider);

              if (activeOverlay == OverlayType.chat) {
                // For chat overlay
                if (chatTriggeredByBubble != null) {
                  ref.read(chatClosingAnimationProvider.notifier).state =
                      chatTriggeredByBubble;
                } else {
                  ref.read(chatOverlayOpenProvider.notifier).state = false;
                  ref.read(activeOverlayTypeProvider.notifier).state = null;
                }
              } else if (activeOverlay == OverlayType.herd) {
                // For herd overlay
                final herdBubbleId = ref.read(herdTriggeredByBubbleProvider);
                if (herdBubbleId != null) {
                  ref.read(herdClosingAnimationProvider.notifier).state =
                      herdBubbleId;
                } else {
                  ref.read(herdOverlayOpenProvider.notifier).state = false;
                  ref.read(activeOverlayTypeProvider.notifier).state = null;
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
