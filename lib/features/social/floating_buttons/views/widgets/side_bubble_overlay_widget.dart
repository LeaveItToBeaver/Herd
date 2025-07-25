import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/floating_buttons/utils/bubble_factory.dart';
import 'package:herdapp/features/social/floating_buttons/utils/controllers/advanced_haptics_controller.dart';
import 'package:herdapp/features/social/floating_buttons/utils/controllers/haptics_controller.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/super_stretchy_painter.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/draggable_bubble_widget.dart';

class SideBubblesOverlay extends ConsumerStatefulWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;
  final bool showHerdBubbles; // New parameter

  const SideBubblesOverlay({
    super.key,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
    this.showHerdBubbles = false, // Default to false (public feed)
  });

  @override
  ConsumerState<SideBubblesOverlay> createState() => _SideBubblesOverlayState();
}

class _SideBubblesOverlayState extends ConsumerState<SideBubblesOverlay>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;

  // Drag state
  String? _draggingBubbleId;
  Offset? _dragStartPosition;
  Offset? _currentDragPosition;
  Offset? _touchOffset;
  final Map<String, GlobalKey> _bubbleKeys = {};

  // Animation for column width
  late AnimationController _widthAnimationController;
  late Animation<double> _widthAnimation;

  // Snap back animation
  AnimationController? _snapBackController;
  Animation<Offset>? _snapBackAnimation;

  // Haptic feedback
  late HapticDragController _hapticController;
  late AdvancedHaptics _haptics;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();

    _widthAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _widthAnimation = Tween<double>(
      begin: 70.0,
      end: 70.0,
    ).animate(CurvedAnimation(
      parent: _widthAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _hapticController = HapticDragController();
    //_haptics = AdvancedHaptics();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _widthAnimationController.dispose();
    _snapBackController?.dispose();
    _hapticController.dispose();
    super.dispose();
  }

  void _startDrag(
      String bubbleId, Offset globalTouchPosition, BoxConstraints constraints) {
    final key = _bubbleKeys[bubbleId];
    if (key?.currentContext == null) return;

    final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Get bubble's screen position
    final bubbleGlobalPos = renderBox.localToGlobal(Offset.zero);

    // Get the container's screen position
    final containerRenderBox = context.findRenderObject() as RenderBox?;
    if (containerRenderBox == null) return;

    final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);

    // Calculate position relative to container
    final relativePosition = bubbleGlobalPos - containerGlobalPos;

    // IMPORTANT: Account for the width animation that will happen
    // The bubble will need to maintain its position relative to the RIGHT edge
    // as the container expands from 70px to full width
    final screenWidth = MediaQuery.of(context).size.width;
    final rightEdgeOffset =
        70.0 - relativePosition.dx; // Distance from right edge
    final adjustedStartPosition = Offset(
      screenWidth -
          rightEdgeOffset, // Position relative to full-width container
      relativePosition.dy,
    );

    setState(() {
      _draggingBubbleId = bubbleId;
      _dragStartPosition = adjustedStartPosition; // Use adjusted position
      _currentDragPosition = adjustedStartPosition; // Use adjusted position
      _touchOffset = globalTouchPosition - bubbleGlobalPos;
    });

    // Update provider
    ref.read(isDraggingProvider.notifier).state = true;

    // Animate width expansion
    _widthAnimation = Tween<double>(
      begin: 70.0,
      end: screenWidth,
    ).animate(CurvedAnimation(
      parent: _widthAnimationController,
      curve: Curves.easeOutCubic,
    ));

    _widthAnimationController.forward();

    HapticFeedback.mediumImpact();
  }

  void _updateDrag(Offset delta) {
    if (_currentDragPosition == null || _dragStartPosition == null) return;

    setState(() {
      _currentDragPosition = _currentDragPosition! + delta;
    });

    // Add haptic feedback based on drag distance
    final currentDistance =
        (_currentDragPosition! - _dragStartPosition!).distance;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDistance = screenWidth * 0.8;
    final tension = math.min(1.0, currentDistance / maxDistance);

    // Use advanced haptics
    _hapticController.onDragUpdate(
      currentDistance: currentDistance,
      maxDistance: maxDistance,
      bubbleSize: 54,
    );
  }

  void _endDrag() {
    if (_dragStartPosition == null || _currentDragPosition == null) return;

    final finalDistance =
        (_currentDragPosition! - _dragStartPosition!).distance;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDistance = screenWidth * 0.8;

    // Trigger end haptics
    _hapticController.onDragEnd(
      finalDistance: finalDistance,
      maxDistance: maxDistance,
    );

    // Create snap back animation - snap back to original bubble position
    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _currentDragPosition!,
      end: _dragStartPosition!, // Adjusted for bubble size
    ).animate(CurvedAnimation(
      parent: _snapBackController!,
      curve: Curves.elasticOut,
    ));

    _snapBackAnimation!.addListener(() {
      setState(() {
        _currentDragPosition = _snapBackAnimation!.value;
      });
    });

    _snapBackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _draggingBubbleId = null;
          _dragStartPosition = null;
          _currentDragPosition = null;
          _touchOffset = null;
        });

        // Update provider
        ref.read(isDraggingProvider.notifier).state = false;

        // Animate width back
        _widthAnimation = Tween<double>(
          begin: _widthAnimation.value,
          end: 70.0,
        ).animate(CurvedAnimation(
          parent: _widthAnimationController,
          curve: Curves.easeOutCubic,
        ));

        _widthAnimationController.forward(from: 0);
      }
    });

    _snapBackController!.forward();
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final feedType = ref.watch(currentFeedProvider);
    final customization = ref.watch(uiCustomizationProvider).value;
    final appTheme = customization?.appTheme;
    final backgroundColor = appTheme?.getBackgroundColor() ??
        Theme.of(context).scaffoldBackgroundColor;

    final bubbleConfigs =
        _createBubbleConfigs(context, ref, feedType, appTheme);

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                fit: StackFit.expand,
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    bottom: 0,
                    width: 70,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            reverse: true,
                            controller: _scrollController,
                            padding: const EdgeInsets.only(
                                top: 8, left: 8, right: 8),
                            itemCount: bubbleConfigs.length,
                            itemBuilder: (context, index) {
                              final config = bubbleConfigs[index];
                              final isBeingDragged =
                                  _draggingBubbleId == config.id;

                              final bubble = DraggableBubble(
                                key: ValueKey(config.id),
                                config: config,
                                appTheme: appTheme,
                                globalKey: _bubbleKeys.putIfAbsent(
                                    config.id, () => GlobalKey()),
                                onDragStart: (globalPos) => _startDrag(
                                    config.id,
                                    globalPos,
                                    constraints // Pass layout constraints
                                    ),
                                onDragUpdate: _updateDrag,
                                onDragEnd: _endDrag,
                                isBeingDragged: isBeingDragged,
                              );

                              if (index == 0) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20.0),
                                  child: bubble,
                                );
                              }
                              return bubble;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Drag overlay with trail
                  if (_draggingBubbleId != null &&
                      _dragStartPosition != null &&
                      _currentDragPosition != null)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: CustomPaint(
                          painter: SuperStretchyTrailPainter(
                            originalPosition: Offset(
                              _dragStartPosition!.dx + 27,
                              _dragStartPosition!.dy + 27,
                            ),
                            currentPosition: Offset(
                              _currentDragPosition!.dx + 27,
                              _currentDragPosition!.dy + 25,
                            ),
                            trailColor: _getDraggedBubbleColor(bubbleConfigs),
                            bubbleSize: 54,
                            screenSize: constraints
                                .biggest, // Use actual container size
                          ),
                        ),
                      ),
                    ),

                  if (_draggingBubbleId != null && _currentDragPosition != null)
                    Positioned(
                      left: _currentDragPosition!.dx,
                      top: _currentDragPosition!.dy,
                      child: IgnorePointer(
                        child: _buildDraggedBubble(bubbleConfigs),
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Color _getDraggedBubbleColor(List<BubbleConfigState> configs) {
    final config = configs.firstWhere(
      (c) => c.id == _draggingBubbleId,
      orElse: () => configs.first,
    );
    return config.backgroundColor ?? Colors.blue;
  }

  Widget _buildDraggedBubble(List<BubbleConfigState> configs) {
    final config = configs.firstWhere(
      (c) => c.id == _draggingBubbleId,
      orElse: () => configs.first,
    );

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: config.backgroundColor ?? Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(
          color: (config.foregroundColor ?? Colors.white).withValues(
              alpha: 0.2), // <-- Use foregroundColor like the original bubbles
          width: 1.5, // <-- Match the original bubble border width
        ),
        boxShadow: [
          BoxShadow(
            color:
                (config.backgroundColor ?? Colors.blue).withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          // Add a glowing border effect
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        config.icon ?? Icons.circle,
        color: config.foregroundColor ?? Colors.white,
        size: 22,
      ),
    );
  }

  List<BubbleConfigState> _createBubbleConfigs(BuildContext context,
      WidgetRef ref, FeedType feedType, dynamic appTheme) {
    final List<BubbleConfigState> configs = [];

    // System bubbles (order 0-99) - NOT DRAGGABLE
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

    // Feed toggle bubble (order 100-199) - NOT DRAGGABLE
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
      padding: const EdgeInsets.fromLTRB(0, 16, 4, 4), // Extra top padding
      order: 100,
      onToggle: () {
        HapticFeedback.mediumImpact();
        final newFeedType =
            feedType == FeedType.alt ? FeedType.public : FeedType.alt;
        ref.read(currentFeedProvider.notifier).state = newFeedType;

        if (newFeedType == FeedType.alt) {
          context.goNamed('altFeed');
        } else {
          context.goNamed('publicFeed');
        }
      },
    ));

    // Community/Chat bubbles (order 500+) - DRAGGABLE
    if (widget.showHerdBubbles) {
      // For alt feed: Show herds first
      // TODO: Replace with actual herd data
      for (int i = 0; i < 5; i++) {
        configs.add(BubbleFactory.herdBubble(
          herdId: 'herd_$i',
          name: 'Herd ${i + 1}',
          backgroundColor: appTheme?.getSurfaceColor().withValues(alpha: 0.9) ??
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
          foregroundColor: appTheme?.getTextColor() ??
              Theme.of(context).colorScheme.onSurface,
          padding: i == 0
              ? const EdgeInsets.fromLTRB(
                  0, 16, 4, 4) // Extra spacing for first
              : const EdgeInsets.fromLTRB(0, 4, 4, 4),
          order: 500 + i,
          customOnTap: () {
            HapticFeedback.lightImpact();
            // TODO: Navigate to herd
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Herd ${i + 1} tapped')),
            );
          },
        ).copyWith(
          isDraggable: true, // Make herd bubbles draggable
          icon: Icons.groups, // Use groups icon for herds
          contentType: BubbleContentType.icon, // Show icon instead of text
        ));
      }
    }

    // Chat bubbles for both feeds
    final chatStartOrder = widget.showHerdBubbles ? 600 : 500;
    for (int i = 0; i < 10; i++) {
      // ALL chat bubbles are draggable
      configs.add(BubbleFactory.chatBubble(
        chatId: 'chat_$i',
        name: 'Chat ${i + 1}',
        backgroundColor: appTheme?.getSurfaceColor() ??
            Theme.of(context).colorScheme.surface,
        foregroundColor:
            appTheme?.getTextColor() ?? Theme.of(context).colorScheme.onSurface,
        padding: i == 0 && !widget.showHerdBubbles
            ? const EdgeInsets.fromLTRB(0, 16, 4, 4) // Extra spacing for first
            : const EdgeInsets.fromLTRB(0, 4, 4, 4),
        order: chatStartOrder + i,
        customOnTap: () {
          HapticFeedback.lightImpact();
          // TODO: Navigate to chat
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Chat ${i + 1} tapped')),
          );
        },
      ).copyWith(
        isDraggable: true, // Make chat bubbles draggable
        icon: Icons.chat_bubble_outline, // Add chat icon
        contentType: BubbleContentType.icon, // Show icon instead of text
      ));
    }

    return configs;
  }
}
