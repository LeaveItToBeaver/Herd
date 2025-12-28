import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'overlay_providers.g.dart';

// Generic overlay type provider
enum OverlayType { chat, herd }

// Chat providers - keepAlive to persist state during overlay animations
@Riverpod(keepAlive: true)
class ChatOverlayOpen extends _$ChatOverlayOpen {
  @override
  bool build() => false;
}

@Riverpod(keepAlive: true)
class ChatTriggeredByBubble extends _$ChatTriggeredByBubble {
  @override
  String? build() => null;
}

// Herd providers - keepAlive to persist state during overlay animations
@Riverpod(keepAlive: true)
class HerdOverlayOpen extends _$HerdOverlayOpen {
  @override
  bool build() => false;
}

@Riverpod(keepAlive: true)
class HerdTriggeredByBubble extends _$HerdTriggeredByBubble {
  @override
  String? build() => null;
}

// Generic active overlay type provider - keepAlive to persist during animations
@Riverpod(keepAlive: true)
class ActiveOverlayType extends _$ActiveOverlayType {
  @override
  OverlayType? build() => null;
}
