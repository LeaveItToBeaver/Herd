import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/floating_buttons/utils/bubble_factory.dart';
import 'package:herdapp/features/social/floating_buttons/utils/global_bubble_wrapper.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/global_drag_provider.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';

class SideBubblesOverlay extends ConsumerStatefulWidget {
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
  ConsumerState<SideBubblesOverlay> createState() => _SideBubblesOverlayState();
}

class _SideBubblesOverlayState extends ConsumerState<SideBubblesOverlay> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    // Update positions when scrolling
    _scrollController.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(globalDraggableProvider.notifier).updateAllPositions();
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final feedType = ref.watch(currentFeedProvider);
    final customization = ref.watch(uiCustomizationProvider).value;

    // Get custom theme colors or fall back to default theme
    final appTheme = customization?.appTheme;
    final backgroundColor = appTheme?.getBackgroundColor() ??
        Theme.of(context).scaffoldBackgroundColor;

    // Create bubble configurations using the factory
    final bubbleConfigs =
        _createBubbleConfigs(context, ref, feedType, appTheme);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(globalDraggableProvider.notifier).updateAllPositions();
    });

    return Container(
      width: 70,
      color: backgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 8),
                    reverse: false,
                    itemCount: bubbleConfigs.length,
                    itemBuilder: (context, index) {
                      final config = bubbleConfigs[index];

                      return GlobalBubbleWrapper(
                        config: config,
                        appTheme: appTheme,
                        key: ValueKey(config.id),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<BubbleConfigState> _createBubbleConfigs(BuildContext context,
      WidgetRef ref, FeedType feedType, dynamic appTheme) {
    final List<BubbleConfigState> configs = [];

    // System bubbles (order 0-99)
    if (widget.showSearchBtn) {
      configs.add(BubbleFactory.searchBubble(
        backgroundColor: appTheme?.getSurfaceColor() ??
            Theme.of(context).colorScheme.surface,
        foregroundColor:
            appTheme?.getTextColor() ?? Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
        order: 10,
      ));
    }

    if (widget.showNotificationsBtn) {
      final notifications =
          ref.watch(notificationStreamProvider(ref.read(authProvider)!.uid));
      final hasNotifications =
          notifications.hasValue && notifications.value!.isNotEmpty;

      configs.add(BubbleFactory.notificationsBubble(
        hasNotifications: hasNotifications,
        backgroundColor: hasNotifications
            ? (appTheme?.getErrorColor().withValues(alpha: 0.2) ??
                Theme.of(context).colorScheme.errorContainer)
            : (appTheme?.getSurfaceColor() ??
                Theme.of(context).colorScheme.surface),
        foregroundColor: hasNotifications
            ? (appTheme?.getErrorColor() ?? Theme.of(context).colorScheme.error)
            : (appTheme?.getTextColor() ??
                Theme.of(context).colorScheme.onSurface),
        errorColor:
            appTheme?.getErrorColor() ?? Theme.of(context).colorScheme.error,
        padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
        order: 20,
      ));
    }

    if (widget.showProfileBtn) {
      final currentUser = ref.read(authProvider);
      configs.add(BubbleFactory.profileBubble(
        userId: currentUser?.uid ?? '',
        isAlt: feedType == FeedType.alt,
        backgroundColor: feedType == FeedType.alt
            ? (appTheme?.getSecondaryColor().withValues(alpha: 0.2) ??
                Theme.of(context).colorScheme.secondaryContainer)
            : (appTheme?.getPrimaryColor().withValues(alpha: 0.2) ??
                Theme.of(context).colorScheme.primaryContainer),
        foregroundColor: feedType == FeedType.alt
            ? (appTheme?.getSecondaryColor() ??
                Theme.of(context).colorScheme.secondary)
            : (appTheme?.getPrimaryColor() ??
                Theme.of(context).colorScheme.primary),
        padding: const EdgeInsets.fromLTRB(0, 4, 4, 4),
        order: 30,
        customOnTap: () {
          HapticFeedback.lightImpact();
          if (currentUser?.uid != null) {
            if (feedType == FeedType.alt) {
              context.pushNamed('altProfile',
                  pathParameters: {'id': currentUser!.uid});
            } else {
              context.pushNamed('publicProfile',
                  pathParameters: {'id': currentUser!.uid});
            }
          } else {
            context.go("/login");
          }
        },
      ));
    }

    // Feed toggle bubble (order 100-199)
    configs.add(BubbleFactory.feedToggleBubble(
      isAltFeed: feedType == FeedType.alt,
      backgroundColor: feedType == FeedType.alt
          ? (appTheme?.getSecondaryColor().withValues(alpha: 0.3) ??
              Theme.of(context).colorScheme.secondaryContainer)
          : (appTheme?.getPrimaryColor().withValues(alpha: 0.3) ??
              Theme.of(context).colorScheme.primaryContainer),
      foregroundColor: feedType == FeedType.alt
          ? (appTheme?.getSecondaryColor() ??
              Theme.of(context).colorScheme.secondary)
          : (appTheme?.getPrimaryColor() ??
              Theme.of(context).colorScheme.primary),
      padding: const EdgeInsets.fromLTRB(
          0, 16, 4, 4), // Extra top padding for spacing
      order: 100,
      onToggle: () {
        HapticFeedback.mediumImpact();
        final newFeedType =
            feedType == FeedType.alt ? FeedType.public : FeedType.alt;
        ref.read(currentFeedProvider.notifier).state = newFeedType;

        // Navigate to appropriate feed
        if (newFeedType == FeedType.alt) {
          context.goNamed('altFeed');
        } else {
          context.goNamed('publicFeed');
        }
      },
    ));

    // Community/Chat bubbles (order 500+) - Every other bubble is draggable
    for (int i = 0; i < 15; i++) {
      final isDraggable = i % 2 == 0; // Every other bubble is draggable

      configs.add(BubbleConfigState(
        id: 'community_$i',
        icon: Icons.chat_bubble_outline,
        text: "${i + 1}",
        backgroundColor: isDraggable
            ? (appTheme?.getPrimaryColor().withValues(alpha: 0.8) ??
                Colors.blue.withValues(alpha: 0.8))
            : (appTheme?.getSurfaceColor().withValues(alpha: 0.8) ??
                Theme.of(context).colorScheme.surface),
        foregroundColor: isDraggable
            ? Colors.white
            : (appTheme?.getTextColor() ??
                Theme.of(context).colorScheme.onSurface),
        padding: i == 0
            ? const EdgeInsets.fromLTRB(
                0, 16, 4, 4) // Extra spacing for first community bubble
            : const EdgeInsets.fromLTRB(0, 4, 4, 4),
        order: 500 + i,
        isDraggable: isDraggable,
        onTap: () {
          HapticFeedback.lightImpact();
          // TODO: Implement community/chat navigation
        },
      ));
    }

    return configs;
  }
}
