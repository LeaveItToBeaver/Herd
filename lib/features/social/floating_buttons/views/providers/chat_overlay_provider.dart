import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to track if the chat overlay is open
final chatOverlayOpenProvider = StateProvider<bool>((ref) => false);

// Provider to track which bubble triggered the chat
final chatTriggeredByBubbleProvider = StateProvider<String?>((ref) => null);
