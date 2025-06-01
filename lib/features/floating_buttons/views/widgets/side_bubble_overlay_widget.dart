import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/view/providers/auth_provider.dart';
import '../../../feed/providers/feed_type_provider.dart';

class SideBubblesOverlay extends ConsumerWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;

  const SideBubblesOverlay({
    super.key,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get current feed type for determining profile route
    final feedType = ref.watch(currentFeedProvider);

    // Generate list of bubbles
    final List<Widget> bubbles = [];

    // Add search button if enabled
    if (showSearchBtn) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: const Icon(
            Icons.search,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: Colors.black,
          onTap: () {
            context.pushNamed('search');
          },
        ),
      );
    }

    if (showNotificationsBtn) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: const Icon(
            Icons.notifications,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: Colors.black,
          onTap: () {
            context.pushNamed('notifications');
          },
        ),
      );
    }

    // Add profile button if enabled
    if (showProfileBtn) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: const Icon(
            Icons.person,
            color: Colors.white,
            size: 24,
          ),
          backgroundColor: Colors.black,
          onTap: () {
            final currentUser = ref.read(authProvider);
            if (currentUser?.uid != null) {
              // Navigate based on current feed type
              if (feedType == FeedType.alt) {
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
      );
    }

    if (showSearchBtn && showProfileBtn ||
        showNotificationsBtn && showProfileBtn ||
        showSearchBtn && showNotificationsBtn) {
      // Add a spacer between the two buttons
      bubbles.add(const SizedBox(height: 16));
    }

    // Add feed toggle button
    bubbles.add(
      _buildBubble(
        context: context,
        child: feedType == FeedType.alt
            ? const Icon(Icons.public, color: Colors.white, size: 24)
            : const Icon(Icons.groups_outlined, color: Colors.white, size: 24),
        backgroundColor: feedType == FeedType.alt
            ? Theme.of(context).colorScheme.primary
            : Colors.black,
        onTap: () {
          // Toggle feed type
          final newFeedType =
              feedType == FeedType.alt ? FeedType.public : FeedType.alt;

          ref.read(currentFeedProvider.notifier).state = newFeedType;

          // Navigate to the appropriate feed
          if (newFeedType == FeedType.alt) {
            context.goNamed('altFeed');
          } else {
            context.goNamed('publicFeed');
          }
        },
      ),
    );

    // Add regular community bubbles
    for (int i = 0; i < 30; i++) {
      bubbles.add(
        _buildBubble(
          context: context,
          child: Text(
            "${i + 1}",
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          backgroundColor: Colors.white,
          onTap: () {
            // Navigate to community or open chat
          },
        ),
      );
    }

    return Container(
      color: Colors.transparent, // Let the app background show through
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 0, bottom: 0),
                reverse: true, // Build from bottom up
                children: bubbles,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to build consistent bubbles with Material and shadow
  Widget _buildBubble({
    required BuildContext context,
    required Widget child,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            // BoxShadow(
            //   color: Colors.black.withOpacity(0.2),
            //   blurRadius: 12,
            //   offset: const Offset(0, 2),
            // ),
          ],
        ),
        child: Material(
            //color: Colors.transparent,
            //borderRadius: BorderRadius.circular(30),
            // clipBehavior: Clip.antiAlias,
            // child: InkWell(
            //   onTap: onTap,
            //   child: Container(
            //     width: 54,
            //     height: 54,
            //     alignment: Alignment.center,
            //     child: child,
            //   ),
            // ),
            ),
      ),
    );
  }
}
