import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/chat/chat_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';
import 'package:herdapp/core/barrels/providers.dart';
import 'package:herdapp/features/user/user_profile/view/providers/current_user_provider.dart';
import 'notifiers/optimistic_messages_notifier.dart';
import 'notifiers/messages_notifier.dart';
import 'state/messages_state.dart';

// Added back providers lost during refactor
final currentChatProvider =
    FutureProvider.family<ChatModel?, String>((ref, bubbleId) async {
  final repo = ref.watch(chatRepositoryProvider);
  final currentUserAsync = ref.watch(currentUserProvider);
  final currentUser = currentUserAsync.when(
    data: (u) => u,
    loading: () => null,
    error: (_, __) => null,
  );
  if (currentUser == null) throw Exception('User not authenticated');
  return repo.getChatByBubbleId(bubbleId, currentUser.id);
});

final optimisticMessagesProvider = StateNotifierProvider.family<
    OptimisticMessagesNotifier,
    Map<String, MessageModel>,
    String>((ref, chatId) => OptimisticMessagesNotifier(chatId));

final messagesProvider =
    StateNotifierProvider.family<MessagesNotifier, MessagesState, String>(
        (ref, chatId) {
  return MessagesNotifier(ref, chatId);
});

// Provider for getting an individual message by ID
// Use format "chatId:messageId" for the parameter
final messageProvider =
    StreamProvider.family<MessageModel?, String>((ref, chatMessageKey) {
  final messagesRepo = ref.watch(messageRepositoryProvider);
  final parts = chatMessageKey.split(':');
  if (parts.length != 2) {
    return Stream.value(null);
  }
  final chatId = parts[0];
  final messageId = parts[1];
  return messagesRepo.getMessageById(chatId, messageId);
});
