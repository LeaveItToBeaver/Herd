import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overlay_providers.g.dart';

// Generic overlay type provider
enum OverlayType { chat, herd }

// Chat providers
@riverpod
class ChatOverlayOpen extends _$ChatOverlayOpen {
  @override
  bool build() => false;
}

@riverpod
class ChatTriggeredByBubble extends _$ChatTriggeredByBubble {
  @override
  String? build() => null;
}

// Herd providers
@riverpod
class HerdOverlayOpen extends _$HerdOverlayOpen {
  @override
  bool build() => false;
}

@riverpod
class HerdTriggeredByBubble extends _$HerdTriggeredByBubble {
  @override
  String? build() => null;
}

// Generic active overlay type provider
@riverpod
class ActiveOverlayType extends _$ActiveOverlayType {
  @override
  OverlayType? build() => null;
}
