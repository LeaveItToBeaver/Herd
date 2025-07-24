import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/floating_buttons/views/providers/state/global_draggable_state.dart';

final globalDraggableProvider =
    StateNotifierProvider<GlobalDraggableNotifier, GlobalDraggableState>(
  (ref) => GlobalDraggableNotifier(),
);
