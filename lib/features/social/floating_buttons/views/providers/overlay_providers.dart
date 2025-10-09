import 'package:flutter_riverpod/flutter_riverpod.dart';

// Chat providers
final chatOverlayOpenProvider = StateProvider<bool>((ref) => false);
final chatTriggeredByBubbleProvider = StateProvider<String?>((ref) => null);

// Herd providers
final herdOverlayOpenProvider = StateProvider<bool>((ref) => false);
final herdTriggeredByBubbleProvider = StateProvider<String?>((ref) => null);

// Generic overlay type provider
enum OverlayType { chat, herd }

final activeOverlayTypeProvider = StateProvider<OverlayType?>((ref) => null);
