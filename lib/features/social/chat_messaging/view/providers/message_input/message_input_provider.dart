import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'state/message_input_state.dart';
import 'notifiers/message_input_notifier.dart';

final messageInputProvider = StateNotifierProvider.family<MessageInputNotifier,
    MessageInputState, String>((ref, chatId) {
  return MessageInputNotifier(ref, chatId);
});
