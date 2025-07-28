import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/social/floating_buttons/providers/chat_animation_provider.dart';
import 'package:herdapp/features/social/floating_buttons/utils/bubble_factory.dart';
import 'package:herdapp/features/social/floating_buttons/utils/bubble_explosion_painter.dart';
import 'package:herdapp/features/social/floating_buttons/utils/controllers/advanced_haptics_controller.dart';
import 'package:herdapp/features/social/floating_buttons/utils/controllers/haptics_controller.dart';
import 'package:herdapp/features/social/floating_buttons/utils/enums/bubble_content_type.dart';
import 'package:herdapp/features/social/floating_buttons/utils/super_stretchy_painter.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/drag_state.dart';
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

  // Replace individual drag variables with a single drag state
  DragState? _dragState;
  final Map<String, GlobalKey> _bubbleKeys = {};

  // Simple state variable for width instead of animation
  double _overlayWidth = 70.0;

  // Animation controllers for enhanced chat animations
  AnimationController? _snapBackController;
  Animation<Offset>? _snapBackAnimation;

  AnimationController? _chatMorphController;
  Animation<double>? _chatMorphAnimation;
  Animation<double>? _chatScaleAnimation;

  AnimationController? _chatCloseController;
  Animation<double>? _chatCloseAnimation;

  // Haptic feedback
  late HapticDragController _hapticController;
  late AdvancedHaptics _haptics;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _hapticController = HapticDragController();
    //_haptics = AdvancedHaptics();

    // Listen for chat closing events to trigger reverse animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Register callback for all draggable bubbles
      ref.read(bubbleAnimationCallbackProvider.notifier).update((state) {
        final newState = Map<String, VoidCallback>.from(state);
        // Register for all potential chat bubble IDs
        for (int i = 0; i < 10; i++) {
          newState['chat_$i'] = _animateFromChat;
        }
        // Register for herd bubbles too if needed
        for (int i = 0; i < 5; i++) {
          newState['herd_$i'] = _animateFromChat;
        }
        return newState;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _snapBackController?.dispose();
    _chatMorphController?.dispose();
    _chatCloseController?.dispose();
    _hapticController.dispose();
    super.dispose();
  }

  void _startDrag(
      String bubbleId, Offset globalTouchPosition, BoxConstraints constraints) {
    final key = _bubbleKeys[bubbleId];
    if (key?.currentContext == null) return;

    final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    // Get bubble config
    final bubbleConfigs = _createBubbleConfigs(
        context, ref, ref.watch(currentFeedProvider), null);
    final bubbleConfig = bubbleConfigs.firstWhere((c) => c.id == bubbleId);

    // Get the PADDED container's screen position
    final paddedContainerGlobalPos = renderBox.localToGlobal(Offset.zero);
    final paddedContainerSize = renderBox.size;

    // Get the container's screen position
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

    // Get the actual bubble's center position relative to our main container
    final bubbleCenterRelativePos =
        paddedContainerRelativePos + bubbleCenterInPaddedContainer;

    // Since we're expanding instantly, calculate the position directly
    final screenWidth = MediaQuery.of(context).size.width;

    // The bubble is currently positioned relative to the right edge (in the 70px container)
    // When we expand to full width, we need to maintain that right-edge relationship
    final rightEdgeOffset = 70.0 - bubbleCenterRelativePos.dx;

    // Calculate where the bubble should be positioned in the expanded container
    final adjustedStartPosition = Offset(
      screenWidth - rightEdgeOffset - (actualBubbleSize.width / 2),
      bubbleCenterRelativePos.dy - (actualBubbleSize.height / 2),
    );

    // Calculate touch offset relative to the bubble's center
    final bubbleCenterGlobalPos =
        paddedContainerGlobalPos + bubbleCenterInPaddedContainer;
    final touchOffset = globalTouchPosition - bubbleCenterGlobalPos;

    // Create drag state
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
        screenSize: MediaQuery.of(context).size, // Add screen size
        hasTriggeredChatThreshold: false, // Initialize threshold state
      );

      // Instantly expand the overlay width
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

    // Check for chat threshold crossing
    if (_dragState!.shouldTriggerChatThreshold) {
      setState(() {
        _dragState = _dragState!.copyWith(
          hasTriggeredChatThreshold: true,
        );
      });

      // Heavy haptic feedback when crossing chat threshold
      HapticFeedback.heavyImpact();

      // Add a delayed second impact for emphasis
      Future.delayed(const Duration(milliseconds: 50), () {
        HapticFeedback.mediumImpact();
      });
    }

    // Add haptic feedback based on drag distance
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

    // Check if we should trigger chat overlay
    if (_dragState!.hasTriggeredChatThreshold && _dragState!.isInChatZone) {
      // Animate bubble to chat position and open chat overlay
      _animateToChat();
      return;
    }

    // Create snap back animation for normal drag end
    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
          // Instantly collapse the overlay width
          _overlayWidth = 70.0;
        });

        // Update provider
        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    _snapBackController!.forward();
    HapticFeedback.lightImpact();
  }

  void _animateToChat() {
    if (_dragState == null) return;

    // Show chat overlay IMMEDIATELY so the explosion can reveal it!
    ref.read(chatOverlayOpenProvider.notifier).state = true;
    ref.read(chatTriggeredByBubbleProvider.notifier).state =
        _dragState!.bubbleId;

    // Mark as animating to chat
    setState(() {
      _dragState = _dragState!.copyWith(
        isAnimatingToChat: true,
        chatTargetPosition: Offset(50.0, _dragState!.currentPosition.dy),
      );
    });

    // Initialize explosion reveal state immediately so it covers chat from start
    // Convert relative position to global screen position
    final containerRenderBox = context.findRenderObject() as RenderBox?;
    if (containerRenderBox != null) {
      final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);
      final bubbleGlobalCenter = containerGlobalPos +
          _dragState!.currentPosition +
          Offset(_dragState!.bubbleConfig.effectiveSize / 2,
              _dragState!.bubbleConfig.effectiveSize / 2);

      print(
          "🎆 Setting explosion reveal state: center=$bubbleGlobalCenter, progress=0.0");
      ref.read(explosionRevealProvider.notifier).state = (
        isActive: true,
        center: bubbleGlobalCenter,
        progress: 0.0, // Start at 0 so it covers everything initially
        bubbleId: _dragState!.bubbleId,
      );
    }

    // Create bubble explosion animation - much more dramatic!
    _chatMorphController?.dispose();
    _chatMorphController = AnimationController(
      duration: const Duration(milliseconds: 500), // Faster explosion effect
      vsync: this,
    );

    // Main explosion animation - goes from 0 to 1
    _chatMorphAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chatMorphController!,
      curve: Curves.easeOutQuart, // Smooth explosion curve
    ));

    // Scale animation for the initial bubble before explosion
    _chatScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5, // Slight initial expansion before explosion
    ).animate(CurvedAnimation(
      parent: _chatMorphController!,
      curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
    ));

    // Position animation - bubble moves to final position
    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration:
          const Duration(milliseconds: 400), // Faster coordinated movement
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _dragState!.currentPosition,
      end: _dragState!.chatTargetPosition!,
    ).animate(CurvedAnimation(
      parent: _snapBackController!,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOutQuart),
    ));

    // Listen to explosion animation with high frequency updates
    _chatMorphAnimation!.addListener(() {
      if (_dragState != null) {
        setState(() {
          // Force high frequency updates for smooth animation
        });

        // Update explosion reveal provider for global overlay
        final explosionProgress = _chatMorphAnimation!.value;

        // Convert relative position to global screen position
        final containerRenderBox = context.findRenderObject() as RenderBox?;
        if (containerRenderBox != null) {
          final containerGlobalPos =
              containerRenderBox.localToGlobal(Offset.zero);
          final bubbleGlobalCenter = containerGlobalPos +
              _dragState!.currentPosition +
              Offset(_dragState!.bubbleConfig.effectiveSize / 2,
                  _dragState!.bubbleConfig.effectiveSize / 2);

          print(
              "🎆 Updating explosion reveal: progress=$explosionProgress, center=$bubbleGlobalCenter");
          ref.read(explosionRevealProvider.notifier).state = (
            isActive: true,
            center: bubbleGlobalCenter,
            progress: explosionProgress,
            bubbleId: _dragState!.bubbleId,
          );
        }
      }
    });

    // Add haptic feedback for explosion phases
    _chatMorphAnimation!.addStatusListener((status) {
      if (status == AnimationStatus.forward) {
        // Add haptic feedback at key explosion moments
        Future.delayed(const Duration(milliseconds: 90), () {
          // Bubble expansion phase - medium impact
          HapticFeedback.mediumImpact();
        });

        Future.delayed(const Duration(milliseconds: 240), () {
          // Explosion particles phase - heavy impact
          HapticFeedback.heavyImpact();
        });

        Future.delayed(const Duration(milliseconds: 480), () {
          // Ripple waves phase - light impact
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

    // When morph is complete, mark chat as fully opened
    _chatMorphController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _dragState = _dragState!.copyWith(
            isChatMorphComplete: true,
          );
        });

        // Clear explosion reveal state when animation completes
        ref.read(explosionRevealProvider.notifier).state = null;
      }
    });

    // When position animation reaches halfway point, show chat overlay so explosion can reveal it
    _snapBackController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Animation fully complete
        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    // Start both animations
    _chatMorphController!.forward();
    _snapBackController!.forward();
  }

  void closeChatWithAnimation() {
    if (_dragState == null) return;

    // Initialize reverse explosion reveal state - start with full reveal (progress 1.0)
    final containerRenderBox = context.findRenderObject() as RenderBox?;
    if (containerRenderBox != null) {
      final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);
      final bubbleGlobalCenter = containerGlobalPos +
          _dragState!.currentPosition +
          Offset(_dragState!.bubbleConfig.effectiveSize / 2,
              _dragState!.bubbleConfig.effectiveSize / 2);

      print(
          "🎆 Setting reverse explosion reveal state: center=$bubbleGlobalCenter, progress=1.0");
      ref.read(explosionRevealProvider.notifier).state = (
        isActive: true,
        center: bubbleGlobalCenter,
        progress: 1.0, // Start fully revealed
        bubbleId: _dragState!.bubbleId,
      );
    }

    // Phase 1: Reverse explosion animation (contracts the reveal circle)
    _chatCloseController?.dispose();
    _chatCloseController = AnimationController(
      duration: const Duration(milliseconds: 400), // Faster close
      vsync: this,
    );

    _chatCloseAnimation = Tween<double>(
      begin: 1.0, // Start from fully revealed
      end: 0.0, // Contract to nothing
    ).animate(CurvedAnimation(
      parent: _chatCloseController!,
      curve: Curves.easeInQuart, // Quick close curve
    ));

    _chatCloseAnimation!.addListener(() {
      if (_dragState != null) {
        setState(() {
          // Force updates during close animation
        });

        // Update explosion reveal provider for reverse effect
        final reverseProgress = _chatCloseAnimation!.value;

        // Convert relative position to global screen position
        final containerRenderBox = context.findRenderObject() as RenderBox?;
        if (containerRenderBox != null) {
          final containerGlobalPos =
              containerRenderBox.localToGlobal(Offset.zero);
          final bubbleGlobalCenter = containerGlobalPos +
              _dragState!.currentPosition +
              Offset(_dragState!.bubbleConfig.effectiveSize / 2,
                  _dragState!.bubbleConfig.effectiveSize / 2);

          print(
              "🎆 Updating reverse explosion reveal: progress=$reverseProgress, center=$bubbleGlobalCenter");
          ref.read(explosionRevealProvider.notifier).state = (
            isActive: true,
            center: bubbleGlobalCenter,
            progress: reverseProgress, // Contracts from 1.0 to 0.0
            bubbleId: _dragState!.bubbleId,
          );
        }
      }
    });

    _chatCloseController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Phase 2: Close chat overlay and clear explosion reveal
        debugPrint("🎆 Reverse animation completed, closing chat overlay");

        // Close the chat overlay
        ref.read(chatOverlayOpenProvider.notifier).state = false;

        // Clear explosion reveal effect
        ref.read(explosionRevealProvider.notifier).state = (
          isActive: false,
          center: Offset.zero,
          progress: 0.0,
          bubbleId: '',
        );

        // Phase 3: Snap bubble back to original position
        _snapBackToOriginalPosition();
      }
    });

    // Start close animation
    _chatCloseController!.forward();
  }

  void _snapBackToOriginalPosition() {
    if (_dragState == null) return;

    // Reset chat state
    setState(() {
      _dragState = _dragState!.copyWith(
        isChatMorphComplete: false,
        isAnimatingToChat: false,
        hasTriggeredChatThreshold: false,
      );
    });

    // Create snap back animation to original position
    _snapBackController?.dispose();
    _snapBackController = AnimationController(
      duration: const Duration(milliseconds: 400), // Faster snap back
      vsync: this,
    );

    _snapBackAnimation = Tween<Offset>(
      begin: _dragState!.currentPosition,
      end: _dragState!.startPosition,
    ).animate(CurvedAnimation(
      parent: _snapBackController!,
      curve: Curves.elasticOut, // Keep elastic for nice bounce effect
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
        // Clean up and reset state
        setState(() {
          _dragState = null;
          _overlayWidth = 70.0;
        });

        // Reset providers (only dragging state, chat is already closed)
        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    _snapBackController!.forward();
  }

  // Method called from chat overlay to trigger reverse animation
  void _animateFromChat() {
    closeChatWithAnimation();
  }

  @override
  Widget build(BuildContext context) {
    final feedType = ref.watch(currentFeedProvider);
    final customization = ref.watch(uiCustomizationProvider).value;
    final appTheme = customization?.appTheme;
    final backgroundColor = appTheme?.getBackgroundColor() ??
        Theme.of(context).scaffoldBackgroundColor;

    // Listen for chat closing animation requests
    final chatClosingBubbleId = ref.watch(chatClosingAnimationProvider);
    if (chatClosingBubbleId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Reset the provider first
        ref.read(chatClosingAnimationProvider.notifier).state = null;
        // Trigger the animation
        final callbacks = ref.read(bubbleAnimationCallbackProvider);
        final callback = callbacks[chatClosingBubbleId];
        if (callback != null) {
          callback();
        }
      });
    }

    final bubbleConfigs =
        _createBubbleConfigs(context, ref, feedType, appTheme);

    return Container(
      width: _overlayWidth,
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
                        itemCount: bubbleConfigs.length,
                        itemBuilder: (context, index) {
                          final config = bubbleConfigs[index];
                          final isBeingDragged =
                              _dragState?.bubbleId == config.id;

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

              // Original stretchy trail (your perfect design!)
              if (_dragState != null)
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: SuperStretchyTrailPainter(
                        originalPosition: _dragState!.trailStartPosition,
                        currentPosition: _dragState!.trailCurrentPosition,
                        trailColor: _dragState!.trailColor,
                        bubbleSize: _dragState!.bubbleSizeValue,
                        screenSize: constraints.biggest,
                      ),
                    ),
                  ),
                ),

              // Chat threshold indicator
              if (_dragState != null)
                Positioned(
                  left: _dragState!.chatThresholdX,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 3,
                      decoration: BoxDecoration(
                        color: _dragState!.isInChatZone
                            ? Colors.green.withValues(alpha: 0.8)
                            : Colors.orange.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(1.5),
                        boxShadow: [
                          BoxShadow(
                            color: (_dragState!.isInChatZone
                                    ? Colors.green
                                    : Colors.orange)
                                .withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Chat threshold label
              if (_dragState != null)
                Positioned(
                  left: _dragState!.chatThresholdX - 40,
                  top: 50,
                  child: IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _dragState!.isInChatZone ? 1.0 : 0.7,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (_dragState!.isInChatZone
                                  ? Colors.green
                                  : Colors.orange)
                              .withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _dragState!.isInChatZone ? 'CHAT ZONE' : 'DRAG LEFT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_dragState != null)
                Positioned(
                  left: _dragState!.currentPosition.dx,
                  top: _dragState!.currentPosition.dy,
                  child: IgnorePointer(
                    child: _buildDraggedBubble(_dragState!.bubbleConfig),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDraggedBubble(BubbleConfigState config) {
    final scale = _chatScaleAnimation?.value ?? 1.0;
    final explosionProgress = _chatMorphAnimation?.value ?? 0.0;
    final closeProgress = _chatCloseAnimation?.value ?? 1.0;

    // Calculate effective animations - consider both opening and closing
    double effectiveScale = 1.0;
    double effectiveExplosionProgress = 0.0;

    if (_dragState?.isAnimatingToChat == true) {
      // Opening: use forward animation
      effectiveScale = scale;
      effectiveExplosionProgress = explosionProgress;
    } else if (_chatCloseAnimation != null) {
      // Closing: use reverse animation
      effectiveScale = 1.0 + (scale - 1.0) * closeProgress;
      effectiveExplosionProgress = explosionProgress * closeProgress;
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
        size: config.effectiveSize * 0.4, // Scale icon with bubble size
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
        padding: const EdgeInsets.all(4),
        order: 10,
      ));
    }

    // if (widget.showNotificationsBtn) {
    //   final notifications =
    //       ref.watch(notificationStreamProvider(ref.read(authProvider)!.uid));
    //   final hasNotifications =
    //       notifications.hasValue && notifications.value!.isNotEmpty;

    //   configs.add(BubbleFactory.notificationsBubble(
    //     hasNotifications: hasNotifications,
    //     backgroundColor: hasNotifications
    //         ? (appTheme?.getErrorColor().withValues(alpha: 0.2) ??
    //             Theme.of(context).colorScheme.errorContainer)
    //         : (appTheme?.getSurfaceColor() ??
    //             Theme.of(context).colorScheme.surface),
    //     foregroundColor: hasNotifications
    //         ? (appTheme?.getErrorColor() ?? Theme.of(context).colorScheme.error)
    //         : (appTheme?.getTextColor() ??
    //             Theme.of(context).colorScheme.onSurface),
    //     errorColor:
    //         appTheme?.getErrorColor() ?? Theme.of(context).colorScheme.error,
    //     padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
    //     order: 20,
    //   ));
    // }

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
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
    // configs.add(BubbleFactory.feedToggleBubble(
    //   isAltFeed: feedType == FeedType.alt,
    //   backgroundColor: feedType == FeedType.alt
    //       ? (appTheme?.getSecondaryColor().withValues(alpha: 0.3) ??
    //           Theme.of(context).colorScheme.secondaryContainer)
    //       : (appTheme?.getPrimaryColor().withValues(alpha: 0.3) ??
    //           Theme.of(context).colorScheme.primaryContainer),
    //   foregroundColor: feedType == FeedType.alt
    //       ? (appTheme?.getSecondaryColor() ??
    //           Theme.of(context).colorScheme.secondary)
    //       : (appTheme?.getPrimaryColor() ??
    //           Theme.of(context).colorScheme.primary),
    //   padding: const EdgeInsets.fromLTRB(4, 16, 4, 4), // Extra top padding
    //   order: 100,
    //   onToggle: () {
    //     HapticFeedback.mediumImpact();
    //     final newFeedType =
    //         feedType == FeedType.alt ? FeedType.public : FeedType.alt;
    //     ref.read(currentFeedProvider.notifier).state = newFeedType;

    //     if (newFeedType == FeedType.alt) {
    //       context.goNamed('altFeed');
    //     } else {
    //       context.goNamed('publicFeed');
    //     }
    //   },
    // ));

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
          padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
        padding: const EdgeInsets.fromLTRB(4, 4, 4, 4),
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
