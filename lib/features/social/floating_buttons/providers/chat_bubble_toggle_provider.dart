import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_bubble_toggle_provider.g.dart';

/// Provider to track if chat bubbles are enabled/disabled
@riverpod
class ChatBubblesEnabled extends _$ChatBubblesEnabled {
  @override
  bool build() => false;
}
