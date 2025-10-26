import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/chat_state.dart';
import 'chat_state_notifier.dart';

final chatStateProvider =
    StateNotifierProvider<ChatStateNotifier, ChatState>((ref) {
  return ChatStateNotifier(ref);
});
