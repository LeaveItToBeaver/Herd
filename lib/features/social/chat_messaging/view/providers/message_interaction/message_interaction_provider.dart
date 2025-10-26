import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'state/message_interaction_state.dart';
import 'notifiers/message_interaction_notifier.dart';

final messageInteractionProvider = StateNotifierProvider.family<
    MessageInteractionNotifier, MessageInteractionState, String>(
  (ref, chatId) {
    final messageRepository = ref.watch(messageRepositoryProvider);
    return MessageInteractionNotifier(chatId, messageRepository);
  },
);
