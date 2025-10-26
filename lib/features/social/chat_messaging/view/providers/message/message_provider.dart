import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:herdapp/features/social/chat_messaging/data/models/message/message_model.dart';
import 'package:herdapp/features/social/chat_messaging/data/repositories/chat_messaging_providers.dart';

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
