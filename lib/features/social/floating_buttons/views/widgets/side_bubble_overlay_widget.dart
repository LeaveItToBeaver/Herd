import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/core/barrels/widgets.dart';
import 'package:herdapp/features/community/herds/data/models/herd_model.dart';
import 'package:herdapp/features/community/herds/view/providers/herd_providers.dart';
import 'package:herdapp/features/social/chat_messaging/view/providers/active_chat/active_chat_notifier.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_bubble_toggle_provider.dart';
import 'package:herdapp/features/social/floating_buttons/utils/bubble_factory.dart';
import 'package:herdapp/features/social/floating_buttons/utils/bubble_explosion_painter.dart';
import 'package:herdapp/features/social/floating_buttons/utils/controllers/advanced_haptics_controller.dart';
import 'package:herdapp/features/social/floating_buttons/utils/controllers/haptics_controller.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/super_stretchy_painter.dart';

import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/drag_state.dart';

class SideBubblesOverlay extends ConsumerStatefulWidget {
  final bool showProfileBtn;
  final bool showSearchBtn;
  final bool showNotificationsBtn;
  final bool showHerdBubbles;
  final bool showChatToggle;

  const SideBubblesOverlay({
    super.key,
    this.showProfileBtn = true,
    this.showSearchBtn = true,
    this.showNotificationsBtn = true,
    this.showHerdBubbles = false, // Default to false (public feed)
    this.showChatToggle = true, // Default to true
  });

  @override
  ConsumerState<SideBubblesOverlay> createState() => _SideBubblesOverlayState();
}

