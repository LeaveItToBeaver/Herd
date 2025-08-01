import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:herdapp/core/barrels/providers.dart';
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

  DragState? _dragState;
  final Map<String, GlobalKey> _bubbleKeys = {};

  double _overlayWidth = 70.0;

  AnimationController? _snapBackController;
  Animation<Offset>? _snapBackAnimation;

  AnimationController? _chatMorphController;
  Animation<double>? _chatMorphAnimation;
  Animation<double>? _chatScaleAnimation;

  AnimationController? _chatCloseController;
  Animation<double>? _chatCloseAnimation;

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
      ref.read(bubbleAnimationCallbackProvider.notifier).update((state) {
        final newState = Map<String, VoidCallback>.from(state);
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
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _snapBackController?.dispose();
    _chatMorphController?.dispose();
    _chatCloseController?.dispose();
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

    final bubbleConfigs = _createBubbleConfigs(
        context, ref, ref.watch(currentFeedProvider), null);
    final bubbleConfig = bubbleConfigs.firstWhere((c) => c.id == bubbleId);

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
      // Animate bubble to chat position and open chat overlay
      _animateToChat();
      return;
    }

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
          _overlayWidth = 70.0;
        });

        ref.read(isDraggingProvider.notifier).state = false;
      }
    });

    _snapBackController!.forward();
    HapticFeedback.lightImpact();
  }

  void _animateToChat() {
    if (_dragState == null) return;

    ref.read(chatOverlayOpenProvider.notifier).state = true;
    ref.read(chatTriggeredByBubbleProvider.notifier).state =
        _dragState!.bubbleId;

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

      ref.read(explosionRevealProvider.notifier).state = (
        isActive: true,
        center: bubbleGlobalCenter,
        progress: 0.0,
        bubbleId: _dragState!.bubbleId,
      );
    }

    _chatMorphController?.dispose();
    _chatMorphController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
      duration: const Duration(milliseconds: 400),
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

        final explosionProgress = _chatMorphAnimation!.value;

        final containerRenderBox = context.findRenderObject() as RenderBox?;
        if (containerRenderBox != null) {
          final containerGlobalPos =
              containerRenderBox.localToGlobal(Offset.zero);
          final bubbleGlobalCenter = containerGlobalPos +
              _dragState!.currentPosition +
              Offset(_dragState!.bubbleConfig.effectiveSize / 2,
                  _dragState!.bubbleConfig.effectiveSize / 2);

          ref.read(explosionRevealProvider.notifier).state = (
            isActive: true,
            center: bubbleGlobalCenter,
            progress: explosionProgress,
            bubbleId: _dragState!.bubbleId,
          );
        }
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

        ref.read(explosionRevealProvider.notifier).state = null;
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

  void closeChatWithAnimation() {
    if (_dragState == null) return;

    final containerRenderBox = context.findRenderObject() as RenderBox?;
    if (containerRenderBox != null) {
      final containerGlobalPos = containerRenderBox.localToGlobal(Offset.zero);
      final bubbleGlobalCenter = containerGlobalPos +
          _dragState!.currentPosition +
          Offset(_dragState!.bubbleConfig.effectiveSize / 2,
              _dragState!.bubbleConfig.effectiveSize / 2);

      ref.read(explosionRevealProvider.notifier).state = (
        isActive: true,
        center: bubbleGlobalCenter,
        progress: 1.0, // Start fully revealed
        bubbleId: _dragState!.bubbleId,
      );
    }

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
        ref.read(chatOverlayOpenProvider.notifier).state = false;

        ref.read(explosionRevealProvider.notifier).state = (
          isActive: false,
          center: Offset.zero,
          progress: 0.0,
          bubbleId: '',
        );

        _snapBackToOriginalPosition();
      }
    });

    // Start close animation
    _chatCloseController!.forward();
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
      duration: const Duration(milliseconds: 400),
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
  }

  void _animateFromChat() {
    if (_dragState == null) {
      ref.read(chatOverlayOpenProvider.notifier).state = false;
      ref.read(chatTriggeredByBubbleProvider.notifier).state = null;
      ref.read(explosionRevealProvider.notifier).state = null;
      return;
    }

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
        ref.read(chatClosingAnimationProvider.notifier).state = null;
        final callbacks = ref.read(bubbleAnimationCallbackProvider);
        final callback = callbacks[chatClosingBubbleId];
        if (callback != null) {
          callback();
        }
      });
    }

    final bubbleConfigs =
        _createBubbleConfigs(context, ref, feedType, appTheme);

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
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 185,
                        width: 70,
                        child: Column(
                          children: [
                            Expanded(
                              child: ShaderMask(
                                shaderCallback: (Rect bounds) {
                                  return LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: const [
                                      Colors.white,
                                      Colors.white,
                                      Colors.white,
                                      Colors.white,
                                      Colors.white,
                                      Colors.transparent,
                                    ],
                                    stops: const [
                                      0.0,
                                      0.80,
                                      0.85,
                                      0.88,
                                      0.90,
                                      1.0
                                    ], // Sharp wall effect: solid until 75%, then razor-sharp fade
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.dstIn,
                                child: ListView.builder(
                                  reverse: true,
                                  controller: _scrollController,
                                  padding: const EdgeInsets.only(bottom: 15),
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
                                          config.id, globalPos, constraints),
                                      onDragUpdate: _updateDrag,
                                      onDragEnd: _endDrag,
                                      isBeingDragged: isBeingDragged,
                                    );

                                    if (index == 0) {
                                      return Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20.0),
                                        child: bubble,
                                      );
                                    }
                                    return bubble;
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
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

    // Chat Toggle Bubble (order 100) - NOT DRAGGABLE
    final isChatEnabled = ref.watch(chatBubblesEnabledProvider);
    configs.add(BubbleFactory.chatToggleBubble(
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
      padding: const EdgeInsets.fromLTRB(4, 16, 4, 4), // Extra top padding
      order: 100,
      onToggle: () {
        HapticFeedback.mediumImpact();
        ref.read(chatBubblesEnabledProvider.notifier).state = !isChatEnabled;
      },
    ));

    // Community/Chat bubbles (order 500+) - DRAGGABLE - only show if chat is enabled
    if (widget.showHerdBubbles && isChatEnabled) {
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

    // Chat bubbles for both feeds - only show if chat is enabled
    if (isChatEnabled) {
      final chatStartOrder = widget.showHerdBubbles ? 600 : 500;
      for (int i = 0; i < 10; i++) {
        // ALL chat bubbles are draggable
        configs.add(BubbleFactory.chatBubble(
          chatId: 'chat_$i',
          name: 'Chat ${i + 1}',
          backgroundColor: appTheme?.getSurfaceColor() ??
              Theme.of(context).colorScheme.surface,
          foregroundColor: appTheme?.getTextColor() ??
              Theme.of(context).colorScheme.onSurface,
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
    }

    return configs;
  }
}
