import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/bubble_config_state.dart';
import 'package:herdapp/features/social/floating_buttons/views/widgets/global_drag_overlay.dart';

// Global draggable state
class GlobalDraggableState {
  final String? activeBubbleId;
  final Offset? dragPosition;
  final bool isDragging;
  final Map<String, GlobalKey> bubbleKeys;
  final Map<String, Offset> bubblePositions;

  const GlobalDraggableState({
    this.activeBubbleId,
    this.dragPosition,
    this.isDragging = false,
    this.bubbleKeys = const {},
    this.bubblePositions = const {},
  });

  GlobalDraggableState copyWith({
    String? activeBubbleId,
    Offset? dragPosition,
    bool? isDragging,
    Map<String, GlobalKey>? bubbleKeys,
    Map<String, Offset>? bubblePositions,
  }) {
    return GlobalDraggableState(
      activeBubbleId: activeBubbleId ?? this.activeBubbleId,
      dragPosition: dragPosition ?? this.dragPosition,
      isDragging: isDragging ?? this.isDragging,
      bubbleKeys: bubbleKeys ?? this.bubbleKeys,
      bubblePositions: bubblePositions ?? this.bubblePositions,
    );
  }
}

// Global draggable notifier
class GlobalDraggableNotifier extends StateNotifier<GlobalDraggableState> {
  OverlayEntry? _dragOverlay;
  BuildContext? _overlayContext;

  GlobalDraggableNotifier() : super(const GlobalDraggableState());

  void registerBubble(String bubbleId, GlobalKey key) {
    final newKeys = Map<String, GlobalKey>.from(state.bubbleKeys);
    newKeys[bubbleId] = key;
    state = state.copyWith(bubbleKeys: newKeys);
    _updateBubblePosition(bubbleId);
  }

  void unregisterBubble(String bubbleId) {
    final newKeys = Map<String, GlobalKey>.from(state.bubbleKeys);
    final newPositions = Map<String, Offset>.from(state.bubblePositions);
    newKeys.remove(bubbleId);
    newPositions.remove(bubbleId);
    state = state.copyWith(bubbleKeys: newKeys, bubblePositions: newPositions);
  }

  void _updateBubblePosition(String bubbleId) {
    final key = state.bubbleKeys[bubbleId];
    if (key?.currentContext != null) {
      final renderBox = key!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final newPositions = Map<String, Offset>.from(state.bubblePositions);
        newPositions[bubbleId] = position;
        state = state.copyWith(bubblePositions: newPositions);
      }
    }
  }

  void updateAllPositions() {
    for (final bubbleId in state.bubbleKeys.keys) {
      _updateBubblePosition(bubbleId);
    }
  }

  void startDrag(String bubbleId, Offset startPosition, BuildContext context,
      BubbleConfigState config, dynamic appTheme) {
    if (state.isDragging) return;

    _overlayContext = context;
    final bubblePosition = state.bubblePositions[bubbleId] ?? startPosition;

    state = state.copyWith(
      activeBubbleId: bubbleId,
      dragPosition: bubblePosition,
      isDragging: true,
    );

    _createDragOverlay(config, appTheme, bubblePosition);
  }

  void updateDrag(Offset newPosition) {
    if (!state.isDragging) return;
    state = state.copyWith(dragPosition: newPosition);
  }

  void endDrag() {
    if (!state.isDragging) return;

    _dragOverlay?.remove();
    _dragOverlay = null;
    _overlayContext = null;

    state = state.copyWith(
      activeBubbleId: null,
      dragPosition: null,
      isDragging: false,
    );
  }

  void _createDragOverlay(
      BubbleConfigState config, dynamic appTheme, Offset startPosition) {
    if (_overlayContext == null) return;

    _dragOverlay = OverlayEntry(
      builder: (context) => GlobalDragOverlay(
        config: config,
        appTheme: appTheme,
        startPosition: startPosition,
        onDragEnd: endDrag,
        dragStateProvider: this,
      ),
    );

    Overlay.of(_overlayContext!).insert(_dragOverlay!);
  }

  @override
  void dispose() {
    _dragOverlay?.remove();
    super.dispose();
  }
}