class _SideBubblesOverlayState extends ConsumerState<SideBubblesOverlay>
    with TickerProviderStateMixin {
  /// Calculate height of FloatingButtonsColumn rendered by GlobalOverlayManager
  /// Mirrors the exact logic from floating_buttons_column_widget.dart
  static double calculateFloatingButtonsHeight({
    required bool showProfileBtn,
    required bool showSearchBtn,
    required bool showNotificationsBtn,
    required bool showChatToggle,
  }) {
    const double fabSize =
        56.0; // Standard FloatingActionButton size (mini: false)
    const double buttonSpacing = 8.0; // Padding between buttons

    double totalHeight = 0;
    bool hasPreviousButton = false;

    // Profile button - mirrors FloatingButtonsColumn logic
    if (showProfileBtn) {
      totalHeight += fabSize;
      final bothButtonsVisible = showProfileBtn && showSearchBtn;
      if (bothButtonsVisible) {
        totalHeight += buttonSpacing; // padding: EdgeInsets.only(bottom: 8.0)
      }
      hasPreviousButton = true;
    }

    // Notifications button
    if (showNotificationsBtn) {
      totalHeight += fabSize;
      totalHeight += buttonSpacing; // padding: EdgeInsets.only(bottom: 8.0)
      hasPreviousButton = true;
    }

    // Search button
    if (showSearchBtn) {
      totalHeight += fabSize;
      if (showChatToggle) {
        totalHeight += buttonSpacing; // padding: EdgeInsets.only(bottom: 8.0)
      }
      hasPreviousButton = true;
    }

    // Chat toggle button (no bottom padding)
    if (showChatToggle) {
      totalHeight += fabSize;
    }

    return totalHeight;
  }

  late ScrollController _scrollController;

  DragState? _dragState;
  final Map<String, GlobalKey> _bubbleKeys = {};

  // Store the original drag state when chat opens to prevent loss during rebuilds
  DragState? _preservedDragState;

  double _overlayWidth = 70.0;

  AnimationController? _snapBackController;
  Animation<Offset>? _snapBackAnimation;

  AnimationController? _chatMorphController;
  Animation<double>? _chatMorphAnimation;
  Animation<double>? _chatScaleAnimation;

  // Chat visibility animation controller
  AnimationController? _chatVisibilityController;
  Animation<double>? _chatVisibilityAnimation;

  // Haptic feedback
  late HapticDragController _hapticController;
  late AdvancedHaptics _haptics;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _hapticController = HapticDragController();
    //_haptics = AdvancedHaptics();

    _chatVisibilityController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _chatVisibilityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatVisibilityController!,
      curve: Curves.easeInOut,
    ));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateAnimationCallbacks();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isChatEnabled = ref.watch(chatBubblesEnabledProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        if (isChatEnabled) {
          _chatVisibilityController?.forward();
        } else {
          _chatVisibilityController?.reverse();
        }

        // Update animation callbacks whenever dependencies change
        _updateAnimationCallbacks();
      }
    });
  }

  void _updateAnimationCallbacks() {
    final newState = <String, VoidCallback>{};

    // Register close animation callbacks for chat bubbles
    final activeChats = ref.read(activeChatBubblesProvider);
    for (final chat in activeChats) {
      newState[chat.id] =
          () => _startCloseAnimation(chat.id, false); // false = chat
      newState['${chat.id}_snapback'] =
          () => _snapBackAfterClose(); // Snap back callback
    }

    // Register close animation callbacks for herd bubbles
    final currentUser = ref.read(authProvider);
    if (currentUser != null) {
      // FIX: Use ref.read instead of ref.watch in update function
      final userHerdsAsync =
          ref.read(profileUserHerdsProvider(currentUser.uid));

      // Handle AsyncValue states properly using pattern matching
      switch (userHerdsAsync) {
        case AsyncData(:final value):
          if (value.isNotEmpty) {
            debugPrint('Registering callbacks for ${value.length} herds');
            for (final herd in value) {
              final herdBubbleId = 'herd_${herd.id}';
              newState[herdBubbleId] =
                  () => _startCloseAnimation(herdBubbleId, true); // true = herd
              newState['${herdBubbleId}_snapback'] =
                  () => _snapBackAfterCloseHerd(); // Snap back callback
              debugPrint('Registered callback for herd bubble: $herdBubbleId');
            }
          }
        case AsyncLoading():
          debugPrint('Herds still loading');
        case AsyncError(:final error):
          debugPrint('Error loading herds: $error');
      }
    }

    debugPrint(
        'Total callbacks registered: ${newState.length}, keys: ${newState.keys.toList()}');
    ref.read(bubbleAnimationCallbackProvider.notifier).state = newState;
  }

  /// Unified close animation method for both chat and herd bubbles
  void _startCloseAnimation(String bubbleId, bool isHerd) {
    debugPrint("_startCloseAnimation called for $bubbleId, isHerd: $isHerd");

    // Check if animation is already in progress to prevent duplicate calls
    final currentReveal = ref.read(explosionRevealProvider);
    if (currentReveal != null &&
        currentReveal.isActive &&
        currentReveal.isClosing) {
      debugPrint(
          "Close animation already in progress, ignoring duplicate call");
      return;
    }

    // Restore preserved drag state if we don't have current drag state
    if (_dragState == null && _preservedDragState != null) {
      setState(() {
        _dragState = _preservedDragState;
        _preservedDragState = null;
      });
    }

    if (_dragState == null) {
      debugPrint("No drag state, closing overlay directly");
      // No animation, just close directly
      if (isHerd) {
        ref.read(herdOverlayOpenProvider.notifier).state = false;
        ref.read(herdTriggeredByBubbleProvider.notifier).state = null;
      } else {
        ref.read(chatOverlayOpenProvider.notifier).state = false;
        ref.read(chatTriggeredByBubbleProvider.notifier).state = null;
      }
      ref.read(activeOverlayTypeProvider.notifier).state = null;
      return;
    }

    // Calculate the bubble center for the animation
    final containerRenderBox = context.findRenderObject() as RenderBox?;
    Offset bubbleGlobalCenter;

    // Try to reuse the existing explosion center for consistency
    final existingReveal = ref.read(explosionRevealProvider);
    if (existingReveal != null &&
        existingReveal.isActive &&
        !existingReveal.isClosing) {
      // Reuse the opening animation's center for perfect symmetry
      bubbleGlobalCenter = existingReveal.center;
      debugPrint(
          "Reusing opening animation center for CLOSING: $bubbleGlobalCenter, bubbleId: $bubbleId");
    } else if (containerRenderBox != null) {
      // Fallback to calculating center from current position
      final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);
      bubbleGlobalCenter = containerGlobalPos +
          _dragState!.currentPosition +
          Offset(_dragState!.bubbleConfig.effectiveSize / 2,
              _dragState!.bubbleConfig.effectiveSize / 2);
      debugPrint(
          "Calculated new center for CLOSING animation: $bubbleGlobalCenter, bubbleId: $bubbleId");
    } else {
      debugPrint("Could not determine bubble center for closing animation");
      return;
    }

    debugPrint(
        "Setting explosion reveal for CLOSING animation at center: $bubbleGlobalCenter, bubbleId: $bubbleId");

    // Set the closing animation state BEFORE any overlay state changes
    // This ensures AnimatedRevealOverlay will handle the animation properly
    ref.read(explosionRevealProvider.notifier).state = (
      isActive: true,
      center: bubbleGlobalCenter,
      progress: 1.0, // Start at fully revealed for closing
      bubbleId: bubbleId,
      isClosing: true, // Mark as closing animation
    );

    // DO NOT close overlay states here - let AnimatedRevealOverlay handle it
    // via onAnimationComplete callback which will call the snapback methods
  }

  void _snapBackAfterCloseHerd() {
    debugPrint("_snapBackAfterCloseHerd called - closing overlay states");

    // Close overlay states
    ref.read(herdOverlayOpenProvider.notifier).state = false;
    ref.read(herdTriggeredByBubbleProvider.notifier).state = null;
    ref.read(activeOverlayTypeProvider.notifier).state = null;

    // Clear explosion reveal state
    ref.read(explosionRevealProvider.notifier).state = null;

    // Snap bubble back to original position
    if (_dragState != null) {
      _snapBackToOriginalPosition();
    }

    _executePendingNavigationCallback();
  }

  void _executePendingNavigationCallback() {
    final callbacks = ref.read(bubbleAnimationCallbackProvider);
    final navigationCallback = callbacks['_navigation_pending'];
    if (navigationCallback != null) {
      debugPrint("== EXECUTING NAVIGATION CALLBACK ==");
      navigationCallback();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _snapBackController?.dispose();
    _chatMorphController?.dispose();
    _chatVisibilityController?.dispose();
    _hapticController.dispose();
    super.dispose();
  }

  void _startDrag(
      String bubbleId, Offset globalTouchPosition, BoxConstraints constraints) {
    final key = _bubbleKeys[bubbleId];
    if (key?.currentContext == null) return;

    final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final currentUser = ref.read(authProvider);
    final userHerdsAsync = currentUser != null
        ? ref.read(profileUserHerdsProvider(currentUser.uid))
        : null;

    final configs = _createBubbleConfigs(
        context,
        ref,
        ref.read(currentFeedProvider),
        null,
        ref.read(activeChatBubblesProvider),
        userHerdsAsync);
    final allBubbleConfigs = [...configs.stationary, ...configs.draggable];
    final bubbleConfig = allBubbleConfigs.firstWhere((c) => c.id == bubbleId);

    final paddedContainerGlobalPos = renderBox.localToGlobal(Offset.zero);
    final paddedContainerSize = renderBox.size;

    final containerRenderBox = context.findRenderObject() as RenderBox?;
    if (containerRenderBox == null) return;

    final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);
    final paddedContainerRelativePos =
        paddedContainerGlobalPos - containerGlobalPos;

    final padding = bubbleConfig.padding;
    final actualBubbleSize = Size(
      bubbleConfig.effectiveSize,
      bubbleConfig.effectiveSize,
    );

    final bubbleCenterInPaddedContainer = Offset(
      (padding.left + padding.right) +
          (actualBubbleSize.width / 2), // Assumes padding is equal
      padding.top + (actualBubbleSize.height / 2),
    );

    final bubbleCenterRelativePos =
        paddedContainerRelativePos + bubbleCenterInPaddedContainer;
    final screenWidth = MediaQuery.of(context).size.width;
    final rightEdgeOffset = 70.0 - bubbleCenterRelativePos.dx;

    final adjustedStartPosition = Offset(
      screenWidth - rightEdgeOffset - (actualBubbleSize.width / 2),
      bubbleCenterRelativePos.dy - (actualBubbleSize.height / 2),
    );

    final bubbleCenterGlobalPos =
        paddedContainerGlobalPos + bubbleCenterInPaddedContainer;
    final touchOffset = globalTouchPosition - bubbleCenterGlobalPos;

    setState(() {
      _dragState = DragState(
        bubbleId: bubbleId,
        bubbleConfig: bubbleConfig,
        startPosition: adjustedStartPosition,
        currentPosition: adjustedStartPosition,
        touchOffset: touchOffset,
        bubbleSize: actualBubbleSize,
        bubbleCenterOffset: Offset(
          actualBubbleSize.width / 2,
          actualBubbleSize.height / 2,
        ),
        bubbleKey: key,
        screenSize: MediaQuery.of(context).size,
        hasTriggeredChatThreshold: false,
      );

      _overlayWidth = screenWidth;
    });

    ref.read(isDraggingProvider.notifier).state = true;
    HapticFeedback.mediumImpact();
  }

  void _updateDrag(Offset delta) {
    if (_dragState == null) return;

    final newPosition = _dragState!.currentPosition + delta;

    setState(() {
      _dragState = _dragState!.copyWith(
        currentPosition: newPosition,
      );
    });

    if (_dragState!.shouldTriggerChatThreshold) {
      setState(() {
        _dragState = _dragState!.copyWith(
          hasTriggeredChatThreshold: true,
        );
      });

      HapticFeedback.heavyImpact();

      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.mediumImpact();
      });
    }

    final currentDistance =
        (_dragState!.currentPosition - _dragState!.startPosition).distance;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDistance = screenWidth * 0.8;
    final tension = math.min(1.0, currentDistance / maxDistance);

    // Use advanced haptics
    _hapticController.onDragUpdate(
      currentDistance: currentDistance,
      maxDistance: maxDistance,
      bubbleSize: _dragState!.bubbleSizeValue,
    );
  }

  void _endDrag() {
    if (_dragState == null) return;

    final finalDistance =
        (_dragState!.currentPosition - _dragState!.startPosition).distance;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxDistance = screenWidth * 0.8;

    // Trigger end haptics
    _hapticController.onDragEnd(
      finalDistance: finalDistance,
      maxDistance: maxDistance,
    );

    if (_dragState!.hasTriggeredChatThreshold && _dragState!.isInChatZone) {
      final bubbleConfig = _dragState!.bubbleConfig;
      final overlayType = bubbleConfig.id.startsWith('herd_')
          ? OverlayType.herd
          : OverlayType.chat;

      // Animate bubble to chat position and open chat overlay
      _animateToOverlay(overlayType);
      return;
    }

    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration:
          const Duration(milliseconds: 800), // Faster for regular snap back
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _dragState!.currentPosition,
      end: _dragState!.startPosition,
    ).animate(CurvedAnimation(
      parent: _snapBackController!,
      curve: Curves.elasticOut,
    ));

    _snapBackAnimation!.addListener(() {
      if (_dragState != null) {
        setState(() {
          _dragState = _dragState!.copyWith(
            currentPosition: _snapBackAnimation!.value,
          );
        });
      }
    });

    _snapBackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragState = null;
          _overlayWidth = 70.0;
        });

        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    _snapBackController!.forward();
    HapticFeedback.lightImpact();
  }

  void _animateToOverlay(OverlayType overlayType) {
    if (_dragState == null) return;

    // Preserve the drag state to prevent loss during rebuilds
    _preservedDragState = _dragState;

    if (overlayType == OverlayType.chat) {
      ref.read(chatOverlayOpenProvider.notifier).state = true;
      ref.read(chatTriggeredByBubbleProvider.notifier).state =
          _dragState!.bubbleId;
    } else if (overlayType == OverlayType.herd) {
      ref.read(herdOverlayOpenProvider.notifier).state = true;
      ref.read(herdTriggeredByBubbleProvider.notifier).state =
          _dragState!.bubbleId;
    }

    ref.read(activeOverlayTypeProvider.notifier).state = overlayType;

    setState(() {
      _dragState = _dragState!.copyWith(
        isAnimatingToChat: true,
        chatTargetPosition: Offset(50.0, _dragState!.currentPosition.dy),
      );
    });

    final containerRenderBox = context.findRenderObject() as RenderBox?;
    if (containerRenderBox != null) {
      final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);
      final bubbleGlobalCenter = containerGlobalPos +
          _dragState!.currentPosition +
          Offset(_dragState!.bubbleConfig.effectiveSize / 2,
              _dragState!.bubbleConfig.effectiveSize / 2);

      debugPrint(
          "Setting explosion reveal for chat at center: $bubbleGlobalCenter, bubbleId: ${_dragState!.bubbleId}");
      ref.read(explosionRevealProvider.notifier).state = (
        isActive: true,
        center: bubbleGlobalCenter,
        progress: 0.0,
        bubbleId: _dragState!.bubbleId,
        isClosing: false, // Opening animation
      );
    }

    _chatMorphController?.dispose();
    _chatMorphController = AnimationController(
      duration: const Duration(milliseconds: 800), // Increased from 500ms
      vsync: this,
    );

    _chatMorphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatMorphController!,
      curve: Curves.easeOutQuart,
    ));

    _chatScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _chatMorphController!,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
    ));

    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 600), // Increased from 400ms
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _dragState!.currentPosition,
      end: _dragState!.chatTargetPosition!,
    ).animate(CurvedAnimation(
      parent: _snapBackController!,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutQuart),
    ));

    _chatMorphAnimation!.addListener(() {
      if (_dragState != null) {
        setState(() {
          // Force high frequency updates for smooth animation
        });

        // DO NOT update explosion reveal progress here - let AnimatedRevealOverlay handle its own animation
        // The explosion reveal state was set once in _animateToOverlay() and should remain static
        // This prevents constant rebuilding of the global overlay manager
      }
    });

    _chatMorphAnimation!.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        Future.delayed(const Duration(milliseconds: 90), () {
          HapticFeedback.mediumImpact();
        });

        Future.delayed(const Duration(milliseconds: 240), () {
          HapticFeedback.heavyImpact();
        });

        Future.delayed(const Duration(milliseconds: 480), () {
          HapticFeedback.lightImpact();
        });
      }
    });

    // Listen to position animation with high frequency updates
    _snapBackAnimation!.addListener(() {
      if (_dragState != null) {
        setState(() {
          _dragState = _dragState!.copyWith(
            currentPosition: _snapBackAnimation!.value,
          );
        });
      }
    });

    _chatMorphController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragState = _dragState!.copyWith(
            isChatMorphComplete: true,
          );
        });

        // DO NOT clear explosion reveal state here - keep it active for potential closing animation
        // The closing animation will handle clearing it when appropriate
        debugPrint(
            "Opening animation completed, keeping explosion reveal active for closing");
      }
    });

    _snapBackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    _chatMorphController!.forward();
    _snapBackController!.forward();
  }

  void _snapBackToOriginalPosition() {
    if (_dragState == null) return;

    setState(() {
      _dragState = _dragState!.copyWith(
        isChatMorphComplete: false,
        isAnimatingToChat: false,
        hasTriggeredChatThreshold: false,
      );
    });

    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 600), // Slightly slower snap back
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _dragState!.currentPosition,
      end: _dragState!.startPosition,
    ).animate(CurvedAnimation(
      parent: _snapBackController!,
      curve: Curves.elasticOut,
    ));

    _snapBackAnimation!.addListener(() {
      if (_dragState != null) {
        setState(() {
          _dragState = _dragState!.copyWith(
            currentPosition: _snapBackAnimation!.value,
          );
        });
      }
    });

    _snapBackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Snap back completed - clean up drag state
        setState(() {
          _dragState = null;
          _overlayWidth = 70.0;
        });

        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    _snapBackController!.forward();
  }

  void _snapBackAfterClose() {
    debugPrint("_snapBackAfterClose called - closing overlay states");

    // Close overlay states
    ref.read(chatOverlayOpenProvider.notifier).state = false;
    ref.read(chatTriggeredByBubbleProvider.notifier).state = null;
    ref.read(activeOverlayTypeProvider.notifier).state = null;

    // Clear explosion reveal state
    ref.read(explosionRevealProvider.notifier).state = null;

    // Snap bubble back to original position
    if (_dragState != null) {
      _snapBackToOriginalPosition();
    }

    _executePendingNavigationCallback();
  }

  @override
  Widget build(BuildContext context) {
    final feedType = ref.watch(currentFeedProvider);
    final customization = ref.watch(uICustomizationProvider).value;
    final appTheme = customization?.appTheme;
    final backgroundColor = appTheme?.getBackgroundColor() ??
        Theme.of(context).scaffoldBackgroundColor;
    final isChatOverlayOpen = ref.watch(chatOverlayOpenProvider);

    // Use ref.listen outside of build in initState/didChangeDependencies
    // Only watch the chat bubbles for rebuilding the bubble list
    final activeChats = ref.watch(activeChatBubblesProvider);

    // Get user herds once to avoid repeated provider access during animation
    final currentUser = ref.read(authProvider);
    final userHerdsAsync = currentUser != null &&
            widget.showHerdBubbles &&
            feedType == FeedType.alt
        ? ref.watch(profileUserHerdsProvider(currentUser.uid))
        : null;

    ref.listen<String?>(chatClosingAnimationProvider,
        (previous, chatClosingBubbleId) {
      if (chatClosingBubbleId != null && chatClosingBubbleId != previous) {
        debugPrint(
            'Chat closing animation triggered for: $chatClosingBubbleId');

        ref.read(chatClosingAnimationProvider.notifier).state = null;

        final callbacks = ref.read(bubbleAnimationCallbackProvider);
        final callback = callbacks[chatClosingBubbleId];
        if (callback != null) {
          debugPrint(
              'Starting reveal animation for $chatClosingBubbleId, isClosing: true');
          callback(); // This calls _startCloseAnimation, AnimatedRevealOverlay will handle the rest
        } else {
          debugPrint('No callback found for bubble ID: $chatClosingBubbleId');
          debugPrint('Available callback IDs: ${callbacks.keys.toList()}');
        }
      }
    });

    ref.listen<String?>(herdClosingAnimationProvider,
        (previous, herdClosingBubbleId) {
      if (herdClosingBubbleId != null && herdClosingBubbleId != previous) {
        debugPrint(
            'Herd closing animation triggered for: $herdClosingBubbleId');

        ref.read(herdClosingAnimationProvider.notifier).state = null;

        final callbacks = ref.read(bubbleAnimationCallbackProvider);
        final callback = callbacks[herdClosingBubbleId];
        if (callback != null) {
          debugPrint(
              'Starting reveal animation for $herdClosingBubbleId, isClosing: true');
          callback(); // This calls _startCloseAnimation, AnimatedRevealOverlay will handle the rest
        } else {
          debugPrint('No callback found for bubble ID: $herdClosingBubbleId');
          debugPrint('Available callback IDs: ${callbacks.keys.toList()}');
        }
      }
    });
    ref.listen(activeChatBubblesProvider, (previous, next) {
      if (previous != next) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _updateAnimationCallbacks();
          }
        });
      }
    });

    // Listen for herd data changes to register callbacks
    // This ensures callbacks are registered when herds load asynchronously
    if (currentUser != null &&
        widget.showHerdBubbles &&
        feedType == FeedType.alt) {
      ref.listen(profileUserHerdsProvider(currentUser.uid), (previous, next) {
        if (previous != next) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint('Herds data changed, updating animation callbacks');
              _updateAnimationCallbacks();
            }
          });
        }
      });
    }

    final configs = _createBubbleConfigs(
        context, ref, feedType, appTheme, activeChats, userHerdsAsync);
    final stationaryConfigs = configs.stationary;
    final draggableConfigs = configs.draggable;

    return AnimatedBuilder(
      animation: _chatVisibilityAnimation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset((1.0 - _chatVisibilityAnimation!.value) * 70, 0),
          child: Opacity(
            opacity: _chatVisibilityAnimation!.value,
            child: Container(
              width: _overlayWidth,
              color: Colors.transparent,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      // Calculate heights for dynamic stacking
                      _buildStackedBubbleLayout(
                        context,
                        constraints,
                        stationaryConfigs,
                        draggableConfigs,
                        appTheme,
                        isChatOverlayOpen,
                      ),
                      if (_dragState != null)
                        Positioned.fill(
                          child: IgnorePointer(
                            child: CustomPaint(
                              painter: SuperStretchyTrailPainter(
                                originalPosition:
                                    _dragState!.trailStartPosition,
                                currentPosition:
                                    _dragState!.trailCurrentPosition,
                                trailColor: _dragState!.trailColor,
                                bubbleSize: _dragState!.bubbleSizeValue,
                                screenSize: constraints.biggest,
                              ),
                            ),
                          ),
                        ),
                      if (_dragState != null)
                        Positioned(
                          left: _dragState!.currentPosition.dx,
                          top: _dragState!.currentPosition.dy,
                          child: IgnorePointer(
                            child:
                                _buildDraggedBubble(_dragState!.bubbleConfig),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggedBubble(BubbleConfigState config) {
    final scale = _chatScaleAnimation?.value ?? 1.0;
    final explosionProgress = _chatMorphAnimation?.value ?? 0.0;

    // Calculate effective animations for opening animation only
    double effectiveScale = 1.0;
    double effectiveExplosionProgress = 0.0;

    if (_dragState?.isAnimatingToChat == true) {
      // Opening: use forward animation
      effectiveScale = scale;
      effectiveExplosionProgress = explosionProgress;
    }

    // If we're in explosion mode (progress > 0), show explosion effect
    if (effectiveExplosionProgress > 0.0) {
      return SizedBox(
        width: config.effectiveSize,
        height: config.effectiveSize,
        child: CustomPaint(
          painter: BubbleExplosionPainter(
            animationProgress: effectiveExplosionProgress,
            bubbleColor: config.backgroundColor ?? Colors.blue,
            bubbleSize: config.effectiveSize,
            position: Offset(
              config.effectiveSize / 2, // Center of the widget
              config.effectiveSize / 2,
            ),
            isRevealMode: true, // Use reveal mode to show connection to chat
          ),
          size: Size(config.effectiveSize, config.effectiveSize),
        ),
      );
    }

    // Normal bubble when not exploding
    return Transform.scale(
      scale: effectiveScale,
      child: Container(
        width: config.effectiveSize,
        height: config.effectiveSize,
        decoration: BoxDecoration(
          color: config.backgroundColor ?? Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(
            color:
                (config.foregroundColor ?? Colors.white).withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Center(
          child: _buildBubbleContent(config),
        ),
      ),
    );
  }

  Widget _buildBubbleContent(BubbleConfigState config) {
    if (config.icon != null) {
      return Icon(
        config.icon!,
        color: config.foregroundColor ?? Colors.white,
        size: config.effectiveSize * 0.4,
      );
    } else if (config.text != null) {
      return Text(
        config.text!,
        style: TextStyle(
          color: config.foregroundColor ?? Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      );
    }
    return const SizedBox.shrink();
  }

  ({List<BubbleConfigState> stationary, List<BubbleConfigState> draggable})
      _createBubbleConfigs(
          BuildContext context,
          WidgetRef ref,
          FeedType feedType,
          dynamic appTheme,
          List<dynamic> activeChats,
          AsyncValue<List<HerdModel>>? userHerdsAsync) {
    final List<BubbleConfigState> stationaryConfigs = [];
    final List<BubbleConfigState> draggableConfigs = [];

    // System bubbles (order 0-99) - NOT DRAGGABLE
    if (widget.showSearchBtn) {
      stationaryConfigs.add(BubbleFactory.searchBubble(
        backgroundColor: appTheme?.getSurfaceColor() ??
            Theme.of(context).colorScheme.surface,
        foregroundColor:
            appTheme?.getTextColor() ?? Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.all(2), // Minimal padding
        order: 10,
      ));
    }

    if (widget.showProfileBtn) {
      final currentUser = ref.read(authProvider);
      stationaryConfigs.add(BubbleFactory.profileBubble(
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
        padding: const EdgeInsets.all(2), // Minimal padding
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

    // Chat Toggle Bubble (order 100) - NOT DRAGGABLE
    final isChatEnabled = ref.watch(chatBubblesEnabledProvider);
    if (widget.showChatToggle) {
      stationaryConfigs.add(BubbleFactory.chatToggleBubble(
        isChatEnabled: isChatEnabled,
        backgroundColor: isChatEnabled
            ? (appTheme?.getPrimaryColor().withValues(alpha: 0.3) ??
                Theme.of(context).colorScheme.primaryContainer)
            : (appTheme?.getSurfaceColor().withValues(alpha: 0.3) ??
                Theme.of(context).colorScheme.surfaceContainerHighest),
        foregroundColor: isChatEnabled
            ? (appTheme?.getPrimaryColor() ??
                Theme.of(context).colorScheme.primary)
            : (appTheme?.getTextColor().withValues(alpha: 0.6) ??
                Theme.of(context).colorScheme.onSurfaceVariant),
        padding: const EdgeInsets.all(
            2), // Minimal padding to match other stationary bubbles
        order: 100,
        onToggle: () {
          HapticFeedback.mediumImpact();
          ref.read(chatBubblesEnabledProvider.notifier).state = !isChatEnabled;
        },
      ));
    }

    // Community/Chat bubbles (order 500+) - DRAGGABLE - only show if chat is enabled
    if (userHerdsAsync != null &&
        userHerdsAsync.hasValue &&
        userHerdsAsync.value != null) {
      final herds = userHerdsAsync.value!;
      for (int i = 0; i < herds.length; i++) {
        final herd = herds[i];

        draggableConfigs.add(BubbleFactory.herdBubble(
                herdId: 'herd_${herd.id}',
                name: herd.name,
                profileImageUrl: herd.profileImageURL,
                backgroundColor: appTheme?.getBackgroundColor() ??
                    Theme.of(context).colorScheme.surface,
                foregroundColor: appTheme?.getTextColor() ??
                    Theme.of(context).colorScheme.onSurface,
                customOnTap: () {
                  HapticFeedback.lightImpact();
                  /* TODO: Add something here for tapping a herd bubble. 
                Maybe it just takes you directly to it. I don't know. */
                })
            .copyWith(
                isDraggable: true,
                contentType: herd.profileImageURL != null
                    ? BubbleContentType.herdProfileImage
                    : BubbleContentType.icon,
                icon: Icons.groups));
      }
    }

    // Chat bubbles for both feeds - only show if chat is enabled
    if (isChatEnabled) {
      final filteredChats = activeChats.where((chat) {
        if (feedType == FeedType.alt) {
          return chat.isAlt;
        } else {
          return !chat.isAlt;
        }
      }).toList();

      final chatStartOrder = widget.showHerdBubbles ? 600 : 500;
      for (int i = 0; i < filteredChats.length; i++) {
        final chat = filteredChats[i];
        draggableConfigs.add(BubbleFactory.chatBubble(
          chatId: chat.id,
          name: chat.otherUserName ?? "unknown",
          imageUrl: feedType == FeedType.alt
              ? chat.otherUserAltProfileImage ?? chat.otherUserProfileImage
              : chat.otherUserProfileImage,
          lastMessage: chat.lastMessage,
          unreadCount: chat.unreadCount > 0 ? chat.unreadCount : null,
          isOnline: false, // You can add online status logic later
          backgroundColor: appTheme?.getSurfaceColor() ??
              Theme.of(context).colorScheme.surface,
          foregroundColor: appTheme?.getTextColor() ??
              Theme.of(context).colorScheme.onSurface,
          order: chatStartOrder + i,
          customOnTap: () {
            HapticFeedback.lightImpact();
            // Navigate to chat screen
            context.pushNamed(
              'chat',
              queryParameters: {'chatId': chat.id},
            );
          },
        ).copyWith(
          isDraggable: true,
          contentType: chat.otherUserProfileImage != null ||
                  chat.otherUserAltProfileImage != null
              ? BubbleContentType.profileImage
              : BubbleContentType.text,
        ));
      }
    }

    return (stationary: stationaryConfigs, draggable: draggableConfigs);
  }

  Widget _buildStackedBubbleLayout(
    BuildContext context,
    BoxConstraints constraints,
    List<BubbleConfigState> stationaryConfigs,
    List<BubbleConfigState> draggableConfigs,
    dynamic appTheme,
    bool isChatOverlayOpen,
  ) {
    // Calculate height of screen-level stationary bubbles (from stationaryConfigs)
    double screenStationaryHeight = 0;
    for (final config in stationaryConfigs) {
      screenStationaryHeight += config.effectiveSize + config.padding.vertical;
    }

    // Calculate height of GlobalOverlayManager's FloatingButtonsColumn
    // Use the same parameters as defined in router.dart (_TabScaffold)
    final globalButtonsHeight = calculateFloatingButtonsHeight(
      showProfileBtn: true, // From router: showProfileBtn: true
      showSearchBtn: true, // From router: showSearchBtn: true
      showNotificationsBtn: false, // From router: showNotificationsBtn: false
      showChatToggle: true, // From router: showChatToggle: true
    );

    // Add some padding between sections
    const sectionPadding = 8.0;
    final totalStationarySpace =
        screenStationaryHeight + globalButtonsHeight + sectionPadding;

    return Positioned(
      right: 0,
      top: 0,
      bottom: totalStationarySpace, // Reserve space for bottom buttons
      width: 70,
      child: Column(
        mainAxisSize: MainAxisSize.max, // Use full available height
        children: [
          // Draggable bubbles section (takes all available space)
          if (draggableConfigs.isNotEmpty)
            Expanded(
              // Use Expanded instead of ConstrainedBox to fill available space
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white,
                      Colors.white,
                      Colors.transparent,
                    ],
                    stops: [
                      0.0,
                      0.92,
                      0.96,
                      1.0
                    ], // Fade at the bottom near stationary bubbles
                  ).createShader(bounds);
                },
                blendMode: BlendMode.dstIn,
                child: ListView.builder(
                  reverse: true, // Start from bottom
                  controller: _scrollController,
                  physics: isChatOverlayOpen
                      ? const NeverScrollableScrollPhysics()
                      : const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(
                    bottom: sectionPadding, // Space for gradient fade
                  ),
                  itemCount: draggableConfigs.length,
                  itemBuilder: (context, index) {
                    final config = draggableConfigs[index];
                    final isBeingDragged = _dragState?.bubbleId == config.id;

                    final bubble = DraggableBubble(
                      key: ValueKey(config.id),
                      config: config,
                      appTheme: appTheme,
                      globalKey:
                          _bubbleKeys.putIfAbsent(config.id, () => GlobalKey()),
                      onDragStart: isChatOverlayOpen
                          ? (_) {} // Disable drag when overlay is open
                          : (globalPos) =>
                              _startDrag(config.id, globalPos, constraints),
                      onDragUpdate: isChatOverlayOpen
                          ? (_) {} // Disable drag when overlay is open
                          : _updateDrag,
                      onDragEnd: isChatOverlayOpen
                          ? () {} // Disable drag when overlay is open
                          : _endDrag,
                      isBeingDragged: isBeingDragged,
                    );

                    // Add padding to the last item (bottom of the list)
                    if (config == draggableConfigs.first) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: bubble,
                      );
                    }
                    return bubble;
                  },
                ),
              ),
            ),

          // Stationary bubbles are now handled by GlobalOverlayManager's FloatingButtonsColumn
        ],
      ),
    );
  }
}
