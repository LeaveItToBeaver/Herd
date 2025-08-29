import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to track if chat bubbles are enabled/disabled
/// Default is true (enabled)
final chatBubblesEnabledProvider = StateProvider<bool>((ref) => false);
